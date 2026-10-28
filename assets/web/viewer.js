// Anatomo 3D viewer. Runs inside the app's WebView, fully offline.
// The Flutter side talks to it through window.anatomo (below) and receives
// events through the "AnatomoBridge" JavaScript channel.

import * as THREE from 'three';
import { OrbitControls } from './vendor/OrbitControls.js';
import { RoomEnvironment } from './vendor/RoomEnvironment.js';

const LAYERS = ['organs', 'bones', 'muscles', 'nerves', 'vessels', 'skin'];
const TEXW = 256; // two texels per part
const STATE_NORMAL = 0, STATE_SELECTED = 1, STATE_GHOST = 2, STATE_HIDDEN = 3;
const ROUGHNESS = { organs: 0.38, bones: 0.62, muscles: 0.5, nerves: 0.45, vessels: 0.4, skin: 0.55 };

function post(msg) {
  try {
    if (window.AnatomoBridge) window.AnatomoBridge.postMessage(JSON.stringify(msg));
  } catch (_) { /* ignore */ }
}

// ---------- renderer and scene ----------
// Graphics quality comes from the page address (?q=auto|low|medium|high).
// Anti-aliasing can only be chosen when the renderer is created.
const params = new URLSearchParams(location.search);
// ?atlas=1 is only used by tool/build_atlas.py to draw the 2D pictures.
const ATLAS = params.get('atlas') === '1';
const QUALITY = ['low', 'medium', 'high'].includes(params.get('q')) ? params.get('q') : 'auto';
const DPR = window.devicePixelRatio || 1;
// [sharp resolution, resolution while the finger moves]
const RATIOS = {
  low: [Math.min(DPR, 1), Math.min(DPR, 0.75)],
  medium: [Math.min(DPR, 1.5), Math.min(DPR, 1)],
  high: [Math.min(DPR, 2), Math.min(DPR, 1.25)],
};
let baseRatio = RATIOS[QUALITY === 'auto' ? 'medium' : QUALITY][0];
let moveRatio = RATIOS[QUALITY === 'auto' ? 'medium' : QUALITY][1];
let curRatio = baseRatio;
let lastMove = 0;
const renderer = new THREE.WebGLRenderer({
  antialias: ATLAS || QUALITY === 'high' || (QUALITY !== 'low' && DPR < 2),
  alpha: ATLAS,
  preserveDrawingBuffer: ATLAS,
  powerPreference: 'high-performance',
});
if (!renderer.capabilities.isWebGL2) {
  post({ type: 'error', code: 'webgl2' });
}
renderer.setPixelRatio(curRatio);
let stageColor = 0x0a1214;
renderer.setClearColor(stageColor, 1);
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.05;
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.localClippingEnabled = true;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const pickScene = new THREE.Scene();
const pmrem = new THREE.PMREMGenerator(renderer);
scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
const lightRig = new THREE.Group();
scene.add(lightRig);
lightRig.add(new THREE.HemisphereLight(0xdfeeee, 0x1a1010, 0.6));
const key = new THREE.DirectionalLight(0xffffff, 1.6); key.position.set(1.5, 3, 3); lightRig.add(key);
const rim = new THREE.DirectionalLight(0x7fd6cf, 0.8); rim.position.set(-2, 1.5, -3); lightRig.add(rim);
const fill = new THREE.DirectionalLight(0xffd9cc, 0.45); fill.position.set(-3, 0.5, 2); lightRig.add(fill);

const camera = new THREE.PerspectiveCamera(30, 1, 0.01, 50);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.12;
controls.minDistance = 0.12;
controls.maxDistance = 9;
controls.screenSpacePanning = true;

// ---------- state ----------
let manifest = null;
let parts = [];            // {index, id, name, key, side, layer, min, max, center, group}
let groups = new Map();    // group id -> {center, parts: []}
let keyParts = new Map();  // key -> [part index]
let partTex = null, texData = null;
let layerMeshes = {};      // layer -> {solid, ghost, pick}
let layerOn = { organs: true, bones: true, muscles: false, nerves: false, vessels: false, skin: true };
let selected = new Set();
let selectedKey = null;
let spread = 0, spreadShown = 0;
let bodyCenter = new THREE.Vector3(0, 0.85, 0);
let bodySize = new THREE.Vector3(0.7, 1.75, 0.3);
let inset = 0;             // part of the screen covered at the bottom (0..1)
let tween = null;
let dirty = true;
let loading = false;
let loadToken = 0;

const uniforms = { partTex: { value: null }, ghostOpacity: { value: 0.16 } };

// Cross-section: everything in front of this plane is cut away.
const cutPlane = new THREE.Plane(new THREE.Vector3(0, 0, -1), 100);
let cut = 0;
const cutUniform = { value: 100 };

