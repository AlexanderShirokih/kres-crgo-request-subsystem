import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef OnLoginFormEntered = Function(String, String);

/// Shows Log-In form with login and password
class LogInFormView extends StatefulWidget {
  final OnLoginFormEntered onLoginFormEntered;

  const LogInFormView({
    @required this.onLoginFormEntered,
  }) : assert(onLoginFormEntered != null);

  @override
  _LogInFormViewState createState() => _LogInFormViewState();
}

class _LogInFormViewState extends State<LogInFormView> {
  String _login = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          maxLength: 50,
          maxLengthEnforced: true,
          decoration: InputDecoration(
            prefixIcon: FaIcon(FontAwesomeIcons.user),
            labelText: 'Логин',
          ),
          onChanged: (value) => setState(() {
            _login = value;
          }),
        ),
        const SizedBox(height: 12.0),
        TextField(
          maxLength: 24,
          maxLengthEnforced: true,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: FaIcon(FontAwesomeIcons.lock),
            labelText: 'Пароль',
          ),
          onChanged: (value) => setState(() {
            _password = value;
          }),
        ),
        const SizedBox(height: 42.0),
        RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
          onPressed: _login.isNotEmpty && _password.isNotEmpty
              ? () {
                  widget.onLoginFormEntered(_login, _password);
                }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.signInAlt),
              const SizedBox(width: 16.0),
              Text('Войти'),
            ],
          ),
          color: Theme.of(context).accentColor,
          textColor: Theme.of(context).accentTextTheme.bodyText1.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ],
    );
  }
}
