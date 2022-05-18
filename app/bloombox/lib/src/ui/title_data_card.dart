import 'package:flutter/material.dart';

class TitleDataCard extends StatefulWidget {
  final String title;
  final String dataCode;
  final Stream channel;
  final Function fcn;

  const TitleDataCard({
    Key? key, 
    required this.title, 
    required this.dataCode,
    required this.channel,
    required this.fcn,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _TitleDataCardState();
  }
}

class _TitleDataCardState extends State<TitleDataCard> {
  String _lastVal = '-2'; // Saved value of the previous data

  @override
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  } 

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
                widget.title, 
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: StreamBuilder(
                stream: widget.channel,
                builder: (context, snapshot) {
                  String? data = 'NOT CONNECTED';
                  double textSize = 40;

                  // Check if data was received
                  if (snapshot.hasData) {
                    // Extract the data from the message that was sent
                    data = snapshot.data.toString();
                    RegExp re = RegExp('${widget.dataCode}: ((\\w|\\.)+)');
                    data = re.firstMatch(snapshot.data.toString())?.group(1);

                    // If the data is invalid then output the previous value on the widget
                    if (data == null) {
                      return Text(
                        _lastVal,
                        style: TextStyle(
                          fontSize: textSize,
                        ),
                      );
                    } else {
                      _lastVal = data.toString();
                    }
                    
                    // If it is a moisture value then convert the data to a percentage
                    if (widget.dataCode == 'MST') {
                      double? dataNum = double.tryParse(data);
          
                      // If it cannot properly parse then return the last value in the widget
                      if (dataNum == null) {
                        return Text(
                          _lastVal,
                          style: TextStyle(
                            fontSize: textSize,
                          ),
                        );
                      }
                      
                      // Calculate the percentage
                      dataNum = (100.0 - (((dataNum - 1000.0) / 2000.0) * 100)).toDouble();
                      data = dataNum.round().toString();

                      _lastVal = data.toString();
                    }
                    
                  }
                  
                  // Update the size of the text if it is not connected to fit better
                  if (data == 'NOT CONNECTED') {
                    textSize = 25;
                  }
                  
                  // Return the widget
                  return Text(
                    data.toString(),
                    style: TextStyle(
                      fontSize: textSize,
                    ),
                  );
                }
              )
            )
          ]
        ),
      )
    );
  }

}
