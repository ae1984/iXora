/* m-out50.p
 * MODULE
        Отчет Для контроля по ф.лицам в НБРК
 * DESCRIPTION
        Отчет Для контроля по ф.лицам в НБРК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU

 * AUTHOR
        10.04.2004 tsoy
 * CHANGES
        18.05.2004 tsoy выдается в winword в виде письма в НБ
        08.09.2004 tsoy изменил шапку в таблице
	03/01/2005 u00121 - Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
	05.12.2005 saltanat - Поменяла должность куратора.
*/

{mainhead.i}

def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".

define stream m-out.
output stream m-out to vc50rpt.html.

form 
  v-dtb  format "99/99/9999" label " Начальная дата периода " 
    help " Введите дату начала периода!"
    validate (v-dtb <= g-today, " Дата не может быть больше " + string (g-today)) skip 

  v-dte  format "99/99/9999" label " Конечная дата периода  " 
    help " Введите дату конца периода"
    validate (v-dte <= g-today, " Дата не может быть больше " + string (g-today)) skip 

  with overlay width 78 centered row 6 side-label title " Параметры отчета "  frame f-period.

def temp-table rmztmp
    field rmztmp_aaa       as char
    field rmztmp_cif       as char
    field rmztmp_fio       as char
    field rmztmp_rnn       as char
    field rmztmp_crc       like crc.code
    field rmztmp_camt      as deci
    field rmztmp_uamt      as deci.

def var v-amtusd as deci.
def var v-sum as deci.

def var v-rnn    as char.
def var v-fio    as char.
def var v-bank   as char.

v-dte = g-today .
update v-dtb v-dte with frame f-period.

{comm-txb.i}
v-bank = comm-txb().

find ofc where ofc.ofc = g-ofc no-lock no-error.
/* BEGIN */
for each remtrz where remtrz.valdt2 >= v-dtb and remtrz.valdt2 <= v-dte no-lock.

if remtrz.fcrc = 1 
   or not can-find (aaa where aaa.aaa = remtrz.sacc no-lock) 
   or remtrz.sbank <> v-bank then next.

  /* Если не физ лицо то next */
  find first sub-cod where sub-cod.sub       = 'rmz' 
                           and sub-cod.acc   = remtrz.remtrz 
                           and sub-cod.d-cod = 'eknp' no-lock  no-error.
  if avail sub-cod then do: 
     if substr(sub-cod.rcode,2,1) <> "9" then next.    
  end.

   /* проверяем сумму*/
   if remtrz.fcrc = 2 then
       v-amtusd = remtrz.amt.
   else do:
           find first crc where crc.crc = remtrz.fcrc no-lock no-error.
              if avail crc then
                 v-amtusd = remtrz.amt * crc.rate[1].

           find first crc where crc.crc = 2 no-lock no-error.
              if avail crc then
                 v-amtusd = v-amtusd / crc.rate[1].
   end.

   if v-amtusd <= 10000 then next.

  find first sub-cod where sub-cod.sub       = 'rmz' 
                           and sub-cod.acc   = remtrz.remtrz 
                           and sub-cod.d-cod = 'zsgavail' no-lock  no-error.
  if avail sub-cod then do: 
     if sub-cod.ccode <> "1" then next.    
  end. else next.
  
  if index(remtrz.ord,"/RNN/") ne 0 then do:
        v-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12).
  end.

  if index(remtrz.ord,"/RNN/") ne 0 then 
           v-fio = substr(remtrz.ord, 1 , length(remtrz.ord) - index(remtrz.ord,"/RNN/")).
  else    
           v-fio = remtrz.ord.

  find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
  if not avail aaa then next.
  
  find first cif where cif.cif = aaa.cif no-lock no-error.
  if not avail cif then next.

  find first crc where crc.crc = remtrz.fcrc no-lock no-error.
  if not avail crc then next.

  if index(remtrz.ord,"/RNN/") ne 0 then do:
        v-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12).
  end.

  if index(remtrz.ord,"/RNN/") ne 0 then 
           v-fio = substr(remtrz.ord, 1 , length(remtrz.ord) - index(remtrz.ord,"/RNN/")).
  else    
           v-fio = remtrz.ord.

  create  rmztmp.          
  assign rmztmp.rmztmp_aaa  = aaa.aaa      
         rmztmp.rmztmp_cif  = cif.cif     
         rmztmp.rmztmp_fio  = v-fio     
         rmztmp.rmztmp_rnn  = v-rnn      
         rmztmp.rmztmp_crc  = crc.code    
         rmztmp.rmztmp_camt = remtrz.amt     
         rmztmp.rmztmp_uamt = v-amtusd.      

