var http             = require('http');
var url              = require('url');
var fs               = require('fs');
const express        = require('express');
const app            = express();
const bodyParser     = require('body-parser');
const formidable     = require('express-formidable');

app.use(bodyParser.urlencoded({extended: true}));

app.use(formidable({
    encoding: 'utf-8',
    uploadDir: 'upload',
    multiples: true
}));

app.listen(1337, function(){
    console.log('We are live on 1337');
  });

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});


// **********************************************************************************************************************
// **********************************************Авторизация*************************************************************
// **********************************************************************************************************************

app.post('/auth', function(req, res) {
    
    console.log('Поступил запрос по адресу /auth');

    var text = fs.readFileSync('database.json','UTF-8', function (err,data) {
        if (err) {
            console.error(err);
        }
        else {
            data.toString();
        }
    });

    var session = 0;
    var counter = 0;
    var id;
    var pjson = JSON.parse(text);
    var sjson;
    var user = {
        id : "",
        surename : "",
        name : "",
        nickname : "",
        email : "",
        password : "",
        gender : "",
        databirth : "",
        nphoto : "",
        rating : "",
        phototype : "",
        avatar : "",
        photo : []
    };

    // Поиск пользователя в БД. Если есть, то ключ session = 1.

    for (var key in pjson) {
        if (req.fields.username == pjson[key].nickname) {
            if (req.fields.password == pjson[key].password) {
                session = 1;
                id = key;
            }
            else session = 0;
        }
    }

    if (session == 1) {
        user.id = pjson[id].id;
        user.surename = pjson[id].surename;
        user.name = pjson[id].name;
        user.nickname = pjson[id].nickname;
        user.email = pjson[id].email;
        user.password = pjson[id].password;
        user.gender = pjson[id].gender;
        user.databirth = pjson[id].databirth;
        user.nphoto = pjson[id].nphoto;
        user.rating = pjson[id].rating;
        user.phototype = pjson[id].phototype;
        user.avatar = pjson[id].avatar;

        for (var key in pjson[id].photo) {
            user.photo[key] = pjson[id].photo[key];
        }

        sjson = JSON.stringify(user);
        console.log('Авторизирован пользователь '+user.nickname);
        res.send(sjson);
    }
    else{
        var err = '';
        res.send(err);
    }



});

// **********************************************************************************************************************
// ********************************************Регистрация***************************************************************
// **********************************************************************************************************************

app.post('/register', function (req,res) {
    console.log('Поступил запрос по адресу /register');

  var text = fs.readFileSync('database.json','UTF-8', function (err,data) {
    if (err) {
      console.error(err);
    }
    else {
      data.toString();
    }
  });

  var pjson = JSON.parse(text);

  // Достаем ID последнего пользователя
  var counter = 0;

  for (var maxid in pjson) {
  counter++;
  }

  // Создаем нового пользователя
        pjson.push({});
        pjson[counter].id = counter;
        pjson[counter].surename = req.fields.lname;
        pjson[counter].name = req.fields.fname;
        pjson[counter].nickname = req.fields.nname;
        pjson[counter].email = req.fields.mail;
        pjson[counter].password = req.fields.pass;
        pjson[counter].gender = req.fields.gen;
        pjson[counter].databirth = req.fields.dat;
        pjson[counter].nphoto = 0;
        pjson[counter].rating = 0;
        pjson[counter].phototype = req.fields.phototype;
        pjson[counter].avatar = "photo/noavatar.png";
        pjson[counter].photo = [];

        var sjson= "";

        sjson = JSON.stringify(pjson);
    fs.unlink('database.json');
    fs.appendFile('database.json', sjson, 'utf8', function (err,data) {
        if (err) {
            console.error(err);
        }
        else {
            var ans = "Пользователь "+pjson[counter].nickname+" успешно зарегестрирован!";
            res.send(ans);
        }
    });
    console.log('Зарегестрирован новый пользователь');
    console.log('id  | SureName  | FirstName  |  NickName');
    console.log(pjson[counter].id + '  |  ' + pjson[counter].surename + '  |  ' + pjson[counter].name + '  |  ' + pjson[counter].nickname);
});

// **********************************************************************************************************************
// **********************************************Добавлени фото**********************************************************
// **********************************************************************************************************************

app.post('/upload', function(req, res){
    console.log('Поступил запрос по адресу /upload');

    var text = fs.readFileSync('database.json','UTF-8', function (err,data) {
        if (err) {
            console.error(err);
        }
        else {
            data.toString();
        }
    });

    var pjson = JSON.parse(text);

    // Ищем пользвателя по ID и записываем новое фото после имеющихся

    var counter = 0;

    for (var maxphoto in pjson[req.fields.id].photo) {
        counter++;
    }
    maxphoto = maxphoto+1;
    
    pjson[req.fields.id].photo.push(req.files.upfile.path);

    var sjson= "";
    sjson = JSON.stringify(pjson);
    fs.unlink('database.json');
    fs.appendFile('database.json', sjson, 'utf8', function (err,data) {
        if (err) {
            console.error(err);
        }
        else {
            var ans = "Фоторгафия успешно добавлена! Что бы увидеть фото перезайдите в ваш аккаунт.";
            res.send(ans);
        }
    });
    
});
