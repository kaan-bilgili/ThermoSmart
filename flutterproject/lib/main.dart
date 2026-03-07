import 'package:flutter/material.dart';

int main() {
  runApp(const MyWidget());
  return 0;
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Lora"),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(50, 25, 25, 255),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 122, 84, 83),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'KONTES BIR CANAVAR TUM SINIF ONDAN KORKAR',
            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight(400)),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GENETICS LOVER!',
                style: TextStyle(fontSize: 24, fontFamily: 'Lora'),
              ),
              SizedBox(height: 25),
              Text(
                'I am a genetics lover and I am passionate about learning more about the field. I enjoy reading about the latest research and discoveries in genetics, and I am always eager to expand my knowledge. I find the complexity of genetics fascinating and I am excited to see how it continues to evolve in the future.',
                style: TextStyle(fontSize: 21, fontFamily: 'Lora'),
              ),
              SizedBox(height: 32),
              Image.network(
                "https://picsum.photos/400",
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 12),
              Image.asset(
                "assets/images/photo.jpeg",
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  print("You have pressed"); //empty function for now
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "Press me if you love kontes",
                  style: TextStyle(fontSize: 23),
                ),
              ),

              SizedBox(height: 3),
              TextButton(
                onPressed: () => print("U pressed the text"),

                child: Text("Press me if you don't"),
              ),
              Icon(Icons.add_box_sharp, size: 22, color: Colors.red.shade400),
              IconButton(
                onPressed: () => print("You have pressed"),
                icon: Icon(color: Colors.red, Icons.agriculture_rounded),
              ),
              IconButton(
                onPressed: () => print("U pressed the text"),
                icon: Icon(
                  Icons.add_box_sharp,
                  size: 22,
                  opticalSize: 13,
                  color: Colors.red.shade400,
                  fill: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
