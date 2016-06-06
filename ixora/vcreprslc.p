/* vcreprslc.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по по контрактам с РС/СУ
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
def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var v-reptype as char init "A".
def new shared var v-repvid as char init "A".

def var v-txbbank as char.
def new shared temp-table wrk
    field fil as char
    field cifname as char
    field rslc as char
    field num as char
    field dt as date
    field ctnum as char
    field ctdt as date
    field psnum as char
    field stat as char
    field sts as char
    field expimp as char.

def var i as integer.
i = 0.



form
  skip(1)
  /*v-dtb label " Начало периода " format "99/99/9999"
   validate (v-dtb <= g-today, " Дата должна быть не больше текущей!")
   skip*/
  v-dte label "  Введите дату " format "99/99/9999"
   validate (v-dtb <= v-dte, " Дата должна быть не больше начальной!")
   skip(1)
  v-reptype label "      E) экспорт     I) импорт     A) все " format "x"
   validate(index("eEiIaA", v-reptype) > 0, "Неверный тип контракта !") skip(1)
   v-repvid label "      A) открытые    C) закрытые   V) все " format "x"
   validate(index("aAcCvV", v-repvid) > 0, "Неверный вид контракта !")
   "  " skip (1)
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

find last cls no-lock no-error.
v-dtb = cls.whn.
v-dte = cls.whn.

displ /*v-dtb*/ v-dte v-reptype v-repvid with frame f-dt.

/*update v-dtb with frame f-dt.*/
v-dte = v-dtb.

update v-dte with frame f-dt.

update v-reptype with frame f-dt.

v-reptype = caps(v-reptype).
displ v-reptype with frame f-dt.

update v-repvid with frame f-dt.

v-repvid = caps(v-repvid).
displ v-repvid with frame f-dt.

message " Формируется отчет...".

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
        run vcreprslc1(v-bank, v-dtb, v-dte, v-reptype, v-repvid).
    end.
end.
if s-vcourbank <> "TXB00" then do:
    find first txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
    if avail txb then run vcreprslc1(txb.bank, v-dtb, v-dte, v-reptype, v-repvid).
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
 &title = "Отчет по запросам в упалнамоченные банки"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по контрактам с РС/СУ <BR> на " + string(v-dte, "99/99/9999")"</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№ </TD>" skip
"<TD><font size=1>Наименование клиента</TD>" skip
"<TD><font size=1>Вид свидетельства <br> (РС/СУ)</TD>" skip
"<TD colspan=""2""><font size=1>Реквизиты РС/СУ</TD>" skip
"<TD><font size=1>Номер договора</TD>" skip
"<TD><font size=1>Дата договора</TD>" skip
"<TD><font size=1>№ ПС</TD>" skip
"<TD><font size=1>Статус cвидетельства</TD>" skip
"<TD><font size=1>Статус контракта</TD>" skip
"<TD><font size=1>Тип</TD>" skip
"</TR>" skip
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""1""><B>Номер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
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
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td></tr>" skip.
        end.
        i = i + 1.
        put stream vcrpt unformatted
        "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.cifname "</td>"
        "<td><font size=1>" wrk.rslc "</td>"
        "<TD><font size=1>" wrk.num "</TD>"
        "<TD><font size=1>" wrk.dt "</TD>"
        "<td><font size=1>" wrk.ctnum "</td>"
        "<td><font size=1>" wrk.ctdt "</td>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.stat "</td>"
        "<td><font size=1>" wrk.sts "</td>"
        "<td><font size=1>" wrk.expimp "</td>"
        "</tr>" skip.
    end.
end.
else do:
    put stream vcrpt unformatted "<P><tr align=""left""><font size=""3""><B>" v-txbbank "</B></FONT></tr></P>" skip.
    for each wrk no-lock:
        i = i + 1.
        put stream vcrpt unformatted
         "<tr><td><font size=1>" i "</td>"
        "<td><font size=1>" wrk.cifname "</td>"
        "<td><font size=1>" wrk.rslc "</td>"
        "<TD><font size=1>" wrk.num "</TD>"
        "<TD><font size=1>" wrk.dt "</TD>"
        "<td><font size=1>" wrk.ctnum "</td>"
        "<td><font size=1>" wrk.ctdt "</td>"
        "<td><font size=1>" wrk.psnum "</td>"
        "<td><font size=1>" wrk.stat "</td>"
        "<td><font size=1>" wrk.sts "</td>"
        "<td><font size=1>" wrk.expimp "</td>"
        "</tr>" skip.
    end.
end.

put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrepub.htm iexplore").

pause 0.

