import 'dart:io';
import 'dart:typed_data';

import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/board/stablediffusion.dart';
import 'package:new_bc/page/board/upload_desription.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  var imageList = <AssetEntity>[];
  var albums = <AssetPathEntity>[];
  var headerTitle = '';
  AssetEntity? selectedImage;
  late File imagefile;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() async {
//    PermissionStatus status = await Permission.storage.request();
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    PermissionStatus status;

    if (android.version.sdkInt >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(minHeight: 100, minWidth: 100),
          ),
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
      if (albums.isNotEmpty) {
        setState(() {
          headerTitle = albums.first.name ?? 'No albums found';
          _loadData();
        });
      } else {
        setState(() {
          headerTitle = 'No albums found';
        });
      }
      print("앨범: $albums");
    } else {
      print('Storage permission not granted');
    } /*
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      albums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          filterOption: FilterOptionGroup(
              imageOption: const FilterOption(
                sizeConstraint: SizeConstraint(minHeight: 100, minWidth: 100),
              ),
              orders: [
                const OrderOption(type: OrderOptionType.createDate, asc: false),
              ]));
      _loadData();
    } else {
      print("권한승인부탁");
      //message 권한 요청
    }*/
  }

  void _loadData() async {
    headerTitle = albums.first.name;
    await _pagingPhotos();
    update();
  }

  Future<void> _pagingPhotos() async {
    var photos = await albums.first.getAssetListPaged(page: 0, size: 30);
    print(photos);
    imageList.addAll(photos);
    selectedImage = imageList.first;
    imagefile = (await selectedImage?.file)!;
  }

  void update() => setState(() {});

  Widget _imagePreview() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: width,
      color: Colors.grey,
      child: selectedImage == null
          ? Container()
          : _photoWidget(selectedImage!, width.toInt(), builder: (data) {
              return Image.memory(data,
                  width: width, height: width, fit: BoxFit.cover);
            }),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  headerTitle,
                  //"Gallery",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            StableDiffusionScreen()), // NewPage는 새로운 페이지 클래스명
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xff808080),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.paintbrush,
                          color: Colors.white.withOpacity(0.7)),
                      Icon(CupertinoIcons.sparkles,
                          color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 3),
                      const Text(
                        'Stable diffusion',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 37,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: const Color(0xff808080)),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _imageSelectList() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: imageList.length,
      itemBuilder: (BuildContext context, int index) {
        return _photoWidget(imageList[index], 200, builder: (data) {
          return GestureDetector(
            onTap: () async {
              selectedImage = imageList[index];

              imagefile = (await selectedImage?.file)!;
              update();
            },
            child: Opacity(
              opacity: imageList[index] == selectedImage ? 0.35 : 1,
              child: Image.memory(data, fit: BoxFit.cover),
            ),
          );
        });
      },
    );
  }

  Widget _photoWidget(AssetEntity asset, int size,
      {required Widget Function(Uint8List) builder}) {
    asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    return FutureBuilder(
        future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
        builder: (_, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return builder(snapshot.data!);
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
          title: const Text('NEW Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.blue.withOpacity(0.5),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadDescription(selectedImg: imagefile),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _imagePreview(),
              _header(),
              _imageSelectList(),
            ],
          ),
        ));
  }
}
