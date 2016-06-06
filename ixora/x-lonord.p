/* x-lonord.p
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

/* x-lonord.p
*/
/*define input parameter voutype as integer.*/
{global.i}
{s-lonliz.i}

def var vi as int.
def var i as int.

define shared var s-jh like jh.jh .
define shared variable s-lon   like lon.lon.
define shared variable s-gl    like gl.gl.
define buffer bjl for jl.
def var vcash as log.
define var vdb as cha format "x(9)" label " ".
define var vcr as cha format "x(9)" label " ".
define var vdes  as cha format "x(32)" label " ". /* chart of account desc */
define var vname as cha format "x(30)" label " ". /* name of customer */
define var vrem as cha format "x(55)" extent 7 label " ".
define var vamt like jl.dam extent 7 label " ".
define var vext as cha format "x(40)" label " ".
define var vtot like jl.dam label " ".
define var vcontra as cha format "x(53)" extent 5 label " ".
define var vpoint as int.
define var inc as int.
define var tdes like gl.des.
define var tty as cha format "x(20)".
define var vconsol as log.
define var vcif as cha format "x(6)" label " ".
define var vofc like ofc.ofc label  " ".
def var vcrc like crc.code label " ".
def var bcode as char format "X(10)".

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xtot like jl.cam.

def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
def buffer bpoint for point.
define new shared variable s-longl as integer extent 20.
define variable v-gl like gl.gl.

define variable s-lon%gl   like gl.gl.
define variable s-sa%gl    like gl.gl.
define variable s-glsoda%  like gl.gl.
define variable pvn_debet  like gl.gl.
define variable pvn_kredit like gl.gl.
define variable gl-noform  like gl.gl.
define variable gl-atalg   like gl.gl.
define variable gl-depo    like gl.gl.
define variable ok as logical.
define variable oper       as char extent 10 format "x(30)".
define variable tmpString  as char format "x(20)".

find jh where jh.jh eq s-jh.

find lon where lon.lon = s-lon no-lock.
find loncon where loncon.lon = s-lon no-lock.
find first lonhar where lonhar.lon = s-lon no-lock no-error.
find first lonliz where lonliz.lon = s-lon no-lock no-error.
find gl where gl.gl = lon.gl no-lock.
find cif where cif.cif = lon.cif no-lock.

v-gl = gl.gl1.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.
find bpoint where bpoint.point = 99 no-lock no-error.

run f-longl(lon.gl,"lon%gl,sa%gl,glsoda%,pvn_debet,pvn_kredit,gl-noform,gl-atalg,gl-depo",output ok).
if not ok
then do:
   bell.
   message lon.lon " - x-lonvou:"
   "longl не определен счет".
   pause.
   return.
end.

s-lon%gl   = s-longl[1].
s-sa%gl    = s-longl[2].
s-glsoda%  = s-longl[3].
pvn_debet  = s-longl[4].
pvn_kredit = s-longl[5].
gl-noform  = s-longl[6].
gl-atalg   = s-longl[7].
gl-depo    = s-longl[8].

oper[1]    = "Платеж по основной сумме".
oper[2]    = "Налог".
oper[3]    = "Банковские проценты".
oper[4]    = "Оформление лизинга".
oper[5]    = "Оплата лизинга".
oper[6]    = "Авансовый платеж".
oper[7]    = "Гарантийный депозит".

def var arp-gl like gl.gl.
find arp where arp.arp = "44" + string(lon.crc) + "liz" no-lock no-error.
if not available arp
then do:
   bell.
   message "Несуществующая АРП карточка" "44" + string(lon.crc) + "ЛИЗ".
   pause.
   return.
end.
arp-gl = arp.gl.

/* vihod is programmi esli ne opredelen status platezha */
if s-ordtype < 1 then return.

/* formatirovanie primechanija */
run s-lonfrm(s-glrem, 70).

output to vou.img page-size 0.
put skip(10).

find first cmp no-lock.
vcha1 = cmp.name.
find sysc where sysc.sysc = "CLECOD" no-lock no-error.
if available sysc then bcode = sysc.chval.

put "               " today format "99/99/9999" "         ОРДЕР -СЧЕТ                        " skip.
put "               ----------" skip.
put "                   дата "  skip.

put fill("-",80) format "x(80)" skip.

put " БАНК :" space(33) "|" " Название банка, Nr счета " skip.
put space(40) "|" skip.
put vcha1 format "x(40)" "|" vcha1 skip.
put point.addr[1] format "x(40)" "|" point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] format "x(40)" "|" point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] format "x(40)" "|" point.addr[3] skip.
put point.regno  format "x(40)" "|" skip 
    point.licno  format "x(40)" "|" skip.
put bpoint.nalno format "x(40)" "|" "     КОД:" bcode skip.

put fill("-",80) format "x(80)" skip.
put fill("-",80) format "x(80)" skip.

