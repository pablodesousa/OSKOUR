import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redux/redux.dart';
import 'redux.dart';
import 'src/welcomePage.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Store<bool> myStore = Store<bool>(connectionReducer, initialState: false);
    return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
              bodyText1: GoogleFonts.montserrat(textStyle: textTheme.bodyText1),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: WelcomePage(store: myStore),
        );
  }
}
