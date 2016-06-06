/* newbilcheck.p
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
begin 28.03.94
*/

def new shared stream m-err.
def stream m-MenBil.
def stream m-MenBilP.
def stream m-MenBilPZ.
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
def var m-key1 as log.
def var m-key2 as log.


message " Processed ? "update m-key1.
if not m-key1 then leave.


m-hslat = "S".
/*  Внимание !!! Это "мягкость" лата. */

output stream m-err to newbilance.err.


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
	    put stream m-err "Not found lgr " aaa.lgr " for " aaa.aaa
	    skip.
	end.
	else do:
	    find gl where gl.gl = lgr.gl no-lock no-error.
	    if not available gl then do:
		m-key1 = no.
		put stream m-err "Not found gl " lgr.gl " for lgr "
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
	    else put stream m-err "Not found crc " aaa.crc " for aaa "
		aaa.aaa skip.
	    m-hs = ?.
	    find crchs where crchs.crc = crc.crc no-lock no-error.
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
		    put stream m-err "Not found geo for " cif.cif
		    skip.
		end.
		else do:
		    m-cgr = cif.cgr.
		    m-geo = integer(cif.geo).
		end.
	    end.
	    else do:
		m-key2 = no.
		put stream m-err "Not found cif " aaa.cif " for aaa "
		aaa.aaa skip.
	    end.
	if m-key2 then do:
		m-sum = 0.
		m-srok = 0.
if aaa.sta <> "C" then do:
    run newblcheck (m-gl,m-gltype,m-crc,m-crccode,m-geo,m-cgr,m-sum,m-srok).
end.
else m-okey = yes.
		if not m-okey then put stream m-err "Error for aaa " aaa.aaa
		" cif " aaa.cif skip.
	end.
    end.
    if i = j then do:
	j = j + 100.
	display  "Обработано aaa " i with frame a
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
		put stream m-err "Not found geo (lon) for " cif.cif
		skip.
		m-key1 = no.
	    end.
	    m-geo = integer(cif.geo).
	    m-cgr = cif.cgr.
	end.
	else do:
	    m-key1 = no.
	    put stream m-err "Not found cif " lon.cif " for lon "
	    lon.lon skip.
	end.
    end.
    if m-key1 then do:
	find gl where gl.gl = lon.gl no-lock no-error.
	if not available gl then do:
	    put stream m-err "Not found gl " lon.gl " for lon "
	    lon.lon skip.
	end.

	find crc where crc.crc = lon.crc no-lock no-error.
	if available crc then do:
		m-sum = lon.dam[1] - lon.cam[1].
		m-srok = lon.duedt - lon.opndt.
		if m-sum <> 0 then
run newbl1check
(gl.gl,gl.type,crc.crc,crc.code,m-geo,m-cgr,lon.loncat,m-sum,m-srok).
		else m-okey = yes.
		if not m-okey then put stream m-err "Error for lon " lon.lon
		" cif " lon.cif skip.
	end.
    end.
    i = i + 1.
    display  "Обработано LON " i with frame l no-label row 10 centered.
    pause 0.
end.
hide frame l.





i = 0.
for each dfb no-lock :
	m-key1 = yes.
	find gl where gl.gl = dfb.gl no-lock no-error.
	if not available gl then do:
	    m-key1 = no.
	    put stream m-err "Not found gl " dfb.gl " for dfb "
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
			put stream m-err "Not found gl " m-rgl " for dfb "
			dfb.dfb skip.
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
run newblcheck (m-gl,m-gltype,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).
	    else m-okey = yes.
	    if not m-okey then put stream m-err "Error for dfb " dfb.dfb skip.

	    end.
	    else put stream m-err "Not found crc " dfb.crc " for dfb "
	    dfb.dfb skip.
	end.  /* bank */
	else put stream m-err "Not found dfb.dfb " dfb.dfb " into bank."
	skip.
    end.
	i = i + 1.
	display  "Обработано DFB " i with frame b no-label row 10 centered.
	pause 0.
end. /* dfb */

hide frame b.

i = 0.
for each fun no-lock :
    m-key1 = yes.
    find gl where gl.gl = fun.gl no-lock no-error.
    if not available gl then do:
	m-key1 = no.
	put stream m-err "Not found gl " fun.gl " for fun "
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
run newblcheck (gl.gl,gl.type,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).
	    else m-okey = yes.
		if not m-okey then put stream m-err "Error for fun " fun.fun
		" bank " fun.bank skip.
	    end.
	    else put stream m-err "Not found crc " fun.crc " for fun "
	    fun.fun skip.
	end.  /* bank */
	else put stream m-err "Not found bank " fun.bank " into bank for fun "
	fun.fun skip.
    end.
	i = i + 1.
	display  "Обработано FUN " i with frame c no-label row 10 centered.
	pause 0.
end. /* fun */

hide frame c.






i = 0.
for each gl no-lock :
    if not (gl.subled = "cif" or gl.subled = "lon" or gl.subled = "dfb" or
    gl.subled = "fun" ) then
    for each crc where crc.sts <> 9 no-lock :
	find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
	no-error.
	if available glbal then do:
	    m-sum = 0.
	    m-hs = ? .
	    m-srok = 0.
	    run newblcheck (gl.gl,gl.type,crc.crc,crc.code,?,?,m-sum,m-srok).
	end.
	else put stream m-err "Not found glbal for " gl.gl crc.code
	skip.
    end. /* crc */
	i = i + 1.
	display  "Обработано GL " i with frame d no-label row 10 centered.
	pause 0.
end.

hide frame d.



i = 0.
for each gl no-lock :
    find first glbl where glbl.gl = gl.gl and  glbl.stsPZ = yes
    no-lock no-error.
    if available glbl  then do:
	for each crc where crc.sts <> 9 no-lock :
	    find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
	    no-error.
	    if not available glbal then
	    put stream m-err "Not found glbal for " gl.gl crc.code skip.
	end.
    end.
    else do:
	find first glbl where glbl.gl = gl.gl
	and glbl.stsPZ = no no-lock no-error.
	if not available glbl then
	put stream m-err "MenBilPZ -> Not found glbl for : gl->" gl.gl
	" crc->" crc.code format "x(3)" skip.
    end.
    i = i + 1.
    display  "Обработано GL " i with frame d1 no-label row 10 centered.
    pause 0.
end.

hide frame d1.


output stream m-err close.



return.
