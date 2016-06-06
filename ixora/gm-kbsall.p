/* gm-kbsall.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        Балансы по всем филиалам - делает баланс и сохраняет его с соответсвующим именем
 * RUN

 * CALLER
        r-kbs1.p
 * SCRIPT

 * INHERIT

 * MENU
        9.12.5
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM TXB
 * CHANGES
        27.08.2002 nadejda  - IP-адрес для определения диска L изменен на IP-адрес сервера
        04.09.2003 nadejda  - 1. внесла каталог складывания балансов в SYSC и сделала переменные шаренными
                              2. добавила запись файла баланса и в архив тоже
        11.02.2004 suchkov  - Добавил рассылку балансов по E-Mail
        01.06.2003 nadejda  - переделала балансы так, чтобы считать на любую дату
        20.07.2004 saltanat - Добавлено сохранение данных в Excel.
        21.07.2004 saltanat - Добавлено рассылка данных в Excel формате.
        04.10.2005 nataly   - изменен порядок следования счетов
        11/10/05 nataly     - был добавлен итоговый уровень по счетам ГК
        03/08/06 nataly     - Валюта была разбита на USD,RUB,EUR
        25/07/2007 madiyar  - убрал упоминание удаленной таблицы e002
        18.11.2010 marinav  - добавили GPB
        10/09/2011 madiyar  - добавил шведские кроны, австралийские доллары и швейцарские франки
        04.07.2012 damir    - добавил ZAR,CAD.
        30.11.2012 Lyubov   - ТЗ 1374 от 23/05/2012 «Изменение счета ГК 1858»
*/

{gl-utils.i}

def input parameter v-alias as char.
def input parameter v-alname as char.

def shared var v-dat    as date.
def shared var dirc     as char format "x(15)".
def shared var dircarc  as char format "x(15)".
def shared var ipaddr   as char format "x(15)".

define buffer b-gl for txb.gl.
define buffer basecrc for txb.crchis.
define buffer crc2 for txb.crchis.
define buffer p-crc for txb.crchis.
define buffer b-crc for txb.crchis.

def var vimgfname   as character format "x(12)".
def var vimgexname  as character format "x(12)".
def var vasof       as date.
def var vbal        as deci extent 11 format 'zzz,zzz,zzz,zz9.99-'.
def var vbaltot     as decimal format 'zzz,zzz,zzz,zz9.99-'.
def var savefile    as cha.
def var v-crc       like txb.crc.crc initial 1.
def var i           as int.
def var v-name      like txb.gl.des init "".
def var vgl         like txb.pglbal.gl.
def var vtitle      as char format "x(132)".
def var vtitle-1    as char format "x(140)".
def var fname       as char format "x(12)".
def var v-result    as char.
def var exname      as char format "x(12)".

def stream exc.  /* For Excel*/


vasof = v-dat.  /*txb.sysc.daval.*/

display "   Ждите...   "  with row 5 frame ww centered .
hide message no-pause.
message " Обработка " v-alname.

vimgfname = "rpt.img".

output to rpt.img.
output stream exc to rpt1.img.

v-crc  = 1.

find last basecrc where basecrc.crc = v-crc and basecrc.rdt <= v-dat no-lock no-error.
find last txb.crchis where txb.crchis.crc = 1  and txb.crchis.rdt <= v-dat no-lock no-error.

vtitle = "БАЛАНС (ТЕНГЕ)    ЗА " + string(vasof).

vtitle-1 =
"Итог ур Г/К          НАЗВАНИЕ                       KZT                   USD                RUB                  EUR             GBP             SEK             AUD             CHF             ZAR             CAD              ВСЕГО".

put v-alname format "x(35)" today " " string(time,"HH:MM:SS") skip(1).
put vtitle skip.
put fill( "=", 150 )  format "x(150)"  skip.
put vtitle-1 skip.
put fill("=",150) format "x(150)" skip.

put stream exc unformatted v-alname format "x(35)"  today " " string(time,"HH:MM:SS") skip(1).
put stream exc unformatted vtitle skip.
put stream exc unformatted fill( "=", 110 )  format "x(110)" skip.
put stream exc unformatted ("Итог ур;Г/К;НАЗВАНИЕ;KZT;USD;RUB;EUR;GBP;SEK;AUD;CHF;ZAR;CAD;ВСЕГО") skip.
put stream exc unformatted fill("=",110) format "x(110)" skip(1).
put stream exc unformatted ("ВАЛ.;НАЗВАНИЕ;КУРС;РАЗМЕРНОСТЬ; ") skip.

