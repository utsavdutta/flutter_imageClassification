import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  List _results;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image classification'),
      ),
      body: Column(
        children: [
          if (_image != null)
            Container(margin: EdgeInsets.all(10), child: Image.file(_image))
          else
            Container(
              margin: EdgeInsets.all(40),
              child: Opacity(
                opacity: 0.6,
                child: Center(
                  child: Text('No Image Selected!'),
                ),
              ),
            ),
          SingleChildScrollView(
            child: Column(
              children: _results != null
                  ? _results.map((result) {
                      return Card(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            "${result["label"]} -  ${result["confidence"].toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList()
                  : [],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAnImage,
        tooltip: 'Select Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
    print(res);
  }

  Future pickAnImage() async {
    // pick image and...
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // Perform image classification on the selected image.
    imageClassification(image);
  }

  Future imageClassification(File image) async {
    // Run tensorflowlite image classification model on the image
    final List results = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = results;
      _image = image;
    });
  }
}
