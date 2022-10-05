import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/constants/db_constants.dart';

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isCompleted;
  final bool isSyncWithClound;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isCompleted,
    required this.isSyncWithClound,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isCompleted = (map[isCompletedColumn] as int) == 1 ? true : false,
        isSyncWithClound =
            (map[isSyncWithCloundColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Person, ID = $id, User = $userId, Text = $text, Completed = $isCompleted, isSyncWithClound = $isSyncWithClound';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
