import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',

    theme: new ThemeData(
      primaryColor: Colors.indigo[400],
    ),
    routes: {
      '/':(BuildContext context) => AuthRoute(),
      '/reg':(context) => RegRoute()
    },
  ));
}

class AuthRoute extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  req_auth() async{
    var response = await http.post(
        'http://10.0.2.2:1337/auth',
        body: {'nickname': 'test', 'password': '10'});
    print(
        "Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Авторизация"),
      ),
      //backgroundColor: Colors.indigo[400],
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) => Center(
          child: Column(
            children: <Widget>[
              Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(left: 50,right: 50,top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextFormField(
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
                    ),
                    TextFormField(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: RaisedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              // If the form is valid, we want to show a Snackbar
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Обработка...')));
                              req_auth();
                            }
                          },
                          child: Text('Войти'),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
             FlatButton(
              child: Text('Забыли пароль?'),
              onPressed: () {
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegRoute()),
                ); */
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
                    padding: EdgeInsets.only(left: 50,right: 50,top: 50),
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
                            icon: Icon(Icons.local_phone ),
                            labelText: 'Телефон',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Пожалуйста, введите номер телефона';
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: RaisedButton(
                              onPressed: () {

                                if (_formKey2.currentState.validate()) {
                                  // If the form is valid, we want to show a Snackbar
                                  Scaffold.of(context2).showSnackBar(SnackBar(content: Text('Обработка...')));
                                }
                              },
                              child: Text('Зарегистрироваться'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}