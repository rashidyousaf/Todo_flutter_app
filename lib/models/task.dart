class Task {
  int? id;
  String title;
  bool isCompleted;

  Task({this.id, required this.title, required this.isCompleted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1 ? true : false,
    );
  }
}
