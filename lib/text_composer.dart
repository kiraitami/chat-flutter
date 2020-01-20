import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage, this.sendImage);

  Function(String text) sendMessage;
  Function(File image) sendImage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _resetField(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
              if (imageFile == null) return;
              widget.sendImage(imageFile);
            },
          ),

          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: 'Type a message'),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },

              onSubmitted: (text){
                widget.sendMessage(text);
                _resetField();
              },
            ),
          ),

          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing ? () {
              widget.sendMessage(_controller.text);
              _resetField();
            } : null,
          )
        ],
      ),
    );
  }
}
