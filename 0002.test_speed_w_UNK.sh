
DBFILE=$BASEDIR/speed_w_UNK.rrd

testcase() {
	# This test case demonstrates a graph which contains
	# data with value zero (12:10 to 12:20)
	# and missing data (12:20 - 12:35)
	# which should be distinguishable

	echo "create"
	rrdtool create $DBFILE \
		--start 920804400 \
		DS:speed:COUNTER:600:U:U \
		RRA:AVERAGE:0.5:1:24 \
		RRA:AVERAGE:0.5:6:10


	upd() {
		rrdtool update $DBFILE 9208$1
	}
	echo "update"
	upd 04700:0
	upd 05000:13
	upd 05300:20
	upd	05600:20
	#upd 05900
	#upd 06200
	upd 06500:32
	upd 06800:40

	echo "fetch"
	rrdtool fetch $DBFILE AVERAGE --start 920804400 --end 920809200

	echo "graph1"
	rrdtool graph $OUTDIR/speed_w_UNK1.png \
		--start 920804400 --end 920808000 \
		--vertical-label m/s \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		CDEF:realspeed=myspeed,1000,* \
		LINE2:realspeed#FF0000

	echo "graph2"
	rrdtool graph $OUTDIR/speed_w_UNK2.png \
		--start 920804400 --end 920808000 \
		--vertical-label km/h \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		"CDEF:kmh=myspeed,3600,*" \
		CDEF:fast=kmh,100,GT,kmh,0,IF \
		CDEF:good=kmh,100,GT,0,kmh,IF \
		HRULE:100#0000FF:"Maximum allowed" \
		AREA:good#00FF00:"Good speed" \
		AREA:fast#FF0000:"Too fast"
}
