/* pkan1.p
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

{global.i}
{pk.i new}

/**
s-credtype = '1'.
**/

def var i as integer.
def new shared var d1 as date.
def var crlf as char.
def var coun as int init 1.
def var cnt as decimal extent 6.
def var v-cif like bank.lon.cif. 
def var kolk as int extent 10.
def var kolz as int extent 2.
def var sumk as decimal extent 10.
def var prck as decimal extent 10.

def var prc as decimal extent 4.
def var srk as decimal extent 14.
def var vsrk as decimal init 0.

def var svald as decimal.
def var svalt as decimal.

prc[1] = 0. prc[2] = 0.

def new shared temp-table  wrk
    field cif    like bank.lon.cif
    field lon    like bank.lon.lon
    field name   like bank.cif.name
    field sts    as   char
    field gua    like bank.lon.gua
    field amoun  like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field dt1    like bank.lon.rdt
    field dt2    like bank.lon.rdt
    field dt3    like bank.lon.rdt
    field duedt  like bank.lon.rdt
    field rez    like bank.lonstat.prc
    field srez   like bank.lon.opnamt
    field zalog  like bank.lon.opnamt
    field srok   as deci.

  

crlf = chr(10) + chr(13).
    /*для долларов*/
       cnt[1] = 0.   /*заявленная*/
       cnt[2] = 0.   /*реальная*/
       cnt[3] = 0.   /*провизия*/
   /*для тенге*/
       cnt[4] = 0.
       cnt[5] = 0.
       cnt[6] = 0.


d1 = g-today.
update d1 label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .


define stream m-out.
output stream m-out to rpt.html.
put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf.

output stream m-out close.

run pkan2 (input d1).

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.regdt le d1 no-lock no-error.

define stream m-out.
output stream m-out to rpt.html append.
             

for each wrk break by wrk.cif. 
   if wrk.cif <> v-cif and wrk.crc = 1 then  kolz[1] = kolz[1] + 1.
   if wrk.cif <> v-cif and wrk.crc = 2 then  kolz[2] = kolz[2] + 1.
    v-cif = wrk.cif.

   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.

    if wrk.crc = 2 then do:             
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       cnt[3] = cnt[3] + wrk.srez.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       prc[4] = prc[4] + wrk.balans * wrk.srok.
    end.
    if wrk.crc = 1 then do:             
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.
    end.
    
    if wrk.crc = 1 and wrk.sts = '0' and wrk.srok <= 365 then do:
       kolk[1] = kolk[1] + 1.
       sumk[1] = sumk[1] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts = '0' and wrk.srok <= 365 then do:
       kolk[2] = kolk[2] + 1.
       sumk[2] = sumk[2] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts <> '0' and wrk.srok <= 365 then do:
       kolk[3] = kolk[3] + 1.
       sumk[3] = sumk[3] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts <> '0' and wrk.srok <= 365 then do:
       kolk[4] = kolk[4] + 1.
       sumk[4] = sumk[4] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts = '0' and wrk.srok > 365 then do:
       kolk[5] = kolk[5] + 1.
       sumk[5] = sumk[5] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts = '0' and wrk.srok > 365 then do:
       kolk[6] = kolk[6] + 1.
       sumk[6] = sumk[6] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts <> '0' and wrk.srok > 365 then do:
       kolk[7] = kolk[7] + 1.
       sumk[7] = sumk[7] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts <> '0' and wrk.srok > 365 then do:
       kolk[8] = kolk[8] + 1.
       sumk[8] = sumk[8] + wrk.balans.
    end.


    coun = coun + 1.
    if wrk.crc = 1 then vsrk = wrk.balans / bank.crchis.rate[1].
    if wrk.crc = 2 then vsrk = wrk.balans.
 
    if wrk.srok < 0 then srk[1] = srk[1] + vsrk.
    if wrk.srok <= 30  and wrk.srok >= 0   then srk[2] = srk[2] + vsrk.
    if wrk.srok <= 60  and wrk.srok > 30  then srk[3] = srk[3] + vsrk.
    if wrk.srok <= 90  and wrk.srok > 60  then srk[4] = srk[4] + vsrk.
    if wrk.srok <= 120 and wrk.srok > 90  then srk[5] = srk[5] + vsrk.
    if wrk.srok <= 150 and wrk.srok > 120 then srk[6] = srk[6] + vsrk.
    if wrk.srok <= 180 and wrk.srok > 150 then srk[7] = srk[7] + vsrk.
    if wrk.srok <= 210 and wrk.srok > 180 then srk[8] = srk[8] + vsrk.
    if wrk.srok <= 240 and wrk.srok > 210 then srk[9] = srk[9] + vsrk.
    if wrk.srok <= 270 and wrk.srok > 240 then srk[10] = srk[10] + vsrk.
    if wrk.srok <= 300 and wrk.srok > 270 then srk[11] = srk[11] + vsrk.
    if wrk.srok <= 330 and wrk.srok > 300 then srk[12] = srk[12] + vsrk.
    if wrk.srok <= 360 and wrk.srok > 330 then srk[13] = srk[13] + vsrk.
    if wrk.srok > 360 then srk[14] = srk[14] + vsrk.

