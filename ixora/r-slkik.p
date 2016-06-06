 /* r-slkik.p
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
        4-4-8-4-5 
 * AUTHOR
        15/12/05 Natalya D.
 * CHANGES
        01/03/2006 Natalya D. - навела красоту (некоторые столбцы съузила, название отчёта по центру)
                                добавила период для формирования отчёта за период.
        06/03/2006 Natalya D. - поправила формат даты
        10/04/2006 Natalya D. - переделала под новые требования
        08/09/2006 Natalya D. - изменила i-шку по филиалам: теперь филиалы будут видеть только себя
*/

/* Отчет по продажам в КИК на дату */


def var s-bank as char no-undo.
def var v-numstr as integer no-undo.
def var dt1 as date no-undo.

{global.i}
dt1 = g-today.
message " Формируется отчет... ".
define new shared temp-table t_t3 no-undo
       field lon like lon.lon
       field name like cif.name
       field cif like lon.cif
       field vid_p as char       
       field opnamt like lon.opnamt
       field opndt like lon.opndt
       field jdt like lonres.jdt
       field prc_first as deci
       field prc_last as deci
       field zero_1lev as date
       field quar as char
       field sumqua as deci
       field insur as date
       field sum26 as deci
       field prim as char
       field code_branch like sysc.chval
       field name_branch as char
       index indx2 code_branch
       index indx3 lon
       index indx4 cif.
{r-brfilial.i &proc = "r-slkik1(input dt1)"}

define stream m-out.
output stream m-out to r-slkik.html.
{html-title.i &stream = " stream m-out "}
put stream m-out "<table><tr><td></td></tr><tr align=""center"" style=""font:bold""><td colspan=15>Кредиты по программе КИК" 
                 "</td></tr><tr><td></td></tr></table>" skip.           
put stream m-out unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td align=center>п/п</td>"
                    "<td align=center>Наименование заемщика</td>"
                    "<td align=center>Код<br>заемщика</td>"
                    "<td align=center>Вид программы<br>(рыночная или<br>государственная)</td>"
                    "<td align=center>Сумма одобренного<br>кредита</td>"
                    "<td align=center>Ставка<br>вознаграждения<br>(первоначальная)</td>"
                    "<td align=center>Ставка<br>вознаграждения<br>(действующая)</td>"
                    "<td align=center>Дата выдачи<br>кредита</td>"
                    "<td align=center>Дата выкупа</td>"
                    "<td align=center>Дата передачи<br>документов</td>" 
                    "<td align=center>Описание обеспечения</td>" 
                    "<td align=center>Сумма залога</td>" 
                    "<td align=center>Срок переоформ<br>ления страховки</td>" 
                    "<td align=center>Остаток осн.долга<br>(уровень 26)</td>" 
                    "<td align=center>Примечание</td>" 
                  "</tr></table>" skip.
v-numstr = 0 .
FOR EACH t_t3 no-lock GROUP BY t_t3.code_branch.
  if first-of(t_t3.code_branch) then do:
     s-bank = t_t3.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td colspan=4>" 
                               s-bank "</td></tr></table>" skip.
  end. 
  v-numstr = v-numstr + 1 .
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr align=""right"">"
               "<td align=""center"">" v-numstr "</td>"
               "<td>" t_t3.name format "x(60)" "</td>"
               "<td>" t_t3.cif format "x(10)" "</td>"
               "<td>" t_t3.vid_p format "x(60)" "</td>"
               "<td>" replace(string(t_t3.opnamt, ">>>>>>>>>>>9.99"),'.',',') " </td>"
               "<td>" replace(string(t_t3.prc_first, ">>9.99%"),'.',',') "</td>"               
               "<td>" replace(string(t_t3.prc_last, ">>9.99%"),'.',',') "</td>"               
               "<td>" string(t_t3.jdt, "99.99.9999") "</td>"
               "<td>" if t_t3.zero_1lev = ? then '' else string(t_t3.zero_1lev, "99.99.9999") "</td>"
               "<td>" "</td>"
               "<td>" t_t3.quar format "x(100)" "</td>" 
               "<td>" replace(string(t_t3.sumqua, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td>" if t_t3.insur = ? then '' else string(t_t3.insur, "99.99.9999") "</td>"
               "<td>" replace(string(t_t3.sum26, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td>" t_t3.prim format "x(15)" "</td>"
               "</tr></table>" skip.  
END.
  put stream m-out unformatted "</body></html>" skip.
output stream m-out close.
hide message no-pause.
unix silent cptwin r-slkik.html excel.exe.
                  
