import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mono_story/constants.dart';

class ThreadButton extends StatelessWidget {
  final String name;
  final void Function() onPressed;

  const ThreadButton({
    Key? key,
    required this.name,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              decoration: const BoxDecoration(
                color: threadNameBgColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Text(
                name,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: GoogleFonts.robotoMono(
                  textStyle: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}
