 /* r-crcstm.p
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
        4-4-2-16-16-7
 * AUTHOR
        22/12/2005 Natalya D.
 * CHANGES
        01/03/2006 Natalya D. - навела красоту (некоторые столбцы съузила, название отчёта по центру)
        06/03/2006 Natalya D. - поправила шрифт
*/

/* Кредитный портфель по клиентам*/

def var v-numstr  as integer.
def var d_date as date.
def var v-kurs as decimal.
def var s-bank as char.

define new shared temp-table tmp_t1
       field code_cstm like lon.cif
       field name_cstm as char /*like cif.name */
       field vid_p as char
       field srok_p as int
       field opnamt like lon.opnamt
       field num_doc as char
       field ost_kzt as decimal
       field ost_usd as decimal
       field curr as char format "x(3)" 
       field prem like lon.prem 
       field opndt like lon.opndt
       field duedt like lon.duedt
       field protec as char
       field protec_usd as decimal
       field reserv as decimal
       field reserv_amt as decimal
       field srok as int format "->>>>>9"
       field manager as char
       field code_branch like sysc.chval
       field name_branch as char
       index indx1 curr
       index indx2 code_branch.

define new shared temp-table tmp_t2
       field manager as char
       field code_manager as char
       field sum_usd as decimal
       field cnt_cstm as integer
       field part as decimal
       field code_branch like sysc.chval
       field name_branch as char
       index indx3 code_branch.

form
   skip(1)
   d_date label 'Введите дату за которую необходимо сформировать отчёт' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.


d_date = today.
update d_date with frame f-dt.


find prev crchis where crchis.rdt = d_date and crchis.crc=2 no-lock.
  v-kurs = crchis.rate[1].         


{r-branch.i &proc = "r-crcstm1.p (input d_date, input v-kurs)"}

define stream m-out.
output stream m-out to r-crcstm.html.

put {&stream} unformatted 
   "<HTML>" skip 
   "<HEAD>" skip
   "<TITLE>" skip.
put stream  m-out unformatted 
   "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: " skip.

put stream m-out unformatted    
       "{&size-add}". 

put stream m-out unformatted        
       "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

put stream m-out "<table><tr><td></td></tr><tr align=""center"" style=""font:bold""><td colspan=19>Кредитный портфель по клиетам на  " string(d_date)"</td></tr><tr><td></td></tr></table>" skip.           

/*КРЕДИТЫ*/
put stream m-out unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td align=center>П/п</td>"
                    "<td align=center>Код заемщика</td>"
                    "<td align=center>ФИО заемщика</td></td>"
                    "<td align=center>Вид продукта</td>"
                    "<td align=center>Срок<br>(в месяцах)</td>"
                    "<td align=center>Одобренная<br>сумма</td>"
                    "<td align=center>Номер договора банк.<br>займа</td>"
                    "<td align=center>Сумма остатка по кредиту,<br>KZT</td>"
                    "<td align=center>Валюта</td>"
                    "<td align=center>% ставка</td>"
                    "<td align=center>Дата выдачи<br>займа</td>"
                    "<td align=center>Дата погашения<br>займа</td>"
                    "<td align=center>Наименование обеспечение</td>"
                    "<td align=center>Обеспечение<br>USD</td>"
                    "<td align=center>Резерв %</td>"
                    "<td align=center>Сформированная<br>сумма резерва</td>"
                    "<td align=center>Остаток срока<br>(в днях)</td>"
                    "<td align=center>Обслуживает менеджер</td>"
                    "<td align=center>Уведомление</td></td>" 
                  "</tr></table>" skip.
v-numstr = 0.

