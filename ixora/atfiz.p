/* atfiz.p
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

/*atfiz.p*/

{global.i}
def var i as int.
def var j as int.
def var v-index as int.
def stream m-out.
def var dest as char.
def var v-first as log.
def var v-type as log.
def var s-type as char.
def var v-okey as log.
def var v-dbeg as date.
def var v-dend as date.
def var v-name as char.
def var v-sta as char.
def var v-ofic as char.
def var v-zakr as char.
def var v-sum like aaa.cbal.
def var v-sum1 like aaa.cbal.


def temp-table sssfil
    field saaa like aaa.aaa
    field sregdt like aaa.regdt
    field sexpdt like aaa.expdt
    field scrc   like crc.crc
    field ddate as integer
    field scode  like crc.code
    field opnsum like aaa.cbal
    field sbal   like aaa.cbal
    field srate  like aaa.rate
    field scif   like cif.cif
    field sname  like cif.name
    field sjss   like cif.jss
    field saddr1 like cif.addr[1] 
    field saddr2 like cif.addr[2]   
    field swho like aaa.who.

v-dbeg = g-today.
v-dend = g-today.
v-sum = 0.
v-sum1 = 0.

dest = "prit".
{aaatoday.f}
/*
def var vappend as log format "Turpin–t/No jauna".
form "Turpin–t (T) vai No jauna (N) ?" vappend
format "Turpin–t/No jauna"
skip
     "Drukas komanda " dest format "x(40)" skip
     with row 4 no-box no-label centered frame image1.
*/


update vappend dest with frame image1.
{jat0.f}
/*
{aaatoday0.f}
repeat :
display "Datums ...   no " v-dbeg "  lЁdz " v-dend with frame cc row 14
column 30 no-label no-box.
update   v-dbeg v-dend with frame cc.
if v-dbeg <= v-dend and v-dend <= g-today then leave.
end.
*/
find ofc where ofc.ofc = g-ofc no-lock no-error.

    if vappend then output stream m-out to rpt.img append.
    else
    output stream m-out to rpt.img.
    {atfiz.f}
    view stream m-out frame bab.
    hide frame bab.
/*
{aaatoday2.f}
*/

put stream m-out fill("=",235) format "x(235)" skip.
put stream m-out "НОМЕР СЧЕТА      С          ПО     КОЛ-ВО ДНЕЙ  ВАЛЮТА".
put stream m-out "      СУММА ДЕПОЗИТА  ВНЕСЕННАЯ СУММА".
put stream m-out "   ПРОЦЕНТНАЯ СТАВКА  ".
put stream m-out "                  ИНФОРМАЦИЯ О КЛИЕНТЕ". 
put stream m-out fill(" ",73) format "x(73)" "КТО ОТКРЫЛ" skip.
put stream m-out fill("=",235) format "x(235)" skip.

    for each aaa where (aaa.gl eq 220320 or aaa.gl eq 221120 or
      aaa.gl eq 221520 or aaa.gl eq 221720 ) and
    aaa.stadt >= v-dbeg and aaa.stadt <= v-dend
    break by aaa.crc /*by aaa.aaa*/ :
        find crc where crc.crc eq aaa.crc no-lock no-error.
        find cif where cif.cif eq aaa.cif no-lock no-error.
        if available crc then do:
                create sssfil.
                sssfil.saaa   = aaa.aaa.
                sssfil.sregdt = aaa.regdt.
                sssfil.sexpdt = aaa.expdt.
                sssfil.ddate  = aaa.expdt - aaa.regdt.
                sssfil.scrc   = crc.crc.
                sssfil.scode  = crc.code.
                sssfil.opnsum = aaa.opnamt.
                sssfil.sbal   = aaa.cr[1] - aaa.dr[1].
                sssfil.srate  = aaa.rate.
                sssfil.scif   = cif.cif.
                sssfil.sname  = trim(trim(cif.prefix) + " " + trim(cif.name)).
                sssfil.sjss   = cif.jss.
                sssfil.saddr1  = cif.addr[1]. 
                sssfil.saddr2  = cif.addr[2].   
                sssfil.swho   = aaa.who.
        end.
    end.
for each sssfil where scrc = 2 break by sexpdt desc by scrc by saaa:
    put stream m-out saaa "    " sregdt "    " sexpdt "" ddate "      " 
    scode "" opnsum ""
    sbal " " srate "  " scif "  " sssfil.sname "   "
    sjss "  " saddr1 "" saddr2 "  "  swho skip.
    v-sum = v-sum + sssfil.opnsum.
    v-sum1 = v-sum1 + sssfil.sbal.
end.

put stream m-out fill("=",235) format "x(235)" skip.
put stream m-out "ИТОГО " space(50) v-sum v-sum1 skip.
put stream m-out fill("=",235) format "x(235)" skip.

v-sum = 0.
v-sum1 = 0.
for each sssfil where scrc = 1 break by sexpdt desc by scrc by saaa:
    put stream m-out saaa "    " sregdt "    " sexpdt "" ddate "      " 
    scode "" opnsum ""
    sbal " " srate "  " scif "  " sssfil.sname "   "
    sjss "  " saddr1 "" saddr2 "  "  swho skip.
    v-sum = v-sum + sssfil.opnsum.
    v-sum1 = v-sum1 + sssfil.sbal.
end.
put stream m-out fill("=",235) format "x(235)" skip.
put stream m-out "ИТОГО " space(50) v-sum v-sum1 skip.
put stream m-out fill("=",235) format "x(235)" skip.

v-sum = 0.
v-sum1 = 0.
for each sssfil where scrc > 2 break by sexpdt desc by scrc by saaa:
    put stream m-out saaa "    " sregdt "    " sexpdt "" ddate "      " 
    scode "" opnsum ""
    sbal " " srate "  " scif "  " sssfil.sname "   "
    sjss "  " saddr1 "" saddr2 "  "  swho skip.
    v-sum = v-sum + sssfil.opnsum.
    v-sum1 = v-sum1 + sssfil.sbal.
end.

if v-sum ne 0 then do:
put stream m-out fill("=",235) format "x(235)" skip.
put stream m-out "ИТОГО " space(50) v-sum v-sum1 skip.
end.

output stream m-out close.
unix silent value(trim(dest)) rpt.img.
