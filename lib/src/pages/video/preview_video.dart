// ignore_for_file: must_be_immutable
import 'dart:io';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:camery/src/widgets/rewardAdDialog.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camery/src/pages/camera_page.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import '../../utils/preferences.dart';

class PeviewVideoScreen extends StatefulWidget {
  String pathed;
  Widget locWidget;
  PeviewVideoScreen({required this.pathed, required this.locWidget, super.key});

  @override
  State<PeviewVideoScreen> createState() => _PeviewVideoScreenState();
}

class _PeviewVideoScreenState extends State<PeviewVideoScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController secondController = ScreenshotController();
  XFile? videoFile;
  VoidCallback? videoPlayerListener;
  late FlickManager flickManager;
  @override
  void initState() {
    setnavbar();
    super.initState();
    // captureImage();

    if (Platform.isIOS) {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.file(
        File(widget.pathed),
      ));
    } else {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.pathed),
      ));
    }
  }

  bool isrewardWatch = false;
  String imgPath = '';
  captureImage() {
    try {
      screenshotController.capture().then((value) async {
        if (value != null) {
          final tempPath = await getApplicationDocumentsDirectory();

          File file = File('${tempPath.path}Imges.png');
          file.writeAsBytesSync(value);

          imgPath = file.path;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> captureImageIOS() async {
    try {
      final value = await screenshotController.capture();
      if (value != null) {
        final directory = await getApplicationDocumentsDirectory();
        String directoryPath = directory.path;

        // Ensure the directory exists
        final Directory outputDir = Directory(directoryPath);
        if (!outputDir.existsSync()) {
          outputDir.createSync(recursive: true);
        }

        String filePath =
            '$directoryPath/IMG_${DateTime.now().microsecondsSinceEpoch}.jpg';
        File file = File(filePath);
        await Future.delayed(const Duration(seconds: 1));
        file.writeAsBytesSync(value);

        imgPath = file.path;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String watermarkPath = '';
  capturewuthWatermark() {
    try {
      secondController.capture().then((value) async {
        if (value != null) {
          final tempPath = await getApplicationDocumentsDirectory();

          File file = File('${tempPath.path}Img.png');
          file.writeAsBytesSync(value);

          watermarkPath = file.path;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
    flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/slidingpuzzleBg.png'),
                fit: BoxFit.fill),
          ),
          child: flickManager.flickVideoManager!.autoInitialize
              ? Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FlickVideoPlayer(flickManager: flickManager),
                    ),
                    Align(
                      alignment: Preferences.getTemplate == 'Temp2'
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      child: Padding(
                        padding: Preferences.getTemplate == 'Temp2'
                            ? EdgeInsets.only(top: Get.height * 0.1)
                            : const EdgeInsets.all(0),
                        child: Stack(
                          children: [
                            if (!AppUtils.isSubscribed && removeWaterMarkReward)
                              !isrewardWatch
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.dialog(ChatTimesUpDialog(
                                            onExit: (ctx) {
                                              setState(() {});
                                            },
                                          ), barrierDismissible: false)
                                              .then((value) => setState(() {
                                                    isrewardWatch =
                                                        value[0] ?? false;
                                                  }));
                                        },
                                        child: Screenshot(
                                          controller: secondController,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightpinkColor
                                                  .withOpacity(0.09),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Image.asset(
                                                  'assets/icon/applogo.png',
                                                  height: 30,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'GPS Map Camera\nTimeStamp Tag',
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            Preferences.getTemplate == 'Temp2'
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Screenshot(
                                        controller: screenshotController,
                                        child: widget.locWidget))
                                : Positioned(
                                    bottom: 60,
                                    left: 20,
                                    right: 20,
                                    child: Screenshot(
                                        controller: screenshotController,
                                        child: widget.locWidget),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text(
                              '<  Back',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'poppins'),
                            ),
                          ),
                          effectButton(
                            onClick: () async {
                              if (Platform.isIOS) {
                                try {
                                  await captureImageIOS();
                                  Future.delayed(const Duration(seconds: 2),
                                      () async {
                                    final directory =
                                        await getApplicationDocumentsDirectory();
                                    String directoryPath = directory.path;

                                    String path =
                                        '$directoryPath/VID_${DateTime.now().microsecondsSinceEpoch}.mp4';

                                    if (Preferences.getTemplate == 'Temp2') {
                                      await attachImageToVideoTemp2(
                                              widget.pathed, imgPath, path)
                                          .whenComplete(() async {
                                        await File(widget.pathed).delete();
                                      });
                                    } else {
                                      await attachImageToVideo(
                                              widget.pathed, imgPath, path)
                                          .whenComplete(() async {
                                        await File(widget.pathed).delete();
                                      });
                                    }

                                    Get.snackbar('Video Saved',
                                        'video saved successfully',
                                        colorText: Colors.white);
                                  });
                                  Get.back();
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              } else {
                                try {
                                  captureImage();
                                  if (!isrewardWatch) {
                                    capturewuthWatermark();
                                  }
                                  Future.delayed(const Duration(seconds: 2),
                                      () async {
                                    var directory = Preferences.getSavePath();

                                    String path =
                                        '$directory/VID_${DateTime.now().microsecondsSinceEpoch}.mp4';

                                    if (Preferences.getTemplate == 'Temp2') {
                                      if (isrewardWatch) {
                                        await attachImageToVideoTemp2(
                                                widget.pathed, imgPath, path)
                                            .whenComplete(() async {
                                          await File(widget.pathed).delete();
                                        });
                                      } else {
                                        await attachImageToVideoTemp2withWatermark(
                                                widget.pathed,
                                                imgPath,
                                                watermarkPath,
                                                path)
                                            .whenComplete(() async {
                                          await File(widget.pathed).delete();
                                        });
                                      }
                                    } else {
                                      if (isrewardWatch) {
                                        await attachImageToVideo(
                                                widget.pathed, imgPath, path)
                                            .whenComplete(() async {
                                          await File(widget.pathed).delete();
                                        });
                                      } else {
                                        await attachImageToVideoWithWaterMArk(
                                                widget.pathed,
                                                imgPath,
                                                watermarkPath,
                                                path)
                                            .whenComplete(() async {
                                          await File(widget.pathed).delete();
                                        });
                                      }
                                    }

                                    Get.snackbar('Video Saved',
                                        'video saved successfully',
                                        colorText: Colors.white);
                                  });
                                  Get.back();
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              }
                            },
                            child: Image.asset(
                              'assets/icon/savebtn.png',
                              height: 40,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
