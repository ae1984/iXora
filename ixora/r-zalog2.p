/* r-zalog2.p
 * MODULE
        Информация
 * DESCRIPTION
        Список кредитов с остатком осн долга  или залога 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-7-2 
 * AUTHOR
        11.02.04 nataly
 * CHANGES
        24/06/2004 madiyar - разбил залоги по валютам, итоговые суммы, вывод в excel, формирование отчета на указанную дату
        08/11/2004 madiyar - разбивка на юр/физ производится не по признаку, а по группе кредита
        09/11/2004 madiyar - последняя колонка - сумма всех 19-х уровней, включая и kzt
        31/05/2005 madiyar - пропускаем кредиты с нулевым 19 уровнем
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        31/05/2005 madiyar - добавил поля "группа" и "сотрудник?"
*/

{mainhead.i}

def var dts as date no-undo.
def stream rep.
def var itog as decimal no-undo extent 20.
def var numcol as int no-undo init 5.

def var kurs as decimal no-undo extent 20.
def var kzt_equiv as decimal no-undo.
def var sum_kzt_equiv as decimal no-undo.
def var usrnm as char no-undo.
def var bb as logi no-undo.

/* группы кредитов юридических лиц */
def var lst_ur as char no-undo init ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
end.

def var v-bal as deci no-undo.
def var v-yes as logi no-undo.

def temp-table temp no-undo
    field cif like lon.cif
    field crc like lon.crc
    field name as char
    field lon like lon.lon
    field grp like lon.grp
    field urfiz as char
    field emp as char
    field ost as decimal
    field zalog as decimal extent 20
    field tshow as logi.

dts = g-today.

update dts label ' Укажите дату ' format '99/99/9999' validate(dts <= g-today and dts > 01/03/2004, " Введите дату >= 01/03/2004 и <= сегодня") skip
       with side-label row 5 centered frame dat.
hide frame dat.

message ' ЖДИТЕ ...'.

for each crc no-lock:
  if dts = g-today then kurs[crc.crc] = crc.rate[1].
  else do:
    find last crchis where crchis.crc = crc.crc and crchis.rdt <= dts no-lock no-error.
    kurs[crc.crc] = crchis.rate[1].
  end.
end.


for each cif /* where cif.cif = 't29005'*/ no-lock:
   /*find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and d-cod = 'clnsts' no-lock no-error.
   if not avail sub-cod then next.*/
   for each lon where lon.cif = cif.cif no-lock:
      
      v-yes = no.
      for each crc no-lock:
        run lonbalcrc('lon',lon.lon,dts,"19",yes,crc.crc,output v-bal).
        if v-bal > 0 then do:
          v-yes = yes.
          leave.
        end.
      end. /* for each crc */
      
      if not (v-yes) then next.
      
      find pkanketa where pkanketa.lon = lon.lon and pkanketa.bank = 'TXB00' no-lock no-error.
      if avail pkanketa and pkanketa.credtype = '6' then next.
      
      create temp.
      temp.cif = cif.cif.
      temp.crc = lon.crc.
      temp.name = cif.name.
      temp.lon = lon.lon.
      temp.grp = lon.grp.
      if lookup(trim(string(lon.grp)),lst_ur) > 0 then temp.urfiz = 'ur'. else temp.urfiz = 'fiz'.
      
      find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnsegm' no-lock no-error.
      if avail sub-cod and sub-cod.ccode = '02' then temp.emp = "сотр".
      
      if dts = g-today then do:
        find trxbal where trxbal.acc = lon.lon and trxbal.sub = 'lon' and trxbal.lev = 1 no-lock no-error. 
        if avail trxbal then temp.ost = temp.ost + trxbal.dam - trxbal.cam.

        find trxbal where trxbal.acc = lon.lon and trxbal.sub = 'lon' and trxbal.lev = 7 no-lock no-error. 
        if avail trxbal then temp.ost = temp.ost + trxbal.dam - trxbal.cam.

        for each trxbal where trxbal.acc = lon.lon and trxbal.sub = 'lon' and trxbal.lev = 19 no-lock:
           temp.zalog[trxbal.crc] = temp.zalog[trxbal.crc] + trxbal.dam - trxbal.cam.
           itog[trxbal.crc] = itog[trxbal.crc] + trxbal.dam - trxbal.cam.
        end.
      end.
      else do:
        find last histrxbal where histrxbal.acc = lon.lon and histrxbal.sub = 'lon' and histrxbal.lev = 1 and histrxbal.dt <= dts no-lock no-error. 
        if avail histrxbal then temp.ost = temp.ost + histrxbal.dam - histrxbal.cam.

        find last histrxbal where histrxbal.acc = lon.lon and histrxbal.sub = 'lon' and histrxbal.lev = 7 and histrxbal.dt <= dts no-lock no-error. 
        if avail histrxbal then temp.ost = temp.ost + histrxbal.dam - histrxbal.cam.

        for each crc no-lock:
          find last histrxbal where histrxbal.acc = lon.lon and histrxbal.sub = 'lon' and histrxbal.lev = 19 and
                                    histrxbal.dt <= dts and histrxbal.crc = crc.crc no-lock no-error.
          if avail histrxbal then do:
             temp.zalog[histrxbal.crc] = temp.zalog[histrxbal.crc] + histrxbal.dam - histrxbal.cam.
             itog[histrxbal.crc] = itog[histrxbal.crc] + histrxbal.dam - histrxbal.cam.
          end.
        end.
      end.
      
      bb = false.
      if temp.ost <> 0 then bb = true.
      for each crc no-lock:
        if temp.zalog[crc.crc] <> 0 then bb = true.
      end.
      temp.tshow = bb.
      
  end. /*lon*/
