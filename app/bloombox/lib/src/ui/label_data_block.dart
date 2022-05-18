import 'package:flutter/material.dart';

class LabelDataBlock extends StatefulWidget {
  final String title;
  final String dataCode;
  final Stream stream;

  const LabelDataBlock({
    Key? key,
    required this.title,
    required this.dataCode,
    required this.stream,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _LabelDataBlockState();
  }
}

class _LabelDataBlockState extends State<LabelDataBlock> {
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
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Text( 
            widget.title,
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        Expanded( 
        flex: 6,
        child: StreamBuilder(
          stream: widget.stream,
          builder: (context, snapshot) {
            String? data = 'NOT CONNECTED';
            double textSize = 40;
            
            if (snapshot.hasData) {
              debugPrint(snapshot.data.toString());
              // Get the value from the response message by parsing the string with the 
              // correct widget code for the value to display
              RegExp re = RegExp('${widget.dataCode}: (.+)');
              debugPrint(re.toString());
              data = re.firstMatch(snapshot.data.toString())?.group(1);

              // If a different code was sent, just use the previous value
              if (data == null) {
                return Text(
                  _lastVal,
                  style: TextStyle(
                    fontSize: textSize,
                  ),
                );
              } else {
                // Since the code was valid, update the previous value to this value
                _lastVal = data.toString();
              }

              debugPrint(re.firstMatch(snapshot.data.toString()).toString());

              // Convert the data to a percentage of moisture
              if (widget.dataCode == 'MST') {
                double? dataNum = double.tryParse(data);
          
                if (dataNum == null) {
                  return Text(
                    _lastVal,
                    style: TextStyle(
                      fontSize: textSize,
                    ),
                  );
                }
                      
                // Convert the data value to the percentage
                dataNum = (100.0 - (((dataNum - 1000.0) / 2000.0) * 100)).toDouble();
                data = dataNum.round().toString();

                // Update the last value
                _lastVal = data;
              }
            }
            
            if (data == 'NOT CONNECTED') {
              textSize = 25;
            }

            return Text(
              data.toString(),
              style: TextStyle(  
                fontSize: textSize,
              ),
            );
            }
          )
        ),
      ],
    );
  }
}