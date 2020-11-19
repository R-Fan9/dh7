import 'dart:io';

import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart'as Path;


class SearchScreen extends StatefulWidget {
  final String uid;
  final String tag;
  final File imgFile;
  SearchScreen(this.uid, this.tag, this.imgFile);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  Stream groupChatsSnapshot;

  getAllChats(){
    DatabaseMethods(uid: widget.uid).getAllGroupChats().then((val){
      setState(() {
        groupChatsSnapshot = val;
      });
    });
  }

  searchChats(String searchText){
    DatabaseMethods(uid: widget.uid).searchGroupChats(searchText.toUpperCase()).then((val){
      setState(() {
        groupChatsSnapshot = val;
      });
    });
  }

  joinChat(String hashTag, String groupId, String username, String admin) async{
    await DatabaseMethods(uid: widget.uid).toggleGroupMembership(groupId, username, hashTag, "JOIN_PUB_GROUP_CHAT");
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ConversationScreen(groupId, hashTag, admin, widget.uid)
    ));
  }

  requestJoin(String groupId, String username){
    DatabaseMethods(uid: widget.uid).requestJoinGroup(groupId, username).then((val) {
      setState(() {
        groupChatsSnapshot = val;
      });
    });
  }

  Future sendImgAndJoin(imgUrl, String hashTag, String groupId, String admin) async{
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:a').format(now);

    await DatabaseMethods(uid: widget.uid).addConversationMessages(groupId, '', Constants.myName, formattedDate, now.microsecondsSinceEpoch, imgUrl);
    await DatabaseMethods(uid: widget.uid).toggleGroupMembership(groupId, Constants.myName, hashTag, "JOIN_PUB_GROUP_CHAT");
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ConversationScreen(groupId, hashTag, admin, widget.uid)
    ));
  }


  fileUpload(File imgFile, String hashTag, String groupId, String admin){
    String fileName = Path.basename(imgFile.path);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('chats/${widget.uid}_${Constants.myName}/$fileName');

    ref.putFile(imgFile).then((value){
      value.ref.getDownloadURL().then((val){
        sendImgAndJoin(val, hashTag, groupId, admin);
      });
    });
  }

  Widget searchTile(String hashTag, String groupId, String adminName, String admin, String chatRoomState, List joinRequests){
    bool requested = joinRequests.contains(widget.uid + '_' + Constants.myName);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hashTag, style: simpleTextStyle(),),
                Text("Admin: "+adminName, style: simpleTextStyle(),),
                Text(chatRoomState, style: TextStyle(
                  fontSize: 16,
                  color: chatRoomState == "public" ? Colors.green : Colors.red
                ),)
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                !requested ?
                chatRoomState == "public" ? widget.imgFile == null ? joinChat(hashTag, groupId, Constants.myName, admin) :
                fileUpload(widget.imgFile, hashTag, groupId, admin) :
                requestJoin(groupId, Constants.myName) : null;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: !requested ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(!requested ? chatRoomState == "public" ? "Join" : "Request" : "Requested", style: simpleTextStyle(),),
              ),
            )
          ],
        )
    );
  }

  String _destructureName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  Widget groupChatsList(){
    return StreamBuilder(
      stream:groupChatsSnapshot,
        builder: (context, snapshot){
        if(snapshot.hasData){
          if(snapshot.data.docs != null){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return !snapshot.data.docs[index].data()['members'].contains(widget.uid + '_' + Constants.myName) ? searchTile(
                      snapshot.data.docs[index].data()["hashTag"],
                      snapshot.data.docs[index].data()["groupId"],
                      _destructureName(snapshot.data.docs[index].data()["admin"]),
                      snapshot.data.docs[index].data()["admin"],
                      snapshot.data.docs[index].data()["chatRoomState"],
                      snapshot.data.docs[index].data()["joinRequests"]
                  ): Container();
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
    widget.tag.isEmpty ? getAllChats() : searchChats(widget.tag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
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
                  SizedBox(width: 15,),
                  Expanded(child: widget.tag.isEmpty ? TextField(
                    onChanged: (String val){
                      searchChats(val);
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.white54
                      ),
                      border: InputBorder.none
                    ),
                  ) : Text(widget.tag, style: TextStyle(color: Colors.black))),
                ],
              ),
            ),
            Expanded(child: groupChatsList()),
          ],
        ),
      ),
    );
  }
}



