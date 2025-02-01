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
    if (time>=PlayList_shuffled[count][1]){
      count++;
      if (PlayList_shuffled.length>count){
        Play();
      }else{
        count=0;
        //PlayList_shuffled = shufflePlaylistWithRandomValues(PlayList);
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
        showControls: false, // コントロール表示
        showFullscreenButton: false, // フルスクリーンボタンを表示
        showVideoAnnotations: false,
        mute: false,
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