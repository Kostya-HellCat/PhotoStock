var http             = require('http');
var url              = require('url');
var fs               = require('fs');
const express        = require('express');
const app            = express();
const formidable     = require('express-formidable');

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
            else {
			session = 0;
			}
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
        var err = 'user_not_found';
        res.send(err);
    }



});