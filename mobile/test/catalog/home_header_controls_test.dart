import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/features/home/presentation/widgets/home_sort_popover.dart';
import '../../lib/src/features/home/presentation/widgets/home_header.dart';
import '../../lib/src/features/home/presentation/widgets/home_filter_chip.dart';
import '../../lib/src/features/home/presentation/widgets/home_sort_menu.dart';
import '../../lib/src/features/app/app.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'home_sort_test.dart' show host, entry;
import 'home_widget_test.dart' show config;

Future<void> render(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage('assets/images/app_icon.png'),
      tester.element(find.byType(HomeView)),
    );
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../.secrets/ui-polish/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
    await (FontLoader(
      'packages/cupertino_icons/CupertinoIcons',
    )..addFont(rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'))).load();
  });
  setUp(() => getIt.registerSingleton<AppConfig>(config()));
  tearDown(() => getIt.reset());
  testWidgets(
    'header search replaces branding; clear preserves search/focus and Back restores normal header',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeCatalog()
        ..recentItems = [
          entry('00036000291452', 'Banana fixture', 2),
          entry('00000096385074', 'Apple fixture', 1),
        ];
      final home = HomeCubit(GetRecentProductsUseCase(repo));
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: host(BlocProvider.value(value: home, child: const HomeView())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(config().appName), findsOneWidget);
      await tester.tap(find.byTooltip('Search your products'));
      await tester.pumpAndSettle();
      expect(find.text(config().appName), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(
        (tester.getCenter(find.byTooltip('Close search')).dy -
                tester.getCenter(find.byType(TextField)).dy)
            .abs(),
        lessThan(2),
      );
      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pumpAndSettle();
      expect(find.text('Apple fixture'), findsNothing);
      expect(find.text('Banana fixture'), findsOneWidget);
      await render(tester, key, 'home-inline-search');
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, true);
      expect(find.text('Apple fixture'), findsOneWidget);
      expect(find.text('Banana fixture'), findsOneWidget);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text(config().appName), findsOneWidget);
      expect(find.byTooltip('Search your products'), findsOneWidget);
      expect(repo.requests, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
    },
  );
  testWidgets(
    'custom sort popover selects, dismisses outside and handles Escape without Material menus',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final home = HomeCubit(GetRecentProductsUseCase(FakeCatalog()));
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: host(BlocProvider.value(value: home, child: const HomeView())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeSortPopover), findsOneWidget);
      expect(find.byType(PopupMenuButton<RecentProductSort>), findsNothing);
      expect(find.byType(PopupMenuItem<RecentProductSort>), findsNothing);
      await render(tester, key, 'home-custom-sort');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(HomeSortPopover), findsNothing);
      expect(find.text('Newest'), findsOneWidget);
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 800));
      await tester.pumpAndSettle();
      expect(find.byType(HomeSortPopover), findsNothing);
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sort-option-oldest')));
      await tester.pumpAndSettle();
      expect(find.text('Oldest'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
    },
  );
  testWidgets('filter/sort heights and normal/search header heights match across text scales', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final scale in [.8, 1.0, 1.6, 2.0]) {
      final home = HomeCubit(GetRecentProductsUseCase(FakeCatalog()));
      await tester.pumpWidget(
        host(
          BlocProvider.value(value: home, child: const HomeView()),
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
      final sortHeight = tester.getSize(find.byType(HomeSortMenu)).height;
      for (final element in find.byType(HomeFilterChip).evaluate()) {
        expect(tester.getSize(find.byWidget(element.widget)).height, closeTo(sortHeight, .01));
      }
      expect(sortHeight, greaterThanOrEqualTo(48));
      expect(
        find.descendant(of: find.byType(HomeSortMenu), matching: find.byType(AppIcon)),
        findsOneWidget,
      );
      final normalHeight = tester.getSize(find.byType(HomeHeader)).height;
      await tester.tap(find.byTooltip('Search your products'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(HomeHeader)).height, closeTo(normalHeight, .01));
      expect(tester.getSize(find.byType(TextField)).height, closeTo(normalHeight, .01));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
    }
  });
}
