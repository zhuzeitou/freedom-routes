## 编译

Update dependencies

```
$ go get -u
$ go install
$ freedom-routes linux
```

```
$ mkdir output
$ sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "runtime"/' routes/routes.go
$ go build -o output/freedom-routes
$ cp -r routes/templates output
```

Debug: $ freedom-routes

Development: use SOURCE/templates
Production: use /usr/share/freedom-routes
            windows: current directory

## 部署

```
$ Setup Cross-Compilation Enviroment, in ~/dev/src/go/go
$ ./ake deploy

(in target server)

# apt install zip
# cd /app/freedom-routes
# ln -s `pwd`/freedom-routes /usr/bin
# cp systemd/*.{service,timer} /etc/systemd/system

$ mkdir dist && cd dist
$ git init
$ git checkout -b dist
$ git remote add origin URL
$ git push -u origin dist

# systemctl start freedom-routes.timer
# systemctl enable freedom-routes.timer
```
