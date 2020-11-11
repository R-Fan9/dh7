import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRoomsScreen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupChatSettingsScreen extends StatefulWidget {
  final String groupId;
  final String uid;
  final String hashTag;
  GroupChatSettingsScreen(this.groupId, this.uid, this.hashTag);
  @override
  _GroupChatSettingsScreenState createState() => _GroupChatSettingsScreenState();
}

class _GroupChatSettingsScreenState extends State<GroupChatSettingsScreen> {

  leaveGroupChat(){
    DatabaseMethods(uid: widget.uid).toggleGroupMembership(widget.groupId, Constants.myName, widget.hashTag, "LeaveGroup");
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatRoom()
    ));
  }

  Widget leaveGroupButton(){
    return GestureDetector(
        onTap: (){
          leaveGroupChat();
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Text("LEAVE " + widget.hashTag, style: TextStyle(
                color: Colors.red,
                fontSize: 20
              ),),

            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            leaveGroupButton()
          ],
        ),
      ),
    );
  }
}
