import 'package:cloud_firestore/cloud_firestore.dart';

class TodoListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> getUserTodoRef(String userId) {
    return _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('todo-items');
  }

  Future<void> addTodo({
    required String userId,
    required String title,
    DateTime? dueDate,
  }) async {
    await getUserTodoRef(userId).add({
      'details': title,
      'isDone': false,
      'createdDate': DateTime.now(),
      'category': 'General',
      'name': 'TODO',
      'userId': userId,
      if (dueDate != null) 'dueDate': dueDate,
    });
  }

  Future<void> deleteTodo(String userId, String docId) async {
    await getUserTodoRef(userId).doc(docId).delete();
  }

  Future<void> toggleTodo(String userId, String docId, bool value) async {
    await getUserTodoRef(userId).doc(docId).update({'isDone': value});
  }

  Future<void> updateTodo({
    required String userId,
    required String docId,
    required String newTitle,
    DateTime? newDueDate,
  }) async {
    final Map<String, dynamic> updates = {'details': newTitle};

    if (newDueDate != null) {
      updates['dueDate'] = Timestamp.fromDate(newDueDate);
    }

    await getUserTodoRef(userId).doc(docId).update(updates);
  }

  Stream<List<Map<String, dynamic>>> watchTodos(String userId) {
    return getUserTodoRef(
      userId,
    ).orderBy('createdDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['details'],
          'completed': doc['isDone'],
          'dueDate': doc['dueDate'],
        };
      }).toList();
    });
  }
}
