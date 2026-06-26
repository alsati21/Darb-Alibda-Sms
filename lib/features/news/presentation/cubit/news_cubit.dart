import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/news_repository.dart';
import '../../data/models/teacher_news_item.dart';

abstract class NewsState {
  const NewsState();
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  const NewsLoaded({required this.news, required this.unreadCount});

  final List<TeacherNewsItem> news;
  final int unreadCount;
}

class NewsError extends NewsState {
  const NewsError(this.message);

  final String message;
}

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._repository) : super(const NewsInitial());

  final NewsRepository _repository;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<void> loadNews(String? token) async {
    if (token == null || token.isEmpty) {
      emit(const NewsError('لم يتم العثور على جلسة نشطة'));
      return;
    }

    setToken(token);
    emit(const NewsLoading());

    try {
      final news = await _repository.fetchNews(token);
      final unreadCount = await _repository.fetchUnreadCount(token);
      emit(NewsLoaded(news: news, unreadCount: unreadCount.unreadCount));
    } catch (error) {
      emit(NewsError(_readErrorMessage(error)));
    }
  }

  Future<void> markAsRead(int newsId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _repository.markAsRead(token, newsId);
      if (state is NewsLoaded) {
        final current = state as NewsLoaded;
        final updatedNews = current.news.map((item) {
          if (item.id == newsId) {
            return item.copyWith(isRead: true);
          }
          return item;
        }).toList();

        emit(NewsLoaded(news: updatedNews, unreadCount: _calculateUnread(updatedNews)));
      }
    } catch (error) {
      emit(NewsError(_readErrorMessage(error)));
    }
  }

  Future<void> markAllAsRead() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final result = await _repository.markAllAsRead(token);
      if (state is NewsLoaded) {
        final current = state as NewsLoaded;
        final updatedNews = current.news.map((item) => item.copyWith(isRead: true)).toList();
        emit(NewsLoaded(news: updatedNews, unreadCount: result.unreadCount));
      }
    } catch (error) {
      emit(NewsError(_readErrorMessage(error)));
    }
  }

  int _calculateUnread(List<TeacherNewsItem> news) {
    return news.where((item) => !item.isRead).length;
  }

  String _readErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
