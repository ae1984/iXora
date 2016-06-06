/* vcdngtd.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/* vcdngtd.f Валютный контроль
   Форма для ГТД

   18.10.2002 nadejda создан
*/

def var v-dntypename as char.
def buffer b-vcdocs for vcdocs.
def var v-sumdoccon as decimal.
def var v-crckod as char.
def var msg-err as char.

{vc-crosscurs.i}

function chk-kod14 returns logical (p-str as char).
  def var l as logical.
  def var i as integer.
  l = true.
  if p-str <> "" then do:
    i = integer(p-str) no-error.
    if error-status:error then l = false.
  end.
  return l.
end.

function chk-dntype returns logical (p-str as char).
  return p-str <> "" and p-str <> "msc" and
      can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = p-str and 
      lookup(p-str, s-vcdoctypes) > 0 no-lock).
end.

function chk-dnnum returns logical (p-str as char).
  if p-str = "" then do:
    msg-err = "Введите номер документа!".
    return false.
  end.
  if can-find(b-vcdocs where b-vcdocs.contract = s-contract and 
         b-vcdocs.dntype = vcdocs.dntype and b-vcdocs.dnnum = p-str and 
         b-vcdocs.dndate = vcdocs.dndate and b-vcdocs.docs <> vcdocs.docs no-lock) then do:
    msg-err = "Уже есть документ с таким номером и датой по данному контракту!".
    return false. 
  end.
  return true.
end.

function chk-dndate returns logical(p-value as date).
 if p-value = ? then do: 
   msg-err = "Введите дату документа!". return false. end.
 if p-value < vccontrs.ctdate then do:
   msg-err = "Дата документа не может быть меньше даты контракта!". return false. end.
 if p-value > vccontrs.lastdate then do:
   msg-err = "Дата документа не может быть больше последней даты контракта!". return false. end.
 if can-find(b-vcdocs where b-vcdocs.contract = s-contract and 
         b-vcdocs.dntype = vcdocs.dntype and b-vcdocs.dnnum = vcdocs.dnnum and 
         b-vcdocs.dndate = p-value and b-vcdocs.docs <> vcdocs.docs no-lock) then do:
    msg-err = "Уже есть документ с таким номером и датой по данному контракту!". return false. end.
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
  if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-value then do:
    msg-err = "Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) + 
       " - заменена " + entry(1, ncrc.prefix) + " !".
    return false.
  end.

  return true.
end.

function summplat returns decimal.
  def var pc like vcdocs.sum.
  pc = 0.
  for each b-vcdocs where b-vcdocs.contract = s-contract and 
      lookup(b-vcdocs.dntype, s-vcdoctypes) > 0 and b-vcdocs.docs <> vcdocs.docs
      no-lock:
    accumulate b-vcdocs.sum / b-vcdocs.cursdoc-con (total).
  end.
  pc = pc + (accum total b-vcdocs.sum / b-vcdocs.cursdoc-con).
  return pc.
end.

function chk-crc returns logical (p-value as integer).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.
  def var v-curs as deci.

  find ncrc where ncrc.crc = p-value no-lock no-error.
  if not avail ncrc then do:
    msg-err = "Недопустимый код валюты!". return false. end.
  if lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
    msg-err = "Выбранная валюта не входит в список валют платежа по данному контракту!".
    return false.
  end.
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find ncrc where ncrc.crc = p-value no-lock no-error.
  if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vcdocs.dndate then do:
    msg-err = "Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) + 
       " - заменена " + entry(1, ncrc.prefix) + " !".
    return false.
  end.

  pc = summplat().
  
  run crosscurs(p-value, vccontrs.ncrc, vcdocs.dndate, output v-curs).
  pd = pc + vcdocs.sum / v-curs.
  if pd > vccontrs.ctsum then do:
    msg-err = "Общая сумма ГТД " + string(pd) + 
       " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
    return false.
  end.
  return true. 
end.

function chk-knp returns logical (p-str as char).
  return p-str = "" or (p-str <> "msc" and 
         can-find(codfr where codfr.codfr = "spnpl" and codfr.code = p-str no-lock)).
end.

function chk-sum returns logical (p-value as decimal).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.
  if p-value = 0 then do:
    msg-err = "Сумма не должна быть нулевой!".
    return false.
  end.

  pc = summplat().
  pd = pc + p-value / vcdocs.cursdoc-con.

  if pd > vccontrs.ctsum then do:
    msg-err = "Общая сумма ГТД " + string(pd) + 
       " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
    return false.
  end.

  return true.
end.

function chk-curs returns logical (p-value as decimal).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.

  if p-value = 0 then do:
    msg-err = "Курс не может быть нулевым!".
    return false.
  end.

  pc = summplat().
  pd = pc + vcdocs.sum / p-value.

  if pd > vccontrs.ctsum then do:
    msg-err = "Общая сумма ГТД " + string(pd) + 
       " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
    return false.
  end.

  return true.
end.

function chk-payret returns logical (p-value as logical).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.
  def var v-curs as deci.

  pc = summplat().
  if p-value then pd = pc - vcdocs.sum / vcdocs.cursdoc-con. 
  else pd = pc + vcdocs.sum / vcdocs.cursdoc-con.
  if pd > vccontrs.ctsum then do:
    msg-err = "Общая сумма ГТД " + string(pd) + 
        " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
    return false.
  end.
  if pd < 0 then do:
    msg-err = "Сумма возвратов не может быть больше суммы отправленных ГТД! Общая сумма ГТД " + string(pd).
    return false.
  end.
  return true. 
end.


form 
  vcdocs.dntype colon 12 format "xx" validate(chk-dntype(vcdocs.dntype), "Неверный тип документа !")
  v-dntypename format "x(15)" no-label
         vcdocs.rdt label "РЕГ." colon 39 
         vcdocs.rwho no-label colon 50 skip
         vcdocs.cdt label "АКЦ." colon 39 
         vcdocs.cwho no-label colon 50 skip
  vcdocs.dnnum colon 12 format "x(50)" label "НОМЕР" validate(chk-dnnum(vcdocs.dnnum), msg-err) skip
  vcdocs.dndate colon 12 validate(chk-dndate(vcdocs.dndate), msg-err) skip
  vcdocs.payret colon 12 validate(chk-payret(vcdocs.payret), msg-err) skip
  vcdocs.pcrc colon 12 format ">>9" label "ВАЛЮТА" validate(chk-crc(vcdocs.pcrc), msg-err)
  v-crckod format "xxx" no-label 
  vcdocs.sum colon 39 validate(chk-sum(vcdocs.sum), msg-err) skip
  vcdocs.cursdoc-con label "К ВАЛ.КОН." colon 12 format ">>>>>>>>>9.9999<<"
        validate(chk-curs(vcdocs.cursdoc-con), msg-err)
  v-sumdoccon format ">>>,>>>,>>>,>>>,>>9.99" label "В ВАЛ.КОН" colon 39 skip
  skip(1)

/*  vcdocs.knp colon 12 validate(chk-knp(vcdocs.knp), "Недопустимый код назначения платежа!")
  vcdocs.kod14 colon 12 validate(chk-kod14(vcdocs.kod14), 
         "Недопустимый код строки отчета - должно быть целое число!") skip*/
  vcdocs.origin  colon 12                label "ЕСТЬ ОРИГ?"  skip
  vcdocs.info[1] colon 12 format "x(50)" label "ПРИМЕЧАНИЕ" skip(1)

  with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcdngtd.

{vc-summf.i}



