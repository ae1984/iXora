/* lniprep.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Консолидированный отчет по ипотечным займам
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
        13/09/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
*/

{mainhead.i}

def var dt as date no-undo.
dt = g-today.

update dt format "99/99/9999" label " За дату" validate(dt <= g-today, "Дата должна быть не позднее сегодня!")
   with centered side-labels overlay row 7 frame frdt.
hide frame frdt.

define new shared var v-od as deci extent 6.
define new shared var v-prc as deci extent 6.
define new shared var v-prov as deci extent 6.
define new shared var v-rates as deci extent 20.

for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.regdt <= dt no-lock no-error.
  if avail crchis then v-rates[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "lniprep2 (dt)"}

def stream rep.
output stream rep to lniprep.htm.

def var usrnm as char no-undo.

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
    "<center><b>Дополнительные сведения для расчета пруденциальных нормативов за " dt format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td></td>" skip
    "<td>пп</td>" skip
    "<td>Наименование признака</td>" skip
    "<td>Сумма</td>" skip
    "<td>Начисленные %</td>" skip
    "<td>Провизии</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>8</td>" skip
    "<td>&nbsp;039</td>" skip
    "<td>Ипотечные жилищные займы, соответствующие условию: отношение суммы предоставленного ипотечного жилищного займа (или остатка ОД) к стоимости залога не превышает 50% от стоимости залога (в части счетов группы 1400 за исключением счета 1428)</td>" skip
    "<td>" replace(string(v-od[1], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[1], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[1], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>8</td>" skip
    "<td>&nbsp;040</td>" skip
    "<td>Ипотечные жилищные займы, соответствующие условию: отношение суммы предоставленного ипотечного жилищного займа (или остатка ОД) к стоимости залога не превышает 60% от стоимости залога (в части счетов группы 1400 за исключением счета 1428)</td>" skip
    "<td>" replace(string(v-od[2], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[2], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[2], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td rowspan=""4"">8</td>" skip
    "<td rowspan=""4"">&nbsp;332</td>" skip
    "<td>Ипотечные жилищные займы, соответствующие условию:</td>" skip
    "<td></td>" skip
    "<td></td>" skip
    "<td></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>&nbsp;- отношение суммы предоставленного ипотечного жилищного займа к стоимости залога не превышает 70% от стоимости залога</td>" skip
    "<td>" replace(string(v-od[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>&nbsp;- отношение суммы предоставленного ипотечного жилищного займа к стоимости залога не превышает 85% от стоимости залога и кредитный риск по которым застрахован страховой организацией, не связанной особыми отношениями с банком, являющимся кредитором, в размере превышения отношения суммы ипотечного жилищного займа к стоимости обеспечения над 70 процентами</td>" skip
    "<td>" replace(string(v-od[4], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[4], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[4], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>&nbsp;- отношение суммы предоставленного ипотечного жилищного займа на приобретение жилья, построенного в рамках реализации государственной программы развития жилищного строительства в Республике Казахстан на 2005-2007 годы, утвержденной постановлением Правительства Республики Казахстан 28 июня 2004 N715, к стоимости залога не превышает 90% от стоимости залога и кредитный риск по которым гарантирован Акционерным обществом ""Казахстанский фонд гарантирования ипотечных кредитов"" в размере превышения отношения суммы ипотечного жилищного займа к стоимости обеспечения над 70 % жилищного займа к стоимости обеспечения над 70 процентами</td>" skip
    "<td>" replace(string(v-od[5], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[5], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[5], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>8</td>" skip
    "<td>&nbsp;333</td>" skip
    "<td>Прочие ипотечные займы</td>" skip
    "<td>" replace(string(v-od[6], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prc[6], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(v-prov[6], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table></body></html>".
output stream rep close.
hide message no-pause.

unix silent cptwin lniprep.htm excel.

