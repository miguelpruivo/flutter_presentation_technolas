import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

enum Technolas {
  happy,
  sad,
  neutral,
}

void main() => runApp(MaterialApp(
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Technolas _technolasMood = Technolas.happy;
  String _currentAsset;
  CameraController _cameraController;
  String photoPath;
  bool photoReady = false;

  @override
  void initState() {
    super.initState();
    _updateAsset();
  }

  void initCamera() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final path = '${appDocDir.path}/photo' + Random().nextInt(1000).toString();
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    _cameraController.initialize().then((_) async {
      if (!mounted) return;

      Future.delayed(Duration(seconds: 1)).then((_) async {
        await _cameraController.takePicture(path);
        setState(() {
          photoPath = path;
          photoReady = true;
        });
      });
    });
  }

  void _updateAsset() {
    switch (_technolasMood) {
      case Technolas.happy:
        _currentAsset = 'assets/technolas_happy.png';
        break;
      case Technolas.neutral:
        _currentAsset = 'assets/technolas_neutral.png';
        break;
      case Technolas.sad:
        _currentAsset = 'assets/technolas_sad.png';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Example app'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: DropdownButton(
                value: _technolasMood,
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text('Happy'),
                    value: Technolas.happy,
                  ),
                  DropdownMenuItem(
                    child: Text('Sad'),
                    value: Technolas.sad,
                  ),
                  DropdownMenuItem(
                    child: Text('Neutral'),
                    value: Technolas.neutral,
                  )
                ],
                onChanged: (value) {
                  print('New mood: ' + value.toString());
                  setState(() {
                    _technolasMood = value;
                    _updateAsset();
                  });
                },
              ),
            ),
            Hero(tag: 'technolas', child: Image.asset(_currentAsset)),
            Align(
                alignment: Alignment(-0.75, 0.3),
                child: Image.asset(
                  'assets/camera.png',
                  height: 100.0,
                )),
            Align(
              alignment: Alignment(0.75, 0.3),
              child: photoPath != null
                  ? InkWell(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (BuildContext context) => SecondScreen(photoPath))),
                      child: Hero(
                        tag: 'photo',
                        child: Image.file(
                          File(photoPath),
                          height: 100.0,
                        ),
                      ))
                  : Container(
                      height: 100.0,
                      width: 100.0,
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                child: Text('Take a picture'),
                onPressed: () => initCamera(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final String photoPath;
  SecondScreen(this.photoPath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second screen'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: 'photo',
                child: Image.file(
                  File(photoPath),
                ),
              ),
            ),
            Expanded(
              child: Hero(
                tag: 'technolas',
                child: Image.asset('assets/technolas_happy.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
