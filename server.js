var http             = require('http');
var url              = require('url');
var fs               = require('fs');
const express        = require('express');
const app            = express();
const formidable     = require('express-formidable');
const shortid = require('shortid');
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
	var i = 0;
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
        photo_count: 0,
		photo : []
    };

    // Поиск пользователя в БД. Если есть, то ключ session = 1.

	pool.connect(function (err, client, done){
			if (err) {
		return console.error('error fetching client from pool', err)
		}
		
		pool.query('SELECT * FROM userinfo WHERE login = \''+req.fields.username+'\'', [], function (err, result) {
		if (err) {
		  return console.error('error happened during query', err)
		  res.sendStatus(400); //Bad query
		}
		
		if (result.rows[0] !== undefined){
			if (result.rows[0].password == req.fields.password){
							
				user.id = result.rows[0].id;
				user.firstname = result.rows[0].firstname;
				user.lastname = result.rows[0].lastname;
				user.email = result.rows[0].email;
				user.phone = result.rows[0].phone;
				user.phototype = result.rows[0].phototype;
				user.birthdate = result.rows[0].birthdate;
				user.raiting = result.rows[0].raiting;
				user.avatar_src = result.rows[0].avatar_src;
				
				pool.query('SELECT COUNT(*) FROM photos WHERE author_id = '+user.id, [], function (err, result) {
					
					if (err) {
						return console.error('error happened during query', err)
						res.sendStatus(400); //Bad query
					}
			
					if (result.rows[0].count != undefined){
						user.photo_count = result.rows[0].count;

						pool.query('SELECT * FROM photos WHERE author_id = \''+user.id+'\'', [], function (err, result) {
						
						while (result.rows[i] != undefined){
							user.photo[i] = result.rows[i].photo_src;
							i++;
						}
						
						res.status(200).send(user); //Авторизация
						console.log('Авторизирован пользователь '+user.id);	
						});
		
					}
				
				});
			}
			else {
				//Неудачный пароль
				res.sendStatus(401); // Unauthorized
		}}
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
			else{res.sendStatus(401);}
			pool.close;
			
		});	
		
		
	});	
});

// **********************************************************************************************************************
// **********************************************Добавление фото*********************************************************
// **********************************************************************************************************************

function getExtension(filename) {
    var i = filename.lastIndexOf('.');
    return (i < 0) ? '' : filename.substr(i);
}

app.post('/upload', function(req, res){
    console.log('Поступил запрос по адресу /upload');


  var name = req.fields.name
  var hashname = shortid.generate()+shortid.generate()+getExtension(name);
  var img = req.fields.image;
  var realFile = Buffer.from(img,"base64");
  
  fs.writeFile('img\\'+hashname, realFile, function(err) {
      if(err)
         console.log(err);
   });
	
	pool.connect(function (err, client, done){
			if (err) {
		return console.error('error fetching client from pool', err)
		}
		
		pool.query('INSERT INTO photos (author_id,photo_name,photo_price,photo_src) VALUES ('+req.fields.user_id+',\''+req.fields.photo_name+'\',\''+req.fields.photo_cost+'\',\''+hashname+'\')', [], function (err, result) {
		if (err) {
		  return console.error('error happened during query', err)
		  res.sendStatus(400); //Bad query
		}
		else{
		res.status(200).send(hashname);
		}
	pool.close;
		});
	});
});
	

// **********************************************************************************************************************
// **********************************************Получение фото**********************************************************
// **********************************************************************************************************************

app.get('/img', function(req, res) {
	console.log('Поступил запрос по адресу /img');

console.log(req.query);
	if (req.query.photo_name !== undefined){
			res.sendFile(__dirname+'\\img\\'+req.query.photo_name);
		}
		else{
			res.sendStatus(401); // Empty result
		}
});