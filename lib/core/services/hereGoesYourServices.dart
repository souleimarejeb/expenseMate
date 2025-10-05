
import '../database/databaseHelper.dart';
import '../models/exempleFilm.dart'; // Import your Film model

class FilmService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Add a new film
  Future<int> addFilm(Film film) async {
    final db = await _databaseHelper.database;
    return await db.insert('example', film.toMap());
  }

  // Fetch all films
  Future<List<Film>> getAllFilms() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('example');

    return List.generate(maps.length, (i) {
      return Film.fromMap(maps[i]);
    });
  }

  // Fetch a film by ID
  Future<Film?> getFilmById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'example',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Film.fromMap(maps.first);
    }
    return null; // Return null if not found
  }

  // Update a film
  Future<int> updateFilm(Film film) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'example',
      film.toMap(),
      where: 'id = ?',
      whereArgs: [film.id],
    );
  }

  // Delete a film
  Future<int> deleteFilm(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'example',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
