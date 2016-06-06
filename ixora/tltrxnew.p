/* tltrxnew.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


/* tltrxnew.p
   Sushinin Vladimir

*/
{global.i}
def stream m-out1.
def stream m-out2.
def stream m-out3.
def var m-count as integer initial 0.
def var m-cashgl as integer.
def var m-first1 as logical.
def var m-var1 as logical.
def var m-first2 as logical.
def var m-var2 as logical.
def var m-amtd as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-amtk as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumdk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumkk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumd1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumdk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumkk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumd2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-sumk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".

def var m-diff as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var m-stn as int.
def var m-sts like jh.sts.
def var m-title as char.
def var m-fun as char.
def var m-stsstr as char.
def var vappend as logical initial false format "Append/Overwrite".
def var dest as char.
def var m-char as char.
def var i as int.
def var j as int.
def var t-ofc like tltrxg.ofc.
def var m-keyofcjl as log.
def var m-keyofc as log.
def var m-dir as char.
def var vtitle as char format "x(132)".
def var vtoday as date.
def var vtime as char.

def var v-nbabeg like gl.gl.
def var v-nbaend like gl.gl.
def var v-nbpbeg like gl.gl.
def var v-nbpend like gl.gl.
def var m-str as char.

def var report-date as date.
def var report-title as char.

report-date = g-today.
report-title = ''.

find sysc where sysc.sysc eq "GLARPB" no-lock.
if available sysc then do:
    m-str = chval.
    v-nbabeg = integer(substring(m-str,1,index(m-str,',') - 1)).
    m-str = substring(m-str,index(m-str,',') + 1).
    v-nbaend = integer(substring(m-str,1,index(m-str,',') - 1)).
    m-str = substring(m-str,index(m-str,',') + 1).
    v-nbpbeg = integer(substring(m-str,1,index(m-str,',') - 1)).
    m-str = substring(m-str,index(m-str,',') + 1).
    v-nbpend = integer(substring(m-str,1,index(m-str,',') - 1)).
end.
else do:
  v-nbabeg = 1020000.
  v-nbaend = 1079999.
  v-nbpbeg = 9060000.
  v-nbpend = 9999999.
end.
def temp-table otl
    field ofc like ofc.ofc
    field gl like gl.gl
    field cam like jl.cam
    field dam like jl.cam
    field ncam as int
    field ndam as int.



find sysc where sysc.sysc eq "cashgl" no-lock no-error .
if available sysc then do:
m-cashgl = sysc.inval.

find sysc where sysc.sysc eq "rtrxdi" no-lock no-error .
m-dir = trim(chval).

for each otl.
 delete otl.
