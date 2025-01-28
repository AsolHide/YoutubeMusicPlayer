import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

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

  bool _playbutton=false;

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
              // A列はStringとして扱い、B列とC列はintとして扱う
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

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  String title="Playlist";

  late YoutubePlayerController _controller;

  List<List<dynamic>> PlayList=[];
  List<List<dynamic>> PlayList_shuffled=[];
  int count=0;

  List<List<dynamic>> shufflePlaylistWithRandomValues(List<List<dynamic>> playlist) {
    var random = Random();

    // 各要素についてランダムな値を生成
    List<List<dynamic>> newPlaylist = playlist.map((item) {
      double randomValue = random.nextDouble() * (item[2].value - item[1].value) + item[1].value; // item[1] と item[2] の間のランダムな値
      return [item[0], randomValue];
    }).toList();

    // リストをシャッフル
    newPlaylist.shuffle(random);

    return newPlaylist;
  } 

  void _listener(YoutubePlayerValue) async {
    double time= await _controller.currentTime;
    if (time>PlayList_shuffled[count][1]){
      count++;
      if (PlayList_shuffled.length>count){
        Play();
      }else{
        count=0;
        PlayList_shuffled = shufflePlaylistWithRandomValues(PlayList);
        Play();
      }
      
    }
  }

  void Play(){
    int count_for_show=count+1;
    int number_of_music=PlayList_shuffled.length;
    setState(() {
      title="▶再生中 ($count_for_show/$number_of_music)";
    });
    _controller.loadVideoById(videoId: PlayList_shuffled[count][0],endSeconds: PlayList_shuffled[count][1]);  
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true, // コントロール表示
        showFullscreenButton: true, // フルスクリーンボタンを表示
        //loop: true, // 動画をループ
      ),
    );

    _controller.listen(_listener);

    WidgetsBinding.instance.addPostFrameCallback((_){PlayList_shuffled = shufflePlaylistWithRandomValues(PlayList);Play();});
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as List<List<dynamic>>?;
    PlayList=arguments??[];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.player,
        title: Text('$title'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}

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

          ],),
      ),
    );
  }
}


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

class MyColor {
  static Color primary = Color.fromARGB(255, 30, 30, 30);
  static Color secondary = Color.fromARGB(255, 30, 30, 30);
  static Color player = Color.fromARGB(255, 30, 30, 30);
  static Color button = Color.fromARGB(255, 50, 50, 50);
}