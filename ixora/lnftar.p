/* lnftar.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Льготы по текущим счетам заемщиков - физ. лиц
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
        28/10/2005 madiar
 * BASES
        bank
 * CHANGES
        08/11/2005 madiar - исключения только по трем тарифам, а также выводить исключения на клиента
*/

{mainhead.i}

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
end.
lst_ur = lst_ur + ",90,92".

def var v-exs as char init "195,230,105".
def var v-bal as deci.
def var i as integer.

def temp-table wrk
  field cif like cif.cif
  field clname as char
  field lon like lon.lon
  field loncrc like crc.crc
  index idx is primary cif lon
  index idx2 cif loncrc.

def temp-table wrk2
  field cif like cif.cif
  field clname as char
  field lon like lon.lon
  field loncrc like crc.crc
  field aaa like aaa.aaa
  field aaacrc like crc.crc
  field exs as logi extent 3
  field exs_sum as deci extent 3
  field exs2 as logi extent 3
  field exs2_sum as deci extent 3
  index idx is primary cif aaacrc desc lon.

message " Формируется отчет... ".

for each lon where lon.grp < 90 no-lock:

  if lon.opnamt <= 0 then next.
  if lookup(string(lon.grp),lst_ur) > 0 then next.
  run lonbalcrc('lon',lon.lon,g-today,"1,7,2,9,16",yes,lon.crc,output v-bal).
  if v-bal <= 0 then next.

  find cif where cif.cif = lon.cif no-lock no-error.

  create wrk.
  wrk.cif = lon.cif.
  if avail cif then wrk.clname = trim(cif.name).
  wrk.lon = lon.lon.
  wrk.loncrc = lon.crc.

end. /* for each lon */

for each wrk no-lock break by wrk.cif by wrk.loncrc:

  if first-of(wrk.cif) then do:
    for each aaa where aaa.cif = wrk.cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = 1 no-lock:

      find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
      if not avail lgr then next.
      else if lgr.led = 'TDA' or lgr.led = 'CDA' /* or lgr.led = 'ODA' */ then next.

      create wrk2.
      wrk2.cif = wrk.cif.
      wrk2.clname = wrk.clname.
      wrk2.aaa = aaa.aaa.
      wrk2.aaacrc = aaa.crc.

      wrk2.exs = no.
      wrk2.exs2 = no.
      do i = 1 to 3:
        find first tarifex where tarifex.str5 = entry(i,v-exs) and tarifex.cif = wrk.cif and tarifex.stat = 'r' no-lock no-error.
        if avail tarifex then do: wrk2.exs[i] = yes. wrk2.exs_sum[i] = tarifex.ost. end.
        find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = wrk.cif and tarifex2.str5 = entry(i,v-exs) and tarifex2.stat = 'r' no-lock no-error.
        if avail tarifex2 then do: wrk2.exs2[i] = yes. wrk2.exs2_sum[i] = tarifex2.ost. end.
      end.

    end. /* for each aaa */
  end.

  if first-of(wrk.loncrc) and wrk.loncrc <> 1 then do:
    for each aaa where aaa.cif = wrk.cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = wrk.loncrc no-lock:

      find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
      if not avail lgr then next.
      else if lgr.led = 'TDA' or lgr.led = 'CDA' /* or lgr.led = 'ODA' */ then next.

      create wrk2.
      wrk2.cif = wrk.cif.
      wrk2.clname = wrk.clname.
      /*
      wrk2.lon = wrk.lon.
      wrk2.loncrc = wrk.loncrc.
      */
      wrk2.aaa = aaa.aaa.
      wrk2.aaacrc = aaa.crc.

      wrk2.exs = no.
      wrk2.exs2 = no.
      do i = 1 to 3:
        find first tarifex where tarifex.str5 = entry(i,v-exs) and tarifex.cif = wrk.cif and tarifex.stat = 'r' no-lock no-error.
        if avail tarifex then do: wrk2.exs[i] = yes. wrk2.exs_sum[i] = tarifex.ost. end.
        find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = wrk.cif and tarifex2.str5 = entry(i,v-exs) and tarifex2.stat = 'r' no-lock no-error.
        if avail tarifex2 then do: wrk2.exs2[i] = yes. wrk2.exs2_sum[i] = tarifex2.ost. end.
      end.

    end. /* for each aaa */
  end.
end. /* for each wrk */


for each wrk:

  find first wrk2 where wrk2.cif = wrk.cif and wrk2.aaacrc = wrk.loncrc and wrk2.lon = '' no-lock no-error.
  if not avail wrk2 then do:
    create wrk2.
    wrk2.cif = wrk.cif.
    wrk2.clname = wrk.clname.
  end.
  wrk2.lon = wrk.lon.
  wrk2.loncrc = wrk.loncrc.

end. /* for each wrk2 */


def var usrnm as char.
def stream rep.
output stream rep to lnftar.htm.

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
    "<center><b>Льготы, установленные по текущим счетам заемщиков - физических лиц</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>Наименование заемщика</td>" skip
    "<td>Сс.счет</td>" skip
    "<td>Валюта<BR>займа</td>" skip
    "<td>Тек.счет</td>" skip
    "<td>Валюта<BR>тек.счета</td>" skip.

do i = 1 to 3:
  put stream rep unformatted "<td>cif_" entry(i,v-exs) "</td>" skip.
end.
do i = 1 to 3:
  put stream rep unformatted "<td>aaa_" entry(i,v-exs) "</td>" skip.
end.
put stream rep unformatted "</tr>" skip.

for each wrk2 no-lock break by wrk2.cif by wrk2.aaacrc:

  if first-of(wrk2.cif) then put stream rep unformatted "<tr><td>" wrk2.cif "</td><td>" wrk2.clname "</td>" skip.
  else put stream rep unformatted "<tr><td></td><td></td>" skip.

  put stream rep unformatted
    "<td>&nbsp;" wrk2.lon "</td>" skip
    "<td>" if wrk2.loncrc > 0 then string(wrk2.loncrc,">9") else "" "</td>" skip
    "<td>&nbsp;" wrk2.aaa "</td>" skip
    "<td>" if wrk2.aaacrc > 0 then string(wrk2.aaacrc,">9") else "" "</td>" skip.

  do i = 1 to 3:
    put stream rep unformatted "<td>" if wrk2.exs[i] then replace(trim(string(wrk2.exs_sum[i],">>>>>>>>9.99")),'.',',') else "" "</td>" skip.
  end.
  do i = 1 to 3:
    put stream rep unformatted "<td>" if wrk2.exs2[i] then replace(trim(string(wrk2.exs2_sum[i],">>>>>>>>9.99")),'.',',') else "" "</td>" skip.
  end.

  put stream rep unformatted "</tr>" skip.

end. /* for each wrk2 */


put stream rep unformatted "</table></body></html>".
output stream rep close.
unix silent cptwin lnftar.htm excel.

hide message no-pause.
