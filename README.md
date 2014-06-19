freedom-routes, chnroutes的改进版本, 大幅提升VPN浏览国内网页速度.
================================================================

|                |                                                             |
|----------------|------------------------------------------------------       |
| 主页:          | https://github.com/GutenYe/freedom-routes        |
| 作者:	         | Guten                                            |
| 版权:          | MIT-LICENSE                                                |
| 提交Bug:       | https://github.com/GutenYe/freedom-routes/issues |
| 平台:          | Linux, Mac OS X, Windows, OpenWRT                         |

生成一个可以运行的脚本, 当VPN运行的时候, 自动添加国内的IP地址到系统路由表, 直接连接访问国内的网站, 用VPN访问国外的网站, 从而提升网页浏览速度. (例如: 使用前ping baidu.com是300ms延迟, 使用后可以减少到30ms)

## 对chnroutes的改进

1. Linux下导入路由的速度更快
2. 支持模板, 可以自定义脚本
3. Go语言写, 单exe运行文件

## 使用方法

**Usage**:

	$ freedom-routes [options] <template>
      -o, --output="."                 # output directory

查看所有的[模板](https://github.com/GutenYe/freedom-routes/tree/master/routes/templates)

**Linux (OpenVPN)**

	# freedom-routes linux -o /etc/openvpn
	# edit /etc/openvpn/foo.conf

		script-security 2
		up ./routes-up.sh
		down ./routes-down.sh

**Mac OS X**

	$ freedom-routes mac
	# ./routes-up.sh

**Windows**

	$ freedom-routes windows
	# ./routes-up.bat

**OpenWRT**

TBA

**RouterOS**

	$ freedom-routes routeros

* upload freedomroutes.rsc via winbox/WebConsole/ssh/ftp
* get into your router terminal, type `/import freedomroutes.rsc`
* add a default route with `routing-mark` set to `freedomroutes.domestic`
* see `/ip route rule print` for more details..

Others, see documentation at [here](https://github.com/GutenYe/chnroutes/blob/master/README.md) (Chinese)

**Add IPs from local**

	# create /etc/freedom-routes
		70.33.217.1/32

**自动更新**

这些ip数据不是固定不变的, 尽管变化不大, 但还是建议每隔两三个月更新一次.

(Linux)

	$ create /etc/cron.weekly/freedom-routes with 0755 mode

		#!/bin/bash

		freedom-routes linux -o /etc/openvpn


## 安装

- ArchLinux: `yaourt -S freedom-routes` # install [freedom-routes](https://aur.archlinux.org/packages/freedom-routes/) from AUR
- Mac OS X: `brew tap gutenye/alt; brew install freedom-routes`
- Windows: 下载[x64](http://downloads.gutenye.com/freedom-routes/freedom-routes.windows.amd64.zip)(64位), [x86](http://downloads.gutenye.com/freedom-routes/freedom-routes.windows.386.zip)(32位)


# 开发

Build
------

	$ mkdir output
	$ sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "runtime"/' routes/routes.go
	$ go build -o output/freedom-routes
	$ cp -r routes/templates output

## 任何人都可以帮助这个项目

- Submit any bugs/features/ideas to github issue tracker.

Please see [Contibution Documentation](https://github.com/GutenYe/freedom-routes/blob/master/CONTRIBUTING.md).

A list of [Contributors](https://github.com/GutenYe/freedom-routes/contributors).

## 版权

(the MIT License)

Copyright (c) 2013 Guten

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
