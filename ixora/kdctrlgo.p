/* kdctrlgo.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Контроль временного прохождения заявок филиалов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-7-11-5
 * AUTHOR
        30/04/2004 madiar
 * CHANGES
        13/05/2004 madiar - добавил возможность просмотра отчета по своим досье на филиалах
    05/09/06   marinav - добавление индексов
*/

{mainhead.i}
{comm-txb.i}
def var s-ourbank as char.
s-ourbank = comm-txb().

def stream rep.
def var usrnm as char.

def var coun as int init 1.
def var s-kdcif like kdcif.kdcif.
def var n-kdcif as char.
def var s-kdlon as char.
def var kdamount as deci.
def var kdcrc as char.
def var v-descr as char.
def var dt-ar as date extent 4.
def var dt-next as date.
def var str-ar as char extent 4.
def var delay-ar as int extent 4.
def var delaystr-ar as char extent 4.
def var kdaffilcod as char.
def var ii as int.

def var sumkr_usd as deci. /* сумма кредита в долларах по курсу на день регистрации досье в филиале */

message "Формируется отчет...".

output stream rep to kdctrlgo.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Контроль временного прохождения заявок</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<col span=13>" skip
    "<tr>" skip
    "<td width=40 rowspan=2><center><b>nn</b></center></td>" skip
    "<td width=60 rowspan=2><center><b>Код клиента</b></center></td>" skip
    "<td width=240 rowspan=2><center><b>Наименование клиента</b><center></td>" skip
    "<td width=80 rowspan=2><center><b>Код заявки</b></center></td>" skip
    "<td width=80 rowspan=2><center><b>Сумма кредита</b></center></td>" skip
    "<td width=80 rowspan=2><center><b>Валюта</b></center></td>" skip
    "<td width=200 rowspan=2><center><b>Статус</b></center></td>" skip
    "<td colspan=2><center><b>Экспертиза Кредитным Департаментом</b></center></td>" skip
    "<td colspan=2><center><b>Экспертиза Юридическим Департаментом</b></center></td>" skip
    "<td colspan=2><center><b>Экспертиза Риск-Менеджером</b></center></td>" skip
    "<td colspan=2><center><b>Рассмотрение на Кредитном Комитете</b></center></td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td width=90><center><b>Дата получения заявки</b></center></td>" skip
    "<td width=90><center><b>Отставание (дней)</b></center></td>" skip
    "<td width=90><center><b>Дата получения заявки</b></center></td>" skip
    "<td width=90><center><b>Отставание (дней)</b></center></td>" skip
    "<td width=90><center><b>Дата получения заявки</b></center></td>" skip
    "<td width=90><center><b>Отставание (дней)</b></center></td>" skip
    "<td width=90><center><b>Дата получения заявки</b></center></td>" skip
    "<td width=90><center><b>Отставание (дней)</b></center></td>" skip
    "</tr>" skip.

