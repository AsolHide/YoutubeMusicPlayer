import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'mycolor.dart';
import 'player.dart';
import 'help.dart';
import 'mywidget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // 縦向き
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
        ),
      ),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/':(context)=>InitPage(title: 'YoutubeMusicPlayer'),
        '/Player':(context)=>VideoPlayerScreen(),
        '/Help':(context)=>Help(title: 'ヘルプ',),
        '/Help/HowtoUse':(context)=>HowtoUse(title: 'アプリの使い方',),
      },
    );
  }
}

class InitPage extends StatefulWidget {
  const InitPage({super.key, required this.title});

  final String title;

  @override
  State<InitPage> createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  List<List<dynamic>> PlayList=[];

  //bool _playbutton=false;
  bool _playbutton=true;

  String? fileName="未選択";
  Map<String, List<List<dynamic>>> excelData = {};
  String sheetname="";
  List<List<dynamic>>? urlList=[];


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Future<void> pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
        withData: true,
        
      );
      if (result!=null){
        PlatformFile file = result.files.first;
        setState(() {
          fileName = file.name; // ファイル名を保存
        });

        // Excelファイルを読み取る
        Uint8List? fileBytes = file.bytes;
        if (fileBytes != null){
          final Excel excel = Excel.decodeBytes(fileBytes);
          Map<String, List<List<dynamic>>> tempData = {};

          // Excelファイル内のデータを読み取る
          for (var table in excel.tables.keys) {
            List<List<dynamic>> rows = [];

            for (var row in excel.tables[table]!.rows) {
              List<dynamic> convertedRow = [];

              for (int colIndex = 0; colIndex < row.length; colIndex++) {
                var cell = row[colIndex];
                if (cell != null) {
                  var value = cell.value;
                  if (colIndex==0){
                    convertedRow.add(value.toString());
                  }else{
                    convertedRow.add(value);
                  }
                  
                } else {
                  convertedRow.add("");  // セルがnullの場合は空文字列を追加
                }
              }
              rows.add(convertedRow);
            }

            tempData[table] = rows; // シート名をキーにしてデータを保存
          }

          setState(() {
            excelData = tempData; // ファイル内容を保存
            sheetname=tempData.keys.elementAt(0);
            urlList=tempData[sheetname];
            _playbutton=true;
          });
          
        }else{
          setState(() {
            //fileName = "読み込めませんでした(fileBytes==null)";
            excelData = {}; // ファイル内容を保存
          });
        }
      }else{
        setState(() {
          //fileName = "読み込めませんでした(result==null)";
          excelData = {}; // ファイル内容を保存
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.primary,
        title: Text(widget.title),
        actions: [IconButton(onPressed: (){Navigator.pushNamed(context, '/Help');}, icon: Icon(Icons.help_outline))],
      ),
      body: Center(
        child:Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Mywidget.NormalBUtton(size.width,"音楽リスト選択",pickFile,true),
            SizedBox(height: 20,),
            Text("＜読み込まれたリスト＞\n$fileName",textAlign: TextAlign.center,),
            SizedBox(height: 20,),
            Mywidget.NormalBUtton(size.width,"再生",(){Navigator.pushNamed(context, '/Player',arguments: urlList);},_playbutton),
          ],
        ),
      ),
    );
  }
}