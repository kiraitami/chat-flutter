import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> data = {};

  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();

    _getUser();

    FirebaseAuth.instance.onAuthStateChanged.listen((user){
      setState(() {
        _currentUser = user;
      });
    });

  }


  Future<FirebaseUser> _getUser() async{
    if(_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      return authResult.user;

    }
    catch (error) {
      print(error);
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Login error. Try again')
          )
      );
      return null;
    }
  }

  void _sendMessage(String text) async {

    data = {
      "uid" : _currentUser.uid,
      "senderName" : _currentUser.displayName,
      "senderPhotoUrl" : _currentUser.photoUrl,
      "time" : Timestamp.now(),
      "body" : text
    };

    Firestore.instance.collection('messages').document().setData(data);
  }

  void _sendImage(File image) async{
    StorageUploadTask task = FirebaseStorage.instance.ref()
        .child('images')
        .child(_currentUser.uid + DateTime.now().millisecondsSinceEpoch.toString()).putFile(image);

    StorageTaskSnapshot taskSnapshot = await task.onComplete;

    String url = await taskSnapshot.ref.getDownloadURL();

    data = {
      'uid' : _currentUser.uid,
      'senderName' : _currentUser.displayName,
      'senderPhotoUrl' : _currentUser.photoUrl,
      'time'  : Timestamp.now(),
      'imgUrl' : url
    };

    Firestore.instance.collection('messages').document().setData(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null ? _currentUser.displayName : 'Chat App'
        ),
        elevation: 1,
        actions: <Widget>[
          _currentUser != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Signed Out')
                  )
              );
            },
          ) : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch (snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center (
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index){
                        return ChatMessage(documents[index].data, documents[index].data['uid'] == _currentUser?.uid);
                      }
                    );
                }
              },
            ),
          ),

          TextComposer(_sendMessage, _sendImage)
        ],
      ),
    );
  }
}
