import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(
    BuildContext context,
    String msg,
  ) //BuildContext context gives access to the location of a widget in the widget tree.
  {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));  //(_) means I am not using that parameter
  }
}