end.

put stream m-out "<tr align=""center""><td><h3>Анализ кредитного портфеля за "
                 string(d1) "</h3></td></tr><br><br>"
                 crlf crlf.
 put stream m-out "<tr></tr>".


/*put stream m-out
                 "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ДОЛЛАРАХ США </b></td> <td></td> "
                 "<td align=""right""><b> " cnt[1] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b> " cnt[2] format '>>>>>>>>>>>9.99' "</b></td><td></td>"
                 "<td align=""right""><b> " prc[1] / cnt[2] format '>9.99%' "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</td></tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ТЕНГЕ </b></td> <td></td>" 
                 "<td align=""right""><b> " cnt[4] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b>" cnt[5] format '>>>>>>>>>>>9.99' "</b></td><td></td>"
                 "<td align=""right""><b> " prc[2] / cnt[5] format '>9.99%' "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</table></td></tr>" crlf.
*/


svald = (cnt[5] / bank.crchis.rate[1] + cnt[2]).
svalt = (cnt[5] / bank.crchis.rate[1] + cnt[2]) * bank.crchis.rate[1].

put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td align=""center""></td>"
                  "<td align=""center"">Количество заемщиков</td>"
                  "<td align=""center"">Кол-во кредитов</td>"
                  "<td align=""center"">Сумма</td></tr>" crlf.

put stream m-out
                 "<td><b> КРЕДИТНЫЙ ПОРТФЕЛЬ, KZT </b></td>"
                 "<td align=""center"" valign=""top"" rowspan=2><b>" kolz[1] + kolz[2] "</td> "
                 "<td align=""center"" valign=""top"" rowspan=2><b>" kolk[1] + kolk[2] + kolk[3] + kolk[4] + kolk[5] + kolk[6] + kolk[7] + kolk[8]"</b></td>"
                 "<td align=""right""><b> " (cnt[5] / bank.crchis.rate[1] + cnt[2]) * bank.crchis.rate[1] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> КРЕДИТНЫЙ ПОРТФЕЛЬ, USD </b></td>"
                 "<td align=""right""><b> " (cnt[5] / bank.crchis.rate[1] + cnt[2]) format '>>>>>>>>>>>9.99' "</b></td> " 
                 "</table></td></tr>" crlf.


put stream m-out
                 "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf 
                 "<tr align=""left"">"
                 "<td><b> В ДОЛЛАРАХ США </b></td>"
                 "<td align=""center""><b>" kolz[2] "</td> "
                 "<td align=""center""><b>" kolk[2] + kolk[4] + kolk[6] + kolk[8] "</b></td>"
                 "<td align=""right""><b> " sumk[2] + sumk[4] + sumk[6] + sumk[8] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " (sumk[2] + sumk[4] + sumk[6] + sumk[8]) / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> В ТЕНГЕ </b></td>"
                 "<td align=""center""><b>" kolz[1] "</td> "
                 "<td align=""center""><b>"kolk[1] + kolk[3] + kolk[5] + kolk[7]"</b></td>"
                 "<td align=""right""><b> " sumk[1] + sumk[3] + sumk[5] + sumk[7]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " (sumk[1] + sumk[3] + sumk[5] + sumk[7]) / svalt * 100  format '>>9.99%' "</i></td> " 
                 "</table></td></tr>" crlf.


put stream m-out "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td align=""center""></td>"
                  "<td align=""center"">Валюта кредита</td>"
                  "<td align=""center"">Кол-во кредитов</td>"
                  "<td align=""center"">Сумма</td>"
                  "<td align=""center"">Доля в портфеле</td></tr>" crlf.


