import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

import '../providers/bcv_provider.dart';

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetectedItem {
  final double value;
  final Rect boundingBox;
  final String label;

  DetectedItem(this.value, this.boundingBox, this.label);
}

class ScanScreen extends ConsumerStatefulWidget {
  final CurrencyType source;
  final CurrencyType target;
  final bool isInverse;
  final CustomRate? customRate;

  const ScanScreen({
    super.key,
    required this.source,
    required this.target,
    this.isInverse = false,
    this.customRate,
  });

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  // OCR related
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  bool _isProcessing = false;

  // State for multiple detections
  List<DetectedItem> _detectedItems = [];
  Size _imageSize = Size.zero; // To scale rects

  // Gallery / Static Image
  File? _staticImageFile;
  Uint8List? _lastGalleryImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fire and forget - do not block UI
    _initializeCamera();
    _fetchLastGalleryImage();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _fetchLastGalleryImage() async {
    try {
      // Robust Permission Request
      PermissionState ps = await PhotoManager.requestPermissionExtend();

      // If not determined/auth, try explicitly requesting via permission_handler for Android 13+ support
      if (!ps.isAuth && Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (status.isGranted) {
          ps = PermissionState.authorized;
        } else {
          // Try legacy storage
          final status2 = await Permission.storage.request();
          if (status2.isGranted) {
            ps = PermissionState.authorized;
          }
        }
      }

      if (ps.isAuth) {
        // Strict sort by creation date (descending) so we get the very latest image/screenshot
        final FilterOptionGroup filterOption = FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        );

        final albums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
          filterOption: filterOption,
        );

        if (albums.isNotEmpty) {
          // Get the most recent 1 item
          final recent = await albums.first.getAssetListRange(start: 0, end: 1);
          if (recent.isNotEmpty) {
            final bytes = await recent.first.thumbnailData;
            if (mounted) {
              setState(() {
                _lastGalleryImageBytes = bytes;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching gallery image: $e");
    }
  }

  Future<void> _initializeCamera() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint("Camera/OCR only supported on Android/iOS");
      return;
    }

    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _controller = CameraController(
            cameras.first,
            ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
          );

          await _controller!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });

            // Only start stream if not viewing a static image
            if (_staticImageFile == null) {
              _controller!.startImageStream(_processImage);
            }
          }
        } else {
          debugPrint("No cameras found");
        }
      } else {
        debugPrint("Camera permission denied");
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      // Pause camera stream if active
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _staticImageFile = File(image.path);
          _detectedItems = []; // Clear previous
          _imageSize = Size.zero; // Reset
        });

        // Process this static image
        await _processStaticImage(_staticImageFile!);
      } else {
        // User cancelled, restart stream if not static
        if (_staticImageFile == null &&
            _controller != null &&
            !_controller!.value.isStreamingImages) {
          _controller!.startImageStream(_processImage);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    // Prevent double taps
    if (_isProcessing) return;

    try {
      // 1. Stop stream
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      // 2. Take high-res picture
      final XFile file = await _controller!.takePicture();

      // 3. Set as static to "freeze" and process
      setState(() {
        _staticImageFile = File(file.path);
        _detectedItems = [];
        _imageSize = Size.zero; // Force recalculate from file
      });

      // 4. Process the High Res image
      await _processStaticImage(_staticImageFile!);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      // Resume stream if failed
      if (_controller != null && !_controller!.value.isStreamingImages) {
        try {
          _controller!.startImageStream(_processImage);
        } catch (_) {}
      }
    }
  }

  Future<void> _processStaticImage(File file) async {
    _isProcessing = true;
    try {
      final inputImage = InputImage.fromFilePath(file.path);

      // We need image dimensions. InputImage doesn't give them directly until processed?
      // Actually decode the image to get size for rendering overlay
      final decodedImage = await decodeImageFromList(file.readAsBytesSync());
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);

      // No rotation needed for static files usually (0)
      _parseRecognizedText(
        recognizedText,
        _imageSize,
        InputImageRotation.rotation0deg,
      );
    } catch (e) {
      debugPrint("Error processing static: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;
    if (_controller == null) return;

    _isProcessing = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      if (_imageSize == Size.zero) {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      }

      final recognizedText = await _textRecognizer.processImage(inputImage);
      _parseRecognizedText(
        recognizedText,
        inputImage.metadata?.size ?? _imageSize,
        inputImage.metadata?.rotation,
      );
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _parseRecognizedText(
    RecognizedText recognizedText,
    Size imgSize,
    InputImageRotation? rotation,
  ) {
    // Regex logic
    final symbolPattern = r'([$€]|Bs\.?|VES|Ref\.?)';
    final amountPattern = r'[\d.,]+';

    // We need conversion rate once per frame
    final conversionData = _getConversionRateAndSymbol();
    final rate = conversionData.rate;
    final symbol = conversionData.symbol;
    final usdRate = conversionData.usdRate;

    // regex filters
    final badContextPattern = RegExp(
      r'\b(combo|caja|bulto|unid|pza|pieza|cant|nro|num|no\.)\b',
      caseSensitive: false,
    );
    // Strict units (start/end boundaries)
    final unitPattern = RegExp(
      r'(?:^|\s)(kg|g|ml|l|lb|oz|m|cm|mm|mts|kms|gr|mg)(?:\s|$)',
      caseSensitive: false,
    );
    final datePattern = RegExp(r'\b\d{1,4}[/-]\d{1,2}[/-]\d{1,4}\b');
    final timePattern = RegExp(r'\b\d{1,2}:\d{2}\b');

    List<DetectedItem> newItems = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text;

        // 1. Global Line Context Checks
        if (datePattern.hasMatch(text) || timePattern.hasMatch(text)) {
          if (text.length < 15 &&
              (datePattern.hasMatch(text) || timePattern.hasMatch(text))) {
            continue;
          }
        }

        // 2. Strict Bad Words in Line
        if (badContextPattern.hasMatch(text)) {
          // If the line has explicit "Model Number" context words, we might want to skip the whole line
          // But "Combo 1" is valid. "Modelo X500" is not.
        }

        // Check against Alphanumeric "Model Number" patterns
        // e.g. "XT-500", "A53", "JBL5"
        // If a word contains both letters and numbers, and the letters are NOT currency symbols, it's a model.
        // We'll split by space to check individual tokens?
        // Or better: in the loop below, check the *raw* match context.

        final matches = RegExp(amountPattern).allMatches(text);

        for (final match in matches) {
          String rawNum = match.group(0)!;

          // --- NEW: Check for adjacent characters to detect Model No ---
          // Find the full token this number belongs to in 'text'
          // Simple heuristic: if the char immediately before or after the match
          // is a Letter (and not a currency code part), it's probably a model.

          int start = match.start;
          int end = match.end;

          bool isModel = false;

          // Check Preceding char
          if (start > 0) {
            String prev = text[start - 1];
            if (RegExp(r'[A-Za-z]').hasMatch(prev)) {
              // Letter before number.
              if (prev != ' ' && prev != '.' && prev != '\$') {
                // Check standard currency codes
                String prefix = text
                    .substring(0, start)
                    .trimRight()
                    .toLowerCase();
                if (!prefix.endsWith("bs") &&
                    !prefix.endsWith("ves") &&
                    !prefix.endsWith("eur") &&
                    !prefix.endsWith("usd")) {
                  isModel = true;
                }
              }
            }
            if (prev == '-') isModel = true;
          }

          // Check Succeeding char
          if (end < text.length) {
            String next = text[end];
            if (RegExp(r'[A-Za-z]').hasMatch(next)) {
              // Number followed by letter "500X"
              String suffix = text.substring(end).trimLeft().toLowerCase();
              if (!suffix.startsWith("bs") &&
                  !suffix.startsWith("ves") &&
                  !suffix.startsWith("eur") &&
                  !suffix.startsWith("usd")) {
                isModel = true;
              }
            }
            if (next == '-') isModel = true;
          }

          if (isModel) continue;

          // Symbol Pattern for Euro explicitly in case it was missed
          bool explicitEuro = text.contains('€');

          rawNum = rawNum.replaceAll(RegExp(r'^[.,]+|[.,]+$'), '');
          if (rawNum.isEmpty) continue;

          final double? val = _parseCurrencyString(rawNum);
          if (val != null && val > 0) {
            // --- CONTEXT FILTERS ---

            // Check Symbols
            // Add explicitEuro to the hasSymbol logic
            bool hasSymbol =
                RegExp(symbolPattern, caseSensitive: false).hasMatch(text) ||
                explicitEuro;

            // Context Logic:
            // Find where this number is in the text.
            // Check characters *immediately* surrounding it?
            // "1.5 kg" -> "1.5" match. " kg" succeeds it.

            // Simple approach: if line contains Unit AND !hasSymbol, skip.
            // "1.5 kg" -> skip.
            // "$ 1.5 kg" -> keep (price per kg).
            if (!hasSymbol && unitPattern.hasMatch(text)) {
              continue;
            }

            // Years
            if (val >= 1900 && val <= 2100 && !hasSymbol) {
              continue;
            }

            // Integer heuristics
            // If strictly integer < 100 with no symbol -> likely count
            bool isInteger = (val % 1 == 0);
            if (!hasSymbol && isInteger && val < 50) {
              continue;
            }

            // Calculate converted value
            double converted = 0.0;
            if (widget.isInverse) {
              if (rate > 0) converted = val / rate;
            } else {
              converted = val * rate;
            }

            final formatter = NumberFormat("#,##0.00", "es_VE");
            final usdFormatter = NumberFormat(
              "#,##0.##",
              "en_US",
            ); // US format for USD usually

            // Formulate Label
            String labelText = "$symbol ${formatter.format(converted)}";

            if (!widget.isInverse &&
                widget.source == CurrencyType.custom &&
                usdRate > 0) {
              final usdEquiv = converted / usdRate;
              // Format:
              // Bs. 1.234,56
              // (BCV $12.34)
              labelText =
                  "Bs. ${formatter.format(converted)}\n(BCV \$${usdFormatter.format(usdEquiv)})";
            } else if (!widget.isInverse &&
                widget.source == CurrencyType.custom) {
              // Fallback if no USD rate? Just show Bs.
              labelText = "Bs. ${formatter.format(converted)}";
            }

            newItems.add(DetectedItem(converted, line.boundingBox, labelText));
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _detectedItems = newItems;
      });
    }
  }

  ({double rate, String symbol, double usdRate}) _getConversionRateAndSymbol() {
    final rates = ref.read(ratesProvider).value;
    if (rates == null) return (rate: 0.0, symbol: 'Bs.', usdRate: 0.0);

    double rate = 0.0;
    double usdRate = rates.usdToday; // Default to today
    String symbol = "Bs.";

    if (widget.target == CurrencyType.custom) {
      // Base logic
      if (widget.source == CurrencyType.usd) {
        rate = rates.usdToday;
      } else if (widget.source == CurrencyType.eur) {
        rate = rates.eurToday;
      } else if (widget.source == CurrencyType.custom &&
          widget.customRate != null) {
        rate = widget.customRate!.rate;
      }
    }

    if (widget.isInverse) {
      if (widget.source == CurrencyType.usd) {
        symbol = "\$";
      } else if (widget.source == CurrencyType.eur) {
        symbol = "€";
      } else {
        symbol = "${widget.customRate?.name ?? "P"} ";
      }
    } else {
      symbol = "Bs.";
    }

    return (rate: rate, symbol: symbol, usdRate: usdRate);
  }

  double? _parseCurrencyString(String input) {
    int dots = input.split('.').length - 1;
    int commas = input.split(',').length - 1;
    String clean = input;

    if (dots == 1 && commas == 0) {
      // 123.45 -> std
    } else if (commas == 1 && dots == 0) {
      // 123,45 -> eur
      clean = clean.replaceAll(',', '.');
    } else if (dots > 0 && commas > 0) {
      // Mixed 1,234.56 or 1.234,56
      int lastDot = input.lastIndexOf('.');
      int lastComma = input.lastIndexOf(',');
      if (lastDot > lastComma) {
        // 1,234.56
        clean = clean.replaceAll(',', '');
      } else {
        // 1.234,56
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (dots > 1) {
      // 1.234.567 -> ambiguous if no decimal. usually thousands.
      // assume integer
      clean = clean.replaceAll('.', '');
    } else if (commas > 1) {
      clean = clean.replaceAll(',', '');
    }

    return double.tryParse(clean);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    // rotation logic
    // For android back camera (sensor 90), to get upright image relative to PORTRAIT UI:
    // It's usually 90 deg clockwise.
    // ML Kit expects the rotation of the image buffer relative to "Upright".

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(
        image.planes.fold(
          <int>[],
          (List<int> previousValue, element) =>
              previousValue..addAll(element.bytes),
        ),
      ),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  void _onViewHeaderTap(TapUpDetails details) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    // Calculate relative point (0.0 - 1.0)
    final size = MediaQuery.of(context).size;
    final double relativeX = details.globalPosition.dx / size.width;
    final double relativeY = details.globalPosition.dy / size.height;

    try {
      _controller!.setFocusPoint(Offset(relativeX, relativeY));
      _controller!.setExposurePoint(Offset(relativeX, relativeY));
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the content layer
    Widget content;
    bool isStatic = _staticImageFile != null;

    if (isStatic) {
      content = Center(
        child: Image.file(_staticImageFile!, fit: BoxFit.contain),
      );
    } else if (_isCameraInitialized && _controller != null) {
      final size = MediaQuery.of(context).size;
      var scale = 1.0;
      if (_controller!.value.aspectRatio > 0) {
        scale = size.aspectRatio * _controller!.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;
      }
      content = GestureDetector(
        onTapUp: _onViewHeaderTap,
        child: Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(_controller!)),
        ),
      );
    } else {
      // Camera loading or failed
      content = Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Starting Camera...",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          content,

          // Overlay - AR Bubbles (Only if ready)
          if (_imageSize != Size.zero)
            LayoutBuilder(
              builder: (ctx, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: ARBubblePainter(
                    items: _detectedItems,
                    imageSize: _imageSize,
                    widgetSize: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    scaleType: isStatic ? BoxFit.contain : BoxFit.cover,
                    isAndroid: Platform.isAndroid,
                    isStatic: isStatic,
                  ),
                );
              },
            ),

          // Overlay - Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (isStatic)
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _staticImageFile = null;
                          _detectedItems = [];
                        });
                        if (_isCameraInitialized) {
                          _controller!.startImageStream(_processImage);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),

          // Overlay - Bottom Controls (Gallery Button)
          // Always show this, even if camera is loading!
          if (!isStatic)
            Positioned(
              bottom: 40,
              left: 40,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: _lastGalleryImageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_lastGalleryImageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[800],
                  ),
                  child: _lastGalleryImageBytes == null
                      ? const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
              ),
            ),

          // Shutter Button visual
          if (!isStatic)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withAlpha(50),
                  ),
                  child: const Icon(
                    Icons.camera, // Changed icon to Camera to signify photo
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ARBubblePainter extends CustomPainter {
  final List<DetectedItem> items;
  final Size imageSize;
  final Size widgetSize;
  final BoxFit scaleType;
  final bool isAndroid;
  final bool isStatic;

  ARBubblePainter({
    required this.items,
    required this.imageSize,
    required this.widgetSize,
    required this.scaleType,
    this.isAndroid = false,
    this.isStatic = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in items) {
      final rect = _scaleRect(item.boundingBox);

      // Text Style - Dynamic but matching scan size
      // Heuristic: Font size roughly 85% of rect height to simulate "replacing" it.
      // Constraints: Min 12, Max 60.
      double fontSize = rect.height * 0.85;
      if (fontSize < 12) fontSize = 12;
      if (fontSize > 60) fontSize = 60;

      final List<String> lines = item.label.split('\n');
      TextSpan textSpan;

      if (lines.length > 1) {
        textSpan = TextSpan(
          children: [
            TextSpan(
              text: lines[0],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            TextSpan(
              text: "\n${lines[1]}",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontSize: fontSize * 0.6, // Smaller font for secondary info
              ),
            ),
          ],
        );
      } else {
        textSpan = TextSpan(
          text: item.label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        );
      }

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center, // Center align for multiline
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate bubble size tightly around text
      final width = textPainter.width + 12;
      final height = textPainter.height + 4;

      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: rect.center, width: width, height: height),
        const Radius.circular(4), // slightly less rounded for tighter look
      );

      final Paint bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final Paint borderPaint = Paint()
        ..color = AppTheme.textAccent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(bubbleRect, bgPaint);
      canvas.drawRRect(bubbleRect, borderPaint);

      textPainter.paint(
        canvas,
        bubbleRect.center -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  Rect _scaleRect(Rect absoluteRect) {
    // Scaling logic handling Camera (Rotated) vs Static (Unrotated)

    double imageW = imageSize.width;
    double imageH = imageSize.height;

    // For Camera on Android: Image is rotated 90 relative to screen.
    // Dimensions swap if isAndroid && !isStatic.
    // Note: If isStatic, Image.file defaults to correct orientation (exif).
    // ML Kit processes it. If we passed rotation0, coordinates are in image space.

    bool rotateDims = isAndroid && !isStatic;

    if (rotateDims && imageW > imageH) {
      double temp = imageW;
      imageW = imageH;
      imageH = temp;
    }

    // Calculate Scale
    double scaleX = widgetSize.width / imageW;
    double scaleY = widgetSize.height / imageH;

    double scale;
    if (scaleType == BoxFit.cover) {
      scale = (scaleX > scaleY) ? scaleX : scaleY;
    } else {
      scale = (scaleX < scaleY) ? scaleX : scaleY; // Contain
    }

    double offsetX = (widgetSize.width - imageW * scale) / 2;
    double offsetY = (widgetSize.height - imageH * scale) / 2;

    double x, y, w, h;

    // Mapping
    if (rotateDims) {
      // Rotated 90 mapping (Android Camera)
      // Check previous derivation; direct mapping of rotated dims worked best?
      // If ML Kit rotated the rects:
      x = absoluteRect.left * scale + offsetX;
      y = absoluteRect.top * scale + offsetY;
      w = absoluteRect.width * scale;
      h = absoluteRect.height * scale;

      // Wait, if I swapped dims above (imageW = 1080), then 'scale' is correct for rotated view.
      // But absoluteRect came from 1920x1080 raw buffer?
      // If ML Kit handles rotation, it might return 1080x1920 coords.
      // If YES, the above is correct.
      // If NO, and it returns 1920x1080 coords... we need 90 deg rotation transform.
      // Usually providing 'rotation' metadata to ML Kit makes it output rotated coords.
      // Since I pass rotation, I assume coords are rotated.
    } else {
      // Standard mapping (iOS or Static)
      x = absoluteRect.left * scale + offsetX;
      y = absoluteRect.top * scale + offsetY;
      w = absoluteRect.width * scale;
      h = absoluteRect.height * scale;
    }

    return Rect.fromLTWH(x, y, w, h);
  }

  @override
  bool shouldRepaint(covariant ARBubblePainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
