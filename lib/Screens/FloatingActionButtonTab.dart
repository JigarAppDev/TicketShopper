import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticket_stopper/Components/DottedContainer.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Screens/ImagePreviewScreen.dart';
import 'package:ticket_stopper/Screens/TicketInformationScreen.dart';

class FloatingActionButtonTab extends StatefulWidget {
  @override
  _FloatingActionButtonTabState createState() => _FloatingActionButtonTabState();
}

class _FloatingActionButtonTabState extends State<FloatingActionButtonTab> {
  File image;

  @override
  Widget build(BuildContext context) {
    _imgFromCamera() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(image)));
      });
    }

    _imgFromGallery() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(image)));
      });
    }

    void _showPicker(context) {
      showDialog(
        context: context,
        builder: (BuildContext bctx) {
          return AlertDialog(
            title: AppText(text: "From where do you want to take the photo?", fontSize: 14),
            content: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: AppText(text: 'Gallery', fontSize: 16),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: AppText(text: 'Camera', fontSize: 16),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DottedContainer(
            text: 'Ticket Information',
            icon: 'receipt.png',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TicketInformationScreen()));
            },
          ),
        ],
      ),
    );
  }
}