for each txb.gl where txb.gl.ibfact eq false no-lock break by substr(string(txb.gl.gl),1,1) by txb.gl.gl :
    if first(substr(string(txb.gl.gl),1,1)) then do:
        for each txb.crc where txb.crc.sts ne 9 no-lock:
            find last b-crc where b-crc.crc = txb.crc.crc and b-crc.rdt <= v-dat no-lock no-error.
            disp txb.crc.crc label "ВАЛ." txb.crc.des label "НАЗВАНИЕ" b-crc.rate[1] format "zzz9.99" label "КУРС " b-crc.rate[9] format "zzzzzz9"
            label "РАЗМЕРНОСТЬ".
            put stream exc unformatted txb.crc.crc " ; " txb.crc.des " ; " XLS-NUMBER (b-crc.rate[1]) " ; " XLS-NUMBER (b-crc.rate[9]) " ; " " " skip.
        end.
        find last txb.crchis where txb.crchis.crc = 1  and txb.crchis.rdt <= v-dat no-lock no-error.
    end.

    if first-of(substr(string(txb.gl.gl),1,1)) then do:
        case substr(string(txb.gl.gl),1,1) :
            when "1" then do: put skip(1) "*** АКТИВЫ ***" skip(1).
                put stream exc unformatted skip(1) "*** АКТИВЫ ***" skip(1).
            end.
            when "2" then do: put skip(1) "*** ПАССИВЫ ***" skip(1).
                put stream exc unformatted skip(1) "*** ПАССИВЫ ***" skip(1).
            end.
            when "3" then do: put skip(1) "*** КАПИТАЛ ***" skip(1).
                put stream exc unformatted skip(1) "*** КАПИТАЛ ***" skip(1).
            end.
            when "4" then do: put skip(1) "*** ДОХОДЫ ***" skip(1).
                put stream exc unformatted skip(1) "*** ДОХОДЫ ***" skip(1).
            end.
            when "5" then do: put skip(1) "*** РАСХОДЫ ***" skip(1).
                put stream exc unformatted skip(1) "*** РАСХОДЫ ***" skip(1).
            end.
            when "6" then do: put skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС ) ***" skip(1).
                put stream exc unformatted skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС ) ***" skip(1).
            end.
            when "7" then do: put skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС ) ***" skip(1).
                put stream exc unformatted skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС ) ***" skip(1).
            end.
        end case.
    end.

    if lookup(txb.gl.type, "A,L,O,R,E") = 0 then next.

    find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = 1 and txb.glday.gdt <= v-dat no-lock no-error.
    if avail txb.glday then vbal[1] = txb.glday.bal * basecrc.rate[9] / basecrc.rate[1].

    /* other currencies */
    vbal[3] = 0.
    for each txb.crc where txb.crc.crc > 1 and txb.crc.sts <> 9 no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= v-dat no-lock no-error.
        if avail txb.glday then do:
            find last b-crc where b-crc.crc = txb.glday.crc and b-crc.rdt <= v-dat no-lock no-error.
            if      txb.glday.crc = 2  then vbal[2]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 4  then vbal[3]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 3  then vbal[4]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 6  then vbal[6]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 7  then vbal[7]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 8  then vbal[8]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 9  then vbal[9]  = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 10 then vbal[10] = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            else if txb.glday.crc = 11 then vbal[11] = txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            /*vbal[3] = vbal[3] + txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).*/
        end.
    end.

    if txb.gl.ibfgl <> 0 then do:
        find b-gl where b-gl.gl = txb.gl.ibfgl no-lock no-error.
        find last txb.glday where txb.glday.gl = txb.gl.ibfgl and txb.glday.crc = 1 and txb.glday.gdt <= v-dat no-lock no-error.
        if avail txb.glday then vbal[1] = vbal[1] + txb.glday.bal * basecrc.rate[9] / basecrc.rate[1].
        for each txb.crc where txb.crc.crc > 1 and txb.crc.sts <> 9 no-lock:
            find last txb.glday where txb.glday.gl = txb.gl.ibfgl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= v-dat no-lock no-error.
            if avail txb.glday then do:
                find last b-crc where b-crc.crc = txb.glday.crc and b-crc.rdt <= v-dat no-lock no-error.
                if      txb.glday.crc = 2  then  vbal[2]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 4  then  vbal[3]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 3  then  vbal[4]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 6  then  vbal[6]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 7  then  vbal[7]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 8  then  vbal[8]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 9  then  vbal[9]  =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 10 then  vbal[10] =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
                else if txb.glday.crc = 11 then  vbal[11] =  txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).

                /*  vbal[3] = vbal[3] + txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).*/
            end.
        end.
    end.

    vbaltot = vbal[1] + vbal[2] + vbal[3] + vbal[4] + vbal[6] + vbal[7] + vbal[8] + vbal[9] + vbal[10] + vbal[11].

    if txb.gl.vadisp and (vbaltot <> 0 or can-do('185800,185900,285800,285900',string(txb.gl.gl))) then  do:
        display txb.gl.totlev txb.gl.gl when txb.gl.gldisp
            txb.gl.des form "x(63)"
            vbal[1]
            vbal[2]
            vbal[3]
            vbal[4]
            vbal[6]
            vbal[7]
            vbal[8]
            vbal[9]
            vbal[10]
            vbal[11]
            vbaltot
        with width 160 no-label down frame bs.

        put stream exc unformatted txb.gl.totlev " ; " if txb.gl.gldisp then string(txb.gl.gl) else " " " ; "
            txb.gl.des form "x(63)" " ; "
            XLS-NUMBER (vbal[1])  " ; "
            XLS-NUMBER (vbal[2])  " ; "
            XLS-NUMBER (vbal[3])  " ; "
            XLS-NUMBER (vbal[4])  " ; "
            XLS-NUMBER (vbal[6])  " ; "
            XLS-NUMBER (vbal[7])  " ; "
            XLS-NUMBER (vbal[8])  " ; "
            XLS-NUMBER (vbal[9])  " ; "
            XLS-NUMBER (vbal[10]) " ; "
            XLS-NUMBER (vbal[11]) " ; "
            XLS-NUMBER (vbaltot)  skip.

        if txb.gl.nskip <> 0 then down 1 with frame bs.
    end.
