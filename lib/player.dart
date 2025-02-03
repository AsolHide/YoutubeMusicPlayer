import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:math';
import 'mycolor.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  String title="Playlist";

  late YoutubePlayerController _controller;

  Map<String, List<List<dynamic>>> PlayList={};
  List<List<dynamic>> urlList=[];
  List<List<dynamic>> urlList_shuffled=[];
  String sheet_name="";
  int music_count=0;
  int sheet_count=0;

  List<List<dynamic>> shufflePlaylistWithRandomValues(List<List<dynamic>> urllist) {
    var random = Random();

    debugPrint("$urllist");
    // 各要素についてランダムな値を生成
    List<List<dynamic>> newurllist = urllist.map((item) {
      double randomValue = random.nextDouble() * (item[2].value - item[1].value) + item[1].value; // item[1] と item[2] の間のランダムな値
      return [item[0], randomValue];
    }).toList();

    // リストをシャッフル
    newurllist.shuffle(random);

    return newurllist;
  } 

  void _listener(YoutubePlayerValue) async {
    double time= await _controller.currentTime;
    if (time>=urlList_shuffled[music_count][1]){
      music_count++;
      if (urlList_shuffled.length>music_count){
        Play();
      }else{
        music_count=0;
        sheet_count++;
        if (sheet_count>=PlayList.keys.length){
          sheet_count=0;
        }
        sheet_name=PlayList.keys.elementAt(sheet_count);
        urlList = PlayList[sheet_name]!;
        urlList_shuffled = shufflePlaylistWithRandomValues(urlList);
        Play();
      }
      
    }
  }

  void Play(){
    int count_for_show=music_count+1;
    int number_of_music=urlList_shuffled.length;
    setState(() {
      title="▶$sheet_name：$count_for_show/$number_of_music";
    });
    _controller.loadVideoById(videoId: urlList_shuffled[music_count][0],endSeconds: urlList_shuffled[music_count][1]);  
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false, // コントロール表示
        showFullscreenButton: false, // フルスクリーンボタンを表示
        showVideoAnnotations: false,
        mute: false,
        //loop: true, // 動画をループ
      ),
    );

    _controller.listen(_listener);

    WidgetsBinding.instance.addPostFrameCallback(
      (_){
        sheet_name=PlayList.keys.elementAt(sheet_count);
        urlList = PlayList[sheet_name]!;
        urlList_shuffled = shufflePlaylistWithRandomValues(urlList);
        Play();
      }
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, List<List<dynamic>>>?;
    PlayList=arguments??{};
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.player,
        title: Text('$title'),
      ),
      body: Center(
        child: Column(children: [
          IgnorePointer(
            ignoring: true,
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          )
        ],)
      ),
    );
  }
}