for each kdlon where kdlon.sts > '20' and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock:
   
   if kdlon.crc <> 2 then do:
      find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = kdlon.crc no-lock no-error.
      if avail crchis then sumkr_usd = kdlon.amount * crchis.rate[1].
      find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = 2 no-lock no-error.
      if avail crchis then sumkr_usd = sumkr_usd / crchis.rate[1].
   end.
   else sumkr_usd = kdlon.amount.
   
   find bookcod where bookcod.bookcod = "kdsts" and bookcod.code = kdlon.sts no-lock no-error.
   if avail bookcod then v-descr = bookcod.name. 
                    else v-descr = ''.
  
   find first kdkrdt where kdkrdt.sumst <= sumkr_usd and kdkrdt.sumend > sumkr_usd no-lock no-error.
   
   find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
   s-kdcif = kdcif.kdcif.
   n-kdcif = kdcif.name.
   find first crc where crc.crc = kdlon.crc no-lock no-error.
   kdcrc = crc.code.
   
   dt-ar[1] = kdlon.resdat[1]. str-ar[1] = string(dt-ar[1],'99/99/9999').
   
   if kdlon.sts >= '35' or kdlon.sts = '09' or kdlon.sts = '03' then do:
     
     find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '61'  no-lock no-error.
     dt-next = kdaffil.whn.
     delay-ar[1] = dt-next - dt-ar[1] - kdkrdt.dayskd.
     
     if kdkrdt.daysud <> 0 then do:
       dt-ar[2] = dt-next. str-ar[2] = string(dt-ar[2],'99/99/9999').
       find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '60' no-lock no-error.
       dt-next = kdaffil.whn.
       delay-ar[2] = dt-next - dt-ar[2] - kdkrdt.daysud.
     end.
     else str-ar[2] = '-'.
     
     if kdkrdt.daysrm <> 0 then do:
       dt-ar[3] = dt-next. str-ar[3] = string(dt-ar[3],'99/99/9999').
       find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '31' no-lock no-error.
       dt-next = kdaffil.whn.
       delay-ar[3] = dt-next - dt-ar[3] - kdkrdt.daysrm.
     end.
     else str-ar[3] = '-'.
     
     dt-ar[4] = dt-next. str-ar[4] = string(dt-ar[4],'99/99/9999').
     if kdlon.sts = '35' then delay-ar[4] = g-today - dt-ar[4] - kdkrdt.dayskk.
     else delay-ar[4] = kdlon.datkk - dt-ar[4] - kdkrdt.dayskk.
     
   end. /* if kdlon.sts >= '35' or ... */
   
   if kdlon.sts = '33' then do:
     
     find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '61' no-lock no-error.
     dt-next = kdaffil.whn.
     delay-ar[1] = dt-next - dt-ar[1] - kdkrdt.dayskd.
     
     if kdkrdt.daysud <> 0 then do:
       dt-ar[2] = dt-next. str-ar[2] = string(dt-ar[2],'99/99/9999').
       find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '60' no-lock no-error.
       dt-next = kdaffil.whn.
       delay-ar[2] = dt-next - dt-ar[2] - kdkrdt.daysud.
     end.
     else str-ar[2] = '-'.
     
     dt-ar[3] = dt-next. str-ar[3] = string(dt-ar[3],'99/99/9999').
     delay-ar[3] = g-today - dt-ar[3] - kdkrdt.daysrm.
     
   end. /* if kdlon.sts = '33' */
   
   if kdlon.sts = '30' then do:
     
     find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '61' no-lock no-error.
     dt-next = kdaffil.whn.
     delay-ar[1] = dt-next - dt-ar[1] - kdkrdt.dayskd.
     
     dt-ar[2] = dt-next. str-ar[2] = string(dt-ar[2],'99/99/9999').
     delay-ar[2] = g-today - dt-ar[2] - kdkrdt.daysud.
     
   end. /* if kdlon.sts = '30' */
   
   if kdlon.sts = '25' then do:
     
     delay-ar[1] = g-today - dt-ar[1] - kdkrdt.dayskd.
     
   end. /* if kdlon.sts = '25' */
   
   
   do ii = 1 to 4:
     if delay-ar[ii] <= 0 then delaystr-ar[ii] = 'нет'.
     else delaystr-ar[ii] = string(delay-ar[ii]).
     if str-ar[ii] = '-' then delaystr-ar[ii] = '-'.
   end.
   
   
   put stream rep unformatted
      "<tr>" skip
      "<td><center>" coun "</center></td>" skip
      "<td><center>" s-kdcif "</center></td>" skip
      "<td><center>" n-kdcif "<center></td>" skip
      "<td><center>" kdlon.kdlon "</center></td>" skip
      "<td><center>" kdlon.amount "</center></td>" skip
      "<td><center>" kdcrc "</center></td>" skip
      "<td><center>" v-descr "</center></td>" skip
      "<td><center>" str-ar[1] "</center></td>" skip
      "<td><center>" delaystr-ar[1] "</center></td>" skip
      "<td><center>" str-ar[2] "</center></td>" skip
      "<td><center>" delaystr-ar[2] "</center></td>" skip
      "<td><center>" str-ar[3] "</center></td>" skip
      "<td><center>" delaystr-ar[3] "</center></td>" skip
      "<td><center>" str-ar[4] "</center></td>" skip
      "<td><center>" delaystr-ar[4] "</center></td>" skip
      "</tr>" skip.
   coun = coun + 1.
end.

put stream rep unformatted "</table>" skip.
{html-end.i "stream rep unformatted"}

hide message no-pause.

output stream rep close.
unix silent cptwin kdctrlgo.htm excel.