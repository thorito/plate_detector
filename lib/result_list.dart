import 'package:flutter/material.dart';

class ResultList extends StatelessWidget {
  final List<String> plates;

  const ResultList({required this.plates, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.black54,
      child: ListView.builder(
        itemCount: plates.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(plates[index], style: TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }
}
