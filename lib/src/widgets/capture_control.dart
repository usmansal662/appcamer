import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../utils/colors.dart';

class CaptureControlWidget extends StatefulWidget {
  const CaptureControlWidget({
    super.key,
    required this.controller,
    required this.onTakePictureButtonPressed,
    required this.onVideoRecordButtonPressed,
    required this.onResumeButtonPressed,
    required this.onPauseButtonPressed,
    required this.onStopButtonPressed,
    required this.onNewCameraSelected,
    required this.isVideoCameraSelected,
    required this.isRecordingInProgress,
    required this.leadingWidget,
    required this.isRearCameraSelected,
    required this.setIsRearCameraSelected,
  });

  final CameraController? controller;
  final VoidCallback onTakePictureButtonPressed;
  final VoidCallback onVideoRecordButtonPressed;
  final VoidCallback onResumeButtonPressed;
  final VoidCallback onPauseButtonPressed;
  final VoidCallback onStopButtonPressed;
  final Function(CameraDescription) onNewCameraSelected;
  final bool isVideoCameraSelected;
  final bool isRecordingInProgress;
  final Widget leadingWidget;
  final bool isRearCameraSelected;
  final Function() setIsRearCameraSelected;

  @override
  State<CaptureControlWidget> createState() => _CaptureControlWidgetState();
}

class _CaptureControlWidgetState extends State<CaptureControlWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget pauseResumeButton() {
    final CameraController? cameraController = widget.controller;

    return AnimatedRotation(
      duration: const Duration(milliseconds: 400),
      turns:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 0.25,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => cameraController.value.isRecordingPaused
            ? widget.onResumeButtonPressed()
            : widget.onPauseButtonPressed(),
        icon: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.circle,
              color: Colors.black38,
              size: 60,
            ),
            cameraController!.value.isRecordingPaused
                ? const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  )
                : const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 30,
                  ),
          ],
        ),
        tooltip: cameraController.value.isRecordingPaused
            ? 'Resume video'
            : 'Pause video',
        iconSize: 60,
      ),
    );
  }

  Widget captureButton() {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 400),
      turns:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 0.25,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: widget.isVideoCameraSelected
            ? () => widget.isRecordingInProgress
                ? widget.onStopButtonPressed()
                : widget.onVideoRecordButtonPressed()
            : () => widget.onTakePictureButtonPressed(),
        icon: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/icon/shutterbtn.png',
              height: 100,
            ),
            // Icon(
            //   widget.isVideoCameraSelected && widget.isRecordingInProgress
            //       ? Icons.stop_rounded
            //       : Icons.videocam,
            //   color: Colors.white,
            //   size: 25,
            // ),
            // if (!widget.isVideoCameraSelected)
            //   Icon(
            //     Icons.camera_alt,
            //     color: Colors.grey.shade800,
            //     size: 25,
            //   )
          ],
        ),
        tooltip: widget.isVideoCameraSelected
            ? widget.isVideoCameraSelected && widget.isRecordingInProgress
                ? 'Stop video'
                : 'Start recording video'
            : 'Take picture',
        iconSize: 80,
      ),
    );
  }

  Widget switchButton() {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 400),
      turns:
          MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 0.25,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          widget.onNewCameraSelected(
              cameras[widget.isRearCameraSelected ? 1 : 0]);
          widget.setIsRearCameraSelected();

          animationController.reset();
          animationController.forward();
        },
        icon: Stack(
          alignment: Alignment.center,
          children: [
            // const Icon(
            //   Icons.circle,
            //   color: Colors.black38,
            //   size: 60,
            // ),
            AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(animationController.value * 6),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/icon/camrot.png',
                  height: 50,
                )),
          ],
        ),
        tooltip: widget.isRearCameraSelected
            ? 'Flip to front camera'
            : 'Flip to rear camera',
        iconSize: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        widget.isRecordingInProgress
            ? pauseResumeButton()
            : widget.leadingWidget,
        captureButton(),
        FutureBuilder(
          future: deviceInfo.androidInfo,
          builder: (context, snapshot) {
            if (!widget.isRecordingInProgress) return switchButton();

            if (snapshot.hasData) {
              AndroidDeviceInfo androidInfo =
                  snapshot.data as AndroidDeviceInfo;

              if (androidInfo.version.sdkInt >= 26) {
                return switchButton();
              } else {
                return const SizedBox(height: 60, width: 60);
              }
            } else {
              return const SizedBox(height: 60, width: 60);
            }
          },
        ),
      ],
    );
  }
}
