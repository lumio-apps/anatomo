<div align="center">

<img src="assets/icon/icon.png" width="112" alt="Anatomo icon">

# Anatomo

**Explore the human body in 2D and 3D. Offline, private and open source. For Android and Windows.**

[![Release](https://img.shields.io/github/v/release/lumio-apps/anatomo)](https://github.com/lumio-apps/anatomo/releases/latest)
[![CI](https://github.com/lumio-apps/anatomo/actions/workflows/ci.yml/badge.svg)](https://github.com/lumio-apps/anatomo/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/code-MIT-green)](LICENSE)
[![Data: CC BY 4.0](https://img.shields.io/badge/anatomy%20data-CC%20BY%204.0-blue)](ATTRIBUTION.md)

[**Download for Android or Windows**](https://github.com/lumio-apps/anatomo/releases/latest)

</div>

## Features

- **Real bodies.** A male body (about 2,300 parts) and a female body (about 1,500 parts) from open scientific anatomy data. The female skeleton and muscles are adapted from the male body.
- **2D, light and fast.** The app shows sharp pictures of the body drawn from the 3D models, from the front, back and side. Pinch or scroll to zoom, tap any part to open it.
- **3D pack (Android).** Download it once from Settings (about 68 MB) to turn the body in 3D and use the **Spread slider** to pull it apart. Switch between 2D and 3D under the body.
- **Layers.** Turn skin, muscles, bones, organs, nerves and vessels on or off.
- **What each part does.** Every part opens a card: what it does, what is good for it, what harms it, and quick facts.
- **Favorites.** Tap the star on a part to keep it; find it again under Favorites in the parts list.
- **Quiz.** Ten questions made from the part texts, in your language, with a best score.
- **Copy.** Copy the texts of a part to the clipboard.
- **Parts list.** Search every part and jump to it on the body.
- **Windows.** A wide layout with a side bar, the body in the middle and the part card on the right. Ctrl + F searches, Esc closes the card.
- **Dark and light mode.** Follows the phone, or pick one in Settings.
- **13 languages.** English, Hindi, Armenian, Russian, Spanish, French, German, Arabic, Chinese, Portuguese, Japanese, Korean and Italian.
- **Fast on phones.** The app itself is small and draws pictures, not 3D. In 3D, layers load only when you switch them on, the view drops to a lower resolution while you move it, and the Graphics setting (Auto, Low, Medium, High) fits it to your phone.
- **Updates inside the app.** Settings → Check for updates downloads the newest release from GitHub (the APK on Android, the installer on Windows). Your settings and favorites are kept.
- **Offline and private.** No ads, no accounts, no tracking. See [PRIVACY.md](PRIVACY.md).

## Install

**Android**

1. Open the [latest release](https://github.com/lumio-apps/anatomo/releases/latest) on your phone.
2. Download `Anatomo-vX.Y.Z.apk`.
3. Open it and allow installing from this source when Android asks.

Android 5.0 (API 21) or newer. For the 3D pack, a phone with 3 GB of RAM or more works best.

**Windows**

1. Download `Anatomo-vX.Y.Z-windows-setup.exe` from the [latest release](https://github.com/lumio-apps/anatomo/releases/latest).
2. Run it. The installer is not signed, so Windows may show "Windows protected your PC": choose **More info → Run anyway**.

Windows 10 or 11, 64-bit. No administrator rights needed.

## Build

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

The body data is built with Python (NumPy, Pillow, Playwright):

```sh
python3 tool/build_models.py <human-atlas checkout> <female data dir> pack/models
python3 tool/fit_female.py pack/models
python3 tool/repack_by_layer.py pack/models
python3 tool/build_atlas.py pack/models assets/web assets/atlas
```

## How it works

- The 2D view shows pictures drawn from the 3D models by `tool/build_atlas.py`: one picture for each side and each mix of layers, plus a "tap map" in which every pixel holds the number of the part drawn there. A tap reads that number.
- The 3D viewer is [three.js](https://threejs.org) in a WebView. A small server inside the app (`127.0.0.1`, random port) serves the viewer and the models of the downloaded 3D pack, so it works offline.
- Model files are split by layer (`tool/repack_by_layer.py`), so organs, bones and skin load first and muscles, nerves and vessels load when you switch them on.
- Each layer is one merged mesh. Every vertex knows its part, and a small GPU texture stores each part's state (selected, faded, hidden) and spread offset. That keeps it to a few draw calls on phones.
- Tapping uses GPU picking: the part under your finger is drawn in an ID color into a 1×1 image.
- Texts for each part are in `assets/content/<lang>_a.json` and `<lang>_b.json`. App texts are in `lib/l10n/`.

## Project layout

```
assets/atlas/      2D pictures and tap maps (front, back, side) + atlas.json
assets/web/        3D viewer (index.html, viewer.js, three.js)
assets/content/    part texts in 13 languages
pack/models/       3D bodies (the 3D pack, not inside the app)
installer/         Windows installer script (Inno Setup)
lib/atlas/         2D view
lib/pack/          3D pack download
lib/viewer/        local server and WebView bridge (3D)
lib/screens/       welcome, explore, parts list, quiz, settings
lib/l10n/          app texts (ARB)
tool/              scripts used to build models and ARB files
```

## Releases

Pushing a version tag such as `v2.0.0` starts the **Release** workflow. It builds and signs the APK, builds the Windows app and its installer, and publishes both on GitHub Releases. Pushes to `main` run the **CI** workflow (`flutter analyze` and `flutter test`).

The 3D pack is published separately: pushing a tag such as `pack-1` starts the **3D pack** workflow, which compresses `pack/models` and uploads it as a pre-release (it is not marked as the latest app release). The app downloads the pack whose number is `kPackVersion` in `lib/pack/pack3d.dart`.

Required repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.

## Credits

Anatomy data: BodyParts3D 4.0 (© The Database Center for Life Science) and the Human Reference Atlas / HuBMAP female reference organ set v1.5, both CC BY 4.0, packed by [human-atlas](https://github.com/ashemag/human-atlas). Full details and changes in [ATTRIBUTION.md](ATTRIBUTION.md).

## Disclaimer

Anatomo is for learning only. It is not medical advice. Talk to a doctor about your health.

## License

Code: MIT, see [LICENSE](LICENSE). Anatomy data: CC BY 4.0, see [ATTRIBUTION.md](ATTRIBUTION.md).

---

<div align="center">

Made by [Lumio Apps](https://github.com/lumio-apps)

</div>
