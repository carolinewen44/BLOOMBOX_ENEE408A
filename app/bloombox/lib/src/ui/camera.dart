import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Camera extends StatefulWidget {
  final WebSocketChannel channel; 
  final Stream broadcast;

  const Camera({
    Key? key,
    required this.channel,
    required this.broadcast,
  }) : super(key: key);

  @override 
  State<StatefulWidget> createState() {
    return _CameraState();
  }
}

class _CameraState extends State<Camera> {
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
    return MaterialApp(
      title: "Camera",
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Camera"),
        ),
        body: Padding(  
          padding: const EdgeInsets.only(left: 15.0, top: 75.0, right: 15.0, bottom: 75.0),
          child: Column(
            children: [
              Expanded(  
                flex: 5,
                child: StreamBuilder(  
                  stream: widget.broadcast,
                  builder: (context, snapshot) {
                    // Check if data was sent
                    if (snapshot.hasData) {
                      // Convert the data to a string
                      String? data = snapshot.data.toString();

                      debugPrint(data);

                      // Received base64, so decode and create an image based on it
                      final picture = base64Decode(data);
                      return Image.memory(picture);
                    } else {
                      // If no data, use a place holder image
                      return const Image(image: AssetImage('lib/assets/Logo.png'));
                    }
                  }
                ),
              ),
              Expanded(  
                flex: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(  
                    child: const Text(
                      'GET PICTURE',
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
                    onPressed: () {
                      // Send message to server to tell it to take and send a picture
                      widget.channel.sink.add('GIMG');
                    },
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}