package routes

import (
	"bitbucket.org/kardianos/osext"
	"go/build"
)

func getAssetsPath(mode string) (dir string) {
	var err error

	switch mode {
	case "source":
		dir, err = getSourceDir()
	case "runtime":
		dir, err = osext.ExecutableFolder()
	default:
		dir = mode
	}

	if err != nil {
		panic(err)
	}
	return dir
}

func getSourceDir() (string, error) {
	p, err := build.Default.Import("github.com/GutenYe/freedom-routes/routes", "", build.FindOnly)

	return p.Dir, err
}
