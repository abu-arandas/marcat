import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/config/exports.dart';

class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    // Initialize the state here if needed
    return null;
  }

  UserModel? get user => state;

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<void> login(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await FirebaseFirestore.instance //
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        state = UserModel.fromJson(userDoc);
      } else {
        state = null;
      }
    } on FirebaseException {}
  }

  Future<void> updatePassword({
    required String email,
    required String currentPassword,
    required String password,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;

      await currentUser.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );

      await currentUser.updatePassword(password);
    } on FirebaseException {}
  }

  Future<void> register({
    required String storeId,
    required Roles role,
    required UserModel user,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = //
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(user.name);

      user.id = userCredential.user!.uid;
      user.storeId = storeId;
      user.role = role;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson());

      state = user;
    } on FirebaseException {}
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      state = null;
    } on FirebaseException {}
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
    }
  }

  Future<void> createStore({required StoreModel store}) async {
    try {
      await FirebaseFirestore.instance.collection('stores').add(store.toJson());
    } on FirebaseException {
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());
