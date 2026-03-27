import 'package:flutter/material.dart';

class SymptomTitle extends StatelessWidget{
  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const SymptomTitle({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap
});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: selected ? Colors.blueAccent : Colors.white,
        child: ListTile(
          leading: Icon(icon, color: selected ? Colors.white : Colors.black,),
          title: Text(name, style: TextStyle(color: selected ? Colors.white : Colors.black),),
        ),
      ),
    );
  }

}