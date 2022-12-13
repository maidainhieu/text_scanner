import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? imageFile;

  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Chọn Nguồn Hình Từ"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.purple),)
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        "Thư Viện",
                        style: TextStyle(color: Colors.purple),)
                    ],
                  ),
                )

              ],
            ),
          );
        }
    );
  }

  void _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 1080,
        maxWidth: 1080
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }


  void _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 1080,
        maxWidth: 1080
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    File? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
    );
    if (croppedImage != null){
      setState(() {
        imageFile = croppedImage;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.amber,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("TÁCH CHỮ TỪ HÌNH ẢNH", style: TextStyle(color: Colors.amber),),
            Container(
              height: 30,
              width: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/avatar.png'),),
            )
          ],
        ),
      ),

      body: ListView(
        children: [
          imageFile != null?
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height* 0.6,
                    width: MediaQuery.of(context).size.width* 0.6,
                    child: Image.file(imageFile!)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        color: Colors.green,
                        child: Text(
                          "Thay Đổi Hình",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onPressed: (){
                          _showImageDialog();
                        }),
                    MaterialButton(
                        color: Colors.red,
                        child: Text(
                          "Tách",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onPressed: (){Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GetResult(image: imageFile!)));})
                  ],
                )
              ],
            ),
          ) :
          Container(
            child: GestureDetector(
                onTap: (){
                  _showImageDialog();
                },
                child: Icon(
                  Icons.camera_enhance_rounded,
                  color: Colors.green,
                  size: MediaQuery.of(context).size.width* 0.6,
                )
            ),
          ),
        ],
      ),
    );
  }
}

class GetResult extends StatefulWidget {
  final File image;

  GetResult({required this.image});

  @override
  _GetResultState createState() {
    return _GetResultState();
  }
}

class _GetResultState extends State<GetResult> {
  String api = "https://527a-2001-ee0-4e67-5d30-15f6-f235-4777-2eaa.ap.ngrok.io/upload";
  uploadImage(File file) async {
    String fileName = file.path.split('/').last;
    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    Dio dio = new Dio();
    Response response = await dio.post(api, data: data);
    return (response.data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          toolbarHeight: 110,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          flexibleSpace: ClipPath(
            clipper: AppbarCustomClipper(),
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Colors.green,
                      ]
                  )
              ) ,
              child: Center(
                child: Text(
                  "KẾT QUẢ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: new FutureBuilder<dynamic>(
          future: uploadImage(widget.image),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError)
                  return Container(
                      child: Center(child: Text("Không Thể Kết Nối Tới Máy Chủ", style: TextStyle(fontSize: 20),)));
                //Text(snapshot.data.toString());
                return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(child: InforCard(value: snapshot.data.toString()))
                );
            };
          },
        ),
      ),
    );
  }
}

class AppbarCustomClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();

    path.lineTo(0, height-50);
    path.quadraticBezierTo(width/2, height, width, height-50);
    path.lineTo(width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class InforCard extends StatelessWidget {
  final String? value;
  const InforCard({
    Key? key,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        margin: EdgeInsets.only(bottom: 16),
        width: size.width - 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38.5),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 10),
              blurRadius: 33,
              color: Color(0xFFD3D3D3).withOpacity(.84),
            ),
          ],
        ),
        child: SelectableText(
          "$value",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          toolbarOptions: ToolbarOptions(
            copy: true,
            selectAll: true,
          ),
          scrollPhysics: ClampingScrollPhysics(),
        )
    );
  }
}
