/* vcdndlg.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма для отображения данных по должникам.
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
        21/06/04 saltanat
 * CHANGES
        26.01.2011 aigul - вывод данных
*/

{vc-crosscurs.i}

def var v-dntypename as char.
def var msg-err as char.
def buffer b-vcdolgs for vcdolgs.
def var v-procent as char.
def var v-crckod as char.
def var v-sumdoccon as decimal.
def var v-partner as char.
def var v-locatben as logical format "да/нет".

/*saltanat*/
function chk-dntype returns logical (p-str as char).
  return p-str <> "" and p-str <> "msc" and
  can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = p-str and
  lookup(p-str, s-vcdoctypes) > 0 no-lock).
end.
/**/
function chk-dndate returns logical(p-value as date).
 if p-value = ? then do:
   msg-err = " Введите дату документа!". return false. end.
 if p-value < vccontrs.ctdate then do:
   msg-err = " Дата документа не может быть меньше даты контракта!". return false. end.
 if p-value > vccontrs.lastdate and (vccontrs.cttype <> '1' or  vccontrs.lastdate <> ?) then do:
   msg-err = " Дата документа не может быть больше последней даты контракта!". return false. end.
 if can-find(b-vcdolgs where b-vcdolgs.contract = s-contract and
         b-vcdolgs.dntype = vcdolgs.dntype and b-vcdolgs.dnnum = vcdolgs.dnnum and
         b-vcdolgs.dndate = p-value and b-vcdolgs.dolgs <> vcdolgs.dolgs no-lock) then do:
    msg-err = " Уже есть документ с таким номером и датой по данному контракту!". return false. end.
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find ncrc where ncrc.crc = vcdolgs.pcrc no-lock no-error.
  if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-value then do:
    msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
       " - заменена " + entry(1, ncrc.prefix) + " !".
    return false.
  end.
  return true.
end.


function summplat returns decimal.
    def var pc like vcdolgs.sum.
    pc = 0.
    if vccontrs.cttype = '1' then do:
      for each b-vcdolgs where b-vcdolgs.contract = s-contract and
      lookup(b-vcdolgs.dntype, s-vcdoctypes) > 0 and b-vcdolgs.dolgs <> vcdolgs.dolgs
      and (if vccontrs.expimp = 'i' then b-vcdolgs.dntype = '26' else b-vcdolgs.dntype = '27') and b-vcdolgs.info[2] = '1'
      no-lock break by b-vcdolgs.payret:
        accumulate b-vcdolgs.sum / b-vcdolgs.cursdoc-con (sub-total by b-vcdolgs.payret).
        if last-of(b-vcdolgs.payret) then do:
            if b-vcdolgs.payret then pc = pc - (accum sub-total by b-vcdolgs.payret b-vcdolgs.sum / b-vcdolgs.cursdoc-con).
            else pc = pc + (accum sub-total by b-vcdolgs.payret b-vcdolgs.sum / b-vcdolgs.cursdoc-con).
        end.
      end.
    end.
    return pc.
end.

function summplat1 returns decimal.
    def var pc1 like vcdolgs.sum.
    pc1 = 0.
    if vccontrs.cttype = '1' then do:
      for each b-vcdolgs where b-vcdolgs.contract = s-contract and
      lookup(b-vcdolgs.dntype, s-vcdoctypes) > 0 and b-vcdolgs.dolgs <> vcdolgs.dolgs
      no-lock:
        if b-vcdolgs.dntype = '26' then do:
            if b-vcdolgs.payret then pc1 = pc1 - b-vcdolgs.sum / b-vcdolgs.cursdoc-con.
            else pc1 = pc1 + b-vcdolgs.sum / b-vcdolgs.cursdoc-con.
        end.
      end.
    end.
    return pc1.
end.
function summplat2 returns decimal.
    def var pc2 like vcdolgs.sum.
    pc2 = 0.
    if vccontrs.cttype = '1' then do:
      for each b-vcdolgs where b-vcdolgs.contract = s-contract and
      lookup(b-vcdolgs.dntype, s-vcdoctypes) > 0 and b-vcdolgs.dolgs <> vcdolgs.dolgs
      no-lock:
        if b-vcdolgs.dntype = '27' then do:
            if b-vcdolgs.payret then pc2 = pc2 - b-vcdolgs.sum / b-vcdolgs.cursdoc-con.
            else pc2 = pc2 + b-vcdolgs.sum / b-vcdolgs.cursdoc-con.
        end.
      end.
    end.
    return pc2.
