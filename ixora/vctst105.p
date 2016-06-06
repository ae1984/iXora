/* vcmsg105.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Формирование сообщения 105 - лицевой карточки валютного контроля
 * RUN
        из главного меню - карточки формируются по одной
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.5.3
 * AUTHOR
        14.05.2003 nadejda
 * CHANGES
        13.08.2003 nadejda - добавлено формирование карточки для повторной отправки
        15.08.2003 nadejda - добавила ограничение по дате отчета для поиска документов
                             проверка на отрицательную сумму задолженности - не должник, формировать сообщение не будем
        05.07.2004 saltanat    - добав. new shared для s-contrstat
*/


{mainhead.i}
{vc.i}

def new shared var s-cif like cif.cif.
def new shared var s-contract like vccontrs.contract.
def var v-cifname as char.
def var v-ans as logical init no.
def var v-dt as date.
def var v-dtb as date.
def var v-dte as date.
def var v-dtrep as date.
def var v-strdt as char.
def var v-str as char.
def var v-kod as char.
def var v-clnsts as char.
def var v-psnum as char.
def var v-partnname as char.
def var i as integer.
def var v-cardnum as char.
def var v-acc as char.
def var v-contrnum as char.
def var v-month as integer.
def var v-god as integer.
def var v-sum as deci.
def var v-addr as char.
def stream rep-err.
def var v-fileerr as char init "reperr.txt".
def var v-newmsg as logical init yes.
def var v-crc as integer.
def var v-curscon as deci.
def var v-addinfo as char.
def var v-val as char.
def var v-valpl as char.
def var v-region as char init "".

def var v-datastrkz as char no-undo.
def var v-crcps as integer.
def var v-valps as char.
def var v-sumps as deci.
def new shared var s-contrstat as char initial 'all'.

def buffer b-vccontrs for vccontrs.


s-cif = "".
v-cifname = "".

{vc-defdt.i}


