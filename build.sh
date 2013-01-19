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
#   ./build.sh -d /usr/share/freedom-routes    # build with system go
#   ./build.sh release                         # build $RELEASEs with user complied go and upload the package to s3.

VERSION=$(sed -rn 's/.*const VERSION.*"([0-9.]+)".*/\1/p' main.go)
FILES="routes/templates freedom-routes.etc README.md CHANGELOG.md"
RELEASE="homebrew/amd64 homebrew/386 windows/386 windows/amd64"
declare -A OS_MAP=(
	[homebrew]="darwin"
)
declare -A DIR_MAP=(
	[homebrew]="/usr/share/freedom-routes"
)

platform=""
os=""
arch=""
assets_dir=""

function cgo_enabled { [ "$1" == "$GOHOSTOS" ] && echo 1 || echo 0; }
function ext { [ $1 == "windows" ] && echo .exe || echo ""; }

# dist{platform, os, arch, assets_dir}
function dist {
	rm -r dist 2>/dev/null
	mkdir dist

	cp -r $FILES dist
	build
}

# build{platform, os, arch, assets_dir}
function build {
	echo -e "\nbuilding $platform/$arch"

	sed -i "/const ASSETS_MODE/s~.*~const ASSETS_MODE = \"$assets_dir\"~" routes/routes.go
	CGO_ENABLED=$(cgo_enabled $os) GOOS=$os GOARCH=$arch $GOROOT/bin/go build -o "dist/freedom-routes$(ext $os)"
	sed -i '/const ASSETS_MODE/s/.*/const ASSETS_MODE = "source"/' routes/routes.go
}

# package{platform, os, arch}
function package {
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
# ¤main
# ----

eval "$(go env)"

o_assets_dir="runtime"
o_package=false
while getopts "d:p" opt; do
  case $opt in
    d ) o_assets_dir=$OPTARG ;;
		p ) o_package=true ;;
  esac
done
shift $(( OPTIND - 1 ))

case $1 in
	"" )
		platform=$GOOS; os=$GOOS; arch=$GOARCH; assets_dir=$o_assets_dir
		dist
		[ $o_package == true ] && package
		;;
	release )
		GOROOT="/home/guten/dev/src/go/go"
		rm *.zip *.tar.gz 2>/dev/null
		for release in $RELEASE; do
			platform=${release%/*}; arch=${release#*/}; os=${OS_MAP[$platform]-$platform}
			assets_dir=${DIR_MAP[$platform]-$o_assets_dir}
			dist
			package
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
		dist
		[ $o_package == true ] && package
		;;
esac

exit 0
