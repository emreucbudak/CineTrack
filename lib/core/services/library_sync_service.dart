import 'package:flutter/foundation.dart';

class LibrarySyncService extends ChangeNotifier {
  void notifyLibraryChanged() {
    notifyListeners();
  }
}
