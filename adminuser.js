db = connect('mongodb://localhost/admin');
db.createUser({ user: "mongoadmin", pwd: "ditpass", roles: [{ role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" }] })