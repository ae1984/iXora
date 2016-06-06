/* lnaudit.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Стандартные и классифицированные займы по видам экономической деятельности (цикл по всем филиалам)
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
 * BASES
        BANK COMM
 * AUTHOR
        28/11/2012 id01143(Sayat)
 * CHANGES
        24/05/2013 Sayat(id01143) - перекомпиляция в связи с изменением repFS.i по ТЗ 1303 от 01/03/2012
*/

{global.i}
def var d1 as date no-undo.
def var cntsum as decimal no-undo extent 22.
def new shared var v-reptype as integer no-undo.
def var v-vid as integer no-undo.
def var v-rash as logi.
v-reptype = 1.

{repFS.i "new"}

def new shared var v-sum_msb as deci no-undo.
def new shared var v-dt as date no-undo.
def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.
def var rezsum as deci.
def var lonsums as deci extent 10.
def var lonsumsval as deci extent 10.
def var lonsumsitog as deci extent 10.
def var lonsumsvalitog as deci extent 10.
def var i as integer.
def var k as integer.
def var sotrasl as char.
def var n as int init 0.
def var sum_od as deci.
def var m as int.
def var m1 as int.
def var prcrezafn as deci.
def var vivod as char.

d1 = g-today.
v-reptype = 5.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
       /*v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - MCБ, 5 - все"*/
       v-vid label ' Вид сумм '  format "9" validate ( v-vid > 0 and v-vid < 3, " Вид сумм - 1 (в тенге) или 2 (в тысячах тенге)") help "1 - в тенге, 2 - в тысячах тенге" skip
       v-rash label ' Расшифровка ' format "да/нет"
       skip with side-label row 5 centered frame dat.

if v-vid = 1 then do:
    m = 1.
    m1 = 2.
    vivod = '->>>>>>>>>>>>>>9.99'.
end.
else do:
    m = 1000.
    m1 = 0.
    vivod = '->>>>>>>>>>>>>>9'.
end.



def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.

{r-brfilial.i &proc = "rasshlons(d1)"}

define stream m-out.
output stream m-out to formFSKZ.htm.
put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">Стандартные и классифицированные банковские займы по видам экономической деятельности'</h3><br>" skip.
put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">АО 'ForteBank'</h3><br>" skip.
put stream m-out unformatted "<h3 colspan=20 align=""center"">Отчет на " string(d1) "</h3><br><br>" skip.

       put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=3>№</td>"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Банковские займы</td>"
/*2 */                  "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Стандартные</td>"
/*3 */                  "<td colspan=10 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные</td>"
/*4 */                  "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Безнадежные</td>"
/*5 */                  "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Специальные провизии</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Итого ссудный портфель.</td>" skip.
        put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 1 категории</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 2 категории</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 3 категории</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 4 категории</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 5 категории</td>" skip.
        put stream m-out unformatted "<tr style=""font:bold"">"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Классификация по видам экономической деятельности</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Всего</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Из них в иностранной валюте</td>" skip.
        put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>А</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>1</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>2</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>3</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>4</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>5</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>6</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>7</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>8</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>9</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>10</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>11</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>12</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>13</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>14</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>15</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>16</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>17</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>18</td>"
 skip.


i = 0.
repeat while i < 10:
    i = i + 1.
    lonsumsitog[i] = 0.
    lonsumsvalitog[i] = 0.
end.

