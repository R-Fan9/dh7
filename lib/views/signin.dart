import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/camera.dart';
import 'package:chat_app/views/pageView.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chatRoomsScreen.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  bool isLoading = false;

  QuerySnapshot snapshotUserInfo;

  signIn() async {
    if(formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      await authMethods.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text)
      .then((result) async {

        if(result != null) {
          QuerySnapshot userInfoSnapshot =
              await databaseMethods.getUserByUserEmail(emailTextEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot.docs[0].data()["name"]
          );
          HelperFunctions.saveUserEmailSharedPreference(
            userInfoSnapshot.docs[0].data()["email"]
          );

          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => PageViewScreen(0)));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appBarMain(context),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 50,
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: Column(children: [
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please provide a valid email";
                        },
                        controller: emailTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("email"),
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (val){
                          return val.length > 6 ? null : "Pleas provide valid password";
                        },
                        controller: passwordTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("password"),
                      ),
                    ],),
                  ),
                  SizedBox(height:8,),
                  Container(
                    alignment: Alignment.centerRight,
                    child:Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Forgot Password", style: simpleTextStyle(),)
                    ),
                  ),
                  SizedBox(height:8,),
                  GestureDetector(
                    onTap: (){
                      signIn();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC)
                          ]
                        ),
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("Sign In", style: simpleTextStyle(),),
                    ),
                  ),
                  SizedBox(height:8,),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text("Sign In with Google", style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16
                    )),
                  ),
                  SizedBox(height:8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account?", style: simpleTextStyle(),),
                      GestureDetector(
                        onTap: (){
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("Register now", style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            decoration: TextDecoration.underline
                          ),),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height:50,),

                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
