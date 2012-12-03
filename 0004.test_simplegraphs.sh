testcase() {
	rrdtool graph $OUTDIR/speed.png \
		--start 920804400 --end 920808000 \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		LINE2:myspeed#FF0000

	rrdtool graph $OUTDIR/speed2.png \
		--start 920804400 --end 920808000 \
		--vertical-label m/s \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		CDEF:realspeed=myspeed,1000,* \
		LINE2:realspeed#FF0000
}
