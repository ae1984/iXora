/* r-lnapg2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Обороты по счетам за период по группам
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
        10/06/2004 madiar - переделанный старый отчет r-lnapg2
 * CHANGES
        18/06/2004 madiar - оптимизация
        16/12/05   marinav - переделала for each jl
*/

{mainhead.i}

def var dt1 as date.
def var dt2 as date.
def var groups as char.
def var usrnm as char.

def var f-lev as int.
def var f-deb as deci.
def var f-cred as deci.
def var v-name as char.
def var v-lneko as char.
def var v-ecdivis as char.
def var v-gruppa as char.
def var sum_de as deci extent 30.
def var sum_cr as deci extent 30.
def var sum_de_kzt as deci extent 30.
def var sum_cr_kzt as deci extent 30.

/* итоговые суммы */
def var sumcrc_de as deci extent 30.
def var sumcrc_cr as deci extent 30.
def var sumcrc_de_kzt as deci extent 30.
def var sumcrc_cr_kzt as deci extent 30.
def var sumgrp_de_kzt as deci extent 30.
def var sumgrp_cr_kzt as deci extent 30.
def var sumcrctot as deci extent 4.
def var sumgrptot as deci extent 2.

def var i as int.
def var grp_ind as int.

def var c-levs  as character extent 19 
    init ["Осн","Рассч%","","","","","Прср","Блок","Прср%","Прдпл%","ПерО","ПерП","","","","","","",""].
def stream rep.

def temp-table lnnn
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field grp         as   int
  field crc         like lon.crc
  field gruppa      as   char
  field mlevel      as   int
  field deb         as   deci
  field cred        as   deci
  field deb_kzt     as   deci
  field cred_kzt    as   deci
  field secec       as   char
  field otrasl      as   char
  field prem        like lon.prem
  index ind is primary grp crc cif lon.

define frame fr skip(1)
       dt1 label " C "
       dt2 label "  По "
       groups format "X(30)" label "  Группы " help " Введите через запятую номера групп" " " skip(1) with side-labels.

dt2 = date(month(g-today),1,year(g-today)) - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 dt2 groups with frame fr.

if dt2 = g-today then message " День не закрыт. Данные на текущий момент. " view-as alert-box buttons ok title " Внимание! ".

do grp_ind = 1 to num-entries(groups):

for each lon /*where lon.grp = integer(entry(grp_ind,groups))*/ no-lock /*use-index grp*/:
if lon.grp ne integer(entry(grp_ind,groups)) then next.

  do i = 1 to 30:
    sum_de[i] = 0. sum_cr[i] = 0.
    sum_de_kzt[i] = 0. sum_cr_kzt[i] = 0.
  end.
  
  for each lonres where lonres.lon = lon.lon and lonres.jdt >= dt1 and lonres.jdt <= dt2 no-lock:
    if lookup(string(lonres.lev),"1,7,8") = 0 then next.
    f-lev = lonres.lev.
    f-deb = 0. f-cred = 0.
    if lonres.dc = 'D' then do:
      f-deb = lonres.amt.
      for each jl where jl.jh = lonres.jh  no-lock.
      if jl.acc = lon.lon and jl.dc = 'C' and jl.cam = lonres.amt and jl.jdt = lonres.jdt then do:
        if lonres.lev = 1 then f-lev = 11. /* level 11 "ПерО" */
                          else f-lev = 12. /* level 12 "ПерП" */
      end.
      end.
    end.
    if lonres.dc = 'C' then do:
      f-cred = lonres.amt.
      for each jl where jl.jh = lonres.jh no-lock.
      if jl.acc = lon.lon and jl.dc = 'D' and jl.dam = lonres.amt and jl.jdt = lonres.jdt then do:
        if lonres.lev = 1 then f-lev = 11. /* level 11 "ПерО" */
                          else f-lev = 12. /* level 12 "ПерП" */
      end.
      end.
    end.
    
    sum_de[f-lev] = sum_de[f-lev] + f-deb.
    sum_cr[f-lev] = sum_cr[f-lev] + f-cred.
    
    find last crchis where crchis.crc = lonres.crc and crchis.rdt <= lonres.jdt no-lock no-error.
    if avail crchis then do:
      sum_de_kzt[f-lev] = sum_de_kzt[f-lev] + f-deb * crchis.rate[1].
      sum_cr_kzt[f-lev] = sum_cr_kzt[f-lev] + f-cred * crchis.rate[1].
    end.
    
  end. /* for each lonres */
  find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lngrp' no-lock no-error.
  if avail sub-cod then v-gruppa = sub-cod.ccode. else v-gruppa = ''. 
  find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lneko' no-lock no-error.
  if avail sub-cod then v-lneko = sub-cod.ccode. else v-lneko = ''.
  find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'ecdivis' no-lock no-error.
  if avail sub-cod then v-ecdivis = sub-cod.ccode. else v-ecdivis = ''. 
  
  find first cif where cif.cif = lon.cif no-lock no-error.
  if avail cif then v-name = cif.prefix + " " + cif.name. else v-name = ''.
  
  do i = 1 to 30:
    if sum_de[i] + sum_cr[i] > 0 then do:
      create lnnn.
      assign lnnn.cif = lon.cif
             lnnn.lon = lon.lon
             lnnn.klname = v-name
             lnnn.grp = lon.grp
             lnnn.crc = lon.crc
             lnnn.prem = lon.prem
             lnnn.mlevel = i
             lnnn.deb = sum_de[i]
             lnnn.cred = sum_cr[i]
             lnnn.deb_kzt = sum_de_kzt[i]
             lnnn.cred_kzt = sum_cr_kzt[i]
             lnnn.gruppa = v-gruppa
             lnnn.secec = v-lneko
             lnnn.otrasl = v-ecdivis.
    end.
  end.
  
