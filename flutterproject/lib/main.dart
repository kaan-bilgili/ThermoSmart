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
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight(300)),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GENETICS LOVER!',
                style: TextStyle(fontSize: 24, fontFamily: 'Lora'),
              ),
              SizedBox(height: 25),
              Text(
                'I am a genetics lover and I am passionate about learning more about the field. I enjoy reading about the latest research and discoveries in genetics, and I am always eager to expand my knowledge. I find the complexity of genetics fascinating and I am excited to see how it continues to evolve in the future.',
                style: TextStyle(fontSize: 16, fontFamily: 'Lora'),
              ),
              SizedBox(height: 32),
              Image.network(
                "https://picsum.photos/400",
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 32),
              Image.asset(
                "assets/images/photo.jpeg",
                width: 400,
                height: 300,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
