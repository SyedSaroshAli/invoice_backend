import 'package:get/get.dart';
import '../models/about_model.dart';
import '../services/about_service.dart';

class AboutController extends GetxController {
  var isLoading = true.obs;
  var aboutData = Rxn<AboutModel>();

  final AboutService service = AboutService();

  @override
  void onInit() {
    fetchAboutData();
    super.onInit();
  }

  void fetchAboutData() async {
    isLoading.value = true;

    var data = await service.fetchAbout();

    if (data != null) {
      aboutData.value = data;
    }

    isLoading.value = false;
  }
}