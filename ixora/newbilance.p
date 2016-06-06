/* newbilance.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
Vladimir Sushinin
begin 12.01.94
*/

def new shared stream m-err.
def stream m-MenBil.
def stream m-MenBilP.
def stream m-MenBilPZ.
def new shared var v-gltd as char.
def new shared var m-aaa like aaa.aaa.
def new shared var m-ind as int.
def var m-srok as int.
def var m-rate as deci.
def var m-sum like glbal.bal.
def var m-crc like crc.crc.
def var m-crccode like crc.code.
def var m-lgr like aaa.lgr.
def var m-rgl like gl.gl.
def var m-gl like gl.gl.
def var m-gltype like gl.type.
def new shared var m-hs like crchs.hs.
def new shared var m-hslat like crchs.hs.
def new shared var m-okey as log.
def var m-geo as int.
def var m-cgr like cgr.cgr.
def var m-host as char.
def var i as int.
def var i1 as int.
def var j as int.
def var la as char.
def var m-key2 as log.
def var dame as char.
def var m-ext as char.
{nb0.f}
{nb.f}
/*
def var m-key1 as log.
message " Processed ? "update m-key1.
if not m-key1 then leave.
*/

find sysc where sysc.sysc = "GLDATE" no-lock no-error.
dame = string(day(sysc.daval),"99") + string(month(sysc.daval),"99").
find sysc where sysc.sysc = "BILEXT" no-lock no-error.
if available sysc then m-ext = "." + trim(sysc.chval). else m-ext = ".".

find sysc where sysc.sysc = "GLTD" no-lock no-error.
if available sysc then v-gltd = sysc.chval. else v-gltd = "".

m-hslat = "S".
/*  Внимание !!! Это "мягкость" лата. */

output stream m-err to newbilance.err.

for each menbil:
    delete menbil.
end.
for each menbilp:
    delete menbilp.
end.

for each menbilpz:
    delete menbilpz.
end.




i = 0.

m-lgr = ?.
for each aaa no-lock break by lgr :


    if first-of(aaa.lgr) then do:
	i1 = 0.
	m-lgr = aaa.lgr.
	m-key1 = yes.
	find lgr where lgr.lgr = aaa.lgr no-lock no-error.
	if not available lgr then do:
	    m-key1 = no.
	    put stream m-err m-strerr1  " lgr " aaa.lgr m-strerr2 " aaa "
	    aaa.aaa skip.
	end.
	else do:
	    find gl where gl.gl = lgr.gl no-lock no-error.
	    if not available gl then do:
		m-key1 = no.
		put stream m-err m-strerr1  " gl " lgr.gl m-strerr2  " lgr "
		lgr.lgr skip.
	    end.
	    else do:
		m-gl = gl.gl.
		m-gltype = gl.type.
	    end.

	    find crc where crc.crc = aaa.crc no-lock no-error.
	    if available crc then do:
		m-crc = crc.crc.
		m-crccode = crc.code.
	    end.
	    else put stream m-err m-strerr1  " crc " aaa.crc m-strerr2  " aaa "
		aaa.aaa skip.
	    m-hs = ?.
	    find crchs where crchs.crc = crc.crc.
	    if available crchs then m-hs = crchs.hs.
	end.
    end.
    if m-key1 then do:
	    m-key2 = yes.
	    m-geo = ? .
	    find cif  where aaa.cif = cif.cif no-lock no-error.
	    if available cif then do:
		if trim(cif.geo) = "" then do:
		    m-key2 = no.
		    put stream m-err m-strerr1  " geo " cif.geo m-strerr2
		    " cif " cif.cif skip.
		end.
		else do:
		    m-cgr = cif.cgr.
		    m-geo = integer(cif.geo).
		end.
	    end.
	    else do:
		m-key2 = no.
		put stream m-err m-strerr1  " cif " aaa.cif m-strerr2  " aaa "
		aaa.aaa skip.
	    end.
	if m-key2 then do:
		m-sum = aaa.dr[1] - aaa.cr[1].
		m-srok = aaa.expdt - aaa.regdt.
if m-sum <> 0 then do:
run newbl (m-gl,m-gltype,m-crc,m-crccode,m-geo,m-cgr,m-sum,m-srok).
end.
else m-okey = yes.
		if not m-okey then put stream m-err
		m-strerr0  " aaa " aaa.aaa
		", cif " aaa.cif skip.
	end.
    end.
    if i = j then do:
	j = j + 100.
	display  m-mess1 i with frame a
	no-label row 10 centered.
	pause 0.
    end.
    i = i + 1.
    i1 = i1 + 1.
