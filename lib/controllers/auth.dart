import '/config/exports.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  UserModel? user;

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<void> login(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      user = UserModel.fromJson(userDoc);
      update();
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
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
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  Future<void> register({
    required String storeId,
    required Roles role,
    required UserModel user,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
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

      this.user = user;
      update();
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      user = null;
      update();
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  Future<void> createStore({required StoreModel store}) async {
    try {
      await FirebaseFirestore.instance.collection('stores').add(store.toJson());
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

}
