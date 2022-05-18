import 'package:bloombox/src/ui/label_data_block.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class Lighting extends StatefulWidget {
  final WebSocketChannel channel;
  final Stream broadcast;

  const Lighting({
    Key? key,
    required this.channel,
    required this.broadcast,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _LightingState();
  }
}

class _LightingState extends State<Lighting> {
  List<bool> _isSelected = [true, false]; // Determines which mode the device is in (auto or manual)
  double _sliderValue = 0; // Value of the slider used to send a new value for the LED

  @override 
  void initState() {
    super.initState();
    // Send a message to get the reading for natural light from the ambient light sensor
    widget.channel.sink.add('GLUX');
    // Initialize selection to always start in auto when this screen is navigated to
    _isSelected = [true, false];
    // Send message to set the device to auto mode since it starts in auto
    widget.channel.sink.add('SLMA');
    _sliderValue = 0;
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(  
      title: 'Lighting',
      home: Scaffold(  
        appBar: AppBar(  
          leading: BackButton(  
            onPressed:() {
              // Send message to get the lux and moisture values so that the homescreen has an updated value
              widget.channel.sink.add('GLUX');
              widget.channel.sink.add('GMST');
              Navigator.pop(context);
            },
          ),
          title: const Text('Lighting'),
        ),
        body: Padding(  
          padding: const EdgeInsets.only(left: 15.0, top: 75.0, right: 15.0, bottom: 35.0),
          child: Column(  
            children: [  
              const Expanded(  
                flex: 1,
                child: Text(
                  'Mode',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                )
              ),
              Expanded(  
                flex: 1,
                child: ToggleButtons(  
                  children: const <Widget>[  
                    Text(
                      ' Auto ',
                      style: TextStyle(  
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      ' User ',
                      style: TextStyle(  
                        fontSize: 20,
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      // Switch the state of the mode buttons when one is pressed
                      for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                        if (buttonIndex == index) {
                          _isSelected[buttonIndex] = true;
                        } else {
                          _isSelected[buttonIndex] = false;
                        }
                      }

                      // Decide which mode to send a message to set the device to
                      if (_isSelected[0] == true) {
                        widget.channel.sink.add('SLMA');
                      } else {
                        widget.channel.sink.add('SLMM');
                      }
                    });
                  },
                  isSelected: _isSelected,
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
                flex: 2, 
                child: LabelDataBlock(  
                  title: 'Brightness',
                  dataCode: 'LUX',
                  stream: widget.broadcast,
                ),
              ),
              Expanded(  
                flex: 3,
                child: Visibility(  
                  child: Column(  
                    children: [  
                      const Expanded(  
                        flex: 1,
                        child: Divider(  
                          height: 1,
                          thickness: 5,
                          color: Colors.grey,
                        ),
                      ),
                      const Expanded(  
                        flex: 2,
                        child: Text(
                          'Set Brightness',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Expanded(  
                        flex: 1,
                        child: Slider(  
                          value: _sliderValue,
                          max: 45,
                          divisions: 45,
                          label: _sliderValue.toInt().toString(),
                          onChanged: (double value) {
                            // Update the slider value
                            setState(() {
                              _sliderValue = value;
                            });
                          },
                        ),
                      ),
                      Expanded(  
                        flex: 1,
                        child: TextButton(  
                          style: ButtonStyle(  
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            // Create a correctly formatted value to send the new value for the LED to the server
                            String val = _sliderValue.toInt().toString();
                            if (0 <= _sliderValue.toInt() && _sliderValue.toInt() <= 9) {
                              val = '0' + val;
                            }

                            // Send this new value
                            widget.channel.sink.add('SL' + val);

                            // Get an update for the lux value
                            Future.delayed(const Duration(milliseconds: 500), () {
                              widget.channel.sink.add('GLUX');
                            });
                          },
                          child: Text(
                            'SEND: ' + _sliderValue.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  visible: _isSelected[1],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}