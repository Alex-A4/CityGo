import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/domain/entities/visit_place/image_src.dart';
import 'package:city_go/localization/localization.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Виджет, содержащий описание к какому-то объекту, используется вместе с
/// [DraggableScrollableSheet].
class DescriptionWidget extends StatelessWidget {
  final String description;
  final double minHeight;
  final List<ImageSrc> images;

  DescriptionWidget({
    Key key,
    @required this.description,
    @required this.minHeight,
    this.images,
  })  : assert(description != null && minHeight != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key('DescriptionMaterial'),
      child: Container(
        key: Key('DescriptionContainerUnderMaterial'),
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          key: Key('DescriptionColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.keyboard_arrow_up_outlined,
                size: 30,
                color: orangeColor,
              ),
            ),
            Text(
              context.localization(DESCRIPTION_WORD),
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'AleGrey',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              key: Key('DescriptionBaseText'),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'MontserRat',
              ),
            ),
            if (images != null)
              DescriptionImages(key: Key('DescriptionImages'), images: images),
          ],
        ),
      ),
      color: Colors.white,
    );
  }
}

class DescriptionImages extends StatelessWidget {
  final List<ImageSrc> images;

  DescriptionImages({Key key, @required this.images})
      : assert(images != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: size.height * 0.45,
      constraints: BoxConstraints(minHeight: 300, maxHeight: 500),
      child: LayoutBuilder(
        builder: (_, constraints) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (_, i) {
              return Container(
                child: DescriptionImageCard(
                  image: images[i],
                  maxWidth: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DescriptionImageCard extends StatelessWidget {
  final ImageSrc image;
  final double height;
  final double maxWidth;

  DescriptionImageCard({
    Key key,
    @required this.image,
    @required this.height,
    @required this.maxWidth,
  })  : assert(image != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = maxWidth * 0.7;
    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: height,
      width: w > height ? height : w,
      child: Material(
        color: Colors.transparent,
        elevation: 7,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: image.path == null
              ? Container()
              : Image.network(image?.path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
