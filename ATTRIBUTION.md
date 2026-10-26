# Attribution

Anatomo's own code is MIT licensed (see [LICENSE](LICENSE)). The 3D anatomy data and the libraries below keep their own licenses. Keep this file when you share the app or its data.

## Male body: BodyParts3D 4.0

BodyParts3D, © The Database Center for Life Science, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

- License: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html
- Dataset: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html
- Paper: Mitsuhashi et al. (2009), *BodyParts3D: 3D structure database for anatomical concepts*. https://doi.org/10.1093/nar/gkn613

## Female body: Human Reference Atlas (HuBMAP)

Kristen Browne and Heidi Schlehlein, Human Reference Atlas / HuBMAP, *3D Reference Organ Set for Female v1.5* (2023), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

- DOI: https://doi.org/10.48539/HBM352.BTSQ.586
- Dataset: https://lod.humanatlas.io/ref-organ/united-female/v1.5

## Packed geometry: human-atlas

Both models were taken from the browser-ready packs of [ashemag/human-atlas](https://github.com/ashemag/human-atlas) (MIT License, © 2026 ashemag), which simplified the geometry (0.2% error limit per structure), converted units and axes, and quantized normals.

## Changes made for Anatomo

`tool/build_models.py` made these changes:

- Re-packed the parts into one set of files per body, grouped by layer (organs, bones, muscles, nerves, vessels, skin), with a short key per part for the info cards.
- **Lungs and liver in the male body.** BodyParts3D has no solid lung or liver tissue, only airways and vessels. The female lung segments and liver from the HuBMAP set were scaled and moved to fit the male chest and abdomen. They are marked `fitted` in the manifest. They show where the organs sit, not their exact male shape.
- The female set covers the whole skin surface and many organs, but its skeleton and muscles are partial.
- Colors and groupings were chosen for this app.

## Libraries

- [three.js](https://threejs.org) r160 (MIT): `assets/web/vendor/three.module.min.js`, `OrbitControls.js`, `RoomEnvironment.js`. License in `assets/web/vendor/three-LICENSE.txt`.
- Flutter packages are listed in `pubspec.yaml`. Each keeps its own license.

## Medical note

Anatomo is for learning. The models are reference anatomy, not any real person, and do not show every structure or every variation. The health tips are general and are not medical advice.
