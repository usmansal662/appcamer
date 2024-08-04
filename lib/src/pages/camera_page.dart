// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camery/main.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/src/widgets/resolution.dart';
import 'package:camery/src/widgets/timer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:camery/src/pages/settings_page.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:camery/src/widgets/exposure.dart';
import 'package:camery/src/widgets/flash.dart';
import 'package:camery/src/widgets/focus.dart';
import 'package:camery/src/widgets/capture_control.dart';
import 'package:weather/weather.dart';

import 'androidMethodChannel.dart';
import 'preview_image.dart';
import 'video/preview_video.dart';

/// Camera example home widget.
class CameraPage extends StatefulWidget {
  bool isVideoCameraSelected;
  bool isSimpleCamera;

  /// Default Constructor
  CameraPage(
      {required this.isVideoCameraSelected,
      required this.isSimpleCamera,
      super.key});

  @override
  State<CameraPage> createState() {
    return _CameraPageState();
  }
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  //Controllers
  File? capturedFile;
  CameraController? controller;
  Uint8List? videoThumbnailUint8list;

  //Zoom
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  //Exposure
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  //Current camera
  bool isRearCameraSelected = Preferences.getStartWithRearCamera();
  // bool isVideoCameraSelected = false;
  bool takingPicture = false;

  //Circle position
  double _circlePosX = 0, _circlePosY = 0;
  bool _circleEnabled = false;
  final Tween<double> _scaleTween = Tween<double>(begin: 1, end: 0.75);

  //Video recording timer
  final Stopwatch _stopwatch = Stopwatch();

  //Photo capture timer
  final Stopwatch _timerStopwatch = Stopwatch();

  //Orientation
  //Volume buttons
  StreamSubscription<HardwareButton>? volumeSubscription;
  bool canPressVolume = true;
  bool isExpand = false;

  String openWeatherApiKey = "979b9c814b1159ab30fb20a8f07b0034";
  Future<void> updateWeather() async {
    WeatherFactory weathers = WeatherFactory(
      openWeatherApiKey,
    );

    Weather currentWeather = await weathers.currentWeatherByLocation(lat, long);
    setState(() {
      weather = currentWeather.temperature!.celsius!.toInt();
      weatherDesription = currentWeather.weatherDescription.toString();
    });
  }

  @override
  void initState() {
    updateWeather();
    super.initState();
    if (Platform.isAndroid) {
      _checkPermission();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isIOS) {
      _initializeCameraController(cameras[0]);

      onNewCameraSelected(
          cameras[Preferences.getStartWithRearCamera() ? 0 : 1]);
    }
  }

