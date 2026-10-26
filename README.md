<div align="center">

<img src="assets/icon/icon.png" width="112" alt="Anatomo icon">

# Anatomo

**Explore the human body in 3D. Offline, private and open source.**

[![Release](https://img.shields.io/github/v/release/lumio-apps/anatomo)](https://github.com/lumio-apps/anatomo/releases/latest)
[![CI](https://github.com/lumio-apps/anatomo/actions/workflows/ci.yml/badge.svg)](https://github.com/lumio-apps/anatomo/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/code-MIT-green)](LICENSE)
[![Data: CC BY 4.0](https://img.shields.io/badge/anatomy%20data-CC%20BY%204.0-blue)](ATTRIBUTION.md)

[**Download the latest APK**](https://github.com/lumio-apps/anatomo/releases/latest)

</div>

## Features

- **Real 3D bodies.** A male body (about 2,300 parts) and a female body (about 900 parts) from open scientific anatomy data.
- **Rotate, zoom and tap.** Drag to turn, pinch to zoom, tap any part to select it.
- **Spread slider.** Pull the body apart to see what sits inside.
- **Layers.** Turn skin, muscles, bones, organs, nerves and vessels on or off.
- **What each part does.** Every part opens a card: what it does, what is good for it, what harms it, and quick facts.
- **Parts list.** Search every part and jump to it in 3D.
- **Dark and light mode.** Follows the phone, or pick one in Settings.
- **13 languages.** English, Hindi, Armenian, Russian, Spanish, French, German, Arabic, Chinese, Portuguese, Japanese, Korean and Italian.
- **Updates inside the app.** Settings → Check for updates downloads the newest release from GitHub. Your settings are kept.
- **Offline and private.** No ads, no accounts, no tracking. See [PRIVACY.md](PRIVACY.md).

## Install

1. Open the [latest release](https://github.com/lumio-apps/anatomo/releases/latest) on your Android phone.
2. Download `Anatomo-vX.Y.Z.apk`.
3. Open it and allow installing from this source when Android asks.

Android 5.0 (API 21) or newer. A phone with 3 GB of RAM or more works best.

## Build

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release
```

## How it works

- The 3D viewer is [three.js](https://threejs.org) in a WebView. A small server inside the app (`127.0.0.1`, random port) serves the viewer and the models, so it works offline.
- Each layer is one merged mesh. Every vertex knows its part, and a small GPU texture stores each part's state (selected, faded, hidden) and spread offset. That keeps it to a few draw calls on phones.
- Tapping uses GPU picking: the part under your finger is drawn in an ID color into a 1×1 image.
- Texts for each part are in `assets/content/<lang>_a.json` and `<lang>_b.json`. App texts are in `lib/l10n/`.

## Project layout

```
assets/web/        viewer (index.html, viewer.js, three.js)
assets/models/     packed male and female bodies + manifest.json
assets/content/    part texts in 13 languages
lib/viewer/        local server and WebView bridge
lib/screens/       welcome, explore, parts list, settings
lib/l10n/          app texts (ARB)
tool/              scripts used to build models and ARB files
```

## Releases

Pushing a version tag such as `v1.0.0` starts the **Release** workflow. It builds the APK, signs it with the key stored in the repository secrets and publishes it on GitHub Releases. Pushes to `main` run the **CI** workflow (`flutter analyze` and `flutter test`).

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
