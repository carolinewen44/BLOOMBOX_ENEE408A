import 'package:bloombox/src/ui/label_data_block.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class Water extends StatefulWidget {
  final WebSocketChannel channel;
  final Stream broadcast;

  const Water({ 
    Key? key,
    required this.channel,
    required this.broadcast,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _WaterState();
  }
}

class _WaterState extends State<Water> {
  @override 
  void initState() {
    super.initState();
    // Get the initial value for the moisture
    widget.channel.sink.add('GMST');
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water',
      home: Scaffold(  
        appBar: AppBar(  
          leading: BackButton(  
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            '      Water      ',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        body: Padding(  
          padding: const EdgeInsets.only(left: 15.0, top: 75.0, right: 15.0, bottom: 75.0),
          child: Card(  
            child: Padding(  
              padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
              child: Column(  
                children: [  
                  Expanded(  
                    flex: 4, 
                    child: LabelDataBlock(  
                      title: 'Moisture',
                      dataCode: 'MST',
                      stream: widget.broadcast,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Divider(  
                      height: 1,
                      thickness: 5, 
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(  
                    flex: 4,
                    child: SizedBox(
                      height: 10,
                      width: double.infinity,
                      child: TextButton(  
                        style: ButtonStyle(  
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          // Send command to have the pump turned on and water the plant
                          widget.channel.sink.add('WPMP');
                        },
                        child: const Text(
                          'Water',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}