import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InviteUserScreen extends StatefulWidget {
  final String groupId;
  final String uid;
  InviteUserScreen(this.groupId, this.uid);
  @override
  _InviteUserScreenState createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  QuerySnapshot userSnapshot;
  String userState;
  bool haveUserSearched = false;
  TextEditingController emailSearchEditingController = new TextEditingController();

  searchUser() async{
    if(emailSearchEditingController.text.isNotEmpty){
      await DatabaseMethods().getUserByUserEmail(emailSearchEditingController.text).then((val) {
        setState(() {
          userSnapshot = val;
          haveUserSearched = true;
        });
      });
      await DatabaseMethods().isInvitedOrJoined(widget.groupId, emailSearchEditingController.text).then((val) {
        setState(() {
          userState = val;
        });
      });
    }
  }

  sendInvite(String email){
    DatabaseMethods().sendInvitation(widget.groupId, email).then((val) {
      setState(() {
        userState = val;
      });
    });
  }

  Widget userTile(String username, String email){

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: simpleTextStyle(),),
                Text(email, style: simpleTextStyle(),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                userState == "notInvited" ? sendInvite(email) : null;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: userState == "alreadyJoined" ? Colors.grey : userState == "Invited" ? Colors.grey : Colors.blue,
                    borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(userState == "alreadyJoined" ? "Joined" : userState == "Invited" ? "Invited" : "Invite", style: simpleTextStyle(),),
              ),
            )
          ],
        )
    );
  }

  Widget userList(){
    return haveUserSearched ? ListView.builder(
      itemCount: userSnapshot.docs.length,
        itemBuilder: (context, index){
        return userTile(
            userSnapshot.docs[index].data()["name"],
            userSnapshot.docs[index].data()["email"]
        );
        }) : Container();

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
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: emailSearchEditingController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "search user by email...",
                        hintStyle: TextStyle(
                            color: Colors.white54
                        ),
                        border: InputBorder.none
                    ),
                  )),
                  SizedBox(width: 15,),
                  GestureDetector(
                    onTap: (){
                      searchUser();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xfffb934d),
                                  const Color(0xfffb934d)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(40)
                        ),
                        padding: EdgeInsets.all(12),
                        child: Image.asset("assets/images/search.png")
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: userList()),
          ],
        ),
      ),
    );
  }
}
