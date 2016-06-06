/* vcacplat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по акцептованным платежам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        02/09/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}



{comm-txb.i}
def var v-dt1 as date no-undo.
def var v-dt2 as date no-undo.
def var v-ourbank as char.
def temp-table t-actplat
   field plnum as char
   field plinout as char
   field pldt as date
   field plsum as deci 
   field plcrc as char
   field plrem as char
   index dt is primary pldt.
   
v-ourbank = comm-txb().

def frame fparam 
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной') 
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ". 

v-dt1 = g-today.
v-dt2 = g-today.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.
message "Формируестя отчет...".
for each remtrz where remtrz.ptype = '4' or remtrz.ptype = '6' or remtrz.ptype = 'M' or remtrz.ptype = '3' or remtrz.ptype = '7' no-lock:
   if (remtrz.ptype = '4' or remtrz.ptype = '6' or remtrz.ptype = 'M') then do:
      if substr(remtrz.sqn,19) matches "ДПС*" then next.
      if trim(remtrz.vcact) = '' then next.
      if num-entries(remtrz.vcact) < 2 then next.
      if date(entry(2,remtrz.vcact)) < v-dt1 or date(entry(2,remtrz.vcact)) > v-dt2 then next.
   end.   
   
   if (remtrz.ptype = '3' or remtrz.ptype = '7') then do:
      
      find first sub-cod where sub-cod.sub   = 'rmz' and sub-cod.acc   = remtrz.remtrz and sub-cod.d-cod = 'eknp' no-lock  no-error.
      if not avail sub-cod then next.
      if substr(sub-cod.rcode,1,1) = "1" and substr(sub-cod.rcode,4,1)= "1" and remtrz.fcrc = 1 then next.
      /*if remtrz.rsub <> 'vcon' then next.*/
      if remtrz.jh2 = ? then next.
      find first jh where jh.jh = remtrz.jh2 no-lock no-error.
      if not avail jh then next.
      if jh.jdt < v-dt1 or jh.jdt > v-dt2 then next.
      find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
      if not avail aaa then next.
   end.  
   
   find first crc where crc.crc = remtrz.tcrc no-lock no-error.
   if not avail crc then next.

   create t-actplat.
   assign t-actplat.plnum = trim( substring( remtrz.sqn,19,8 )) + ' (' + remtrz.remtrz + ')'
   t-actplat.pldt = remtrz.rdt
   t-actplat.plsum = remtrz.amt
   t-actplat.plcrc = crc.code
   t-actplat.plrem = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4].
   
   if (remtrz.ptype = '4' or remtrz.ptype = '6' or remtrz.ptype = 'M') then t-actplat.plinout = 'Исходящий'. /*out*/
   if (remtrz.ptype = '3' or remtrz.ptype = '7') then t-actplat.plinout = 'Входящий'. /*in*/
   
end.

for each vcblock where vcblock.bank = v-ourbank and vcblock.sts = 'c' and vcblock.jh2 <> ? no-lock:
  find first jh where jh.jh = vcblock.jh2 no-lock no-error.
  if not avail jh then next.
  if jh.jdt < v-dt1 or jh.jdt > v-dt2 then next.
  
  find first remtrz where remtrz.remtrz = vcblock.remtrz no-lock no-error.
  if not avail remtrz then next.
  
  find first crc where crc.crc = remtrz.tcrc no-lock no-error.
  if not avail crc then next.
  
  create t-actplat.
  assign t-actplat.plnum =  trim( substring( remtrz.sqn,19,8 )) + ' (' + remtrz.remtrz + ')'
         t-actplat.pldt = remtrz.rdt
         t-actplat.plsum = remtrz.amt
         t-actplat.plcrc = crc.code
         t-actplat.plrem = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4]
         t-actplat.plinout = 'Входящий'.
end.


for each joudoc where joudoc.jh <> ? no-lock:
  if joudoc.dracctype <> "2" or joudoc.cracctype <> "2" then next.        
  if joudoc.rescha[2] = '' then next.
  
  find first jh where jh.jh = joudoc.jh no-lock no-error.
  if not avail jh then next.
  
  if date(entry(2,joudoc.rescha[2])) < v-dt1 or date(entry(2,joudoc.rescha[2])) > v-dt2 then next.
  
  find first crc where crc.crc = joudoc.crcur no-lock no-error.
  if not avail crc then next.
  create t-actplat.
  assign t-actplat.plnum =  trim(joudoc.num) + ' (' + joudoc.docnum + ')'
         t-actplat.pldt = joudoc.whn
         t-actplat.plsum = joudoc.cramt
         t-actplat.plcrc = crc.code
         t-actplat.plrem = joudoc.remark[1] + ' ' + joudoc.remark[2].
end.  
  
find first t-actplat no-lock no-error.
if not avail t-actplat then return.
def stream v-out.
output stream v-out to actpayments.xls.
{html-title.i
 &title = "METROCOMBANK" &stream = "stream v-out" &size-add = "x-"}



find first cmp no-lock no-error.
put stream v-out unformatted
    "<p><b>Отчет по всем акцептованым платежам <br>за период с " + string(v-dt1,'99/99/9999') + " года по " + string(v-dt2,'99/99/9999') + " года <br><br>" + cmp.name + "</b></p>"  skip.
  

put stream v-out unformatted
    "<TABLE border=""1"" cellpadding=""10"" cellspacing=""0"">" skip.
put stream v-out unformatted skip
    "<tr style=""font:bold"" align=""center"">"
    "<td >№ платежного<br>поручения или<br>запявления на<br> перевод и № RMZ<br>или № JOU</td>"
    "<td >Исходящий/Входящий</td>"
    "<td >Дата платежа или<br>завления на<br> перевод</td>"
    
    "<td >Сумма<br>платежа или <br> заявления на <br> перевод</td>"
    "<td >Валюта<br>платежа или <br> заявления на <br> перевод</td>"                         
    "<td >Назначение<br>платежа</td></tr>" skip.

for each t-actplat no-lock:
 put stream v-out unformatted  "<tr>" skip
 "<td>" t-actplat.plnum "</td>" skip
 "<td>" t-actplat.plinout "</td>" skip
 "<td>" string(t-actplat.pldt,'99/99/9999') "</td>" skip
 "<td>" replace(trim(string(t-actplat.plsum,'>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
 "<td>" t-actplat.plcrc "</td>" skip
 "<td>" t-actplat.plrem "</td></tr>" skip.
  
end.  

put stream v-out unformatted "</table>" skip.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then put stream v-out unformatted "<p>Исполнитель: " ofc.name "</p>" skip.
put stream v-out unformatted "</body></html>" skip.
output stream v-out close.
hide message no-pause.
unix silent cptwin actpayments.xls excel.
unix silent rm -f actpayments.xls.