end.

m-hs = ? .
hide frame a.





i = 0.

for each lon no-lock break by cif:
    if first-of(lon.cif) then do:
	m-key1 = yes.
	m-geo = ? .
	find cif  where lon.cif = cif.cif no-lock no-error.
	if available cif then do:
	    if trim(cif.geo) = "" then do:
		put stream m-err m-strerr1  " geo " cif.geo m-strerr2
		" cif " cif.cif skip.
		m-key1 = no.
	    end.
	    m-geo = integer(cif.geo).
	    m-cgr = cif.cgr.
	end.
	else do:
	    m-key1 = no.
	    put stream m-err m-strerr1  " cif " lon.cif m-strerr2  " lon "
	    lon.lon skip.
	end.
    end.
    if m-key1 then do:
	find gl where gl.gl = lon.gl no-lock no-error.
	if not available gl then do:
	    put stream m-err m-strerr1  " gl " lon.gl m-strerr2  " lon "
	    lon.lon skip.
	end.

	find crc where crc.crc = lon.crc no-lock no-error.
	if available crc then do:
		m-sum = lon.dam[1] - lon.cam[1].
		find first ln%his where ln%his.lon = lon.lon and
		     ln%his.opnamt > 0 and ln%his.rdt <> ? and ln%his.duedt <> ?
		     no-lock no-error.
		if not available ln%his
		then m-sum = 0.
		else m-srok = ln%his.duedt - ln%his.rdt.
		/* m-srok = lon.duedt - lon.rdt.
		find loncnt where loncnt.lon = lon.lon no-lock no-error.
		if available loncnt then do:
		    find lcnt where lcnt.lcnt = loncnt.lcnt no-lock no-error.
		    if available lcnt then
		    m-srok = lcnt.duedt - lcnt.rdt.
		end.
		J.O. */
		if m-sum <> 0 then
run newbl1 (gl.gl,gl.type,crc.crc,crc.code,m-geo,m-cgr,lon.loncat,m-sum,m-srok).
		else m-okey = yes.
		if not m-okey then put stream m-err
		m-strerr0  " lon " lon.lon
		", cif " lon.cif skip.
	end.
    end.
    i = i + 1.
    display  m-mess2 i with frame l no-label row 10 centered.
    pause 0.
end.
hide frame l.





i = 0.
for each dfb no-lock :
	m-key1 = yes.
	find gl where gl.gl = dfb.gl no-lock no-error.
	if not available gl then do:
	    m-key1 = no.
	    put stream m-err m-strerr1  " gl " dfb.gl m-strerr2  " dfb "
	    dfb.dfb skip.

	end.
	else do:
	    m-gl = gl.gl.
	    m-gltype = gl.type.
	end.
    if m-key1 then do:
	find bank where bank.bank = dfb.dfb no-lock no-error .
	if available bank then do:

	    find crc where crc.crc = dfb.crc no-lock no-error.
	    if available crc then do:
		m-srok = 0.
		m-sum = dfb.dam[1] - dfb.cam[1].
		if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
		if m-sum < 0 then do:
		    if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
		    m-rgl = gl.revgl.
		    find gl where gl.gl = m-rgl no-lock no-error.
		    if not available gl then do:
			m-key1 = no.
			put stream m-err m-strerr1  " gl " m-rgl
			m-strerr2  " dfb " dfb.dfb skip.
		    end.
		    else do:
			m-gl = gl.gl.
			m-gltype = gl.type.
		    end.
		end.
		else
		if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
		m-cgr = ?.
	    if m-sum <> 0 and m-key1 then
run newbl (m-gl,m-gltype,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).
	    else m-okey = yes.
	    if not m-okey then put stream m-err
	    m-strerr0 + " dfb " dfb.dfb skip.

	    end.
	    else put stream m-err m-strerr1  " crc " dfb.crc m-strerr2  " dfb "
	    dfb.dfb skip.
	end.  /* bank */
	else put stream m-err m-strerr1  " bank " dfb.dfb
	m-strerr2 " dfb " dfb.dfb skip.
    end.
	i = i + 1.
	display  m-mess3 i with frame b no-label row 10 centered.
	pause 0.
end. /* dfb */