FOR EACH tmp_t1 no-lock GROUP BY tmp_t1.code_branch.
  if first-of(tmp_t1.code_branch) then do:
     s-bank = tmp_t1.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td colspan=4>" s-bank "</td></tr></table>" skip.
  end.
  v-numstr = v-numstr + 1.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font-size:x-small"" align=""right"">"
               "<td align=""center""> " v-numstr "</td>"
               "<td align=""left""> " tmp_t1.code_cstm "</td>"
               "<td align=""left""> " caps(tmp_t1.name_cstm) format "x(60)" "</td>"
               "<td align=""left""> " tmp_t1.vid_p format "x(30)" "</td>"
               "<td align=""left""> " tmp_t1.srok_p "</td>"
               "<td align=""left""> " replace(string(tmp_t1.opnamt, ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""left""> " tmp_t1.num_doc format "x(10)" "</td>"
               "<td align=""left""> " replace(string(tmp_t1.ost_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " tmp_t1.curr "</td>"
               "<td align=""left""> " replace(string(tmp_t1.prem, ">>9.99%"),'.',',') "</td>" 
               "<td align=""left""> " tmp_t1.opndt format "99/99/9999" "</td>"
               "<td align=""left""> " tmp_t1.duedt format "99/99/9999" "</td>"
               "<td align=""left""> " tmp_t1.protec format "x(30)" "</td>"
               "<td align=""left""> " replace(string(tmp_t1.protec_usd, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t1.reserv, ">>9.99%"),'.',',') "</td>" 
               "<td align=""left""> " replace(string(tmp_t1.reserv_amt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t1.srok, "->>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""left""> " tmp_t1.manager format "x(60)" "</td>"
               "<td></td>"
               "</tr>" skip. 
END.
put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<table><tr><td></td></tr><tr><td></td></tr><tr><td></td></tr></table>" skip.

put stream m-out unformatted "<table><tr><td rowspan=10></td><td rowspan=10></td></tr>" skip.
put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td>Кредитный портфель в USD</td>"
                    "<td>Кол-во кредитов</td>"
                    "<td>Средневзвешенная<br>ставка</td>"
                    "<td>Средневзвешенный<br>срок(дней)</td>"
                  "</tr></table></td></tr>" skip.
  
FOR EACH tmp_t1 WHERE tmp_t1.curr = 'USD' NO-LOCK GROUP BY tmp_t1.code_branch.
  if first-of(tmp_t1.code_branch) then do:
     s-bank = tmp_t1.name_branch.
  put stream m-out unformatted "<tr><td><table><tr align=""left "" style=""font:bold;font-size:x-small""><td>" 
                               s-bank "</td></tr></table></td></tr>" skip.
  end.
  ACCUMULATE tmp_t1.ost_usd(TOTAL BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.code_cstm(COUNT BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.prem(TOTAL BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.srok(TOTAL BY tmp_t1.code_branch).
  IF LAST-OF (tmp_t1.code_branch) THEN DO :
  put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font:bold;font-size:x-small"" align=""rigth"">"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.ost_usd), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm), ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""right""> " replace(string(
                                      ((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.prem) / 
                                      (ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm)), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string(
                                       ((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.srok) / 
                                       (ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm)), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "</tr></table>" skip.
  put stream m-out unformatted "<table><tr><td></td></tr></table>" skip. 
  END.

END.                      

put stream m-out unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td>Кредитный портфель в KZT</td>"
                    "<td>Кол-во кредитов</td>"
                    "<td>Средневзвешенная<br>ставка</td>"
                    "<td>Средневзвешенный<br>срок(дней)</td>"
                  "</tr></table>" skip.

FOR EACH tmp_t1 WHERE tmp_t1.curr = 'KZT' NO-LOCK GROUP BY tmp_t1.code_branch.
  if first-of(tmp_t1.code_branch) then do :
     s-bank = tmp_t1.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td>" s-bank "</td></tr></table>" skip.
  end.
  ACCUMULATE tmp_t1.ost_kzt(TOTAL BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.code_cstm(COUNT BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.prem(TOTAL BY tmp_t1.code_branch).
  ACCUMULATE tmp_t1.srok(TOTAL BY tmp_t1.code_branch).
  IF LAST-OF (tmp_t1.code_branch) THEN DO:
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font:bold;font-size:x-small"" align=""rigth"">"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.ost_kzt), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm), ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""right""> " replace(string(((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.prem) / 
                                                       (ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm)), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string(((ACCUM TOTAL BY tmp_t1.code_branch tmp_t1.srok) / 
                                                       (ACCUM COUNT BY tmp_t1.code_branch tmp_t1.code_cstm)), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "</tr></table>" skip.
  put stream m-out unformatted "<table><tr><td></td></tr></table>" skip. 
  END.

END.

put stream m-out unformatted "<table><tr><td></td></tr>" skip.

put stream m-out unformatted "<tr style=""font:bold;font-size:x-small"" align=""rigth""><td align=""left"" > 1USD = " 
                                                  replace(string((v-kurs), ">>>>>>>>>>>9.99"),'.',',') "</td></tr>" skip.

put stream m-out unformatted "<tr><td></td></tr>" skip.

put stream m-out unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td>ФИО менеджера</td>"
                    "<td>Портфель (USD)</td>"
                    "<td>Доля</td>"
                  "</tr></table>" skip.

/*put stream m-out unformatted "</td></tr></table>" skip.*/

FOR EACH tmp_t2 NO-LOCK GROUP BY tmp_t2.code_branch.
  if first-of(tmp_t2.code_branch) then do:
     s-bank = tmp_t2.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td>" s-bank "</td></tr></table>" skip.
  end.
  ACCUMULATE tmp_t2.sum_usd(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.part(TOTAL BY tmp_t2.code_branch).
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font-size:x-small"" align=""right"">"
               "<td align=""left""> " tmp_t2.manager "</td>"
               "<td align=""left""> " replace(string(tmp_t2.sum_usd, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.part, ">>9.99%"),'.',',') "</td>"
               "</tr></table>" skip.
  IF LAST-OF (tmp_t2.code_branch) THEN DO:
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font:bold;font-size:x-small"" align=""rigth"">"
               "<td align=""right"">  Итого : </td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.sum_usd), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.part), ">>9.99%"),'.',',') "</td>"
               "</tr></table>" skip.
  put stream m-out unformatted "<table><tr><td></td></tr></table>" skip. 
  END.

END.

put stream m-out unformatted "<tr><td></td></tr>" skip.

put stream m-out unformatted "<tr style=""font-size:x-small"" align=""rigth""><td align=""left"" colspan=4>1 раз в месяц, на 1 число</td></tr>" skip.
/*put stream m-out unformatted "</td></tr></table>" skip.*/

put stream m-out unformatted "</table></body></html>" skip.                        

output stream m-out close.

hide message no-pause.

unix silent cptwin r-crcstm.html excel.exe.








                      



                      