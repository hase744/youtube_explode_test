import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<String> getDownloadUrl(String videoId) async {
    var youtube = YoutubeExplode();
    var video = await youtube.videos.get(videoId);  

    // Get the stream manifest for the video
    var streamManifest = await youtube.videos.streamsClient.getManifest(videoId); 

    // Get the audio-only streams from the manifest
    var audioOnlyStreams = streamManifest.audioOnly;  

    // Get the highest quality audio-only stream
    var audioStream = audioOnlyStreams.withHighestBitrate();  

    // Return the URL of the audio stream
    return audioStream.url.toString(); 
    
  }
  final yt = YoutubeExplode();

  Future<void> explodedown() async {
    stdout.write('type the video id or url: ');

    var url = stdin.readLineSync()!.trim();

    // save the video to the download directory.
    Directory('downloads').createSync();

    // download the video.
    await download(url);

    yt.close();
    exit(0);
  }

Future<void> download(String id) async {
  // get video metadata.
  var video = await yt.videos.get(id);

  // get the video manifest.
  var manifest = await yt.videos.streamsClient.getManifest(id);
  var streams = manifest.videoOnly;

  // get the audio track with the highest bitrate.
  var audio = streams.first;
  var audiostream = yt.videos.streamsClient.get(audio);

  // compose the file name removing the unallowed characters in windows.
  var filename = '${video.title}.${audio.container.name}'
      .replaceAll(r'\', '')
      .replaceAll('/', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '');
  var file = File('downloads/$filename');

  // delete the file if exists.
  if (file.existsSync()) {
    file.deleteSync();
  }

  // open the file in writeappend.
  var output = file.openWrite(mode: FileMode.writeOnlyAppend);

  // track the file download status.
  var len = audio.size.totalBytes;
  var count = 0;

  // create the message and set the cursor position.
  var msg = 'downloading ${video.title}.${audio.container.name}';
  stdout.writeln(msg);

  // listen for data received.
  //  var progressbar = progressbar();
  await for (final data in audiostream) {
    // keep track of the current downloaded data.
    count += data.length;
    // calculate the current progress.
    var progress = ((count / len) * 100).ceil();
    print (progress);
    // update the progressbar.
    // progressbar.update(progress);
    // write to file.
    output.add(data);
  }
  await output.close();
}

  String youtubelink = "https://www.youtube.com/watch?v=ohFxsyrQQ68";
  Future<void> _downloadvideo(youtubelink) async{
    final yt = YoutubeExplode();
    final video = await yt.videos.get(youtubelink);
    // get the video manifest.
    final manifest = await yt.videos.streamsClient.getManifest(youtubelink);
    final streams = manifest.muxed;
    final audio = streams.first;
    final audiostream = yt.videos.streamsClient.get(audio);
    final filename = '${video.title}.${audio.container.name.toString()}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', ''); 
  
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    final directory = Directory('$path/video/');
    await directory.create(recursive: true);
    final file = File('$path/video/$filename');
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);
    var len = audio.size.totalBytes;
    var count = 0;
    var msg = 'downloading ${video.title}.${audio.container.name}';
    stdout.writeln(msg);
    await for (final data in audiostream){
      count += data.length;
      var progress = ((count / len) * 100).ceil();
      print(progress);
      output.add(data);
    }
    print('saving in $path/video/$filename');
    await output.flush();
    await output.close();
  }

  downloadFunc() async {
    String url = await getDownloadUrl("13gcZ1Chayk");
    print(url);
  }

  Future<void> listApplicationDocumentsDirectories() async {
    Directory dir = await getApplicationDocumentsDirectory();
    if (dir.existsSync()) {
      List<FileSystemEntity> filesAndDirectories = dir.listSync();
      List<Directory> directories = [];

      for (var entity in filesAndDirectories) {
        if (entity is Directory) {
          directories.add(entity);
        }
      }

      for (var subDir in directories) {
        print("Directory: ${subDir.path}");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: (){
                downloadFunc();
              }, 
              child: Text("ダウンロードオーディオ")
            ),
            TextButton(
              onPressed: (){
                _downloadvideo(youtubelink);
              }, 
              child: Text(" YouTubeダウンロード")
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: VideoPlayerApp(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class VideoPlayerApp extends StatefulWidget {
  @override
  _VideoPlayerAppState createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  late VideoPlayerController _controller;
  late List controllerList = [];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      // Replace with the path to your video file
      File('/data/user/0/com.example.youtube_explode_test/app_flutter/video/SennaRin「melt」Music Video（アニメ『銀河英雄伝説 Die Neue These 激突』テーマソング）.3gpp'),
    )..initialize().then((_) {
        // Ensure the first frame is shown
        
      });
      print("ディレクトリ");
      listApplicationDocumentsDirectories();
  }

  getAllFiles() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String videoDirPath = '${dir.path}/video';
    Directory videoDir = Directory(videoDirPath);
    List files = [];
    if (videoDir.existsSync()) {
    List<FileSystemEntity> videoDirectories = videoDir.listSync();

      for (var videoDirectory in videoDirectories) {
        if (videoDirectory is Directory) {
          print('Directory: ${videoDirectory.path}');
          // You can perform operations on each video directory here.
        }
         else if (videoDirectory is  File) {
          files.add(videoDirectory.path);
          // It's a Directory, you can access directory-specific properties here.
          print('File: ${videoDirectory.path}');
        }
      }
    } else {
      print('The "video" directory does not exist in the Application Documents Directory.');
    }
    return files;
  }

  Future<void> listApplicationDocumentsDirectories() async {
  Directory dir = await getApplicationDocumentsDirectory();
  String videoDirPath = '${dir.path}/video';
  Directory videoDir = Directory(videoDirPath);

  if (videoDir.existsSync()) {
    List<FileSystemEntity> videoDirectories = videoDir.listSync();

    for (var videoDirectory in videoDirectories) {
      if (videoDirectory is Directory) {
        print('Directory: ${videoDirectory.path}');
        // You can perform operations on each video directory here.
      }
       else if (videoDirectory is  File) {
        // It's a Directory, you can access directory-specific properties here.
        print('File: ${videoDirectory.path}');
      }
    }
  } else {
    print('The "video" directory does not exist in the Application Documents Directory.');
  }
}

bool isVideoFile(File file) {
  final videoExtensions = ['.mp4', '.avi', '.mov', '.mkv', '.wmv']; // Add more extensions if needed
  return videoExtensions.contains(file.path.split('.').last);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Video Player Example'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(), // Show loading indicator until the video is initialized
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}