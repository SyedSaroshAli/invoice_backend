class NotesModel {
  final int id;
  final String description;
  final String path;

  NotesModel({
    required this.id,
    required this.description,
    required this.path,
  });

  factory NotesModel.fromJson(Map<String, dynamic> json) {
    return NotesModel(
      id: json['id'],
      description: json['description'],
      path: json['path'],
    );
  }
}