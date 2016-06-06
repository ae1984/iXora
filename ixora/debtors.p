/* debtors.p
 * MODULE
        Потреб. кредитование - "Быстрые деньги"
 * DESCRIPTION
        Соотношение должников к кредитному портфелю
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-13-6-5
 * AUTHOR
        04.04.05 saltanat
 * CHANGES
        07.04.05 saltanat - Внесла изменение в вычисление долей.
        15.09.05 saltanat - Изменила наименование пунктов
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/
{mainhead.i}

FUNCTION fdate RETURNS date (INPUT d AS INTEGER, INPUT fmon AS INTEGER, INPUT fyear AS INTEGER).
        if fmon - d + 1 < 1 then do:
           fmon = fmon - d + 13.
           fyear = fyear - 1.
        end.
        else fmon = fmon - d + 1.

        RETURN DATE(fmon,1,fyear).
END FUNCTION.

def var i      as inte no-undo.
def var vmon   as inte no-undo.
def var vyear  as inte no-undo.
def var v-bank as char no-undo.
def var v-code as char no-undo.
def var v-sum  as deci no-undo extent 3 .
def var usrnm  as char no-undo.

define new shared var vdt as date extent 3.
define new shared temp-table tmp
  field bank      as character
  field sum       as deci extent 3
  field code      as inte
index idx bank
index idc code.

define temp-table b-tmp  no-undo
  field bank      as character
  field sum       as deci extent 3
  field code      as inte
index idx bank.

vmon = month(g-today).
vyear = year(g-today).

def frame fr
    skip(1)
    vmon  label 'Отчетный месяц  ' format 'zzz9'
    skip
    vyear label 'Отчетный год    ' format '9999'
    skip(1)
with title 'Участвуют при формировании отчета' centered row 5 side-label.

update
      vmon validate(vmon > 0 and vmon < 13, 'Некорректно внесен месяц!')
      vyear validate(vyear > 1992 and vyear < year(g-today) + 1, 'Некорректно внесен год!')
with frame fr.

do i = 1 to 3:
    vdt[i] = fdate(i,vmon,vyear).
end.

for each txb where txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
        run debtxb (txb.bank).
        if connected ("txb") then disconnect "txb".
end.  


for each tmp:
    create b-tmp.
    buffer-copy tmp to b-tmp.
end.

/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет количественного, процентного и суммарного соотношения должников к кредитному портфелю"
 &size-add = "xx-"
}

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream vcrpt unformatted 
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет количественного, процентного и суммарного соотношения должников<br> к кредитному портфелю по программе Быстрые деньги на " + string(vdt[1], "99/99/9999") + 
       " </B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#000000>" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#000000 bgcolor=#C0C0C0>" skip
     "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>" + string(vdt[1],"99/99/99") + "</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>" + string(vdt[2],"99/99/99") + "</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>" + string(vdt[3],"99/99/99") + "</B></FONT></TD>" skip
   "</TR>" skip.

for each tmp break by tmp.bank by tmp.code :
    if first-of(tmp.bank) then do:
       if tmp.bank = 'all' then v-bank = 'По всем филиалам'.
       else do:
           find first txb where txb.bank = tmp.bank and txb.consolid no-lock no-error.
           if avail txb then v-bank = trim(substring(txb.info,3)).
           else v-bank = tmp.bank.
       end.

       put stream vcrpt unformatted 
       "<TR align=""left"" valign=""bottom"" bordercolor=#000000>" skip
           "<TD colspan = ""4""><FONT size=""1""><B>" + v-bank + " </B></FONT></TD>" skip
       "</TR>" skip.    
    end.
    
    CASE tmp.code:
            WHEN 1 THEN do:
                   if tmp.bank = 'all' then v-code = 'Количество кредитов в портфеле Банка по БД'.
                   else v-code = 'Количество кредитов в портфеле филиала по БД'.
                   end.
            WHEN 2 THEN do:
                   if tmp.bank = 'all' then v-code = 'Количество просроченных кредитов в портфеле Банка по БД'.
                   else v-code = 'Количество просроченных кредитов'.
                   end.
            WHEN 3 THEN do:
                   if tmp.bank = 'all' then v-code = 'Сумма портфеля БД,KZT'.
                   else v-code = 'Сумма портфеля БД по филиалу,KZT'.
                   end.
            WHEN 4 THEN do:
                   if tmp.bank = 'all' then v-code = 'Общая сумма задолженности,KZT'.
                   else v-code = 'Общая сумма задолженности по филиалу,KZT'.
                   end.
            WHEN 5 THEN do:
                   if tmp.bank = 'all' then v-code = 'Сумма остатка ОД'.
                   else v-code = 'Сумма остатка ОД'.
                   end.
            WHEN 6 THEN do:
                   if tmp.bank = 'all' then v-code = 'Сумма просрочки %'.
                   else v-code = 'Сумма просрочки %'.
                   end.
            WHEN 7 THEN do:
                   if tmp.bank = 'all' then v-code = 'Сумма неустойки'.
                   else v-code = 'Сумма неустойки'.
                   end.
        END CASE.
        
    put stream vcrpt unformatted 
       "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
           "<TD><FONT size=""1"">" + v-code + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + replace(string(tmp.sum[1],">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + replace(string(tmp.sum[2],">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + replace(string(tmp.sum[3],">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
       "</TR>" skip.
       
/* ~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~1~ */
    if tmp.code = 1 then do:
              if tmp.bank <> 'all' then do:
              find b-tmp where b-tmp.bank = 'all' and b-tmp.code = 1 no-error.
                  if not avail b-tmp then next.
              if tmp.bank = 'all' then v-code = 'Доля просроченных кредитов в портфеле БД по филиалу:'.
              else v-code = 'Доля филиала к портфелю Банка по БД'.
                      put stream vcrpt unformatted 
                   "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                           "<TD><FONT size=""1"">" + v-code + " </FONT></TD>" skip
                           "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((tmp.sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                       "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((tmp.sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((tmp.sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "</TR>" skip.   
              end.
    end.       

/* ~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~2~ */
    if tmp.code = 2 then do:      
              find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 1 no-error.
          if not avail b-tmp then next.
          if tmp.bank = 'all' then v-code = 'Доля просроченных кредитов в портфеле БД по количеству:'.
          else v-code = 'Доля просроченных кредитов в портфеле БД по филиалу:'.
              put stream vcrpt unformatted 
           "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                   "<TD><FONT size=""1""><B>" + v-code + " </B></FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((tmp.sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
               "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((tmp.sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((tmp.sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "</TR>" skip.  
                   
              if tmp.bank <> 'all' then do:
              find b-tmp where b-tmp.bank = 'all' and b-tmp.code = 1 no-error.
                  if not avail b-tmp then next.
                      put stream vcrpt unformatted 
                   "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                           "<TD><FONT size=""1""><B>Доля просроченных кредитов в портфеле Банка по БД: </B></FONT></TD>" skip
                           "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((tmp.sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                       "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((tmp.sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((tmp.sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "</TR>" skip.   
              end.
                   
               put stream vcrpt unformatted 
           "<TR align=""left"" valign=""bottom"" bordercolor=#000000>" skip
                   "<TD colspan = ""4""><FONT size=""1"">' </FONT></TD>" skip
               "</TR>" skip.  
    end.

/* ~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~3~ */
    if tmp.code = 3 then do:
              if tmp.bank <> 'all' then do:
              find b-tmp where b-tmp.bank = 'all' and b-tmp.code = 3 no-error.
                  if not avail b-tmp then next.
                      put stream vcrpt unformatted 
                   "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                           "<TD><FONT size=""1"">Доля филиала к портфелю Банка по БД: </FONT></TD>" skip
                           "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((tmp.sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                       "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((tmp.sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((tmp.sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "</TR>" skip.   
              end.
    end.       
    
/* ~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~4~ */

    if tmp.code = 4 then do:
               put stream vcrpt unformatted 
           "<TR align=""left"" valign=""bottom"" bordercolor=#000000>" skip
                   "<TD colspan = ""4""><FONT size=""1"">в том числе: </FONT></TD>" skip
           "</TR>" skip.   
    end.


/* ~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~7~ */

    if tmp.code = 7 then do:

              find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 5 no-error.
              if not avail b-tmp then next.
              v-sum[1] = b-tmp.sum[1]. v-sum[2] = b-tmp.sum[2]. v-sum[3] = b-tmp.sum[3].
              
              find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 3 no-error.
          if not avail b-tmp then next.
          if tmp.bank = 'all' then v-code = 'Доля кредитов с просроченным ОД в портфеле БД:'.
          else v-code = 'Доля кредитов с просроченным ОД в портфеле филиала по БД:'.
              put stream vcrpt unformatted 
               "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
               "<TD><FONT size=""1""><B>" + v-code + " </B></FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((v-sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((v-sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
               "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((v-sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
               "</TR>" skip.    

          find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 4 no-error.
              if not avail b-tmp then next.
              v-sum[1] = b-tmp.sum[1]. v-sum[2] = b-tmp.sum[2]. v-sum[3] = b-tmp.sum[3].
              
          find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 3 no-error.
          if not avail b-tmp then next.
          if tmp.bank = 'all' then v-code = 'Доля общей суммы задолженности к портфелю БД:'.
          else v-code = 'Доля общей суммы задолженности к портфелю филиала по БД:'.
              put stream vcrpt unformatted 
               "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
               "<TD><FONT size=""1""><B>" + v-code + " </B></FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((v-sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                   "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((v-sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
               "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((v-sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
               "</TR>" skip.    

              if tmp.bank <> 'all' then do:
                              find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 5 no-error.
                          if not avail b-tmp then next.
                              v-sum[1] = b-tmp.sum[1]. v-sum[2] = b-tmp.sum[2]. v-sum[3] = b-tmp.sum[3].
              
                              find b-tmp where b-tmp.bank = 'all' and b-tmp.code = 3 no-error.
                          if not avail b-tmp then next.
                              put stream vcrpt unformatted 
                           "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                               "<TD><FONT size=""1""><B>Доля кредитов с просроченным ОД в портфеле Банка по БД: </B></FONT></TD>" skip
                                   "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((v-sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                                   "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((v-sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                               "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((v-sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                               "</TR>" skip.    

                          find b-tmp where b-tmp.bank = tmp.bank and b-tmp.code = 4 no-error.
                              if not avail b-tmp then next.
                          v-sum[1] = b-tmp.sum[1]. v-sum[2] = b-tmp.sum[2]. v-sum[3] = b-tmp.sum[3].
              
                          find b-tmp where b-tmp.bank = 'all' and b-tmp.code = 3 no-error.
                          if not avail b-tmp then next.
                              put stream vcrpt unformatted 
                           "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
                               "<TD><FONT size=""1""><B>Доля общей суммы задолженности в портфеле Банка по БД: </B></FONT></TD>" skip
                                   "<TD><FONT size=""1"">" + if tmp.sum[1] = 0 then '0' else replace(string((v-sum[1] / b-tmp.sum[1]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                                   "<TD><FONT size=""1"">" + if tmp.sum[2] = 0 then '0' else replace(string((v-sum[2] / b-tmp.sum[2]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                               "<TD><FONT size=""1"">" + if tmp.sum[3] = 0 then '0' else replace(string((v-sum[3] / b-tmp.sum[3]) * 100,">>>>>>>>>>>9.99"),'.',',') + " </FONT></TD>" skip
                               "</TR>" skip.    
              end. 

    end.
       
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.




unix silent cptwin vcreestr.htm excel.




