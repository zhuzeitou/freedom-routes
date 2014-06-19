#!/bin/sh

export PATH="/bin:/sbin:/usr/sbin:/usr/bin"
OLDGW=`route -n get default | grep gateway | awk '{print $2}'`

{{range $i, $ip := .Ips}}route delete {{$ip.Ip}}/{{$ip.Cidr}} "${OLDGW}"
{{end}}
