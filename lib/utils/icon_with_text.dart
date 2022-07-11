import 'package:flutter/material.dart';
class IconWithTextUtility extends StatelessWidget {
  final IconData? iconData;
  final String? text;
  final VoidCallback? onTap;
  const IconWithTextUtility({Key? key, this.iconData, this.text, this.onTap, }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData,
            size: 20,color: Colors.black,),
            Flexible(child: Text(text!,style: const TextStyle(fontSize: 11,color: Colors.black),))
          ],
        ),
      ),
    );
  }
}