def frame f-client 
  v-month label "МЕСЯЦ " format ">9" colon 10 skip 
  v-god label   "ГОД " format "9999" colon 10 skip(1) 
  s-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = s-cif no-lock), " Клиент с таким кодом не найден!")
  v-cifname no-label format "x(45)" colon 18
  v-contrnum label "КОНТРАКТ" format "x(50)" colon 10 help " Выберите контракт (F2 - поиск)"
    validate(can-find(first vccontrs where vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999") begins v-contrnum no-lock), " Контракт не найден!")
  with side-label row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

on help of v-contrnum in frame f-client do:
  run h-contract.
  if s-contract <> 0 then do:
    find vccontrs where vccontrs.contract = s-contract no-lock no-error.
    v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
    displ v-contrnum with frame f-client.
  end.
end.

update v-month v-god s-cif with frame f-client.

find first cif where cif.cif = s-cif no-lock no-error.
v-cifname = trim((cif.prefix) + " " + trim(cif.name)).

displ v-cifname with frame f-client.

update v-contrnum with frame f-client.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
if not avail vccontrs then return.

if vccontrs.cttype <> "1" then do:
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



message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).

v-dtrep = v-dte + 1.

/* проверить неактуальные валюты */
v-crc = vccontrs.ncrc.
find ncrc where ncrc.crc = v-crc no-lock no-error.
v-val = ncrc.code.
if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
  v-curscon = decimal(entry(3, ncrc.prefix)).
  v-addinfo = "Фактическая валюта контракта " + ncrc.code.
  v-val = entry(1, ncrc.prefix).

  find ncrc where ncrc.code = v-val no-lock no-error.
  v-crc = ncrc.crc.
end.


/*
/ * проверка на повторную отправку * /
v-newmsg = not vccontrs.cardsend or (vccontrs.cardsend and vccontrs.cardfirstdt = v-dtrep).
*/

/* при тестировании запросим вид сообщения */
message skip " Сформировать лицевую карточку для ПЕРВИЧНОЙ отправки ?" skip
  skip (1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-newmsg.


if v-newmsg then do:
  v-dtb = vccontrs.ctdate.
end.
else do:
  v-dtb = vccontrs.cardsenddt.

  message skip " Выполняется формирование лицевой карточки для ПОВТОРНОЙ отправки" skip
    " за период с" string (v-dtb, "99/99/9999") "по" string (v-dte, "99/99/9999")
    skip (2) view-as alert-box button ok title " ВНИМАНИЕ ! ".
end.



/* собрать платежи и определить сумму задолженности  */

def temp-table t-docs0
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  index main is primary dndate dnnum docs.


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
         and vcdocs.dndate <= v-dte no-lock:
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
         and vcdocs.dndate <= v-dte no-lock:
  create t-docs0.
  buffer-copy vcdocs to t-docs0.
end.

for each t-docs0:
  find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.

  if vccontrs.expimp = "i" then
    find first t-docs where t-docs.data30 = ? no-error.
  else
    find first t-docs where t-docs.data20 = ? no-error.

  if not avail t-docs then do:
    find last t-docs no-lock no-error.
    if avail t-docs then i = t-docs.ln + 1.
                    else i = 1.
    create t-docs.
    t-docs.ln = i.
  end.

  v-sum = vcdocs.sum / vcdocs.cursdoc-con.
  if v-crc <> vccontrs.ncrc then v-sum = v-sum / v-curscon.
  
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


def var v-failsum as deci.
def var v-note as char.

for each t-docs:
  accumulate (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30) (total).
end.
v-failsum = accum total (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30).
if v-failsum = 0 then v-note = "Полное погашение задолженности".
                 else v-note = "".


if v-failsum < 0 then do:
  message skip " Клиент не является должником !" 
          skip(1) " Сообщение для отправки лицевой карточки не сформировано !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  
  return.
end.



find cif where cif.cif = vccontrs.cif no-lock no-error.
find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek" and sub-cod.acc = cif.cif no-lock no-error.
if sub-cod.ccode = "9" then do:
  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" and sub-cod.acc = cif.cif no-lock no-error.
  if sub-cod.ccode = "98" then do: v-kod = cif.jss. v-clnsts = "2". end.
                          else do: v-kod = cif.ssn. v-clnsts = "1". end.
end.
else do:
  v-kod = cif.ssn.
  v-clnsts = "1".
end.

if length(v-kod) < 12 then v-kod = v-kod + fill("0", 12 - length(v-kod)).

find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "regionkz" and sub-cod.acc = cif.cif no-lock no-error.
if avail sub-cod and sub-cod.ccode <> "msc" then v-region = sub-cod.ccode.


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
put stream rep-err unformatted skip(1) " ОШИБКИ, ОБНАРУЖЕННЫЕ ПРИ ФОРМИРОВАНИИ ЛИЦЕВОЙ КАРТОЧКИ" skip(1).


/* проверить наличие ОКПО/РНН клиента */
if v-newmsg and v-kod = fill("0", 12) then do:
  v-ans = yes.
  put stream rep-err unformatted " Отсутствует код ОКПО/РНН" skip.
end.


/* проверить наличие кода региона у клиента */
if v-newmsg and v-region = "" then do:
  v-ans = yes.
  put stream rep-err unformatted " Не указан код региона" skip.
end.


v-dt = date(month(g-today), 1, year(g-today)).
run pkdefdtstr(v-dt, output v-strdt, output v-datastrkz).

if vccontrs.cardnum = "" or vccontrs.ctregnom = 0 then do:
  def frame f-cardnum
      vccontrs.ctregnom    label " Номер контракта по журналу " 
           help " Номер контракта по журналу регистрации" 
           validate (vccontrs.ctregnom = 0 or 
                     not can-find(first b-vccontrs where b-vccontrs.ctregnom = vccontrs.ctregnom and 
                           b-vccontrs.contract <> vccontrs.contract no-lock), 
                     " Этот номер принадлежит другому контракту!") skip
      v-str format "x(12)" label "     Номер лицевой карточки " 
           help " Уточните уникальную часть номера лицевой карточки"
           validate (length(v-str) >=3 and length(v-str) <= 12, " Номер должен быть не меньше 3 и не больше 12 символов!")
      with centered overlay side-label row 8 title " УНИКАЛЬНАЯ ЧАСТЬ НОМЕРА КАРТОЧКИ ".



  if vccontrs.ctregnom = 0 then do:
    find current vccontrs exclusive-lock.
    update vccontrs.ctregnom with frame f-cardnum.
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
    update v-str with frame f-cardnum.

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
  vccontrs.cardnum = v-cardnum.
  find current vccontrs no-lock.

  hide frame f-cardnum.
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


for each t-docs0. delete t-docs0. end.
for each vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "22" no-lock:

  if vcrslc.dndate < v-dtb or vcrslc.dndate > v-dte then next.

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

  if v-crc <> vccontrs.ncrc then t-rslc.lcsum = t-rslc.lcsum / v-curscon.
end.

for each t-docs0. delete t-docs0. end.
for each vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock:
  
  if vcrslc.dndate < v-dtb or vcrslc.dndate > v-dte then next.

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

  if v-crc <> vccontrs.ncrc then t-rslc.rssum = t-rslc.rssum / v-curscon.
end.

if can-find (first t-rslc where t-rslc.lcnum <> "" and t-rslc.lcsum = 0) or 
   can-find (first t-rslc where t-rslc.rsnum <> "" and t-rslc.rssum = 0) then do:
  message skip " Найден документ (рег.св-во или лицензия) с суммой = 0 !" skip(1)
          " Проверьте суммы !" skip(1)
          view-as alert-box button ok title " ВНИМАНИЕ ! ".
end.



{vctstparam.i &msg = "105"}

v-text = "/REPORTDATE/" + replace(string(v-dtrep, "99/99/9999"), "/", "").
put stream rpt unformatted v-text skip.

v-text = "/CARDNUMBER/" + vccontrs.cardnum.
put stream rpt unformatted v-text skip.

v-text = "/PART1/".
put stream rpt unformatted v-text skip.

v-text = "/OKPO/" + if v-newmsg then v-kod else "".
put stream rpt unformatted v-text skip.
    
v-text = "//FORM/" + if v-newmsg then substr(cif.prefix, 1, 10) else "".
put stream rpt unformatted v-text skip.

v-text = "//NAME/" + if v-newmsg then substr(cif.name, 1, 100) else "".
put stream rpt unformatted v-text skip.

/* NEW */
v-text = "//REGIONCODE/" + if v-newmsg then v-region else "".
put stream rpt unformatted v-text skip.
    


v-addr = trim(cif.addr[1]).
if trim(cif.addr[2]) <> "" then do:
  if v-addr <> "" then v-addr = v-addr + "; ".
  v-addr = v-addr + trim(cif.addr[2]).
end.

v-text = "//ADDRESS/" + if v-newmsg then substr(v-addr, 1, 100) else "".
put stream rpt unformatted v-text skip.

v-text = "//ACCOUNT/" + if v-newmsg then v-acc else "".
put stream rpt unformatted v-text skip.

v-text = "//CUSTOMCODE/" + if v-newmsg then trim(vccontrs.custom) else "".
put stream rpt unformatted v-text skip.

/* проверить наличие кода таможенного органа клиента */
if v-newmsg and trim(vccontrs.custom)  = "" then do:
  v-ans = yes.
  put stream rep-err unformatted " Отсутствует код таможенного органа" skip.
end.


if vccontrs.expimp = "e" then v-text = "1". 
                         else v-text = "2".
v-text = v-text + v-clnsts.

v-text = "//SIGN/" + if v-newmsg then v-text else "".
put stream rpt unformatted v-text skip.


v-text = "/PART21/".
put stream rpt unformatted v-text skip.

/* проверка формата номера ПС */
if v-newmsg and length(vcps.dnnum) < 19 then do:
  v-ans = yes.
  put stream rep-err unformatted " Короткий номер ПС" skip.
end.

if v-newmsg and length(vcps.dnnum) > 30 then do:
  v-ans = yes.
  put stream rep-err unformatted " Длинный номер ПС" skip.
end. 

if v-newmsg and (not vcps.dnnum matches "../......../.../0\.*" or (substr(vcps.dnnum, 17, 2) <> "0.")) then do:
  v-ans = yes.
  put stream rep-err unformatted " Неверный формат номера ПС" skip.
end.


find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.

def var v-thirdname as char.
def var v-thirdcntry as char.
def var v-thirdbank as char.
def var v-partncntry as char.
def var v-partnbank as char.

find vcpartners where vcpartners.partner = vccontrs.third no-lock no-error.
if avail vcpartners then do:
  v-thirdname = trim(trim(vcpartners.formasob) + " " + trim(vcpartners.name)).
  v-thirdcntry = vcpartners.country.
  v-thirdbank = trim(vcpartners.bankdata).
end.


find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
if avail vcpartners then do:
  v-partnname = trim(trim(vcpartners.formasob) + " " + trim(vcpartners.name)).
  v-partncntry = vcpartners.country.
  v-partnbank = trim(vcpartners.bankdata).

  /* проверить наличие кода страны партнера */
  if v-newmsg and v-partncntry = "" then do:
    v-ans = yes.
    put stream rep-err unformatted " Не указана страна инопартнера" skip.
  end.

  /* проверить наличие банка партнера */
  if v-newmsg and v-partnbank = "" then do:
    v-ans = yes.
    put stream rep-err unformatted " Не указан банк инопартнера" skip.
  end.

end.
else do:
  if v-newmsg then do:
    v-ans = yes.
    put stream rep-err unformatted " В контракте не указан ИНОПАРТНЕР" skip.
  end.
end.

def buffer b-vcps for vcps.

find first vcps where vcps.contract = vccontrs.contract and vcps.dndate >= v-dtb and vcps.dndate <= v-dte no-lock no-error.
if avail vcps then do:

  for each vcps where vcps.contract = vccontrs.contract and vcps.dndate >= v-dtb and vcps.dndate <= v-dte no-lock break by vcps.dntype by vcps.dndate by vcps.dnnum:
    
    v-text = "/PS/" + if vcps.dntype = "01" then vcps.dnnum else "".
    put stream rpt unformatted v-text skip.

    if vcps.dntype = "01" then v-psnum = "".
    else do:
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
    end.

    v-text = "//ADDSHEET/" + v-psnum.
    put stream rpt unformatted v-text skip.

    v-text = "//PSDATE/" + replace(string(vcps.dndate, "99/99/9999"), "/", "").
    put stream rpt unformatted v-text skip.

    v-text = "/CONTRACT/" + if vcps.dntype = "01" then vccontrs.ctnum else "".
    put stream rpt unformatted v-text skip.

    v-text = "//CDATE/" + if vcps.dntype = "01" then replace(string(vccontrs.ctdate, "99/99/9999"), "/", "") else "".
    put stream rpt unformatted v-text skip.


    v-crcps = vcps.ncrc.
    v-sumps = vcps.sum.
    find ncrc where ncrc.crc = v-crcps no-lock no-error.
    v-valps = ncrc.code.
    if ncrc.prefix <> "" and num-entries(ncrc.prefix) >= 3 then do:
      v-sumps = v-sumps / decimal(entry(3, ncrc.prefix)).
      v-valps = entry(1, ncrc.prefix).
    end.
    
    v-text = "//CSUMM/" + v-valps + trim(replace(string(v-sumps, ">>>>>>>>9.99"), ".", ",")).
    put stream rpt unformatted v-text skip.

    /* проверка суммы на 1 - не исправленная сумма */
    if v-newmsg and vcps.sum = 1 then do:
      v-ans = yes.
      put stream rep-err unformatted " В ПС/ДЛ номер " vcps.dnnum " не исправлена сумма после импорта в ПРАГМУ" skip.
    end. 


    if vcps.dntype = "01" then do:
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

      v-text = "//CURRCLAUSE/" + caps(replace(v-valpl, ",", "/")).
      put stream rpt unformatted v-text skip.
    end.
    else do:
      v-text = "//CURRCLAUSE/".
      put stream rpt unformatted v-text skip.
    end.

    v-text = "//CLASTDATE/" + replace(string(vcps.lastdate, "99/99/9999"), "/", "").
    put stream rpt unformatted v-text skip.

    v-text = "/FPARTNER/" + if vcps.dntype = "01" then v-partnname else "".
    put stream rpt unformatted v-text skip.

    v-text = "//FPCOUNTRY/" + if vcps.dntype = "01" then v-partncntry else "".
    put stream rpt unformatted v-text skip.

    v-text = "//FPBANKNAME/" + if vcps.dntype = "01" then substr(v-partnbank, 1, 100) else "".
    put stream rpt unformatted v-text skip.

    v-text = "/TPERSON/" + if vcps.dntype = "01" then v-thirdname else "".
    put stream rpt unformatted v-text skip.
    v-text = "//TPCOUNTRY/" + if vcps.dntype = "01" then v-thirdcntry else "".
    put stream rpt unformatted v-text skip.
    v-text = "//TPBANKNAME/" + if vcps.dntype = "01" then v-thirdbank else "".
    put stream rpt unformatted v-text skip.


    if vcps.dntype = "01" then do:
      if v-addinfo <> "" then v-addinfo = v-addinfo + ". ".
      v-addinfo = v-addinfo + vcps.dnnote[5].
    end.
    else
      v-addinfo = vcps.dnnote[5].

    v-text = "//OTHERS/" + substr(v-addinfo, 1, 100).
    put stream rpt unformatted v-text skip.

    v-text = substr(v-addinfo, 101, 100).
    if v-text <> "" then put stream rpt unformatted v-text skip.
    v-text = substr(v-addinfo, 201, 100).
    if v-text <> "" then put stream rpt unformatted v-text skip.
  end.
end.
else do:
  v-text = "/PS/".
  put stream rpt unformatted v-text skip.

  v-text = "//ADDSHEET/".
  put stream rpt unformatted v-text skip.

  v-text = "//PSDATE/".
  put stream rpt unformatted v-text skip.

  v-text = "/CONTRACT/".
  put stream rpt unformatted v-text skip.

  v-text = "//CDATE/".
  put stream rpt unformatted v-text skip.

  v-text = "//CSUMM/".
  put stream rpt unformatted v-text skip.



  v-text = "//CURRCLAUSE/".
  put stream rpt unformatted v-text skip.

  v-text = "//CLASTDATE/".
  put stream rpt unformatted v-text skip.

  v-text = "/FPARTNER/".
  put stream rpt unformatted v-text skip.

  v-text = "//FPCOUNTRY/".
  put stream rpt unformatted v-text skip.

  v-text = "//FPBANKNAME/".
  put stream rpt unformatted v-text skip.

  v-text = "/TPERSON/".
  put stream rpt unformatted v-text skip.
  v-text = "//TPCOUNTRY/".
  put stream rpt unformatted v-text skip.
  v-text = "//TPBANKNAME/".
  put stream rpt unformatted v-text skip.


  v-text = "//OTHERS/".
  put stream rpt unformatted v-text skip.
end.

v-text = "/PART22/".
put stream rpt unformatted v-text skip.

find first t-rslc where t-rslc.lcnum <> "" no-error.
if avail t-rslc then 

  for each t-rslc where t-rslc.lcnum <> "":
    v-text = "/LICENCE/" + substr(t-rslc.lcnum, 1, 12).
    put stream rpt unformatted v-text skip.

    v-text = "//LDATE/" + replace(string(t-rslc.lcdate, "99/99/9999"), "/", "").
    put stream rpt unformatted v-text skip.

    v-text = "//LSUMM/" + v-val + trim(replace(string(t-rslc.lcsum, ">>>>>>>>9.99"), ".", ",")).
    put stream rpt unformatted v-text skip.

    v-text = "//LTIMELIMIT/" + replace(string(t-rslc.lclast, "99/99/9999"), "/", "").
    put stream rpt unformatted v-text skip.
  end.

else do:
  v-text = "/LICENCE/".
  put stream rpt unformatted v-text skip.

  v-text = "//LDATE/".
  put stream rpt unformatted v-text skip.

  v-text = "//LSUMM/".
  put stream rpt unformatted v-text skip.

  v-text = "//LTIMELIMIT/".
  put stream rpt unformatted v-text skip.
end.


find first t-rslc where t-rslc.rsnum <> "" no-error.
if avail t-rslc then 

  for each t-rslc where t-rslc.rsnum <> "":
    v-text = "/REGCERT/" + substr(t-rslc.rsnum, 1, 20).
    put stream rpt unformatted v-text skip.

    v-text = "//RCSUMM/" + v-val + trim(replace(string(t-rslc.rssum, ">>>>>>>>9.99"), ".", ",")).
    put stream rpt unformatted v-text skip.
  end.

else do:
  v-text = "/REGCERT/".
  put stream rpt unformatted v-text skip.

  v-text = "//RCSUMM/".
  put stream rpt unformatted v-text skip.
end.


v-text = "/PART3/".
put stream rpt unformatted v-text skip.


v-text = "/10FAILSUMM/" + trim(replace(string(v-failsum, ">>>>>>>>9.99"), ".", ",")).
put stream rpt unformatted v-text skip.

v-text = "//NOTE/" + v-note.
put stream rpt unformatted v-text skip.


find first t-docs where t-docs.data20 <> ? no-error.
if not avail t-docs then do:
  v-text = "/20DATE/".
  put stream rpt unformatted v-text skip.

  v-text = "//COST01/0,00".
  put stream rpt unformatted v-text skip.

  v-text = "//COST02/0,00".
  put stream rpt unformatted v-text skip.
end.

for each t-docs where t-docs.data20 <> ?:
  v-text = "/20DATE/" + replace(string(t-docs.data20, "99/99/9999"), "/", "").
  put stream rpt unformatted v-text skip.

  v-text = "//COST01/" + trim(replace(string(t-docs.sum20, ">>>>>>>>9.99"), ".", ",")).
  put stream rpt unformatted v-text skip.

  v-text = "//COST02/" + trim(replace(string(t-docs.sumret20, ">>>>>>>>9.99"), ".", ",")).
  put stream rpt unformatted v-text skip.
end.


find first t-docs where t-docs.data30 <> ? no-error.
if not avail t-docs then do:
  v-text = "/30DATE/".
  put stream rpt unformatted v-text skip.

  v-text = "//SUMM01/0,00".
  put stream rpt unformatted v-text skip.

  v-text = "//SUMM02/0,00".
  put stream rpt unformatted v-text skip.
end.

for each t-docs where t-docs.data30 <> ?:
  v-text = "/30DATE/" + replace(string(t-docs.data30, "99/99/9999"), "/", "").
  put stream rpt unformatted v-text skip.

  v-text = "//SUMM01/" + trim(replace(string(t-docs.sum30, ">>>>>>>>9.99"), ".", ",")).
  put stream rpt unformatted v-text skip.

  v-text = "//SUMM02/" + trim(replace(string(t-docs.sumret30, ">>>>>>>>9.99"), ".", ",")).
  put stream rpt unformatted v-text skip.
end.


v-text = "/PART4/".
put stream rpt unformatted v-text skip.

/* для закрытых контрактов выдавать vccontrs.ctclosedt, но пока можно vccontrs.stsdt */
v-text = "/PSCLOSEDATE/" + if vccontrs.sts begins "C" then replace(string(vccontrs.stsdt, "99/99/9999"), "/", "") else "".
put stream rpt unformatted v-text skip.

{vctstend.i &msg = "105"}

output stream rep-err close.

/* при тестировании ничего не записываем!
/ * записать сведения об отправке карточки * /
find current vccontrs exclusive-lock.

/ * если первичная отправка * /
if not vccontrs.cardsend then do:
  vccontrs.cardsend = yes.
  vccontrs.cardfirstdt = v-dtrep.
  vccontrs.cardfirstmsg = v-filename.
  vccontrs.cardsenddt = v-dtrep.
  vccontrs.cardlastdt = v-dtrep.
end.
else do:
  if vccontrs.cardlastdt <> v-dtrep then do:
    vccontrs.cardsenddt = vccontrs.cardlastdt.
    vccontrs.cardlastdt = v-dtrep.
  end.
end.

vccontrs.cardlastmsg = v-filename.

find current vccontrs no-lock.
*/

if v-ans then do:
  message " При формировании сообщения были обнаружены ошибки данных!". pause 3.
  run menu-prt (v-fileerr).
end.



