import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/viewInvitation.dart';
import 'package:chat_app/views/viewJoinRequests.dart';
import 'package:chat_app/views/createChatRoom.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();

  User _user;
  Stream myChatsStream;
  QuerySnapshot myInvitesSnapshot;

  Widget myGroupChatList(){
    return StreamBuilder(
      stream: myChatsStream,
        builder: (context, snapshot){
        if(snapshot.hasData){
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
              return myChatTile(snapshot.data.docs[index].data()["hashTag"],
                  snapshot.data.docs[index].data()["groupId"],
                  snapshot.data.docs[index].data()["admin"],
                  snapshot.data.docs[index].data()['joinRequests']);
              });
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }



  Widget myChatTile(String hashTag, String groupId, String admin, List<dynamic> joinRequestsList){
    int numOfRequests = joinRequestsList.length;
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(groupId, hashTag, admin, _user.uid)));
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Text("${hashTag.substring(1,2).toUpperCase()}"),
            ),
            SizedBox(width: 8,),
            Text(hashTag, style: simpleTextStyle(),),
            SizedBox(width: 8,),
            admin == _user.uid + '_' + Constants.myName ? Container(
              width: 10,
              height: 10,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor
              ),
            ) : SizedBox.shrink(),
            Spacer(),
            numOfRequests > 0 ? admin == _user.uid + '_' + Constants.myName ? GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => JoinRequestsScreen(joinRequestsList, groupId, hashTag)
                ));
              },
              child: Container(
                  decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text("$numOfRequests Join Request", style: simpleTextStyle(),)
              ),
            ) : SizedBox.shrink() : SizedBox.shrink()
          ],
        ),
      )
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    getUseInfo();
    super.initState();
  }

  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("You've not joined any group"),
          ],
        )
    );
  }

  getUseInfo() async {
    _user = await FirebaseAuth.instance.currentUser;
    Constants.myName = await HelperFunctions.getUserNameInSharedPreference();
    DatabaseMethods(uid: _user.uid).getMyChats(Constants.myName)
        .then((val) {
      setState(() {
        myChatsStream = val;
      });
    });
    DatabaseMethods().checkMyInvites(_user.email).then((val){
      setState(() {
        myInvitesSnapshot = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/spidr_logo.jpg", height: 50,),
        actions: [
          GestureDetector(
            onTap: (){
              authMethods.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => Authenticate()
              ));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app),
            ),
          )
        ]
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: myGroupChatList()),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          myInvitesSnapshot != null ? myInvitesSnapshot.docs.isNotEmpty ? FloatingActionButton(
            heroTag: "sgi",
            child: Icon(Icons.group_add),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => InvitationScreen(_user.email, _user.uid, myInvitesSnapshot)
              ));
            },
          ) : SizedBox.shrink() : SizedBox.shrink(),
          SizedBox(height: 10,),
          FloatingActionButton(
            heroTag: "cgc",
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CreateChatRoom(_user.uid)
              ));
            },
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            heroTag: "ssn",
            child: Icon(Icons.search),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SearchScreen(_user.uid)
              ));
            },
          ),
        ],
      ),
    );
  }
}