end.
function summakt returns decimal.
  def var pc like vcdolgs.sum.
  pc = 0.
  for each b-vcdolgs where b-vcdolgs.contract = s-contract and
      b-vcdolgs.dntype = vcdolgs.dntype and b-vcdolgs.dolgs <> vcdolgs.dolgs
      no-lock break by b-vcdolgs.payret:
    accumulate b-vcdolgs.sum / b-vcdolgs.cursdoc-con (sub-total by b-vcdolgs.payret).
    if last-of(b-vcdolgs.payret) then do:
      if b-vcdolgs.payret then
        pc = pc - (accum sub-total by b-vcdolgs.payret b-vcdolgs.sum / b-vcdolgs.cursdoc-con).
      else
        pc = pc + (accum sub-total by b-vcdolgs.payret b-vcdolgs.sum / b-vcdolgs.cursdoc-con).
    end.
  end.
  return pc.
end.

function chk-percent returns logical (p-str as char).
  def var l as logical.
  def var d as decimal.
  def var n as integer.
  def var vs as decimal.

  l = true.
  if p-str = "" then do:
    l = false.
    msg-err = " Введите процент от суммы!".
  end.
  else do:
    vs = 0.
    do n = 1 to num-entries(p-str):
      d = decimal(entry(n, p-str)) no-error.
      if error-status:error then do:
        l = false.
        msg-err = " Введены неверные символы - должны быть цифры или точка-разделитель.".
        leave.
      end.
      vs = vs + d.
    end.
    if l and vs > 100 then do:
      l = false.
      msg-err = " Сумма процентов не должны быть больше 100% !".
    end.
  end.
  return l.
end.

function chk-payret returns logical (p-value as logical).
    def var pd like vcdolgs.sum.
    def var pc like vcdolgs.sum.
    def var v-curs as deci.
    if index(s-dnvid, "p") > 0 then do:
        pc = summplat().
        if vccontrs.cttype = '1' and vcdolgs.dntype = '26' then do:
            if vcdolgs.payret then /*pd = pc - p-value / vcdolgs.cursdoc-con*/  pd = pc - vcdolgs.sum / vcdolgs.cursdoc-con.
            if vcdolgs.payret = no then /*pd = pc + p-value / vcdolgs.cursdoc-con*/ pd = pc + vcdolgs.sum / vcdolgs.cursdoc-con.
        end.
        if vccontrs.cttype = '1' and vcdolgs.dntype = '27' then do:
            if vcdolgs.payret then pd = pc - vcdolgs.sum / vcdolgs.cursdoc-con.
            if vcdolgs.payret = no then pd = pc + vcdolgs.sum / vcdolgs.cursdoc-con.
        end.
        if pd > vccontrs.ctsum and vccontrs.cttype <> '7' and (vccontrs.ctsum > 0 and vccontrs.cttype <> '3') then do:
            msg-err = " Общая сумма платежей " + string(pd) +
            " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
            return false.
        end.
        if pd < 0 then do:
            msg-err = " Сумма возвратов не может быть больше суммы проплат! Общая сумма платежей " + string(pd).
            return false.
        end.
    end.
    return true.
end.


function chk-crc returns logical (p-value as integer).
  def var pd like vcdolgs.sum.
  def var pc like vcdolgs.sum.
  def var v-curs as deci.

  find ncrc where ncrc.crc = p-value no-lock no-error.
  if not avail ncrc then do:
    msg-err = " Недопустимый код валюты!". return false. end.
  if lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
    msg-err = " Выбранная валюта не входит в список валют платежа по данному контракту!".
    return false.
  end.
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find ncrc where ncrc.crc = p-value no-lock no-error.
  if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vcdolgs.dndate then do:
    msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
       " - заменена " + entry(1, ncrc.prefix) + " !".
    return false.
  end.
  return true.
