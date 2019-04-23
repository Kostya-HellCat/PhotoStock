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

app.post('/reg', function (req,res) {
    console.log('Поступил запрос по адресу /reg');

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

	pool.connect(function (err, client, done){
		if (err) {
			return console.error('error fetching client from pool', err)
		}
		
		pool.query('SELECT * FROM userinfo WHERE login = \''+req.fields.username+'\'', [], function (err, result) {
			if (err) {
			  return console.error('error happened during query', err)
			  res.sendStatus(400); //Bad query
			}
			if (result.rows[0] === undefined){
				
				pool.query('SELECT * FROM userinfo WHERE email = \''+req.fields.email+'\'', [], function (err, result) {
				
					if (err) {
					  return console.error('error happened during query', err)
					  res.sendStatus(400); //Bad query
					}
					if (result.rows[0] === undefined){
						
						pool.query('INSERT INTO userinfo (login,password,email,phone) VALUES (\''+req.fields.username+'\',\''+req.fields.password+'\',\''+req.fields.email+'\',\''+req.fields.phone+'\')', [], function (err, result) {
							done()
							if (err) {
							  return console.error('error happened during query', err)
							  res.sendStatus(400); //Bad query
							}
							
							user.login = req.fields.username;
							user.email = req.fields.email;
							user.phone = req.fields.phone;
							res.sendStatus(200);
						});
						
						}
					else {res.sendStatus(401)};
					pool.close;
				});
			
			}
			else{res.sendStatus(401);console.log('Рега неуспешна2')}
			pool.close;
			
		});	
		
		
	});	
});

// **********************************************************************************************************************
// **********************************************Добавление фото*********************************************************
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

// **********************************************************************************************************************
// **********************************************Получение фото**********************************************************
// **********************************************************************************************************************

app.post('/getphoto', function(req, res) {
    
    console.log('Поступил запрос по адресу /get_photo');
	
    var user = {
        id : "",
        photo : ['']
    };
	var i=0;

    // Поиск пользователя в БД. Если есть, то ключ session = 1.

	pool.connect(function (err, client, done){
			if (err) {
		return console.error('error fetching client from pool', err)
		}
		
		pool.query('SELECT * FROM photos WHERE author_id = \''+req.fields.user_id+'\'', [], function (err, result) {
		
		if (err) {
		  return console.error('error happened during query', err)
		  res.sendStatus(400); //Bad query
		}
		
		while (result.rows[i] !== undefined){
			user.photo[i]=result.rows[i].photo_src;
			console.log(result.rows[i].photo_src);
			user.photo[i] = result.rows[i].photo_src;
			i++;
		}
		
		res.status(200).send(user.photo);
		pool.close;
		});
	});
});