end. /* for each lon */

end. /* do grp_ind = 1 to */

output stream rep to rep.htm.

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
    "<center><b>Обороты по счетам за период с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Наименование клиента</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>Уровень</td>" skip
    "<td>Дебет</td>" skip
    "<td>Кредит</td>" skip
    "<td>Дебет KZT</td>" skip
    "<td>Кредит KZT</td>" skip
    "<td>Сектор эк</td>" skip
    "<td>Отрасль</td>" skip
    "<td>Группа</td>" skip
    "<td>% ставка</td>" skip
    "</tr>" skip.

for each lnnn no-lock break by lnnn.grp by lnnn.crc by lnnn.cif by lnnn.lon:
  
  if first-of(lnnn.grp) then put stream rep unformatted "<tr><td colspan=10 bgcolor=""#9BCDFF""><b>Обороты по группе " lnnn.grp "</b></td></tr>" skip.
  
  if first-of(lnnn.lon) then do:
    put stream rep unformatted "<tr align=""right"">" skip.
    if first-of(lnnn.cif) then put stream rep unformatted "<td align=""left"">" lnnn.klname "</td>" skip.
    else put stream rep unformatted "<td></td>" skip.
    put stream rep unformatted
      "<td align=""left"">&nbsp;" lnnn.lon "</td>" skip
      "<td align=""left"">" c-levs[lnnn.mlevel] "</td>" skip
      "<td>" lnnn.deb format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.cred format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.deb_kzt format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.cred_kzt format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.secec "</td>" skip
      "<td>" lnnn.otrasl "</td>" skip
      "<td>" lnnn.gruppa "</td>" skip
      "<td>" lnnn.prem format ">>9.99" "</td>" skip
      "</tr>" skip.
  end.
  else
    put stream rep unformatted
      "<tr align=""right"">" skip
      "<td></td>" skip
      "<td></td>" skip
      "<td align=""left"">" c-levs[lnnn.mlevel] "</td>" skip
      "<td>" lnnn.deb format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.cred format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.deb_kzt format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.cred_kzt format ">>>>>>>>>>>>>>9.99" "</td>" skip
      "<td>" lnnn.secec "</td>" skip
      "<td>" lnnn.otrasl "</td>" skip
      "<td>" lnnn.gruppa "</td>" skip
      "<td>" lnnn.prem format ">>9.99" "</td>" skip
      "</tr>" skip.
  
  sumcrc_de[mlevel] = sumcrc_de[mlevel] + lnnn.deb.
  sumcrc_cr[mlevel] = sumcrc_cr[mlevel] + lnnn.cred.
  sumcrc_de_kzt[mlevel] = sumcrc_de_kzt[mlevel] + lnnn.deb_kzt.
  sumcrc_cr_kzt[mlevel] = sumcrc_cr_kzt[mlevel] + lnnn.cred_kzt.
  
  sumgrp_de_kzt[mlevel] = sumgrp_de_kzt[mlevel] + lnnn.deb_kzt.
  sumgrp_cr_kzt[mlevel] = sumgrp_cr_kzt[mlevel] + lnnn.cred_kzt.
  
  if last-of(lnnn.crc) then do:
    find crc where crc.crc = lnnn.crc no-lock.
    put stream rep unformatted
          "<tr><td colspan=10><b>ИТОГО ПО " crc.code "</b></td></tr>" skip.
    do i = 1 to 30:
      if sumcrc_de[i] + sumcrc_cr[i] > 0 then
        put stream rep unformatted
          "<tr align=""right"">" skip
          "<td></b></td>"
          "<td></td>" skip
          "<td align=""left"">" c-levs[i] "</td>" skip
          "<td>" sumcrc_de[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrc_cr[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrc_de_kzt[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrc_cr_kzt[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "</tr>" skip.
      sumcrctot[1] = sumcrctot[1] + sumcrc_de[i].
      sumcrctot[2] = sumcrctot[2] + sumcrc_cr[i].
      sumcrctot[3] = sumcrctot[3] + sumcrc_de_kzt[i].
      sumcrctot[4] = sumcrctot[4] + sumcrc_cr_kzt[i].
      sumcrc_de[i] = 0. sumcrc_cr[i] = 0.
      sumcrc_de_kzt[i] = 0. sumcrc_cr_kzt[i] = 0.
    end. /* do */
    put stream rep unformatted
          "<tr align=""right"">" skip
          "<td></b></td>"
          "<td></td>" skip
          "<td align=""left"">ВСЕГО</td>" skip
          "<td>" sumcrctot[1] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrctot[2] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrctot[3] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumcrctot[4] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "</tr>" skip
          "<tr><td colspan=10></td></tr>" skip.
    do i = 1 to 4: sumcrctot[i] = 0. end.
  end.

  if last-of(lnnn.grp) then do:
    put stream rep unformatted
          "<tr><td colspan=10><b>ИТОГО ПО ГРУППЕ " lnnn.grp "</b></td></tr>" skip.
    do i = 1 to 30:
      if sumgrp_de_kzt[i] + sumgrp_cr_kzt[i] > 0 then
        put stream rep unformatted
          "<tr align=""right"">" skip
          "<td></b></td>"
          "<td></td>" skip
          "<td align=""left"">" c-levs[i] "</td>" skip
          "<td></td>" skip
          "<td></td>" skip
          "<td>" sumgrp_de_kzt[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumgrp_cr_kzt[i] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "</tr>" skip.
      sumgrptot[1] = sumgrptot[1] + sumgrp_de_kzt[i].
      sumgrptot[2] = sumgrptot[2] + sumgrp_cr_kzt[i].
      sumgrp_de_kzt[i] = 0. sumgrp_cr_kzt[i] = 0.
    end.
    put stream rep unformatted
          "<tr align=""right"">" skip
          "<td></b></td>"
          "<td></td>" skip
          "<td align=""left"">ВСЕГО</td>" skip
          "<td></td>" skip
          "<td></td>" skip
          "<td>" sumgrptot[1] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>" sumgrptot[2] format ">>>>>>>>>>>>>>9.99" "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "<td>"  "</td>" skip
          "</tr>" skip
          "<tr><td colspan=10></td></tr>" skip.
    do i = 1 to 2: sumgrptot[i] = 0. end.
  end.
    
end. /* for each lnnn */

put stream rep unformatted "</table></body></html>".
output stream rep close.
unix silent cptwin rep.htm excel.
