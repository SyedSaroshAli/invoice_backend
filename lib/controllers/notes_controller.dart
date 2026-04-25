import 'package:get/get.dart';

import '../models/subject_model.dart';
import '../models/notes_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class NotesController extends GetxController {
  var subjects = <SubjectModel>[].obs;
  var notes = <NotesModel>[].obs;

  var selectedSubjectId = RxnInt();
  var isLoadingSubjects = false.obs;
  var isLoadingNotes = false.obs;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  String? classId;

  @override
  void onInit() {
    super.onInit();
    initController();
  }

  // 🔹 INIT
  Future<void> initController() async {
    classId = await _authService.getClassId();

    print("CLASS ID: $classId");

    if (classId != null && classId!.isNotEmpty) {
      await fetchSubjects();
    } else {
      print("❌ Class ID NOT FOUND");
    }
  }

  // 🔹 FETCH SUBJECTS
  Future<void> fetchSubjects() async {
    try {
      isLoadingSubjects(true);

      final response = await _apiService.get(
        "/Subjects/by-class/$classId",
      );

      print("SUBJECT RESPONSE: $response");

      if (response is List) {
        subjects.value =
            response.map((e) => SubjectModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("❌ Error Subjects: $e");
    } finally {
      isLoadingSubjects(false);
    }
  }

  // 🔹 FETCH NOTES
  Future<void> fetchNotes(int subjectId) async {
    try {
      isLoadingNotes(true);

      final response = await _apiService.get(
        "/Notes/By-Class-Subject-Id",
        queryParams: {
          "classId": classId!,
          "subjectId": subjectId.toString(),
        },
      );

      print("NOTES RESPONSE: $response");

      if (response is Map && response.containsKey('notes')) {
        List notesList = response['notes'];

        notes.value =
            notesList.map((e) => NotesModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("❌ Error Notes: $e");
    } finally {
      isLoadingNotes(false);
    }
  }
}