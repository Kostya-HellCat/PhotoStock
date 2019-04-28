import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/ensure_visible.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    theme: new ThemeData(
      primaryColor: Colors.indigo[400],
    ),
    routes: {
      '/': (BuildContext context) => AuthRoute(), //Main route
      '/reg': (BuildContext context) => RegRoute(),
      '/user': (context) => UserRoute(),
      '/addphoto': (context) => AddPhotoRoute(),
    },
  ));
}

// Popups

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

class RegErrorPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Регистрация не удалась. Пожалуйста, попробуйте позже.'),
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
                Text('Неверные логин или пароль.'),
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

class RegLoginErrPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Пользователь с таким логином или email уже существует.'),
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

class MyBody extends StatefulWidget {
  @override
  createState() => new PhotoList();
}

class UserData{

  static int id;
  static String username = '';
  static String password = '';
  static String email = '';
  static String surname = '';
  static String name = '';
  static String gender = '';
  static String databirth = '';
  static int raiting;
  static String avatar = '';
  static String phone = '';
  static var photo;

  static final _changedStreamController = StreamController<UserDataState>.broadcast();
  static Stream<UserDataState> get userDataState => _changedStreamController.stream;
  static void updated() {
    //notify listeners with new state
    _changedStreamController.sink.add(UserDataState());
  }
}

class UserDataState {}

class _AuthRouteState extends State<AuthRoute> {
  final _formKey = GlobalKey<FormState>();
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  //UserData user = new UserData();

  get_photo(context) async {
    var response = await http.post('http://10.0.2.2:1337/getphoto', body: {'user_id' : UserData.id.toString()});

    if (response.statusCode == 200){
      UserData.photo = json.decode(response.body);
      UserData.updated();
    }
    else {
      //error or bad photoKaty
    }
  }

  req_auth() async {

    var response = await http.post('http://10.0.2.2:1337/auth', body: {'username' : UserData.username, 'password' : UserData.password});

    Map<String, dynamic> _jsonMap = json.decode(response.body);

    UserData.id = _jsonMap['id'];
    UserData.email = _jsonMap['email'];
    UserData.surname = _jsonMap['lastname'];
    UserData.name = _jsonMap['firstname'];
    UserData.databirth = _jsonMap['birthdate'];
    UserData.raiting = _jsonMap['raiting'];
    UserData.avatar = _jsonMap['avatar_src'];
    UserData.phone = _jsonMap['phone'];

      if (response.statusCode == 200){
        get_photo(context).whenComplete(
            Navigator.push(context, PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => UserRoute()
            ))
        );
        return UserData.photo;
      }
      else {
      if (response.statusCode == 401){
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => AuthNotFoundPopup()
        ));

      }
      else{
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => AuthErrorPopup()
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Авторизация"),
      ),
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
                  onSaved: (val) => UserData.username = val,
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
                    onSaved: (val) => UserData.password = val,
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
  //UserData user = new UserData();

  req_reg(context) async {

    var response = await http.post('http://10.0.2.2:1337/reg', body: {'username' : UserData.username, 'password' : UserData.password, 'email' : UserData.email, 'phone' : UserData.phone});
    if (response.statusCode == 200){
      Navigator.push(context, PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) => UserRoute()
    ));

    }
    else {
      if (response.statusCode == 401){
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => RegLoginErrPopup()
        ));

      }
      else{
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => RegErrorPopup()
        ));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: Builder(
        builder: (context) => Center(
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
                              onSaved: (val) => UserData.username = val,
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
                              onSaved: (val) => UserData.email = val,
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
                              onSaved: (val) => UserData.password = val,
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
                              onSaved: (val) => UserData.phone = val,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_formKey2.currentState.validate()) {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text('Обработка...')));
                                              _formKey2.currentState.save();
                                    }
                                    req_reg(context);
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () { Scaffold.of(context).openDrawer(); },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
              onPressed: (){
                Navigator.push(context, PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) => AuthRoute()
                ));
              },
            ),
          ]
      ),
      drawer: Text('drawer'), //левая навигация
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) =>
              new AddPhotoRoute())
          );
        },
        child: Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: <Widget>[
          Row(
              children: <Widget>[
                Expanded(
                    child: Column(
                      children: <Widget>[

                        Text('Рейтинг', textAlign: TextAlign.center),
                        Text(UserData.raiting.toString(), textAlign: TextAlign.center),
                      ]
                    )
                ),
            CircleAvatar(
            backgroundImage: NetworkImage(UserData.avatar),
                radius: 40,/*image: DecorationImage(
                  image: AssetImage('avatars/avatar_1.jpg');
                ),*/
                ),
                Expanded(
                    child: Column(
                        children: <Widget>[
                          Text('Тип фотографий', textAlign: TextAlign.center),
                          Text('', textAlign: TextAlign.center),
                        ]
                    )
                ),
              ],
            ),
          new Divider(),
          Row(
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  color: Colors.grey[400],
                  child: Text('Продано', textAlign: TextAlign.center),
                  onPressed: () {
                  },
                ),
                FlatButton(
                  color: Colors.grey[400],
                  child: Text('Куплено', textAlign: TextAlign.center),
                  onPressed: () {
                  },
                  padding: EdgeInsets.symmetric(horizontal: 50),
                ),
              ],
            ),
          Expanded(
            child: new MyBody()
            )
          ]
        ),
      ),
      ),
      //body: Builder(),
    );
  }
}

class PhotoList extends State<MyBody> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserDataState>(
        stream: UserData.userDataState,
        initialData: UserDataState(),
        builder: (context, snapshot) {
          //snapshot - UserState, we may get some data from it
          if (UserData.photo != null) {
            int j = -1;
            return new GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 3.0, mainAxisSpacing: 1.0,),
              itemCount: UserData.photo.length,
              itemBuilder: (context, i) {
                j++;
                return new GridTile(child: new Image.network(UserData.photo[j]));
              });
          } else return new Container(
              width: 0.0,
              height: 0.0,
              child: Center(
                child: Text('Loading...') // CircularProgressIndicator
              )
          );
        }
    );
  }
}

class AddPhotoRoute extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: Center(
            child: Text("Добавить фото"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info),
              tooltip: 'Settings',
              //onPressed: (),
            ),
          ]
      ),
      body: Builder(
        builder: (context) => Center(
          child: Text('new photo')
      )
    )
    );
  }
}