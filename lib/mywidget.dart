import 'package:flutter/material.dart';
import 'mycolor.dart';

class Mywidget {
  static Widget NormalBUtton(size,title,func,isvisible)=> SizedBox(
              width:size-20,
              height:80.0,
              child:Visibility(
                visible: isvisible,
                child:ElevatedButton(
                  onPressed: func, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 40.0,),
                  ),
                ),
              ),
            );
}