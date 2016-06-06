/* depst_rep.p
 * MODULE
        Депозиты с измененными ставками
 * DESCRIPTION
        Отчет по депозитам физ. лиц и юр. лиц. по которым изменилась ставка вознаграждения за период.
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        depst_rep1
 * MENU
        Пункт меню 5.3.1.17
 * AUTHOR
        26/09/2011 lyubov
 * BASES
        BANK, COMM, TXB
 * CHANGES
*/

def new shared var dt1 as date.
def new shared var dt2 as date.

def new shared temp-table wrk no-undo
field npp as int
field sch_vk as char format "x(20)"
field nd as char format "x(20)"
field grp as char
field name as char format "x(60)"
field val as char
field sumdepcrd as deci format "z,zzz,zzz,zz9.99"
field cdt as date format "99/99/9999"
field stn as deci
field stk as deci
field prolong like txb.acvolt.x3
field bank as char format "x(20)"
index bank is primary bank.

def var i as int.

form dt1 label ' Укажите период с' format '99/99/9999'
     dt2 label ' по' format '99/99/9999' skip(1)
with side-label row 5 width 48 centered frame dat.

dt2 = today.
dt1 = date(month(dt2), 1, year(dt2)).

update dt1 dt2 with frame dat.

hide frame dat.


define stream m-out.
output stream m-out to depst_rep.htm.
put stream m-out unformatted "<html><head><title>Портфель</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>METROCOMBANK</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет по депозитам физических/юридических лиц с измененными ставками</h3><br>" skip.
put stream m-out unformatted "<h3>С " string(dt1) " по " string(dt2) "</h3><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">№ п/п</TD>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет вкладчика</TD>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наим. депозита</TD>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Группа</TD>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Ф.И.О. вкладчика</TD>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</TD>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</TD>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата изм. % ставки</TD>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Ставка на нач.</TD>"
/*10 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Ставка на кон.</TD>"
/*11 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Пролонгация депозита</TD>"
/*12 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</TD>"
                        "</TR>" skip.

{r-brfilial.i &proc = "depst_rep1"}

i = 0.

for each wrk no-lock break by wrk.bank by wrk.cdt by wrk.grp:

i = i + 1.

put stream m-out unformatted
                  "<tr>" skip
/*1 */            "<td align=""center"">"  i "</TD>" skip
/*2 */            "<td>" wrk.sch_vk "</td>" skip
/*3 */            "<td>" wrk.nd "</td>" skip
/*4 */            "<td>" wrk.grp "</td>" skip
/*5 */            "<td>" wrk.name "</td>" skip
/*6 */            "<td align=""center"">" wrk.val "</td>" skip
/*7 */            "<td align=""right"">" replace(trim(string(wrk.sumdepcrd,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*8 */            "<td>" wrk.cdt format "99/99/9999" "</td>" skip
/*9 */            "<td align=""right"">" replace(trim(string(wrk.stn,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*10 */           "<td align=""right"">" replace(trim(string(wrk.stk,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*11 */           "<td align=""right"">" wrk.prolong "</td>" skip
/*12 */           "<td>" wrk.bank "</td>" skip
                  "</tr>" skip.

end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin depst_rep.htm excel.