/* svkrarp.p
 * MODULE
        Отчет по открытым счетам ARP
 * DESCRIPTION
        Отчет по переоценке внебалансовой валютной позиции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
    8.6.4
 * AUTHOR
        12.03.2004 tsoy
 * CHANGES
 */

{mainhead.i}

def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".

def var v-crc as char.
def var v-who as char.

define stream m-out.
output stream m-out to svkrep.html.

form 
  v-dtb  format "99/99/9999" label " Начальная дата периода " 
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше текущей" ) skip 

  v-dte  format "99/99/9999" label " Конечная дата периода  " 
    help " Введите дату конца периода"
    validate (v-dte <= g-today, " Дата не может быть больше текущей" ) skip 

  with overlay width 78 centered row 6 side-label title " Параметры отчета "  frame f-period.

def temp-table arptmp
    field arptmp_arp       like arp.arp
    field arptmp_gl        like arp.gl
    field arptmp_rdt       like arp.rdt
    field arptmp_des       like arp.des
    field arptmp_crc       like crc.code
    field arptmp_whon      like ofc.name.

v-dte = g-today.
update v-dtb v-dte with frame f-period.

/* BEGIN */
for each arp where arp.rdt >= v-dtb and arp.rdt <= v-dte no-lock.
   
   find first crc where crc.crc = arp.crc no-lock no-error.

   if avail crc then
      v-crc = crc.code.
   else
      v-crc = string (arp.crc).

   find first ofc where ofc.ofc = arp.who no-lock no-error.

   if avail ofc then
      v-who = ofc.name.
   else
      v-who = ofc.who.

   create arptmp.
      assign arptmp_arp  = arp.arp   
             arptmp_gl   = arp.gl
             arptmp_rdt  = arp.rdt   
             arptmp_des  = arp.des   
             arptmp_crc  = v-crc
             arptmp_whon = v-who.

end.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3> Отчет по открытым внутренним счетам <br>" skip
                 " c " string(v-dtb, "99.99.9999") " по " string(v-dte, "99.99.9999") "</h3>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip. 
       put stream m-out unformatted "<tr style=""font:bold"">"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата Открытия</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Счета ГК</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Счет АРП</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Наименование счета</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>"
                         "</tr>" skip.

for each arptmp break by arptmp_rdt by arptmp_gl by arptmp_arp:
        
        put stream m-out  unformatted "<tr style=""font:bold"">"
                         "<td>" string(arptmp_rdt, "99.99.9999") "</td>"  skip
                         "<td>" string(arptmp_gl)  "</td>"  skip
                         "<td>" string(arptmp_arp) "</td>"  skip
                         "<td>" arptmp_des  "</td>"  skip
                         "<td>" arptmp_crc  "</td>"  skip
                         "<td>" arptmp_whon "</td>"  skip
                         "</tr>" skip.

end.
   put stream m-out unformatted
   "</table>". 
                   
output stream m-out close.
unix silent cptwin svkrep.html excel.