end. 
/* END */

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted 
   "<BR><BR><BR><BR><BR><BR><BR><BR>" skip
   "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
   "<TR><TD><BR>" skip
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
       "<TR valign=""top"">" skip
         "<TD width=""60%"" align=""left""></TD>" skip
         "<TD width=""40%"" align=""center""><FONT size=""3"">" skip
                  "Национальный Банк <br>Республики Казахстан " skip
         "</FONT><BR><BR><BR><BR>"
         "</TD>" skip
       "</TR>"
     "</TABLE></TR>" skip.

find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/       
put stream m-out unformatted 
  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""3"" align=""center"" >" skip
    "<TR><TD colspan=""6"">" skip 
    "<P align =""justify""><FONT size=""3"">"       skip.

       put stream m-out unformatted
       "<TR><TD colspan=""6"">&nbsp;&nbsp;&nbsp;&nbsp; Согласно п. 35 ""Правил проведения валютных операций в Республике Казахстан""" CAPS(bank.cmp.name) skip
       "                      сообщает информацию о физических лицах, осуществивших платежи и/или переводы денег по валютным операциям" skip
       "                      без предоставления документов в банк за отчетный календарный месяц." skip
       "</TD></TR> " skip
       "<TR><TD colspan=""6"" align = ""center"">" skip
       "За период с " string (v-dtb,"99.99.9999") " по " string (v-dte,"99.99.9999") skip
       "<TR><TD colspan=""6"" align = ""center"">" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                       style=""border-collapse: collapse"">" skip. 
       
       put stream m-out unformatted "<tr>"
                  "<td align=""center"">N</td>"
                  "<td align=""center"">Ф.И.О</td>"
                  "<td align=""center"">РНН</td>"
                  "<td align=""center"">Сумма денежных переводов <br> (в долларах США)</td>"
                  "</tr>" skip.

       for each rmztmp break by rmztmp.rmztmp_rnn:
       accumulate rmztmp.rmztmp_uamt (TOTAL by rmztmp.rmztmp_rnn).
             if last-of(rmztmp.rmztmp_rnn) then do:  
             v-sum = ACCUM total by (rmztmp.rmztmp_rnn) rmztmp.rmztmp_uamt.
                  if v-sum > 50000 then do: 
                  put stream m-out  unformatted "<tr>"
                                     "<td></td>"
                                     "<td>" rmztmp.rmztmp_fio "</td>"  skip
                                     "<td>" rmztmp.rmztmp_rnn "</td>"  skip
                                     "<td>" replace(trim(string(v-sum, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"  skip
                                     "</tr>" skip.
                   end. 
             end.
       end.

       put stream m-out unformatted  "</table>".

put stream m-out unformatted                                       
    "</FONT></P>" skip
    "</TD></TR>" skip 
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then

  put stream m-out unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""2"" align=""left""> Управляющий директор <br>" CAPS(bank.cmp.name)    skip 
    "<TD colspan=""4"" align=""right"">    Лысенкер В.Л. </TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""2"" align=""left""><FONT size=""2"">Исполнитель : " + ofc.name + "<BR> тел : " + ofc.tel[2] "</FONT><BR>" skip
    "<TD colspan=""4""></TD></TR>" skip.

put stream m-out unformatted 
  "</TABLE> </TABLE>" skip.

output stream m-out close.
unix silent cptwin vc50rpt.html winword.



