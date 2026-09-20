# EzListView

A defensive, self-aware drop-in replacement for Flutter's `ListView` that automatically prevents layout crashes from unbounded constraints in `Column`, `Row`, `Flex`, and nested scroll views.

## 🛑 The Problem

In Flutter, placing a `ListView` inside an unbounded parent immediately throws a fatal runtime exception:
* `"Vertical viewport was given unbounded height"`
* `"Horizontal viewport was given unbounded width"`

Common culprits include:
* Vertical `ListView` inside a `Column` or `Flex` without `Expanded` or `Flexible`
* Horizontal `ListView` inside a `Row`
* Nesting a `ListView` directly inside another scroll view (`CustomScrollView`, `SingleChildScrollView`) without `shrinkWrap: true` or explicit height
* Unconstrained widgets like `Card` or non-expanded `Stack` children

Instead of a helpful warning, the entire widget subtree fails to render, showing the red error screen.

## ✅ The EzListView Solution

`EzListView` intercepts unbounded constraints before Flutter's viewport layout throws an exception:

* **Crash Prevention:** Detects unbounded dimensions along the scroll or cross axis and applies safe, responsive fallback dimensions.
* **Developer Feedback:**
  * **Debug Mode:** Displays a red border around the fallback container and reports a structured `FlutterError` pointing out the exact parent culprit (e.g. `Column`, `Row`) with actionable fix instructions.
  * **Release Mode:** Silently applies the fallback layout so your users never experience a crash or red screen.
* **100% Drop-in Parity:** Supports all four standard `ListView` constructors:
  * `EzListView(...)` (children list)
  * `EzListView.builder(...)`
  * `EzListView.separated(...)`
  * `EzListView.custom(...)`

## 📦 Installation

```shell
flutter pub add ez_list_view
```

## 🚀 Usage

### 1. Drop-in Replacement inside a Column

Instead of crashing, `EzListView` safely displays your items and shows a red debug outline with console diagnostics:

```dart
Column(
  children: [
    const Text('Header'),
    // In standard Flutter, ListView.builder crashes here.
    // EzListView prevents the crash gracefully!
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

### 4. Custom Fallback Dimensions & Telemetry

```dart
EzListView.builder(
  itemCount: 25,
  itemBuilder: (context, index) => Text('Row $index'),
  fallbackHeight: 300, // Custom height when unbounded
  showDebugIndicator: false, // Hide the red border in debug mode
  onUnboundedDetected: ({
    required bool isWidthUnbounded,
    required bool isHeightUnbounded,
    required String? culprit,
  }) {
    // Send telemetry or log to your analytics service
    print('Unbounded layout caught in $culprit: width=$isWidthUnbounded, height=$isHeightUnbounded');
  },
)
```

## 💡 The Permanent Fix

While `EzListView` prevents application crashes and provides graceful fallbacks, best practice in Flutter is to explicitly constrain scrollables. When `EzListView` flags an issue in debug mode, apply one of the following permanent fixes:

```dart
// Option A: Wrap in Expanded or Flexible inside Column/Row
Column(
  children: [
    Expanded(
      child: EzListView.builder(...),
    ),
  ],
)

// Option B: Set explicit dimensions
SizedBox(
  height: 300,
  child: EzListView.builder(...),
)

// Option C: Use shrinkWrap if the list has a small, finite number of children
EzListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  ...
)
```

## 🤝 Contributing

Contributions, issues, and feature suggestions are always welcome! Check out the [GitHub repository](https://github.com/Evgenii-Zinner/ez-list-view).

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.