end.


function chk-sum returns logical (p-value as decimal).
  def var pd like vcdolgs.sum.
  def var pc like vcdolgs.sum.
  def var pd1 like vcdolgs.sum.
  def var pc1 like vcdolgs.sum.
  def var pd2 like vcdolgs.sum.
  def var pc2 like vcdolgs.sum.
  if p-value = 0 then do:
    msg-err = " Сумма не должна быть нулевой!".
    return false.
  end.
  if index(s-dnvid, "p") > 0 then do:
    pc = summplat().
    pc1 = summplat1().
    pc2 = summplat2().
    if vccontrs.cttype = '1' and vcdolgs.dntype = '26' then do:
      if vcdolgs.payret then do:
        pd = pc - p-value / vcdolgs.cursdoc-con.
        pd1 = pc1 - p-value / vcdolgs.cursdoc-con.
      end.
      if vcdolgs.payret = no then do:
        pd = pc + p-value / vcdolgs.cursdoc-con.
        pd1 = pc1 + p-value / vcdolgs.cursdoc-con.
      end.
    end.
    if vccontrs.cttype = '1' and vcdolgs.dntype = '27' then do:
      if vcdolgs.payret then do:
        pd = pc - p-value / vcdolgs.cursdoc-con.
        pd2 = pc2 - p-value / vcdolgs.cursdoc-con.
      end.
      if vcdolgs.payret = no then do:
        pd = pc + p-value / vcdolgs.cursdoc-con.
        pd2 = pc2 + p-value / vcdolgs.cursdoc-con.
      end.
    end.

    if pd > vccontrs.ctsum and vccontrs.cttype <> '7' and (vccontrs.ctsum > 0 and vccontrs.cttype <> '3') then do:
      msg-err = " Общая сумма платежей " + string(pd) + " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
      return false.
    end.

    if pd1 > vccontrs.ctsum then do:
      msg-err = " Общая сумма платежей " + string(pd1) + " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
      return false.
    end.

    if pd2 > vccontrs.ctsum then do:
      msg-err = " Общая сумма платежей " + string(pd2) + " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
      return false.
    end.
    else return true.
    if pd < 0 then do:
      msg-err = " Сумма возвратов не может быть больше суммы проплат! Общая сумма платежей " + string(pd).
      return false.
    end.
  end.
  return true.
end.


function chk-curs returns logical (p-value as decimal).
  def var pd like vcdolgs.sum.
  def var pc like vcdolgs.sum.

  if p-value = 0 then do:
    msg-err = " Курс не может быть нулевым!".
    return false.
  end.
  return true.
end.


function chk-knp returns logical (p-str as char).
  return p-str = "" or (p-str <> "msc" and
         can-find(codfr where codfr.codfr = "spnpl" and codfr.code = p-str no-lock)).
end.

function chk-forms return logical(p-dntype as char, p-forms as char).
def var l as logical init false.
  if lookup(p-dntype,'02,03,23,24') > 0 then do:
     find current vccontrs no-lock.
     if lookup(p-forms, vccontrs.ctformrs) > 0 then l = true.
  end.
  else l = true.
  return l.
end.

function chk-dnnum returns logical (p-str as char).
  if p-str = "" then do:
    msg-err = " Введите номер документа!".
    return false.
  end.
  if can-find(b-vcdolgs where b-vcdolgs.contract = s-contract and
         b-vcdolgs.dntype = vcdolgs.dntype and b-vcdolgs.dnnum = p-str and
         b-vcdolgs.dndate = vcdolgs.dndate and b-vcdolgs.dolgs <> vcdolgs.dolgs no-lock) then do:
    msg-err = " Уже есть документ с таким номером и датой по данному контракту!".
    return false.
  end.
  return true.
end.

