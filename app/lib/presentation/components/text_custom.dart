import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextCustom extends StatelessWidget {
  final String text;
  final String fontName;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextOverflow textOverflow;
  final int? maxLines;
  final TextAlign textAlign;
  final double? letterSpacing;
  final double? height;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;

  const TextCustom({
    super.key,
    required this.text,
    this.fontName = 'Cairo',
    this.fontSize = 14,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textOverflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.left,
    this.letterSpacing,
    this.height,
    this.decoration,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: GoogleFonts.getFont(
        fontName,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle,
      ),
    );
  }
}
