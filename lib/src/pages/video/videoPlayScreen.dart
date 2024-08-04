// ignore_for_file: must_be_immutable, file_names

import 'dart:io';

import 'package:camery/src/pages/camera_page.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import '../photoGaller/photoGallery.dart';
import 'package:video_player/video_player.dart';

class VideoPlayScreen extends StatefulWidget {
  String pathed;

  VideoPlayScreen({required this.pathed, super.key});

  @override
  State<VideoPlayScreen> createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  XFile? videoFile;
  // late CachedVideoPlayerController videoController;
  VoidCallback? videoPlayerListener;
  // late CustomVideoPlayerController _customVideoPlayerController;
  late FlickManager flickManager;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
    // captureImage();
    flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(
      File(widget.pathed),
    ));
  }

  @override
  void dispose() {
    setnavbar();
    super.dispose();
    flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/slidingpuzzleBg.png'),
                  fit: BoxFit.fill),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                  child: repAppBar(
                    fn: () {
                      Get.back();
                    },
                    title: 'Video Player',
                  ),
                ),

                // videoController.value.isInitialized
                //     ?
                Expanded(
                  child: FlickVideoPlayer(
                    flickManager: flickManager,
                  ),
                )
                // : const CircularProgressIndicator(),
              ],
            )));
  }
}
