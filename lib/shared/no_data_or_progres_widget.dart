import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String info;
  final bool isProgress;
  final String? asset;

  const NoDataWidget(
      {Key? key, required this.info, required this.isProgress, this.asset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!isProgress) {
      if (asset != null) {
        return Center(
          child: Container(
              height: size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Image.asset(asset!),
                  ),
                  SizedBox(height: 8,),
                  Center(child: Text(info)),
                ],
              )),
        );
      } else
        return Container(
            height: size.height * 0.5, child: Center(child: Text(info)));
    } else {
      return Container(
          height: size.height * 0.5,
          child: Center(child: CircularProgressIndicator()));
    }
  }
}
