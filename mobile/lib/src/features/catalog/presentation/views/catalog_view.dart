import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../data/data_sources/services/scanner_media_service.dart';
import '../../domain/entities/catalog_entity.dart';
import '../blocs/catalog/catalog_cubit.dart';
import '../widgets/lookup_notice.dart';

class CatalogView extends StatefulWidget {
  final AppSession? session;
  const CatalogView({super.key, this.session});
  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> with WidgetsBindingObserver {
  late final MobileScannerController camera;
  final manual = TextEditingController();
  bool busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    camera = MobileScannerController(
      autoStart: false,
      formats: [BarcodeFormat.ean8, BarcodeFormat.ean13, BarcodeFormat.upcA, BarcodeFormat.upcE],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  Future<void> _start() async {
    if (!mounted || busy) return;
    final cubit = context.read<CatalogCubit>();
    try {
      await camera.start();
      if (mounted && !busy) cubit.scanning();
    } on MobileScannerException catch (e) {
      if (mounted) {
        if (e.errorCode == MobileScannerErrorCode.permissionDenied) {
          cubit.cameraDenied();
        } else {
          cubit.cameraError();
        }
      }
    } catch (_) {
      if (mounted) cubit.cameraError();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted && context.read<CatalogCubit>().state.status == LookupStatus.scanning) _start();
    } else {
      unawaited(camera.stop().catchError((Object _) {}));
    }
  }

  Future<void> _detect(BarcodeCapture capture, {bool fromGallery = false}) async {
    if (!mounted) return;
    if (!fromGallery &&
        !{
          LookupStatus.idle,
          LookupStatus.scanning,
        }.contains(context.read<CatalogCubit>().state.status)) {
      return;
    }
    if (busy || !mounted || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first;
    final raw = value.rawValue;
    if (raw == null) return;
    busy = true;
    final cubit = context.read<CatalogCubit>();
    try {
      await camera.stop();
      if (!cubit.isClosed) await cubit.check(raw, upce: value.format == BarcodeFormat.upcE);
    } catch (_) {
      if (!cubit.isClosed) cubit.cameraError();
    } finally {
      busy = false;
    }
  }

  Future<void> _gallery() async {
    if (busy) return;
    busy = true;
    final cubit = context.read<CatalogCubit>();
    try {
      await camera.stop();
      final path = await getIt<ScannerMediaService>().galleryBarcode();
      if (!mounted) return;
      if (path == null) {
        busy = false;
        await _start();
        return;
      }
      final result = await camera.analyzeImage(path);
      busy = false;
      if (result == null || result.barcodes.isEmpty) {
        cubit.cameraError();
        return;
      }
      await _detect(result, fromGallery: true);
    } catch (_) {
      if (!cubit.isClosed) cubit.cameraError();
    } finally {
      busy = false;
    }
  }

  Future<void> _manual() async {
    try {
      await camera.stop();
    } catch (_) {}
    if (!mounted) return;
    final cubit = context.read<CatalogCubit>();
    manual.clear();
    final code = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(context.l10n.pkManual),
        content: TextField(
          controller: manual,
          autofocus: true,
          keyboardType: TextInputType.number,
          onSubmitted: (value) => Navigator.pop(dialog, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: Text(context.l10n.pkCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, manual.text),
            child: Text(context.l10n.pkContinue),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (code != null) {
      await cubit.check(code);
    } else {
      await _start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    manual.dispose();
    unawaited(camera.dispose().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = context.themeData.dimensionsData;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pkScan),
        actions: [
          BlocBuilder<CatalogCubit, CatalogState>(
            builder: (context, state) => IconButton(
              tooltip: l.pkTorch,
              onPressed:
                  state.status == LookupStatus.scanning &&
                      camera.value.torchState != TorchState.unavailable
                  ? () => camera.toggleTorch().catchError((Object _) {
                      if (context.mounted) context.read<CatalogCubit>().cameraError();
                    })
                  : null,
              icon: const AppIcon(icon: Icons.flash_on),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<CatalogCubit, CatalogState>(
          listener: (context, state) {
            if (state.status == LookupStatus.found) {
              context.replace('/product/${state.barcode}', extra: state.quota);
            }
            if (state.status == LookupStatus.miss) {
              context.replace('/capture/${state.barcode}', extra: state.quota);
            }
          },
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: camera,
                      onDetect: (capture) => unawaited(_detect(capture)),
                      onDetectError: (_, _) {
                        if (context.mounted) context.read<CatalogCubit>().cameraError();
                      },
                      errorBuilder: (context, error) => Center(
                        child: Text(
                          error.errorCode == MobileScannerErrorCode.permissionDenied
                              ? l.pkCameraDenied
                              : l.pkError,
                        ),
                      ),
                    ),
                    if (state.status == LookupStatus.scanning || state.status == LookupStatus.idle)
                      IgnorePointer(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width.clamp(0, 300) - 40,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.colorScheme.tertiaryContainer,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(d.cardCornerRadius),
                          ),
                        ),
                      ),
                    if (state.status == LookupStatus.checking)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
              if (state.status == LookupStatus.scanning)
                Padding(
                  padding: EdgeInsets.all(d.paddingMd),
                  child: Text(l.pkPoint, textAlign: TextAlign.center),
                ),
              if ([
                LookupStatus.denied,
                LookupStatus.error,
                LookupStatus.processing,
              ].contains(state.status))
                Flexible(
                  child: SingleChildScrollView(
                    child: LookupNotice(
                      status: state.status,
                      error: state.error,
                      quota: state.quota,
                      session: widget.session,
                      retry: () {
                        if (state.barcode != null && state.error != 'invalid_barcode') {
                          context.read<CatalogCubit>().retry();
                        } else {
                          _start();
                        }
                      },
                    ),
                  ),
                ),
              if (state.error == 'camera')
                TextButton(onPressed: () => openAppSettings(), child: Text(l.pkOpenSettings)),
              Padding(
                padding: EdgeInsets.all(d.paddingSm),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    IconButton(
                      tooltip: l.pkGallery,
                      onPressed: state.status == LookupStatus.checking ? null : _gallery,
                      icon: const AppIcon(icon: Icons.photo_library_outlined),
                    ),
                    TextButton(
                      onPressed: state.status == LookupStatus.checking ? null : _manual,
                      child: Text(l.pkManual),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
