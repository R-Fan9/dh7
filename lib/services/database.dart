import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseMethods{

  final String uid;
  DatabaseMethods({
    this.uid
  });

  final CollectionReference groupChatCollection = FirebaseFirestore.instance.collection('groupChats');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  getUserByUsername(String username) async{
    return await userCollection
        .where("name", isEqualTo: username )
        .get();
  }

  getUserByUserEmail(String userEmail) async{
    return await userCollection
        .where("email", isEqualTo: userEmail )
        .get();
  }

  uploadUserInfo(userMap) async{
    return await userCollection
    .doc(uid)
    .set(userMap);
  }

  Future<String> createChatRoom(String hashTag, String username, String chatRoomState, int time, List searchKeys) async{

    DocumentReference groupChatDocRef = await groupChatCollection.add({
      'hashTag': hashTag,
      'admin': uid + '_' + username,
      'members':[],
      'groupId': '',
      'chatRoomState': chatRoomState,
      'createdAt':time,
      'searchKeys':searchKeys,
      'joinRequests':[],
      'invites':[]
    });

    await groupChatDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + username]),
      'groupId': groupChatDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    await userDocRef.update({
      'myChats': FieldValue.arrayUnion([{'groupId':groupChatDocRef.id, 'hashTag': hashTag}])
    });

    return groupChatDocRef.id;

  }

  deleteConversationMessages(String groupChatId, String messageId){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .doc(messageId)
        .delete();
    
    return getConversationMessages(groupChatId);
  }

  addConversationMessages(String groupChatId, String message, String username, String dateTime, int time){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .add({
      'message': message,
      'sendBy': username,
      'userId': uid,
      'dateTime': dateTime,
      'time':time
    }).catchError((e) {print(e.toString());});
  }

  getConversationMessages(String groupChatId) async {
    return await groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getMyChats(String username) async{
    return await groupChatCollection
        .where('members', arrayContains: uid + "_" + username).snapshots();
  }

  getMyInvites(String email) async{
    return await groupChatCollection
        .where('invites', arrayContains: email).snapshots();
  }

  getGroupChatById(String groupId) async{
    return await groupChatCollection
        .doc(groupId).get();
  }

  getAllGroupChats() async{
    return await groupChatCollection.orderBy('createdAt', descending: true)
        .snapshots();
  }

  getAllUsers() async{
    return await userCollection.snapshots();
  }

  searchGroupChats(String searchText) async{
    return await groupChatCollection.where('searchKeys', arrayContains: searchText )
        .snapshots();
  }

  getJoinRequests(String groupId) async {
    DocumentReference newGroupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot newGroupDocSnapshot = await newGroupDocRef.get();

    return newGroupDocSnapshot.data()['joinRequests'];
  }

  Future<String> isInvitedOrJoined(String groupId, String email) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    QuerySnapshot userSnapshot = await userCollection.where('email', isEqualTo: email).get();

    List<dynamic> invites = await groupDocSnapshot.data()['invites'];
    List<dynamic> members = await groupDocSnapshot.data()['members'];
    if(userSnapshot.docs.isNotEmpty){
      if(!members.contains(userSnapshot.docs[0].id + '_' + userSnapshot.docs[0].data()['name'])){
        if(!invites.contains(email)){
          return "notInvited";
        }else {
          return "Invited";
        }
      }else{
        return "alreadyJoined";
      }
    }
    return "userDoesNotExist";

  }

  Future sendInvitation(String groupId, String email) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> invites = await groupDocSnapshot.data()['invites'];
    if(!invites.contains(email)){
      await groupDocRef.update({
        'invites': FieldValue.arrayUnion([email])
      });
    }

    return isInvitedOrJoined(groupId, email);
  }

  Future requestJoinGroup(String groupId, String username) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(!joinRequests.contains(uid + '_' + username)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayUnion([uid + '_' + username])
      });
    }

    return getAllGroupChats();
  }

  Future declineJoinRequest(String groupId, String username) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(joinRequests.contains(uid + '_' + username)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayRemove([uid + '_' + username])
      });
    }

    return getJoinRequests(groupId);

  }


  Future toggleGroupMembership(String groupId, String username, String hashTag, String actionType) async{
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinedGroups = await userDocSnapshot.data()['joinedChats'];

    if(actionType != "LeaveGroup"){
      if(actionType == "acceptRequest"){
        List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
        if (joinRequests.contains(uid + '_' + username)){
          await groupDocRef.update({
            'joinRequests': FieldValue.arrayRemove([uid + '_' + username])
          });
        }
      }
      if(actionType == "acceptInvite"){
        List<dynamic> invites = await groupDocSnapshot.data()['invites'];
        if(invites.contains(userDocSnapshot.data()['email'])){
          await groupDocRef.update({
            'invites': FieldValue.arrayRemove([userDocSnapshot.data()['email']])
          });
        }
      }
    }

    if(joinedGroups.contains(groupId + '_' + hashTag)){
      await userDocRef.update({
        'joinedChats': FieldValue.arrayRemove([groupId + '_' + hashTag])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid + '_' + username])
      });
    }else{
      await userDocRef.update({
        'joinedChats': FieldValue.arrayUnion([groupId + '_' + hashTag])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid + '_' + username])
      });
    }

    return getJoinRequests(groupId);

  }







}