end.
  for each jl where jl.jdt eq g-today no-lock break by jl.who
  by crc by jl.jh by jl.ln:

  if first-of(jl.who) then do:
    find tltrxg where ofc = jl.who and sts0 = no no-lock no-error.
    if not available tltrxg then m-keyofc = no.
    else m-keyofc = yes.

    if m-keyofc then do:
        t-ofc = jl.who.
        output stream m-out1 to value (m-dir + lc(trim(t-ofc)) + "msos.txt").
        output stream m-out2 to value (m-dir + lc(trim(t-ofc)) + "mson.txt").
        put stream m-out1 chr(15).
        put stream m-out2 chr(15).
        m-var1 = false.
        m-var2 = false.
        {tltrx01.f}
        {tltrx02.f}
        hide frame tltrxh1.
        hide frame tltrxh2.
    end.
  end.

  if m-keyofc then do:
  if first-of(jl.crc) then do:
        find crc where crc.crc = jl.crc no-lock no-error.
        {tltrx0.f}
        m-first1 = no.
        m-first2 = no.
        m-sumk1 = 0.
        m-sumd1 = 0.
        m-sumkk1 = 0.
        m-sumdk1 = 0.
        m-sumk2 = 0.
        m-sumd2 = 0.
        m-sumkk2 = 0.
        m-sumdk2 = 0.

  end.
        find jh where jh.jh = jl.jh no-lock no-error.
        if available jh then m-sts = jh.sts.
        else m-sts = 1.

    if not m-first1 and m-sts >= 6 then do:
        m-first1 = true.
        view stream m-out1 frame crc.
        hide frame crc.
    end.

    if not m-first2 and m-sts < 6 then do:
        m-first2 = true.
        view stream m-out2 frame crc.
        hide frame crc.
    end.

    m-amtk = 0.
    m-amtd = 0.

    if jl.dc eq "D"  then do:
        if m-sts >= 6 then do:
            if jl.gl = m-cashgl then m-sumdk1 = m-sumdk1 + jl.dam.
            m-sumd1 = m-sumd1 + jl.dam.
        end.
        else do:
            if jl.gl = m-cashgl then m-sumdk2 = m-sumdk2 + jl.dam.
            m-sumd2 = m-sumd2 + jl.dam.
        end.
        m-amtd = jl.dam.
    end.
    else do:
        if m-sts >= 6 then do:
            if jl.gl = m-cashgl then m-sumkk1 = m-sumkk1 + jl.cam.
            m-sumk1 = m-sumk1 + jl.cam.
        end.
        else do:
            if jl.gl = m-cashgl then m-sumkk2 = m-sumkk2 + jl.cam.
            m-sumk2 = m-sumk2 + jl.cam.
        end.
        m-amtk = jl.cam.
    end.

    m-char = string(jl.tim,"HH:MM:SS").
    if m-sts = 1
    then m-stsstr = "Err".
    else m-stsstr = "   ".
    {tltrx2.f}
    if  m-sts >= 6 then
    display stream m-out1 m-char
            jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk
            jl.teller m-sts m-stsstr
            with frame jltl .
    else
    display stream m-out2 m-char
            jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk
            jl.teller m-sts m-stsstr
            with frame jltl .

  find first otl where otl.gl = jl.gl and otl.ofc = jl.who exclusive-lock
  no-error.
  if not available otl then do:
   create otl.
   otl.gl = jl.gl.
   otl.ofc = jl.who.
  end.
  if jl.dc eq "D" then
    do: otl.dam = otl.dam + jl.dam. otl.ndam = otl.ndam + 1. end.
  else
    do: otl.cam = otl.cam + jl.cam. otl.ncam = otl.ncam + 1. end.

  if last-of ( jl.crc ) then do:
        if m-first1 then do:
            hide frame jltl.
            m-var1 = true.
            {tltrx41.f}
            display stream m-out1 m-sumd1 m-sumk1
            with frame tl1total1.
            hide frame tl1total1.
            {tltrx31.f}
            m-diff = m-sumdk1 - m-sumkk1.
            display stream m-out1
            m-sumdk1 m-sumkk1 m-diff with frame tltotal1.
            hide frame tltotal1.
        end.
        if m-first2 then do:
            m-var2 = true.
            {tltrx42.f}
            display stream m-out2 m-sumd2 m-sumk2
            with  frame tl1total2.
            hide frame tl1total2.
            hide frame jltl.
            {tltrx32.f}
            m-diff = m-sumdk2 - m-sumkk2.
            display stream m-out2
            m-sumdk2 m-sumkk2 m-diff with frame tltotal2.
            hide frame tltotal2.
        end.
  end.
  end.
  if last-of(jl.who) and m-keyofc then do transaction:
        find tltrxg where ofc = jl.who and sts0 = no exclusive-lock no-error.
        if m-var1 then do :
            tltrxg.sts1 = yes.
        end.
        if m-var2 then do :
            tltrxg.sts2 = yes.
        end.

        output stream m-out1 close.
        output stream m-out2 close.
  end.
  end. 




