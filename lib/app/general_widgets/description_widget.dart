import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/visit_place/image_src.dart';
import 'package:city_go/localization/localization.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// Виджет, содержащий описание к какому-то объекту.
/// Этот виджет уже сам по себе реализует вытягивание и скролл за счет
/// [SlidingUpPanel], поэтому ему нужно передать только максимальную и
/// минимальную высоты.
/// Лучше всего оборачивать [DescriptionWidget] в [Stack].
class DescriptionWidget extends StatefulWidget {
  final List<ImageSrc> images;
  final String description;
  final double minHeight;
  final double maxHeight;

  DescriptionWidget({
    Key key = const Key('DescriptionWidget'),
    @required this.description,
    @required this.minHeight,
    @required this.maxHeight,
    this.images,
  })  : assert(description != null && minHeight != null && maxHeight != null),
        super(key: key);

  @override
  _DescriptionWidgetState createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  PanelController _controller = PanelController();

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      controller: _controller,
      panelBuilder: (c) {
        return Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AdaptiveButton(
                  padding: 0,
                  needBorder: false,
                  backgroundColor: Colors.transparent,
                  onTap: () {
                    _controller.isPanelOpen
                        ? _controller.close()
                        : _controller.open();
                  },
                  child: Icon(
                    Icons.keyboard_arrow_up_outlined,
                    size: 30,
                    color: orangeColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AutoSizeText(
                  context.localization(DESCRIPTION_WORD),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'AleGrey',
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: c,
                  child: DescriptionContent(
                    description: widget.description,
                    images: widget.images,
                    minHeight: widget.minHeight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Контент описательного виджета, который содержит текст и картинки по необходимости
class DescriptionContent extends StatelessWidget {
  final List<ImageSrc> images;
  final String description;
  final double minHeight;

  DescriptionContent({
    Key key,
    @required this.images,
    @required this.description,
    @required this.minHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('DescriptionContainerUnderMaterial'),
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: Key('DescriptionColumn'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          AutoSizeText(
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
                  client: sl(),
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
  final HttpClient client;
  final double height;
  final double maxWidth;

  DescriptionImageCard({
    Key key,
    @required this.image,
    @required this.height,
    @required this.maxWidth,
    @required this.client,
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
              : Image.network(client.getMediaPath(image.path),
                  fit: BoxFit.cover),
        ),
      ),
    );
  }
}
