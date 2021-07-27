import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qrreaderapp/src/models/scan_model.dart';
export 'package:qrreaderapp/src/models/scan_model.dart'; // para exportar la libreria a donde se usa esta clase

class DBProvider{

  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {

    if(_database != null) return _database;

    _database = await initDB();
    return _database;
    
  }

  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'ScansDB.db');

    return openDatabase(
      path,
      version: 1,
      onOpen: (db){},
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Scans ('
          'id INTEGER PRIMARY KEY,'
          'tipo TEXT,'
          'valor TEXT'
         ')'
        );
      }
    );
  }

  //CREAR - resgistros
  nuevoScanRow(ScanModel nuevoScan) async{
    final db = await database;

    final res = await db.rawInsert(
      "INSERT into Scans (id, tipo, calor) "
      "VALUES (${nuevoScan.id}, '${nuevoScan.tipo}', '${nuevoScan.valor}')"
    );
    return res;
  }
  
  //CREAR - registros con otra instruccion 
  nuevoScan(ScanModel nuevoScan) async {
    final db = await database;
    final resp = await db.insert('Scans', nuevoScan.toJson() );

    return resp;
  }

  //SELECT - obtener informacion por ID
  getScanId(int id) async {
    
    final db = await database;
    final resp = await db.query('Scans', where: 'id = ?', whereArgs: [id]); //los argumentos deben ir en orden de procedencia
    return resp.isNotEmpty ? ScanModel.fromJson(resp.first) : null;

  }
  //SELECT - todos
  Future<List<ScanModel>> getTodosScans() async{

    final db = await database;
    final resp = await db.query('Scans');

    List<ScanModel> list = resp.isNotEmpty 
                                ? resp.map((c) => ScanModel.fromJson(c)).toList() 
                                :[];
    return list;
  }
  Future<List<ScanModel>> getScansPorTipo(String tipo) async{

    final db = await database;
    final resp = await db.rawQuery("SELECT * FROM Scans WHERE tipo='$tipo'");

    List<ScanModel> list = resp.isNotEmpty 
                                ? resp.map((c) => ScanModel.fromJson(c)).toList() 
                                :[];
    return list;
  }
  // ACTUALIZAR Registros
  Future<int> updateScan(ScanModel nuevoScan) async {

    final db = await database;
    final resp = await db.update('Scans', nuevoScan.toJson(), where: 'id=?', whereArgs: [nuevoScan.id] );

    return resp;

  }

  Future<int> deleteScan(int id) async {

    final db = await database;
    final resp = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);
    return resp;
  }
  Future<int> deletAll() async {

    final db = await database;
    final resp = await db.rawDelete('DELETE FROM Scans');
    return resp;
  }

}