put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Краткосрочные кредиты юридических лиц</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[1] "</b></td>"
                 "<td align=""right""><b> " sumk[1]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[1] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[2] "</b></td>"
                 "<td align=""right""><b> " sumk[2]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[2] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Краткосрочные кредиты физических лиц</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[3] "</b></td>"
                 "<td align=""right""><b> " sumk[3]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[3] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[4] "</b></td>"
                 "<td align=""right""><b> " sumk[4]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[4] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Долгосрочные кредиты юридических лиц</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[5] "</b></td>"
                 "<td align=""right""><b> " sumk[5]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[5] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[6] "</b></td>"
                 "<td align=""right""><b> " sumk[6]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[6] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Долгосрочные кредиты физических лиц</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[7] "</b></td>"
                 "<td align=""right""><b> " sumk[7]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[7] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[8] "</b></td>"
                 "<td align=""right""><b> " sumk[8]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i>" sumk[8] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</table></tr>" crlf.



put stream m-out
                 "<br><br><br><br><tr align=""left"">"
                 "<td></td><td><b> Провизии на текущую дату </b></td> "
                 "</tr>" crlf.



put stream m-out
                 "<br><br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""><br><tr align=""left"">"
                 "<td><b> Сумма резервов по кредитам в USD </b></td> "
                 "<td align=""right""><b> " cnt[3] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b> " cnt[3] / cnt[2] * 100 format '>>9.99%' "</b></td>"
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> Сумма резервов по кредитам в KZT </b></td> " 
                 "<td align=""right""><b> " cnt[6] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b> " cnt[6] / cnt[5] * 100 format '>>9.99%' "</b></td>"
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> ИТОГО РЕЗЕРВОВ В ДОЛЛ США</b></td> " 
                 "<td align=""right""><b> " cnt[6] / bank.crchis.rate[1] + cnt[3] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b> " (cnt[6] / bank.crchis.rate[1] + cnt[3]) / (cnt[5] / bank.crchis.rate[1] + cnt[2]) * 100 format '>>9.99%' "</b></td>"
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> ИТОГО РЕЗЕРВОВ В KZT</b></td> " 
                 "<td align=""right""><b> " (cnt[6] / bank.crchis.rate[1] + cnt[3]) * bank.crchis.rate[1] format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><b> " (cnt[6] / bank.crchis.rate[1] + cnt[3]) / (cnt[5] / bank.crchis.rate[1] + cnt[2]) * 100 format '>>9.99%' "</b></td>"
                 "</table></td></tr>" crlf.


/*********************/

do i = 1 to  10:
   kolk[i] = 0.
end.
do i = 1 to  10:
   sumk[i] = 0.
end.
 
for each wrk:

    if wrk.crc = 1 and wrk.rez = 0 then do:
       kolk[1] = kolk[1] + 1.
       sumk[1] = sumk[1] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.rez = 0 then do:
       kolk[2] = kolk[2] + 1.
       sumk[2] = sumk[2] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.rez <= 10 and wrk.rez > 0 then do:
       kolk[3] = kolk[3] + 1.
       sumk[3] = sumk[3] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.rez <= 10 and wrk.rez > 0 then do:
       kolk[4] = kolk[4] + 1.       
       sumk[4] = sumk[4] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.rez > 10 and  wrk.rez <= 25  then do:
       kolk[5] = kolk[5] + 1.
       sumk[5] = sumk[5] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.rez > 10 and  wrk.rez <= 25 then do:
       kolk[6] = kolk[6] + 1.
       sumk[6] = sumk[6] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.rez = 50  then do:
       kolk[7] = kolk[7] + 1.
       sumk[7] = sumk[7] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.rez = 50  then do:
       kolk[8] = kolk[8] + 1.
       sumk[8] = sumk[8] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.rez = 100  then do:
       kolk[9] = kolk[9] + 1.
       sumk[9] = sumk[9] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.rez = 100 then do:
       kolk[10] = kolk[10] + 1.
       sumk[10] = sumk[10] + wrk.balans.
    end.
end.

put stream m-out "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td align=""center""></td>"
                  "<td align=""center"">Валюта кредита</td>"
                  "<td align=""center"">Кол-во кредитов</td>"
                  "<td align=""center"">Сумма</td>"
                  "<td colspan=2 align=""center"">Доля в портфеле</td></tr>" crlf.


