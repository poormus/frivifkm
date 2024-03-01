import 'package:flutter/material.dart';

class MyMarker extends StatelessWidget {
  // declare a global key and get it trough Constructor

  MyMarker(this.globalKey, this.url);
  final GlobalKey globalKey;
  final String url;
  @override
  Widget build(BuildContext context) {
    // wrap your widget with RepaintBoundary and
    // pass your global key to RepaintBoundary
    return RepaintBoundary(
      key: globalKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration:
            BoxDecoration(
                image: DecorationImage(image: NetworkImage(url)),
                color: Colors.black, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}