import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/ensure_visible.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:css_colors/css_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      '/addphoto': (context) => PhotoRoute(),
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

class PhotoErrorPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Фотография не выбрана.'),
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

class PhotoOkPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Успех'),
      content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                Text('Фотография успешно загружена'),
              ]
          )),
      actions: [
        FlatButton(
          onPressed: () {Navigator.pop(context);Navigator.pop(context);},
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
  static var photo = [];
  static int photoCount;

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

  req_auth() async {

    var response = await http.post('http://192.168.1.37:1337/auth', body: {'username' : UserData.username, 'password' : UserData.password});

    if (response.statusCode == 200){
      Map<String, dynamic> _jsonMap = json.decode(response.body);

      UserData.id = _jsonMap['id'];
      UserData.email = _jsonMap['email'];
      UserData.surname = _jsonMap['lastname'];
      UserData.name = _jsonMap['firstname'];
      UserData.databirth = _jsonMap['birthdate'];
      UserData.raiting = _jsonMap['raiting'];
      UserData.avatar = _jsonMap['avatar_src'];
      UserData.phone = _jsonMap['phone'];
      UserData.photoCount = int.parse(_jsonMap['photo_count']);
      UserData.photo = _jsonMap['photo'];

      Navigator.push(context, PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => UserRoute()
      ));

      return UserData;
    }
    else {
        Navigator.push(context, PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => AuthNotFoundPopup()
        ));
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

    var response = await http.post('http://192.168.1.37:1337/reg', body: {'username' : UserData.username, 'password' : UserData.password, 'email' : UserData.email, 'phone' : UserData.phone});
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
              new PhotoRoute())
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

          if (UserData.photoCount != null) {
            if (UserData.photoCount == 0){
              return new Container(
                width: 0.0,
                height: 0.0,
              );
            }else{
            return new GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 3.0, mainAxisSpacing: 1.0,),
                itemCount: UserData.photoCount,
                itemBuilder: (context, i) {
                  //i++;
                  return new GridTile(child: new Image.network('http://192.168.1.37:1337/img?photo_name=${UserData.photo[i]}'));
                });
            }
          } else {
              return new Container(
                  width: 50.0,
                  height: 50.0,
                    child: new Center(
                      child: new CircularProgressIndicator()
                    )
              );
            }
        }
    );
  }
}

class PhotoRoute extends StatefulWidget {
  @override
  PhotoRouteState createState() => PhotoRouteState();
}

class PhotoRouteState extends State<PhotoRoute> {
  final _formKey3 = GlobalKey<FormState>();
  var photo = {
    'name' : '',
    'cost' : '',
    'tags' : ''
  };

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  void _upload() {
    if (_image == null) return;
    String base64Image = base64Encode(_image.readAsBytesSync());
    String fileName = _image.path.split("/").last;

    http.post('http://192.168.1.37:1337/upload', body: {
      'user_id': UserData.id.toString(),
      'image': base64Image,
      'name': fileName,
      'photo_name': photo['name'],
      'photo_cost': photo['cost'],
      'photo_tags': photo['tags'],
    }).then((res) {
      return res.statusCode;
    }).catchError((err) {
      print(err);
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: Icon(Icons.image),
        ),
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
                child:  Form(
                    key: _formKey3,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50, top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.mode_edit),
                              labelText: 'Название',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Пожалуйста, введите название';
                              }
                            },
                            onSaved: (val) => photo['name'] = val,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.monetization_on),
                              labelText: 'Цена',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Пожалуйста, введите цену';
                              }
                            },
                            onSaved: (val) => photo['cost'] = val,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.vpn_key),
                              labelText: 'Ключевые слова',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Пожалуйста, введите ключевые слова через зяпятую';
                              }
                            },
                            onSaved: (val) => photo['tags'] = val,
                          ),
                          //FileFormField(),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: _image == null
                                ? Text('Выберите фотографию')
                                : Image.file(_image), // если надо отображать фото
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: RaisedButton(
                                onPressed: () {
                                  if (_formKey3.currentState.validate()) {
                                    if (_image != null) {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text('Обработка...')));
                                      _formKey3.currentState.save();
                                      _upload();
                                          Navigator.push(context, PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (BuildContext context, _, __) => PhotoOkPopup()
                                          ));
                                    }
                                    else{
                                      Navigator.push(context, PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (BuildContext context, _, __) => PhotoErrorPopup()
                                      ));
                                    }
                                  }
                                  //req_reg(context);
                                },
                                child: Text('Загрузить'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
            )
        )
    );
  }
}