put "Плательщик:" format "x(40)" "|" " Название банка, Nr счета " skip.
put space(40) "|" skip.
put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(40)" "|"  skip.
if cif.addr[1] <> "" then put cif.addr[1] format "x(40)"  "|" skip.
if cif.addr[2] <> "" then put cif.addr[2] format "x(40)"  "|" skip.
if cif.addr[3] <> "" then put cif.addr[3] format "x(40)"  "|". else put space(40) "|".
put "   Счет :" loncon.konts skip.
put "Регистрац.Nr." loncon.rez-char[9] format "x(23)" "|" "    КОД :" loncon.kods  skip.

put fill("-",80) format "x(80)" skip(3).

put jh.jdt " " string(time,"HH:MM") " транзакция Nr." jh.jh skip.
do i = 1 to 10:
   if s-glremx[i] <> "" then put s-glremx[i] format "x(80)" skip.
end.
put "согласно договору лизинга NR." loncon.lcnt skip.

find first crc where crc.crc = lon.crc no-lock.
find sysc where sysc.sysc = "CASHGL" no-lock.
put fill("-",80) format "x(80)" skip.
put "        Наименование                    |Раз-|Кол-во|  Цена    |    Сумма     " skip.
put "                                        |мерн|      |          |              " skip.
put fill("-",80) format "x(80)" skip.

def var opertmp as char format "X(25)".
def var pvnstr  as char format "X(25)".
def var bezpvn  as deci.
def var pvn     as deci.

vcash = false.
xdam = 0. xcam = 0.
xtot = 0.
bezpvn = 0.
pvn    = 0.
for each jl of jh use-index jhln break by jl.ln:
    if s-ordtype = 1 and (jl.gl <> pvn_debet and jl.gl <> pvn_kredit and
                          jl.gl <> gl-noform and jl.gl <> gl-atalg   and
                          jl.gl <> arp-gl    and jl.gl <> gl-depo)
    then next.
    else if s-ordtype = 2 and (jl.gl <> pvn_debet and jl.gl <> pvn_kredit and
                               jl.gl <> lon.gl    and jl.gl <> s-lon%gl)
    then next.
    if s-ordtype = 1 and (jl.gl = arp-gl and jl.dc <> "C")
    then next.
  
    if      jl.gl = lon.gl    then opertmp = oper[1].
    else if jl.gl = pvn_debet or jl.gl = pvn_kredit 
         then do:
            if available lonhar then do:
               opertmp = oper[2] + " (" + trim(lonhar.rez-char[3]) + "%)".
               pvnstr  = opertmp.
            end.
         end.
    else if jl.gl = s-lon%gl  then opertmp = oper[3].
    else if jl.gl = gl-noform then opertmp = oper[4].
    else if jl.gl = gl-atalg  then opertmp = oper[5]. 
    else if jl.gl = arp-gl    then opertmp = oper[6].
    else if jl.gl = gl-depo   then opertmp = oper[7].
    
    if jl.gl = sysc.inval then vcash = true.
    if jl.dam ne 0 then do:
       xtot = xtot + jl.dam.
       xamt = jl.dam.
    end.
    else do:
      xtot = xtot + jl.cam.
      xamt = jl.cam.
    end.
    find crc where crc.crc eq jl.crc.
    vcrc = crc.code.
    if jl.gl <> pvn_debet and jl.gl <> pvn_kredit then do:
       if jl.dam ne 0 then bezpvn = bezpvn + jl.dam.
       else                bezpvn = bezpvn + jl.cam.
       disp opertmp format "x(40)" crc.code format "x(3)" space(15) 
            xamt format "zzz,zzz,zzz,zz9.99-" with down width 132 
            frame jlprt1 no-label no-box.
    end.
    else do:
       if jl.dam ne 0 then pvn = pvn + jl.dam.
       else                pvn = pvn + jl.cam.
    end.
end.

put fill("-",80) format "x(80)" skip.
put space (44) "Сумма без налога" format "x(15)" bezpvn format "zzz,zzz,zzz,zz9.99-" skip.
if pvn > 0 then
put space (44) pvnstr          format "x(15)" pvn    format "zzz,zzz,zzz,zz9.99-" skip.
put space (44) "Общая сумма"      format "x(15)" xtot   format "zzz,zzz,zzz,zz9.99-" skip.
put fill("-",80) format "x(80)" skip.

def var out-summa  as char.
def var out-valuta as char.
find crc where crc.crc eq lon.crc.
run Sm-vrd(truncate(xtot,0), output out-summa).
out-summa = trim(out-summa) + " " + string((xtot - truncate(xtot,0)), "9.99").
put "Общая сумма:" xtot format "zzz,zzz,zzz,zz9.99-" " " vcrc " " 
    out-summa format "x(60)" skip(4).
put "Руководитель лизинг.отдела  _____________________    Бухгалтер _____________________" skip(3)
    space(30) "Z.V."        skip.

put skip(20).
output close.
unix silent prit -t vou.img.
pause 0.
