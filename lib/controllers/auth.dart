import 'package:get/get.dart';

import '../models/user.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

/*
CollectionReference<Map<String, dynamic>> usersCollection =
    FirebaseFirestore.instance.collection('users');

Stream<List<UserModel>> users() => usersCollection.snapshots().map(
    (query) => query.docs.map((item) => UserModel.fromJson(item)).toList());
Stream<List<UserModel>> drivers() =>
    usersCollection.snapshots().map((query) => query.docs
        .map((item) => UserModel.fromJson(item))
        .where((element) => element.role == UserRole.driver)
        .toList());
Stream<UserModel> singleUser(id) => usersCollection
    .doc(id)
    .snapshots()
    .map((query) => UserModel.fromJson(query));
*/

  User? user;

  void login(String email, String password) {
    /*try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => page(context: context, page: const Main()));
    } on FirebaseException catch (error) {
      errorSnackBar(context, error.message.toString());
    }*/
  }

  void updatePassword({required String password}) {
    /*try {
      FirebaseAuth.instance.currentUser!
          .updatePassword(password)
          .then((value) => page(context: context, page: const Main()));
    } on FirebaseException catch (error) {
      errorSnackBar(context, error.message.toString());
    }*/
  }

  void register(User user) {}

  void signOut() {
    /*try {
      FirebaseAuth.instance.signOut();

      page(context: context, page: const Main());
    } on FirebaseException catch (error) {
      errorSnackBar(context, error.message.toString());
    }*/
  }
}
