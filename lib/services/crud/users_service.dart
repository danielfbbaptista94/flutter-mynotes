import 'dart:async';

import 'package:mynotes/services/crud/constants/db_constants.dart';
import 'package:mynotes/services/crud/entities/user_database.dart';
import 'package:mynotes/services/crud/exceptions/user_exceptions.dart';
import 'package:mynotes/services/database/db_connection.dart';

class UsersService {
  final DatabaseConnection connection = DatabaseConnection();

  static final UsersService _shared = UsersService._sharedInstance();
  UsersService._sharedInstance();

  factory UsersService() => _shared;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoNotExists {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (result.isEmpty) {
      throw UserDoNotExists();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase().trim()},
    );

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}