form
  vcdolgs.dntype colon 15 format "xx" validate(chk-dntype(vcdolgs.dntype), "Неверный тип документа !")
  v-dntypename format "x(15)" no-label
         vcdolgs.rdt label "РЕГ." colon 39
         vcdolgs.rwho no-label colon 50 skip
         vcdolgs.cdt label "АКЦ." colon 39
         vcdolgs.cwho no-label colon 50 skip
  vcdolgs.dnnum colon 15 format "x(30)" label "НОМЕР" validate(chk-dnnum(vcdolgs.dnnum), msg-err) skip
  vcdolgs.dndate colon 15 validate(chk-dndate(vcdolgs.dndate), msg-err)
  vcdolgs.pdt label "ДАТА ВОЗВРАТА" colon 15
  vcdolgs.pwho no-label colon 29
  /*vcdolgs.dnvn label "ДАТА ВНЕСЕНИЯ" colon 15 skip
  vcdolgs.dnpg label "ДАТА ПОГ.ДОЛГА" colon 15 skip*/

  vcdolgs.payret colon 15 validate(chk-payret(vcdolgs.payret), msg-err)
  vcdolgs.sumpercent colon 39 format "x(18)" validate(chk-percent(vcdolgs.sumpercent), msg-err)
  vcdolgs.info[2] colon 39 format "x" label "ОПЛАТА%" validate(index('12',vcdolgs.info[2]) > 0, "Неверный код оплаты процентов!")
  v-procent format "x(3)" no-label skip
  vcdolgs.pcrc colon 15 format ">>9" label "ВАЛЮТА" validate(chk-crc(vcdolgs.pcrc), msg-err)
  v-crckod format "xxx" no-label
  vcdolgs.sum colon 39 validate(chk-sum(vcdolgs.sum), msg-err) skip
  vcdolgs.cursdoc-con label "К ВАЛ.КОН." colon 15 format ">>>>>>9.9999<<"
         validate(chk-curs(vcdolgs.cursdoc-con), msg-err)
  v-sumdoccon format ">>>,>>>,>>>,>>>,>>9.99" label "В ВАЛ.КОН" colon 39 skip

  vcdolgs.info[4] label "ИНОПАРТНЕР" format "x(10)"
         help " Код партнера - получателя/отправителя платежа (F2 - список)"
         validate (can-find (vcpartners where vcpartners.partner = vcdolgs.info[4] no-lock) , " Неверный код инопартнера!")
         colon 15
  v-partner no-label colon 25 format "x(30)" skip

  vcdolgs.knp colon 15
         validate(chk-knp(vcdolgs.knp), " Недопустимый код назначения платежа!")
         help " F2 - справочник кодов назначения платежа"
  v-locatben colon 39 label "БЕНЕФ-Р РЕЗ-Т?" skip
  vcdolgs.origin colon 15 label "ЕСТЬ ОРИГ?"
/*  vcdocs.kod14 colon 39 validate(chk-kod14(vcdocs.kod14),
         " Недопустимый код строки отчета - должно быть целое число!") skip*/
  vcdolgs.kod14 colon 39 label "ФОРМА РАСЧЕТОВ" validate(chk-forms(vcdolgs.dntype,vcdolgs.kod14),
         "Форма расчетов не соответсвует указанной в конракте!")
         help " F2 - формы расчетов по данному контракту" skip
  vcdolgs.info[1] colon 15 format "x(40)" label "ПРИМЕЧАНИЕ" skip
  with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcdndlg.


{vc-summf.i}

on help of vcdolgs.info[4] in frame vcdndlg do:
  run h-partner.
  vcdolgs.info[4] = return-value.
  displ vcdolgs.info[4] with frame vcdndlg.
end.
on help of vcdolgs.kod14  in frame vcdndlg do:
  def var v-forms as char.
  def var v-sel as integer.
  def var i as integer.
  find current vccontrs no-lock.
  if v-forms = '' then do:
     do i = 1 to num-entries(vccontrs.ctformrs):
        find codfr where codfr.codfr = 'vcfpay' and codfr.code = entry(i,vccontrs.ctformrs) no-lock no-error.
        if v-forms <> '' then v-forms = v-forms + '|'.
        v-forms = v-forms + codfr.code + " " + codfr.name[1].
     end.
  end.
  run sel2 (' ФОРМА РАСЧЕТА ', v-forms, output v-sel).
  if v-sel <> 0 then vcdolgs.kod14  = entry(1,entry(v-sel,v-forms,'|'),' ').
  displ vcdolgs.kod14  with frame vcdndlg.
end.