import 'package:get/get.dart';

class HomeController extends GetxController {
  List<RxBool> isTappedList = [];

  void enableIsArmed(int index) {
    isTappedList[index].value = !isTappedList[index].value;
  }
}
