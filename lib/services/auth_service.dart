import '/config/exports.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .get();

      return UserModel.fromJson(userDoc);
    } on FirebaseException {
      return null;
    }
  }

  Future<UserModel?> register(UserModel user, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: user.email, password: password);

      user.id = result.user!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());

      return user;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseException {}
  }

  Future<void> updatePassword({
    required String email,
    required String currentPassword,
    required String password,
  }) async {
    try {
      final currentUser = _auth.currentUser!;

      await currentUser.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );

      await currentUser.updatePassword(password);
    } on FirebaseException {}
  }

  Future<void> createStore({required StoreModel store}) async {
    try {
      await FirebaseFirestore.instance.collection('stores').add(store.toJson());
    } on FirebaseException {}
  }
}
