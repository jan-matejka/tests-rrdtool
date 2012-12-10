#! /usr/bin/env bash

DBFILE=$BASEDIR/load.rrd

testcase() {
	# The same as speed test but uses GAUGE instead of COUNTER
	START="920804400"
	echo "create"
	UPDATE_RATE=300
	rrdtool create $DBFILE \
		--start $START \
		-s $UPDATE_RATE \
		DS:used:GAUGE:$(($UPDATE_RATE*2)):0:U \
		DS:free:GAUGE:$(($UPDATE_RATE*2)):0:U \
		RRA:AVERAGE:0.5:1:24 \
		RRA:AVERAGE:0.5:6:10

	upd() {
		rrdtool update $DBFILE 9208$1
	}
	echo "update"
	upd 04700:600:400
	upd 05000:620:380
	upd 05300:630:370
	upd 05600:635:365 # this one touches the HRULE limit on graph2
	upd 05900:648:352
	upd 06200:710:290
	upd 06500:700:300
	upd 06800:708:292
	# upd 07100: # missing data
	# upd 07400:0.1
	upd 07700:715:285
	upd 08000:730:270
	upd 08300:730:270
	upd 08600:735:265

	END=920809000

	echo "graph1"
	rrdtool graph $OUTDIR/mem1.png \
		--start $START --end $END \
		--vertical-label % \
		'--lower-limit' '0' \
		'--upper-limit' '100' \
		DEF:used=$DBFILE:used:AVERAGE \
		DEF:free=$DBFILE:free:AVERAGE \
		"CDEF:pused=used,100,*,used,free,+,/" \
		CDEF:used_area=pused,100,GT,0,pused,IF \
		HRULE:80#0000FF:"critical" \
		AREA:used_area#00FF00:"used"

#	rrdtool graph $OUTDIR/mem1.png \
#'--start', "10/24/2009" \
#'--end', "12/31/2009 00:00am" \
#'--title', "Memory Usage" \
#'--interlace', '--width=620', '--height=200' \
#"--color","ARROW#009900" \
#'--vertical-label', "Memory used (%)" \
#'--lower-limit', '0' \
#'--upper-limit', '100' \
#'--border','0' \
#'--rigid' \
#"DEF:used1=$DBFILE:used:AVERAGE" \
#"DEF:used2=$DBFILE:used:AVERAGE:start=10/24/2009" \
#"DEF:used3=$DBFILE:used:AVERAGE:start=-1w" \
#"DEF:used4=$DBFILE:used:AVERAGE:start=-2w" \
#"DEF:used5=$DBFILE:used:AVERAGE:start=-4w" \
#"DEF:free1=$DBFILE:free:AVERAGE" \
#"DEF:free2=$DBFILE:free:AVERAGE:start=10/24/2009" \
#"DEF:free3=$DBFILE:free:AVERAGE:start=-1w" \
#"DEF:free4=$DBFILE:free:AVERAGE:start=-2w" \
#"DEF:free5=$DBFILE:free:AVERAGE:start=-4w" \
#"CDEF:pused1=used1,100,*,used1,free1,+,/" \
#"CDEF:pused2=used2,100,*,used2,free2,+,/" \
#"CDEF:pused3=used3,100,*,used3,free3,+,/" \
#"CDEF:pused4=used4,100,*,used4,free4,+,/" \
#"CDEF:pused5=used5,100,*,used5,free5,+,/" \
#"LINE1:90" \
#"AREA:5#FF000022::STACK" \
#"AREA:5#FF000044::STACK" \
#"COMMENT:                         Now          Min             Avg             Max\\n" \
#"AREA:pused1#00880077:Memory Used" \
#'GPRINT:pused1:LAST:%12.0lf%s' \
#'GPRINT:pused1:MIN:%10.0lf%s' \
#'GPRINT:pused1:AVERAGE:%13.0lf%s' \
#'GPRINT:pused1:MAX:%13.0lf%s' . "\\n" \
#"COMMENT: \\n" \
#'VDEF:D2=pused2,LSLSLOPE' \
#'VDEF:H2=pused2,LSLINT' \
#'CDEF:avg2=pused2,POP,D2,COUNT,*,H2,+' \
#'CDEF:abc2=avg2,90,100,LIMIT' \
#'VDEF:minabc2=abc2,FIRST' \
#'VDEF:maxabc2=abc2,LAST' \
#'VDEF:D3=pused3,LSLSLOPE' \
#'VDEF:H3=pused3,LSLINT' \
#'CDEF:avg3=pused3,POP,D3,COUNT,*,H3,+' \
#'CDEF:abc3=avg3,90,100,LIMIT' \
#'VDEF:minabc3=abc3,FIRST' \
#'VDEF:maxabc3=abc3,LAST' \
#"AREA:abc2#FFBB0077" \
#"AREA:abc3#0077FF77" \
#"LINE2:abc2#FFBB00" \
#"LINE2:abc3#0077FF" \
#"LINE1:avg2#FFBB00:Trend since 24 Oct 2009                      :dashes=10" \
#"LINE1:avg3#0077FF:Trend since 1 week\\n:dashes=10" \
#"GPRINT:minabc2:  Reach  90% @ %c :strftime" \
#"GPRINT:minabc3:  Reach  90% @ %c \\n:strftime" \
#"GPRINT:maxabc2:  Reach 100% @ %c :strftime" \
#"GPRINT:maxabc3:  Reach 100% @ %c \\n:strftime"



}
