import 'package:cloud_firestore/cloud_firestore.dart';

class TodoListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 這裡假設每個使用者都有自己的 collection
  CollectionReference<Map<String, dynamic>> getUserTodoRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  Future<void> addTodo(String userId, String title) async {
    await getUserTodoRef(userId).add({
      'title': title,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTodo(String userId, String docId) async {
    await getUserTodoRef(userId).doc(docId).delete();
  }

  Future<void> toggleTodo(String userId, String docId, bool value) async {
    await getUserTodoRef(userId).doc(docId).update({'completed': value});
  }

  Stream<List<Map<String, dynamic>>> watchTodos(String userId) {
    return getUserTodoRef(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'completed': doc['completed'],
        };
      }).toList();
    });
  }
}