/*

find first aal where aal.regdt eq g-today no-lock no-error.


if available aal then 
do:

  for each aal where aal.regdt = g-today no-lock break by aal.who by aal.crc by aal.aah by aal.ln:

	if first-of(aal.who) then 
	do:
	    find tltrxg where tltrxg.ofc = aal.who and sts0 = no no-lock no-error.
	    if not available tltrxg then m-keyofc = no.
	    else m-keyofc = yes.

		if m-keyofc then do:
        	t-ofc = aal.who.
	        output stream m-out1 to value (m-dir + lc(trim(t-ofc)) + "msos.txt")
        	append.         
	        output stream m-out2 to value (m-dir + lc(trim(t-ofc)) + "mson.txt")
        	append.         
	            if not tltrxg.sts1 and  not tltrxg.sts2 then do:
        	    put stream m-out1 chr(15).
	            put stream m-out2 chr(15).
        	    {tltrx010.f}
	            {tltrx020.f}
        	    hide frame tltrxh10.
	            hide frame tltrxh20.
        	end.
	        if not tltrxg.sts1 then do:
        	    m-var1 = false.
	        end.
        	if not tltrxg.sts2 then do:
	            m-var2 = false.
        	end.

    		end.    
	end. 

	if m-keyofc then do:

	 if first-of(aal.crc) then do:
        	find crc where crc.crc = aal.crc no-lock no-error.
	        {tltrxc.f}
        	m-first1 = no.
	        m-first2 = no.
        	m-sumk1 = 0.
	        m-sumd1 = 0.
        	m-sumkk1 = 0.
	        m-sumdk1 = 0.
        	m-sumk2 = 0.
	        m-sumd2 = 0.
        	m-sumkk2 = 0.
	        m-sumdk2 = 0.
	  end.


  if (aal.jh = 0 or aal.jh = ? ) then do:
      find aah where aah.aah = aal.aah no-lock no-error.
      if available aah then m-stn = aah.stn.
       else m-stn = 1.

    find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax no-lock no-error.

    m-char = string(aal.tim,"HH:MM:SS").
    m-amtd = 0.
    m-amtk = 0.
    if aax.cash <> ? then do:
        if aax.cash eq true  then do:
            if m-stn >= 6 then
                m-sumdk1 = m-sumdk1 + aal.amt.
            else
                m-sumdk2 = m-sumdk2 + aal.amt.
        end.
        else if aax.cash eq false then do:
            if m-stn >= 6 then
                m-sumkk1 = m-sumkk1 + aal.amt.
            else
                m-sumkk2 = m-sumkk2 + aal.amt.
        end.
    end.
    if m-stn = 1
    then m-stsstr = "Err".
    else m-stsstr = "   ".


    if m-stn >= 6 then do:
        if not m-first1  then do:
            m-first1 = true.
            
            view stream m-out1 frame crc1.
            hide frame crc1.
        end.
        {tltrx1.f}
        display stream m-out1 m-char
                aal.aah format 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa
                aal.amt format "z,zzz,zzz,zzz,zz9.99-"
                aal.teller m-stn m-stsstr
	                with frame aaltl.
	    end.

	    if m-stn < 6 then do:
	        if not m-first2  then do:
	            m-first2 = true.
        	    view stream m-out2 frame crc1.
	            hide frame crc1.
        	end.
	        {tltrx1.f}
	        display stream m-out2 m-char
	                aal.aah format 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa
                	aal.amt format "z,zzz,zzz,zzz,zz9.99-"
        	        aal.teller m-stn m-stsstr
	                with frame aaltl.
	    end.

	     if aax.dgl ne 0 then do:
	      find first otl where otl.gl = aax.dgl
	      and otl.ofc = aal.who no-error.
	      if not available otl then do:
	        create otl.
	        otl.gl = aax.dgl.
	        otl.ofc = aal.who.
	      end.
	     otl.dam = otl.dam + aal.amt. otl.ndam = otl.ndam + 1.
	    end.
	     if aax.cgl ne 0 then do:
	      find first otl where otl.gl = aax.cgl
	      and otl.ofc = aal.who no-error.
	      if not available otl then do:
	        create otl.
	        otl.gl = aax.cgl.
        	otl.ofc = aal.who.
	      end.
	      otl.cam = otl.cam + aal.amt. otl.ncam = otl.ncam + 1.
	     end.

	 end. 

	if last-of (aal.crc) then do:
        if m-first1 then do:
            m-var1 = true.
            m-diff = m-sumdk1 - m-sumkk1.
            {tltrx61.f}
            display stream m-out1
            m-sumdk1 m-sumkk1 m-diff with  frame tltotal61.
            hide frame tltotal61.
            hide frame aaltl.
        end.
        if m-first2 then do:
            m-var2 = true.
            m-diff = m-sumdk2 - m-sumkk2.
            {tltrx62.f}
            display stream m-out2
            m-sumdk2 m-sumkk2 m-diff with frame tltotal62.
            hide frame tltotal62.
            hide frame aaltl.
        end.

	end.  

	end. 


  if last-of(aal.who) and m-keyofc then do transaction:
  find tltrxg where tltrxg.ofc = aal.who and sts0 = no exclusive-lock no-error.

        if m-var1 then do :
            tltrxg.sts1 = yes.
        end.
        if m-var2 then do :
            tltrxg.sts2 = yes.
        end.
        output stream m-out1 close.
        output stream m-out2 close.
  end.

  end. 
end.  
*/

