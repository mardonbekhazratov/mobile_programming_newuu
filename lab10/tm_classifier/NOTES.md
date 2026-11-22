# Lab 10 – Teachable Machine classifier (Lens)

## Part 1 – Model

Classes (same order as `labels.txt`):

| # | Class | Samples |
|---|-------|---------|
| 0 | _fill in_ | |
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | Nothing (background) | |

- **Object from none of the classes?** The softmax output always sums to 1, so the model still picks
  one of the trained classes, often with a high percentage. It has no "unknown" answer. The background
  class gives it somewhere to put "no trained object here", so empty or unfamiliar scenes go there
  instead of being forced onto a real object. It only helps for scenes that look like the background
  samples, though.
- **Floating point vs quantized.** The float model (`model_unquant.tflite`) stores 32-bit weights:
  about 4× bigger, float32 input in −1…1, output already probabilities. The quantized one stores 8-bit
  weights: smaller and faster, but slightly less accurate. Its input is uint8 0…255 (no normalisation)
  and its output is uint8, so you divide by 255. `Classifier` reads the input tensor type and handles
  both (`toFloatTensor` / `toUint8Tensor`).

## Part 2 – Setup

- **`assets/model/` vs `assets/`.** `assets/model/` bundles only the files directly inside
  `assets/model`. `assets/` bundles only the files directly inside `assets`, which is none here,
  because subfolders are not included: `assets/model/model_unquant.tflite` would be missing.
- **Why can `image` and `http` run in a plain unit test?** They are pure Dart (`image` decodes in
  Dart, `http` can take a `MockClient`, see `test/download_test.dart`). `tflite_flutter` calls a
  native C library through FFI, and `image_picker` talks to the Android/iOS side over a platform
  channel. Neither exists in the `flutter test` VM.

## Part 3 – Classifier

- **T10:** run in debug mode. `runSmokeTest` (`lib/services/smoke_test.dart`) prints every label,
  the top label and the sum. Paste the console output here: _…_
- **T11:** constructor injection. `ClassifierApp` (`lib/app.dart`) loads the classifier once, the
  Welcome screen shows the loading state, and the instance is passed to `HomeShell` and from there
  to the screens. `close()` runs on `AppLifecycleListener.onDetach` and in `dispose`.
- **T12:** Model tab → *Classify a text file* shows a snackbar ("This file is not a picture…").
  A wrong path (`flutter run --dart-define=MODEL_ASSET=assets/model/model_unqant.tflite`) shows
  "The model is missing" on the Welcome screen, with the expected path and a Try again button.
- **T13:** `test/labels_test.dart`. The awkward case (CRLF, trailing blank line, `2 Car keys`)
  passed without changes, because `trim()` already removes the `\r`.
- **`value / 255` instead of `value / 127.5 − 1`:** every input lands in 0…1 instead of −1…1, so
  the image looks like a washed-out, bright version of itself to the model. The percentages shift,
  usually towards one wrong class with high confidence. Nothing crashes, because the tensor still
  has the right shape and type: the interpreter can't tell what the numbers mean.
- **Where is the number of classes written?** Nowhere in the code. It comes from the lines in
  `labels.txt`, and `Classifier.load` checks it against the model's output shape. For a seventh
  class, replace the two files in `assets/model/` and nothing else.

## Part 4 – Screens

Design: **_name_** by **_author_**, _link_, licence CC BY 4.0. The same credit appears in
`lib/theme/design_credit.dart`, on the Welcome screen and on the Model screen. Frames:
`docs/design-1.png`, `docs/design-2.png`.

All colours, text sizes, radii and spacing live in `lib/theme/app_theme.dart` (a `ColorScheme`,
a `TextTheme`, component themes and an `AppTokens` extension). The screens contain no
`Color(0x…)` and no font sizes.

- **Changed or left out from the Figma file:** _1. …, 2. … (for example: the custom font is not
  bundled, so the platform font is used; illustrations were replaced by Material icons)._
- **Model screen labels: classifier or file?** From the classifier (`ModelInfo.labels`). Those are
  exactly the labels paired with the output, already validated against the model's output size,
  so the screen can never show a list that differs from what Result uses. Reading the file again
  would duplicate the parsing and could drift.

## Part 5 – Sources

Camera, gallery and download each only produce bytes. `HomeShell._run`
(`lib/screens/home_screen.dart`) is the single path: bytes → `classify` → `History.add` →
`ResultScreen`. History entries keep the bytes and predictions, so reopening one does not run the
model again.

### Evaluation (T23)

| # | Source | Expected | Predicted | % | Correct |
|---|--------|----------|-----------|---|---------|
| 1 | camera | | | | |
| 2 | gallery | | | | |
| 3 | download | | | | |
| … 18 rows (3 per class) | | | | | |

Overall accuracy: _correct / 18 = …_ · Weakest class: _…_

- **Camera vs downloaded scores differ, from the training data:** (1) every training sample came
  from the laptop webcam, so they share its colours, sharpness, distance and our desk background,
  while a downloaded picture has studio lighting, a white background and a different camera.
  (2) Each class had few, similar samples (the same mug from the same angles), so the model learnt
  "our mug on our desk", not mugs in general.
- **Time on the UI thread:** _… ms_ (the Result screen shows it, and the console prints
  `[classify] … ms`). During that time the spinner overlay is frozen, and taps are ignored until the
  result opens.

## Checkpoint questions

1. **Shutter → percentage:** the camera app saves a JPEG and `image_picker` scales it to 1024 px wide
   (`image_sources.dart`). `readAsBytes` → `Uint8List`. Decode to pixels, `bakeOrientation`,
   centre-crop and resize to 224 × 224 (`prepareImage`, `classifier.dart`). Each channel goes
   `/127.5 − 1` into a `Float32List` of shape [1, 224, 224, 3] (`toFloatTensor`). The interpreter
   gives 6 softmax floats [1, 6], `pairAndSort` pairs them with `labels.txt` lines and sorts them
   (`classifier.dart`), and `Prediction.percent` gives `(c * 100).toStringAsFixed(1) %` on
   `ResultScreen` (`result_screen.dart`, `widgets/common.dart`).
2. **Three lines of `pubspec.yaml`:** `- assets/model/`: the start-up screen reports "The model is
   missing" (Unable to load asset). `tflite_flutter: …`: compile error, `Target of URI doesn't exist:
   package:tflite_flutter/…`, and the same for `image_picker`. `image: …`: compile error,
   `img.decodeImage` undefined. (`http` behaves the same way.)
3. **Matching pre-processing:** the model only learnt from inputs prepared one way. Two things must
   match: the **geometry** (centre square crop, resized to 224 × 224, correct orientation) and the
   **value range** (channels scaled to −1…1, RGB order). A mismatch gives confident nonsense, not an
   error.
4. **97 % sure a shoe is a mug:** not a bug. The percentage is the softmax share among *our six
   classes*: "of the things I know, this looks most like Mug". It is not the probability that the
   picture really is a mug, and the model has no way to say "none of these".
5. **What leaves the device:** the model, labels, photos and results all stay on the phone. Only
   the *Download an image* request goes out (a GET to the address you typed). A cloud vision API
   would upload every photo, need the network, add latency and cost, and depend on someone else's
   privacy policy. In exchange it would recognise thousands of classes instead of six.
