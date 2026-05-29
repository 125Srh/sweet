import 'package:flutter/material.dart';
import '../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isAdmin => _user?.rol == 'admin';
  bool get isClient => _user?.rol == 'cliente';

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
