import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


import '../../../../main.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'agent.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE userX(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
        );
      },
      version: 1,
    );
  }
  
  Future<int> insertUser(List<User> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var user in users){
      try {
      result = await db.insert('userX', user.toMap());
      } catch (e) {
        showMyDialog();
        print(e);
      }
    }
    return result;
  }


  Future<List<User>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object>> queryResult = await db.query('userX');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<void> cleanTable() async {
      final Database db = await initializeDB();
      await db.rawQuery('delete from userX ;');       
  } 

   Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'userX',
      where: "idsend = ?",
      whereArgs: [id],
    );
  }



}

