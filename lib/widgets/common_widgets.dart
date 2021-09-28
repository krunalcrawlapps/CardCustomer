import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget getCardForImageName(String imgName, String text, Function onTap) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          child: Column(children: [
        Expanded(child: Image.asset(imgName, fit: BoxFit.fitHeight)),
        Container(
          alignment: Alignment.center,
          height: 30,
          child: Text(text,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
        )
      ])),
    ),
  );
}

Widget getImageCard(String imgUrl) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Container(
        child: Column(children: [
      Expanded(
          child: CachedNetworkImage(
        imageUrl: imgUrl,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      )),
    ])),
  );
}