let dragging = false;
function invalidate() { dirty = true; }
controls.addEventListener('change', invalidate);
controls.addEventListener('start', () => { dragging = true; lastMove = performance.now(); });
controls.addEventListener('end', () => { dragging = false; });
controls.autoRotateSpeed = 1.6;

function setRatio(r) {
  if (r === curRatio) return;
  curRatio = r;
  renderer.setPixelRatio(r);
  renderer.setSize(window.innerWidth, window.innerHeight, false);
  dirty = true;
}

function useQuality(level) {
  [baseRatio, moveRatio] = RATIOS[level];
  setRatio(baseRatio);
  invalidate();
}

// Auto quality: draw a few frames on a slowly turning camera, wait for the GPU
// each time, and pick the level from the time one frame takes.
let tuned = false;
function autoTune() {
  if (QUALITY !== 'auto' || tuned || loading || !parts.length) return;
  tuned = true;
  const gl = renderer.getContext();
  const px = new Uint8Array(4);
  const savedPos = camera.position.clone();
  setRatio(RATIOS.high[0]);
  const times = [];
  for (let i = 0; i < 6; i++) {
    camera.position.sub(controls.target).applyAxisAngle(camera.up, 0.12).add(controls.target);
    camera.lookAt(controls.target);
    const t0 = performance.now();
    renderer.render(scene, camera);
    gl.readPixels(0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, px);
    times.push(performance.now() - t0);
  }
  camera.position.copy(savedPos);
  camera.lookAt(controls.target);
  times.shift(); // the first frame also compiles shaders
  const ms = times.reduce((a, b) => a + b, 0) / times.length;
  const level = ms <= 24 ? 'high' : ms <= 50 ? 'medium' : 'low';
  useQuality(level);
  post({ type: 'quality', value: level, ms: Math.round(ms) });
}

// ---------- materials ----------
function patchMaterial(mat, ghost) {
  mat.onBeforeCompile = (shader) => {
    shader.uniforms.partTex = uniforms.partTex;
    shader.uniforms.ghostOpacity = uniforms.ghostOpacity;
    shader.vertexShader = shader.vertexShader
      .replace('#include <common>', `#include <common>
attribute float partIndex;
uniform highp sampler2D partTex;
varying vec3 vPartColor;
varying float vState;`)
      .replace('#include <begin_vertex>', `#include <begin_vertex>
int pIdx = int(partIndex + 0.5);
ivec2 c0 = ivec2((pIdx * 2) % ${TEXW}, (pIdx * 2) / ${TEXW});
vec4 t0 = texelFetch(partTex, c0, 0);
vec4 t1 = texelFetch(partTex, c0 + ivec2(1, 0), 0);
transformed += t0.xyz;
vState = t0.w;
vPartColor = t1.rgb;`);
    shader.fragmentShader = shader.fragmentShader
      .replace('#include <common>', `#include <common>
varying vec3 vPartColor;
varying float vState;
uniform float ghostOpacity;`)
      .replace('#include <color_fragment>', `#include <color_fragment>
#ifdef GHOST
  if (vState < 1.5 || vState > 2.5) discard;
  diffuseColor.a *= ghostOpacity;
#else
  if (vState > 1.5) discard;
#endif
  diffuseColor.rgb = vPartColor;`)
      .replace('#include <emissivemap_fragment>', `#include <emissivemap_fragment>
  if (vState > 0.5 && vState < 1.5) totalEmissiveRadiance += vPartColor * 0.22;`);
  };
  mat.customProgramCacheKey = () => (ghost ? 'anatomo-ghost' : 'anatomo-solid');
  return mat;
}

function makeSolid(layer) {
  return patchMaterial(new THREE.MeshStandardMaterial({
    roughness: ROUGHNESS[layer], metalness: 0, envMapIntensity: 0.9,
  }), false);
}

function makeGhost(layer) {
  const m = new THREE.MeshStandardMaterial({
    roughness: ROUGHNESS[layer], metalness: 0, envMapIntensity: 0.9,
    transparent: true, depthWrite: false,
  });
  m.defines = { GHOST: '' };
  return patchMaterial(m, true);
}

