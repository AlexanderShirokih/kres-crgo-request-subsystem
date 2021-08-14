import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef OnUpdateSearchText = Function(BuildContext, String);

/// Animated expandable search bar
class SearchBar extends HookWidget {
  final OnUpdateSearchText onUpdateSearchText;
  final double expandedWidth;

  const SearchBar({
    Key? key,
    required this.onUpdateSearchText,
    required this.expandedWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).accentColor;

    final isOpened = useState(false);

    final focusNode = useFocusNode();

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final widthPercent = useAnimation(
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController));

    final color = useAnimation(ColorTween(begin: accent, end: Colors.white)
        .animate(animationController));

    final isExpanded = widthPercent > 0.3;

    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widthPercent * expandedWidth * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 4.0,
              ),
              child: TextField(
                focusNode: focusNode,
                onChanged: (text) => onUpdateSearchText(context, text),
              ),
            ),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.search,
              color: isExpanded ? accent : Colors.white,
            ),
            onPressed: () {
              if (!isOpened.value) {
                isOpened.value = true;
                animationController.forward();
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
              } else {
                isOpened.value = false;
                animationController.reverse();
              }
            },
          ),
        ],
      ),
    );
  }
}
