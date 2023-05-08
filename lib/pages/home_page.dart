import 'dart:developer';

import 'package:chatme/helper/helper_funtion.dart';
import 'package:chatme/pages/auth/Login_page.dart';
import 'package:chatme/pages/profile_page.dart';
import 'package:chatme/pages/search_page.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String userName = '';
  String email = '';
  String uuid = '';
  Stream? groups;
  bool _fetchinggroup = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    _fetchinggroup = true;
    await HelperFunction.getUserEmailFromSF().then((value) {
      email = value!;
    });
    await HelperFunction.getUserNameFromSF().then((value) {
      userName = value!;
    });
    uuid = FirebaseAuth.instance.currentUser!.uid;

    // /// Getting the snapshot in our stream
    // await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
    //     .getUserGroups()
    //     .then((snapshot) {
    //   groups = snapshot();
    // });
    _fetchinggroup = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreenReplace(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
        elevation: 2,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Groups',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.group,
                size: 30,
              ),
              title: const Text(
                'Groups',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                  context,
                  Profilepage(
                    userName: userName,
                    email: email,
                  ),
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.account_box,
                size: 30,
              ),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content:
                            const Text('Are you sure your want to logout?'),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _authService.signOutUser();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const Loginpage()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          )
                        ],
                      );
                    });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.exit_to_app,
                size: 30,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            )
          ],
        ),
      ),
      body: _fetchinggroup
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log(FirebaseAuth.instance.currentUser!.uid);
          popUpDialog(context);
        },
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {}

  groupList() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection("users").doc(uuid).snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        /// make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return const Text('Helloooo');
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle,
            color: Colors.grey[700],
            size: 75,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'You have not joined any group , tap on the add icon to create a group or also search from top search button',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


