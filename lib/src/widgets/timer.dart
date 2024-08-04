import 'package:flutter/material.dart';
import 'package:camery/src/utils/preferences.dart';

class TimerButton extends StatefulWidget {
  const TimerButton({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  List<Duration> durations = [
    const Duration(seconds: 1),
    const Duration(seconds: 3),
    const Duration(seconds: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Timer',
      child: DropdownButton(
        underline: const SizedBox(),
        icon: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.av_timer,
              size: 25,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Timer',
              style: TextStyle(color: Colors.white, fontSize: 9.16),
            )
          ],
        ),
        iconEnabledColor: Colors.white,
        value: Duration(seconds: Preferences.getTimerDuration()),
        selectedItemBuilder: (context) {
          return durations.map(
            (duration) {
              final name = duration.inSeconds < 60
                  ? '${duration.inSeconds}s'
                  : '${duration.inMinutes}m';

              return DropdownMenuItem(
                child: Text(
                  name,
                  style: TextStyle(
                      color: widget.enabled ? Colors.white : Colors.white24),
                ),
              );
            },
          ).toList()
            ..insert(
              0,
              DropdownMenuItem<Duration>(
                child: Text(
                  '',
                  style: TextStyle(
                      color: widget.enabled ? Colors.white : Colors.white24),
                ),
              ),
            );
        },
        items: durations.map(
          (duration) {
            final name = duration.inSeconds < 60
                ? '${duration.inSeconds}s'
                : '${duration.inMinutes}m';

            return DropdownMenuItem(
              value: duration,
              onTap: () {
                setState(() {
                  Preferences.setTimerDuration(duration.inSeconds);
                });
              },
              child: Text(
                name,
                style: const TextStyle(color: Colors.blue),
              ),
            );
          },
        ).toList()
          ..insert(
            0,
            DropdownMenuItem<Duration>(
              value: const Duration(),
              onTap: () {
                setState(() {
                  Preferences.setTimerDuration(0);
                });
              },
              child: const Text(
                'Off',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        onChanged: widget.enabled ? (_) {} : null,
        iconDisabledColor: Colors.white24,
      ),
    );
  }
}
