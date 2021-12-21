import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_widget.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const LoginWidget();
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${snapshot.data.displayName}님 환영합니다.'),
                  TextButton(
                    onPressed: FirebaseAuth.instance.signOut,
                    child: const Text('로그아웃'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      primary: Colors.black,
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