  @override
  void dispose() {
    _timerStopwatch.stop();
    _timerStopwatch.reset();
    setnavbar();
    super.dispose();
    if (controller!.value.isRecordingVideo) {
      _stopwatch.stop();
      _stopwatch.reset();
      controller?.stopVideoRecording();
    }
    controller?.dispose();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      _initializeCameraController(cameras[0]);

      onNewCameraSelected(
          cameras[Preferences.getStartWithRearCamera() ? 0 : 1]);
    } else {
      await Permission.camera.request();
      _checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(Get.width, Get.height * 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _settingsWidget(
                  enabled: controller?.value.isRecordingVideo == false &&
                      _timerStopwatch.elapsedTicks <= 1,
                ),
                const SizedBox(
                  width: 30,
                ),
                FlashModeWidget(
                  controller: controller,
                  isRearCameraSelected: isRearCameraSelected,
                  isVideoCameraSelected: widget.isVideoCameraSelected,
                ),
                const SizedBox(
                  width: 30,
                ),
                TimerButton(
                    enabled: !widget.isVideoCameraSelected &&
                        _timerStopwatch.elapsedTicks <= 1),
              ],
            ),
          ),
        ),
        backgroundColor: AppColor.scaffoldBgColor,
        body: _cameraPreview(context),
      ),
    );
  }

  Widget _cameraPreview(context) {
    return Stack(
      children: [
        _previewWidget(),
        _shutterBorder(),
        _timerWidget(),
        // _topControlsWidget(),
        _zoomWidget(context),
        Preferences.getAddTagComplete() == true
            ? Preferences.getTemplate == 'Temp2'
                ? Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Preferences.getTemplate.imageWidget),
                  )
                : const SizedBox()
            : const SizedBox(),
        _bottomControlsWidget(),
        _circleWidget(),
      ],
    );
  }

  Widget _shutterBorder() {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
              color: takingPicture
                  ? const Color(0xFFFFFFFF)
                  : const Color.fromARGB(0, 255, 255, 255),
              width: 4.0,
              style: BorderStyle.solid), //Border.all
        ),
      ),
    );
  }

  Widget _timerWidget() {
    var minuteAmount =
        (Preferences.getTimerDuration() - _timerStopwatch.elapsed.inSeconds) /
            60;
    var minute = minuteAmount.floor();

    return Duration(seconds: Preferences.getTimerDuration()).inSeconds > 0 &&
            _timerStopwatch.elapsedTicks > 1
        ? Center(
            child: IgnorePointer(
              child: Text(
                Preferences.getTimerDuration() -
                            _timerStopwatch.elapsed.inSeconds <
                        60
                    ? '${Preferences.getTimerDuration() - _timerStopwatch.elapsed.inSeconds}s'
                    : '${minute}m ${(Preferences.getTimerDuration() - _timerStopwatch.elapsed.inSeconds) % 60}s',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 64.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _previewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController != null && cameraController.value.isInitialized) {
      return CameraPreview(
        controller!,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (TapDownDetails details) =>
                _onViewFinderTap(details, constraints),
          );
        }),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _zoomWidget(context) {
    final leftHandedMode = Preferences.getLeftHandedMode() &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final left = leftHandedMode ? null : 0.0;
    final right = leftHandedMode ? 0.0 : null;

    return Positioned(
      top:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : null,
      right: MediaQuery.of(context).orientation == Orientation.portrait
          ? 0
          : right,
      left: MediaQuery.of(context).orientation == Orientation.portrait
          ? null
          : left,
      bottom:
          MediaQuery.of(context).orientation == Orientation.portrait ? null : 0,
      child: RotatedBox(
        quarterTurns:
            MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!leftHandedMode) const SizedBox(height: 64.0),
              if (Preferences.getEnableZoomSlider())
                RotatedBox(
                    quarterTurns: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 0
                        : 2,
                    child: _zoomSlider(update: false)),
              if (leftHandedMode) const SizedBox(height: 64.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsWidget({required bool enabled}) {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 400),
      turns:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 0.25,
      child: SettingsButton(
        onPressed: enabled
            ? () {
                _stopVolumeButtons();
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          controller: controller,
                          onNewCameraSelected: _initializeCameraController,
                        ),
                      ),
                    )
                    .then((value) => setState(() {}));
              }
            : null,
        controller: controller,
      ),
    );
  }

  Widget _bottomControlsWidget() {
    final leftHandedMode = Preferences.getLeftHandedMode() &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final cameraControls = <Widget>[
      if (Preferences.getEnableModeRow()) _cameraModesWidget(),
      if (Preferences.getEnableModeRow()) const Divider(color: Colors.white),
      if (Preferences.getEnableExposureSlider())
        ExposureSlider(
          setExposureOffset: _setExposureOffset,
          currentExposureOffset: _currentExposureOffset,
          minAvailableExposureOffset: _minAvailableExposureOffset,
          maxAvailableExposureOffset: _maxAvailableExposureOffset,
        ),
      if (Preferences.getEnableExposureSlider())
        const Divider(color: Colors.white),
      Preferences.getAddTagComplete() == true
          ? Preferences.getTemplate != 'Temp2'
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Preferences.getTemplate.imageWidget)
              : const SizedBox()
          : const SizedBox(),
      Container(
        height: 40,
        width: 160,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xff8E36FF).withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ToggleSwitch(
          fontSize: 12,
          labels: const [
            'Camera',
            'Video',
          ],
          initialLabelIndex: widget.isVideoCameraSelected ? 1 : 0,
          changeOnTap: true,
          onToggle: controller?.value.isRecordingVideo == false &&
                  _timerStopwatch.elapsedTicks <= 1
              ? (index) async {
                  if (Platform.isAndroid) {
                    if (!widget.isVideoCameraSelected) {
                      final status = await Permission.microphone.status;

                      if (status.isDenied ||
                          status.isRestricted ||
                          status.isPermanentlyDenied) {
                        await Permission.microphone.request();
                      } else {
                        setState(() {
                          widget.isVideoCameraSelected = true;
                          _initializeCameraController(controller!.description);
                        });
                      }
                    } else {
                      controller?.value.isRecordingVideo ?? false
                          ? null
                          : setState(
                              () => widget.isVideoCameraSelected = false);
                    }
                  } else {
                    if (!widget.isVideoCameraSelected) {
                      setState(() {
                        widget.isVideoCameraSelected = true;
                        _initializeCameraController(controller!.description);
                      });
                    } else {
                      controller?.value.isRecordingVideo ?? false
                          ? null
                          : setState(
                              () => widget.isVideoCameraSelected = false);
                    }
                  }
                }
              : null,
          cornerRadius: 0.0,
          radiusStyle: true,
          inactiveFgColor: Colors.white,
          activeBgColor: const [Color(0xff8E36FF)],
          inactiveBgColor: Colors.transparent,
        ),
      ),
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: CaptureControlWidget(
          controller: controller,
          onTakePictureButtonPressed: onTakePictureButtonPressed,
          onVideoRecordButtonPressed: onVideoRecordButtonPressed,
          onResumeButtonPressed: onResumeButtonPressed,
          onPauseButtonPressed: onPauseButtonPressed,
          onStopButtonPressed:
              Platform.isAndroid ? onStopButtonPressed : onStopButtonPressedIOS,
          onNewCameraSelected: onNewCameraSelected,
          isVideoCameraSelected: widget.isVideoCameraSelected,
          isRecordingInProgress: controller?.value.isRecordingVideo ?? false,
          leadingWidget: const Icon(
            Icons.close,
            size: 50,
            color: Colors.transparent,
          ),
          isRearCameraSelected: getIsRearCameraSelected(),
          setIsRearCameraSelected: setIsRearCameraSelected,
        ),
      ),
    ];

    final bottomControls = <Widget>[
      if (controller != null &&
          widget.isVideoCameraSelected &&
          controller!.value.isRecordingVideo)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 400),
              turns: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 0
                  : 0.25,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4.0)),
                child: Text(
                  _stopwatch.elapsed.inSeconds < 60
                      ? '${_stopwatch.elapsed.inSeconds}s'
                      : '${_stopwatch.elapsed.inMinutes}m ${_stopwatch.elapsed.inSeconds % 60}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      Container(
        color: AppColor.scaffoldBgColor.withOpacity(0),
        child: Column(
          children: leftHandedMode
              ? cameraControls.reversed.toList()
              : cameraControls,
        ),
      ),
    ];

    return RotatedBox(
      quarterTurns:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 3,
      child: Column(
        mainAxisAlignment:
            leftHandedMode ? MainAxisAlignment.start : MainAxisAlignment.end,
        children:
            leftHandedMode ? bottomControls.reversed.toList() : bottomControls,
      ),
    );
  }

  Widget _cameraModesWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ExposureModeControlWidget(controller: controller),
        FocusModeControlWidget(controller: controller),
      ],
    );
  }

  //Selecting camera
  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final flashMode = getFlashMode();
    final resolution = getResolution();

    final CameraController cameraController = CameraController(
      cameraDescription,
      widget.isVideoCameraSelected ? ResolutionPreset.veryHigh : resolution,
      enableAudio:
          widget.isVideoCameraSelected ? Preferences.getEnableAudio() : false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController.setFlashMode(flashMode),
        cameraController
            .getMinExposureOffset()
            .then((double value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((double value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          break;
        case 'AudioAccessDenied':
          break;
        default:
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
    if (Platform.isAndroid) {
      checkVolumeButtons();
    }
  }

  bool getIsRearCameraSelected() {
    return isRearCameraSelected;
  }

  void setIsRearCameraSelected() {
    setState(() => isRearCameraSelected = !isRearCameraSelected);
  }

  //Camera button functions
  void onTakePictureButtonPressed() {
    if (Platform.isAndroid) {
      takePicture().then((XFile? file) {
        if (mounted) {
          setState(() {
            videoThumbnailUint8list = null;
          });
        }
      });
    } else {
      takePictureIOS().then((XFile? file) {
        if (mounted) {
          setState(() {
            videoThumbnailUint8list = null;
          });
        }
      });
    }
  }

  void onVideoRecordButtonPressed() {
    // if (!Preferences.getDisableShutterSound()) {
    if (Platform.isAndroid) {
      var methodChannel = AndroidMethodChannel();
      methodChannel.startVideoSound();
    }
    // }
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) async {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        // await SpfServices.saveMyVideo(file.path);

        String basePath = Preferences.getSavePath();

        Directory downloadDir = Directory(basePath);
        // Check if the download directory exists, if not, create it
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }
        Get.to(
          () => PeviewVideoScreen(
            pathed: file.path,
            locWidget: widget.isSimpleCamera ||
                    Preferences.getAddTagComplete() == false
                ? const SizedBox()
                : Preferences.getTemplate.imageWidget,
          ),
        );
      }
    });
  }

  void onStopButtonPressedIOS() {
    stopVideoRecording().then((XFile? file) async {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          String basePath = directory.path;
          Directory downloadDir = Directory(basePath);
          // Check if the download directory exists, if not, create it
          if (!downloadDir.existsSync()) {
            downloadDir.createSync(recursive: true);
          }
          Get.to(
            () => PeviewVideoScreen(
              pathed: file.path,
              locWidget: widget.isSimpleCamera ||
                      Preferences.getAddTagComplete() == false
                  ? const SizedBox()
                  : Preferences.getTemplate.imageWidget,
            ),
          );
        } catch (e) {
          debugPrint('Error creating directory or navigating: $e');
        }
      }
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _subscribeVolumeButtons() {
    volumeSubscription =
        FlutterAndroidVolumeKeydown.stream.listen((event) async {
      if (canPressVolume) {
        final int delay;
        if (widget.isVideoCameraSelected) {
          // delay = 2;
          // controller?.value.isRecordingVideo == true
          //     ? onStopButtonPressed()
          //     : onVideoRecordButtonPressed();
          return;
        } else {
          delay = 1;
          onTakePictureButtonPressed();
        }

        canPressVolume = false;
        await Future.delayed(Duration(seconds: delay));
        canPressVolume = true;
      }
    });
  }

  void _stopVolumeButtons() => volumeSubscription?.cancel();

  void checkVolumeButtons() => Preferences.getCaptureAtVolumePress()
      ? _subscribeVolumeButtons()
      : _stopVolumeButtons();

  //Camera controls
  Future<XFile?> takePicture() async {
    setState(() {
      Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer t) => setState(() {}),
      );
      _timerStopwatch.start();
    });

    await Future.delayed(Duration(seconds: Preferences.getTimerDuration()));

    setState(() {
      _timerStopwatch.stop();
      _timerStopwatch.reset();
    });

    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already going on, return
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      takingPicture = true;

      // if (!Preferences.getDisableShutterSound()) {
      if (Platform.isAndroid) {
        var methodChannel = AndroidMethodChannel();
        methodChannel.shutterSound();
      }
      // }
      capturedFile = File(file.path);

      final directory = Preferences.getSavePath();

      String path = '$directory/IMG_${timestamp()}.jpg';

      if (!isRearCameraSelected && Preferences.getFlipFrontCameraPhoto()) {
        final imageBytes = await capturedFile!.readAsBytes();
        img.Image? originalImage = img.decodeImage(imageBytes);
        img.Image fixedImage = img.flipHorizontal(originalImage!);

        await capturedFile!.writeAsBytes(
          img.encodeJpg(fixedImage),
          flush: true,
        );
      }

      Uint8List? newFileBytes = await FlutterImageCompress.compressWithFile(
        capturedFile!.path,
        quality: Preferences.getCompressQuality(),
        format: CompressFormat.jpeg,
      );
      try {
        final tempFile = capturedFile!.copySync(path);
        await tempFile.writeAsBytes(newFileBytes!);
        capturedFile = File(path);
        Get.to(() => PeviewImage(
              pathed: capturedFile!,
              isTagExist: true,
              iswidgetExist: widget.isSimpleCamera,
            ));
      } catch (e) {
        if (mounted) showSnackbar(text: e.toString());
      }

      takingPicture = false;
      return file;
    } on CameraException {
      return null;
    }
  }

  Future<XFile?> takePictureIOS() async {
    setState(() {
      Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer t) {
          if (mounted) {
            setState(() {});
          }
        },
      );
      _timerStopwatch.start();
    });

    await Future.delayed(Duration(seconds: Preferences.getTimerDuration()));

    setState(() {
      _timerStopwatch.stop();
      _timerStopwatch.reset();
    });

    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already going on, return
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      takingPicture = true;

      capturedFile = File(file.path);

      final directory = await getApplicationDocumentsDirectory();

      String path = '${directory.path}/IMG_${timestamp()}.jpg';

      if (!isRearCameraSelected && Preferences.getFlipFrontCameraPhoto()) {
        final imageBytes = await capturedFile!.readAsBytes();
        img.Image? originalImage = img.decodeImage(imageBytes);
        img.Image fixedImage = img.flipHorizontal(originalImage!);

        await capturedFile!.writeAsBytes(
          img.encodeJpg(fixedImage),
          flush: true,
        );
      }

      Uint8List? newFileBytes = await FlutterImageCompress.compressWithFile(
        capturedFile!.path,
        quality: Preferences.getCompressQuality(),
        format: CompressFormat.jpeg,
      );
      try {
        final tempFile = capturedFile!.copySync(path);
        await tempFile.writeAsBytes(newFileBytes!);
        capturedFile = File(path);
        Get.to(() => PeviewImage(
              pathed: capturedFile!,
              isTagExist: true,
              iswidgetExist: widget.isSimpleCamera,
            ));
      } catch (e) {
        if (mounted) showSnackbar(text: e.toString());
      }

      takingPicture = false;
      return file;
    } on CameraException {
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    setState(() {
      Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) {
          if (mounted) {
            setState(() {});
          }
        },
      );
      _stopwatch.start();
    });

    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording already started, return
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException {
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
    });

    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException {
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    setState(() {
      _stopwatch.stop();
    });

    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException {
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    setState(() {
      _stopwatch.start();
    });

    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException {
      rethrow;
    }
  }

  //Zoom
  Widget _zoomSlider({required bool update}) {
    if (mounted && update) {
      setState(() {});
    }

    if (_currentScale > _maxAvailableZoom) {
      _currentScale = _maxAvailableZoom;
    }

    return RotatedBox(
      quarterTurns: 3,
      child: SliderTheme(
        data: SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
          overlayShape: SliderComponentShape.noOverlay,
        ),
        child: Slider(
          value: _currentScale,
          min: _minAvailableZoom,
          max: _maxAvailableZoom,
          label: _currentScale.toStringAsFixed(2),
          onChanged: ((value) async {
            setState(() {
              _currentScale = value;
            });
            await controller!.setZoomLevel(value);
          }),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    _circlePosX = details.localPosition.dx;
    _circlePosY = details.localPosition.dy;

    _displayCircle();

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void _displayCircle() async {
    setState(() {
      _circleEnabled = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _circleEnabled = false;
    });
  }

  Widget _circleWidget() {
    return Positioned(
      top: _circlePosY - 20.0,
      left: _circlePosX - 20.0,
      child: _circleEnabled
          ? TweenAnimationBuilder(
              tween: _scaleTween,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                // ignore: unnecessary_cast
                return Transform.scale(scale: scale as double, child: child);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.transparent,
                  size: 42.0,
                ),
              ),
            )
          : Container(),
    );
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    _zoomSlider(update: true);

    await controller!.setZoomLevel(_currentScale);
  }

  //Exposure
  Future<void> _setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException {
      rethrow;
    }
  }

  //Thumbnail

  //Misc
  String timestamp() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String formatted = formatter.format(now);
    return formatted;
  }

  void showSnackbar({required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 5),
    ));
  }
}