const pickMaterial = new THREE.ShaderMaterial({
  glslVersion: THREE.GLSL3,
  uniforms: { partTex: uniforms.partTex, pickGhost: { value: 0 }, cutZ: cutUniform },
  vertexShader: `
in float partIndex;
uniform highp sampler2D partTex;
flat out int vId;
out float vState;
out float vFlag;
out float vZ;
void main() {
  int pIdx = int(partIndex + 0.5);
  ivec2 c0 = ivec2((pIdx * 2) % ${TEXW}, (pIdx * 2) / ${TEXW});
  vec4 t0 = texelFetch(partTex, c0, 0);
  vec4 t1 = texelFetch(partTex, c0 + ivec2(1, 0), 0);
  vId = pIdx;
  vState = t0.w;
  vFlag = t1.w;
  vZ = (modelMatrix * vec4(position + t0.xyz, 1.0)).z;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position + t0.xyz, 1.0);
}`,
  fragmentShader: `
flat in int vId;
in float vState;
in float vFlag;
in float vZ;
uniform float pickGhost;
uniform float cutZ;
layout(location = 0) out highp vec4 pickColor;
void main() {
  if (vState > 2.5) discard;
  if (vZ > cutZ) discard;
  bool ghost = vState > 1.5;
  if (pickGhost < 0.5) {
    if (ghost) discard;
  } else {
    if (!ghost || vFlag > 0.5) discard;
  }
  int id = vId + 1;
  pickColor = vec4(float(id % 256) / 255.0, float(id / 256) / 255.0, 0.0, 1.0);
}`,
});
const pickTarget = new THREE.WebGLRenderTarget(1, 1);
const pickPixel = new Uint8Array(4);

// ---------- loading ----------
// A layer (organs, bones, muscles, ...) is downloaded from the app and built
// only when it is switched on. That keeps start-up fast and the GPU memory low.
let chunkBufs = new Map();   // chunk index -> ArrayBuffer (until its layer is built)
let layerJobs = new Map();   // layer -> Promise
let baseUrl = '';
let busyCount = 0;

async function fetchBuffer(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error('Could not load ' + url);
  return res.arrayBuffer();
}

function setBusy(delta) {
  const was = busyCount > 0;
  busyCount = Math.max(0, busyCount + delta);
  const now = busyCount > 0;
  if (was !== now && !loading) post({ type: 'busy', value: now });
}

function layerChunkIds(layer) {
  const man = manifest;
  if (!man) return [];
  const ids = [];
  man.chunks.forEach((_, i) => { if (man.chunkLayers[i] === layer) ids.push(i); });
  return ids;
}

function disposeModel() {
  for (const layer of Object.keys(layerMeshes)) {
    const m = layerMeshes[layer];
    scene.remove(m.solid); scene.remove(m.ghost); pickScene.remove(m.pick);
    m.solid.geometry.dispose();
    m.solid.material.dispose(); m.ghost.material.dispose();
  }
  layerMeshes = {};
  if (partTex) partTex.dispose();
  partTex = null; texData = null;
  uniforms.partTex.value = null;
  parts = []; groups = new Map(); keyParts = new Map();
  selected = new Set(); selectedKey = null;
  chunkBufs = new Map(); layerJobs = new Map(); busyCount = 0;
  stateNeeds = { solid: {}, ghost: {} };
  manifest = null;
  renderer.renderLists.dispose();
}

async function load(sex) {
  const token = ++loadToken;
  loading = true;
  post({ type: 'progress', value: 0 });
  disposeModel();
  invalidate();
  try {
    baseUrl = `models/${sex}/`;
    const man = JSON.parse(new TextDecoder().decode(await fetchBuffer(baseUrl + 'manifest.json')));
    if (token !== loadToken) return;
    buildParts(man);
    manifest = man;
    const wanted = LAYERS.filter((l) => layerOn[l] && layerChunkIds(l).length);
    const total = wanted.reduce((n, l) => n + layerChunkIds(l).length, 0);
    let done = 0;
    for (const layer of wanted) {
      await ensureLayer(layer, token, () => post({ type: 'progress', value: ++done / (total + 1) }));
      if (token !== loadToken) return;
    }
    loading = false;
    applyLayers();
    setCut(cut);
    resetView(false);
    post({ type: 'ready', sex, parts: parts.length });
    setTimeout(autoTune, 600);
  } catch (e) {
    if (token === loadToken) {
      loading = false;
      post({ type: 'error', code: 'load', message: String(e && e.message || e) });
    }
  }
}

function ensureLayer(layer, token = loadToken, onChunk = null) {
  if (layerMeshes[layer]) return Promise.resolve(true);
  const running = layerJobs.get(layer);
  if (running) return running;
  const job = (async () => {
    const man = manifest;
    const ids = layerChunkIds(layer);
    for (const i of ids) {
      if (!chunkBufs.has(i)) chunkBufs.set(i, await fetchBuffer(baseUrl + man.chunks[i]));
      if (token !== loadToken) return false;
      if (onChunk) onChunk();
    }
    if (token !== loadToken) return false;
    buildLayer(layer);
    for (const i of ids) chunkBufs.delete(i); // a chunk holds one layer only
    return true;
  })();
  layerJobs.set(layer, job);
  const clear = () => { if (layerJobs.get(layer) === job) layerJobs.delete(layer); };
  job.then(clear, clear);
  return job;
}

/** Switches on a layer that is not built yet; shows a small busy signal. */
function wantLayer(layer) {
  if (!manifest || layerMeshes[layer] || !layerChunkIds(layer).length) return;
  const token = loadToken;
  setBusy(1);
  ensureLayer(layer).then((ok) => {
    if (ok && token === loadToken) applyLayers();
  }).catch(() => {
    if (token !== loadToken) return;
    layerOn[layer] = false;
    post({ type: 'layers', layers: layerOn });
    applyLayers();
  }).finally(() => { if (token === loadToken) setBusy(-1); });
}