end. /*cif*/

output stream rep to rpt.htm.

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
    "<center><b>Список кредитов с остатком осн долга  или залога за " dts format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код клиента</td>" skip
    "<td>Наименование клиента</td>" skip
    "<td>Сотрудник?</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>Группа</td>" skip
    "<td>Валюта</td>" skip
    "<td>Остаток<BR>(Уровни 1+7)</td>" skip.
for each crc no-lock:
  if itog[crc.crc] <> 0 then do:
    put stream rep unformatted "<td>Сумма залога<BR>(19 уровень " crc.code ")</td>" skip.
    numcol = numcol + 1.
  end.
end.
put stream rep unformatted
    "<td>Сумма залога<BR>(19 уровень<BR>эквивалент в KZT)</td>" skip
    "</tr>" skip.

def buffer b-crc for crc.

for each temp where temp.tshow break by urfiz by temp.cif.

  kzt_equiv = 0.
  
  if first-of(temp.urfiz) then do:
    if temp.urfiz = 'ur' then put stream rep unformatted "<tr><td colspan=" numcol "><b>Юридические лица (ВСЕ)</b></td></tr>" skip.
    else put stream rep unformatted "<tr><td colspan=" numcol "><b>Физические лица (кроме БЫСТРЫХ ДЕНЕГ)</b></td></tr>" skip.
  end.
  
  find first b-crc where b-crc.crc = temp.crc no-lock no-error.
  
  if first-of(temp.cif) then do:
    put stream rep unformatted
      "<tr align=""right"">" skip
      "<td align=""left"">" temp.cif "</td>" skip
      "<td align=""left"">" temp.name "</td>" skip
      "<td align=""left"">" temp.emp "</td>" skip.
  end.
  else do:
    put stream rep unformatted
      "<tr align=""right"">" skip
      "<td align=""left""></td>" skip
      "<td align=""left""></td>" skip
      "<td align=""left""></td>" skip.
  end.
  
  put stream rep unformatted
      "<td align=""left"">&nbsp;" temp.lon "</td>" skip
      "<td align=""left"">" temp.grp "</td>" skip
      "<td align=""left"">&nbsp;" b-crc.code "</td>" skip
      "<td>" temp.ost format 'zzz,zzz,zzz,zz9.99' "</td>" skip.
  for each crc no-lock:
    if itog[crc.crc] <> 0 then put stream rep unformatted "<td>" temp.zalog[crc.crc] format 'zzz,zzz,zzz,zz9.99' "</td>" skip.
    if crc.crc = 1 then kzt_equiv = kzt_equiv + temp.zalog[crc.crc].
    if crc.crc <> 1 then kzt_equiv = kzt_equiv + temp.zalog[crc.crc] * kurs[crc.crc].
  end.
  put stream rep unformatted
    "<td>" kzt_equiv format 'zzz,zzz,zzz,zz9.99' "</td>" skip
    "</tr>" skip.
  
  sum_kzt_equiv = sum_kzt_equiv + kzt_equiv.
  
end. /* for each temp */

put stream rep unformatted
      "<tr style=""font:bold"" align=""right"">" skip
      "<td align=""left"" colspan=3>ИТОГО</td>" skip
      "<td></td><td></td>" skip.
for each crc no-lock:
   if itog[crc.crc] <> 0 then put stream rep unformatted "<td>" itog[crc.crc] format 'zzz,zzz,zzz,zz9.99' "</td>" skip.
end.
put stream rep unformatted
    "<td>" sum_kzt_equiv format 'zzz,zzz,zzz,zz9.99' "</td>" skip
    "</tr>" skip.


put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rpt.htm excel.