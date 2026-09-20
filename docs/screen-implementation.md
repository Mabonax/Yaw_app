# Screen implementation — 17 September 2026

Implemented the six distinct designs in the eight supplied PNG references from
C:\Users\John Mabona\Downloads\screens.

## Screens and navigation

- Pilot Profile: name, email, calling code, phone, date picker and country.
- Add Aircraft: aircraft type, model filtering, popular model photographs,
  selection, manual entry, serial and registration details.
- Certifications: add/remove licence and medical entries, dates, category,
  native PDF/JPEG/PNG selection with a 5 MB limit.
- Review: entered personal, aircraft and certificate details, edit navigation
  and confirmation.
- Account Created: complete visual component, restricted to the isolated
  preview until a server-confirmed registration contract exists.
- Dashboard: scenic identity header, four shortcuts, metrics, recent activity,
  upcoming missions, promotional card and custom bottom navigation.

The existing register and role screens lead into the new setup flow. Form values
remain in memory while setup is open; passwords are not copied into the draft.
The authenticated dashboard consumes existing AuthController, AircraftController
and MissionController state. Account actions, profile, aircraft, mission and
compliance navigation remain available.

## Backend boundary

The current myaviation routes/api.php was inspected. It exposes login and current
identity reads, but no mobile registration, pilot profile write, physical aircraft
onboarding or pilot-certificate submission contract. Create Account therefore
explains that nothing was submitted and never claims an account or email exists.
Selected documents stay local; they are not uploaded. Public legal documents are
also not supplied, so the links explain their current unavailability.

Active certificate and expiry totals are displayed as unavailable until the server
supplies those totals. Preview sample numbers and activity are isolated in
lib/design_preview.dart, which is not imported by lib/main.dart.

## Artwork and typography

- Existing official icon artwork is displayed with native YAW / PLAN. FLY. COMPLY.
  text. The Android launcher assets were preserved.
- Poppins Regular/SemiBold are bundled with the upstream SIL OFL licence in
  assets/fonts/OFL.txt.
- The supplied aircraft screenshot is used only for clipped product-photo
  regions. All labels, fields, progress indicators and controls are Flutter widgets.
- assets/screens/mountain_lake.png was created with the built-in imagegen tool.
  Its source is the supplied scenic reference. It reconstructs the photograph;
  it is not a pixel-identical export of the flattened reference.
- Native status/navigation bars and responsive text may differ from the
  iPhone-style status bars drawn in the supplied images.

Final imagegen prompt:

"Create a clean background artwork asset for the YAW mobile app. The first supplied
image is a contact sheet with eight references, the second shows three existing
backgrounds. Use ONLY the scenic photograph in REF 6 (second row, second column of
the contact sheet) as your target, use existing background photographs for landscape
detail. Reproduce that mountain lake scene, bright blue sky, wispy clouds, mountain
slopes descending to the central long blue lake, foreground pines and black
quadcopter drone in upper right. Preserve composition, colors, lighting, drone
position and landscape as closely as possible. Output only a continuous scenic
photograph, portrait 1024x1152, full bleed: NO text, NO logos, NO UI, NO status icons,
NO checkmarks, NO buttons, NO people, NO collage or frame, NO white fade. Sky
occupies upper 45%, drone around 72% width and 36% height, valley lake lower 55%.
This clean photo will sit behind real Flutter text and controls."

## Verification and launch

Golden renders are in test/features/onboarding/goldens/screen_0.png through
screen_5.png. They are implementation snapshots for regression detection, not
automated proof of pixel equivalence with the supplied designs. Tests load the
actual fonts and artwork and cover phone layouts, larger text, keyboard insets,
draft preservation, edit navigation, and the unavailable registration boundary.

The emulator walkthrough also exposed and fixed:
- failed bootstrap preventing Create Account navigation;
- role cards and footer clipping at phone widths;
- the dashboard promotional card clipping when text wraps.

An Android runtime capture is in
screenshots/screen-implementation/pilot-runtime.png.

Normal launch:
flutter run -d emulator-5554

Isolated visual preview (no API calls or authenticated state):
flutter run -d chrome -t lib/design_preview.dart
Use the grid button to switch between all six designs.
YAW_PREVIEW_SCREEN=0..5 can select the initial screen via --dart-define.

On this host, use the process-local JAVA_TOOL_OPTIONS value
-Djdk.net.unixdomain.tmpdir=C:/xampp/htdocs/yaw_app/build/aimtmp for Android builds.
The emulator was restarted with -gpu swiftshader_indirect after a host graphics
context failure. Live authenticated backend acceptance remains unverified because
the configured local service did not respond during the walkthrough.


Final results: all 79 Flutter tests pass; Flutter analysis reports no issues.
The Android debug APK builds and was installed/launched on emulator-5554.
The host emulator subsequently shut down again, including with software rendering.
The application remains served at http://127.0.0.1:8088 and the isolated six-screen
preview at http://127.0.0.1:8089. Both returned HTTP 200. The preview was opened in
Chrome for interactive review. The in-app browser automation bridge was unavailable,
so browser interaction has not been automated; rendered widget and Android capture
evidence are recorded above.

The final APK was rebuilt successfully after the last spacing adjustments. The
saved Android capture predates those final adjustments; the emulator could not
remain running for a final reinstall. The live web processes remain listening on
ports 8088 and 8089. Automated browser interaction was unavailable, so the Chrome
open request should not be interpreted as browser acceptance proof.
