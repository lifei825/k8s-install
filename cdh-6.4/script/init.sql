create database cdh DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
create database scm DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
grant all privileges on cdh.* to 'cdh_admin'@'%' identified by 'cdh_admin' with grant option;
grant all privileges on scm.* to 'scm_admin'@'%' identified by 'scm_admin' with grant option;
flush privileges;