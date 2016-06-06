/* statrep.p 

 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет по оценке активов на текущий месяц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
          
 * AUTHOR
        30.12.03 marinav
 * CHANGES
*/

{global.i}
{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

define var v-stat as inte init 0.
define var bilance as deci.
define var v-log as logi init no.
define var v-desc as char.

def temp-table  wrk
    field lon    like lon.lon
    field cif    like lon.cif
    field name   like cif.name
    field lonstat   like lonstat.lonstat   /*сейчас есть*/
    field lonstat1   like lonstat.lonstat  /*вышло по клас-ции*/
    field rdt1 as date 
    field lonstat2   like lonstat.lonstat  /*максимум по клиенту*/
    field who as char
    field stat   like lonstat.apz
    field prc    like lonstat.prc.

/* вспомогат таблица для расчета макс по клиенту */
define temp-table wrk1
    field cif like lon.cif
    field lonstat  like lonstat.lonstat
    index cif cif. 

define stream m-out.
output stream m-out to rpt.html.

put stream m-out skip.
           
put stream m-out "<html><head><title>TEXAKABANK:</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>".
put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""3""
                 style=""border-collapse: collapse"">". 
put stream m-out "<tr><td align=""right""><h3>АО TEXAKABANK"
                 "<br></td></tr>" skip.
                 
put stream m-out "<tr><td align=""center""><h3>Статусы для классификации кредитов<br><br><br></td></tr>" skip.

  put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код клиента</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Тек статус</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Статус по клас</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Макс статус по клиенту</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Менеджер</td></tr>" skip.

for each lon no-lock break by lon.cif.

   run atl-dat (lon.lon,g-today,output bilance). /* остаток  ОД*/                        
   if bilance <= 0 then next.

   v-log = no.
   for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = lon.cif no-lock:
     if pkanketa.lon = lon.lon then do:
       v-log = yes.
       leave.
     end.
   end.
   if v-log = yes then next.
  
   find first cif where cif.cif = lon.cif no-lock no-error.

   create wrk.
   assign wrk.cif = lon.cif
          wrk.lon = lon.lon
          wrk.name = cif.name.

   find last lonhar where lonhar.lon = lon.lon and lonhar.fdt <= g-today no-lock no-error.
      if avail lonhar then wrk.lonstat = lonhar.lonstat.
                      else wrk.lonstat = 1.

   find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif and
                           kdlonkl.kdlon = lon.lon and kdlonkl.kod = 'klass' 
                            use-index bclrdt no-lock no-error . 
   if avail kdlonkl then assign wrk.lonstat1 = inte(kdlonkl.val1) wrk.rdt1 = kdlonkl.rdt wrk.who = kdlonkl.who.
                    else wrk.lonstat1 = 0.

   find first wrk1 where wrk1.cif = lon.cif no-error.
   if not avail wrk1 then do:
       create wrk1.
       assign wrk1.cif = lon.cif wrk1.lonstat = wrk.lonstat1.
   end.
   else if wrk1.lonstat < wrk.lonstat1 then wrk1.lonstat = wrk.lonstat1.

        
end.

for each wrk break by wrk.cif.
    find first wrk1 where wrk1.cif = wrk.cif .

        find bookcod where bookcod.bookcod = "kdstat" and inte(bookcod.code) = wrk1.lonstat no-lock no-error.
        if avail bookcod then v-desc = bookcod.name.
                         else v-desc = ''.
 
        put stream m-out "<tr><td>"  wrk.cif "</td>"
                             "<td>"  wrk.name "</td>"
                             "<td>"  '`' wrk.lon format 'x(10)' "</td>"  
                             "<td>"  wrk.lonstat "</td>"  
                             "<td>"  wrk.rdt1 "</td>"  
                             "<td>"  wrk.lonstat1 "</td>"  
                             "<td>"  wrk1.lonstat "</td>"  
                             "<td>"  v-desc format 'x(25)' "</td>"  
                             "<td>"  wrk.who "</td></tr>" skip.  
end.

put stream m-out "</table></body></html>".

output stream m-out close.
unix silent cptwin rpt.html excel.
