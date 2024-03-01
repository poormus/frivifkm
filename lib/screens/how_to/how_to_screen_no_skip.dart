import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/how_to_object.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/utils.dart';

class HowToNoSkip extends StatefulWidget {
  const HowToNoSkip({Key? key}) : super(key: key);

  @override
  _HowToNoSkipState createState() => _HowToNoSkipState();
}

class _HowToNoSkipState extends State<HowToNoSkip> {
  PageController _pageController = PageController();
  double currentPage = 0;
  List<Tutorial> tutorialList = [
    Tutorial(title: 'Welcome to Frivi'.tr(), lottieAsset: 'assets/1.png'),
    Tutorial(title: '', lottieAsset: 'assets/2.png'),
    Tutorial(title: '', lottieAsset: 'assets/3.png'),
    Tutorial(title: '', lottieAsset: 'assets/4.png'),
    Tutorial(title: '', lottieAsset: 'assets/5.png'),
    Tutorial(title: '', lottieAsset: 'assets/6.png'),
    Tutorial(title: '', lottieAsset: 'assets/7.png'),
    Tutorial(title: '', lottieAsset: 'assets/8.png'),
    Tutorial(title: '', lottieAsset: 'assets/9.png'),
  ];

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!;
      });
    });

    super.initState();
  }

  void _onChanged(int index) {
    setState(() {
      currentPage = index.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return buildScaffold('How To'.tr(), context, buildBody(size), null);
  }

  Widget buildBody(Size size) {
    return Column(
      children: [
        Container(
          height: size.height * 0.6,
          child: PageView.builder(
              onPageChanged: _onChanged,
              itemCount: tutorialList.length,
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              itemBuilder: (context, index) {
                return _buildPageView(tutorialList[index]);
              }),
        ),
        Spacer(),
        DotsIndicator(
            dotsCount: tutorialList.length, position: currentPage.toInt()),
        Spacer(),
      ],
    );
  }

  Widget _buildPageView(Tutorial tutorial) {
    return Column(
      children: [
        Image.asset(tutorial.lottieAsset),
        Text(tutorial.title),
      ],
    );
  }
}
