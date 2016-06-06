/* vcrepdplout.p
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vcrepdpl.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. 1306. Оптимизация кода.
*/

{vcrepdplvar.i}

{sum2strd.i}

def var v-ncrccod like ncrc.code.
def var v-koldep as integer.
def var v-kolall as integer.
def var v-sumdep as deci.
def var v-sumall as deci.
def var v-numcif as integer.
def var v-numkon as integer.
def var v-psnum as char.
def var v-psnumnum as integer.
def var v-ctei as int.
def var v-sts as char.
def var v-filename as char init "vcrepdpl.htm".
def var v-title as char.

v-title = "ПОСТАВКЕ ТОВАРА<BR>КОНТРАКТЫ ПО ИМПОРТУ<BR>сумма проплат превышает сумму ГТД<BR>Приложение 14, строки 3, 14 по импорту<BR>(ИМПОРТ)".

def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i &stream = "stream vcrpt" &title = "Задолжники по поставке товара"}

put stream vcrpt unformatted
   "<P style='font-size:12pt;font:bold' align=center>КЛИЕНТЫ-ЗАДОЛЖНИКИ ПО " v-title "<BR>на " + string(s-dte,"99/99/9999") +
   "<BR>по контрактам с " + string(s-dtb,"99/99/9999") + "</P>" skip.

put stream vcrpt unformatted
   "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream vcrpt unformatted
    "<TR style='font-size:10pt;font:bold' align=center>" skip
/*1*/    "<TD>N</TD>" skip
/*2*/    "<TD>Код клиента</TD>" skip
/*3*/    "<TD>Наименование клиента</TD>" skip
/*4*/    "<TD>РНН</TD>" skip
/*5*/    "<TD>Номер контракта</TD>" skip
/*6*/    "<TD>Дата контракта</TD>" skip
/*7*/    "<TD>Паспорт сделки</TD>" skip
/*8*/    "<TD>Код экспорта (1)<br>или импорта (2)</TD>" skip
/*9*/    "<TD>Вал. кон.</TD>" skip
/*10*/   "<TD>Сумма задолженности<BR>в валюте контракта</TD>" skip
/*11*/   "<TD>Сумма задолженности<BR>в USD</TD>" skip
/*12*/   "<TD>Дни задолж-ти</TD>" skip
/*13*/   "<TD>СРОКИ РЕПАТРИАЦИИ</TD>" skip
/*14*/   "<TD>Сумма просроченная<BR>в USD</TD>" skip
/*15*/   "<TD>Статус<BR>конт</TD>" skip
/*16*/   "<TD>Номер<B>ЛКБК</TD>" skip
/*17*/   "<TD>Дата<BR>ЛКБК</TD>" skip
    "</TR>" skip.

/* сумма просроченных платежей */

def buffer b-t-dolgs for t-dolgs.

