#!/bin/bash

# Build binary for distribution.
#
# Usage:
#
#   ./build.sh [options] [platform ...]
#     -d <assets_dir>
#     -p              # packaging the binary
#
# Example:
#
#   ./build.sh linux/amd64
#   ./build.sh -d /usr/share/freedom-routes linux/amd64

VERSION=$(sed -rn 's/.*const VERSION.*"([0-9.]+)".*/\1/p' main.go)
FILES="routes/templates freedom-routes.etc README.md CHANGELOG.md"
#RELEASE="homebrew/amd64 homebrew/386 windows/386 windows/amd64"
RELEASE="homebrew/amd64 homebrew/386"

declare -A OS_MAP=(
	[homebrew]="darwin"
)

declare -A DIR_MAP=(
	[homebrew]="/usr/share/freedom-routes"
)

function cgo-enabled { [[ "$1" == "$GOHOSTOS" ]] && echo 1 || echo 0; }
function ext { [[ $1 == "windows" ]] && echo .exe || echo ""; }

# dist(platform, os, arch, assets_dir)
function dist {
	rm -r dist >/dev/null
	mkdir dist

	cp -r $FILES dist
	build $*
}

# build(platform, os, arch, assets_dir)
function build {
	platform=$1; os=$2; arch=$3; assets_dir=$4
	echo -e "\nbuilding $platform/$arch"

	sed -i "/const ASSETS_MODE/s~.*~const ASSETS_MODE = \"$assets_dir\"~" routes/routes.go
	CGO_ENABLED=$(cgo-enabled $os) GOOS=$os GOARCH=$arch $GOROOT/bin/go build -o "dist/freedom-routes$(ext $os)"
	sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "source"/' routes/routes.go
}

# package(platform, os, arch)
function package {
	platform=$1; os=$2; arch=$3;
	
	echo "packing $platform/$arch" 
	mkdir dist/freedom-routes-$VERSION
	cp -r dist/* dist/freedom-routes-$VERSION 2>/dev/null

	case $os in
		linux | darwin )
			tar zcvf freedom-routes.$platform.$arch-$VERSION.tar.gz -C dist freedom-routes-$VERSION;;
		windows ) 
			rm ../freedom-routes.$platform.$arch.zip 2>/dev/null
			cd dist && zip -r ../freedom-routes.$platform.$arch.zip freedom-routes-$VERSION && cd ..
			;;
	esac
}

function upload {
	for file in $*; do
		s3cmd put --acl-public $file s3://downloads.gutenye.com/freedom-routes/
		#current=$(echo $file | sed -r 's/(.*)-[0-9.]+(\..*)$/\1\2/')
		#s3cmd copy s3://downloads.gutenye.com/freedom-routes/$file s3://downloads.gutenye.com/freedom-routes/$current
	done
}

#
# main
# ----

eval "$(go env)"
ASSETS_DIR="runtime"
is_package=false

while getopts "d:p" opt; do
  case $opt in
    d ) ASSETS_DIR=$OPTARG ;;
		p ) is_package=true
  esac
done

shift $(( OPTIND-1 ))

case $1 in
	"" )
		dist $GOOS $GOOS $GOARCH $ASSETS_DIR
		[[ $is_package == true ]] && package $GOOS $GOOS $GOARCH
		;;
	release )
		GOROOT="/home/guten/dev/src/go/go"
		rm *.zip *.tar.gz 2>/dev/null
		for release in $RELEASE; do
			platform=${release%/*}; arch=${release#*/}; os=${OS_MAP[$platform]-$platform}
			assets_dir=${DIR_MAP[$platform]-$ASSETS_DIR}
			dist $platform $os $arch $assets_dir
			package $platform $os $arch
		done
		upload *.zip *.tar.gz
		;;
	upload )
		shift
		upload $*
		;;
	* )
		GOROOT="/home/guten/dev/src/go/go"
		platform=${1%/*}; arch=${1#*/}; os=${OS_MAP[$platform]-$platform}
		dist $platform $os $arch $ASSETS_DIR
		[[ $is_package == true ]] && package $platform $os $arch
		;;
esac

exit 0
