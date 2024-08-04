import 'package:flutter/material.dart';

class EndlessAnimation extends StatefulWidget {
  final double height;
  final double width;

  const EndlessAnimation({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  State<EndlessAnimation> createState() => _EndlessAnimationState();
}

class _EndlessAnimationState extends State<EndlessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<Offset> _animation1;
  late AnimationController _controller2;
  late Animation<Offset> _animation2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });

    _animation1 =
        Tween<Offset>(begin: Offset.zero, end: Offset(-widget.width, 0))
            .animate(_controller1);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });

    _animation2 =
        Tween<Offset>(begin: Offset(-widget.width, 0), end: Offset.zero)
            .animate(_controller2);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();

    super.dispose();
  }

  List<String> list1 = [
    'assets/sub/1.png',
    'assets/sub/2.png',
    'assets/sub/3.png',
    'assets/sub/4.png',
    'assets/sub/5.png',
    'assets/sub/6.png',
  ];
  List<String> list2 = [
    'assets/sub/7.png',
    'assets/sub/8.png',
    'assets/sub/9.png',
    'assets/sub/10.png',
    'assets/sub/11.png',
    'assets/sub/12.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          widget1(list1),
          widget2(list2),
        ],
      ),
    );
  }

  Widget widget1(List<String> list) => Container(
        width: widget.width,
        height: widget.height / 2,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Transform.translate(
          offset: _animation1.value,
          child: Row(
            children: List.generate(
              list.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: Image.asset(
                  list[index],
                  height: widget.height * 0.4,
                  width: widget.width * 0.3,
                ),
              ),
            ),
          ),
        ),
      );

  Widget widget2(List<String> list) => Container(
        width: widget.width,
        height: widget.height / 2,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Transform.translate(
          offset: _animation2.value,
          child: Row(
            children: List.generate(
              list.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: Image.asset(
                  list[index],
                  height: widget.height * 0.4,
                  width: widget.width * 0.3,
                ),
              ),
            ),
          ),
        ),
      );
}
