import 'dart:async';
import 'package:common_plugin/common_plugin.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库管理
class Sql {
  static Database? database;
  static List<String> _createData = [];
  static List<String> _indexData = [];
  static QueueTask queueTask = QueueTask(defaultTaskTimeout: 10); // 数据库请求调度，以避免瞬间高并发调用导致一切判断失效造成IO混乱。

  /// 初始化
  static Future<Database> init({
    ///切换数据库
    bool changeData = false,

    ///要切换的数据库后缀id,为空使用默认数据库
    String? userId,

    ///初始化创建数据库，只有创建数据库时才执行
    List<String>? createData,

    ///创建数据库时建立索引
    List<String>? indexData,

    ///数据库版本
    int version = 1,
    Function(int version)? onCreate,

    ///数据库升级事件，新版本版本大于旧版本时执行
    Function(int oldVersion, int newVersion)? onUpgrade,

    ///数据库降级事件
    Function(int oldVersion, int newVersion)? onDowngrade,

    ///数据库配置事件，最先执行
    Function()? onConfigure,

    ///数据库每次打开事件
    Function()? onOpen,
  }) async {
    return await queueTask.add(() async {
      try {
        String dataName = '';
        if (changeData) {
          if (database != null) {
            await close();
          }
          if (userId != null) {
            dataName = userId;
          }
        }
        var path = await getDatabasesPath();
        if (database == null) {
          _createData = createData ?? [];
          _indexData = indexData ?? [];
          database = await openDatabase(
            '$path/data$dataName.db',
            version: version,
            singleInstance: true, // 默认true，如果为false，则多个实例可以同时打开数据库
            onCreate: _onCreate,
            onUpgrade: (db, oldVersion, newVersion) {
              onUpgrade?.call(oldVersion, newVersion);
            },
            onDowngrade: (db, oldVersion, newVersion) {
              onDowngrade?.call(oldVersion, newVersion);
            },
            onConfigure: (db) {
              onConfigure?.call();
            },
            onOpen: (db) async {
              onOpen?.call();
            },
          );
          return database!;
        }
      } catch (e) {
        await close();
        Logger.error("数据库初始化失败: $e", mark: "Sql-init");
      }
      return database!;
    },isAddToFirst: true);
  }

  /// 数据库创建事件
  static FutureOr<void> _onCreate(Database db, int version) async {
    //消息列表
    // await db.execute('CREATE TABLE message (id INTEGER PRIMARY KEY AUTOINCREMENT,type INTEGER NOT NULL,msgID TEXT NOT NULL,uid TEXT NOT NULL, name TEXT NOT NULL, avatar TEXT NOT NULL, content TEXT NOT NULL, unread INTEGER NOT NULL, msgnum INTEGER NOT NULL, last_time INTEGER NOT NULL)');

    await db.transaction((txn) async {
      for (var element in _createData) {
        await txn.execute(element);
      }
    });
    if (_indexData.isNotEmpty) {
      await db.transaction((txn) async {
        for (var element in _indexData) {
          await txn.execute(element);
        }
      });
    }
  }

  //查询数据库版本
  static Future<int> getVersion() async {
    database = await init();
    return database!.getVersion();
  }

  //设置数据库版本
  static Future<void> setVersion(int version) async {
    database = await init();
    await database?.setVersion(version);
  }

  //提交Sql命令
  static Future<void> execute(String sql) async {
    database = await init();
    await database?.execute(sql);
  }

  //批量提交Sql命令
  static Future<void> batch(List<String> sqls) async {
    database = await init();
    await database?.transaction((txn) async {
      for (var element in sqls) {
        await txn.execute(element);
      }
    });
  }

  /// 删除数据库文件
  static Future deleteData(dynamic userId) async {
    var path = await getDatabasesPath();
    return await deleteDatabase('$path/data${userId ?? ''}.db');
  }

  /// 判断数据库表是否存在
  static Future<bool> isTableExists(String table) async {
    database = await init();
    String sql =
        "select * from Sqlite_master where type='table' and name= '$table'";
    var result = await database?.rawQuery(sql);
    return result != null && result.isNotEmpty;
  }

  /// 关闭数据库
  static Future<void> close() async {
     await queueTask.add(() async {
      await database?.close();
      database = null;
    });
  }

