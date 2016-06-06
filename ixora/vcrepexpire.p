/* vcrepexpire.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по истекшим контрактам
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
{global.i}
{nbankBik.i}
def new shared var s-vcourbank as char.
def new shared var p-bank as char.
def new shared var dt as date.
def new shared var v-cttype as char.

def var v-sum-docs as decimal.
def var v-sume as decimal.
def var v-sumi as decimal.

def new shared var v-cif like cif.cif.
def new shared var v-cifname as char.
def new shared var v-rnn as char.
def new shared var v-depart as int.
def new shared var v-ppname as char.


def var i as integer.
i = 0.

def new shared temp-table wrk
    field cif as char
    field fil as char
    field num as int
    field cif_name as char
    field ctnum as char
    field ctdate as date
    field cttype as char
    field psnum as char
    field ctsum as decimal format ">>>,>>>,>>>,>>9.99"
    field ctval as char
    field lastdt as date
    field expimp as char.
form
  skip(1)
  dt label " Введите дату " format "99/99/9999"
  v-cttype label "Тип конракта"  format "x(3)" validate (can-find(first codfr where codfr.codfr = 'vccontr' and codfr.code = v-cttype no-lock) or v-cttype = 'ALL', " Не верный тип контракта!") help " Введите код контракта (F2 - поиск)" skip
  skip
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.
dt = g-today.
v-cttype = "ALL".
displ dt v-cttype with frame f-dt.
update dt v-cttype with frame f-dt.


find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-vcourbank = trim(sysc.chval).

def var v-txbbank as char.
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
        run vcrepexpire1(v-bank, dt, v-cttype).
    end.
end.
if s-vcourbank <> "TXB00" then do:
    find first txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
    if avail txb then run vcrepexpire1(txb.bank, dt, v-cttype).
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
 &title = "Отчет по контрактам с истекшим сроком действия"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по контрактам с истекшим сроком действия <BR> на " + string(dt, "99/99/9999") "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№ </TD>" skip
"<TD><font size=1>Наименование клиента</TD>" skip
"<TD><font size=1>Номер контракта</TD>" skip
"<TD><font size=1>Дата контракта</TD>" skip
"<TD><font size=1>Тип контракта</TD>" skip
"<TD><font size=1>Номер ПС <br> (при наличии)</TD>" skip
"<TD><font size=1>Сумма контракта</TD>" skip
"<TD><font size=1>Валюта контракта</TD>" skip
"<TD><font size=1>Последняя дата</TD>" skip
"<TD><font size=1>Признак <br>(экспорт/импорт)</TD>" skip
"</TR>" skip.

if s-vcourbank = "TXB00" then do:
    for each wrk no-lock break by wrk.fil /*by wrk.cif*/.
        if first-of(wrk.fil) then do:
            put stream vcrpt unformatted "<tr><td>" wrk.fil "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td></tr>" skip.
        end.
        /*if first-of(wrk.cif) then do:*/
        i = i + 1.
        put stream vcrpt unformatted
        "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.cif_name "</td>"
        "<td><font size=1>" wrk.ctnum "</td>"
        "<TD><font size=1>" wrk.ctdate "</TD>"
        "<TD><font size=1>" wrk.cttype "</TD>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.ctsum "</td>"
        "<td><font size=1>" wrk.ctval "</td>"
        "<td><font size=1>" wrk.lastdt "</td>"
        "<td><font size=1>" wrk.expimp "</td>"
        "</tr>" skip.
        /*end.*/
    end.
end.

else do:
    put stream vcrpt unformatted "<P><tr align=""left""><font size=""3""><B>" v-txbbank "</B></FONT></tr></P>" skip.
    for each wrk no-lock /* break by wrk.cif.*/:
        /*if first-of(wrk.cif) then do:*/
        i = i + 1.
        put stream vcrpt unformatted
         "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.cif_name "</td>"
        "<td><font size=1>" wrk.ctnum "</td>"
        "<TD><font size=1>" wrk.ctdate "</TD>"
        "<TD><font size=1>" wrk.cttype "</TD>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.ctsum "</td>"
        "<td><font size=1>" wrk.ctval "</td>"
        "<td><font size=1>" wrk.lastdt "</td>"
        "<td><font size=1>" wrk.expimp "</td>"
        "</tr>" skip.
        /*end.*/
    end.
end.

put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrepub.htm iexplore").

pause 0.