for each t-dolgs no-lock break by t-dolgs.txb:
    if first-of(t-dolgs.txb) then do:
        put stream vcrpt unformatted
            "<TR style='font-size:10pt;font:bold'>" skip
            "<TD colspan=17 align=left>"  t-dolgs.namefil "</TD>" skip
            "</TR>" skip.

        v-sumall = 0. v-kolall = 0. v-numkon = 0.
        for each b-t-dolgs where b-t-dolgs.txb = t-dolgs.txb no-lock break by b-t-dolgs.depart:
            v-numcif = 0. v-sumdep = 0. v-koldep = 0.
            v-numkon = v-numkon + 1.

            put stream vcrpt unformatted
                "<TR style='font-size:10pt'>" skip
        /*1*/       "<TD align=left>" string(v-numkon) "</TD>" skip
        /*2*/       "<TD align=center>" caps(b-t-dolgs.cif) "</TD>" skip
        /*3*/       "<TD align=left>" b-t-dolgs.cifname "</TD>" skip
        /*4*/       "<TD align=left>" b-t-dolgs.cifrnn "</TD>" skip.

            find first vcps where vcps.contract = b-t-dolgs.contract and vcps.dntype = "01" no-lock no-error.
            if avail vcps then do:
                v-psnum = vcps.dnnum.
                v-psnumnum = vcps.num.
            end.
            else v-psnum = "отсутствует ".
            find ncrc where ncrc.crc = b-t-dolgs.ncrc no-lock no-error.
            if avail ncrc then v-ncrccod = ncrc.code.
            else v-ncrccod = "&nbsp;".
            find vccontrs where vccontrs.contract = b-t-dolgs.contract no-lock no-error.
            if avail vccontrs then v-sts = vccontrs.sts.

            put stream vcrpt unformatted
        /*5*/       "<TD align=left>" b-t-dolgs.ctnum "</TD>" skip.

            if b-t-dolgs.ctdate <> ? then put stream vcrpt unformatted
        /*6*/       "<TD align=left>" string(b-t-dolgs.ctdate, "99/99/9999") "</TD>" skip.
            else put stream vcrpt unformatted
        /*6*/       "<TD align=left>&nbsp;</TD>" skip.

            put stream vcrpt unformatted
        /*7*/       "<TD align=left>" v-psnum + string(v-psnumnum) + "," + "&nbsp;" + "N" + "&nbsp;" + string(v-psnumnum) "</TD>" skip.

            if b-t-dolgs.ctei = "E" then v-ctei = 1.
            else v-ctei = 2.
            put stream vcrpt unformatted
        /*8*/       "<TD align=center>" v-ctei "</TD>" skip
        /*9*/       "<TD align=center>" v-ncrccod "</TD>" skip
        /*10*/      "<TD align=right>" sum2strd(b-t-dolgs.sumcon,2) "</TD>" skip
        /*11*/      "<TD align=right>" sum2strd(b-t-dolgs.sumusd,2) "</TD>" skip
        /*12*/      "<TD align=center>" sum2strd(decimal(b-t-dolgs.days),0) "</TD>" skip
        /*13*/      "<TD align=center>" substr(b-t-dolgs.ctterm,1,3) + "." + substr(b-t-dolgs.ctterm,4,2) "</TD>" skip
        /*14*/      "<TD align=right>" sum2strd(b-t-dolgs.sumdolg,2) "</TD>" skip
        /*15*/      "<TD align=center>" v-sts "</TD>" skip
        /*16*/      "<TD>" b-t-dolgs.cardnum "</TD>" skip
        /*17*/      "<TD>" b-t-dolgs.carddt "</TD>" skip
                "</TR>" skip.

            accumulate b-t-dolgs.sumusd(total count by b-t-dolgs.depart).
            accumulate b-t-dolgs.sumdolg(total count by b-t-dolgs.depart).

            if last-of(b-t-dolgs.depart) then do:
                put stream vcrpt unformatted
                    "<TR style='font-size:10pt;font:bold'>" skip
                    "<TD colspan=5>Всего (колич/сумма)</TD>" skip
                    "<TD align=right>" sum2strd(deci(accum sub-count by b-t-dolgs.depart b-t-dolgs.sumusd),0) "</TD>" skip
                    "<TD colspan=2 align=right>" sum2strd(accum sub-total by b-t-dolgs.depart b-t-dolgs.sumusd,2) "</TD>" skip
                    "<TD colspan=9></TD>" skip
                    "</TR>" skip
                    "<TR style='font-size:10pt;font:bold'>" skip
                    "<TD colspan=5>Всего просроч. (колич/сумма)</TD>" skip
                    "<TD align=right>" sum2strd(decimal(v-koldep),0) "</TD>" skip
                    "<TD colspan=2 align=right>" sum2strd(v-sumdep,2) "</TD>" skip
                    "<TD colspan=9></TD>" skip
                    "</TR>" skip.

                    v-sumall = v-sumall + v-sumdep.
                    v-kolall = v-kolall + v-koldep.
            end.
        end.
    end. /*if first-of(t-dolgs.txb)*/
end.

put stream vcrpt unformatted
    "<TR style='font-size:10pt;font:bold'>" skip
    "<TD colspan=5>ВСЕГО ПО БАНКУ (колич/сумма)</B></FONT></TD>" skip
    "<TD align=right>" sum2strd(decimal(accum count b-t-dolgs.sumusd), 0) "</TD>" skip
    "<TD colspan=2 align=right>" sum2strd(accum total b-t-dolgs.sumusd, 2) "</TD>" skip
    "<TD colspan=9>&nbsp;</TD>" skip
    "</TR>" skip
    "<TR style='font-size:10pt;font:bold'>" skip
    "<TD colspan=5>ВСЕГО ПРОСРОЧ. (колич/сумма)</TD>" skip
    "<TD align=right>" sum2strd(decimal(v-kolall),0) "</TD>" skip
    "<TD colspan=2 align=right>" sum2strd(v-sumall,2) "</TD>" skip
    "<TD colspan=9>&nbsp;</TD>" skip
    "</TR>" skip.

put stream vcrpt unformatted
    "</TABLE>" skip.

find first cmp no-lock no-error.

put stream vcrpt unformatted
    "<P style='font-size:10pt;font:bold'>" cmp.name "<br>".

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then put stream vcrpt unformatted
    entry(1, sysc.chval) + "&nbsp;<BR>" + entry(2, sysc.chval) skip.

put stream vcrpt unformatted
    "</P>" skip.

{html-end.i "stream vcrpt"}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.


