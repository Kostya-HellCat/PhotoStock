import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/ensure_visible.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    theme: new ThemeData(
      primaryColor: Colors.indigo[400],
    ),
    routes: {
      '/': (BuildContext context) => UserRoute(), //AuthRoute()
      '/reg': (context) => RegRoute(),
      '/user': (context) => UserRoute(),
    },
  ));
}

// Popup Auth Error route

class AuthErrorPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Авторизация не удалась. Пожалуйста, попробуйте позже.'),
              ]
          )),
      actions: [
        FlatButton(
          onPressed: () {Navigator.pop(context);},
          child: Text('Ок'),
        ),
      ],
    );
  }
}

class AuthNotFoundPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Пользователь с указанными данными не найден.'),
              ]
          )),
      actions: [
        FlatButton(
          onPressed: () {Navigator.pop(context);},
          child: Text('Ок'),
        ),
      ],
    );
  }
}

// MAIN AUTH ROUTE

class AuthRoute extends StatefulWidget {
  @override
  _AuthRouteState createState() => _AuthRouteState();
}

class UserData{

  //Рабочий логин = 'Katy' пасс = '123'

  String username = '';
  String password = '';
  String email = '';
  int id;
  String surname = '';
  String name = '';
  String gender = '';
  String databirth = '';
  String raiting = '';
  String avatar = '';
  var photo = <String>[];
}

class _AuthRouteState extends State<AuthRoute> {
  final _formKey = GlobalKey<FormState>();
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  UserData user = new UserData();


  req_auth() async {

    var response = await http.post('http://10.0.2.2:1337/auth', body: {'username' : user.username, 'password' : user.password});
    if (response.statusCode == 200){
      if (response.body == 'user_not_found'){
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => AuthNotFoundPopup()
        ));
      }
      else {
          //Successful Request
      }
    }
    else{
      Navigator.push(context, PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => AuthErrorPopup()
      ));
    }
    //response.body


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Авторизация"),
      ),
      //backgroundColor: Colors.indigo[400],
      //resizeToAvoidBottomPadding: false,
      //resizeToAvoidBottomInset: true,
      body: Container(
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 50, right: 50),
            children: <Widget>[
              EnsureVisibleWhenFocused(
                focusNode: _loginFocusNode,
                child: TextFormField(
                  focusNode: _loginFocusNode,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    //hintText: 'Логин или E-Mail',
                    labelText: 'Логин',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Пожалуйста, введите логин';
                    }
                  },
                  onSaved: (val) => user.username = val,
                ),
              ),
              EnsureVisibleWhenFocused(
                focusNode: _passwordFocusNode,
                child: TextFormField(
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    //hintText: 'Логин или E-Mail',
                    labelText: 'Пароль',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                  },
                    onSaved: (val) => user.password = val,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: RaisedButton(
                    onPressed: () {

                      if (_formKey.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar
                        _formKey.currentState.save();
                        req_auth();
                      }
                    },
                    child: Text('Войти'),
                  ),
                ),
              ),
              FlatButton(
                child: Text('Забыли пароль?'),
                onPressed: () {

                },
              ),
              FlatButton(
                child: Text('Регистрация'),
                onPressed: () {
                  Navigator.pushNamed(context, '/reg');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegRoute extends StatelessWidget {
  final _formKey2 = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context2) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: Builder(
        builder: (context2) => Center(
              child: Column(
                children: <Widget>[
                  Form(
                      key: _formKey2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.person),
                                labelText: 'Логин',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Пожалуйста, введите логин';
                                }
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.alternate_email),
                                labelText: 'E-mail',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Пожалуйста, введите E-mail';
                                }
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock),
                                labelText: 'Пароль',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                }
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.local_phone),
                                labelText: 'Телефон',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Пожалуйста, введите номер телефона';
                                }
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_formKey2.currentState.validate()) {
                                      // If the form is valid, we want to show a Snackbar
                                      Scaffold.of(context2).showSnackBar(
                                          SnackBar(
                                              content: Text('Обработка...')));
                                    }
                                  },
                                  child: Text('Зарегистрироваться'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
      ),
    );
  }
}

class UserRoute extends StatelessWidget {

  @override
  Widget build(BuildContext context3) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context3) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () { Scaffold.of(context3).openDrawer(); },
                tooltip: MaterialLocalizations.of(context3).openAppDrawerTooltip,
              );
            },
          ),
          title: Center(
            child: Text("Eclipse"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: 'Settings',
              //onPressed: (),
            ),
          ]
      ),
      drawer: Text('drawer'),
      body: Row(
        children: <Widget>[
          Expanded(
              child: Text('Raiting', textAlign: TextAlign.center)
          ),
          Expanded(
            child: RawImage(
              //Image: '',
            )

          ),
          Expanded(
              child: Text('Type', textAlign: TextAlign.center)
          ),
        ],
      ),
      //body: Builder(),
    );
  }
}