import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../config/app_session.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../home/presentation/widgets/home_backdrop.dart';
import '../../domain/entities/catalog_entity.dart';
import '../blocs/catalog/catalog_cubit.dart';
import 'barcode_lookup_loading.dart';
import 'barcode_scan_overlay.dart';
import 'lookup_notice.dart';
import 'scanner_circle_button.dart';

class BarcodeScannerPage extends StatelessWidget {
  final CatalogState state;
  final Widget camera, torchAction;
  final AppSession? session;
  final VoidCallback onClose, onGallery, onManual, onRetry, onOpenSettings;
  const BarcodeScannerPage({
    super.key,
    required this.state,
    required this.camera,
    required this.torchAction,
    required this.onClose,
    required this.onGallery,
    required this.onManual,
    required this.onRetry,
    required this.onOpenSettings,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData, colors = context.colorScheme;
    final scanning = state.status == LookupStatus.idle || state.status == LookupStatus.scanning;
    final checking = {
      LookupStatus.checking,
      LookupStatus.found,
      LookupStatus.miss,
    }.contains(state.status);
    final overlay = scanning
        ? SystemUiOverlayStyle.light
        : colors.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: colors.scrim,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The camera stays attached underneath status views so existing retry,
            // gallery and lifecycle behavior can continue using its controller.
            Positioned.fill(child: camera),
            if (!scanning) const Positioned.fill(child: HomeBackdrop()),
            if (scanning) const Positioned.fill(child: BarcodeScanOverlay()),
            SafeArea(
              child: Padding(
                padding: context.themeData.edgeInsetsData.pagePadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ScannerCircleButton(
                          icon: HugeIcons.strokeRoundedCancel01,
                          tooltip: l.pkCancel,
                          onPressed: onClose,
                          overCamera: scanning,
                        ),
                        const Spacer(),
                        if (scanning) torchAction,
                      ],
                    ),
                    Gap(d.spacingMd),
                    Expanded(
                      child: checking
                          ? const BarcodeLookupLoading()
                          : scanning
                          ? const SizedBox.shrink()
                          : Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LookupNotice(
                                      status: state.status,
                                      error: state.error,
                                      quota: state.quota,
                                      session: session,
                                      retry: onRetry,
                                    ),
                                    if (state.error == 'camera')
                                      TextButton(
                                        onPressed: onOpenSettings,
                                        child: Text(l.pkOpenSettings),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // Preserve room for controls on short landscape viewports.
                    if (scanning && MediaQuery.sizeOf(context).height >= 480) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: d.paddingMd,
                          vertical: d.paddingSm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.scrim.withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(d.heroCornerRadius),
                        ),
                        child: Text(
                          l.pkPoint,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      Gap(d.spacingLg),
                    ],
                    if (!checking)
                      Row(
                        children: [
                          ScannerCircleButton(
                            icon: HugeIcons.strokeRoundedImage02,
                            tooltip: l.pkGallery,
                            onPressed: onGallery,
                            overCamera: scanning,
                          ),
                          Gap(d.spacingMd),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton.icon(
                                onPressed: onManual,
                                icon: const AppIcon(icon: HugeIcons.strokeRoundedKeyboard),
                                label: Text(l.pkManual),
                                style: TextButton.styleFrom(
                                  foregroundColor: scanning ? Colors.white : colors.primary,
                                  backgroundColor: scanning
                                      ? colors.scrim.withValues(alpha: .45)
                                      : colors.surfaceContainerLowest,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: d.paddingMd,
                                    vertical: d.paddingSm,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
