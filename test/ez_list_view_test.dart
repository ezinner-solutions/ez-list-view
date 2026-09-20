import 'package:ez_list_view/ez_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzListView', () {
    testWidgets('renders normally with bounded constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 400,
              child: EzListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies fix when inside Center inside Column (Unbounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Center(
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally directly in Scaffold body (Bounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix when inside SingleChildScrollView -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally inside Flexible in Column (Bounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Flexible(
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix when inside Padding -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('applies fix when inside ListTile title -> ListView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  title: EzListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => Text('Sub-item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('applies fix when inside Wrap -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Wrap(
                  children: [
                    EzListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) =>
                          Text('Wrapped Item $index'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets(
        'shrinkWrap: true allows rendering in unbounded Column without fix',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('renders normally inside Container with fixed size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 300,
                width: 300,
                child: EzListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix inside Stack (unpositioned)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    EzListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => Text('Item $index'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally inside Positioned in Stack',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets(
        'EzListView default constructor renders children normally when bounded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 400,
              child: EzListView(
                children: const [
                  Text('Child 1'),
                  Text('Child 2'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets(
        'EzListView default constructor handles unbounded Column gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView(
                  children: const [
                    Text('Child 1'),
                    Text('Child 2'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(find.text('Child 1'), findsOneWidget);
    });

    testWidgets('EzListView.separated renders items and separators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 400,
              child: EzListView.separated(
                itemCount: 3,
                itemBuilder: (context, index) => Text('Item $index'),
                separatorBuilder: (context, index) => Text('Separator $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Separator 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('EzListView.separated handles unbounded Column gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.separated(
                  itemCount: 3,
                  itemBuilder: (context, index) => Text('Item $index'),
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('EzListView.custom renders with custom childrenDelegate',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 400,
              child: EzListView.custom(
                childrenDelegate: SliverChildListDelegate(
                  const [
                    Text('Custom 1'),
                    Text('Custom 2'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom 1'), findsOneWidget);
      expect(find.text('Custom 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('EzListView.custom handles unbounded Column gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.custom(
                  childrenDelegate: SliverChildListDelegate(
                    const [
                      Text('Custom 1'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(find.text('Custom 1'), findsOneWidget);
    });

    testWidgets('handles horizontal scrollDirection in unbounded Row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                EzListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => SizedBox(
                    width: 60,
                    child: Text('H$index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(find.text('H0'), findsOneWidget);
    });

    testWidgets('respects custom fallbackHeight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.builder(
                  fallbackHeight: 222,
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final matchingBox = sizedBoxes.any((box) => box.height == 222);
      expect(matchingBox, isTrue);
    });

    testWidgets('respects showDebugIndicator: false in debug mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.builder(
                  showDebugIndicator: false,
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets(
        'triggers onUnboundedDetected callback with culprit information',
        (WidgetTester tester) async {
      bool detectedWidth = false;
      bool detectedHeight = false;
      String? detectedCulprit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                  onUnboundedDetected: ({
                    required bool isWidthUnbounded,
                    required bool isHeightUnbounded,
                    required String? culprit,
                  }) {
                    detectedWidth = isWidthUnbounded;
                    detectedHeight = isHeightUnbounded;
                    detectedCulprit = culprit;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(detectedHeight, isTrue);
      expect(detectedWidth, isFalse);
      expect(detectedCulprit, 'Column');
    });
  });
}

bool _hasRedBorder(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    if (c.decoration is BoxDecoration) {
      final box = c.decoration as BoxDecoration;
      if (box.border is Border) {
        final b = box.border as Border;
        if (b.top.color == Colors.red) return true;
      }
    }
  }
  return false;
}
