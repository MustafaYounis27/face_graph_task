import 'package:face_gragh_task/component/default_form_field.dart';
import 'package:face_gragh_task/component/note_item.dart';
import 'package:face_gragh_task/component/slid_background.dart';
import 'package:face_gragh_task/cubit/cubit.dart';
import 'package:face_gragh_task/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var titleController = TextEditingController();

  var descriptionController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Visual Notes',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(
            10.0,
          ),
          child: ListView.separated(
            itemBuilder: (context, index) => Dismissible(
              key: Key(
                  AppCubit.get(context).visualNotes[index]['id'].toString()),
              background: slidBackground(true),
              secondaryBackground: slidBackground(false),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd ||
                    direction == DismissDirection.endToStart) {
                  confirmDismiss(index);
                }
              },
              child: noteItem(
                context,
                model: AppCubit.get(context).visualNotes[index],
              ),
            ),
            separatorBuilder: (context, index) => SizedBox(
              height: 10.0,
            ),
            itemCount: AppCubit.get(context).visualNotes.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!AppCubit.get(context).isBottomSheetOpen) {
              AppCubit.get(context).changeBottomSheetState(true);
              openBottomSheet(context);
            } else {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                if (AppCubit.get(context).noteImage != null) {
                  await AppCubit.get(context).insertToDatabase(
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                    msg: 'Please take an Image',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: 'Please complete the data',
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            }
          },
          child: Icon(
            AppCubit.get(context).icon,
          ),
        ),
      ),
    );
  }

  // to open bottom sheet to insert new note
  void openBottomSheet(context) {
    scaffoldKey.currentState!
        .showBottomSheet(
          (context) => Container(
            height: MediaQuery.of(context).size.height-300,
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            color: Colors.grey[200],
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<AppCubit, AppStates>(
                    builder: (context, state) => Row(
                      children: [
                        Expanded(
                          child: defaultFormField(
                            controller: titleController,
                            title: 'Title',
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        if (AppCubit.get(context).noteImage == null)
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 35.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 30.0,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                AppCubit.get(context).getNoteImage();
                              },
                            ),
                          ),
                        if (AppCubit.get(context).noteImage != null)
                          InkWell(
                            onTap: () {
                              AppCubit.get(context).getNoteImage();
                            },
                            child: Container(
                              height: 80.0,
                              width: 80.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    15.0,
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey,
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: FileImage(
                                        AppCubit.get(context).noteImage!,
                                      ))),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Expanded(
                    child: defaultFormField(
                      controller: descriptionController,
                      title: 'Description',
                    ),
                  ),
                  BlocBuilder<AppCubit, AppStates>(
                    builder: (context, state) => ListTile(
                      title: Text(
                        AppCubit.get(context).noteStatus ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppCubit.get(context).noteStatus
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      trailing: Switch(
                        value: AppCubit.get(context).noteStatus,
                        onChanged: (s) {
                          AppCubit.get(context).changeNoteStatus(s);
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          elevation: 20.0,
        )
        .closed
        .then((value) {
      AppCubit.get(context).changeBottomSheetState(false);

      titleController.clear();
      descriptionController.clear();
    });
  }

  // to handle the dismiss action to delete note
  Future<void> confirmDismiss(index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Are you sure you want to delete this note?'),
            actions: <Widget>[
              MaterialButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  AppCubit.get(context).deleteNote(
                      id: AppCubit.get(context).visualNotes[index]['id']);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
