package main

import (
	"./routes"
	"fmt"
	"github.com/ogier/pflag"
	"os"
)

const VERSION = "1.0.0"

var USAGE = `
$ freedom-routes [options] <template>

OPTIONS:
	-o, --output="."                 # output directory
	-h, --help
	--version
`

func genRoutes(templateName string, outputDir string) {
	ips := routes.FetchIps()
	routes.Generate(templateName, ips, outputDir)
}

func main() {
	pflag.Usage = func() {
		fmt.Fprintf(os.Stderr, USAGE)
	}

	var output = pflag.StringP("output", "o", ".", "output directory")
	var version = pflag.BoolP("version", "", false, "version")
	pflag.Parse()

	if *version {
		fmt.Println(VERSION)
	} else if pflag.NArg() == 1 {
		genRoutes(pflag.Arg(0), *output)
	} else {
		pflag.Usage()
	}
}
