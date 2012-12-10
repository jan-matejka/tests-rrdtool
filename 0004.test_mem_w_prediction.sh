#! /usr/bin/env bash

DBFILE=$BASEDIR/load.rrd

testcase() {
	# stolen from http://hints.jeb.be/2009/12/04/trend-prediction-with-rrdtool/
	START="920804400"
	echo "create"
	UPDATE_RATE=300
	CURTIME=920808900
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
	upd 07100:715:285
	upd 07400:730:270
	upd 07700:730:270
	upd 08000:800:200
	upd 08300:820:180

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

	echo "graph2"
	rrdtool graph $OUTDIR/mem2.png \
		'--start' $START \
		'--end' $(($END+2*3600)) \
		'--title' "Memory Usage" \
		'--interlace' '--width=620' '--height=200' \
		"--color" "ARROW#009900" \
		'--vertical-label' "Memory used (%)" \
		'--lower-limit' '0' \
		'--upper-limit' '100' \
		'--rigid' \
		"DEF:used1=$DBFILE:used:AVERAGE" \
		"DEF:used2=$DBFILE:used:AVERAGE:start=$START" \
		"DEF:used3=$DBFILE:used:AVERAGE:start=$(($CURTIME-70*60))" \
		"DEF:used4=$DBFILE:used:AVERAGE:start=$(($CURTIME-50*60))" \
		"DEF:used5=$DBFILE:used:AVERAGE:start=$(($CURTIME-30*60))" \
		"DEF:free1=$DBFILE:free:AVERAGE" \
		"DEF:free2=$DBFILE:free:AVERAGE:start=$CURTIME" \
		"DEF:free3=$DBFILE:free:AVERAGE:start=$(($CURTIME-70*60))" \
		"DEF:free4=$DBFILE:free:AVERAGE:start=$(($CURTIME-50*60))" \
		"DEF:free5=$DBFILE:free:AVERAGE:start=$(($CURTIME-30*60))" \
		"CDEF:pused1=used1,100,*,used1,free1,+,/" \
		"CDEF:pused2=used2,100,*,used2,free2,+,/" \
		"CDEF:pused3=used3,100,*,used3,free3,+,/" \
		"CDEF:pused4=used4,100,*,used4,free4,+,/" \
		"CDEF:pused5=used5,100,*,used5,free5,+,/" \
		"LINE1:90" \
		"AREA:5#FF000022::STACK" \
		"AREA:5#FF000044::STACK" \
		"COMMENT:                         Now          Min             Avg             Max\\n" \
		"AREA:pused1#00880077:Memory Used" \
		'GPRINT:pused1:LAST:%12.0lf%s' \
		'GPRINT:pused1:MIN:%10.0lf%s' \
		'GPRINT:pused1:AVERAGE:%13.0lf%s' \
		'GPRINT:pused1:MAX:%13.0lf%s'"\\n" \
		"COMMENT: \\n" \
\
		'VDEF:D2=pused2,LSLSLOPE' \
		'VDEF:H2=pused2,LSLINT' \
		'VDEF:D3=pused3,LSLSLOPE' \
		'VDEF:H3=pused3,LSLINT' \
		'VDEF:D5=pused5,LSLSLOPE' \
		'VDEF:H5=pused5,LSLINT' \
\
		'CDEF:avg2=pused2,POP,D2,COUNT,*,H2,+' \
		'CDEF:abc2=avg2,90,100,LIMIT' \
		'VDEF:minabc2=abc2,FIRST' \
		'VDEF:maxabc2=abc2,LAST' \
\
		'CDEF:avg3=pused3,POP,D3,COUNT,*,H3,+' \
		'CDEF:abc3=avg3,90,100,LIMIT' \
		'VDEF:minabc3=abc3,FIRST' \
		'VDEF:maxabc3=abc3,LAST' \
\
		'CDEF:avg5=pused5,POP,D5,COUNT,*,H5,+' \
		'CDEF:abc5=avg5,90,100,LIMIT' \
		'VDEF:minabc5=abc5,FIRST' \
		'VDEF:maxabc5=abc5,LAST' \
\
		"AREA:abc2#FFBB0077" \
		"AREA:abc3#0077FF77" \
		"AREA:abc5#0077FF77" \
\
		"LINE2:abc5#FFBB00" \
		"LINE2:abc3#0077FF" \
		"LINE1:avg5#FFBB00:Trend since 12\\:40                      :dashes=10" \
		"LINE1:avg3#0077FF:Trend since 12\\:00 week\\n:dashes=10" \
		"GPRINT:minabc2:  Reach  90% @ %c :strftime" \
		"GPRINT:minabc5:  Reach  90% @ %c \\n:strftime" \
		"GPRINT:maxabc2:  Reach 100% @ %c :strftime" \
		"GPRINT:maxabc5:  Reach 100% @ %c \\n:strftime"



}
