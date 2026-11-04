import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../catalog/catalog.dart';
import '../../../catalog/presentation/widgets/pending_capture_card.dart';
import '../blocs/home/home_cubit.dart';
import '../widgets/home_backdrop.dart';
import '../widgets/home_filter_bar.dart';
import '../widgets/home_header.dart';

class HomeView extends StatefulWidget {
  final LabelCaptureCubit? drafts;
  const HomeView({super.key, this.drafts});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool search = false, food = false;
  String query = '';
  bool _hasPendingItems = false;
  int _privateRefreshRevision = 0;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  RecentProductSort sort = RecentProductSort.newest;
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
    if (widget.drafts != null) unawaited(widget.drafts!.restore());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _open(String barcode) async {
    await context.push('/product/$barcode');
    if (mounted) context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = context.themeData.dimensionsData;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HomeBackdrop(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: d.maxWidth),
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    final items = state.maybeWhen(
                      ready: (items) => items,
                      orElse: () => <RecentProduct>[],
                    );
                    final visible = filterRecentProducts(
                      items,
                      query: query,
                      foodOnly: food,
                      sort: sort,
                    );
                    final loading = state.maybeWhen(loading: () => true, orElse: () => false);
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() => _privateRefreshRevision++);
                        await context.read<HomeCubit>().load();
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          SliverPadding(
                            padding: context.themeData.edgeInsetsData.pagePadding,
                            sliver: SliverList.list(
                              children: [
                                HomeHeader(
                                  searching: search,
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  onOpen: () => setState(() => search = true),
                                  onBack: () => setState(() {
                                    search = false;
                                    query = '';
                                    _searchController.clear();
                                    _searchFocus.unfocus();
                                  }),
                                  onClear: () => setState(() {
                                    query = '';
                                    _searchController.clear();
                                    _searchFocus.requestFocus();
                                  }),
                                  onChanged: (value) => setState(() => query = value),
                                ),
                                Gap(d.spacingLg),
                                HomeFilterBar(
                                  foodOnly: food,
                                  onFoodChanged: (value) => setState(() => food = value),
                                  sort: sort,
                                  onSortChanged: (value) => setState(() => sort = value),
                                ),
                                Gap(d.spacingLg),
                                if (state.maybeWhen(error: (_) => true, orElse: () => false)) ...[
                                  Text(l.pkStoredUnavailable),
                                  TextButton(
                                    onPressed: () => context.read<HomeCubit>().load(),
                                    child: Text(l.pkRetry),
                                  ),
                                ],
                                if (widget.drafts != null)
                                  PendingCaptureCard(
                                    draft: widget.drafts!,
                                    query: query,
                                    refreshRevision: _privateRefreshRevision,
                                    onHasItemsChanged: (value) {
                                      if (mounted && value != _hasPendingItems) {
                                        setState(() => _hasPendingItems = value);
                                      }
                                    },
                                    onPublished: () async {
                                      if (mounted) {
                                        await context.read<HomeCubit>().reloadAfterCurrent();
                                      }
                                    },
                                  ),
                                if (loading) ...[
                                  const Center(child: CircularProgressIndicator()),
                                  Gap(d.spacingLg),
                                ],
                                if (!loading && visible.isEmpty && !_hasPendingItems) ...[
                                  Gap(d.spacingXxl),
                                  AppIcon(
                                    icon: HugeIcons.strokeRoundedBarcodeScan,
                                    size: 64,
                                    color: context.colorScheme.primary,
                                  ),
                                  Gap(d.spacingLg),
                                  Text(
                                    items.isEmpty ? l.pkEmptyTitle : l.pkNoMatches,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleLarge,
                                  ),
                                  Gap(d.spacingSm),
                                  if (items.isEmpty)
                                    Text(
                                      l.pkEmptyBody,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                ],
                                for (final entry in visible) ...[
                                  CatalogWidget(
                                    key: ValueKey('recent-${entry.barcode}'),
                                    entry: entry,
                                    onTap: () => _open(entry.barcode),
                                  ),
                                  Gap(d.spacingSm),
                                ],
                                const Gap(120),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
