update mysql.user set host = '%' where user='polini';
flush privileges;