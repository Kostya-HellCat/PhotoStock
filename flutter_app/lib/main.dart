import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/ensure_visible.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  String phone = '';
}

class _AuthRouteState extends State<AuthRoute> {
  final _formKey = GlobalKey<FormState>();
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  UserData user = new UserData();


  req_auth() async {

    var response = await http.post('http://10.0.2.2:1337/auth', body: {'username' : user.username, 'password' : user.password});
    print(response.statusCode);
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
  UserData user = new UserData();

  req_reg(context) async {

    var response = await http.post('http://10.0.2.2:1337/reg', body: {'username' : user.username, 'password' : user.password, 'email' : user.email, 'phone' : user.phone});
    print(response.statusCode);
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
                              onSaved: (val) => user.username = val,
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
                              onSaved: (val) => user.email = val,
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
                              onSaved: (val) => user.password = val,
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
                              onSaved: (val) => user.phone = val,
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
              onPressed: (){
                Navigator.push(context3, PageRouteBuilder(
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
          Navigator.push(context3, new MaterialPageRoute(
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
                    child: Text('Raiting', textAlign: TextAlign.center)
                ),
            CircleAvatar(
            backgroundImage: NetworkImage("https://pp.userapi.com/c633328/v633328661/23637/o0dWWCQLTcw.jpg"),
                radius: 40,/*image: DecorationImage(
                  image: AssetImage('avatars/avatar_1.jpg');
                ),*/
                ),
                Expanded(
                    child: Text('Type', textAlign: TextAlign.center)
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

class PhotoList extends  State<MyBody> {
  List<String> _photo = [];

  @override
  Widget build(BuildContext context) {

    return new GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4,crossAxisSpacing: 3.0, mainAxisSpacing: 1.0),
        itemBuilder: (context3, i) {
      final int index = i ~/ 2;


      print('index $index'); // Что бы понимать, что программа не сдохла
      print('length ${_photo.length}'); // Что бы понимать, что программа не сдохла

      if (index >= _photo.length) _photo.addAll([
        'https://pp.userapi.com/c633328/v633328661/23637/o0dWWCQLTcw.jpg',
        'https://pp.userapi.com/c633328/v633328661/23637/o0dWWCQLTcw.jpg',
        'https://pp.userapi.com/c633328/v633328661/23637/o0dWWCQLTcw.jpg'
      ]);

      return new GridTile(child: new Image.network(_photo[index]));

    });
  }
}

class AddPhotoRoute extends StatelessWidget {
  @override

  Widget build(BuildContext context4) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context3) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context3);
                },
                tooltip: MaterialLocalizations.of(context3).openAppDrawerTooltip,
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