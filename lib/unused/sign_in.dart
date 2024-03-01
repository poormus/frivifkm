/* 
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/loading.dart';
import 'package:flutter/material.dart';

import '../shared/constants.dart';

class SignIn extends StatefulWidget {
  late final Function toggleView;

  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool _obscureText = true;
  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final AuthService _auth = AuthService();

  String email = "";
  String password = "";
  String error = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future signIn() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _auth
          .signInWithEmailAndPassword(email, password)
          .then((onSuccess) {
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading=false;
          error = err.toString();
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height-56;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Sign in'),
        elevation: 0.0,
        backgroundColor: Colors.black12,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                widget.toggleView();
              },
              icon: Icon(Icons.person),
              label: Text('register'))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/log_in.jpg'), fit: BoxFit.cover)),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        hintText: 'email', icon: Icon(Icons.mail)),
                    validator: (val) =>
                        val!.isEmpty ? 'enter a valid e-mail' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        hintText: 'password', icon: Icon(Icons.lock)),
                    validator: (val) =>
                        val!.length < 6 ? 'password must be longer than 6' : null,
                    obscureText: _obscureText,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  TextButton(
                      onPressed: _togglePassword,
                      child: new Text(_obscureText ? "Show" : "Hide")),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    color: Colors.blue[400],
                    onPressed: signIn,
                    child: Text(
                      'sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Container(child: isLoading ? CircularProgressIndicator() : null)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */