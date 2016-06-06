/* lonclrep.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет "Классификация кредитного портфеля по критериям"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        13/04/04 madiar
 * CHANGES
        22/04/2004 madiar - добавил no-lock
        23/02/2006 madiar - название клиента ищется и в досье, и в оперу
        07/09/06 marinav - добавлен индекс во временную таблицу
*/

{mainhead.i}

def var dt as date no-undo.
def var usrnm as char no-undo.
def stream rep.


def temp-table kdklassm no-undo
     field    cif        like kdlonkl.kdcif
     field    lon        like kdlonkl.kdlon
     field    rdt        like kdlonkl.rdt
     field    finsost1_v like kdlonkl.val1
     field    finsost1_d like kdlonkl.valdesc
     field    finsost1_r like kdlonkl.rating
     field    prosr_v    like kdlonkl.val1
     field    prosr_d    like kdlonkl.valdesc
     field    prosr_r    like kdlonkl.rating
     field    obesp1_v   like kdlonkl.val1
     field    obesp1_d   like kdlonkl.valdesc
     field    obesp1_r   like kdlonkl.rating
     field    long1_v    like kdlonkl.val1
     field    long1_d    like kdlonkl.valdesc
     field    long1_r    like kdlonkl.rating
     field    prosr_1_v  like kdlonkl.val1
     field    prosr_1_d  like kdlonkl.valdesc
     field    prosr_1_r  like kdlonkl.rating
     field    ispakt_v   like kdlonkl.val1
     field    ispakt_d   like kdlonkl.valdesc
     field    ispakt_r   like kdlonkl.rating
     field    spisob1_v  like kdlonkl.val1
     field    spisob1_d  like kdlonkl.valdesc
     field    spisob1_r  like kdlonkl.rating
     field    rait_v     like kdlonkl.val1
     field    rait_d     like kdlonkl.valdesc
     field    rait_r     like kdlonkl.rating
     field    kateg_v    like kdlonkl.val1
     field    kateg_d    as char
     field    kateg_r    like kdlonkl.rating
     index main is primary cif lon rdt.
     

dt = g-today.
update dt format '99/99/9999' label " Дата " with centered frame df.
hide frame df.

message "Формируется отчет...".


/* -------------- */

find first kdlonkl where kdlonkl.rdt = dt and not (kdlonkl.kdlon matches "KD*") no-lock no-error.
if not avail kdlonkl then do:
  message " На запрашиваемую дату нет данных " view-as alert-box buttons ok title " Нет данных! ".
  return.
end.

for each kdlonkl where kdlonkl.rdt = dt no-lock:
  find first kdklassm where kdklassm.cif = kdlonkl.kdcif and kdklassm.lon = kdlonkl.kdlon and kdklassm.rdt = kdlonkl.rdt no-error.
  if not avail kdklassm then do:
    create kdklassm.
    kdklassm.cif = kdlonkl.kdcif.
    kdklassm.lon = kdlonkl.kdlon.
    kdklassm.rdt = kdlonkl.rdt.
  end.
  case trim(kdlonkl.kod):
    when "finsost1" then do: kdklassm.finsost1_v = kdlonkl.val1. kdklassm.finsost1_r = kdlonkl.rating. kdklassm.finsost1_d = kdlonkl.valdesc. end.
    when "prosr" then do: kdklassm.prosr_v = kdlonkl.val1. kdklassm.prosr_r = kdlonkl.rating. kdklassm.prosr_d = kdlonkl.valdesc. end.
    when "obesp1" then do: kdklassm.obesp1_v = kdlonkl.val1. kdklassm.obesp1_r = kdlonkl.rating. kdklassm.obesp1_d = kdlonkl.valdesc. end.
    when "long1" then do: kdklassm.long1_v = kdlonkl.val1. kdklassm.long1_r = kdlonkl.rating. kdklassm.long1_d = kdlonkl.valdesc. end.
    when "prosr_1" then do: kdklassm.prosr_1_v = kdlonkl.val1. kdklassm.prosr_1_r = kdlonkl.rating. kdklassm.prosr_1_d = kdlonkl.valdesc. end.
    when "ispakt" then do: kdklassm.ispakt_v = kdlonkl.val1. kdklassm.ispakt_r = kdlonkl.rating. kdklassm.ispakt_d = kdlonkl.valdesc. end.
    when "spisob1" then do: kdklassm.spisob1_v = kdlonkl.val1. kdklassm.spisob1_r = kdlonkl.rating. kdklassm.spisob1_d = kdlonkl.valdesc. end.
    when "rait" then do: kdklassm.rait_v = kdlonkl.val1. kdklassm.rait_r = kdlonkl.rating. kdklassm.rait_d = kdlonkl.valdesc. end.
    when "klass" then kdklassm.kateg_v = kdlonkl.val1.
  end case.
