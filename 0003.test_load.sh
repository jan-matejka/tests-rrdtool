#! /usr/bin/env bash

DBFILE=$BASEDIR/load.rrd

testcase() {
	# The same as speed test but uses GAUGE instead of COUNTER
	START=920804400
	echo "create"
	rrdtool create $DBFILE \
		--start $START \
		DS:load:GAUGE:600:0:10 \
		RRA:AVERAGE:0.5:1:24 \
		RRA:AVERAGE:0.5:6:10

	upd() {
		rrdtool update $DBFILE 9208$1
	}
	echo "update"
	upd 04700:0.6
	upd 05000:0.2
	upd 05300:0.6
	upd 05600:1.0 # this one touches the HRULE limit on graph2
	upd 05900:1.2
	upd 06200:1.2
	upd 06500:0.2
	upd 06800:0.2
	# upd 07100: # missing data
	# upd 07400:0.1
	upd 07700:0.3
	upd 08000:0.2
	upd 08300:0.2
	upd 08600:0.0 # zero value data
	upd 08900:0.3

	END=920809000

	echo "fetch"
	rrdtool fetch $DBFILE AVERAGE --start $START --end $END

	echo "graph1"
	rrdtool graph $OUTDIR/load1.png \
		--start $START --end $END \
		--vertical-label load \
		DEF:myload=$DBFILE:load:AVERAGE \
		LINE2:myload#FF0000

	LIMIT=1

	echo "graph2"
	rrdtool graph $OUTDIR/load2.png \
		--start $START --end $END \
		--vertical-label km/h \
		DEF:myload=$DBFILE:load:AVERAGE \
		CDEF:lot=myload,$LIMIT,GT,myload,0,IF \
		CDEF:good=myload,$LIMIT,GT,0,myload,IF \
		HRULE:$LIMIT#0000FF:"Maximum allowed" \
		AREA:good#00FF00:"Good load" \
		AREA:lot#FF0000:"Too much"

	echo "graph3"
	rrdtool graph $OUTDIR/load3.png \
		--start $START --end $END \
		--vertical-label km/h \
		DEF:myload=$DBFILE:load:AVERAGE \
		CDEF:fast=myload,$LIMIT,GT,$LIMIT,0,IF \
		CDEF:over=myload,$LIMIT,GT,myload,$LIMIT,-,0,IF \
		CDEF:good=myload,$LIMIT,GT,0,myload,IF \
		HRULE:$LIMIT#0000FF:"Maximum allowed" \
		AREA:good#00FF00:"Good load" \
		AREA:fast#550000:"Too much" \
		STACK:over#FF0000:"Over load"
}
