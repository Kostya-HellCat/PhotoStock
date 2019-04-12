var http             = require('http');
var url              = require('url');
var fs               = require('fs');
const express        = require('express');
const app            = express();
const formidable     = require('express-formidable');
const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'users',
  password: '123',
})

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
	
    var session = 0;
    var counter = 0;
    var id;
    var user = {
        id : "",
        firstname : "",
        lastname : "",
        email : "",
		phone : "",
		phototype : "",
        birthdate : "",
        raiting : 0.00,
        avatar_src:  "",
        photo : []
    };

    // Поиск пользователя в БД. Если есть, то ключ session = 1.

	pool.connect(function (err, client, done){
			if (err) {
		return console.error('error fetching client from pool', err)
		}
		
		pool.query('SELECT * FROM userinfo WHERE login = \''+req.fields.username+'\'', [], function (err, result) {
		done()
		if (err) {
		  return console.error('error happened during query', err)
		  res.sendStatus(400); //Bad query
		}
		
		if (result.rows[0] !== undefined){
			if (result.rows[0].password == req.fields.password){
							
				session = 1;
				user.id = result.rows[0].id;
				user.firstname = result.rows[0].firstname;
				user.lastname = result.rows[0].lastname;
				user.email = result.rows[0].email;
				user.phone = result.rows[0].phone;
				user.phototype = result.rows[0].phototype;
				user.birthdate = result.rows[0].birthdate;
				user.raiting = result.rows[0].raiting;
				user.avatar_src = result.rows[0].avatar_src;
				
				res.status(200).send(user); //Авторизация
				
				console.log('Авторизирован пользователь '+user.id);
				
			}
			else {
				//Неудачный пароль
				res.sendStatus(401); // Unauthorized
			}
		}
		else{
			//Неудачный логин
			res.sendStatus(401); // Unauthorized
		}
	
		pool.close;
		});
	});
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