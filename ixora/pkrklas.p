/* pkrklas.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Проверка классификации по экспресс-кредитам
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
        08/07/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        29/08/2009 madiyar - добавил дату погашения
*/

{mainhead.i}

def new shared temp-table wrk no-undo
  field bank as char
  field cif as char
  field fio as char
  field lon as char
  field crc as integer
  field sts_prolong as char
  field prolong_rating as deci
  field prosr_kzt as deci
  field prosr_val as deci
  field dayspr as integer
  field dayspr_dc as integer
  field sts_prosr as char
  field sts_prosr_des as char
  field prosr_rating as deci
  field ost_kzt as deci
  field ost_val as deci
  field prov_sts_old as integer
  field prov_sts_new as integer
  field provprc as deci
  field od as deci
  field od_pro as deci
  field progprov as deci
  field duedt as date
  index idx is primary bank crc fio cif.

{r-brfilial.i &proc = "pkrklas2"}

def stream rep.
output stream rep to rpt.htm.

put stream rep "<html><head><title>Проверка классификации портфеля экспресс-кредитов</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Проверка классификации портфеля экспресс-кредитов, " g-today format "99/99/9999" " " string(time,"hh:mm:ss") "<BR>" skip
    v-bankname "</b><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код кл</td>" skip
    "<td>ФИО</td>" skip
    "<td>Сс. счет</td>" skip
    "<td>Дата пог</td>" skip
    "<td>Валюта</td>" skip
    "<td>Пролонг(стс)</td>" skip
    "<td>Пролонг(балл)</td>" skip
    "<td>Просрочка(KZT)</td>" skip
    "<td>Просрочка(вал)</td>" skip
    "<td>Дней проср (тек)</td>" skip
    "<td>Дней проср (закр)</td>" skip
    "<td>Остаток(KZT)</td>" skip
    "<td>Остаток(вал)</td>" skip
    "<td>Просрочка(стс)</td>" skip
    "<td>Просрочка(опис)</td>" skip
    "<td>Просрочка(балл)</td>" skip
    "<td>Статус (стар)</td>" skip
    "<td>Статус (нов)</td>" skip
    "<td>%</td>" skip
    "<td>ОД</td>" skip
    "<td>ОД прог</td>" skip
    "<td>Прогноз провизий</td>" skip
    "</tr>" skip.

for each wrk no-lock:
    put stream rep unformatted
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.fio "</td>" skip
        "<td>&nbsp;" wrk.lon "</td>" skip
        "<td>" string(wrk.duedt,"99/99/9999") "</td>" skip
        "<td>" wrk.crc "</td>" skip
        "<td>&nbsp;" wrk.sts_prolong "</td>" skip
        "<td>" trim(string(wrk.prolong_rating,"->>>9.99")) "</td>" skip
        "<td>" replace(trim(string(wrk.prosr_kzt,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prosr_val,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" trim(string(wrk.dayspr,">>>9")) "</td>" skip
        "<td>" trim(string(wrk.dayspr_dc,">>>9")) "</td>" skip
        "<td>" replace(trim(string(wrk.ost_kzt,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost_val,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>&nbsp;" wrk.sts_prosr "</td>" skip
        "<td>" wrk.sts_prosr_des "</td>" skip
        "<td>" trim(string(wrk.prosr_rating,"->>>9.99")) "</td>" skip
        "<td>" trim(string(wrk.prov_sts_old,">>>9")) "</td>" skip
        "<td>" trim(string(wrk.prov_sts_new,">>>9")) "</td>" skip
        "<td>" trim(string(wrk.provprc,"->>>9.99")) "</td>" skip
        "<td>" replace(trim(string(wrk.od,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.od_pro,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.progprov,">>>>>>>>9.99")),'.',',') "</td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table><BR><BR>" skip.

hide message no-pause.
put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.

