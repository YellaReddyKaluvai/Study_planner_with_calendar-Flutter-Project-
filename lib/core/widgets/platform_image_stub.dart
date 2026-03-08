import 'package:flutter/material.dart';

Widget platformNetworkImage(String url, {double? width, double? height, BoxFit? fit}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => const Center(
      child: Icon(Icons.person, color: Colors.white, size: 38),
    ),
  );
}
