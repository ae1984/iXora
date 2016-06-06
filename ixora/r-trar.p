/* r-trar.p
 * MODULE
        Отчет по счетам ARP
 * DESCRIPTION
        Консолидированный отчет по счетам ARP в инвалюте по счетам ГК: 179300
        179900 185600 186700 (профит центр ДВО)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-9-7-1 
 * AUTHOR
        21.09.2006 u00777
 * CHANGES
*/

/*{mainhead.i}*/
def stream st1.
def var v-dam1 as decimal no-undo.
def var v-cam1 as decimal no-undo.
def new shared var v-dt1 as date format "99/99/9999".
def new shared var v-dt2 as date format "99/99/9999".
def new shared var v-gl1 as character initial "1793,1799,1856,1867".

def new shared temp-table t-arp no-undo
  field jdt like bank.jl.jdt
  field jh like bank.jl.jh
  field dam like bank.jl.dam
  field cam like bank.jl.cam
  field who like bank.jl.who
  field acc like bank.jl.acc
  field acc2 like bank.jl.acc
  field rem as character
  field fil as character        
  field pr as integer
  field code like bank.crc.code
  field ost like bank.jl.cam
  field gl like bank.arp.gl
  field crc like bank.jl.crc
  field subled like bank.jl.subled.

update v-dt1 label "Период с" with centered side-label.
update v-dt2 validate(v-dt2 >= v-dt1 and  v-dt2 <= today, "Введите правильно период") label "по" with centered side-label.

display "......Ж Д И Т Е ......."  with row 12 frame ww centered.
pause 0.

{r-branch.i &proc = "r-trar1(txb.name)"}                                  
output stream st1 to r-arp.html.
{html-title.i
&stream  = " stream st1 "
&title = " "
&size-add = "x-"
}               
put stream st1 unformatted "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
"<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
"<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.
for each t-arp no-lock break by t-arp.fil by t-arp.gl by t-arp.acc by t-arp.pr by t-arp.jh: 
  if first-of(t-arp.fil) then do:
     put stream st1 unformatted   "<P align=""center"" style=""font:bold"">" "<BR>" trim(t-arp.fil) "<BR>" " ПРОВОДКИ
     С ARP КАРТОЧКОЙ ЗА ПЕРИОД С " v-dt1 " ПО " v-dt2  skip
     "<TABLE cellspacing=""0"" cellpadding=""7"" border=""1"">" skip
     "<TR align=""center"" style=""font:bold"">" skip
     "<TD>Дата</TD>" skip
     "<TD>Транзакция</TD>" skip
     "<TD>Дебет</TD>" skip
     "<TD>Кредит</TD>" skip
     "<TD>Исполн.</TD>" skip
     "<TD>Корр.счет</TD>" skip
     "<TD>Наименование и детали платежа</TD>" skip
     "</TR>" skip. 
  end.                                                     
  case t-arp.pr:  /*Входящий остаток*/
     when 0 then do:
       assign v-dam1 = 0
              v-cam1 = 0.
       
       put stream st1 unformatted
       "<TR>"
       "<TD COLSPAN = 4>"
       "ARP N " t-arp.acc " (" t-arp.gl ") " trim(t-arp.rem) skip "</TD>" 
       "<TD ALIGN = ""right"" COLSPAN = 3>"
       "Входящий остаток (" t-arp.code ")     "  t-arp.ost
       format "->,>>>,>>>,>>9.99" "</TD>" skip
       "</TR>" skip.                                
      end.
      when 1 then do:
       assign v-dam1 = v-dam1 + t-arp.dam
              v-cam1 = v-cam1 + t-arp.cam.
       put stream st1 unformatted
        "<TR>"
        "<TD align = ""left"">" t-arp.jdt format "99/99/9999" "</TD>" skip
        "<TD>" t-arp.jh "</TD>" skip
        "<TD ALIGN = ""right"">" t-arp.dam format "->,>>>,>>>,>>9.99" "</TD>" skip
        "<TD ALIGN = ""right"">" t-arp.cam format "->,>>>,>>>,>>9.99" "</TD>" skip 
        "<TD>" t-arp.who "</TD>" skip                
        "<TD align = ""left"">" "&nbsp;" trim(t-arp.acc2) + "<br>" + caps(t-arp.subled) "</TD>" skip      
        "<TD>" t-arp.rem "</TD>" skip
        "</TR>" skip.                   
      end.     
      when 2 then do: /*Исходящий остаток*/     
        put stream st1 unformatted      
        "<TR>"
        "<TD COLSPAN = 2>" "Итого по ARP N " t-arp.acc  "</TD>" skip 
        "<TD ALIGN = ""right"">" v-dam1 format "->,>>>,>>>,>>9.99" "</TD>" skip
        "<TD ALIGN = ""right"">" v-cam1 format "->,>>>,>>>,>>9.99" "</TD>" skip
        "<TD  ALIGN = ""right"" COLSPAN = 3>" "Исходящий остаток ("
        t-arp.code ")       "  t-arp.ost format "->,>>>,>>>,>>9.99" 
        "</TD>" skip
        "</TR>" skip.                                           
      end.
  end case.  
  if last-of(t-arp.fil) then
  put stream st1 unformatted "</TABLE>" "<BR>" "<BR>"skip.
end.   

{html-end.i " stream st1"}
output stream st1 close.  

hide frame ww.
unix silent cptwin r-arp.html excel.

        
                  
  
 
