import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/src/utils/preferences.dart';

import '../../main.dart';

class ResolutionButton extends StatefulWidget {
  const ResolutionButton({
    super.key,
    this.isDense = false,
    this.onNewCameraSelected,
    this.isRearCameraSelected,
    required this.enabled,
  });

  final Function(CameraDescription)? onNewCameraSelected;
  final bool? isRearCameraSelected;
  final bool isDense;
  final bool enabled;

  @override
  State<ResolutionButton> createState() => _ResolutionButtonState();
}

class _ResolutionButtonState extends State<ResolutionButton> {
  List<ResolutionPreset> presets = ResolutionPreset.values;
  List<String> texts = [
    'HD',
    'FULL HD',
  ];
  List<String> textsDense = [
    'HD',
    'FULL HD',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isDense) {
      for (var i = 0; i < texts.length; i++) {
        texts[i] = textsDense[i];
      }
    }

    return Tooltip(
      message: 'Resolution',
      child: DropdownButton(
        alignment: Alignment.center,
        icon: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
        dropdownColor: AppColor.scaffoldBgColor,
        underline: const SizedBox(),

        // icon: Padding(
        //     padding: const EdgeInsets.only(left: 4.0),
        //     child: Icon(Icons.aspect_ratio,
        //         color: widget.enabled

        //             ? widget.isDense
        //                 ? Colors.white
        //                 : null
        //             : Colors.white24),
        //             ),
        value: getResolution(),
        isDense: widget.isDense ? true : false,
        selectedItemBuilder: widget.isDense
            ? (context) {
                return [
                  // Text('LOW',
                  //     style: TextStyle(
                  //         color: widget.enabled ? Colors.white : Colors.white,
                  //         fontWeight: FontWeight.w500)),
                  // Text('MEDIUM',
                  //     style: TextStyle(
                  //         color: widget.enabled ? Colors.white : Colors.white24,
                  //         fontWeight: FontWeight.w500)),
                  Text('HD',
                      style: TextStyle(
                          color: widget.enabled ? Colors.white : Colors.white24,
                          fontWeight: FontWeight.w500)),
                  Text('FULL HD',
                      style: TextStyle(
                          color: widget.enabled ? Colors.white : Colors.white24,
                          fontWeight: FontWeight.w500)),
                  // Text('4K',
                  //     style: TextStyle(
                  //         color: widget.enabled ? Colors.white : Colors.white24,
                  //         fontWeight: FontWeight.w500)),
                  // Text('MAX',
                  //     style: TextStyle(
                  //         fontSize: 10,
                  //         color: widget.enabled ? Colors.white : Colors.white24,
                  //         fontWeight: FontWeight.w500)),
                ];
              }
            : null,
        items: [
          DropdownMenuItem<ResolutionPreset>(
            value: ResolutionPreset.high,
            child: Text(
              texts[0],
              style: TextStyle(
                  fontSize: 10,
                  color: widget.isDense ? Colors.white : null,
                  fontWeight: widget.isDense ? FontWeight.w500 : null),
            ),
          ),
          DropdownMenuItem<ResolutionPreset>(
            value: ResolutionPreset.veryHigh,
            child: Text(
              texts[1],
              style: TextStyle(
                  fontSize: 10,
                  color: widget.isDense ? Colors.white : null,
                  fontWeight: widget.isDense ? FontWeight.w500 : null),
            ),
          ),
          // DropdownMenuItem<ResolutionPreset>(
          //   value: ResolutionPreset.max,
          //   child: Text(
          //     texts[2],
          //     style: TextStyle(
          //         fontSize: 10,
          //         color: widget.isDense ? Colors.white : null,
          //         fontWeight: widget.isDense ? FontWeight.w500 : null),
          //   ),
          // ),
          // DropdownMenuItem<ResolutionPreset>(
          //   value: ResolutionPreset.max,
          //   child: Text(
          //     texts[3],
          //     style: TextStyle(
          //         fontSize: 10,
          //         color: widget.isDense ? Colors.white : null,
          //         fontWeight: widget.isDense ? FontWeight.w500 : null),
          //   ),
          // ),

          // DropdownMenuItem<ResolutionPreset>(
          //   value: ResolutionPreset.ultraHigh,
          //   child: Text(
          //     texts[4],
          //     style: TextStyle(
          //         fontSize: 10,
          //         color: widget.isDense ? Colors.white : null,
          //         fontWeight: widget.isDense ? FontWeight.w500 : null),
          //   ),
          // ),
          // DropdownMenuItem<ResolutionPreset>(
          //   value: ResolutionPreset.max,
          //   child: Text(
          //     texts[5],
          //     style: TextStyle(
          //         fontSize: 10,
          //         color: widget.isDense ? Colors.white : null,
          //         fontWeight: widget.isDense ? FontWeight.w500 : null),
          //   ),
          // ),
        ],
        onChanged: widget.enabled
            ? widget.isDense
                ? (resolution) {
                    setState(() {
                      Preferences.setResolution(
                          (resolution as ResolutionPreset).name);
                    });
                    widget.onNewCameraSelected!(
                        cameras[widget.isRearCameraSelected! ? 0 : 1]);
                  }
                : (resolution) {
                    setState(() {
                      Preferences.setResolution(
                          (resolution as ResolutionPreset).name);
                    });
                  }
            : null,
      ),
    );
  }
}

ResolutionPreset getResolution() {
  final resolutionString = Preferences.getResolution();
  ResolutionPreset resolution = ResolutionPreset.veryHigh;
  for (var res in ResolutionPreset.values) {
    if (res.name == resolutionString) resolution = res;
  }

  return resolution;
}
