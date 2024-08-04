import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 90.0,
      width: MediaQuery.of(context).size.width / 2.25,
      //width: 150,
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(15.0)),
      child: const Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 12.0, right: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10.0),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
