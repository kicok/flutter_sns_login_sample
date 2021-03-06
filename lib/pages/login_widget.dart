import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

//https://firebase.flutter.dev/docs/auth/social 에서 코드 복사해옴
class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithKakao() async {
    final clientState = const Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': '98d9f710fd3b6aba07b3fe2135aa2edd',
      'response_mode': 'form_post',
      'redirect_uri':
          'https://periodic-hushed-beet.glitch.me/callbacks/kakao/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: 'webauthcallback');
    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': '98d9f710fd3b6aba07b3fe2135aa2edd',
      'redirect_uri':
          'https://periodic-hushed-beet.glitch.me/callbacks/kakao/sign_in',
      'code': body['code'],
    });

    var response = await http.post(tokenUrl);
    Map<String, dynamic> accessTokenResult = jsonDecode(response.body);
    print(accessTokenResult['access_token']);
    var responseCustomToken = await http.post(
        Uri.parse(
            'https://periodic-hushed-beet.glitch.me/callbacks/kakao/token'),
        body: {'accessToken': accessTokenResult['access_token']});

    return await FirebaseAuth.instance
        .signInWithCustomToken(responseCustomToken.body);
  }

  Future<UserCredential> signInWithNaver() async {
    final clientState = const Uuid().v4();
    final url = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
      'response_type': 'code',
      'client_id': 'dxZulrlRpG5MUlUF8KqL',
      'response_mode': 'form_post',
      'redirect_uri':
          'https://periodic-hushed-beet.glitch.me/callbacks/naver/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: 'webauthcallback');
    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('nid.naver.com', '/oauth2.0/token', {
      'grant_type': 'authorization_code',
      'client_id': 'dxZulrlRpG5MUlUF8KqL',
      'client_secret': 'p5yzBmNz2V',
      'state': clientState,
      'code': body['code'],
    });

    var response = await http.post(tokenUrl);
    Map<String, dynamic> accessTokenResult = jsonDecode(response.body);
    print(accessTokenResult['access_token']);
    var responseCustomToken = await http.post(
        Uri.parse(
            'https://periodic-hushed-beet.glitch.me/callbacks/naver/token'),
        body: {'accessToken': accessTokenResult['access_token']});

    return await FirebaseAuth.instance
        .signInWithCustomToken(responseCustomToken.body);
  }

  /////////////// Email & Password SingUp, SingIn ///////////////////////
  // 반드시 firebase 의 Authentication 에서 [Sign-in method]에서 [새 제공업체 추가]를 눌러 이메일/비밀번호 의 사용설정을 해야 사용할수 있음

  void _signUp() async {
    print('signUp');
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "barry.allen@example.com", password: "SuperSecretPassword!");
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException");

      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print("catch");
    }
  }

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "barry.allen@example.com", password: "SuperSecretPassword!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
  ///////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "~~~~~~~ Social 로그인 ~~~~~~~~~",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  TextButton(
                    onPressed: signInWithGoogle,
                    child: const Text('Google login'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      primary: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: signInWithFacebook,
                    child: const Text('Facebook login'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      primary: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: signInWithKakao,
                    child: const Text('Kakao login'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      primary: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: signInWithNaver,
                    child: const Text('Naver login'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      primary: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Column(
              children: [
                const Divider(
                  thickness: 10,
                ),
                const Text(
                  "기타 개별 Email/password 회원가입 및 로그인",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(onPressed: _signUp, child: const Text("회원가입")),
                ElevatedButton(onPressed: _signIn, child: const Text("로그인")),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