for each codfr where codfr.codfr = "ecdivis" and lookup(codfr.code,"0,msc") = 0  no-lock:
    i = 0.
    repeat while i < 10:
        i = i + 1.
        lonsums[i] = 0.
        lonsumsval[i] = 0.
    end.
    sotrasl = codfr.code + " - " + codfr.name[1].
    for each wrkFS where  wrkFS.otrasl = sotrasl no-lock /*break by wrkFS.otrasl*/:
        rezsum = absolute(wrkFS.rezsum_afn).
        sum_od = wrkFS.ostatok_kzt.
        k = 0.
        if sum_od = 0 then do:
            if rezsum = 0 then k = 1.
            else k = 7.
        end.
        else do:
            if round(rezsum / sum_od,3) = 0 then k = 1.
            if round(rezsum / sum_od,3) > 0 and round(rezsum / sum_od,4) <= 0.05 then k = 2.
            if round(rezsum / sum_od,4) > 0.05 and round(rezsum / sum_od,4) <= 0.1 then k = 3.
            if round(rezsum / sum_od,4) > 0.1 and round(rezsum / sum_od,4) <= 0.2 then k = 4.
            if round(rezsum / sum_od,4) > 0.2 and round(rezsum / sum_od,4) <= 0.25 then k = 5.
            if round(rezsum / sum_od,4) > 0.25 and round(rezsum / sum_od,4) <= 0.5 then k = 6.
            if round(rezsum / sum_od,4) > 0.5 then k = 7.
        end.
         if k <> 0 then do:
            lonsums[k] = lonsums[k] + sum_od.
            lonsums[8] = lonsums[8] + rezsum.
            lonsums[9] = lonsums[9] + sum_od.
            if wrkFS.crc <> 1 then do:
                lonsumsval[k] = lonsumsval[k] + sum_od.
                lonsumsval[8] = lonsumsval[8] + rezsum.
                lonsumsval[9] = lonsumsval[9] + sum_od.
            end.
        end.
    end.
    i = 0.
    repeat while i < 10:
        i = i + 1.
        lonsumsitog[i] = lonsumsitog[i] + lonsums[i].
        lonsumsvalitog[i] = lonsumsvalitog[i] + lonsumsval[i].
    end.
    n = n + 1.
    put stream m-out unformatted
            "<tr>" skip
            "<td align=""center"">" n "</td>" skip
            "<td>" sotrasl "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[1] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[1] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[2] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[2] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[3] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[3] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[4] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[4] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[5] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[5] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[6] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[6] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[7] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[7] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[8] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[8] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[9] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[9] / m,m1),vivod)),'.',',') "</td>" skip
            "</tr>" skip.
end.

n = n + 1.
put stream m-out unformatted
            "<tr>" skip
            "<td align=""center"">" n "</td>" skip
            "<td>Всего</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[1] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[1] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[2] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[2] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[3] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[3] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[4] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[4] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[5] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[5] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[6] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[6] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[7] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[7] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[8] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[8] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[9] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[9] / m,m1),vivod)),'.',',') "</td>" skip
            "</tr>" skip.

/*i = 0.
repeat while i < 10:
    i = i + 1.
    lonsumsitog[i] = 0.
    lonsumsvalitog[i] = 0.
end.*/