GeoData? location;
double lat = 0;
double long = 0;
int weather = 0;
String weatherDesription = '';
Future<void> attachImageToVideo(
    String videoPath, String imagePath, String outputPath) async {
  String command =
      '-i $videoPath -i $imagePath -filter_complex "overlay=(main_w-overlay_w)/2:main_h-overlay_h" -codec:a copy $outputPath';
  await FFmpegKit.execute(command);

  Preferences.addvideo = outputPath;
}

Future<void> attachImageToVideoWithWaterMArk(String videoPath, String imagePath,
    String watermark, String outputPath) async {
  String command =
      '-i $videoPath -i $imagePath -i $watermark -filter_complex "[0:v][1:v] overlay=(main_w-overlay_w)/2:main_h-overlay_h-10[temp]; [temp][2:v] overlay=main_w-overlay_w-10:(main_h-overlay_h)/2" -codec:a copy $outputPath';
  await FFmpegKit.execute(command);

  Preferences.addvideo = outputPath;
}

Future<void> attachImageToVideoTemp2(
    String videoPath, String imagePath, String outputPath) async {
  String command =
      '-i $videoPath -i $imagePath -filter_complex "overlay=(main_w-overlay_w)/2:10" -codec:a copy $outputPath';
  await FFmpegKit.execute(command);

  Preferences.addvideo = outputPath;
}

Future<void> attachImageToVideoTemp2withWatermark(String videoPath,
    String imagePath, String watermark, String outputPath) async {
  String command =
      '-i $videoPath -i $imagePath -i $watermark -filter_complex "[0:v][1:v] overlay=(main_w-overlay_w)/2:10[temp]; [temp][2:v] overlay=main_w-overlay_w-10:(main_h-overlay_h)/2" -codec:a copy $outputPath';
  await FFmpegKit.execute(command);

  Preferences.addvideo = outputPath;
}

Future<void> attachImageToImage(
    String imagPriPath, String imagePath, String outputPath) async {
  String command =
      '-i $imagPriPath -i $imagePath -filter_complex "overlay=(main_w-overlay_w)/2:main_h-overlay_h" $outputPath';
  await FFmpegKit.execute(command);
}

Future<void> attachImageToImageTemp2(
    String imagPriPath, String imagePath, String outputPath) async {
  String command =
      '-i $imagPriPath -i $imagePath -filter_complex "overlay=(main_w-overlay_w)/2:0" $outputPath';
  await FFmpegKit.execute(command);
}

setnavbar() async {
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
}
