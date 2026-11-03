import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../../../catalog/domain/entities/catalog_entity.dart';

String recentSortLabel(BuildContext context, RecentProductSort sort) => switch (sort) {
  RecentProductSort.newest => context.l10n.pkNewest,
  RecentProductSort.oldest => context.l10n.pkOldest,
  RecentProductSort.nameAscending => context.l10n.pkNameAscending,
  RecentProductSort.nameDescending => context.l10n.pkNameDescending,
};