for each codfr where codfr.codfr = "ecdivis" and lookup(codfr.code,"0") <> 0 no-lock by codfr.code:
    i = 0.
    repeat while i < 10:
        i = i + 1.
        lonsums[i] = 0.
        lonsumsval[i] = 0.
    end.
    sotrasl = codfr.code + " - " + codfr.name[1].
    for each wrkFS where wrkFS.otrasl = sotrasl no-lock /*break by wrkFS.otrasl*/ :
        rezsum = absolute(wrkFS.rezsum_afn). /*+ absolute(wrkFS.rezsum_prc) + wrkFS.rezsum_pen.*/
        sum_od = wrkFS.ostatok_kzt.
        k = 0.
        if sum_od = 0 then do:
            if rezsum = 0 then k = 1.
            else k = 7.
        end.
        else do:
            if round(rezsum / sum_od,3) = 0 then k = 1.
            if round(rezsum / sum_od,3) > 0 and round(rezsum / sum_od,4) <= 0.05 then k = 2.
            if round(rezsum / sum_od,4) > 0.05 and round(rezsum / sum_od,4) <= 0.1 then k = 3.
            if round(rezsum / sum_od,4) > 0.1 and round(rezsum / sum_od,4) <= 0.2 then k = 4.
            if round(rezsum / sum_od,4) > 0.2 and round(rezsum / sum_od,4) <= 0.25 then k = 5.
            if round(rezsum / sum_od,4) > 0.25 and round(rezsum / sum_od,4) <= 0.5 then k = 6.
            if round(rezsum / sum_od,4) > 0.5 then k = 7.
        end.
        if k <> 0 then do:
            lonsums[k] = lonsums[k] + sum_od.
            lonsums[8] = lonsums[8] + rezsum.
            lonsums[9] = lonsums[9] + sum_od.
            if wrkFS.crc <> 1 then do:
                lonsumsval[k] = lonsumsval[k] + sum_od.
                lonsumsval[8] = lonsumsval[8] + rezsum.
                lonsumsval[9] = lonsumsval[9] + sum_od.
            end.
        end.
    end.
    i = 0.
    repeat while i < 10:
        i = i + 1.
        lonsumsitog[i] = lonsumsitog[i] + lonsums[i].
        lonsumsvalitog[i] = lonsumsvalitog[i] + lonsumsval[i].
    end.
    n = n + 1.
    put stream m-out unformatted
            "<tr>" skip
            "<td align=""center"">" n "</td>" skip
            "<td>" sotrasl "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[1] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[1] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[2] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[2] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[3] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[3] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[4] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[4] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[5] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[5] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[6] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[6] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[7] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[7] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[8] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[8] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsums[9] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsval[9] / m, m1),vivod)),'.',',') "</td>" skip
            "</tr>" skip.
end.
n = n + 1.
put stream m-out unformatted
            "<tr>" skip
            "<td align=""center"">" n "</td>" skip
            "<td>Всего</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[1] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[1] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[2] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[2] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[3] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[3] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[4] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[4] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[5] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[5] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[6] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[6] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[7] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[7] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[8] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[8] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsitog[9] / m, m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(lonsumsvalitog[9] / m, m1),vivod)),'.',',') "</td>" skip
            "</tr>" skip.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin formFSKZ.htm excel.


if v-rash then do:
    define stream m-out.
    output stream m-out to formFSKZrassh.htm.
    put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">Стандартные и классифицированные банковские займы по видам экономической деятельности'</h3><br>" skip.
    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">АО 'ForteBank'</h3><br>" skip.
    put stream m-out unformatted "<h3 colspan=20 align=""center"">Отчет на " string(d1) "</h3><br><br>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">N бал. счета</td>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код<BR>заемщика</td>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Пул МСФО</td>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Группа</td>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">N договора<BR>банк. займа</td>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Объект<BR>кредитования</td>"
