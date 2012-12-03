testcase() {
	rrdtool create $DBFILE \
		--start 920804400 \
		DS:speed:COUNTER:600:U:U \
		RRA:AVERAGE:0.5:1:24 \
		RRA:AVERAGE:0.5:6:10
}