for each tltrxg where sts0 = no exclusive-lock :
        t-ofc = tltrxg.ofc.
        output stream m-out1 to 
        value (m-dir + lc(trim(t-ofc)) + "msos.txt") append.
        output stream m-out2 to 
        value (m-dir + lc(trim(t-ofc)) + "mson.txt") append.
        output stream m-out3 to 
        value (m-dir + lc(trim(t-ofc)) + "sum.txt") append
        page-size 59 append.
        if not tltrxg.sts1 and  not tltrxg.sts2 then do:
            put stream m-out1 chr(15).
            put stream m-out2 chr(15).
            {tltrx011.f}
            {tltrx021.f}
            hide frame tltrxh11.
            hide frame tltrxh21.
        end.


        {tltrx5.f}



        if not tltrxg.sts1 then view stream m-out1 frame navvar.
        if not tltrxg.sts2 then view stream m-out2 frame navvar.
        display stream m-out1 skip(3).
        display stream m-out2 skip(3).

        output stream m-out1 close.
        output stream m-out2 close.
        unix silent chmod 0777 value (m-dir + trim(t-ofc) + "msos.txt") .
        unix silent chmod 0777 value (m-dir + trim(t-ofc) + "mson.txt") .


        find ofc where ofc.ofc = t-ofc no-lock.
        vtoday = g-today.
        vtime = string(time,"HH:MM:SS").
        vtitle = {ofcsumo.f} .
        /*
        { report2.i "132" "" "" "stream m-out3" }
        */



form header
  skip(3)
  g-comp vtoday vtime "BY" caps(g-ofc)
     "Page: " + string(page-number, "zzz9") format "x(10)" to 132 skip
  g-fname g-mdes skip
  vtitle format "x(132)" skip
  fill("=",132) format "x(132)" skip
  with width 132 page-top no-box no-label frame rpthead.
view stream m-out3 frame rpthead.

        find first otl where otl.ofc = tltrxg.ofc no-error.
        if available otl then do:
        for each otl where otl.ofc eq t-ofc
            and not
            ((otl.gl ge v-nbabeg and otl.gl lt v-nbaend) or
            (otl.gl ge v-nbpbeg and otl.gl lt v-nbpend))

            break by otl.gl.
            find gl where otl.gl = gl.gl no-lock.
            {ofcsum.f "stream m-out3" }
        end.
        for each otl where otl.ofc = t-ofc
            and
            ((otl.gl ge v-nbabeg and otl.gl lt v-nbaend) or
            (otl.gl ge v-nbpbeg and otl.gl lt v-nbpend))

        break by otl.gl.
            find gl where otl.gl = gl.gl no-lock.
            {ofcsum.f "stream m-out3" }
        end.

        end.
        output stream m-out3 close.
        unix silent chmod 0777 value (m-dir + trim(t-ofc) + "sum.txt") .

        tltrxg.sts0 = yes.

end.





end.
