import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/_core.dart';
import '../../../../config/_config.dart';
import '../../../app/app.dart';
import '../../../catalog/catalog.dart';
import '../../../catalog/presentation/widgets/pending_capture_card.dart';
import '../blocs/home/home_cubit.dart';

class HomeView extends StatefulWidget {
  final LabelCaptureCubit? drafts;
  const HomeView({super.key, this.drafts});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool search = false, food = false;
  String query = '';
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
    if (widget.drafts != null) unawaited(widget.drafts!.restore());
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
      body: SafeArea(
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
                final visible = filterRecentProducts(items, query: query, foodOnly: food);
                final loading = state.maybeWhen(loading: () => true, orElse: () => false);
                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().load(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(d.paddingComfortable),
                        sliver: SliverList.list(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/pickwell_lemon.png',
                                  width: 40,
                                  height: 40,
                                  excludeFromSemantics: true,
                                ),
                                Gap(d.spacingXs),
                                Expanded(
                                  child: Text(
                                    getIt<AppConfig>().appName,
                                    style: context.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: search ? l.pkCloseSearch : l.pkSearch,
                                  onPressed: () => setState(() {
                                    search = !search;
                                    if (!search) {
                                      query = '';
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                  }),
                                  icon: AppIcon(icon: search ? Icons.close : Icons.search),
                                ),
                              ],
                            ),
                            if (search) ...[
                              Gap(d.spacingMd),
                              TextField(
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  labelText: l.pkSearch,
                                  prefixIcon: const AppIcon(icon: Icons.search),
                                ),
                                onChanged: (value) => setState(() => query = value),
                              ),
                            ],
                            Gap(d.spacingLg),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: d.spacingMd,
                              runSpacing: d.spacingXs,
                              children: [
                                Wrap(
                                  spacing: d.spacingXs,
                                  runSpacing: d.spacingXs,
                                  children: [
                                    ChoiceChip(
                                      label: Text(l.pkAll),
                                      selected: !food,
                                      onSelected: (_) => setState(() => food = false),
                                    ),
                                    ChoiceChip(
                                      label: Text(l.pkFood),
                                      selected: food,
                                      onSelected: (_) => setState(() => food = true),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l.pkNewest, style: context.textTheme.labelLarge),
                                    AppIcon(icon: Icons.arrow_downward, size: d.iconSmall),
                                  ],
                                ),
                              ],
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
                              PendingCaptureCard(draft: widget.drafts!, query: query),
                            if (loading) ...[
                              const Center(child: CircularProgressIndicator()),
                              Gap(d.spacingLg),
                            ],
                            if (!loading && visible.isEmpty) ...[
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
                              CatalogWidget(entry: entry, onTap: () => _open(entry.barcode)),
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
    );
  }
}
