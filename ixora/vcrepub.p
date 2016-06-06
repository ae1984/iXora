/* vcrepub.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по запросам в упалнамоченные банки
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
        28.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/
def new shared var s-vcourbank as char.
def shared var g-today as date.
def var dt as date.
{nbankBik.i}
def var v-txbbank as char.
def new shared temp-table wrk
    field fil as char
    field num1 as char
    field num2 as char
    field dt as date
    field nameub as char
    field psnum as char
    field id as char
    field nameid as char.

def var i as integer.
i = 0.

form
  skip(1)
  dt label " Введите дату " format "99/99/9999" skip
  with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

dt = g-today.
update dt with frame f-dt.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-vcourbank = trim(sysc.chval).

def var v-sel as int.
def var v-banklist as char.
def var v-txblist as char.
def var v-bank as char.
v-banklist = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. ЦО | 2. Актобе | 3. Кустанай | 4. Тараз | 5. Уральск | 6. Караганда | 7. Семск | 8. Кокчетав | 9. Астана | 10. Павлодар | 11. Петропавловск | 12. Атырау | 13. Актау | 14. Жезказган | 15. Усть-Каман | 16. Чимкент | 17. Алматы".
v-txblist = "ALL,TXB00,TXB01,TXB02,TXB03,TXB04 ,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
v-sel = 0.
if s-vcourbank = "TXB00" then do:
    run sel2("ФИЛИАЛЫ",v-banklist,output v-sel).
    if v-sel > 0 then v-bank = entry(v-sel,v-txblist).
    else return.
    find first comm.txb where (comm.txb.bank = v-bank or v-bank = "ALL") and comm.txb.consolid = true no-lock no-error.
    if avail txb then do:
        run vcrepub1(v-bank, dt).
    end.
end.
if s-vcourbank <> "TXB00" then do:
    find first txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
    if avail txb then run vcrepub1(txb.bank, dt).
end.
if s-vcourbank = "TXB00" then v-txbbank = v-nbankru.
if v-bank <> "TXB00" and s-vcourbank = "TXB00" then do:
    find first txb where txb.bank = v-bank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.
if s-vcourbank <> "TXB00" then do:
    find first txb where txb.bank = s-vcourbank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.
def stream vcrpt.
output stream vcrpt to vcrepub.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Отчет по запросам в уполномоченные банки"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по запросам в уполномоченные банки <BR> на " + string(dt, "99/99/9999")"</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№ </TD>" skip
"<TD><font size=1>№ (внутр)</TD>" skip
"<TD><font size=1>№ (исход)</TD>" skip
"<TD><font size=1>Дата</TD>" skip
"<TD><font size=1>Наименование УБ</TD>" skip
"<TD><font size=1>Номер ПС</TD>" skip
"<TD><font size=1>Исполнитель</TD>" skip
"</TR>" skip.

if s-vcourbank = "TXB00" then do:
    for each wrk no-lock break by wrk.fil.
        if first-of(wrk.fil) then do:
        put stream vcrpt unformatted "<tr><td>" wrk.fil "</td>"
        "<td><font size=1>"  "</td>"
        "<td><font size=1>"  "</td>"
        "<td><font size=1>"  "</td>"
        "<td><font size=1>"  "</td>"
        "<td><font size=1>"  "</td>"
        "<td><font size=1>"  "</td></tr>" skip.
        end.
        i = i + 1.
        put stream vcrpt unformatted
        "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.num1 "</td>"
        "<td><font size=1>" wrk.num2 "</td>"
        "<td><font size=1>" wrk.dt "</td>"
        "<td><font size=1>" wrk.nameub "</td>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.nameid "</td>"
        "</tr>" skip.
    end.
end.
else do:
    put stream vcrpt unformatted "<P><B><tr align=""left""><font size=""3"">" v-txbbank "</tr></B></FONT></P>" skip.
    for each wrk no-lock:
        i = i + 1.
        put stream vcrpt unformatted
        "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.num1 "</td>"
        "<td><font size=1>" wrk.num2 "</td>"
        "<td><font size=1>" wrk.dt "</td>"
        "<td><font size=1>" wrk.nameub "</td>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.nameid "</td>"
        "</tr>" skip.
    end.
end.

put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrepub.htm iexplore").

pause 0.




