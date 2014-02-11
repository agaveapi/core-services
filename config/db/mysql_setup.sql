CREATE DATABASE 'agave-api';
USE 'agave-api';
CREATE USER 'agaveuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON 'agaveuser'.* TO 'newuser'@'localhost';
FLUSH PRIVILEGES;