function buildParts(man) {
  const F = {};
  man.fields.forEach((f, i) => { F[f] = i; });
  if (!man.chunkLayers) throw new Error('Model files are outdated');
  const [lo, hi] = man.bounds;
  bodyCenter.set((lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, (lo[2] + hi[2]) / 2);
  bodySize.set(hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2]);

  parts = man.parts.map((r, index) => {
    const k = r[F.key];
    const min = new THREE.Vector3(r[F.minX], r[F.minY], r[F.minZ]);
    const max = new THREE.Vector3(r[F.maxX], r[F.maxY], r[F.maxZ]);
    const info = man.keys[k];
    return {
      index, id: r[F.id], name: r[F.name], key: k, side: r[F.side],
      layer: info.layer, whole: info.whole,
      chunk: r[F.chunk], pos: r[F.positions], nrm: r[F.normals], idx: r[F.indices],
      vc: r[F.vertexCount], ic: r[F.indexCount],
      min, max, center: min.clone().add(max).multiplyScalar(0.5),
    };
  });

  for (const p of parts) {
    if (!keyParts.has(p.key)) keyParts.set(p.key, []);
    keyParts.get(p.key).push(p.index);
    const g = p.whole ? `${p.key}:${p.side}` : `p${p.index}`;
    p.group = g;
    if (!groups.has(g)) groups.set(g, { min: p.min.clone(), max: p.max.clone(), parts: [] });
    const gr = groups.get(g);
    gr.min.min(p.min); gr.max.max(p.max); gr.parts.push(p.index);
  }
  for (const g of groups.values()) g.center = g.min.clone().add(g.max).multiplyScalar(0.5);

  // part texture: [offset.xyz, state] [color.rgb, flag]
  const rows = Math.ceil((parts.length * 2) / TEXW);
  texData = new Float32Array(TEXW * rows * 4);
  const color = new THREE.Color();
  for (const p of parts) {
    color.set(man.keys[p.key].color);
    // small, stable variation so neighbouring pieces can be told apart
    let h = 0;
    for (let i = 0; i < p.id.length; i++) h = (h * 31 + p.id.charCodeAt(i)) >>> 0;
    const v = 0.9 + ((h % 1000) / 1000) * 0.2;
    const o = (p.index * 2 + 1) * 4;
    texData[o] = color.r * v; texData[o + 1] = color.g * v; texData[o + 2] = color.b * v;
    texData[o + 3] = p.layer === 'skin' ? 1 : 0;
  }
  partTex = new THREE.DataTexture(texData, TEXW, rows, THREE.RGBAFormat, THREE.FloatType);
  partTex.minFilter = THREE.NearestFilter;
  partTex.magFilter = THREE.NearestFilter;
  partTex.needsUpdate = true;
  uniforms.partTex.value = partTex;
  writeOffsets();
}

