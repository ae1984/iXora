/* lnklctrl.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет - контроль за формированием провизий
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
        31/08/2004 madiar
 * CHANGES
*/

{mainhead.i}

def temp-table lnnn
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field crc         like lon.crc
  field opnamt      like lon.opnamt
  field ostatok     like lon.opnamt
  field rdt         like lon.rdt
  field duedt       like lon.duedt
  field finsostr    as   char
  field finsost     as   char
  field prosrpogr   as   char
  field prosrpog    as   char
  field obespr      as   char
  field obesp       as   char
  field prolongr    as   char
  field prolong     as   char
  field drprosrr    as   char
  field drprosr     as   char
  field necelr      as   char
  field necel       as   char
  field spisr       as   char
  field spis        as   char
  field rat_rkr     as   char
  field rat_rk      as   char
  field ratallr     as   deci
  field ratall      as   deci
  field klstsr      as   char
  field klsts       as   char
  field provr       as   deci
  field prov        as   deci
  field differ      as   deci
  index ind is primary cif lon.

def var bilance as deci.
def var v-dt as date.
def stream rep.
def var usrnm as char.
def var bi as deci.

def var v-rat as deci.
def var v-ratr as deci.

{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

/* по всем кредитам юр. лиц */
for each lon where lon.grp = 10 or lon.grp = 15 or lon.grp = 30 or lon.grp = 35 or lon.grp = 50 or lon.grp = 55 or lon.grp = 70 no-lock:
  run lonbal('lon', lon.lon, g-today, "1,7,21", yes, output bilance).
  if bilance <= 0 then next.
  
  find cif where cif.cif = lon.cif no-lock no-error.
  
  create lnnn.
  assign lnnn.cif = lon.cif.
  if avail cif then lnnn.klname = trim(cif.prefix) + ' ' + trim(cif.name).
  else lnnn.klname = "--не найдено--".
  assign lnnn.lon = lon.lon
         lnnn.crc = lon.crc
         lnnn.opnamt = lon.opnamt
         lnnn.ostatok = bilance
         lnnn.rdt = lon.rdt.
  lnnn.duedt = lon.duedt.
  if lon.ddt[5] <> ? /* and txb.lon.ddt[5] < dat */ then lnnn.duedt = lon.ddt[5].
  if lon.cdt[5] <> ? /* and txb.lon.cdt[5] < dat */ then lnnn.duedt = lon.cdt[5].
  
  find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif 
                     and kdlonkl.kdlon = lon.lon use-index bclrdt no-lock no-error.
  if avail kdlonkl then do:
    v-dt = kdlonkl.rdt.
    for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif 
                     and kdlonkl.kdlon = lon.lon and kdlonkl.rdt = v-dt no-lock.
       case kdlonkl.kod:
         when 'finsost1' then do: /* kdfin */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.finsost = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.finsostr = lnnn.finsost.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.finsostr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'prosr' then do: /* kdprosr */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.prosrpog = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.prosrpogr = lnnn.prosrpog.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.prosrpogr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'obesp1' then do: /* kdobes */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.obesp = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.obespr = lnnn.obesp.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.obespr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'long1' then do: /* kdlong ???? */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.prolong = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.prolongr = lnnn.prolong.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.prolongr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'prosr_1' then do: /* kdlong1 ???? */ 
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdlong1' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.drprosr = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.drprosrr = lnnn.drprosr.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdlong1' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.drprosrr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'ispakt' then do: /* kdispakt */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdispakt' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.necel = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.necelr = lnnn.necel.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdispakt' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.necelr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'spisob1' then do: /* kdkred */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdkred' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.spis = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.spisr = lnnn.spis.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdkred' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.spisr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
         when 'rait' then do: /* kdrait */
            bi = 0.
            find bookcod where bookcod.bookcod = 'kdrait' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then do:
               lnnn.rat_rk = kdlonkl.val1 + ' - ' + bookcod.name.
               bi = deci(trim(bookcod.info[1])).
               v-rat = v-rat + bi.
            end.
            if kdlonkl.info[1] = '' then do:
              lnnn.rat_rkr = lnnn.rat_rk.
              v-ratr = v-ratr + bi.
            end.
            else do:
              find bookcod where bookcod.bookcod = 'kdrait' and bookcod.code = kdlonkl.info[1] no-lock no-error.
              if avail bookcod then do:
                 lnnn.rat_rkr = kdlonkl.info[1] + ' - ' + bookcod.name.
                 v-ratr = v-ratr + deci(trim(bookcod.info[1])).
              end.
            end.
         end.
       end. /* case */
    end. /* for each kdlonkl */
    
    lnnn.ratall = v-rat.
    lnnn.ratallr = v-ratr.
    find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif 
                       and kdlonkl.kdlon = lon.lon and kdlonkl.rdt = v-dt and kdlonkl.kod = 'klass' no-lock.
    if avail kdlonkl then do:
      lnnn.klsts = kdlonkl.val1.
      if kdlonkl.info[1] <> '' then lnnn.klstsr = kdlonkl.info[1].
      else lnnn.klstsr = kdlonkl.val1.
    end.
    find first lonstat where lonstat.lonstat = integer(lnnn.klsts) no-lock no-error.
    if avail lonstat then lnnn.prov = bilance * lonstat.prc / 100.
    find first lonstat where lonstat.lonstat = integer(lnnn.klstsr) no-lock no-error.
    if avail lonstat then lnnn.provr = bilance * lonstat.prc / 100.
    lnnn.differ = lnnn.provr - lnnn.prov.
  end. /* if avail kdlonkl */
  else lnnn.finsostr = "---".
  
end.

output stream rep to lnklctrl.htm.

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
    "<center><b>Контрольный отчет по классификации кредитного портфеля на " g-today format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код клиента</td>" skip
    "<td>Наименование клиента</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>Валюта кредита</td>" skip
    "<td>Сумма кредита</td>" skip
    "<td>Остаток кредита</td>" skip
    "<td>Дата выдачи</td>" skip
    "<td>Дата погашения</td>" skip
    "<td>Фин. состояние - R</td>" skip
    "<td>Фин. состояние</td>" skip
    "<td>Просрочка погашения - R</td>" skip
    "<td>Просрочка погашения</td>" skip
    "<td>Качество предл. обеспечения - R</td>" skip
    "<td>Качество предл. обеспечения</td>" skip
    "<td>Наличие пролонгаций - R</td>" skip
    "<td>Наличие пролонгаций</td>" skip
    "<td>Другие проср. обязательства - R</td>" skip
    "<td>Другие проср. обязательства</td>" skip
    "<td>Доля нецелевого исп-я активов - R</td>" skip
    "<td>Доля нецелевого исп-я активов</td>" skip
    "<td>Наличие спис. задолженности - R</td>" skip
    "<td>Наличие спис. задолженности</td>" skip
    "<td>Наличие рейтинга у заемщика - R</td>" skip
    "<td>Наличие рейтинга у заемщика</td>" skip
    "<td>Итого баллов - R</td>" skip
    "<td>Итого баллов</td>" skip
    "<td>Статус по класс-ции - R</td>" skip
    "<td>Статус по класс-ции</td>" skip
    "<td>Сумма провизий - R</td>" skip
    "<td>Сумма провизий</td>" skip
    "<td>Разница</td>" skip
    "</tr>" skip.

for each lnnn no-lock:
  
  find first crc where crc.crc = lnnn.crc no-lock no-error.
  put stream rep unformatted
      "<tr align=""right"">" skip
      "<td>" lnnn.cif "</td>" skip
      "<td>" lnnn.klname "</td>" skip
      "<td>&nbsp;" lnnn.lon "</td>" skip
      "<td>" crc.code skip
      "<td>" lnnn.opnamt format ">>>>>>>>>>>>>>9,99" "</td>" skip
      "<td>" lnnn.ostatok format ">>>>>>>>>>>>>>9,99" "</td>" skip
      "<td>" lnnn.rdt format "99/99/9999" "</td>" skip
      "<td>" lnnn.duedt format "99/99/9999" "</td>" skip
      "<td>" lnnn.finsostr "</td>" skip
      "<td>" lnnn.finsost "</td>" skip
      "<td>" lnnn.prosrpogr "</td>" skip
      "<td>" lnnn.prosrpog "</td>" skip
      "<td>" lnnn.obespr "</td>" skip
      "<td>" lnnn.obesp "</td>" skip
      "<td>" lnnn.prolongr "</td>" skip
      "<td>" lnnn.prolong "</td>" skip
      "<td>" lnnn.drprosrr "</td>" skip
      "<td>" lnnn.drprosr "</td>" skip
      "<td>" lnnn.necelr "</td>" skip
      "<td>" lnnn.necel "</td>" skip
      "<td>" lnnn.spisr "</td>" skip
      "<td>" lnnn.spis "</td>" skip
      "<td>" lnnn.rat_rkr "</td>" skip
      "<td>" lnnn.rat_rk "</td>" skip
      "<td>" lnnn.ratallr format ">>>>>9,99" "</td>" skip
      "<td>" lnnn.ratall format ">>>>>9,99" "</td>" skip
      "<td>" lnnn.klstsr "</td>" skip
      "<td>" lnnn.klsts "</td>" skip
      "<td>" lnnn.provr "</td>" skip
      "<td>" lnnn.prov "</td>" skip
      "<td>" lnnn.differ "</td>" skip
      "</tr>" skip.
  
end.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin lnklctrl.htm excel.

