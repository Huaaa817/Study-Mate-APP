import 'package:flutter/foundation.dart';
import 'package:flutter_app/repositories/feed_repo.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _repository;
  final String _userId;

  FeedViewModel(this._repository, this._userId);

  Future<void> addFeedCount() async {
    await _repository.incrementFeedCount(_userId);
  }
}

