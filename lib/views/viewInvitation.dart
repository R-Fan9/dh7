import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class InvitationScreen extends StatefulWidget {
  final String email;
  final String uid;
  InvitationScreen(this.email, this.uid);
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  Stream myInvitesSnapshot;

  getAllInvites(){
    DatabaseMethods().getMyInvites(widget.email).then((val){
      setState(() {
        myInvitesSnapshot = val;
      });
    });
  }


  acceptInviteAndJoinChat(String hashTag, String groupId, String username, String admin) async{
    await DatabaseMethods(uid: widget.uid).toggleGroupMembership(groupId, username, hashTag, "acceptInvite");
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ConversationScreen(groupId, hashTag, admin, widget.uid)
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
    return StreamBuilder(
        stream:myInvitesSnapshot,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.docs != null){
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return inviteTile(
                        snapshot.data.docs[index].data()["hashTag"],
                        snapshot.data.docs[index].data()["groupId"],
                        snapshot.data.docs[index].data()["admin"],
                    );
                  });
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }


  @override
  void initState() {
    // TODO: implement initState
    getAllInvites();
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