end. /* for each kdlonkl */

for each kdklassm:
  kdklassm.kateg_r = kdklassm.finsost1_r + kdklassm.prosr_r + kdklassm.obesp1_r + kdklassm.long1_r + kdklassm.prosr_1_r +
                     kdklassm.ispakt_r + kdklassm.spisob1_r + kdklassm.rait_r.
  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdklassm.kateg_v no-lock no-error.
  if avail bookcod then kdklassm.kateg_d = bookcod.name.
end.

hide message no-pause.

/* вывод в файл  */

output stream rep to lonclrep.htm.

put stream rep unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE></TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 6" skip
   "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "<style><!--.xl24 \{mso-number-format:""\@"";\}--></style>" skip
   "</HEAD>" skip
   "<BODY>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
  "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
  "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
  "<center><font size=+1><b>Классификация кредитного портфеля по критериям</b></font><BR>" skip
  "на " dt FORMAT "99/99/9999" "<BR><BR>" skip
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<col span=13>" skip
  "<tr>" skip
  "<td width=150><center><b>Код Кл</b></center></td>" skip
  "<td width=150><center><b>Клиент</b></center></td>" skip
  "<td width=100><center><b>Счет</b></center></td>" skip
  "<td width=100><center><b>Дата</b><center></td>" skip
  "<td width=160><center><b>Фин. состояние</b><center></td>" skip
  "<td width=160><center><b>Просрочка погашения</b><center></td>" skip
  "<td width=180><center><b>Качество предлагаемого обеспечения</b><center></td>" skip
  "<td width=160><center><b>Наличие пролонгации</b><center></td>" skip
  "<td width=160><center><b>Другие просроченные обяз-ва</b><center></td>" skip
  "<td width=160><center><b>Доля нецелевого исп-ния активов</b><center></td>" skip
  "<td width=160><center><b>Наличие списанной задолженности</b><center></td>" skip
  "<td width=160><center><b>Наличие рейтинга у заемщика</b><center></td>" skip
  "<td width=60><center><b>Итого кол-во баллов</b><center></td>" skip
  "<td width=200><center><b>Статус по классификации</b><center></td>" skip
  "</tr>" skip.

for each kdklassm no-lock:
  
  put stream rep unformatted "<tr>" skip.
  put stream rep unformatted "<td>" kdklassm.cif "</td>" skip.
  find first kdcif where kdcif.kdcif = kdklassm.cif no-lock no-error.
  if avail kdcif then put stream rep unformatted "<td>" kdcif.name "</td>" skip.
  else do:
    find first cif where cif.cif = kdklassm.cif no-lock no-error.
    if avail cif then put stream rep unformatted "<td>" cif.name "</td>" skip.
    else put stream rep unformatted "<td>!! Not found !!</td>" skip.
  end.

  put stream rep unformatted
    "<td class=xl24>" kdklassm.lon "</td>" skip
    "<td>" kdklassm.rdt FORMAT "99/99/9999" "</td>" skip
    "<td>" trim(kdklassm.finsost1_d) " - " kdklassm.finsost1_r "</td>" skip
    "<td>" trim(kdklassm.prosr_d) " - " kdklassm.prosr_r "</td>" skip
    "<td>" trim(kdklassm.obesp1_d) " - " kdklassm.obesp1_r "</td>" skip
    "<td>" trim(kdklassm.long1_d) " - " kdklassm.long1_r "</td>" skip
    "<td>" trim(kdklassm.prosr_1_d) " - " kdklassm.prosr_1_r "</td>" skip
    "<td>" trim(kdklassm.ispakt_d) " - " kdklassm.ispakt_r "</td>" skip
    "<td>" trim(kdklassm.spisob1_d) " - " kdklassm.spisob1_r "</td>" skip
    "<td>" trim(kdklassm.rait_d) " - " kdklassm.rait_r "</td>" skip
    "<td>" replace(string(kdklassm.kateg_r),".",",") "</td>" skip
    "<td>" trim(kdklassm.kateg_v) " (" trim(kdklassm.kateg_d) ")</td>" skip.
    
end. /* for each kdklassm */

{html-end.i}
output stream rep close.
unix silent cptwin lonclrep.htm excel.
