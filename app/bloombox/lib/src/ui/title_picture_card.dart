import 'package:flutter/material.dart';

class TitlePictureCard extends StatefulWidget {
  final String title;
  final Function fcn;

  const TitlePictureCard({
    Key? key, 
    required this.title,
    required this.fcn,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _TitlePictureCardState();
  }
}

class _TitlePictureCardState extends State<TitlePictureCard> {
  @override 
  Widget build(BuildContext context) {
    return Card( 
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          debugPrint('${widget.title} card tapped');
          widget.fcn();
        },
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                '${widget.title}', 
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: const Image(
                image: AssetImage('lib/assets/Logo.png'),
              )
            )
          ]
        ),
      )
    );
  }
}