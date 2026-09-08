# Automated screenshots

`integration_test/screenshot_tour_test.dart` runs a deterministic full-screen
tour at a fixed 390x844 logical surface. It seeds one property and does not
log in or call the remote API.

From `imovato_app/`, run the driver on an available device or emulator:

```bash
SCREENSHOT_VERSION=$(git rev-parse --short HEAD) \
  flutter drive \
  --driver=test_driver/screenshot_tour_test.dart \
  --target=integration_test/screenshot_tour_test.dart \
  -d <device-id>
```

Screenshots are written directly to
`artifacts/screenshots/<SCREENSHOT_VERSION>/<screen>.png`. The current names
are `welcome`, `home`, `listings`, `property_details`, `favorites`, `profile`,
and `login`. `flutter test ...` remains useful for checking that the test
passes, but it does not export PNG files to the host; use the `flutter drive`
command above when you need files.

To add a screen, add one `_capture(..., 'descriptive_name', YourPage())` call.
Put any required deterministic state in `_ScreenshotApp` or beside
`_mockProperty`; do not depend on live network data.

Compare two runs with ImageMagick:

```bash
tool/compare_screenshots.sh \
  artifacts/screenshots/main/home.png \
  artifacts/screenshots/feature/home.png \
  artifacts/screenshots/feature/home.diff.png
```

The script writes a PNG diff and a pixel-count metric next to it. For closest
comparisons, keep Flutter, device pixel ratio, platform, fonts, locale, and
theme consistent. Checkout and authenticated reservation screens are omitted
because they require real backend state and credentials.
