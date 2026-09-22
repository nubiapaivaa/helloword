//Database_helper.dart
//Database helper para gerenciar a conexão com o banco de dados SQLite.
//Responsável por criar a tabela, inserir, atualizar, excluir e consultar registros.
//dados SQLite.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tarefa.dart';

class DatabaseHelper {
  //instancia unica do banco de dados
  static Database? _database;

  //Retorna o banco.
  //Se ainda não existir, cria o banco e a tabela.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  //Criação/abertura do banco de dados.
  Future<Database> _initDatabase() async {
    final caminho = join(await getDatabasesPath(), 'tarefas.db');

    return await openDatabase(
      caminho,
      version: 1,

      //Executado somente na primeira vez que o banco é criado.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL,
            prioridade TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  //Insere uma nova tarefa no banco de dados.
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  //Lista todas as tarefas do banco de dados.
  Future<List<Tarefa>> listarTarefas() async {
    final db = await database;
    return await db.query('tarefas', orderBy: 'id DESC').then((maps) {
      return maps.map((map) => Tarefa.fromMap(map)).toList();
    });
  }

  //Atualiza uma tarefa existente no banco de dados.
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  //Exclui uma tarefa do banco de dados.
  Future<int> ExcluirTarefa(int id) async {
    final db = await database;

    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
