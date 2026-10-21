# Feral 3D

The model library, parametric CAD workflow, coloured model viewer and printer site live in this repository. Website source is at the root. `cad/` contains the complete model library, shared artwork, BOSL2 and CAD tools, with both original Git histories preserved.

## Models

```bash
utils/models.sh                      # stage every catalog entry and its available files
utils/models.sh --render-colours     # also export SCAD colours to GLB, using a cache
npm run dev -- --host 127.0.0.1 --strictPort
```

Open `/models` in the local website. Each model is listed once with its category, available views and downloads. Entries lacking a browser-readable mesh stay visible with their availability stated. GLB preserves the colours from SCAD; STL remains the printable geometry format. Original STL files carry no colour information.

```bash
utils/build.sh fence-pumpkins
utils/render.sh fence-pumpkins
utils/finalize.sh --all
utils/models.sh --push               # deliberate publication to the NAS; not a website deployment
```

Root CAD wrappers accept model IDs and former CAD-relative paths. See [CAD instructions](cad/AGENTS.md), [the model library](cad/library/README.md), [catalog workflow](docs/model-catalog.md), and [website architecture](docs/architecture.md). The existing printer monitor, authentication and video workflow remain in the website. Publishing models remains independent of rebuilding the website.

## Local checks

```bash
python3 cad/utils/library.py check
python3 cad/utils/test-library.py
python3 cad/utils/test-web-library.py
npm run build
```

Private runtime files remain local and ignored. Do not replace them with examples. The earlier website README is retained in [printer-site-readme.md](docs/printer-site-readme.md).
