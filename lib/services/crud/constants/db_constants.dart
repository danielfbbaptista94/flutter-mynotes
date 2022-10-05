const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isCompletedColumn = 'is_completed';
const isSyncWithCloundColumn = 'is_synced_with_clound';
const createUsersTable = '''
        	CREATE TABLE IF NOT EXISTS "users" (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE
          )
      ''';
const createNotesTable = '''
        	CREATE TABLE IF NOT EXISTS "notes" (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            "text" TEXT NOT NULL,
            is_completed INTEGER, 
            is_synced_with_clound INTEGER,
            CONSTRAINT notes_FK FOREIGN KEY (user_id) REFERENCES "user"(id)
          )
      ''';
