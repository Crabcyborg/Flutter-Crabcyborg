import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

List<String> colorStrings = [
  '105,55,173','65,7,143','157,40,189','112,61,125',
	'168,41,118','221,59,157','208,37,37','0,74,149',
	'57,212,168','40,203,227','20,205,59','255,213,39',
	'223,112,0','182,250,29','55,67,172','42,147,64',
	'128,255,128','42,140,248','200,6,10','255,68,0',
	'255,0,128','58,205,98','0,198,189','16,107,177',
	'225,0,39','143,170,0','13,127,44','0,250,251',
	'255,128,255','0,232,35','128,0,64','242,93,49',
	'255,237,0','207,45,255','224,119,255','240,0,0',
	'255,51,51','199,228,27','237,57,167','183,123,160',
	'255,128,192','0,128,128','112,146,190','255,128,0',
	'128,128,192','249,200,30','44,32,255','237,46,18',
	'21,36,174','255,154,53','221,0,111','82,197,33'
];

List<Color> colors;
List<List> grid = [];
String style = 'gradient';

int offsetColorIndex(int index, int offset) => (index + offset) % colors.length;

List<Widget> renderShapeUp({int colorIndexOffset = 0, int overrideColorIndex = -1, Function onTap}) => grid.map<Widget>(
    (row) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row.map<Widget>(
        (value) => GestureDetector(
          onTap: onTap == null || value['empty'] ? null : () => onTap(offsetColorIndex(value['colorIndex'], colorIndexOffset)),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2.0),
            decoration: new BoxDecoration(
              color: value['empty'] ? null : (overrideColorIndex >= 0 ? colors[overrideColorIndex] : colors[(value['colorIndex'] + colorIndexOffset) % colors.length]),
              gradient: value['empty'] || style != 'gradient' || overrideColorIndex >= 0 ? null : new LinearGradient(
                begin: Alignment(-1.0, -1.0),
                end: Alignment(1.0, 1.0),
                colors: value['empty'] || overrideColorIndex >= 0 ? [] : [
                  colors[offsetColorIndex(value['colorIndex'], colorIndexOffset)],
                  colors[offsetColorIndex(value['colorIndex'], colorIndexOffset + 1)]
                ],
              ),
              border: value['empty'] ? null : new Border.all(
                  width: 1.0,
                  style: BorderStyle.solid
              ),
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            ),
          )
        )
      ).toList()
    )
).toList();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crab Cyborg',
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
      home: MyHomePage(title: 'Crab Cyborg'),
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
  Animation<double> animation;            
  AnimationController controller;

  List<int> numbers = new List<int>.generate(10, (i) => i + 1);
 
  @override
  void initState() {
    super.initState();

    List<int> skull =	[11,10,	30,15,195,243,255,140,99,25,231,207,51,15,194,208];
    int height = skull[0];
    int width = skull[1];

    List<int> targets = [128,64,32,16,8,4,2,1];
    int x = -1, y = -1, dataIndex = 2, targetIndex = 0;

    colors = colorStrings.map(
      (rgb) {
        List<int> split = rgb.split(',').map((rgbValue) => int.parse(rgbValue)).toList();
        return Color.fromRGBO(split[0], split[1], split[2], 1);
      }
    ).toList();

    while(++y < height) {
      List row = [];

      while(++x < width) {
        bool empty = (skull[dataIndex] & targets[targetIndex]) == 0;
				row.add({
          "x": x,
          "y": y,
          "empty": empty,
          "colorIndex": empty ? null : x+y,
        });

				if(targetIndex++ == 7) {
					++dataIndex;
					targetIndex = 0;
				}
			}

      grid.add(row);
      x = -1;
    }

    controller = AnimationController(duration: const Duration(seconds: 10), vsync: this);
    animation = Tween<double>(begin: 0, end: colors.length.toDouble()).animate(controller)
      ..addListener(() {
        setState(() {
        // The state that has changed here is the animation object’s value.
        });
      })
      ..addStatusListener((status) {
        if(status == AnimationStatus.completed) {
          controller.reverse();
        } else if(status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
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
          children: renderShapeUp(
            colorIndexOffset: animation.value.toInt(),
            onTap: (colorIndex) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute(colorIndex: colorIndex)),
            )
          )
          ..add(SizedBox(height: 10))
          ..add(Container(padding: const EdgeInsets.all(20.0), child: Text('Clicking on any grid cell will load a new route with a new Shape Up widget in the selected color.')))
          ..add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              RaisedButton(
                onPressed: () => style = 'solid',
                child: Text('solid')
              ),
              SizedBox(width: 10),
              RaisedButton(
                onPressed: () => style = 'gradient',
                child: Text('gradient')
              )
            ])
          )
          ..add(SizedBox(height: 20))
          ..add(
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              padding: const EdgeInsets.all(20.0),
              child: Linkify(
                onOpen: (link) async {
                  if(await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                text: "This website is open source https://github.com/Crabcyborg/Flutter-Crabcyborg",
                linkStyle: TextStyle(color: Colors.blue[500]),
              )
            )
          )
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {

  final int colorIndex;

  SecondRoute({Key key, @required this.colorIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Color"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: renderShapeUp( overrideColorIndex: colorIndex )
        )
      ),
    );
  }
}