import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/log_in_method.dart';
import 'package:flutter_app/models/user.dart' as models;
import 'package:flutter_app/repositories/user_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:image_picker/image_picker.dart'; // 移除 image_picker

class AuthenticationService {
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthenticationService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  /// Returns the user ID.
  Future<String?> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    // 移除 avatarFile，改用可選 avatarUrl
    String? avatarUrl,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      await _postSingUp(
        userId: userId,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        logInMethods: [LogInMethod.emailAndPassword],
      );
      debugPrint('New email account created');

      return userId;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final existingUserDoc = await _userRepository.getUserByEmail(email);
        if (existingUserDoc == null) {
          throw Exception('Email already in use but no user doc found');
        }

        if (existingUserDoc.logInMethods.contains(
          LogInMethod.emailAndPassword,
        )) {
          if (context.mounted) {
            await _promptLogInInstead(context);
          }
          return null;
        } else if (existingUserDoc.logInMethods.contains(LogInMethod.google)) {
          final googleSignIn = GoogleSignIn();
          GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
          if (googleUser == null && context.mounted) {
            bool shouldProceed = await _promptLinkEmailToGoogle(context);
            if (!shouldProceed) {
              return null;
            }
            googleUser = await googleSignIn.signIn();
          }
          if (googleUser == null) return null;

          final googleAuth = await googleUser.authentication;
          final googleCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final user =
              (await _firebaseAuth.signInWithCredential(
                googleCredential,
              )).user!;

          if (user.email == email) {
            final emailCredential = EmailAuthProvider.credential(
              email: email,
              password: password,
            );
            await user.linkWithCredential(emailCredential);
            debugPrint(
              'Email account linked to existing Google account: $email',
            );

            await _postSingUp(
              userId: user.uid,
              email: email,
              name: name,
              avatarUrl: avatarUrl,
              logInMethods: [LogInMethod.google, LogInMethod.emailAndPassword],
            );

            return user.uid;
          } else {
            throw Exception(
              'Email does not match Google account email while linking',
            );
          }
        } else {
          throw Exception('Email already in use but no log in method found');
        }
      } else {
        throw Exception('${e.code}: ${e.message}');
      }
    }
  }

  /// Param `avatarUrl` and `avatarFile` cannot be both `null`.
  Future<void> _postSingUp({
    required String userId,
    required String email,
    required name,
    String? avatarUrl,
    // 移除 avatarFile
    required List<LogInMethod> logInMethods,
  }) async {
    // 不再處理 avatarFile 上傳

    if (avatarUrl == null) {
      // 若沒有提供 avatarUrl，設成預設圖示（或可改成空字串）
      avatarUrl = 'https://via.placeholder.com/150';
    }

    await _userRepository.createOrUpdateUser(
      models.User(
        id: userId,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        logInMethods: logInMethods,
      ),
    );
  }

  // 下面其餘函式不變，因為不涉及 image_picker

  Future<void> _promptLogInInstead(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Email already in use'),
          content: const Text(
            'The email address you provided is already in use. Please log in instead.',
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _promptLinkEmailToGoogle(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Email already in use'),
              content: const Text(
                'The email address you provided is already in use. This may be due to an existing Google account using the same email address. Press Cancel to use another email address, or Proceed to log in with the Google account and link it with your password.',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Proceed'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<String> logIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _postLogIn(userCredential.user!);

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception('${e.code}: ${e.message}');
    }
  }

  Future<void> _postLogIn(User user) async {
    IdTokenResult idTokenResult = await user.getIdTokenResult(true);

    final isModerator = idTokenResult.claims?['isModerator'] ?? false;
    debugPrint('Logged in with state: isModerator=$isModerator');
  }

  Future<String?> logInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final googleEmail = googleUser.email;
      final existingUserDoc = await _userRepository.getUserByEmail(googleEmail);

      if (!context.mounted) return null;

      late User user;
      if (existingUserDoc == null) {
        user =
            (await _firebaseAuth.signInWithCredential(googleCredential)).user!;

        await _postSingUp(
          userId: user.uid,
          email: googleEmail,
          name: googleUser.displayName ?? googleEmail.split('@').first,
          avatarUrl: googleUser.photoUrl ?? 'https://via.placeholder.com/150',
          logInMethods: [LogInMethod.google],
        );
        debugPrint('New Google account created');
      } else {
        if (!existingUserDoc.logInMethods.contains(LogInMethod.google)) {
          final password = await _promptLinkGoogleToEmail(context, googleEmail);
          if (password == null) {
            return null;
          }

          user =
              (await _firebaseAuth.signInWithEmailAndPassword(
                email: googleEmail,
                password: password,
              )).user!;

          await user.linkWithCredential(googleCredential);
          debugPrint(
            'Google account linked to existing email account: $googleEmail',
          );

          await _postSingUp(
            userId: user.uid,
            email: googleEmail,
            name: existingUserDoc.name,
            avatarUrl: existingUserDoc.avatarUrl,
            logInMethods: [LogInMethod.emailAndPassword, LogInMethod.google],
          );
        } else {
          user =
              (await _firebaseAuth.signInWithCredential(
                googleCredential,
              )).user!;
        }
      }

      _postLogIn(user);

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception('${e.code}: ${e.message}');
    }
  }

  Future<String?> _promptLinkGoogleToEmail(
    BuildContext context,
    String email,
  ) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Email already in use'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium!,
                  children: [
                    const TextSpan(
                      text: 'The email address of your Google account:\n\n',
                    ),
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\n\nhas already been used by an email account. To proceed, please log into the email account to link it with this Google account.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  String? checkAndGetLoggedInUserId() {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;

    user.reload();
    return _firebaseAuth.currentUser?.uid;
  }

  //新增的??
  Stream<String?> userIdStream() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }
}