hide frame b.

i = 0.
for each fun no-lock :
    m-key1 = yes.
    find gl where gl.gl = fun.gl no-lock no-error.
    if not available gl then do:
	m-key1 = no.
	put stream m-err m-strerr1  " gl " fun.gl m-strerr2  " fun "
	fun.fun skip.
    end.
    if m-key1 then do:
	find bank where bank.bank = fun.bank no-lock no-error .
	if available bank then do:
	    find crc where crc.crc = fun.crc no-lock no-error.
	    if available crc then do:
		m-sum = fun.dam[1] - fun.cam[1].
		m-srok = fun.trm.
		m-cgr = ?.
if m-sum <> 0 then
run newbl (gl.gl,gl.type,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).
	    else m-okey = yes.
		if not m-okey then put stream m-err
		m-strerr0  " FUN " fun.fun
		",bank " fun.bank skip.
	    end.
	    else put stream m-err m-strerr1  " crc " fun.crc m-strerr2  " fun "
	    fun.fun skip.
	end.  /* bank */
	else put stream m-err m-strerr1  " bank " fun.bank m-strerr2 " FUN "
	fun.fun skip.
    end.
	i = i + 1.
	display  m-mess4 i with frame c no-label row 10 centered.
	pause 0.
end. /* fun */

hide frame c.






i = 0.
for each gl no-lock :
    if not (gl.subled = "cif" or
    (gl.subled eq "lon" and gl.level eq 1)
    or gl.subled = "dfb" or
    (gl.subled eq "fun" and gl.level eq 1)) then
    for each crc no-lock :
	find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
	no-error.
	if available glbal then do:
	if glbal.bal <> 0 then do:
	    m-hs = ? .
	    if
	    gl.type = "L" or gl.type = "O" then m-sum = - glbal.bal.
	    else m-sum = glbal.bal.
	    /* glbal.dam - glbal.cam. */
	    m-srok = 0.
	    run newbl (gl.gl,gl.type,crc.crc,crc.code,?,?,m-sum,m-srok).
	end.    /* glbal */
	end.
	else put stream m-err m-strerr1  " glbal  " m-strerr2 " gl "
	gl.gl crc.code
	skip.
    end. /* crc */
	i = i + 1.
	display  m-mess5 i with frame d no-label row 10 centered.
	pause 0.
end.

hide frame d.



i = 0.
for each gl no-lock :
    find first glbl where glbl.gl = gl.gl and  glbl.stsPZ = yes
    no-lock no-error.
    if available glbl  then do:
	for each crc no-lock :
	    find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
	    no-error.
	    if available glbal then do:
		if glbal.bal <> 0 then do:
		    m-sum = glbal.bal.
		    if glbl.SignSum = true then m-sum = - m-sum.
		    find first MenBilPZ where
		    MenBilPZ.p-kodsPZ = glbl.p-kods and
		    MenBilPZ.stabs = glbl.stabs and
		    MenBilPZ.kod-val = crc.code
		    no-error.
		    if available MenBilPZ then
		    MenBilPZ.summa = MenBilPZ.summa + m-sum.
		    else do:
			create MenBilPZ.
			MenBilPZ.p-kodsPZ = glbl.p-kods.
			MenBilPZ.stabs = glbl.stabs.
			MenBilPZ.kod-val = crc.code.
			MenBilPZ.summa = m-sum.
		    end.
		    m-okey = yes.
		end.
	    end.
	    else put stream m-err m-strerr1  " glbal " m-strerr2 " gl "
	    gl.gl crc.code
	    skip.
	end.
    end.
    else do:
	find first glbl where glbl.gl = gl.gl
	and glbl.stsPZ = no no-lock no-error.
	if available glbl then m-okey = yes.
	if not m-okey then
	put stream m-err "PZ -> " m-strerr1 " glbl " m-strerr2 " gl " gl.gl
	 " " crc.code format "x(3)" skip.
    end.
    i = i + 1.
    display  m-mess5 i with frame d1 no-label row 10 centered.
    pause 0.
end.

hide frame d1.




output stream m-MenBil to value("MB" + dame + m-ext).
output stream m-MenBilPZ to value("MBPZ" + dame + m-ext).

for each MenBil break by kod-val :
    if first-of(kod-val) then do:
	find first crc where crc.code = kod-val no-lock no-error.
	if available crc then m-rate = (crc.rate[1] / crc.rate [9]).
	else m-rate = 0.
    end.
    summaLs = summa * m-rate.
