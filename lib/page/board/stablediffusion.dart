import 'dart:io';
import 'dart:typed_data';
import 'package:new_bc/manager/stablediffusion_controller.dart';
import 'package:new_bc/page/board/upload_desription.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import 'package:quiver/strings.dart';

import '../../manager/firebase_controller.dart';

class StableDiffusionScreen extends StatefulWidget {
  @override
  _StableDiffusionScreenState createState() => _StableDiffusionScreenState();
}

enum SeedOption { random, custom }

class _StableDiffusionScreenState extends State<StableDiffusionScreen> {
  List<dynamic>? _image;
  late File imageFile;
  bool _loading = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void scrollAnimate() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(MediaQuery.of(context).viewInsets.bottom,
          duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
    });
  }

  Future<Uint8List> fetchImageData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to fetch image');
    }
  }

  Future<void> downloadImage(String url) async {
    // 갤러리 접근 권한 요청
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    Uint8List downloadedFile = await fetchImageData(url);

    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (status.isGranted) {
      /* final result = await ImageGallerySaver.saveImage(downloadedFile);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access gallery denied')),
      );*/
    }
  }

  Future<File> createFileFromURL(String dataURL, String fileName) async {
    try {
      final response = await http.get(Uri.parse(dataURL));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();

        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter new request URL'),
          content: TextField(
            controller: TextEditingController(
              text: MyFire.box.read('diffusion_url') ?? '',
            ),
            decoration: InputDecoration(
              hintText: 'Enter URL',
            ),
            onChanged: (value) {
              // Update the value as the user types
              MyFire.box.write('diffusion_url', value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the value and close the dialog
                MyFire.box
                    .write('diffusion_url', MyFire.box.read('diffusion_url'));
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  SeedOption? _selectedOption = SeedOption.random;
  TextEditingController _customController = TextEditingController();
  TextEditingController _negativePromptController = TextEditingController();
  int _currentImageIndex = 0;
  Widget _buildCustomRadioButton(SeedOption option, String label) {
    final bool isSelected = _selectedOption == option;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });

        Future.microtask(() {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
      child: Container(
        width: 176,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                isSelected ? Colors.blueAccent.withOpacity(0.7) : Colors.grey,
            width: 1.3,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Colors.blueAccent.withOpacity(1)
                  : Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  bool isFlipped = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.5),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          title: const Text(
            'Stable Diffusion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: IconButton(
                icon: Icon(
                  Icons.build_circle,
                  color: Colors.grey.withOpacity(0.5),
                  size: 40,
                ),
                onPressed: () {
                  _showEditDialog(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.blue.withOpacity(0.5),
                  size: 38,
                ),
                onPressed: () async {
                  if (_image != null) {
                    imageFile = await createFileFromURL(
                        _image![(_currentImageIndex)], 'image.png');
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UploadDescription(selectedImg: imageFile),
                      ),
                    );
                  } else {
                    _showDialog("Error", "create your AI image");
                  }
                },
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 이미지 표시 위젯
                  _loading
                      ? SizedBox(
                          width: 100,
                          height: 360,
                          child: SpinKitFadingCircle(
                            itemBuilder: (BuildContext context, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Color.fromARGB(255, 85, 165, 255)
                                      : Colors.green,
                                ),
                              );
                            },
                          ),
                        )
                      : _image != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentImageIndex =
                                          (_currentImageIndex + 1) %
                                              _image!.length;
                                    });
                                  },
                                  child: Container(
                                      height: 380,
                                      child: Image.network(_image![
                                          _currentImageIndex %
                                              _image!.length])),
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      onPressed: () => downloadImage(_image![
                                          _currentImageIndex % _image!.length]),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color:
                                            Color.fromARGB(255, 144, 163, 190),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Color.fromARGB(255, 255, 255, 255),
                              height: 360,
                              child: Image.asset(
                                //logo
                                'assets/images/aieev_logo.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                  SizedBox(height: 30),
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.all(3.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 180.0,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: Center(
                            child: SizedBox(
                              height: 180.0,
                              child: TextField(
                                controller: _textController,
                                onTap: () {
                                  scrollAnimate();
                                },
                                maxLines: 100,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'Describe the image you want with text',
                                  hintStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.blueAccent.withOpacity(0.7),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Seed',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            _buildCustomRadioButton(
                                SeedOption.random, 'Random'),
                            Spacer(),
                            _buildCustomRadioButton(
                                SeedOption.custom, 'Custom'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (_selectedOption == SeedOption.custom)
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: InkWell(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      child: TextField(
                                          controller: _customController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Enter seed number',
                                            hintStyle: TextStyle(fontSize: 14),
                                            border: OutlineInputBorder(),
                                          ),
                                          onTap: () {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          }),
                                      onTap: () {
                                        _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.red.withOpacity(0.7),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Negative prompt',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                    controller: _negativePromptController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Enter negative prompt (e.g. No animals, No kids..)',
                                      hintStyle: TextStyle(fontSize: 14),
                                      border: OutlineInputBorder(),
                                    ),
                                    onTap: () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 8.0, bottom: 30.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color.fromARGB(255, 191, 221, 255),
                        Color.fromARGB(255, 195, 228, 255),
                        Color.fromRGBO(182, 173, 255, 1),
                      ],
                    ),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 72,
                    onPressed: () async {
                      if (_textController.text.isEmpty) {
                        _showDialog("Create Error",
                            "Please enter some text feild to generate an image.");
                      } else {
                        print("push submit");
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _loading = true; // 로딩 상태 시작
                        });
                        if (_selectedOption == SeedOption.random) {
                          var ranNum = Random().nextInt(10000000) + 1;
                          _customController.text = ranNum.toString();
                          print("ranNUm" + _customController.text);
                        }
                        _image = await StableManager().convertTextToImage(
                            _textController.text,
                            _customController.text,
                            _negativePromptController.text);
                        if (_image!.contains("null")) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("오류"),
                                content: Text("잘못된 HTTP 요청입니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                          _image = null;
                        }
                        setState(() {
                          _loading = false; // 로딩 상태 종료
                        });
                      }
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Create AI image",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color.fromARGB(255, 73, 48, 0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
