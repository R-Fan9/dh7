import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRoomsScreen.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InvitationScreen extends StatefulWidget {
  final String email;
  final String uid;
  final QuerySnapshot myInvitesSnapshot;
  InvitationScreen(this.email, this.uid, this.myInvitesSnapshot);
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {

  acceptInviteAndJoinChat(String hashTag, String groupId, String username, String admin) async{
    await DatabaseMethods(uid: widget.uid).toggleGroupMembership(groupId, username, hashTag, "acceptInvite");
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatRoom()
    ));
  }


  Widget inviteTile(String hashTag, String groupId, String admin){
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hashTag, style: simpleTextStyle(),),
                Text("Admin: " + admin.substring(admin.indexOf('_') + 1), style: simpleTextStyle(),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                acceptInviteAndJoinChat(hashTag, groupId, Constants.myName, admin);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text("Join", style: simpleTextStyle(),),
              ),
            )
          ],
        )
    );
  }


  Widget myInvitesList(){
    return ListView.builder(
      itemCount: widget.myInvitesSnapshot.docs.length,
        itemBuilder: (context, index){
        return inviteTile(
            widget.myInvitesSnapshot.docs[index].data()['hashTag'],
            widget.myInvitesSnapshot.docs[index].data()['groupId'],
            widget.myInvitesSnapshot.docs[index].data()['admin']);
        });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Expanded(child: myInvitesList()),
          ],
        ),
      ),
    );
  }
}
