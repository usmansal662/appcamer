import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class FocusModeControlWidget extends StatefulWidget {
  const FocusModeControlWidget({
    super.key,
    required this.controller,
  });

  final CameraController? controller;

  @override
  State<FocusModeControlWidget> createState() => _FocusModeControlWidgetState();
}

class _FocusModeControlWidgetState extends State<FocusModeControlWidget> {
  List<FocusMode> focusModes = [FocusMode.auto, FocusMode.locked];
  FocusMode? selectedFocusMode = FocusMode.auto;

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (widget.controller == null) {
      return;
    }

    try {
      await widget.controller!.setFocusMode(mode);
    } on CameraException {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Focus mode',
      child: Row(
        children: [
          const Icon(
            Icons.filter_center_focus,
            color: Colors.white,
          ),
          const SizedBox(width: 6.0),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              iconEnabledColor: Colors.white,
              value: selectedFocusMode,
              /*selectedItemBuilder: (context) => [
                for (final item in focusModes)
                  DropdownMenuItem<FocusMode>(
                    value: item,
                    child: Text(
                      item.name.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],*/
              selectedItemBuilder: (context) => [
                const DropdownMenuItem(
                  value: FocusMode.auto,
                  child: Text(
                    'AUTO',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                const DropdownMenuItem(
                  value: FocusMode.locked,
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              items: [
                DropdownMenuItem(
                  value: FocusMode.auto,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          AppColor.lightpinkColor,
                          AppColor.blueColor
                        ])),
                    child: const Text(
                      'AUTO FOCUS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: FocusMode.locked,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          AppColor.lightpinkColor,
                          AppColor.blueColor
                        ])),
                    child: const Text(
                      'LOCKED FOCUS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
              /*items: focusModes
                  .map(
                    (item) => DropdownMenuItem<FocusMode>(
                      value: item,
                      child: Text(
                        '${item.name.toUpperCase()} FOCUS',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                  .toList(),*/
              onChanged: (item) => setState(() {
                selectedFocusMode = item as FocusMode;
                if (widget.controller != null) {
                  onSetFocusModeButtonPressed(item);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
