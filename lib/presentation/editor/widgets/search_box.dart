import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef SearchTextWatcher = void Function(String);

class SearchBox extends StatefulWidget {
  final SearchTextWatcher textWatcher;

  const SearchBox({Key? key, required this.textWatcher}) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _fadeInAnimation,
      axis: Axis.horizontal,
      axisAlignment: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          type: MaterialType.card,
          elevation: 8.0,
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            width: 280.0,
            height: 46.0,
            child: Row(
              children: [
                IconTheme(
                  data: Theme.of(context)
                      .primaryIconTheme
                      .copyWith(color: Colors.black54, size: 16.0),
                  child: FaIcon(FontAwesomeIcons.search),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: widget.textWatcher,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
