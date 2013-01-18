#!/bin/bash

# Build
#
#   mkdir output
#   sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "runtime"/' routes/routes.go
#   go build -o output/freedom-routes
#   cp routes/templates output

# Build binary for distribution.
#
# Usage:
#
#   GOROOT=x ./build.sh [options] [platform ...]
#     -d <assets_dir>
#     -p              # packaging the binary
#
# Example:
#
#   ./build.sh linux/amd64                       # linux x64 platform
#   ./build.sh all                               # all platforms
#   ./build.sh -d /usr/share/freedom-routes linux/amd64

PLATFORMS="linux/386 linux/amd64 darwin/386 darwin/amd64 windows/386 windows/amd64"
ASSETS_DIR="runtime"

GOROOT=${GOROOT-/home/guten/dev/src/go/go}
eval "$($GOROOT/bin/go env)"

function cgo-enabled {
	if [ "$1" = "$GOHOSTOS" ]; then echo 1; else echo 0; fi
}

function build {
	os=${1%/*}
	arch=${1#*/}

	echo "building $os/$arch"

	sed -i "/const ASSETS_MODE/s~.*~const ASSETS_MODE = \"$ASSETS_DIR\"~" routes/routes.go
	CGO_ENABLED=$(cgo-enabled $os) GOOS=$os GOARCH=$arch $GOROOT/bin/go build -o "dist/freedom-routes.$os.$arch"
	ln -sf freedom-routes.$os.$arch dist/freedom-routes
	sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "source"/' routes/routes.go
}

function package {
	os=${1%/*}
	arch=${1#*/}
	
	echo "packing $os/$arch" 
	rm -r dist/freedom-routes/* 2>/dev/null

	cd dist
	cp -rL templates freedom-routes/
	ext=$([[ $os == "windows" ]] && echo .exe || echo "")
	cp freedom-routes.$os.$arch freedom-routes/freedom-routes$ext

	case $os in
		linux | darwin )
			tar zcvf freedom-routes.$os.$arch.tar.gz freedom-routes ;;
		windows ) 
			zip freedom-routes.$os.$arch.zip freedom-routes ;;
	esac
}

#
# main
# ----

if [ ! -d dist ]; then
	mkdir dist
	mkdir dist/freedom-routes
	ln -s ../routes/templates dist
fi

is_package=false

while getopts "d:p" opt; do
  case $opt in
    d ) ASSETS_DIR=$OPTARG ;;
		p ) is_package=true
  esac
done

shift $(( OPTIND-1 ))

case $1 in
	all )
		for platform in $PLATFORMS; do
			build $platform
			[[ $is_package == true ]] && package $platform
		done
		;;
	"" )
		build $GOOS/$GOARCH 
		[[ $is_package == true ]] && package $GOOS/$GOARCH
		;;
	* )
		build $1
		[[ $is_package == true ]] && package $GOOS/$GOARCH
		;;
esac