end.
hide frame rptbottomaa.
display SKIP(10) with frame rptendbb no-box no-label .
put chr(12) skip.

/*vtitle = "ДОХОДЫ И РАСХОДЫ        ЗА " + string(vasof).

vtitle-1 =
" Г/К          НАЗВАНИЕ                       НАЦИОНАЛЬНАЯ ВАЛЮТА        "
 + "ПРОЧИЕ ВАЛЮТЫ               ВСЕГО".

put v-alname format "x(35)" today " " string(time,"HH:MM:SS") skip(1).
put vtitle skip.
put fill( "=", 110 )  format "x(110)"  skip.
put vtitle-1 skip.
put fill("=",110) format "x(110)" skip.

put stream exc unformatted v-alname format "x(35)" today " " string(time,"HH:MM:SS") skip(1).
put stream exc unformatted vtitle skip.
put stream exc unformatted fill( "=", 110 )  format "x(110)" skip.
put stream exc unformatted ("Г/К;НАЗВАНИЕ;НАЦИОНАЛЬНАЯ ВАЛЮТА;ПРОЧИЕ ВАЛЮТЫ;ВСЕГО") skip.
put stream exc unformatted fill("=",110) format "x(110)" skip.
  */
hide frame rptbottombb.
output stream exc close.
output close.



fname = v-alias + substring(string(vasof),1,2) + substring(string(vasof),4,2) + ".txt".
exname = v-alias + substring(string(vasof),1,2) + substring(string(vasof),4,2) + ".csv".

def var v-ans as logical.
v-ans = yes.

find txb.sysc where txb.sysc.sysc eq "GLDATE" no-lock no-error.
if v-dat < sysc.daval then do:
    message skip " Балансы уже были сохранены!~n~n Сохранить новый баланс" fname "в каталог" dirc "?"
    skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.
end.

if v-ans then do:

/* suchkov - Отправить готовый файл по почте! */
/*unix silent rcode rpt.img value(fname) -kw > /dev/null.*/

unix silent un-dos rpt.img value(fname).
/*
find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if not available sysc then
message "Не настроен адрес отправки баланса!" view-as alert-box.
else do:
run mail (entry(6, sysc.chval,"|"),"bank@metrocombank.kz","Баланс", "В приложении содержится баланс","1","",fname) .
pause 0 .
end.
*/
/* saltanat - Отправка Ехсел файла по почте */
/*unix silent rcode rpt1.img value(exname) -kw > /dev/null.*/
unix silent un-win rpt1.img value(exname).
find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if not available sysc then
message "Не настроен адрес отправки баланса!" view-as alert-box.
else do:
run mail (entry(6, sysc.chval,"|"),"bank@metrocombank.kz","Баланс в Excel", "В приложении содержится баланс в Excel","1","",exname) .
pause 0 .
end.



input through value("scp -q " + fname + " Administrator@fs01.metrobank.kz:" + dirc + ";echo $?" ).
repeat:
import v-result.
end.
pause 0.

if v-result <> "0" then do:
message skip " Произошла ошибка при копировании файла" fname "в каталог" dirc "!"
skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.


input through value("scp -q " + exname + " Administrator@fs01.metrobank.kz:" + dirc + ";echo $?").
repeat:
import v-result.
end.
pause 0.

if v-result <> "0" then do:
message skip " Произошла ошибка при копировании файла" exname "в каталог" dirc "!"
skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

input through value("scp -q " + fname + " Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?" ).
repeat:
import v-result.
end.
pause 0.

if v-result <> "0" then do:
message skip " Произошла ошибка при копировании файла" fname "в каталог" dircarc "!"
skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

input through value("scp -q " + exname + " Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?" ).
repeat:
import v-result.
end.
pause 0.

if v-result <> "0" then do:
message skip " Произошла ошибка при копировании файла" exname "в каталог" dircarc "!"
skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

end.
else
run menu-prt ("rpt.img").











