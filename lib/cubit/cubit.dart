import 'dart:io';

import 'package:face_gragh_task/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  late Database database;
  List<Map> visualNotes = [];

  void createDatabase() {
    openDatabase(
      'note.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, picture TEXT, description TEXT, date TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getNotesFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void getNotesFromDatabase(database) {
    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM notes').then((value) {
      visualNotes = value;

      emit(AppGetDatabaseState());
    });
  }

  Future<void> insertToDatabase({
    required String title,
    required String description,
  }) async {
    var getDate = DateTime.now();
    String date = DateFormat('dd/MM/yyyy, h:mm a').format(getDate);
    String status = noteStatus ? 'open' : 'closed';
    await database.transaction((txn) {
      return txn
          .rawInsert(
        'INSERT INTO notes(title, picture, description, date, status) VALUES("$title", "${noteImage!.uri.toString()}", "$description", "$date", "$status")',
      )
          .then((value) {
        print('$value inserted successfully');

        noteImage = null;
        getNotesFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  Future<void> updateNote({
    required String title,
    required String picture,
    required String description,
    required bool status,
    required int id,
  }) async {
    String noteStatus = 'open';
    if (!status) noteStatus = 'closed';
    database.rawUpdate(
      'UPDATE notes SET title = ?, picture = ?, description = ?, status = ? WHERE id = ?',
      ['$title', '$picture', '$description', '$noteStatus', id],
    ).then((value) {
      emit(AppUpdateDatabaseState());
      noteImage = null;
      getNotesFromDatabase(database);
    });
  }

  void deleteNote({
    required int id,
  }) async {
    database.rawDelete('DELETE FROM notes WHERE id = ?', [id]).then((value) {
      getNotesFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  var picker = ImagePicker();

  File? noteImage;

  Future<void> getNoteImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      noteImage = File(pickedFile.path);
      emit(AppGetPictureState());
    } else {
      print('No image selected.');
      emit(AppGetPictureState());
    }
  }

  bool isBottomSheetOpen = false;
  IconData icon = Icons.add;

  void changeBottomSheetState(bool isOpen) {
    isBottomSheetOpen = isOpen;
    if (isOpen) {
      icon = Icons.save_outlined;
    } else {
      icon = Icons.add;
    }

    noteImage = null;
    emit(AppBottomSheetState());
  }

  bool noteStatus = true;

  void changeNoteStatus(bool isOpen) {
    noteStatus = isOpen;

    emit(AppChangeNoteStatusState());
  }
}
