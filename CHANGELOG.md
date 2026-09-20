## 0.0.5

* **Feat:** Full constructor parity with Flutter's standard `ListView`:
  * Added `EzListView` default constructor for explicit children lists.
  * Added `EzListView.separated` with `separatorBuilder`.
  * Added `EzListView.custom` with `childrenDelegate`.
* **Feat:** Added `fallbackHeight` and `fallbackWidth` for custom fallback dimension overrides.
* **Feat:** Added `onUnboundedDetected` callback for automated telemetry, custom logging, and testing.
* **Feat:** Added `showDebugIndicator` flag (defaults to `true`) to toggle the debug red border.
* **Fix:** Enhanced debug error reporting with parent culprit diagnosis (e.g. `Column`, `Row`, `Flex`) and actionable hints.
* **Tests:** Expanded test suite covering all constructors, horizontal lists, custom dimensions, and callbacks.

## 0.0.4

* **Feat:** Full support for `ListView.builder` API (added `shrinkWrap`, `scrollDirection`, `physics`, etc.).
* **Feat:** Refined crash detection to respect `shrinkWrap: true`.
* **Tests:** Added comprehensive test suite for various layout scenarios.

## 0.0.3

* **Docs:** Added `FUNDING.yml` and updated `pubspec.yaml` metadata.
* **Docs:** Refined `README.md` for better clarity and SEO.
* **Example:** Restructured example app for better pub.dev compatibility.

## 0.0.2

* Added comprehensive documentation and a public example.
* The widget now also handles unbounded width constraints.
* Improved debug error messages to be more specific.

## 0.0.1

* Initial release of the `ez_list_view` widget, a defensive version of ListView.builder that prevents crashes from unbounded height constraints.
