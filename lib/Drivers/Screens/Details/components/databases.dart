import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../../components/warning_dialog.dart';
import '../../../../main.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    
    return openDatabase(
      join(path, 'agent.db'),
      onCreate: (database, version) async {
        print('aquiiii week');
        print(version);
        await database.execute(
          "CREATE TABLE userX(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
        );
        await database.execute(
            "CREATE TABLE agentInsert(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
          );
          await database.execute(
            "CREATE TABLE agentInsertSolid(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
          );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('aquiiii week2wwe');
        print(oldVersion);
        if (oldVersion == 2) {
          await db.execute(
            "CREATE TABLE agentInsert(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
          );
          await db.execute(
            "CREATE TABLE agentInsertSolid(noempid TEXT PRIMARY KEY, nameuser TEXT NOT NULL,hourout TEXT NOT NULL, direction TEXT NOT NULL, idsend INTEGER NOT NULL)",
          );
        }
      },
      version: 3,
    );
  }

  Future<int> insertUser(List<User> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      try {
        result = await db.insert('userX', user.toMap());
      } catch (e) {
        WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: 'El agente seleccionado ya está agregado al viaje',
          tipo: 2,
          onOkay: () {},
        );
        print(e);
      }
    }
    return result;
  }

  Future<int> insertAgent(List<User> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      try {
        result = await db.insert('agentInsert', user.toMap());
      } catch (e) {
        WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: 'El agente seleccionado ya está agregado al viaje',
          tipo: 2,
          onOkay: () {},
        );
        print(e);
      }
    }
    return result;
  }

  Future<int> insertAgentSolid(List<User> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      try {
        result = await db.insert('agentInsertSolid', user.toMap());
      } catch (e) {
        showMyDialog();
        print(e);
      }
    }
    return result;
  }

  Future<List<User?>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('userX');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<List<User?>> retrieveAgent() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('agentInsert');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<List<User?>> retrieveAgentSolid() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('agentInsertSolid');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }


  Future<void> cleanTable() async {
    final Database db = await initializeDB();
    await db.rawQuery('delete from userX ;');
  }

  Future<void> cleanTableAgent() async {
    final Database db = await initializeDB();
    await db.rawQuery('delete from agentInsert ;');
  }

  Future<void> cleanTableAgentSolid() async {
    final Database db = await initializeDB();
    await db.rawQuery('delete from agentInsertSolid ;');
  }

  Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'userX',
      where: "idsend = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAgent(dynamic id) async {
    final db = await initializeDB();
    await db.delete(
      'agentInsert',
      where: "idsend = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAgentSolid(dynamic id) async {
    final db = await initializeDB();
    await db.delete(
      'agentInsertSolid',
      where: "idsend = ?",
      whereArgs: [id],
    );
  }
}
