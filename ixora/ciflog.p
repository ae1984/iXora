/* ciflog.p
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
        01/09/04 dpuchkov
 * CHANGES
        02/09/04 dpuchkov добавил отчет об удачных попытках входа.
*/


{mainhead.i}

def var v-ofc like ofc.ofc.

def var return_choice as logical.
def var d_date as date.
def var d_date_fin as date.
def var out as char.
def var file1 as char format "x(20)".
def var acctype as logical.
def var v-arp_acc  as integer.
def var v-num as integer.
def var v-luck as logical init false.



  file1 = "file1.html". 
 
  d_date = g-today.
  d_date_fin = g-today.

  update v-ofc label "Логин" /* validate (v-ofc <> "", ' Необходимо ввести логин офицера')*/ help "Пусто - поиск по всем логинам за период"  with centered side-label.
  update d_date label "Дата с" with centered side-label.
  update d_date_fin label "по" with centered side-label.

  update v-luck label "Удачные/неудачные попытки" help " YES - только удачные попытки, NO - только неудачные попытки"  with centered side-label.


  display "......Ж Д И Т Е ......."  with row 12 frame ww centered.
  pause 0.


  if not v-luck then
  do:
     output to value(file1).
     {html-title.i}
       put unformatted
           "<P align=""center"" style=""font:bold;font-size:small"">Отчет о неудачных попытках доступа к заблокированному CIF клиента </P>" skip
           "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
       put unformatted
           "<TR align=""center"" style=""font:bold;background:white "">" skip
           "<TD>Логин офицера</TD>" skip     
           "<TD>CIF</TD>" skip     
           "<TD>Пункт меню</TD>" skip
           "<TD>Время</TD>" skip
           "<TD>Дата</TD>" skip
           "</TR>" skip.         

if v-ofc = "" then              
    for each ciflog where ciflog.jdt >= d_date and ciflog.jdt <= d_date_fin no-lock :
          put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
          put unformatted
              "<td>" ciflog.ofc  "</td>" skip
              "<td>" ciflog.cif  "</td>" skip
              "<td>" ciflog.menu  format "x(50)" "</td>" skip
              "<td>" string( ciflog.sectime, "HH:MM:SS" ) "</td>" skip
              "<td>" ciflog.jdt "</td>" skip.
    end.
else
    for each ciflog where ciflog.ofc = v-ofc and ciflog.jdt >= d_date and ciflog.jdt <= d_date_fin no-lock :
          put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
          put unformatted
              "<td>" ciflog.ofc  "</td>" skip
              "<td>" ciflog.cif  "</td>" skip
              "<td>" ciflog.menu  format "x(50)" "</td>" skip
              "<td>" string( ciflog.sectime, "HH:MM:SS" ) "</td>" skip
              "<td>" ciflog.jdt "</td>" skip.
    end.





       put unformatted       "</TABLE>" skip.
  end.
  else
  do:
     output to value(file1).
     {html-title.i}
       put unformatted
           "<P align=""center"" style=""font:bold;font-size:small"">Отчет об удачных попытках доступа к заблокированному CIF клиента </P>" skip
           "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
       put unformatted
           "<TR align=""center"" style=""font:bold;background:white "">" skip
           "<TD>Логин офицера</TD>" skip     
           "<TD>CIF</TD>" skip     
           "<TD>Пункт меню</TD>" skip
           "<TD>Время</TD>" skip
           "<TD>Дата</TD>" skip
           "</TR>" skip.         
if v-ofc = "" then
      for each ciflogu where ciflogu.jdt >= d_date and ciflogu.jdt <= d_date_fin no-lock :
          put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
          put unformatted
              "<td>" ciflogu.ofc  "</td>" skip
              "<td>" ciflogu.cif  "</td>" skip
              "<td>" ciflogu.menu  format "x(50)" "</td>" skip
              "<td>" string(ciflogu.sectime, "HH:MM:SS" ) "</td>" skip
              "<td>" ciflogu.jdt "</td>" skip.
      end.
else
      for each ciflogu where ciflogu.ofc = v-ofc and ciflogu.jdt >= d_date and ciflogu.jdt <= d_date_fin no-lock :
          put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
          put unformatted
              "<td>" ciflogu.ofc  "</td>" skip
              "<td>" ciflogu.cif  "</td>" skip
              "<td>" ciflogu.menu  format "x(50)" "</td>" skip
              "<td>" string(ciflogu.sectime, "HH:MM:SS" ) "</td>" skip
              "<td>" ciflogu.jdt "</td>" skip.
      end.





      put unformatted       "</TABLE>" skip.
  end.



  {html-end.i " "} 
  output close .  
  hide frame ww. 
  unix silent cptwin value(file1) iexplore.
  