put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Стандартные</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[1] "</b></td>"
                 "<td align=""right""><b> " sumk[1]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[1] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "<td align=""center"" valign=""top"" rowspan=2 ><i> " sumk[1] / svalt * 100 + sumk[2] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[2] "</b></td>"
                 "<td align=""right""><b> " sumk[2]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[2] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Неудовлетворительные</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[3] "</b></td>"
                 "<td align=""right""><b> " sumk[3]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[3] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "<td align=""center"" valign=""top"" rowspan=2 ><i> " sumk[3] / svalt * 100 + sumk[4] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[4] "</b></td>"
                 "<td align=""right""><b> " sumk[4]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[4] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Сомнительные</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[5] "</b></td>"
                 "<td align=""right""><b> " sumk[5]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[5] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "<td align=""center"" valign=""top"" rowspan=2 ><i> " sumk[5] / svalt * 100 + sumk[6] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[6] "</b></td>"
                 "<td align=""right""><b> " sumk[6]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[6] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Сомнительные с повышенным риском</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[7] "</b></td>"
                 "<td align=""right""><b> " sumk[7]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[7] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "<td align=""center"" valign=""top"" rowspan=2 ><i> " sumk[7] / svalt * 100 + sumk[8] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[8] "</b></td>"
                 "<td align=""right""><b> " sumk[8]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[8] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td rowspan=2><b> Безнадежные</b></td>"
                 "<td align=""center""><b> KZT</b></td>"
                 "<td align=""center""><b>"kolk[9] "</b></td>"
                 "<td align=""right""><b> " sumk[9]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[9] / svalt * 100 format '>>9.99%' "</i></td> " 
                 "<td align=""center"" valign=""top"" rowspan=2 ><i> " sumk[9] / svalt * 100 + sumk[10] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td align=""center""><b> USD</b></td>"
                 "<td align=""center""><b>"kolk[10] "</b></td>"
                 "<td align=""right""><b> " sumk[10]  format '>>>>>>>>>>>9.99' "</b></td> " 
                 "<td align=""right""><i> " sumk[10] / svald * 100 format '>>9.99%' "</i></td> " 
                 "</table></tr>" crlf.

/*********************/








/*put stream m-out
                 "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""><br><tr align=""left"">"
                 "<td><b> СРЕДНЕВЗВЕШЕННАЯ СТАВКА ПОРТФЕЛЯ </b></td> <td></td><td></td> "
                 "<td align=""right""><b> " prc[3] / (cnt[5] / bank.crchis.rate[1] + cnt[2]) format '>9.99%' "</b></td> " 
                 "</tr>" crlf.
*/
put stream m-out
                "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""><br><tr align=""left"">"
                 "<td><b> СРЕДНЕВЗВЕШЕННЫЙ СРОК ПОРТФЕЛЯ (дней) </b></td> "
                 "<td align=""right""><b> " prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2]) format '>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> СРЕДНЕВЗВЕШЕННЫЙ СРОК ПОРТФЕЛЯ (мес) </b></td> "
                 "<td align=""right""><b> " (prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2])) / 30  format '>>>>>9.99' "</b></td> " 
                 "</table></tr>" crlf.


put stream m-out
                 "<br><br><br><br><tr align=""left"">"
                 "<td></td><td><b> Структура кредитного портфеля по срокам погашения </b></td> "
                 "</tr><br>" crlf.


put stream m-out
                 "<br><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""><tr align=""left"">"
                 "<td><b> Просроченные</b></td> "
                 "<td align=""right""><b> " srk[1] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> менее 30 дн </b></td> "
                 "<td align=""right""><b> " srk[2] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 30 до 60 </b></td> "
                 "<td align=""right""><b> " srk[3] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 60 до 90 </b></td> "
                 "<td align=""right""><b> " srk[4] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 90 до 120 </b></td> "
                 "<td align=""right""><b> " srk[5] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 120 до 150 </b></td>"
                 "<td align=""right""><b> " srk[6] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 150 до 180 </b></td>"
                 "<td align=""right""><b> " srk[7] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 180 до 210 </b></td> "
                 "<td align=""right""><b> " srk[8] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 210 до 240 </b></td> "
                 "<td align=""right""><b> " srk[9] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 240 до 270 </b></td> "
                 "<td align=""right""><b> " srk[10] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 270 до 300 </b></td> "
                 "<td align=""right""><b> " srk[11] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 300 до 330 </b></td> "
                 "<td align=""right""><b> " srk[12] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> от 330 до 360 </b></td>  "
                 "<td align=""right""><b> " srk[13] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.
put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> более 1 года </b></td> "
                 "<td align=""right""><b> " srk[14] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</tr>" crlf.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td><b> ИТОГО </b></td> "
                 "<td align=""right""><b> " srk[1] + srk[2] + srk[3] + srk[4] + srk[5] + srk[6] + srk[7] + srk[8] + srk[9] + srk[10] + srk[11] + srk[12] + srk[13] + srk[14] format '>>>>>>>>>>>>9.99' "</b></td> " 
                 "</table></tr>" crlf.

put stream m-out "</body></html>" crlf.
output stream m-out close.

unix silent cptwin rpt.html excel.exe. 
