 /* repcred.p
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
        14/12/2005 Natalya D.
 * CHANGES
        22/02/2006 Natalya D. исправила столбец "П/п". Сделала его узким.
        01/03/2006 Natalya D. - навела красоту (некоторые столбцы съузила, название отчёта по центру)
*/

/* Отчет по кредитам, выданным за день, в разрезе менеджеров по филиалам*/

def var v-numstr  as integer no-undo.
def var d_date as date no-undo.
def var ttlsum_usd_kzt as decimal no-undo.
def var v-kurs as decimal no-undo.
def var s-bank as char no-undo.

form
   skip(1)
   d_date label 'Введите дату за которую необходимо сформировать отчёт' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.


d_date = today.
update d_date with frame f-dt.

define new shared temp-table tmp_t1  no-undo
       field name like loncon.pase-pier
       field sum_kzt as decimal
       field sum_usd as decimal
       field ttl_sum as decimal
       field prem_kzt like lon.prem
       field prem_usd like lon.prem
       field srok_kzt as integer
       field srok_usd as integer
       field code_cred as integer
       field cif like cif.cif
       field code_branch like sysc.chval
       index indx1 code_branch
       index indx2 name.

define new shared temp-table tmp_t2  no-undo
       field pp_num as integer
       field name like ofc.ofc
       field sum_kzt as decimal
       field sum_usd as decimal
       field ttl_sum as decimal
       field part as decimal
       field cnt_cstm as integer
       field avrg_sum as integer
       field prem_kzt like lon.prem
       field prem_usd like lon.prem
       field srok_kzt as integer
       field srok_usd as integer
       field code_branch like sysc.chval
       field name_branch as char
       index indx3 code_branch.

define new shared temp-table tmp_t3  no-undo
       field vid_cred as character
       field p_kzt as decimal
       field p_usd as decimal
       field ttl_usd as decimal
       field cnt_cstm as integer
       field code_branch like sysc.chval
       field name_branch as char
       index indx4 code_branch.

find prev crchis where crchis.rdt = d_date and crchis.crc=2 no-lock.
  v-kurs = crchis.rate[1].         

{r-branch.i &proc = "repcred1.p (input d_date, input v-kurs)"}

define stream m-out.
output stream m-out to repcred.html.

{html-title.i &stream = " stream m-out "}

put stream m-out "<tr><td></td></tr><table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">" skip.           
put stream m-out unformatted "<tr><td></td></tr><tr><td></td></tr>"
                 "<tr align=""center"" style=""font:bold""><td colspan=12>Кредитный портфель по менеджерам за "
                 string(d_date) "</td></tr><tr><td></td></tr>" skip.
put stream m-out "<tr><td></td></tr><br><br></table>" skip.

/*КРЕДИТЫ*/
put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td rowspan=2 align=center>П/п</td>"
                    "<td rowspan=2 align=center>Менеджер</td>"
                    "<td colspan=3 align=center>Общая сумма остатков, выданная</td></td>"
                    "<td rowspan=2 align=center>Доля</td>"
                    "<td rowspan=2 align=center>К-во заeмщиков<br>(всего)</td>"
                    "<td rowspan=2 align=center>Средняя сумма<br>кредита, выданная на<br>одного заeмщика</td>"
                    "<td colspan=2>Средневзвешенная<br>ставка кредитов</td>"
                    "<td colspan=2>Средневзвешенный срок<br>(дней) кредитов, выданных</td></td>" 
                  "</tr>" skip.
put stream m-out unformatted "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                 "<td>в тенге</td><td>в USD</td><td>Всего(тенге)</td>"
                 "<td>в тенге</td><td>в USD</td><td>в тенге</td><td>в USD</td>"
                 "</tr></table></td></tr>" skip.

