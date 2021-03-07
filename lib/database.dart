import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethods{
  final CollectionReference onCallUsersCollection = FirebaseFirestore.instance.collection('onCallUsers');

  getOnCallUsers(){
    return onCallUsersCollection.get();
  }

  addOnCallUser(String name){
    onCallUsersCollection.add({"name":name});
  }

  removeOnCallUser(String uid){
    onCallUsersCollection.doc(uid).delete();
  }



}