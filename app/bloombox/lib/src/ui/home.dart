import 'package:bloombox/src/ui/lighting.dart';
import 'package:flutter/material.dart';
import './title_data_card.dart';
import './title_picture_card.dart';
import './water.dart';
import './camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  
  @override 
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final String _url = ''; // Set this equal to the WebSocket url from the server
  WebSocketChannel? _channel; // The WebSocket channel used for sending messages back to the device
  Stream? _broadcast; // Stream of incoming messages from the server

  @override 
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(_url)); // Connect to the device
    _broadcast = _channel?.stream.asBroadcastStream(); // Allow the stream to be read from multiple widgets

    // Delay to wait for the connection
    Future.delayed(const Duration(milliseconds: 500), () { 
      _channel!.sink.add('GLUX');
      _channel!.sink.add('GMST');
    });
  }

  @override 
  void dispose() {
    _channel!.sink.close();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BloomBox'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 50.0),
          child: Column (
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5, 
                      child: TitleDataCard(
                        title: 'Moisture', 
                        dataCode: 'MST',
                        channel: _broadcast!,
                        fcn: () {
                          // Change to the water screen
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => 
                              Water( 
                                channel: _channel!,
                                broadcast: _broadcast!,
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                    Expanded(
                      flex: 5, 
                      child: TitleDataCard(
                        title: 'Brightness', 
                        dataCode: 'LUX',
                        channel: _broadcast!,
                        fcn: () {
                          // Change to the brightness screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                              Lighting(
                                channel: _channel!, 
                                broadcast: _broadcast!,
                              ),
                            ),
                          );
                        }
                      )
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: TitlePictureCard(
                  title: 'Camera',
                  fcn: () {
                    // Change to the camera screen
                    Navigator.push( 
                      context,
                      MaterialPageRoute(builder: (context) => 
                        Camera(
                          channel: _channel!,
                          broadcast: _broadcast!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}