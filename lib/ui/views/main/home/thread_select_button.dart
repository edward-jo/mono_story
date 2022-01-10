import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class ThreadSelectButton extends PlatformWidgetBase {
  final String name;
  final void Function() onPressed;

  const ThreadSelectButton({
    Key? key,
    required this.name,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          Flexible(
            child: Container(
              color: const Color(0xFFFAEBDD),
              padding: const EdgeInsets.all(5.0),
              child: Text(
                name,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          CupertinoButton(
            child: Icon(
              CupertinoIcons.chevron_down,
              color: CupertinoTheme.of(context)
                  .textTheme
                  .navLargeTitleTextStyle
                  .color,
              size: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .fontSize,
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            name,
            style: GoogleFonts.robotoMono(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MaterialButton(
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
