import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final Map <String, dynamic> data;
  final bool mine;


  Widget profileAvatar(){
    return
    Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: CircleAvatar(
          backgroundImage: NetworkImage(data['senderPhotoUrl'])
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !mine ? profileAvatar() : Container(),

          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                data['imgUrl'] != null ?
                Image.network(data['imgUrl'], width: 250, height: 300)
                    :
                Text(data['body'], textAlign: mine ? TextAlign.end : TextAlign.start, style: TextStyle(fontSize: 16)),

                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                      data['senderName'],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)
                  )
                )
              ],
            ),
          ),

          mine ? profileAvatar() : Container(),

        ],
      ),
    );
  }
}
