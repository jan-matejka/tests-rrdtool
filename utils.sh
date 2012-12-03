get_cur_version() {
	zypper se -s rrdtool | grep '^i | rrdtool ' | cut -d '|' -f 4 | sed 's/\s//g'
}

run() {
	local log_file
	. $1

	log_file=$LOGDIR/`basename $1`.log
	testcase > $log_file
}
