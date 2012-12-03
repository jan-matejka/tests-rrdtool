testcase() {
	rrdtool graph $OUTDIR/speed3.png \
		--start 920804400 --end 920808000 \
		--vertical-label km/h \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		"CDEF:kmh=myspeed,3600,*" \
		CDEF:fast=kmh,100,GT,kmh,0,IF \
		CDEF:good=kmh,100,GT,0,kmh,IF \
		HRULE:100#0000FF:"Maximum allowed" \
		AREA:good#00FF00:"Good speed" \
		AREA:fast#FF0000:"Too fast"

	rrdtool graph $OUTDIR/speed4.png \
		--start 920804400 --end 920808000 \
		--vertical-label km/h \
		DEF:myspeed=$DBFILE:speed:AVERAGE \
		"CDEF:kmh=myspeed,3600,*" \
		CDEF:fast=kmh,100,GT,100,0,IF \
		CDEF:over=kmh,100,GT,kmh,100,-,0,IF \
		CDEF:good=kmh,100,GT,0,kmh,IF \
		HRULE:100#0000FF:"Maximum allowed" \
		AREA:good#00FF00:"Good speed" \
		AREA:fast#550000:"Too fast" \
		STACK:over#FF0000:"Over speed"
}
