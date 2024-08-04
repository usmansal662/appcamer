// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables, file_names

import 'dart:ui';
import 'package:camery/google%20ads/adservice.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/subscription/subscription.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatTimesUpDialog extends StatefulWidget {
  //final int langIndex;
  final Function(BuildContext)? onExit;

  ChatTimesUpDialog({super.key, this.onExit});

  @override
  State<ChatTimesUpDialog> createState() => _ChatTimesUpDialogState();
}

class _ChatTimesUpDialogState extends State<ChatTimesUpDialog> {
  bool isLoadingAd = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 20.0,
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(22)),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              width: double.maxFinite,
              child: ListView(shrinkWrap: true, children: [
                const SizedBox(height: 20.0),
                MyTextEdit(
                  text: 'Remove Watermark',
                  color: Colors.white,
                  align: TextAlign.center,
                  size: 16.0,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 20.0),
                MyTextEdit(
                  text:
                      'Purchase Premium version or\nwatch an ad to remove watermark.',
                  color: Colors.white,
                  weight: FontWeight.w500,
                  size: 16,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 30.0),
                !isLoadingAd
                    ? InkWell(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              isLoadingAd = true;
                            });
                          }
                          AdServices().loadRewardAd((isLod) {
                            setState(() {
                              isLoadingAd = isLod;
                            });
                          });
                        },
                        child: Container(
                          height: 50.0,
                          margin: const EdgeInsets.symmetric(horizontal: 34.0),
                          decoration: BoxDecoration(
                            color: AppColor.lightpinkColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_outline_outlined,
                                    color: Colors.white, size: 35.0),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: MyTextEdit(
                                    text: 'Watch a video to continue'
                                        .toUpperCase(),
                                    color: Colors.white,
                                    maxlines: 2,
                                    size: 13.0,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 30.0),
                InkWell(
                  onTap: () {
                    widget.onExit!(context);
                    Get.off(() => const SubscriptionScreen());
                  },
                  child: Container(
                    height: 50.0,
                    margin: const EdgeInsets.symmetric(horizontal: 34.0),
                    decoration: BoxDecoration(
                      color: AppColor.scaffoldBgColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: MyTextEdit(
                        text: 'go to premium'.toUpperCase(),
                        color: Colors.white,
                        size: 13.0,
                        maxlines: 2,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ]),
            ),
          ),
        );
      }),
    );
  }
}

// ignore: must_be_immutable
class MyTextEdit extends StatelessWidget {
  var text,
      color,
      weight,
      // family,
      align,
      spacing,
      decoration,
      maxlines,
      overFlow;
  double? size;

  MyTextEdit(
      {super.key,
      required this.text,
      this.color,
      this.weight,
      // this.family,
      this.size,
      this.spacing,
      this.align,
      this.decoration,
      this.overFlow,
      this.maxlines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxlines,
      style: TextStyle(
          overflow: overFlow ?? TextOverflow.ellipsis,
          decoration: decoration,
          letterSpacing: spacing,
          color: color,
          fontSize: size,
          // fontFamily: "varsity",
          fontWeight: weight),
    );
  }
}
