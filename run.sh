#! /bin/sh

. `dirname $0`/utils.sh

main() {
	while getopts x name
	do
		case $name in
			x) set -x;;
			?) usage
		esac
	done

	shift $((OPTIND - 1))

	DBFILE=/tmp/test.rrd

	for i in `dirname $0`/*\.test_*.sh; do
		run $i
	done
}

main $@
