#! /bin/sh

set -eu

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

	BASEDIR=/tmp/rrdtool_tests/`get_cur_version`

	test -d $BASEDIR && rm $BASEDIR -r
	echo "BASEDIR: $BASEDIR"

	OUTDIR=$BASEDIR/out
	LOGDIR=$BASEDIR/log
	for i in $OUTDIR $LOGDIR; do
		test -d $i || mkdir $i -p
	done

	for i in `dirname $0`/*\.test_*.sh; do
		echo "running $i"
		run $i
	done
}

main $@
