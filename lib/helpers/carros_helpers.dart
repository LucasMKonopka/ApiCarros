import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String idColumn = "idColumn";
String marcaColumn = "marcaColumn";
String modeloColumn = "modeloColumn";
String anoColumn = "anoColumn";
String corColumn = "corColumn";
String categoriaColumn = "categoriaColumn";
String imgColumn = "imgColumn";
String carroTable = "carroTable";

class CarrosHelper {
  static final CarrosHelper _instance = CarrosHelper.internal();
  factory CarrosHelper() => _instance;
  CarrosHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final DatabasePath = await getDatabasesPath();
    final path = join(DatabasePath, "carros.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
            "CREATE TABLE $carroTable($idColumn INTEGER PRIMARY KEY, $marcaColumn TEXT, $modeloColumn TEXT, $anoColumn TEXT, $corColumn TEXT, $categoriaColumn TEXT, $imgColumn TEXT)");
      },
    );
  }

  Future<List> getAllCarros() async {
    Database dbCarro = await db;
    List listMap = await dbCarro.rawQuery("SELECT * FROM $carroTable");
    List<Carro> listCarro = List();
    for (Map m in listMap) {
      listCarro.add(Carro.fromMap(m));
    }
    return listCarro;
  }

  Future<Carro> getCarro(int id) async {
    Database dbCarro = await db;
    List<Map> maps = await dbCarro.query(carroTable,
        columns: [
          idColumn,
          marcaColumn,
          modeloColumn,
          anoColumn,
          corColumn,
          categoriaColumn,
          imgColumn
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Carro.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Carro> saveCarro(Carro carro) async {
    Database dbCarro = await db;
    carro.id = await dbCarro.insert(carroTable, carro.toMap());
    return carro;
  }

  Future<int> updateCarro(Carro carro) async {
    Database dbCarro = await db;
    return await dbCarro.update(carroTable, carro.toMap(),
        where: "$idColumn = ?", whereArgs: [carro.id]);
  }

  Future<int> deleteCarro(int id) async {
    Database dbCarro = await db;
    return await dbCarro
        .delete(carroTable, where: "$idColumn = ?", whereArgs: [id]);
  }
}

class Carro {
  Carro();

  int id;
  String marca;
  String modelo;
  String ano;
  String cor;
  String categoria;
  String img;

  Carro.fromMap(Map map) {
    id = map[idColumn];
    marca = map[marcaColumn];
    modelo = map[modeloColumn];
    ano = map[anoColumn];
    cor = map[corColumn];
    categoria = map[categoriaColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      marcaColumn: marca,
      modeloColumn: modelo,
      anoColumn: ano,
      corColumn: cor,
      categoriaColumn: categoria,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Carro(id: $id, marca: $marca, modelo: $modelo, ano: $ano, cor: $cor, categoria: $categoria, img: $img)";
  }
}
