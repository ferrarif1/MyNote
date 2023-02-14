import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageHelper extends StatelessWidget {
  const ImageHelper(this.path, {Key? key, this.width, this.height,this.color})
      : super(key: key);
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   return Image.asset(
    //     'assets$path',
    //     width: width,
    //     height: height,
    //   );
    // }
    return Image.asset(
      'assets$path',
      width: width,
      height: height,
      color: color,
    );
  }
}

class SvgHelper extends StatelessWidget {
  const SvgHelper(this.path,
      {Key? key, this.width, this.height, this.semanticsLabel, this.color})
      : super(key: key);
  final String path;
  final double? width;
  final double? height;
  final String? semanticsLabel;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   return SvgPicture.asset(
    //     'assets$path',
    //     width: width,
    //     height: height,
    //     color: color,
    //     semanticsLabel: semanticsLabel,
    //   );
    // }
    return SvgPicture.asset(
      'assets$path',
      width: width,
      height: height,
      color: color,
      semanticsLabel: semanticsLabel,
    );
  }
}
