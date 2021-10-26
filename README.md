# memo application "memorin"
A simple memo app created with Sinatra.
It has memo creation, editing, deleting, and listing functions.
## Install
```
$ git clone https://github.com/aim2bpg/memorin.git
$ cd memorin
$ bundle install
```
## Run server (storage:File, detail:PStore Class)
```
$ rackup
```
Access the following url in your browser. http://localhost:9292/
## Run server (storage:DB, detail:PostgreSQL)
```
createdb -O *db_owner_name* memos_db
$ rackup -E production
```
Access the following url in your browser. http://localhost:9292/