FOR EACH tmp_t2 no-lock GROUP BY tmp_t2.code_branch.
  if first-of(tmp_t2.code_branch) then do:
     s-bank = tmp_t2.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td colspan=3>" s-bank "</td></tr></table>" skip.
  end.
 
  ACCUMULATE tmp_t2.sum_kzt(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.sum_usd(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.ttl_sum(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.part(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.cnt_cstm(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.avrg_sum(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.prem_kzt(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.prem_usd(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.srok_kzt(TOTAL BY tmp_t2.code_branch).
  ACCUMULATE tmp_t2.srok_usd(TOTAL BY tmp_t2.code_branch).
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr align=""right"">"
               "<td align=""center""> " tmp_t2.pp_num "</td>"
               "<td align=""left""> " tmp_t2.name format "x(60)" "</td>"
               "<td align=""left""> " replace(string(tmp_t2.sum_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.sum_usd, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.ttl_sum, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.part, ">>9.99%"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.cnt_cstm, ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.avrg_sum, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.prem_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left""> " tmp_t2.prem_usd "</td>" 
               "<td align=""left""> " replace(string(tmp_t2.srok_kzt, ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""left""> " replace(string(tmp_t2.srok_usd, ">>>>>>>>>>>9"),'.',',') "</td>"
               "</tr></table>" skip. 

  IF LAST-OF (tmp_t2.code_branch) THEN DO:
  put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font:bold;font-size:x-small"" align=""rigth"">"
               "<td align=""center""> "  "</td>"
               "<td align=""left"">  Итого по потребительскому кредитованию: </td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.sum_kzt), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.sum_usd), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.ttl_sum), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.part), ">>9.99%"),'.',',') " </td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.cnt_cstm), ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.avrg_sum), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.prem_kzt), ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""right""> " (ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.prem_usd) "</td>" 
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.srok_kzt), ">>>>>>>>>>>9"),'.',',') "</td>"
               "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t2.code_branch tmp_t2.srok_usd), ">>>>>>>>>>>9"),'.',',') "</td>"
               "</tr></table>" skip.
  END.
 
END.
  /*put stream m-out unformatted "</table>" skip.*/

  put stream m-out unformatted "<table><tr><td></td></tr><tr><td></td></tr><tr><td></td></tr></table>" skip.

  put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td colspan=2>Вид кредитования</td>"
                    "<td>Портфель KZT</td>"
                    "<td>Портфель USD</td>"
                    "<td>Итого портфель в USD</td>"
                    "<td>К-во заемщиков</td>"
                  "</tr></table></td></tr>" skip.                        


FOR EACH tmp_t3 NO-LOCK GROUP BY tmp_t3.code_branch.
  if first-of(tmp_t3.code_branch) then do:
     s-bank = tmp_t3.name_branch.
  put stream m-out unformatted "<table><tr align=""left "" style=""font:bold;font-size:x-small""><td colspan=3>" s-bank "</td></tr></table>" skip.
  end. 
  ACCUMULATE tmp_t3.p_kzt(TOTAL BY tmp_t3.code_branch).
  ACCUMULATE tmp_t3.p_usd(TOTAL BY tmp_t3.code_branch).
  ACCUMULATE tmp_t3.ttl_usd(TOTAL BY tmp_t3.code_branch).
  ACCUMULATE tmp_t3.cnt_cstm(TOTAL BY tmp_t3.code_branch).
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr align=""right"">"
                "<td colspan=2 align=""left""> " tmp_t3.vid_cred "</td>"
                "<td> " replace(string(tmp_t3.p_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td> " replace(string(tmp_t3.p_usd, ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td> " replace(string(tmp_t3.ttl_usd, ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td> " replace(string(tmp_t3.cnt_cstm, ">>9"),'.',',') "</td>"
               "</tr></table>" skip.
  IF LAST-OF (tmp_t3.code_branch) THEN DO:
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr style=""font:bold;font-size:x-small"" align=""rigth"">"
                "<td colspan=2 align=""left"">  Итого по Департаменту: </td>"
                "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t3.code_branch tmp_t3.p_kzt), ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t3.code_branch tmp_t3.p_usd), ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t3.code_branch tmp_t3.ttl_usd), ">>>>>>>>>>>9.99"),'.',',') "</td>"
                "<td align=""right""> " replace(string((ACCUM TOTAL BY tmp_t3.code_branch tmp_t3.cnt_cstm), ">>>>>>>>>>>9"),'.',',') "</td>"
               "</tr></table>" skip.
  put stream m-out unformatted "<table><tr><td></td></tr></table>" skip. 
  END.
 
END.

  put stream m-out unformatted "</table>" skip.

  

put stream m-out unformatted "<table><tr><td></td></tr>" skip.

put stream m-out unformatted "<tr align=""rigth""><td colspan=2 align=""left"" > 1USD = " replace(string((v-kurs), ">>>>>>>>>>>9.99"),'.',',') "</td></tr>" skip.
put stream m-out unformatted "<tr><td></td></tr>" skip.
put stream m-out unformatted "<tr align=""rigth""><td colspan=2 align=""left"" >на ежедневной основе</td></tr>" skip.
put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

hide message no-pause.

unix silent cptwin repcred.html excel.exe.









                      



                      