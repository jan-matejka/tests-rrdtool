get_cur_version() {
	zypper se -s rrdtool | grep '^i | rrdtool ' | cut -d '|' -f 4 | sed 's/\s//g'
}

run() {
	local log_file dir
	. $1

	dir=/tmp/rrdtool_`get_cur_version`
	test -d $dir || mkdir $dir

	log_file=$dir/`basename $1`.log
	testcase > $log_file
}