end.

for each MenBilP break by kod-val :
    if first-of(kod-val) then do:
	find first crc where crc.code = kod-val no-lock no-error.
	if available crc then m-rate = (crc.rate[1] / crc.rate [9]).
	else m-rate = 0.
    end.
    summaLs = summa * m-rate.
end.

for each MenBilPZ break by MenBilPZ.kod-val :
    if first-of(MenBilPZ.kod-val) then do:
	find first crc where crc.code = MenBilPZ.kod-val no-lock no-error.
	if available crc then m-rate = (crc.rate[1] / crc.rate [9]).
	else m-rate = 0.
    end.
    MenBilPZ.summaLs = MenBilPZ.summa * m-rate.
end.

for each MenBil break by p-kods by stabs :
accumulate SummaLs (total by stabs).
    if last-of(stabs) then do:
	m-sum =  accum total by stabs summaLs .
	if m-sum <> 0 then
	put stream m-MenBil '"'
	p-kods '" "' MenBil.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.


output stream m-MenBilP to value("MBP" + dame + m-ext).
for each MenBilP break by p-kodsP by stabs :
accumulate SummaLs (total by stabs).
    if last-of(stabs) then do:
	m-sum =  accum total by stabs summaLs .
	if m-sum <> 0 then
	put stream m-MenBilP '"'
	p-kodsP '" "' MenBilP.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.
output stream m-MenBilP close.

output stream m-MenBilP to value("MBPL" + dame + m-ext).
for each MenBilP break by p-kodsP by stabs :
    find first crc where crc.code = MenBilP.kod-val no-lock no-error.
    if available crc then do:
	find first crchs where crc.crc = crchs.crc no-lock no-error.
	if available crchs then do:
	    if crchs.hs = "L" then
	    accumulate SummaLs (total by stabs).
	end.
    end.
    if last-of(stabs) then do:
	m-sum =  accum total by stabs summaLs .
	if m-sum <> 0 then
	put stream m-MenBilP '"'
	p-kodsP '" "' MenBilP.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.
output stream m-MenBilP close.


output stream m-MenBilP to value("MBPH" + dame + m-ext).
for each MenBilP break by p-kodsP by stabs :
    find first crc where crc.code = MenBilP.kod-val no-lock no-error.
    if available crc then do:
	find first crchs where crc.crc = crchs.crc no-lock no-error.
	if available crchs then do:
	    if crchs.hs = "H" then
	    accumulate SummaLs (total by stabs).
	end.
    end.
    if last-of(stabs) then do:
	m-sum =  accum total by stabs summaLs .
	if m-sum <> 0 then
	put stream m-MenBilP '"'
	p-kodsP '" "' MenBilP.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.
output stream m-MenBilP close.

output stream m-MenBilP to value("MBPS" + dame + m-ext).
for each MenBilP break by p-kodsP by stabs :
    find first crc where crc.code = MenBilP.kod-val no-lock no-error.
    if available crc then do:
	find first crchs where crc.crc = crchs.crc no-lock no-error.
	if available crchs then do:
	    if crchs.hs = "S" then
	    accumulate SummaLs (total by stabs).
	end.
    end.
    if last-of(stabs) then do:
	m-sum =  accum total by stabs summaLs .
	if m-sum <> 0 then
	put stream m-MenBilP '"'
	p-kodsP '" "' MenBilP.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.
output stream m-MenBilP close.


for each MenBilPZ break by p-kodsPZ by MenBilPZ.stabs :
accumulate MenBilPZ.SummaLs (total by MenBilPZ.stabs).
    if last-of(MenBilPZ.stabs) then do:
	m-sum =  accum total by MenBilPZ.stabs MenBilPZ.SummaLs .
	if m-sum <> 0 then
	put stream m-MenBilPZ '"'
	p-kodsPZ '" "' MenBilPZ.stabs '" "' m-sum
	format "->>>>>>>>>>>>9.99" '"' skip.
    end.
end.

output stream m-MenBil close.
output stream m-MenBilPZ close.
output stream m-err close.



return.
/*-----------------------------------------------------------------
  #3.
     1.izmai‡a - kredЁta ilgums tiek fiksёts no s–kotnёj– termi‡a,
       t.i. izmai‡as netiek ‡emtas vёr–
------------------------------------------------------------------*/