/*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта<BR>кредита</td>"
/*11*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОКЭД(согласно<BR>карточке клиента)</td>"
/*12*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОКЭД(по<BR>банковскому займу) клиента</td>"
/*13*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата<BR>выдачи</td>"
/*14*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Срок<BR>погашения</td>"
/*15*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата<BR>пролонгации</td>"
/*16*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дней<BR>просрочки ОД</td>"
/*17*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дней<BR>просрочки %</td>"
/*18*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Остаток ОД<BR>(в тенге)</td>"
/*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Проср. ОД(в тенге)</td>"
/*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Начисл. %<BR>(в тенге)</td>"
/*21*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Проср. %<BR>(в тенге)</td>"
/*22*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дисконт<BR>по займам</td>"
/*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">%<BR>резерва АФН</td>"
/*24*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв АФН(KZT)<BR>(1428+3305)</td>"
/*25*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв АФН(KZT)<BR> (9100) </td>"
/*26*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО ОД,<BR>(KZT)</td>"
/*27*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО %%,<BR>(KZT)</td>"
/*28*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО Пеня,<BR>(KZT)</td>"
/*29*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма резерва МСФО,<BR>(KZT)</td>"
/*30*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Истор.ставка</td></tr>" skip.
    i = 0.
    m = 1.
    m1 = 2.
    vivod = '->>>>>>>>>>>>>>9.99'.
    for each wrkFS no-lock by wrkFS.cif:
        i = i + 1.
        prcrezafn = -1.
        find first crc where crc.crc = wrkFS.crc no-lock no-error.
        if wrkFS.ostatok_kzt = 0 then do:
            if wrkFS.rezsum_afn = 0 then prcrezafn = 0. else prcrezafn = 100.
        end.
        else prcrezafn = 100 * wrkFS.rezsum_afn / wrkFS.ostatok_kzt.
        put stream m-out unformatted
            "<tr>" skip
/*1 */          "<td>" i "</td>" skip
/*2 */          "<td align=""center"">" wrkFS.schet_gk "</td>" skip
/*3 */          "<td>" wrkFS.name "</td>" skip
/*4 */          "<td>" wrkFS.cif "</td>" skip
/*5 */          "<td>" wrkFS.bankn "</td>" skip
/*6 */          "<td>" wrkFS.pooln "</td>" skip
/*7 */          "<td>" wrkFS.grp "</td>" skip
/*8 */          "<td>&nbsp;" wrkFS.num_dog "</td>" skip
/*9 */          "<td>" wrkFS.tgt "</td>" skip
/*10*/          "<td align=""center"">" crc.code "</td>" skip
/*11*/          "<td>" wrkFS.otrasl "</td>" skip
/*12*/          "<td>" wrkFS.finotrasl "</td>" skip
/*13*/          "<td>" wrkFS.isdt format "99/99/9999" "</td>" skip
/*14*/          "<td>" wrkFS.duedt format "99/99/9999" "</td>" skip
/*15*/          "<td>" wrkFS.dprolong format "99/99/9999" "</td>" skip
/*16*/          "<td align=""right"">" wrkFS.dayc_od  "</td>" skip
/*17*/          "<td align=""right"">" wrkFS.dayc_prc  "</td>" skip
/*18*/          "<td align=""right"">" replace(trim(string(round(wrkFS.ostatok_kzt / m,m1),vivod)),'.',',') "</td>" skip
/*19*/          "<td align=""right"">" replace(trim(string(round(wrkFS.prosr_od_kzt / m,m1),vivod)),'.',',') "</td>" skip
/*20*/          "<td align=""right"">" replace(trim(string(round(wrkFS.nach_prc_kzt / m,m1),vivod)),'.',',') "</td>" skip
/*21*/          "<td align=""right"">" replace(trim(string(round(wrkFS.prosr_prc_kzt / m,m1),vivod)),'.',',') "</td>" skip
/*22*/          "<td align=""right"">" replace(trim(string(round(wrkFS.zam_dk / m,m1),vivod)),'.',',') "</td>" skip
/*23*/          "<td align=""right"">" replace(trim(string(round(prcrezafn,4),'->>>>>9.99<<')),'.',',') "</td>" skip
/*24*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_afn / m,m1),vivod)),'.',',') "</td>" skip
/*25*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_afn41 / m,m1),vivod)),'.',',') "</td>" skip
/*26*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_od / m,m1),vivod)),'.',',') "</td>" skip
/*27*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_prc / m,m1),vivod)),'.',',') "</td>" skip
/*28*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_pen / m,m1),vivod)),'.',',') "</td>" skip
/*29*/          "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_msfo / m,m1),vivod)),'.',',') "</td>" skip
/*30*/          "<td align=""right"">" replace(trim(string(round(wrkFS.prem_his,4),'->>>>>9.99<<')),'.',',') "</td></tr>" skip.
                /*"</tr>" skip.*/
    end.

    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    hide message no-pause.

    unix silent cptwin formFSKZrassh.htm excel.
end.

