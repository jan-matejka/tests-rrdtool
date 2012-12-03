testcase() {
	rrdtool fetch $DBFILE AVERAGE --start 920804400 --end 920809200
}
