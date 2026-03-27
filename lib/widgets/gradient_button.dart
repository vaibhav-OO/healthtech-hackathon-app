import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  
  const GradientButton({required this.text, required this.onPressed});
  
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
        child: Text(text,style: TextStyle(fontSize: 16),),
      ),
    );
  }
  
}