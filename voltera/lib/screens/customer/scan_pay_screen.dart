import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';

class ScanPayScreen extends StatefulWidget {
  const ScanPayScreen({super.key});

  @override
  State<ScanPayScreen> createState() => _ScanPayScreenState();
}

class _ScanPayScreenState extends State<ScanPayScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final _manualCodeController = TextEditingController();
  bool _isFlashOn = false;
  bool _isScanningLocked = false;
  bool _isLoadingCharger = false;
  String _errorMessage = '';
  bool _showManualInput = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  String _parseChargerId(String rawValue) {
    String val = rawValue.trim();
    if (val.startsWith('DUMMY-DEMO-ONLY')) {
      return ''; // Reject dummy non-Voltera sample QRs
    }
    if (val.startsWith('VOLTERA-CHARGER-')) {
      return val.replaceFirst('VOLTERA-CHARGER-', '');
    }
    if (val.startsWith('CHARGER:')) {
      return val.replaceFirst('CHARGER:', '');
    }
    if (val.contains('/chargers/')) {
      final parts = val.split('/chargers/');
      if (parts.length > 1) {
        return parts[1].split('?')[0];
      }
    }
    return val;
  }

  Future<void> _handleScannedChargerId(String rawValue) async {
    if (_isScanningLocked) return;

    debugPrint('QR SCANNED VALUE: $rawValue');
    final chargerId = _parseChargerId(rawValue);
    debugPrint('PARSED CHARGER ID: $chargerId');

    if (chargerId.isEmpty) {
      setState(() {
        _errorMessage = 'Invalid charger QR code. Please scan a valid VOLTERA charger QR.';
      });
      return;
    }

    setState(() {
      _isScanningLocked = true;
      _isLoadingCharger = true;
      _errorMessage = '';
    });

    debugPrint('REQUESTING CHARGER: $chargerId');

    try {
      final customerRepo = CustomerRepositoryImpl(apiService: ApiService());

      // Timeout guard so it never stays on "Checking charger..." forever
      final charger = await customerRepo.getChargerDetails(chargerId).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      debugPrint('CHARGER API RESPONSE: 200 OK');

      if (!mounted) return;
      if (charger != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.customerDetails,
          arguments: {'chargerName': charger.name, 'charger': charger},
        ).then((_) {
          if (mounted) {
            _resetScanner();
          }
        });
      } else {
        setState(() {
          _isLoadingCharger = false;
          _isScanningLocked = false;
          _errorMessage = 'Charger not found';
        });
      }
    } catch (e) {
      debugPrint('CHARGER API RESPONSE ERROR: $e');
      if (!mounted) return;

      String errText = 'Unable to connect to VOLTERA server.';
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('400') || errStr.contains('invalid')) {
        errText = 'Invalid charger QR code';
      } else if (errStr.contains('404') || errStr.contains('not found')) {
        errText = 'Charger not found';
      } else if (errStr.contains('500') || errStr.contains('server')) {
        errText = 'Server error. Please try again.';
      } else if (errStr.contains('timeout') || errStr.contains('connection') || errStr.contains('network') || errStr.contains('timed out')) {
        errText = 'Unable to connect to VOLTERA server.';
      }

      setState(() {
        _isLoadingCharger = false;
        _isScanningLocked = false;
        _errorMessage = errText;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanningLocked = false;
      _isLoadingCharger = false;
      _errorMessage = '';
      _manualCodeController.clear();
    });
    _scannerController.start();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isLoadingCharger = true;
        _errorMessage = '';
      });

      final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final rawValue = capture.barcodes.first.rawValue;
        if (rawValue != null) {
          await _handleScannedChargerId(rawValue);
          return;
        }
      }

      setState(() {
        _isLoadingCharger = false;
        _errorMessage = 'No QR code found in this image.';
      });
    } catch (e) {
      setState(() {
        _isLoadingCharger = false;
        _errorMessage = 'Failed to read QR from image.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full screen live camera preview (bottom layer)
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !_isScanningLocked) {
                    _handleScannedChargerId(barcode.rawValue!);
                    break;
                  }
                }
              },
              errorBuilder: (context, error, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to start camera',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Camera permission is required to scan charger QR codes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _resetScanner,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkGreen),
                          child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Dark semi-transparent surrounding overlay with transparent center window & white corners
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),

          // 3. Top App Bar & Instructions
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Scan QR code',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isFlashOn = !_isFlashOn;
                            _scannerController.toggleTorch();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Align the QR code inside the frame',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 4. Loading State Overlay
          if (_isLoadingCharger)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Checking charger...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Error Alert Overlay with [Scan Again] and [Try Again]
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = '';
                              _showManualInput = true;
                            });
                          },
                          child: const Text('Enter Manually', style: TextStyle(color: AppColors.lightGreen)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _resetScanner,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkGreen),
                          child: const Text('Scan Again', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 6. Bottom Controls (Gallery & Manual Entry toggle)
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'gallery_btn',
                  onPressed: _pickImageFromGallery,
                  backgroundColor: Colors.white24,
                  elevation: 0,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'manual_btn',
                  onPressed: () {
                    setState(() {
                      _showManualInput = !_showManualInput;
                    });
                  },
                  backgroundColor: Colors.white24,
                  elevation: 0,
                  icon: const Icon(Icons.keyboard, color: Colors.white),
                  label: Text(_showManualInput ? 'Close Input' : 'Enter ID', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // 7. Manual Input Bottom Sheet / Overlay when toggled
          if (_showManualInput)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enter Charger ID manually',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showManualInput = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    VolteraTextField(
                      controller: _manualCodeController,
                      label: 'Charger ID',
                      hint: 'e.g. real charger UUID or code',
                    ),
                    const SizedBox(height: 16),
                    VolteraButton(
                      text: 'Continue',
                      onPressed: () {
                        if (_manualCodeController.text.trim().isNotEmpty) {
                          setState(() => _showManualInput = false);
                          _handleScannedChargerId(_manualCodeController.text.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final double scanWindowSize = 250.0;
    final double left = (size.width - scanWindowSize) / 2;
    final double top = (size.height - scanWindowSize) / 2 - 40;

    // Draw 4 surrounding dim rectangles (Top, Bottom, Left, Right) leaving center transparent for camera preview
    // Top
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint);
    // Bottom
    canvas.drawRect(Rect.fromLTWH(0, top + scanWindowSize, size.width, size.height - (top + scanWindowSize)), paint);
    // Left
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanWindowSize), paint);
    // Right
    canvas.drawRect(Rect.fromLTWH(left + scanWindowSize, top, size.width - (left + scanWindowSize), scanWindowSize), paint);

    // Draw white corner borders around the transparent scan window
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final double cornerLength = 30.0;
    // Top-left
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), borderPaint);

    // Top-right
    canvas.drawLine(Offset(left + scanWindowSize - cornerLength, top), Offset(left + scanWindowSize, top), borderPaint);
    canvas.drawLine(Offset(left + scanWindowSize, top), Offset(left + scanWindowSize, top + cornerLength), borderPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + scanWindowSize - cornerLength), Offset(left, top + scanWindowSize), borderPaint);
    canvas.drawLine(Offset(left, top + scanWindowSize), Offset(left + cornerLength, top + scanWindowSize), borderPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + scanWindowSize - cornerLength, top + scanWindowSize), Offset(left + scanWindowSize, top + scanWindowSize), borderPaint);
    canvas.drawLine(Offset(left + scanWindowSize, top + scanWindowSize - cornerLength), Offset(left + scanWindowSize, top + scanWindowSize), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
