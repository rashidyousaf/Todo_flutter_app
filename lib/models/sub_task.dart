class Subtask {
  int? id;
  int taskId;
  String title;
  bool isCompleted;

  Subtask(
      {this.id,
      required this.taskId,
      required this.title,
      this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1 ? true : false,
    );
  }

  // ... other methods
}
