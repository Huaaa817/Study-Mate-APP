import 'package:flutter/material.dart';
import '/repositories/todo_list_repo.dart';

class TodoListViewModel extends ChangeNotifier {
  final TodoListRepository _repository;
  final String _userId;

  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> get todos => _todos;

  TodoListViewModel(this._repository, this._userId) {
    _repository.watchTodos(_userId).listen((data) {
      _todos = data;
      notifyListeners();
    });
  }

  Future<void> addTodo(String title, {DateTime? dueDate}) async {
    await _repository.addTodo(userId: _userId, title: title, dueDate: dueDate);
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteTodo(_userId, id);
  }

  Future<void> toggleTodo(String id, bool value) async {
    await _repository.toggleTodo(_userId, id, value);
  }

  Future<void> updateTodo(
    String id,
    String newTitle,
    DateTime? newDueDate,
  ) async {
    await _repository.updateTodo(
      userId: _userId,
      docId: id,
      newTitle: newTitle,
      newDueDate: newDueDate,
    );
  }
}
