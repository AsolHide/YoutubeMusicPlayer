import 'package:flutter/material.dart';
import 'mycolor.dart';
import 'mywidget.dart';

class Help extends StatefulWidget {
  const Help({super.key, required this.title});

  final String title;

  @override
  State<Help> createState() => HelpState();
}

class HelpState extends State<Help> {
@override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.secondary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Mywidget.NormalBUtton(size.width, "アプリの使い方", (){Navigator.pushNamed(context, '/Help/HowtoUse');}, true),

          ],),
      ),
    );
  }
}

class HowtoUse extends StatefulWidget {
  const HowtoUse({super.key, required this.title});

  final String title;

  @override
  State<HowtoUse> createState() => HowtoUseState();
}

class HowtoUseState extends State<HowtoUse> {
@override
  Widget build(BuildContext context) {
    //final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.secondary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [

          ],),
      ),
    );
  }
}