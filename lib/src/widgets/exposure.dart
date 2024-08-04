import 'package:camera/camera.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:flutter/material.dart';

class ExposureModeControlWidget extends StatefulWidget {
  const ExposureModeControlWidget({
    super.key,
    required this.controller,
  });

  final CameraController? controller;

  @override
  State<ExposureModeControlWidget> createState() =>
      _ExposureModeControlWidgetState();
}

class _ExposureModeControlWidgetState extends State<ExposureModeControlWidget> {
  List<ExposureMode> exposureModes = [ExposureMode.auto, ExposureMode.locked];
  ExposureMode? selectedExposureMode = ExposureMode.auto;

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (widget.controller == null) {
      return;
    }

    try {
      await widget.controller!.setExposureMode(mode);
    } on CameraException {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tooltip(
          message: 'Exposure mode',
          child: Row(
            children: [
              const Icon(
                Icons.exposure,
                color: Colors.white,
              ),
              const SizedBox(width: 6.0),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  iconEnabledColor: Colors.white,
                  value: selectedExposureMode,
                  selectedItemBuilder: (context) => [
                    const DropdownMenuItem(
                      value: ExposureMode.auto,
                      child: Text(
                        'AUTO',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: ExposureMode.locked,
                      child: Text(
                        'LOCKED',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  /*selectedItemBuilder: (context) => [
                    for (final item in exposureModes)
                      DropdownMenuItem<ExposureMode>(
                        value: item,
                        child: Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],*/
                  /*items: exposureModes
                      .map(
                        (item) => DropdownMenuItem<ExposureMode>(
                          value: item,
                          child: Text(
                            "${item.name.toUpperCase()} EXPOSURE",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                      .toList(),*/
                  items: [
                    DropdownMenuItem(
                      value: ExposureMode.auto,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              AppColor.lightpinkColor,
                              AppColor.blueColor
                            ])),
                        child: const Text(
                          'AUTO EXPOSURE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: ExposureMode.locked,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              AppColor.lightpinkColor,
                              AppColor.blueColor
                            ])),
                        child: const Text(
                          'LOCKED EXPOSURE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (item) => setState(() {
                    selectedExposureMode = item as ExposureMode;
                    if (widget.controller != null) {
                      onSetExposureModeButtonPressed(item);
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(widget.minAvailableExposureOffset.toString()),
            Slider(
              value: widget.currentExposureOffset,
              min: widget.minAvailableExposureOffset,
              max: widget.maxAvailableExposureOffset,
              label: widget.currentExposureOffset.toString(),
              onChanged: widget.minAvailableExposureOffset ==
                      widget.maxAvailableExposureOffset
                  ? null
                  : widget.setExposureOffset,
            ),
            Text(widget.maxAvailableExposureOffset.toString()),
          ],
        ),*/
      ],
    );
  }
}

class ExposureSlider extends StatefulWidget {
  const ExposureSlider({
    super.key,
    required this.minAvailableExposureOffset,
    required this.maxAvailableExposureOffset,
    required this.currentExposureOffset,
    required this.setExposureOffset,
  });

  final double minAvailableExposureOffset;
  final double maxAvailableExposureOffset;
  final double currentExposureOffset;
  final Function(double) setExposureOffset;

  @override
  State<ExposureSlider> createState() => _ExposureSliderState();
}

class _ExposureSliderState extends State<ExposureSlider> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Tooltip(
          message: 'Default exposure',
          child: TextButton(
            onPressed: () {
              widget.setExposureOffset(0.0);
            },
            child: const Row(
              children: [
                Icon(Icons.restore),
                SizedBox(
                  width: 8.0,
                ),
                Text('Reset'),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.minAvailableExposureOffset.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            SliderTheme(
              data: SliderThemeData(
                showValueIndicator: ShowValueIndicator.always,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: widget.currentExposureOffset,
                min: widget.minAvailableExposureOffset,
                max: widget.maxAvailableExposureOffset,
                label: widget.currentExposureOffset.toStringAsFixed(2),
                onChanged: widget.minAvailableExposureOffset ==
                        widget.maxAvailableExposureOffset
                    ? null
                    : widget.setExposureOffset,
              ),
            ),
            Text(
              widget.maxAvailableExposureOffset.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
