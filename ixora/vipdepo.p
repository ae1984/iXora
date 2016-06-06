/* vipdepo.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по депозитам VIP клиентов у которых до окончания срока осталось 3 и менее дней
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
        05.08.05 dpuchkov
 * CONNECT
        bank
 * CHANGES
*/





{mainhead.i}

def var return_choice as logical.
def var d_date as date.
def var d_date_fin as date.
def var out as char.
def var file1 as char format "x(20)".
def var acctype as logical.
def var v-arp_acc  as integer.
def var v-num as integer.



  file1 = "file1.html". 
 
  d_date = g-today.
  d_date_fin = g-today.




  displ "ЖДИТЕ ИДЕТ ФОРМИРОВАНИЕ ОТЧЕТА"  with row 12  centered. 


  
  output to value(file1).
  {html-title.i} 
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Отчет по депозитам VIP клиентов до окончания срока которых осталось 3 и менее дней" "</P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        "<TD>CIF</TD>" skip     
        "<TD>Ф.И.О</TD>" skip
        "<TD>Наименование депозита</TD>" skip
        "<TD>Счет</TD>" skip
        "<TD>Сумма депозита</TD>" skip
        "<TD>Дата окончания депозита</TD>" skip
        "</TR>" skip.
          	
   for each vip no-lock :
       find last cif where cif.cif = vip.cif no-lock no-error.
       if avail cif then do:
          for each aaa where aaa.cif = cif.cif no-lock:
              find last lgr where lgr.lgr = aaa.lgr and (aaa.sta = "A" or aaa.sta = "N") and (lgr.led = "TDA" or lgr.led = "CDA")  no-lock no-error.
              if avail lgr then do:
                 if aaa.expdt - g-today <= 3 and aaa.expdt - g-today > 0 then do:
                    put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
                    put unformatted
                        "<td>" cif.cif "</td>" skip
                        "<td>" cif.name format "x(50)" "</td>" skip
                        "<td>" lgr.des format "x(50)" "</td>" skip
                        "<td>" aaa.aaa format "x(9)" "</td>" skip
                        "<td>" aaa.opnamt  "</td>" skip
                        "<td>" aaa.expdt  "</td>" skip.
                 end.
              end.
          end.

       end.
   end.
   put unformatted       "</TABLE>" skip.




  {html-end.i " "}  
  output close .  
  hide frame ww. 
  unix silent cptwin value(file1) iexplore.
