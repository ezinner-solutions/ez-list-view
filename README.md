# EzListView

A defensive, crash-safe drop-in replacement for Flutter's `ListView` that automatically handles unbounded height and width constraints in `Column`, `Row`, `Flex`, and nested scroll views.

[![pub package](https://img.shields.io/pub/v/ez_list_view.svg)](https://pub.dev/packages/ez_list_view)
[![likes](https://img.shields.io/pub/likes/ez_list_view.svg)](https://pub.dev/packages/ez_list_view)
[![pub points](https://img.shields.io/pub/points/ez_list_view.svg)](https://pub.dev/packages/ez_list_view)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Problem Statement

In Flutter, standard `ListView` widgets expand to fill all available space along their scrolling axis. When placed inside a parent widget that provides unconstrained or infinite dimensions, the Flutter rendering pipeline throws an assertion failure or fatal exception, producing the red crash screen:

* Placing a vertical `ListView` inside a `Column` or `Flex` without `Expanded` or `Flexible`.
* Placing a horizontal `ListView` inside a `Row` without explicit width constraints.
* Nesting a `ListView` directly inside another scroll view (`CustomScrollView`, `SingleChildScrollView`) without `shrinkWrap: true`.
* Rendering inside unconstrained wrappers like `UnconstrainedBox` or floating cards.

### Targeted Error Signatures
`EzListView` catches and prevents the following Flutter layout runtime exceptions:
* `"Vertical viewport was given unbounded height"`
* `"Horizontal viewport was given unbounded width"`
* `"RenderBox was not laid out: RenderViewport #... NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE"`
* `"Failed assertion: line ... pos ...: 'hasSize'"`
* `"A RenderFlex overflowed by ... pixels on the bottom"`

## Technical Solution

`EzListView` intercepts incoming constraints before the `RenderViewport` can throw a fatal layout exception:

1. **Defensive Layout Fallback:** Uses `LayoutBuilder` to detect infinite constraints along the scrolling or cross axes. When detected, it calculates a responsive fallback size (50% of available screen height/width via `MediaQuery`/`View`) so the widget renders visibly.
2. **Debug Diagnostics:** In debug mode, highlights the widget with a visible red outline border and logs an actionable `FlutterError` identifying the exact parent widget (`Column`, `Row`, `Flex`, etc.) causing the violation.
3. **Silent Release Protection:** In release mode, silently applies the fallback dimensions so end users never experience a crash or red screen.
4. **100% Drop-in Parity:** Supports all four standard `ListView` constructors:
   * `EzListView(...)` (children list)
   * `EzListView.builder(...)` (on-demand item builder)
   * `EzListView.separated(...)` (item and separator builders)
   * `EzListView.custom(...)` (custom child delegates)

## Installation

```shell
flutter pub add ez_list_view
```

## Quick Migration

Replace standard `ListView` with `EzListView`:

```diff
- ListView.builder(
+ EzListView.builder(
    itemCount: 20,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  )
```

## Usage Examples

### 1. Crash Prevention inside a Column

In standard Flutter, placing `ListView.builder` directly inside a `Column` throws `"Vertical viewport was given unbounded height"`. `EzListView` prevents the crash:

```dart
Column(
  children: [
    const Text('Header'),
    // Does not crash. Renders safely with a red diagnostic outline in debug mode:
    EzListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(
        title: Text('Item $index'),
      ),
    ),
  ],
)
```

### 2. Default Children Constructor

```dart
EzListView(
  children: const [
    ListTile(title: Text('Profile')),
    ListTile(title: Text('Settings')),
    ListTile(title: Text('Logout')),
  ],
)
```

### 3. Separated Constructor

```dart
EzListView.separated(
  itemCount: 10,
  itemBuilder: (context, index) => ListTile(title: Text('Message $index')),
  separatorBuilder: (context, index) => const Divider(),
)
```

### 4. Custom Fallback Dimensions & Telemetry Callback

```dart
EzListView.builder(
  itemCount: 25,
  itemBuilder: (context, index) => Text('Row $index'),
  fallbackHeight: 300, // Custom fallback height when unbounded
  showDebugIndicator: false, // Disables the red border in debug mode
  onUnboundedDetected: ({
    required bool isWidthUnbounded,
    required bool isHeightUnbounded,
    required String? culprit,
  }) {
    // Send diagnostics to your logging or telemetry service
    debugPrint('Unbounded layout caught in $culprit: width=$isWidthUnbounded, height=$isHeightUnbounded');
  },
)
```

## Permanent Architectural Resolution

While `EzListView` safely handles constraint failures, the recommended structural patterns in Flutter include:

```dart
// Option A: Provide flex expansion inside Column or Row
Column(
  children: [
    Expanded(
      child: EzListView.builder(...),
    ),
  ],
)

// Option B: Provide explicit bounding dimensions
SizedBox(
  height: 300,
  child: EzListView.builder(...),
)

// Option C: Use shrinkWrap for small, finite collections
EzListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: 5,
  itemBuilder: (context, index) => ListTile(title: Text('$index')),
)
```

## API Reference

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `childrenDelegate` | `SliverChildDelegate` | *Required* | Supplies children to the viewport. |
| `scrollDirection` | `Axis` | `Axis.vertical` | Scrolling direction (`Axis.vertical` or `Axis.horizontal`). |
| `reverse` | `bool` | `false` | Whether to reverse scroll direction. |
| `controller` | `ScrollController?` | `null` | Controls the scroll position. |
| `primary` | `bool?` | `null` | Whether this is the primary scroll view. |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics configuration. |
| `shrinkWrap` | `bool` | `false` | Whether the extent should wrap the contents. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Viewport content padding. |
| `itemExtent` | `double?` | `null` | Fixed extent along the scroll axis for every item. |
| `prototypeItem` | `Widget?` | `null` | Prototype child widget used to compute item extent. |
| `showDebugIndicator` | `bool` | `true` | Shows a red outline border in debug mode when unbounded. |
| `fallbackWidth` | `double?` | `null` | Explicit fallback width when horizontal dimension is unbounded. |
| `fallbackHeight` | `double?` | `null` | Explicit fallback height when vertical dimension is unbounded. |
| `onUnboundedDetected` | `Function?` | `null` | Diagnostic callback invoked when an unbounded parent is encountered. |

## Sponsoring & Support

If this package saved you debugging time, consider supporting ongoing maintenance:
* [GitHub Sponsors](https://github.com/sponsors/Evgenii-Zinner/)
* [Thanks.dev](https://thanks.dev/u/gh/evgenii-zinner)
* [Buy Me a Coffee](https://buymeacoffee.com/evgeniizinner)

## License

MIT License. See [LICENSE](LICENSE) for details.
