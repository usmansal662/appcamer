// ignore_for_file: must_be_immutable, camel_case_types, file_names

import 'dart:io';

import 'package:camery/model/locationModel.dart';
import 'package:camery/src/pages/home/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:camery/src/pages/preview_image.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../../google ads/adservice.dart';
import '../../../subscription/subscription.dart';
import '../../utils/apputils.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  // final String title;

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  List<File> imgList = [];
  @override
  void initState() {
    super.initState();
    loadImages();
  }

  final ImagePicker picker = ImagePicker();
  selectimage() async {
    final XFile? result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      File file = File(result.path);
      Preferences.addLatLong = LocationModel(
          address: '',
          imageUrl: file.path,
          lat: 0,
          long: 0,
          dateTime: DateTime.now());
      imgList.insert(0, file);
      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  loadImages() async {
    imgList.clear();
    List<LocationModel> list = Preferences.latlongList;
    for (int i = 0; i < list.length; i++) {
      File file = File(list[i].imageUrl);

      if (await file.exists()) {
        imgList.add(file);
        setState(() {});
      } else {
        Preferences.removeLatlong = i;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBgColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/slidingpuzzleBg.png'),
              fit: BoxFit.fill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
          child: Column(
            children: [
              repAppBar(
                title: 'Sliding Puzzle',
                fn: () {
                  if (AdServices.slidingPuzzleGameBAckInterstitial != null &&
                      !AppUtils.isSubscribed) {
                    Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          content: Container(
                            height: 90.0,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(15.0)),
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 12.0,
                                  right: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white),
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ));
                    Future.delayed(const Duration(seconds: 1), () {
                      Get.back();
                      AdServices.slidingPuzzleGameBAckInterstitial?.show();
                      Get.back();
                    });
                  } else {
                    Get.back();
                  }
                },
              ),
              SizedBox(
                height: Get.height * 0.05,
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  try {
                    selectimage();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: Image.asset(
                  'assets/images/importGal.png',
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10),
                    itemCount: imgList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(
                              () => PuzzleSolveScreen(imgPath: imgList[index]));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            imgList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class repBackButton extends StatelessWidget {
  String title;
  void Function() tapfun;
  repBackButton({
    super.key,
    required this.title,
    required this.tapfun,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: tapfun,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        // Container(
        //   height: 50,
        //   width: 120,
        //   alignment: Alignment.center,
        //   decoration: const BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage('assets/images/optBtn.png'),
        //     ),
        //   ),
        //   child: Text(
        //     title,
        //     style: const TextStyle(
        //         color: Colors.white,
        //         fontSize: 13.74,
        //         fontWeight: FontWeight.bold),
        //   ),
        // ),
      ],
    );
  }
}

class repAppBar extends StatelessWidget {
  repAppBar({
    super.key,
    this.title,
    required this.fn,
  });
  String? title;
  void Function() fn;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: fn,
              child: const Text(
                '<  Back',
                style: TextStyle(
                    fontSize: 18, color: Colors.white, fontFamily: 'poppins'),
              ),
            ),
            Text(
              title ?? "",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins'),
            ),
            const proButton()
          ],
        ),
        Divider(
          color: const Color(0xffFFFFFF).withOpacity(0.2),
        ),
      ],
    );
  }
}
