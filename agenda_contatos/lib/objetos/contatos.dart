import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String idColumn = "idColumn",
    nomeColumn = "nomeColumn",
    foneColumn = "foneColumn",
    emailColumn = "emailColumn",
    imgColumn = "imgColumn",
    contatosTable = "contatosTable ";

class Contatos {
  static final Contatos _contatos = Contatos.internal();

  factory Contatos() => _contatos;

  Contatos.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  Future<Database> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contatoslfcapp.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $contatosTable("
          "$idColumn INTEGER PRIMARY KEY,"
          "$nomeColumn TEXT,"
          "$emailColumn Text,"
          "$foneColumn TEXT,"
          "$imgColumn TEXT )");
    });
  }

  Future<Contato> salvarContato(Contato contato) async {
    Database dbContato = await db;
    contato.id = await dbContato.insert(contatosTable, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database dbContato = await db;
    List<Map> maps = await dbContato.query(contatosTable,
        columns: [idColumn, nomeColumn, foneColumn, emailColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List> getAllContato() async {
    Database dbContato = await db;
    List listMaps = await dbContato.rawQuery("SELECT * FROM $contatosTable");
    List<Contato> listContatos = List();
    for (Map m in listMaps) {
      listContatos.add(Contato.fromMap(m));
    }
    return listContatos;
  }

  Future<int> deleteContato(int id) async {
    Database dbContato = await db;
    return await dbContato
        .delete(contatosTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContato(Contato contato) async {
    Database dbContato = await db;
    return await dbContato.update(contatosTable, contato.toMap(),
        where: "$idColumn = ?", whereArgs: [contato.id]);
  }

  Future<int> getNumeroContato() async {
    Database dbContato = await db;
    return Sqflite.firstIntValue(
        await dbContato.rawQuery("SELECT COUNT(*) FROM $contatosTable"));
  }

  Future close() async {
    Database dbContato = await db;
    await dbContato.close();
  }
}

class Contato {
  int id;
  String nome;
  String email;
  String fone;
  String img;

  Contato();

  Contato.fromMap(Map map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    fone = map[foneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      foneColumn: fone,
      emailColumn: email,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString(){
    return "Contato(id: $id, nome: $nome, email: $email, fone: $fone, img: $img)";
  }
}
