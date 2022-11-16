  import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
  import 'package:image/image.dart' as imglib;
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
class frist extends StatefulWidget {
  const frist({Key? key}) : super(key: key);

  @override
  State<frist> createState() => _fristState();
}

class _fristState extends State<frist> {
  List<Image> imglist=[];
  List<Image> splitImage(List<int> input) {
    // convert image to image from image package
    imglib.Image? image = imglib.decodeImage(input);

    int x = 0, y = 0;
    int width = (image!.width / 3).round();
    int height = (image.height / 3).round();

    // split image to parts
    List<imglib.Image> parts = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }
    // convert image from image package to Image Widget to display
    List<Image> output = [];
    for (var img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }
    return output;
  }

  Future<File> getImageFilefromassets(String path) async {
    final byteData = await rootBundle.load('$path');
    var directory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/myfolder";
    Directory d=Directory(directory);
    if(!await d.exists())
      {
        await d.create();
      }
    final file=File('${d.path}/img.jpg');
    await file.writeAsBytes(byteData.buffer.asInt8List(byteData.offsetInBytes,byteData.lengthInBytes));
    return file;
    // /storage/emulated/0/Download
  }

  @override
  void initState() {
    createimage();
  }

  createimage()
  async {
    var status= await Permission.storage.status;
    if(status.isDenied)
    {
      await[Permission.storage].request();
    }
    File f=await getImageFilefromassets('image/lion.jpg');
    List<int> intimglist = await f.readAsBytes();
    imglist=await splitImage(intimglist);
    imglist.shuffle();
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("game")),
      body: Column(
        children: [
          Container(
            height: 350,
            width: double.infinity,
            child: GridView.builder(itemCount: imglist.length,itemBuilder: (context, index) {
              return DragTarget(
                onAccept: (int data) {
                  setState((){
                    Image temp;
                    temp = imglist[data];
                    imglist[data]=imglist[index];
                    imglist[index]=temp;
                    
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Draggable(
                    data:index,
                    feedback:Container(
                      height: 100,
                      width: 100,
                      child: imglist[index],
                    ),
                    child: Container(child: imglist[index],),);
                },);
            },gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 3,crossAxisSpacing: 3)),
          ),
          ElevatedButton(onPressed: () {
            setState((){imglist.shuffle();});
          }, child: Text("refresh"))
        ],
      )
    );
  }
}
