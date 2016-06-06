/* newbl.p
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
newbl.p
Vladimir Sushinin
begin 12.01.94.
*/

def shared stream m-err.
def shared var v-gltd as char.
def var m-ind as int.
def var m-key3 as log.
def shared var m-aaa like aaa.aaa.
def input parameter m-gl like gl.gl.
def input parameter m-la like gl.type.
def input parameter m-crc like crc.crc.
def input parameter m-crccode like crc.code.
def input parameter m-geo as int.
def input parameter m-cgr like cgr.cgr.
def input parameter m-sum as decimal format ">>>,>>>,>>>,>>9.99-".
def input parameter m-srok as int.
def shared var m-okey as log.
def shared var m-hs like crchs.hs.
def shared var m-hslat like crchs.hs.
def var m1-hs like crchs.hs.
def var m-geos like glbl.geo.
{nb0.f}

m-ind = 0.
m-cgr = integer(substring(string(m-cgr,"999"),1,1)).

if m-srok <=0 or m-srok = ? then
if v-gltd matches "*" + string(m-gl,"999999") + "*" then m-srok = 1.


if m-geo = 23 or m-geo = 22 then m-geo = 21.

if m-geo >= 0 then m-geos = string(m-geo,"99"). else m-geos = ?.
m-key3 = no.
m-okey = no.
m1-hs = ?.
if m-hs = ? then do:
    find first crchs where crchs.crc = m-crc no-lock no-error.
    if available crchs then m1-hs = crchs.hs.
end.
else m1-hs = m-hs.

if m1-hs <> ? then do:
m-key3 = yes.

	find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
	glbl.cgr = m-cgr  and glbl.hs = m1-hs no-lock no-error.
	if not available glbl then do:
	    find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
	    glbl.cgr = ? and glbl.hs = m1-hs no-lock no-error.
	    if not available glbl then do:
		find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
		glbl.cgr = m-cgr  and glbl.hs = ? no-lock no-error.
		if not available glbl then do:
		    find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
		    glbl.cgr = ? and glbl.hs = ? no-lock no-error.
		    if not available glbl then m-key3 = no.
		end.
	    end.
	end.

end.


if m-key3 then do:
    if (m-geo = ?) then do:
	if ( not glbl.period) then do:
	    if m1-hs = "L" then m-ind = 0. else m-ind = 3.
	end.
	else m-ind = 3.
    end.


    if glbl.p-kods <> 0 then do:
    if (m-geo = 25) or (m-geo = 12) or (m-geo = 13) then m-ind = 3.
    if  m1-hs = "L" then m-ind = m-ind + 1.
    if  m1-hs = "H" then m-ind = m-ind + 2.
    if  m1-hs = "S" then m-ind = m-ind + 3.
    if m-la = "L" or m-la = "O" then m-sum = - m-sum.

    if m-geo = ? and glbl.stabs > 0 then m-ind = glbl.stabs.

    find first MenBil where
    MenBil.p-kods = glbl.p-kods and
    MenBil.stabs = m-ind and
    MenBil.kod-val = m-crccode
    no-error.
    if available MenBil then do:
	if glbl.SignSum then MenBil.summa = MenBil.summa - m-sum.
	else MenBil.summa = MenBil.summa + m-sum.
    end.
    else do:
	create MenBil.
	MenBil.p-kods = glbl.p-kods.
	MenBil.stabs = m-ind.
	MenBil.kod-val = m-crccode.

	if glbl.SignSum then MenBil.summa = - m-sum.
	else MenBil.summa =  m-sum.
    end.
    if m-la = "L" or m-la = "O" then m-sum = - m-sum.
    m-okey = yes.
    end.
    else
    put stream m-err "MB -> " m-strerr1 " glbl " m-strerr2 " gl " m-gl
    " cgr " m-cgr format "zz9-"
    " crc " m-crccode format "x(3)"
    " Summa " m-sum skip.

end.



else do:
    find first glbl where glbl.gl = m-gl and glbl.sts = no no-lock no-error.
    if available glbl then m-okey = yes.
    if not m-okey then
    put stream m-err "MB -> " m-strerr1 " glbl " m-strerr2 " gl " m-gl
    " cgr->" m-cgr format "zz9-"
    " crc->" m-crccode format "x(3)"
    " Summa " m-sum skip.
end.



if m-key3 and glbl.period then do :

m-key3 = yes.
m-okey = no.

find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
glbl.cgr = m-cgr and  integer(glbl.geo) = m-geo
and glbl.hs = m1-hs no-lock no-error.
if not available glbl then do:
    find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
    glbl.cgr = ? and integer(glbl.geo) = m-geo and glbl.hs = m1-hs
    no-lock no-error.
    if not available glbl then do:
	find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
	glbl.cgr = m-cgr and  integer(glbl.geo) = m-geo
	and glbl.hs = ? no-lock no-error.
	if not available glbl then do:
	    find first glbl where glbl.gl = m-gl and  glbl.sts = yes and
	    glbl.cgr = ? and integer(glbl.geo) = m-geo
	    and glbl.hs = ? no-lock no-error.
	    if not available glbl then m-key3 = no.
	end.
    end.
end.



if m-key3 then do:


		if m-srok <= 0 or m-srok = ? then m-ind = 1.
		else if m-srok <= 92 then m-ind = 2.
		else if m-srok <= 183 then m-ind = 3.
		else if m-srok <= 366 then m-ind = 4.
		else if m-srok <= 1827 then m-ind = 5.
		else m-ind = 6.

    if m-la = "L" or m-la = "O" then do:
	m-sum = - m-sum.
    end. /* учитываются только типы A и L */

    find first MenBilP where
    MenBilP.p-kodsp = glbl.p-kodsp and
    MenBilP.stabs = m-ind and
    MenBilP.kod-val = m-crccode
    no-error.
    if available MenBilP then do:
	if glbl.SignSum = true then MenBilP.summa = MenBilP.summa - m-sum.
	else MenBilP.summa = MenBilP.summa + m-sum.
    end.
    else do:
	create MenBilP.
	MenBilP.p-kodsP = glbl.p-kodsP.
	MenBilP.stabs = m-ind.
	MenBilP.kod-val = m-crccode.
	if glbl.SignSum = true then MenBilP.summa = - m-sum.
	else MenBilP.summa =  m-sum.
    end.
    m-okey = yes.
end.

else do:
    find first glbl where glbl.gl = m-gl and glbl.sts = no no-lock no-error.
    if available glbl then m-okey = yes.
    if not m-okey then
    put stream m-err "MBP -> " m-strerr1 " glbl " m-strerr2 " gl " m-gl
    " cgr->" m-cgr format "zz9-"
    " geo->" m-geo format "zz9-"
    " crc->" m-crccode format "x(3)"
    " Summa " m-sum skip.
end.


end.
