import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/groupChatSettings.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';

import 'inviteUser.dart';

class ConversationScreen extends StatefulWidget {
  final String groupChatId;
  final String hashTag;
  final String admin;
  final String uid;
  ConversationScreen(this.groupChatId, this.hashTag, this.admin, this.uid);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();

  Stream chatMessageStream;

  @override
  void initState() {
    DatabaseMethods(uid: widget.uid).getConversationMessages(widget.groupChatId).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });
    super.initState();
  }


  sendMessage(){
    if(messageController.text.isNotEmpty){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm:a').format(now);

      DatabaseMethods(uid: widget.uid).addConversationMessages(widget.groupChatId, messageController.text, Constants.myName, formattedDate, now.microsecondsSinceEpoch);
      messageController.text = "";
    }
  }

  deleteMessage(String messageId){
    DatabaseMethods(uid: widget.uid).deleteConversationMessages(widget.groupChatId, messageId).then((val){
      setState(() {
        chatMessageStream = val;
      });
    });
  }

  Widget messageTile(message, sendBy, dateTime, userId, isSendByMe, messageId, admin){
    return GestureDetector(
      onLongPress: (){
        isSendByMe ? showMenu(
            context: context,
            position: RelativeRect.fromLTRB(0.0, 600.0, 300.0, 0.0),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                value:1,
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      Text("Delete")
                    ],
                  )),
            ]).then((value) {
              if(value == null){
                return;
              }else{
                deleteMessage(messageId);
              }
        }) : null;
      },
      child: Container(
        padding: EdgeInsets.only(left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),

            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSendByMe ? [
                    const Color(0xffff914d),
                    const Color(0xffff914d)
                  ]:
                  [
                    const Color(0xffe5e7e9),
                    const Color(0xffe5e7e9),
                  ],
                ),
                borderRadius: isSendByMe ?
                BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23)
                ):
                BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)
                )

            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !isSendByMe ? Text(userId + "_" + sendBy == admin ? sendBy + " (admin) " : sendBy, style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w300
                )) : SizedBox.shrink(),
                Text(message, style:
                TextStyle(
                    color: isSendByMe ? Colors.white : Colors.black,
                    fontSize: 20
                )
                ),
              ],
            )
        ),
      ),
    );
  }


  Widget chatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          reverse: true,
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
            return messageTile(snapshot.data.docs[index].data()["message"],
            snapshot.data.docs[index].data()["sendBy"],
            snapshot.data.docs[index].data()["formattedDate"],
            snapshot.data.docs[index].data()["userId"],
            snapshot.data.docs[index].data()["sendBy"] == Constants.myName,
            snapshot.data.docs[index].id,
            widget.admin);
            }) : Container();
      },
    );
  }

  _buildMessageComposer(){
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(child: TextField(
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration.collapsed(
              hintText: 'Message',
            ),
          ),),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
                icon: widget.admin == widget.uid + "_" + Constants.myName ? Icon(Icons.add): Icon(Icons.more_horiz),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: (){
                  widget.admin == widget.uid + "_" + Constants.myName ? Navigator.push(context, MaterialPageRoute(
                      builder: (context) => InviteUserScreen(widget.groupChatId, widget.uid)
                  )) : Navigator.push(context, MaterialPageRoute(
                      builder: (context) => GroupChatSettingsScreen(widget.groupChatId, widget.uid, widget.hashTag)));
                },
            )
          ],
          title: Text(widget.hashTag,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54
          ),),

        ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: chatMessageList(),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      )
    );
  }
}




