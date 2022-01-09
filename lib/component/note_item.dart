import 'dart:io';

import 'package:face_gragh_task/component/default_form_field.dart';
import 'package:face_gragh_task/component/image.dart';
import 'package:face_gragh_task/cubit/cubit.dart';
import 'package:face_gragh_task/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget noteItem(
  context, {
  required model,
}) =>
    InkWell(
      onTap: () {
        // to open edit dialog
        openDialog(context, model);
      },
      child: Container(
        height: 130,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        child: Row(
          children: [
            customImage(
              File.fromUri(
                Uri.parse(
                  model['picture'],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontSize: 16.0,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Expanded(
                    child: Text(
                      model['description'],
                      style: Theme.of(context).textTheme.bodyText2,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        model['date'],
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Spacer(),
                      Text(
                        model['status'],
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              color: model['status'] == 'open'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

// dialog to edit all attributes of the note
void openDialog(context, model) {
  //this boolean is to check if note is open or close
  bool isOpen = model['status'] == 'open' ? true : false;

  //this to check if image is open or not
  bool isImageOpen = false;

  //this to check if status of note changed or not
  bool statusChanges = false;

  var title = TextEditingController();
  var description = TextEditingController();
  title.text = model['title'];
  description.text = model['description'];

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) =>
          StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(
            10.0,
          ),
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (isImageOpen)
                    setState(() {
                      isImageOpen = false;
                    });
                  else {
                    Navigator.pop(context);
                    AppCubit.get(context).changeBottomSheetState(false);
                  }
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              Spacer(),

              //this icon appear to save changes on note
              if (!isImageOpen)
                IconButton(
                  onPressed: () async {
                    if (title.text.isNotEmpty && description.text.isNotEmpty) {
                      if (title.text != model['title'] ||
                          description.text != model['description'] ||
                          statusChanges ||
                          AppCubit.get(context).noteImage != null) {
                        await AppCubit.get(context).updateNote(
                          title: title.text,
                          picture: AppCubit.get(context).noteImage != null
                              ? AppCubit.get(context).noteImage!.uri.toString()
                              : model['picture'],
                          description: description.text,
                          status: isOpen,
                          id: model['id'],
                        );
                        Fluttertoast.showToast(
                          msg: 'Note save successfully',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: 'No changes happened',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: 'the data must not be empty',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.save,
                    color: Colors.teal,
                  ),
                ),

              //this icon appear if image is opened to take a photo
              if (isImageOpen)
                IconButton(
                  onPressed: () {
                    AppCubit.get(context).getNoteImage();
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.teal,
                  ),
                ),
            ],
          ),
          titlePadding: EdgeInsets.zero,
          content: Stack(
            children: [
              //this is content of note to make edit on it
              if (!isImageOpen)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  isOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: isOpen ? Colors.green : Colors.red,
                                  ),
                                ),
                                trailing: Switch(
                                  value: isOpen,
                                  onChanged: (s) {
                                    setState(() {
                                      statusChanges = true;
                                      isOpen = !isOpen;
                                    });
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isImageOpen = true;
                                });
                              },
                              child: customImage(
                                AppCubit.get(context).noteImage ??
                                    File.fromUri(
                                      Uri.parse(
                                        model['picture'],
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        defaultFormField(
                          controller: title,
                          title: 'Title',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        defaultFormField(
                          controller: description,
                          title: 'Description',
                        ),
                      ],
                    ),
                  ),
                ),

              //this is an image that will appear if image is opened
              if (isImageOpen)
                customImage(
                  AppCubit.get(context).noteImage ??
                      File.fromUri(
                        Uri.parse(
                          model['picture'],
                        ),
                      ),
                ),
            ],
          ),
        );
      }),
    ),
  );
}