  /// 自动根据搜索条件查找指定表，如果存在则更新，不存在则插入,
  /// where: "userID = '$userID'"
  static Future<bool> saveDataAuto(
      {required String table,
      required Map<String, Object?> value,
      required String where}) async {
    database = await init();
    if (await isTableExists(table)) {
      var value0 = await query(table, where: where);

      if (value0 == null) {
        await database?.insert(table, value);
      } else {
        await database?.update(table, value, where: where);
      }
      return true;
    } else {
      return false;
    }
  }

  /// 自动键值对保存数据
  static Future saveKeyData(String key, String value) async {
    database = await init();
    var value0 = await query('keydata', where: 'name = "$key"');
    var list = {
      'name': key,
      'value': value,
      'addTime': DateTime.now().millisecondsSinceEpoch,
    };
    if (value0 == null) {
      return await database?.insert("keydata", list);
    } else {
      return await database?.update("keydata", list, where: 'name = "$key"');
    }
  }

  /// 获取键值对数据
  static Future getKeyData(String key) async {
    var value = await query('keydata', where: 'name = "$key"');
    if (value != null) {
      return value['value'];
    } else {
      return null;
    }
  }

  /// 插入单条数据
  static Future<int> insert(String table, Map<String, Object?> value) async {
    database = await init();
    return await database!.insert(table, value);
  }

  /// 插入多条数据
  static Future<List<dynamic>> insertList(
      String table, List<Map<String, Object?>> value) async {
    database = await init();
    var batch = database?.batch();
    for (var element in value) {
      batch?.insert(table, element);
    }

    return await batch!.commit();
  }

  /// 更新单条数据,
  /// where: "userID = '${widget.userID}'"
  static Future<int> update(
      {required String table,
      required Map<String, Object?> value,
      required String where}) async {
    database = await init();
    if (where.contains('"')) {
      //将双引号替换为单引号
      where = where.replaceAll('"', "'");
    } else if (!where.contains("'")) {
      //不含单引号则添加
      if (where != '1=1') {
        final parts = where.split('=');
        final variableName = parts.last.trim();
        where = '${parts.first} = \'$variableName\'';
      }
    }
    return await database!.update(table, value, where: where);
  }

  /// 查询数据条数
  static Future<int> count(String table) async {
    database = await init();
    var rowCount = Sqflite.firstIntValue(
        await database!.rawQuery('SELECT COUNT(*) FROM $table'));
    return rowCount ?? 0;
  }

  /// 统计字段累计数
  static Future<int> allCount(String table, String field,
      {String where = ''}) async {
    database = await init();
    if (where.isNotEmpty) {
      where = ' WHERE $where';
    }
    final result = Sqflite.firstIntValue(
        await database!.rawQuery('SELECT SUM($field) FROM $table $where'));
    return result ?? 0;
  }

  /// 检索单条数据
  /// where: "userID = '${widget.userID}'"，参数部分必须包含单引号，不能双引号
  /// field,不为空就直接返回该字段数据
  static Future query(
    String table, {
    String? where,
    String? field,
    int limit = 1,
    bool? distinct,
    List<String>? columns,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? offset,
  }) async {
    database = await init();
    if (where != null) {
      if (where.contains('"')) {
        //将双引号替换为单引号
        where = where.replaceAll('"', "'");
      } else if (!where.contains("'")) {
        //不含单引号则添加
        final parts = where.split('=');
        final variableName = parts.last.trim();
        where = '${parts.first} = \'$variableName\'';
      }
    }
    var maps = await database!.query(table,
        where: where,
        limit: limit,
        columns: columns,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        offset: offset,
        distinct: distinct);
    if (maps.length == 1) {
      var json = maps.first;
      return field != null ? json[field] : json;
    }
    return null;
  }

  /// 检索所有数据
  static Future queryAll(
    String table, {
    String? orderBy,
    int? limit,
    int page = 1,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
  }) async {
    database = await init();
    var maps = await database!.query(
      table,
      orderBy: orderBy,
      limit: limit,
      offset: (page - 1) * (limit ?? 20),
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
    ); //orderBy:'lastTime desc'
    return maps;
  }

  /// 删除单条数据
  static Future<int> delete(String table, {List? ids, String? where}) async {
    database = await init();
    return await database!
        .delete(table, where: where ?? 'id = ?', whereArgs: ids);
  }

  /// 删除所有数据
  static Future<int> clear(String table) async {
    database = await init();
    return await database!.delete(table);
  }
}
