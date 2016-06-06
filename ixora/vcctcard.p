/* vcctcard.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Формирование лицевой карточки валютного контроля
 * RUN
        перед запуском должна быть определена шаренная переменная s-contract
 * CALLER
        vccontrs
 * SCRIPT

 * INHERIT

 * MENU
        15.1
 * AUTHOR
        11.04.2003 nadejda
 * CHANGES
        05.08.2003 nadejda - убрала UDF из условия where
        13.08.2003 nadejda - поправила поиск текущего счета, чтобы искал по нужным группам
        15.08.2003 nadejda - добавила ограничение по дате отчета для поиска документов
        18.01.2004 nadejda - добавила код региона клиента
        05.02.2004 nadejda - изменены форматы вывода
        03.03.2004 tsoy    - переставил код региона
        01.07.2004 saltanat - для контрактов типа =5, обязательным является наличие паспорта сделки
        11.02.2005 saltanat - включила проставление статуса Лицевой карты
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
        04.08.2011 damir - объявил переменные v-valogov1,v-valogov2
        08.08.2011 aigul - вывод инфы по ИНН, счета получателя, банк бенефициара, банк-корреспондент
        09.09.2011 damir - объявил переменную v-check.
*/


{global.i}
{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var v-cifname as char.
def var v-ans as logical init no.
def var v-dt as date.
def var v-strdt as char.
def var v-str as char.
def var v-addr as char.
def var v-kod as char.
def var v-psnum as char.
def var v-partnname as char.
def var i as integer.
def var v-cardnum as char.
def var v-acc as char.
def var v-sum as deci.
def var v-curscon as deci.
def var v-crc as integer.
def var v-addinfo as char.
def var v-val as char.
def var v-valpl as char.
def var v-filename as char init "ctcard.htm".
def stream rep-err.
def var v-fileerr as char init "reperr.txt".
def var v-region as char init "".
def var v-psdnnum as char.
def var v-failsum as deci.
def var v-note as char.
def var v-type as char format 'x(1)' init ''.
def var v-dep as char.
def var v-datastrkz as char no-undo.
def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.

def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .
def var v-check as logi init no.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
if not avail vccontrs then return.

if ((vccontrs.cttype <> "1") and (vccontrs.cttype <> "5")) then do:
  message skip " Лицевые карточки банковского контроля формируются только для контрактов с паспортами сделок!"
          skip(1) view-as alert-box button ok title "".
  return.
end.

find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
if not avail vcps then do:
  message skip " Паспорт сделки не найден!"
          skip(1) view-as alert-box button ok title "".
  return.
end.
v-psdnnum = vcps.dnnum.

find cif where cif.cif = vccontrs.cif no-lock no-error.
find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek" and sub-cod.acc = cif.cif no-lock no-error.
if sub-cod.ccode = "9" then do:
  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" and sub-cod.acc = cif.cif no-lock no-error.
  if sub-cod.ccode = "98" then v-kod = cif.jss.
                          else v-kod = cif.ssn.
end.
else v-kod = cif.ssn.

if length(v-kod) < 12 then v-kod = v-kod + fill("0", 12 - length(v-kod)).

find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "regionkz" and sub-cod.acc = cif.cif no-lock no-error.
if avail sub-cod and sub-cod.ccode <> "msc" then v-region = sub-cod.ccode.

/* проверить неактуальные валюты */
v-crc = vccontrs.ncrc.
find ncrc where ncrc.crc = v-crc no-lock no-error.
if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
  v-curscon = decimal(entry(3, ncrc.prefix)).
  v-addinfo = "Фактическая валюта контракта " + ncrc.code.
  v-val = entry(1, ncrc.prefix).

  find ncrc where ncrc.code = v-val no-lock no-error.
  v-crc = ncrc.crc.
end.

def var v-lgrlist as char.
find sysc where sysc.sysc = "vc-agr" no-lock no-error.
if avail sysc then v-lgrlist = sysc.chval.

find first aaa where aaa.cif = cif.cif and aaa.crc = v-crc and aaa.sta = "A" and lookup(string(aaa.lgr), v-lgrlist) > 0 no-lock use-index cif no-error.
if not avail aaa then do:
  find first aaa where aaa.cif = cif.cif and aaa.crc = 2 and aaa.sta = "A" and lookup(string(aaa.lgr), v-lgrlist) > 0 no-lock use-index cif no-error.
  if not avail aaa then do:
    find first aaa where aaa.cif = cif.cif and aaa.crc = 1 and aaa.sta = "A" and lookup(string(aaa.lgr), v-lgrlist) > 0 no-lock use-index cif no-error.
    if not avail aaa then find first aaa where aaa.cif = cif.cif and aaa.sta = "A" and lookup(string(aaa.lgr), v-lgrlist) > 0 no-lock use-index cif no-error.
  end.
end.

if not avail aaa then do:
  message skip " Доступный текущий счет не найден!"
          skip(1) view-as alert-box button ok title "".
  return.
end.

v-acc = aaa.aaa.

output stream rep-err to value(v-fileerr).

put stream rep-err unformatted skip(1)
  " ОШИБКИ, ОБНАРУЖЕННЫЕ ПРИ ФОРМИРОВАНИИ ЛИЦЕВОЙ КАРТОЧКИ БАНКОВСКОГО КОНТРОЛЯ" skip(1).

/* проверить наличие кода региона у клиента */
if v-region = "" then do:
  v-ans = yes.
  put stream rep-err unformatted " Не указан код региона" skip.
end.

/* проверить наличие ОКПО/РНН клиента */
if v-kod = fill("0", 12) then do:
  v-ans = yes.
  put stream rep-err unformatted " Отсутствует код ОКПО/РНН" skip.
end.

/* проверить наличие кода таможенного органа клиента */
if trim(vccontrs.custom)  = "" then do:
  v-ans = yes.
  put stream rep-err unformatted " Отсутствует код таможенного органа" skip.
end.

/* проверка формата номера ПС */
if length(vcps.dnnum) < 19 then do:
  v-ans = yes.
  put stream rep-err unformatted " Короткий номер ПС" skip.
end.

if length(vcps.dnnum) > 30 then do:
  v-ans = yes.
  put stream rep-err unformatted " Длинный номер ПС" skip.
end.

if not vcps.dnnum matches "../......../.../0\.*" or (substr(vcps.dnnum, 17, 2) <> "0.") then do:
  v-ans = yes.
  put stream rep-err unformatted " Неверный формат номера ПС" skip.
end.

/* проверка суммы на 1 - не исправленная сумма */
if vcps.sum = 1 then do:
  v-ans = yes.
  put stream rep-err unformatted " В ПС номер " vcps.dnnum " не исправлена сумма после импорта в ПРАГМУ" skip.
end.


def shared frame vccontrs.
{vccontrs.f}


v-dt = date(month(g-today), 1, year(g-today)).
run pkdefdtstr(v-dt, output v-strdt, output v-datastrkz).

v-str = ''. v-type = ''.
v-type = vccontrs.cardtype.
if vccontrs.cardnum = "" or vccontrs.ctregnom = 0 then do:
  if vccontrs.ctregnom = 0 then do:
    find current vccontrs exclusive-lock.
    update vccontrs.ctregnom with frame vccontrs.
    find current vccontrs no-lock.
  end.

  if vccontrs.cardnum = "" then do:
    /* первый раз формируется номер лицевой карточки банковского контроля */
    v-str = "".
    do i = 1 to length(vcps.dnnum):
      if index("12", substr(vcps.dnnum, i, 1)) > 0 then v-str = v-str + substr(vcps.dnnum, i, 1).
      if length(v-str) = 2 then leave.
    end.

    v-str = v-str + string(vccontrs.ctregnom).
    find vcparams where vcparams.parcode = "mt105-rn" no-lock no-error.
    /* попытаемся включить в карточку дату регистрации целиком */
    if length(v-str) + 6 <= vcparam.valinte then v-str = v-str + replace(string(vccontrs.rdt, "99/99/99"), "/", "").
    else do:
      /* не поместилась дата - попытаемся обсечь нули */
      if length(v-str) + length(replace(replace(string(vccontrs.rdt, "99/99/99"), "/", ""), "0", "")) <= vcparam.valinte then v-str = v-str + replace(replace(string(vccontrs.ctdate, "99/99/99"), "/", ""), "0", "").
      else do:
        /* все равно дата не поместилась - обсекаем день */
        if length(v-str) + 4 <= vcparam.valinte then v-str = v-str + string(month(vccontrs.rdt), "99") + substr(string(year(vccontrs.ctdate), "9999"), 3, 2).
        else do:
          /* все равно не поместилась - ну тогда только год оставим! */
          if length(v-str) + 2 <= vcparam.valinte then v-str = v-str + substr(string(year(vccontrs.rdt), "9999"), 3, 2).
        end.
      end.
    end.
  end.
  else do:
    if num-entries(vccontrs.cardnum, "/") >= 3 then v-str = entry (3, vccontrs.cardnum, "/").
  end.

  find first cmp no-lock no-error.

  repeat:
    update v-str format "x(12)" label " Номер лицевой карточки"
           help " Уточните уникальную часть номер лицевой карточки банковского контроля"
           validate(length(v-str) >=3 and length(v-str) <= 12, " Номер должен быть не меньше 3 и не больше 12 символов!") skip
           v-type format "x(1)" label "Признак лицевой карточки"
           help " Ввести можно только- N "
           validate( upper(v-type) = "N" or v-type = "", "Признак лицевой карточки может быть равен только: N!")
      with centered overlay side-label row 8 title " УНИКАЛЬНАЯ ЧАСТЬ НОМЕРА КАРТОЧКИ " frame f-cardnum.

    /* вот это и будет номер лицевой карточки */

    v-cardnum = substr(cmp.addr[3], 1, 8) + "/" + substr(cmp.addr[3], 9, 4) + "/" + v-str.

    find first b-vccontrs where b-vccontrs.cardnum = v-cardnum and b-vccontrs.contract <> vccontrs.contract no-lock no-error.
    if avail b-vccontrs then
      message skip " Такая лицевая карточка банковского контроля уже существует!"
              skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    else
      leave.
  end.

  find current vccontrs exclusive-lock.
  vccontrs.cardnum  = v-cardnum.
  vccontrs.cardtype = upper(v-type).
  find current vccontrs no-lock.

  hide frame f-cardnum.
end.
else do:
  update v-type format "x(1)" label "Признак лицевой карточки"
         help " Ввести можно только- N "
         validate( upper(v-type) = "N" or v-type = "", "Признак лицевой карточки может быть равен только: N!")
      with centered overlay side-label row 8 title " УНИКАЛЬНАЯ ЧАСТЬ НОМЕРА КАРТОЧКИ " frame f-cardnum1.

  find current vccontrs exclusive-lock.
  vccontrs.cardtype = upper(v-type).
  find current vccontrs no-lock.
  hide frame f-cardnum1.
end.


def temp-table t-rslc
  field ln as integer
  field lcnum as char
  field lcdate as date
  field lcsum as deci
  field lclast as date
  field rsnum as char
  field rssum as deci
  index ln is primary unique ln.

def temp-table t-docs0
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  index main is primary dndate dnnum docs.



for each t-docs0. delete t-docs0. end.
for each vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "22" no-lock:
  if vcrslc.dndate >= v-dt then next.

  create t-docs0.
  t-docs0.docs = vcrslc.rslc.
  buffer-copy vcrslc to t-docs0.
end.

i = 0.
for each t-docs0:
  /* lc */
  find vcrslc where vcrslc.rslc = t-docs0.docs no-lock no-error.

  i = i + 1.
  create t-rslc.
  assign t-rslc.ln = i
         t-rslc.lcnum = vcrslc.dnnum
         t-rslc.lcdate = vcrslc.dndate
         t-rslc.lcsum = vcrslc.sum
         t-rslc.lclast = vcrslc.lastdate.

  /* исключить неактуальные валюты * /
  find ncrc where ncrc.crc = vcrslc.ncrc no-lock no-error.
  if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
    t-rslc.lcsum = t-rslc.lcsum / decimal(entry(3, ncrc.prefix)).
  end.
  */
end.

for each t-docs0. delete t-docs0. end.
for each vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock:
  if vcrslc.dndate >= v-dt then next.

  create t-docs0.
  t-docs0.docs = vcrslc.rslc.
  buffer-copy vcrslc to t-docs0.
end.

for each t-docs0:
  /* rs */
  find vcrslc where vcrslc.rslc = t-docs0.docs no-lock no-error.

  find first t-rslc where t-rslc.rsnum = "" no-error.

  if not avail t-rslc then do:
    find last t-rslc no-lock no-error.
    if avail t-rslc then i = t-rslc.ln + 1.
                    else i = 1.
    create t-rslc.
    t-rslc.ln = i.
  end.

  assign t-rslc.rsnum = vcrslc.dnnum
         t-rslc.rssum = vcrslc.sum.

  /*find ncrc where ncrc.crc = vcrslc.ncrc no-lock no-error.
  if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
    t-rslc.lcsum = t-rslc.lcsum / decimal(entry(3, ncrc.prefix)).
  end.*/
end.

for each t-rslc where t-rslc.lcnum <> "" and t-rslc.lcsum = 0 :
  v-ans = yes.
  put stream rep-err unformatted " Найдена лицензия с суммой = 0 : " t-rslc.lcnum skip.
end.

for each t-rslc where t-rslc.rsnum <> "" and t-rslc.rssum = 0 :
  v-ans = yes.
  put stream rep-err unformatted " Найдено рег.св-во с суммой = 0 : " t-rslc.rsnum skip.
end.


def temp-table t-docs
  field ln as integer
  field data20 as date
  field sum20 as deci
  field sumret20 as deci
  field data30 as date
  field sum30 as deci
  field sumret30 as deci
  index ln is primary unique ln.

def var s-vcdoctypes as char.
def var s-dnvid as char.

/* платежи */
s-dnvid = "p".
s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index(s-dnvid, codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

for each t-docs0. delete t-docs0. end.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, s-vcdoctypes) > 0
         and vcdocs.dndate < v-dt no-lock:
  create t-docs0.
  buffer-copy vcdocs to t-docs0.
end.

i = 0.
for each t-docs0:
  i = i + 1.
  create t-docs.
  t-docs.ln = i.

  find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.

  v-sum = vcdocs.sum / vcdocs.cursdoc-con.
  if v-crc <> vccontrs.ncrc then v-sum = v-sum / v-curscon.

  if vccontrs.expimp = "i" then do:
    t-docs.data20 = vcdocs.dndate.
    if vcdocs.payret then t-docs.sumret20 = v-sum.
                     else t-docs.sum20 = v-sum.
  end.
  else do:
    t-docs.data30 = vcdocs.dndate.
    if vcdocs.payret then t-docs.sumret30 = v-sum.
                     else t-docs.sum30 = v-sum.
  end.
end.


/* ГТД */
s-dnvid = "g".
s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index(s-dnvid, codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

for each t-docs0. delete t-docs0. end.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, s-vcdoctypes) > 0
         and vcdocs.dndate < v-dt no-lock:
  create t-docs0.
  buffer-copy vcdocs to t-docs0.
end.

for each t-docs0:
  find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.

  if vccontrs.expimp = "i" then
    find first t-docs where t-docs.data30 = ? no-error.
  else
    find first t-docs where t-docs.data20 = ? no-error.

  v-sum = vcdocs.sum / vcdocs.cursdoc-con.
  if v-crc <> vccontrs.ncrc then v-sum = v-sum / v-curscon.

  if not avail t-docs then do:
    find last t-docs no-lock no-error.
    if avail t-docs then i = t-docs.ln + 1.
                    else i = 1.
    create t-docs.
    t-docs.ln = i.
  end.

  if vccontrs.expimp = "i" then do:
    t-docs.data30 = vcdocs.dndate.
    if vcdocs.payret then t-docs.sumret30 = v-sum.
                     else t-docs.sum30 = v-sum.
  end.
  else do:
    t-docs.data20 = vcdocs.dndate.
    if vcdocs.payret then t-docs.sumret20 = v-sum.
                     else t-docs.sum20 = v-sum.
  end.
end.

for each t-docs:
  accumulate (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30) (total).
end.
v-failsum = accum total (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30).
if v-failsum = 0 then v-note = "Полное погашение задолженности".
                 else v-note = "".

if v-failsum < 0 then do:
  v-ans = yes.
  put stream rep-err unformatted " Клиент не является должником!" skip.
end.

def stream rep.
output stream rep to value(v-filename).

{html-title.i &stream = "stream rep" &title = " " &size-add = "xx-"}



put stream rep unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR style=""font:bold;font-size:x-small""><TD>Лицевая карточка банковского контроля по " if vccontrs.expimp = "e" then "экспорту" else "импорту".
put stream rep unformatted
  " N&nbsp;" vccontrs.cardnum skip
  "<BR>по состоянию на " v-strdt " года</TD><TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR style=""font:bold""><TD>Часть 1. Идентификационные сведения</TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR><TD><TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
    "<TR style=""font:bold"" align=""center"">" skip
      "<TD>Организационно-правовая форма</TD>" skip
      "<TD>Наименование</TD>" skip
      "<TD>Код ОКПО/РНН</TD>" skip
      "<TD>Код региона</TD>" skip
      "<TD>Юридический адрес</TD>" skip
      "<TD>N банковского счета</TD>" skip
      "<TD>Код таможенного органа</TD>" skip
    "</TR>" skip.

v-addr = trim(cif.addr[1]).
if trim(cif.addr[2]) <> "" then do:
  if v-addr <> "" then v-addr = v-addr + "; ".
  v-addr = v-addr + trim(cif.addr[2]).
end.

put stream rep unformatted
  "<TR style=""font-size:8pt"" align=""center"" valign=""top"">" skip
    "<TD>" cif.prefix "</TD>" skip
    "<TD>" cif.name "</TD>" skip
    "<TD>&nbsp;" v-kod "</TD>" skip
    "<TD>&nbsp;" v-region "</TD>" skip
    "<TD>&nbsp;" v-addr "</TD>" skip
    "<TD>&nbsp;" v-acc "</TD>" skip
    "<TD>" vccontrs.custom "</TD>" skip
  "</TR></TABLE></TD></TR>" skip.

put stream rep unformatted
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR style=""font:bold""><TD>Часть 2. Сведения о сделке по лицевой карточке</TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR style=""font:bold""><TD>2.1. Сведения о контракте</TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR><TD><TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
    "<TR style=""font-size:8pt; font:bold"" align=""center"">" skip
      "<TD colspan=""3"">Реквизиты паспорта сделки (ПС) /дополнительного листа</TD>" skip
      "<TD colspan=""7"">Условия контракта</TD>" skip
      "<TD colspan=""3"">Инопартнер</TD>" skip
      "<TD colspan=""3"">Третье лицо</TD>" skip
    "</TR>" skip
    "<TR style=""font-size:6pt; font:bold"" align=""center"">" skip
      "<TD>N ПС</TD>" skip
      "<TD>N дополнительного листа к ПС (ДЛ к ПС)</TD>" skip
      "<TD>Дата оформления ПС/ДЛ к ПС</TD>" skip
      "<TD>N контракта</TD>" skip
      "<TD>Дата заключения контракта</TD>" skip
      "<TD>Код валюты по контракту</TD>" skip
      "<TD>Сумма контракта</TD>" skip
      "<TD>Валюта платежа</TD>" skip
      "<TD>Последняя дата</TD>" skip
      "<TD>Прочие изменения в ДЛ к ПС</TD>" skip
      "<TD>Наименование</TD>" skip
      "<TD>Страна происхождения</TD>" skip
      "<TD>Наименование банка инопартнера</TD>" skip
      "<TD>Наименование</TD>" skip
      "<TD>Страна происхождения</TD>" skip
      "<TD>Наименование банка третьего лица</TD>" skip
    "</TR>" skip.


v-crc = vcps.ncrc.
v-sum = vcps.sum.
find ncrc where ncrc.crc = v-crc no-lock no-error.
v-val = ncrc.code.
if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
  v-sum = v-sum / decimal(entry(3, ncrc.prefix)).
  v-val = entry(1, ncrc.prefix).
end.


find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
if avail vcpartners then do:
  v-partnname = trim(trim(vcpartners.formasob) + " " + trim(vcpartners.name)).

  /* проверить наличие кода страны партнера */
  if trim(vcpartners.country) = "" then do:
    v-ans = yes.
    put stream rep-err unformatted " Не указана страна инопартнера" skip.
  end.

  /* проверить наличие банка партнера */
  if trim(vcpartners.bankdata) = "" then do:
    v-ans = yes.
    put stream rep-err unformatted " Не указан банк инопартнера" skip.
  end.
end.
else do:
  v-ans = yes.
  put stream rep-err unformatted " В контракте не указан ИНОПАРТНЕР" skip.
end.

v-valpl = "".
do i = 1 to num-entries(vccontrs.ctvalpl):
  find ncrc where ncrc.code = entry(i, vccontrs.ctvalpl) no-lock no-error.
  if v-valpl <> "" then v-valpl = v-valpl + ",".
  if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then v-valpl = v-valpl + entry(1, ncrc.prefix).
                                                         else v-valpl = v-valpl + entry(i, vccontrs.ctvalpl).

end.
if v-valpl <> vccontrs.ctvalpl then do:
  if v-addinfo <> "" then v-addinfo = v-addinfo + ". ".
  v-addinfo = v-addinfo + "Фактическая валюта платежа " + vccontrs.ctvalpl.
end.

if vcps.dnnote[5] <> "" then do:
  if v-addinfo <> "" then v-addinfo = v-addinfo + "; ".
  v-addinfo = v-addinfo + vcps.dnnote[5].
end.
if v-addinfo = "" then v-addinfo = "&nbsp;".

put stream rep unformatted
  "<TR style=""font-size:8pt"" valign=""top"">" skip
      "<TD>" vcps.dnnum "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD align=""center"">" string(vcps.dndate, "99/99/9999") "</TD>" skip
      "<TD>" vccontrs.ctnum "</TD>" skip
      "<TD align=""center"">" string(vccontrs.ctdate, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" v-val "</TD>" skip
      "<TD align=""right"">" replace(trim(string(v-sum, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
      "<TD align=""center"">" v-valpl "</TD>" skip
      "<TD align=""center"">" string(vcps.lastdate, "99/99/9999") "</TD>" skip
      "<TD>" v-addinfo "</TD>" skip
      "<TD align=""center"">" v-partnname "</TD>" skip
      "<TD align=""center"">" if avail vcpartners then vcpartners.country else "&nbsp;" "</TD>" skip
      "<TD>" if avail vcpartners then vcpartners.bankdata else "&nbsp;" "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
  "</TR>" skip.

def buffer b-vcps for vcps.

for each vcps where vcps.contract = vccontrs.contract and vcps.dntype = "19" and vcps.dndate < v-dt no-lock break by vcps.dndate by vcps.dnnum:
  i = index(vcps.dnnum, "N").
  if i > 0 then do:
    v-psnum = left-trim(substr(vcps.dnnum, i + 1)).
    i = index(vcps.dnnum, " ").
    if i <> 0 then v-psnum = substr(v-psnum, 1, i - 1).
  end.
  else do:
    i = 0.
    for each b-vcps where b-vcps.contract = vcps.contract and b-vcps.dntype = "19" and
             (b-vcps.dndate < vcps.dndate or (b-vcps.dndate = vcps.dndate and b-vcps.ps < vcps.ps)) no-lock:
      accumulate b-vcps.ps (count).
    end.
    i = accum count b-vcps.ps.
    i = i + 1.
    v-psnum = string(i).
    hide message no-pause.
    message " Неверный формат номера доплиста " vccontrs.cif vccontrs.ctdate vccontrs.ctnum vcps.dnnum.
    message " В лицевой карточке будет указан номер по порядку " i.
    pause.
  end.

  /* проверка суммы на 1 - не исправленная сумма */
  if vcps.sum = 1 then do:
    v-ans = yes.
    put stream rep-err unformatted " В ДЛ номер " vcps.dnnum " не исправлена сумма после импорта в ПРАГМУ" skip.
  end.

  v-sum = vcps.sum.
  find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
  v-val = ncrc.code.
  if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
    v-sum = v-sum / decimal(entry(3, ncrc.prefix)).
    v-val = entry(1, ncrc.prefix).
  end.

  put stream rep unformatted
    "<TR style=""font-size:8pt"" valign=""top"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>" v-psnum "</TD>" skip
        "<TD align=""center"">" string(vcps.dndate, "99/99/9999") "</TD>" skip
        "<TD>" vccontrs.ctnum "</TD>" skip
        "<TD align=""center"">" string(vccontrs.ctdate, "99/99/9999") "</TD>" skip
        "<TD align=""center"">" v-val "</TD>" skip
        "<TD align=""right"">" replace(trim(string(v-sum, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""center"">" vccontrs.ctvalpl "</TD>" skip
        "<TD align=""center"">" string(vcps.lastdate, "99/99/9999") "</TD>" skip
        "<TD>" if vcps.dnnote[5] = "" then "&nbsp;" else vcps.dnnote[5] "</TD>" skip
        "<TD align=""center"">" v-partnname "</TD>" skip
        "<TD align=""center"">" vcpartners.country "</TD>" skip
        "<TD>" vcpartners.bankdata "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
    "</TR>" skip.
end.

put stream rep unformatted
  "</TABLE></TD></TR>" skip.

/* лицензии и рег.св-ва */

put stream rep unformatted
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR style=""font:bold""><TD>2.2. Сведения о разрешениях на осуществление операций, связанных с движением капитала</TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR><TD><TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
    "<TR style=""font-size:8pt; font:bold"" align=""center"">" skip
      "<TD colspan=""4"">Лицензия НБ РК</TD>" skip
      "<TD colspan=""2"">Регистрационное свидетельство</TD>" skip
    "</TR>" skip
    "<TR style=""font-size:6pt; font:bold"" align=""center"">" skip
      "<TD>N лицензии</TD>" skip
      "<TD>Дата выдачи</TD>" skip
      "<TD>Сумма лицензии</TD>" skip
      "<TD>Предельный срок исполнения</TD>" skip
      "<TD>N свидетельства</TD>" skip
      "<TD>Сумма свидетельства</TD>" skip
    "</TR>" skip.

find first t-rslc no-error.
if avail t-rslc then
  for each t-rslc :
    put stream rep unformatted
      "<TR style=""font-size:8pt"" valign=""top"">" skip
          "<TD>" t-rslc.lcnum "</TD>" skip
          "<TD align=""center"">" if t-rslc.lcnum = "" then "&nbsp;" else string(t-rslc.lcdate, "99/99/9999") "</TD>" skip
          "<TD align=""right"">" if t-rslc.lcnum = "" then "&nbsp;" else replace(trim(string(t-rslc.lcsum, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
          "<TD align=""center"">" if t-rslc.lcnum = "" then "&nbsp;" else string(t-rslc.lclast, "99/99/9999") "</TD>" skip
          "<TD>" t-rslc.rsnum "</TD>" skip
          "<TD align=""right"">" if t-rslc.rsnum = "" then "&nbsp;" else replace(trim(string(t-rslc.rssum, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
      "</TR>" skip.
  end.
else
  put stream rep unformatted
    "<TR>" skip
        "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>" skip
    "</TR>" skip.


put stream rep unformatted
  "</TABLE></TD></TR>" skip.


/* платежные документы и ГТД */

put stream rep unformatted
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR style=""font:bold""><TD>Часть 3. Сведения о проведенных операциях по лицевой карточке</TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR><TD><TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
    "<TR style=""font-size:8pt; font:bold"" align=""center"">" skip.

if vccontrs.expimp = "i" then
  put stream rep unformatted
      "<TD colspan=""3"">Платежи</TD>" skip
      "<TD colspan=""3"">Поставка товара</TD>" skip
      "<TD rowspan=""2"">Сумма непоступившего в установленные сроки товара</TD>" skip
      "<TD rowspan=""2"">Примечание</TD>" skip
    "</TR>" skip
    "<TR style=""font-size:6pt; font:bold"" align=""center"">" skip
      "<TD>Дата платежа</TD>" skip
      "<TD>Сумма произведенного платежа</TD>" skip
      "<TD>Сумма возвращенного авансового платежа</TD>" skip
      "<TD>Дата поступления/ возврата товара</TD>" skip
      "<TD>Стоимость поступившего товара</TD>" skip
      "<TD>Стоимость возвращенного товара</TD>" skip
    "</TR>" skip.
else
  put stream rep unformatted
      "<TD colspan=""3"">Поставка товара</TD>" skip
      "<TD colspan=""3"">Платежи</TD>" skip
      "<TD rowspan=""2"">Сумма непоступившей в установленные сроки экспортной выручки</TD>" skip
      "<TD rowspan=""2"">Примечание</TD>" skip
    "</TR>" skip
    "<TR style=""font-size:6pt; font:bold"" align=""center"">" skip
      "<TD>Дата отправки/ возврата товара</TD>" skip
      "<TD>Стоимость отправленного товара</TD>" skip
      "<TD>Стоимость возвращенного товара</TD>" skip
      "<TD>Дата платежа</TD>" skip
      "<TD>Сумма поступившей экспортной выручки</TD>" skip
      "<TD>Сумма возвращенного авансового платежа</TD>" skip
    "</TR>" skip.


for each t-docs :
  put stream rep unformatted
    "<TR style=""font-size:8pt"" valign=""top"">" skip
        "<TD align=""center"">" if t-docs.data20 = ? then "&nbsp;" else string(t-docs.data20, "99/99/9999") "</TD>" skip
        "<TD align=""right"">" if t-docs.data20 = ? or t-docs.sum20 = 0 then "&nbsp;" else replace(trim(string(t-docs.sum20, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""right"">" if t-docs.data20 = ? or t-docs.sumret20 = 0 then "&nbsp;" else replace(trim(string(t-docs.sumret20, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""center"">" if t-docs.data30 = ? then "&nbsp;" else string(t-docs.data30, "99/99/9999") "</TD>" skip
        "<TD align=""right"">" if t-docs.data30 = ? or t-docs.sum30 = 0 then "&nbsp;" else replace(trim(string(t-docs.sum30, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""right"">" if t-docs.data30 = ? or t-docs.sumret30 = 0 then "&nbsp;" else replace(trim(string(t-docs.sumret30, ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip.

  if t-docs.ln = 1 then
    put stream rep unformatted
      "<TD align=""right"">" replace(trim(string(v-failsum, "->>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
      "<TD>" v-note "</TD>" skip.
  else
    put stream rep unformatted
      "<TD>&nbsp;</TD><TD>&nbsp;</TD>" skip.

  put stream rep unformatted
    "</TR>" skip.
end.

put stream rep unformatted
  "</TD></TR></TABLE>" skip.

/* нужно выдавать дату закрытия ПС! */

put stream rep unformatted
  "<TR><TD>&nbsp;</TD></TR>" skip
  "<TR><TD><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""2"">" skip
  "<TR style=""font:bold""><TD width=""20"">Часть&nbsp;4.&nbsp;Дата&nbsp;закрытия&nbsp;паспорта&nbsp;сделки&nbsp;по&nbsp;" if vccontrs.expimp = "e" then "экспорту" else "импорту"
  "</TD><TD align=""left"">&nbsp;&nbsp;<U>"
   if vccontrs.sts = "c" then string(vccontrs.stsdt, "99/99/9999") else "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
  "</U>&nbsp;г.</TD></TR></TABLE></TD></TR>" skip
  "<TR><TD>&nbsp;</TD></TR>" skip.



/* подписи */

def var v-kurname as char.
def var v-kurpos as char.
def var v-depname as char.
def var v-deppos as char.

find sysc where sysc.sysc = "vc-kur" no-lock no-error.
if avail sysc then do:
  v-kurname = entry(1, trim(sysc.chval)).
  v-kurpos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений о кураторе Департамента валютного контроля!". pause 3.
  v-kurpos = "".
  v-kurname = "".
end.

/*
find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then do:
  v-depname = entry(1, trim(sysc.chval)).
  v-deppos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений об ответственном лице валютного контроля!". pause 3.
  v-deppos = "".
  v-depname = "".
end.*/

/*  find cif where cif.cif = s-cif no-lock no-error.*/
  v-dep = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep no-lock no-error .
  if avail codfr and codfr.name[1] <> "" then do:
     v-depname = entry(1, trim(codfr.name[1])).
  if num-entries(codfr.name[1]) > 1 then
     v-deppos = entry(2, trim(codfr.name[1])).
    else
      v-deppos = "".
  end.
  else do:
   message " Нет сведений об ответственном лице валютного контроля!". pause 3 no-message.
   v-deppos = "".
   v-depname = "".
  end.


find first cmp no-lock no-error.

put stream rep unformatted
  "<TR><TD>" skip
  "<B>"
     v-kurpos  " _________________________ "
     v-kurname  "<BR><BR>" skip
     v-deppos  " _________________________ "
     v-depname  "<BR><BR>" skip
     cmp.name skip.

{get-dep.i}
i = get-dep(g-ofc, g-today).
find ppoint where ppoint.depart = i no-lock no-error.
v-depname = ppoint.name.
put stream rep unformatted "<BR>" v-depname.

put stream rep unformatted
  "</B></TD></TR></TABLE>" skip.

{html-end.i "stream rep"}

output stream rep close.
output stream rep-err close.

unix silent cptwin value(v-filename) iexplore.

if v-ans then do:
  message skip " При формировании сообщения были обнаружены ошибки !"
          skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
  run menu-prt (v-fileerr).
end.