/** Merges all parts of one layer into a single geometry (few draw calls). */
function buildLayer(layer) {
  const list = parts.filter((p) => p.layer === layer);
  if (!list.length || layerMeshes[layer]) return;
  let vc = 0, ic = 0;
  for (const p of list) { vc += p.vc; ic += p.ic; }
  const pos = new Float32Array(vc * 3);
  const nrm = new Int16Array(vc * 3);
  const pid = new Uint16Array(vc);
  const idx = new Uint32Array(ic);
  let vo = 0, io = 0;
  for (const p of list) {
    const buf = chunkBufs.get(p.chunk);
    pos.set(new Float32Array(buf, p.pos, p.vc * 3), vo * 3);
    nrm.set(new Int16Array(buf, p.nrm, p.vc * 3), vo * 3);
    pid.fill(p.index, vo, vo + p.vc);
    const src = new Uint32Array(buf, p.idx, p.ic);
    for (let i = 0; i < p.ic; i++) idx[io + i] = src[i] + vo;
    vo += p.vc; io += p.ic;
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  geo.setAttribute('normal', new THREE.BufferAttribute(nrm, 3, true));
  geo.setAttribute('partIndex', new THREE.BufferAttribute(pid, 1));
  geo.setIndex(new THREE.BufferAttribute(idx, 1));
  const solid = new THREE.Mesh(geo, makeSolid(layer));
  const ghost = new THREE.Mesh(geo, makeGhost(layer));
  applyCutTo(solid.material);
  applyCutTo(ghost.material);
  const pick = new THREE.Mesh(geo, pickMaterial);
  for (const m of [solid, ghost, pick]) m.frustumCulled = false;
  ghost.renderOrder = 1;
  scene.add(solid); scene.add(ghost); pickScene.add(pick);
  layerMeshes[layer] = { solid, ghost, pick };
}

// ---------- states, layers, spread ----------
let stateNeeds = { solid: {}, ghost: {} };

function writeStates() {
  if (!texData) return;
  const anySel = selected.size > 0;
  const solid = {}, ghost = {};
  for (const p of parts) {
    let s;
    if (selected.has(p.index)) s = STATE_SELECTED;
    else if (anySel || p.layer === 'skin') s = STATE_GHOST;
    else s = STATE_NORMAL;
    texData[p.index * 8 + 3] = s;
    if (s === STATE_GHOST) ghost[p.layer] = true; else solid[p.layer] = true;
  }
  uniforms.ghostOpacity.value = anySel ? 0.1 : 0.16;
  partTex.needsUpdate = true;
  stateNeeds = { solid, ghost };
  updateVisibility();
  invalidate();
}

/** A pass is drawn only when the layer has parts in that state. */
function updateVisibility() {
  for (const layer of Object.keys(layerMeshes)) {
    const m = layerMeshes[layer];
    const on = !!layerOn[layer];
    m.pick.visible = on;
    m.solid.visible = on && !!stateNeeds.solid[layer];
    m.ghost.visible = on && !!stateNeeds.ghost[layer];
  }
}

function writeOffsets() {
  if (!texData) return;
  const k = spreadShown * 1.15;
  for (const p of parts) {
    const g = groups.get(p.group);
    const o = p.index * 8;
    texData[o] = (g.center.x - bodyCenter.x) * 1.9 * k;
    texData[o + 1] = (g.center.y - bodyCenter.y) * 0.45 * k;
    texData[o + 2] = (g.center.z - bodyCenter.z) * 2.6 * k + (p.layer === 'organs' ? 0.12 * k : 0);
  }
  partTex.needsUpdate = true;
}

function applyLayers() {
  writeStates();
}

// ---------- cross-section ----------
function applyCutTo(mat) {
  const on = cut > 0.001;
  const planes = on ? [cutPlane] : null;
  const side = on ? THREE.DoubleSide : THREE.FrontSide;
  if ((mat.clippingPlanes ? 1 : 0) !== (planes ? 1 : 0) || mat.side !== side) {
    mat.clippingPlanes = planes;
    mat.side = side;
    mat.needsUpdate = true;
  }
}

function setCut(v) {
  cut = Math.max(0, Math.min(1, Number(v) || 0));
  const front = bodyCenter.z + bodySize.z / 2 + 0.01;
  const depth = bodySize.z + 0.02;
  const z = cut > 0.001 ? front - cut * depth : 100;
  cutPlane.constant = z; // keeps points with z <= constant
  cutUniform.value = z;
  for (const layer of Object.keys(layerMeshes)) {
    applyCutTo(layerMeshes[layer].solid.material);
    applyCutTo(layerMeshes[layer].ghost.material);
  }
  invalidate();
}

// ---------- labels ----------
let labelNames = null;       // key -> name, or null when labels are off
let labelEls = new Map();    // key -> element
const labelBox = document.createElement('div');
labelBox.style.cssText = 'position:fixed;left:0;top:0;right:0;bottom:0;pointer-events:none;overflow:hidden;';
document.body.appendChild(labelBox);
let labelLight = false;
const LABEL_ORDER = ['organs', 'bones', 'muscles', 'vessels', 'nerves', 'skin'];

function clearLabels() {
  for (const el of labelEls.values()) el.remove();
  labelEls = new Map();
}

function labelStyle(el) {
  el.style.background = labelLight ? 'rgba(255,255,255,0.92)' : 'rgba(18,29,32,0.88)';
  el.style.color = labelLight ? '#0E1A1C' : '#E8F0EF';
  el.style.borderColor = labelLight ? '#E2E8E7' : '#22302F';
}

function setLabels(map) {
  clearLabels();
  labelNames = map && typeof map === 'object' ? map : null;
  if (!labelNames) { invalidate(); return; }
  for (const [k, name] of Object.entries(labelNames)) {
    const el = document.createElement('div');
    el.textContent = String(name);
    el.style.cssText = 'position:absolute;left:0;top:0;padding:3px 8px;border-radius:10px;'
      + 'border:1px solid;font:600 11px system-ui,sans-serif;white-space:nowrap;display:none;'
      + 'box-shadow:0 2px 6px rgba(0,0,0,0.18);';
    labelStyle(el);
    labelBox.appendChild(el);
    labelEls.set(k, el);
  }
  invalidate();
}

const tmpV = new THREE.Vector3();
function updateLabels() {
  if (!labelNames || !parts.length) {
    for (const el of labelEls.values()) el.style.display = 'none';
    return;
  }
  const w = window.innerWidth, h = window.innerHeight;
  const placed = [];
  const keys = [...labelEls.keys()].filter((k) => keyParts.has(k));
  keys.sort((a, b) => LABEL_ORDER.indexOf(parts[keyParts.get(a)[0]].layer)
    - LABEL_ORDER.indexOf(parts[keyParts.get(b)[0]].layer));
  for (const k of keys) {
    const el = labelEls.get(k);
    const first = parts[keyParts.get(k)[0]];
    let show = !!layerOn[first.layer] && !!layerMeshes[first.layer] && first.layer !== 'skin';
    if (show && selected.size) show = selectedKey === k;
    if (show) {
      const g = groups.get(first.group);
      tmpV.copy(g.center).add(offsetOf(first));
      if (cut > 0.001 && tmpV.z > cutPlane.constant) show = false;
    }
    if (show) {
      tmpV.project(camera);
      if (tmpV.z > 1 || tmpV.x < -1 || tmpV.x > 1 || tmpV.y < -1 || tmpV.y > 1) show = false;
    }
    if (!show) { el.style.display = 'none'; continue; }
    const x = (tmpV.x + 1) / 2 * w;
    const y = (1 - tmpV.y) / 2 * h;
    const lw = el.textContent.length * 6.4 + 18, lh = 22;
    const r = { l: x - lw / 2, t: y - lh / 2, r: x + lw / 2, b: y + lh / 2 };
    if (placed.some((p) => r.l < p.r && r.r > p.l && r.t < p.b && r.b > p.t)) {
      el.style.display = 'none';
      continue;
    }
    placed.push(r);
    el.style.display = 'block';
    el.style.transform = `translate(${Math.round(r.l)}px, ${Math.round(r.t)}px)`;
  }
}

function offsetOf(p) {
  const o = p.index * 8;
  return new THREE.Vector3(texData[o], texData[o + 1], texData[o + 2]);
}

// ---------- camera ----------
function fitDistance(size) {
  const t = Math.tan(THREE.MathUtils.degToRad(camera.fov / 2));
  const visible = 1 - inset;
  const h = size.y / 2 / (t * visible);
  const w = Math.max(size.x, size.z) / 2 / (t * camera.aspect);
  return Math.max(h, w) * 1.12;
}

function flyTo(target, dist, dir) {
  const d = (dir ? dir.clone() : camera.position.clone().sub(controls.target)).normalize();
  tween = {
    fp: camera.position.clone(), tp: target.clone().addScaledVector(d, dist),
    ft: controls.target.clone(), tt: target.clone(), t: 0,
  };
  invalidate();
}

function resetView(animate = true) {
  const size = bodySize.clone();
  const dist = fitDistance(size);
  const dir = new THREE.Vector3(0, 0.08, 1);
  if (!animate) {
    controls.target.copy(bodyCenter);
    camera.position.copy(bodyCenter).addScaledVector(dir.normalize(), dist);
    controls.update();
    invalidate();
    return;
  }
  flyTo(bodyCenter, dist, dir);
}

function setView(name) {
  const dirs = { front: [0, 0.08, 1], back: [0, 0.08, -1], side: [1, 0.08, 0], left: [-1, 0.08, 0] };
  const d = dirs[name] || dirs.front;
  flyTo(controls.target.clone(), camera.position.distanceTo(controls.target), new THREE.Vector3(...d));
}

function applyInset() {
  const w = window.innerWidth, h = window.innerHeight;
  if (inset > 0) camera.setViewOffset(w, h, 0, Math.round(h * inset / 2), w, h);
  else camera.clearViewOffset();
  camera.updateProjectionMatrix();
  invalidate();
}

function focusSelection() {
  if (!selected.size) return;
  const box = new THREE.Box3();
  for (const i of selected) {
    const p = parts[i];
    const off = offsetOf(p);
    box.expandByPoint(p.min.clone().add(off));
    box.expandByPoint(p.max.clone().add(off));
  }
  const size = box.getSize(new THREE.Vector3());
  const center = box.getCenter(new THREE.Vector3());
  const dist = Math.max(fitDistance(size.clone().multiplyScalar(1.25)), 0.22);
  flyTo(center, dist);
}

// ---------- selection ----------
function selectIndices(list, keyName, fromTap) {
  const first = parts[list[0]];
  if (!layerMeshes[first.layer]) {
    // the layer is not loaded yet: load it, then select
    layerOn[first.layer] = true;
    post({ type: 'layers', layers: layerOn });
    const token = loadToken;
    setBusy(1);
    ensureLayer(first.layer).then((ok) => {
      if (ok && token === loadToken) selectIndices(list, keyName, fromTap);
    }).catch(() => {}).finally(() => { if (token === loadToken) setBusy(-1); });
    return;
  }
  selected = new Set(list);
  selectedKey = keyName;
  if (!layerOn[first.layer]) {
    layerOn[first.layer] = true;
    applyLayers();
    post({ type: 'layers', layers: layerOn });
  }
  writeStates();
  focusSelection();
  post({
    type: 'select', key: first.key, partId: first.whole ? null : first.id,
    name: first.name, layer: first.layer, whole: first.whole, count: list.length, tap: !!fromTap,
  });
}

function selectPartIndex(i, fromTap) {
  const p = parts[i];
  if (!p) return;
  if (p.whole) selectIndices(keyParts.get(p.key), p.key, fromTap);
  else selectIndices([i], p.key, fromTap);
}

function clearSelection(notify) {
  if (!selected.size) return;
  selected = new Set();
  selectedKey = null;
  writeStates();
  if (notify) post({ type: 'clear' });
}

function pickAt(x, y) {
  if (!parts.length) return -1;
  const w = window.innerWidth, h = window.innerHeight;
  const offY = inset > 0 ? Math.round(h * inset / 2) : 0;
  for (const ghostPass of [0, 1]) {
    pickMaterial.uniforms.pickGhost.value = ghostPass;
    camera.setViewOffset(w, h, Math.round(x), Math.round(y) + offY, 1, 1);
    camera.updateProjectionMatrix();
    renderer.setRenderTarget(pickTarget);
    renderer.setClearColor(0x000000, 0);
    renderer.clear();
    renderer.render(pickScene, camera);
    renderer.readRenderTargetPixels(pickTarget, 0, 0, 1, 1, pickPixel);
    renderer.setRenderTarget(null);
    renderer.setClearColor(stageColor, 1);
    const id = pickPixel[0] + pickPixel[1] * 256;
    if (id > 0) { applyInset(); return id - 1; }
  }
  applyInset();
  return -1;
}

// tap = short press without moving
let down = null;
renderer.domElement.addEventListener('pointerdown', (e) => {
  down = { x: e.clientX, y: e.clientY, t: performance.now(), id: e.pointerId };
  tween = null;
});
renderer.domElement.addEventListener('pointerup', (e) => {
  if (!down || down.id !== e.pointerId) return;
  const moved = Math.hypot(e.clientX - down.x, e.clientY - down.y);
  const quick = performance.now() - down.t < 450;
  down = null;
  if (moved > 8 || !quick || loading) return;
  const i = pickAt(e.clientX, e.clientY);
  if (i >= 0) {
    if (selected.has(i) && selected.size === 1 && !parts[i].whole) return;
    if (selected.has(i) && parts[i].whole && selectedKey === parts[i].key) return;
    selectPartIndex(i, true);
  } else if (selected.size) {
    clearSelection(true);
  }
});
renderer.domElement.addEventListener('pointercancel', () => { down = null; });

renderer.domElement.addEventListener('webglcontextlost', (e) => {
  e.preventDefault();
  post({ type: 'error', code: 'context' });
});

// ---------- sizing and loop ----------
function resize() {
  const w = window.innerWidth, h = window.innerHeight;
  renderer.setSize(w, h, false);
  camera.aspect = w / h;
  applyInset();
}
window.addEventListener('resize', resize);
resize();

function tick() {
  requestAnimationFrame(tick);
  let moving = false;
  if (tween) {
    tween.t = Math.min(1, tween.t + 0.05);
    const e = 1 - Math.pow(1 - tween.t, 3);
    camera.position.lerpVectors(tween.fp, tween.tp, e);
    controls.target.lerpVectors(tween.ft, tween.tt, e);
    if (tween.t >= 1) tween = null;
    moving = true;
  }
  if (Math.abs(spread - spreadShown) > 1e-4) {
    spreadShown += (spread - spreadShown) * 0.2;
    if (Math.abs(spread - spreadShown) <= 1e-4) spreadShown = spread;
    writeOffsets();
    moving = true;
  }
  const changed = controls.update();
  const now = performance.now();
  // lower resolution while the finger moves the view, sharp again when it
  // stops (the slow auto-rotation stays sharp)
  if (moving || dragging || (changed && !controls.autoRotate)) lastMove = now;
  setRatio(now - lastMove < 220 ? moveRatio : baseRatio);
  if (!(moving || changed || dirty)) return;
  dirty = false;
  renderer.render(scene, camera);
  if (labelNames) updateLabels();
}
if (!ATLAS) tick();

// ---------- API for Flutter ----------
window.anatomo = {
  load(sex) { load(sex === 'female' ? 'female' : 'male'); },
  setLayers(map) {
    for (const k of LAYERS) if (k in map) layerOn[k] = !!map[k];
    if (selected.size) {
      const p = parts[[...selected][0]];
      if (p && !layerOn[p.layer]) clearSelection(true);
    }
    applyLayers();
    for (const k of LAYERS) if (layerOn[k]) wantLayer(k);
  },
  setView(name) { setView(name); },
  reset() { clearSelection(false); resetView(true); },
  setTheme(mode) {
    stageColor = mode === 'light' ? 0xf3f6f5 : 0x0a1214;
    renderer.setClearColor(stageColor, 1);
    document.body.style.background = mode === 'light' ? '#F3F6F5' : '#0A1214';
    labelLight = mode === 'light';
    for (const el of labelEls.values()) labelStyle(el);
    invalidate();
  },
  setAutoRotate(on) { controls.autoRotate = !!on; invalidate(); },
  setCut(v) { setCut(v); },
  setLabels(map) { setLabels(map); },
  setSpread(v) { spread = Math.max(0, Math.min(1, Number(v) || 0)); invalidate(); },
  setInset(v) {
    inset = Math.max(0, Math.min(0.7, Number(v) || 0));
    applyInset();
    if (selected.size) focusSelection();
  },
  selectKey(k) {
    const list = keyParts.get(k);
    if (!list || !list.length) return false;
    const p = parts[list[0]];
    if (p.whole) selectIndices(list, k, false);
    else selectIndices([list[0]], k, false);
    return true;
  },
  selectPart(id) {
    const p = parts.find((x) => x.id === id);
    if (!p) return false;
    selectPartIndex(p.index, false);
    return true;
  },
  clear() { clearSelection(false); if (!tween) resetView(true); },
  focus() { focusSelection(); },
};

// ---------- offline 2D pictures (tool/build_atlas.py) ----------
if (ATLAS) {
  const VIEWS = { front: [0, 0], back: [Math.PI, 0], side: [Math.PI / 2, 1] };
  window.anatomoAtlas = {
    async open(sex) {
      await load(sex);
      for (const layer of LAYERS) await ensureLayer(layer);
      return { parts: parts.length, bounds: manifest.bounds };
    },
    /** Draws the given layers from one side; kind 'color' or 'ids'. */
    shot(view, layers, height, kind) {
      const [yaw, axis] = VIEWS[view];
      const [lo, hi] = manifest.bounds;
      const margin = 0.02;
      const h0 = lo[1] - margin, h1 = hi[1] + margin;
      // front: x to the right; back: x to the left; side (from +x): z to the left
      const a0 = (axis ? lo[2] : lo[0]) - margin;
      const a1 = (axis ? hi[2] : hi[0]) + margin;
      const width = Math.round(height * (a1 - a0) / (h1 - h0));
      const cam = new THREE.OrthographicCamera();
      const mid = (a0 + a1) / 2, half = (a1 - a0) / 2;
      cam.left = -half; cam.right = half; cam.top = (h1 - h0) / 2; cam.bottom = -(h1 - h0) / 2;
      cam.near = 0.01; cam.far = 10;
      const cy = (h0 + h1) / 2;
      if (view === 'front') { cam.position.set(mid, cy, 3); cam.lookAt(mid, cy, 0); }
      else if (view === 'back') { cam.position.set(mid, cy, -3); cam.lookAt(mid, cy, 0); }
      else { cam.position.set(3, cy, mid); cam.lookAt(0, cy, mid); }
      cam.updateProjectionMatrix();
      lightRig.rotation.y = yaw;

      for (const l of LAYERS) layerOn[l] = layers.includes(l);
      for (const p of parts) texData[p.index * 8 + 3] = STATE_NORMAL;
      partTex.needsUpdate = true;
      stateNeeds = { solid: Object.fromEntries(LAYERS.map((l) => [l, true])), ghost: {} };
      updateVisibility();

      renderer.setPixelRatio(1);
      renderer.setSize(width, height, false);
      if (kind === 'color') {
        renderer.setRenderTarget(null);
        renderer.setClearColor(0x000000, 0);
        renderer.clear();
        renderer.render(scene, cam);
        return { width, height, data: renderer.domElement.toDataURL('image/png') };
      }
      const target = new THREE.WebGLRenderTarget(width, height);
      pickMaterial.uniforms.pickGhost.value = 0;
      renderer.setRenderTarget(target);
      renderer.setClearColor(0x000000, 0);
      renderer.clear();
      renderer.render(pickScene, cam);
      const px = new Uint8Array(width * height * 4);
      renderer.readRenderTargetPixels(target, 0, 0, width, height, px);
      renderer.setRenderTarget(null);
      target.dispose();
      const canvas = document.createElement('canvas');
      canvas.width = width; canvas.height = height;
      const ctx = canvas.getContext('2d');
      const img = ctx.createImageData(width, height);
      for (let y = 0; y < height; y++) {
        const src = (height - 1 - y) * width * 4, dst = y * width * 4;
        for (let x = 0; x < width * 4; x += 4) {
          img.data[dst + x] = px[src + x];
          img.data[dst + x + 1] = px[src + x + 1];
          img.data[dst + x + 2] = 0;
          img.data[dst + x + 3] = 255;
        }
      }
      ctx.putImageData(img, 0, 0);
      return { width, height, data: canvas.toDataURL('image/png') };
    },
  };
}

post({ type: 'boot' });
