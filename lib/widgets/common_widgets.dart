import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget getCardForImageName(
    String imgName, String text, Function() onTap, bool isSelected) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 2,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(imgName, fit: BoxFit.fitHeight)),
            Container(
              alignment: Alignment.center,
              height: 30,
              color: Colors.black12,
              child: Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(1.5),
                margin: EdgeInsets.all(5),
                height: 8,
                width: 8,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Container(
                  decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.grey,
                      shape: BoxShape.circle),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget getImageCard(String imgUrl) {
  return Card(
    // semanticContainer: true,
    color: Colors.white,
    // clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
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

Widget getBuyImageCard(String imgUrl) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    child: Container(
      child: Column(
        children: [
          Expanded(
              child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )),
          Container(
            color: Colors.orangeAccent.withOpacity(0.8),
            alignment: Alignment.center,
            height: 25,
            child: Text('Buy',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          )
        ],
      ),
    ),
  );
}
