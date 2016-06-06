/* tlnstrx.p
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

/* tlnstrx.p
   Sushinin Vladimir

*/

def var m-count as integer initial 2.
def var m-cashgl as integer.
def var m-first as logical.
def var m-var as logical.
def var m-amtd as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-amtk as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumd as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumk as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-diff as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-stn as int.
def var m-title as char.
def var vappend as logical initial false format "Append/Overwrite".
def var dest as char.
def shared var g-comp as char.
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-char as char.

dest = "prit".
{tlimage1.f}
view frame image1.
update vappend dest with frame image1 no-box no-label.
hide frame image1.


find sysc where sysc.sysc eq "cashgl" no-error.
if available sysc then do:
m-cashgl = sysc.inval.

if vappend then output to rpt.img append.
else output to rpt.img.
put chr(15).

repeat while m-count < 4 :
m-count = m-count + 1.
m-var = false.
{tlatrx.f}
view frame tlatrxh.


for each crc :
m-sumd = 0.
m-sumk = 0.
m-first = false.
{tlatrx0.f}

/*
find first aal where aal.regdt eq g-today and aal.crc = crc.crc no-lock no-error.
if available aal then 
do:
  	for each aal where aal.regdt eq g-today and aal.crc = crc.crc no-lock break by aal.aah by aal.ln:
		find aah where aah.aah = aal.aah no-lock no-error.
		m-stn = 0.
		if aal.jh = ? or aal.jh = 0 then 
		do:
	    		find aah where aah.aah = aal.aah no-lock no-error.
	    		if available aah then m-stn = aah.stn.
		end.
		else do :
	    		find jh where jh.jh = aal.jh no-lock no-error.
	    		if available jh then m-stn = jh.sts.
		end.
     if m-count = 1 and m-stn < 6 then next.
     if m-count = 2 and m-stn < 6 then next.
     if m-count = 3 and m-stn >= 6 then next.
     if m-count = 4 and m-stn >= 6 then next.

    find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
    if aax.cash = ? and m-count = 1 then next.
    if aax.cash <> ? and m-count = 2 then next.
    if aax.cash = ? and m-count = 3 then next.
    if aax.cash <> ? and m-count = 4 then next.

  if not m-first  then do:
    m-first = true.
    view frame crc.
  end.

    {tlatrx1.f}
    m-char = string(aal.tim,"HH:MM:SS").
    m-amtd = 0.
    m-amtk = 0.
    if aax.cash <> ? then do:
	if aax.cash eq true  then do:
	    m-amtd = aal.amt.
	    m-sumd = m-sumd + m-amtd.
	end.
	else if aax.cash eq false then do:
	    m-amtk = aal.amt.
	    m-sumk = m-sumk + aal.amt.
	end.
    end.
    else do:
	if aax.dgl > 0 then do:
	    m-amtd = aal.amt.
	    m-sumd = m-sumd + m-amtd.
	end.
	if aax.cgl > 0 then do:
	    m-amtk = aal.amt.
	    m-sumk = m-sumk + aal.amt.
	end.
    end.
    display m-char aal.who
	    aal.aah format 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa
	    m-amtd format "z,zzz,zzz,zzz,zz9.99-"
	    m-amtk format "z,zzz,zzz,zzz,zz9.99-"
	    aal.teller m-stn
	    with width 136 frame aaltl.
  end.  
end.
*/

  find first jl where jl.jdt eq g-today
    and jl.crc = crc.crc and jl.aah = 0  no-lock no-error.
  if available jl then do:
  for each jl where jl.jdt eq g-today
      and jl.crc = crc.crc and jl.aah = 0 no-lock break by jl.jh by jl.ln:
     find jh where jh.jh = jl.jh no-lock no-error.
     if m-count = 1 and jh.sts < 6 then next.
     if m-count = 2 and jh.sts < 6 then next.
     if m-count = 3 and jh.sts >= 6 then next.
     if m-count = 4 and jh.sts >= 6 then next.



    if jl.gl <> m-cashgl and m-count = 1 then next.
    if jl.gl =  m-cashgl and m-count = 2 then next.
    if jl.gl <> m-cashgl and m-count = 3 then next.
    if jl.gl =  m-cashgl and m-count = 4 then next.


  if not m-first  then do:
    m-first = true.
    view frame crc.
  end.
    m-amtd = 0.
    m-amtk = 0.

    if jl.dam>0  then do:
	m-sumd = m-sumd + jl.dam.
	m-amtd = jl.dam.
    end.
    else do:
	m-sumk = m-sumk + jl.cam.
	m-amtk = jl.cam.
    end.
    {tlatrx2.f}
    m-char = string(jl.tim,"HH:MM:SS").
    display m-char jl.who
	    jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk
	    jl.teller jh.sts
	    with width 136 frame jltl.


  end.  /* for each jl */
end.
if m-first then do:
    m-var = true.
    if m-count = 1 or m-count = 3 then do:
	{tlatrx3.f}
	m-diff = m-sumd - m-sumk.
	display m-sumd m-sumk m-diff with width 136 frame tltotal.
	hide frame tltotal.
    end.
    else do:
	{tlatrx4.f}
	display m-sumd m-sumk with width 136 frame tl1total.
	hide frame tl1total.
    end.
    hide frame aaltl.
    hide frame jltl.
    hide frame crc.
end.
end. /* for each crc */
{tlatrx5.f}
if not m-var then view frame navvar.
hide frame navvar.
hide frame tlatrxh.
display skip(3).
end.
output close.
unix value(dest) rpt.img.
end.
