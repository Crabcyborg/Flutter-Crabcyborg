import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final double cellSize = 20;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shape Up Editor',
      theme: ThemeData(
        primaryIconTheme: const IconThemeData.fallback().copyWith(
          color: Colors.white,
        ),
        primarySwatch: Colors.lightGreen,
        primaryTextTheme: TextTheme(
          title: TextStyle(
            color: Colors.white
          )
        )
      ),
      home: MyHomePage(title: 'Shape Up Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
 
  List<String> _toggled = new List<String>();

  bool solid(x,y) => _toggled.contains("$x,$y");

  void toggle(x,y) {
    setState(() {
      if(!_toggled.remove("$x,$y")) {
        _toggled.add("$x,$y");
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: new List<int>.generate(
          (MediaQuery.of(context).size.height - AppBar().preferredSize.height) ~/ cellSize,
          (i) => i + 1
        ).map(
          (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: new List<int>.generate(
              MediaQuery.of(context).size.width ~/ cellSize,
              (i) => i + 1
            ).map(
              (cell) => GestureDetector(
                onTap: () => toggle(cell, row),
                child: Container(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                      width: 1.0,
                      style: BorderStyle.solid
                    ),
                  ),
                  width: cellSize,
                  height: cellSize,
                  child: solid(cell, row) ? Container(
                    decoration: new BoxDecoration(
                      color: Color.fromRGBO(0,0,0,1),
                    )
                  ) : null
                )
              )
            ).toList()
          )
        ).toList() 
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          int minx, miny, maxx, maxy;
          _toggled.forEach((coord) {
            List<String> split = coord.split(',');
            int x = int.parse(split[0]);
            int y = int.parse(split[1]);
            if(minx == null || x < minx) minx = x;
            if(miny == null || y < miny) miny = y;
            if(maxx == null || x > maxx) maxx = x;
            if(maxy == null || y > maxy) maxy = y;
          });

          int width = maxx-minx+1;
          int height = maxy-miny+1;
          
          List<List<bool>> grid = new List<List<bool>>();
          for(int y = miny; y <= maxy; ++y) {
            List<bool> row = new List<bool>();
            for(int x = minx; x <= maxx; ++x) {
              row.add(_toggled.contains("$x,$y"));
            }

            grid.add(row);
          }

          String shape = "$height,$width,";

          int index = 0;
          int value = 0;
          List<int> targets = [128,64,32,16,8,4,2,1];
          grid.forEach((row) {
            row.forEach((cell) {
              if(cell) {
                value += targets[index];
              }

              if(++index == 8) {
                shape += "$value,";
                value = index = 0;
              }
            });
          });

          if(value > 0) {
            shape += "$value";
          } else {
            shape = shape.substring(0, shape.length-1);
          }

          String url = "https://crabcyb.org/shapeup/$shape";

          if(await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
}