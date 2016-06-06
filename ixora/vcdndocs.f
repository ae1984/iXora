/* vcdndocs.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма документа по контракту
 * RUN
        верхнее меню контракта
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-1
 * AUTHOR
        18.10.2002 nadejda
 * BASES
        BANK COMM
 * CHANGES
        22.08.2003 nadejda - добавлены поля сведений о партнере
        17.04.2008 - платеж на контракт с нулевой суммой (типа 7)
        14.05.2008 galina - Добавлно поле ОПЛАТА %
        06.06.2008 galina - не прибавлять погашение% и перевод займа к сумме платежей
        18.08.2008 galina - в поле info[1] вводим форму расчетов
                            функция проверки соотвествия формы расчетов, указанной на контракте
        10.11.2008 galina - платеж на контракт с нулевой суммой (типа 3)
        25.11.2008 galina - акты на контракт с нулевой суммой (типа 3)
        09.04.2009 galina - расчет ссуммы платежей для конрактов типа 6 (фин.займы)
        18.05.2009 galina - возмоность ввода пустой даты завершения контракта
        21/06/2010 galina - новые типы документов зачет- (тип документа 23) и зачет+ (тип документа 24)
        03.08.2011 aigul - добавила возможность создания др доков в валюте контракта
        30.09.2011 damir - добавлены
                           1) новые поля во фрейм vcdndocs - opertype, dtcorrect, zachet, ustupka, perdolga , numobyaz
                           2) 3 form - фреймы newps, newdc, country. 3) Алгоритм выбора редактирования нужных полей при корректировке.
        12.01.2012 damir - изменил формат поля.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        27.04.2012 aigul - проверка валюты в платДк с валютой платежа контракта
        15.05.2012 aigul - проверка платежей, что они не превышают сумму контракта
        16.05.2012 aigul - проверка даты платежа с послдней датой РС/СУ
        13.06.2012 damir - добавил тип контракта 1 при проверке ОБЩ СУММЫ ПЛАТ > СУММЫ КОНТР. (chk-sum)
        29.06.2012 damir - убрал validate проверку на наличие Формы расчетов в контракте.
        29.06.2012 damir - убрал зачет,уступка,пер.долга в form, убрал validate на Код способа расчетов.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/


def shared var s-avail03 as logical.

def var v-dntypename as char.
def buffer b-vcdocs for vcdocs.
def var v-sumdoccon as decimal.
def var v-crckod as char.
def var msg-err as char.
def var v-locatben as logical format "да/нет".
def var v-partner as char.

def var v-procent as char.
def var v-ordben as char.
def var v-country as char.
def var v-sel as char.
def var v-plreas as char.
def var s as inte.
def var v-s as inte.
def var v-cod as char.
def var v-info4 as char.

def new shared temp-table t-chg no-undo
    field k as inte
    field nam as char
    field cod as char
index idx1 is primary k ascending.

{vc-crosscurs.i}

/*function chk-kod14 returns logical (p-str as char).
    def var l as logical.
    def var i as integer.
    l = true.
    if p-str <> "" then do:
        i = integer(p-str) no-error.
        if error-status:error then l = false.
    end.
    return l.
end.*/
function chk-forms return logical(p-dntype as char, p-forms as char).
    def var l as logical init false.
    if lookup(p-dntype,'02,03,23,24') > 0 then do:
        find current vccontrs no-lock.
        if lookup(p-forms, vccontrs.ctformrs) > 0 then l = true.
    end.
    else l = true.
    return l.
end.

function chk-dntype returns logical (p-str as char).
    if p-str = "" then do:
        msg-err = " Введите тип документа!".
        return false.
    end.
    if not can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = p-str and codfr.code <> "msc" and lookup(p-str, s-vcdoctypes) > 0 no-lock) then do:
        msg-err = " Недопустимый тип документа!".
        return false.
    end.
    /* 28.11.2003 nadejda - временно отключено для ввода старых платежей
    if p-str = "03" and not s-avail03 then do:
    msg-err = " ЗАПРЕЩЕНО создавать поручение на перевод!".
    return false.
    end.
    */
    return true.
end.

function chk-dnnum returns logical (p-str as char).
    p-str = trim(p-str).
    if p-str = "" then do:
        msg-err = " Введите номер документа!".
        return false.
    end.
    return true.
end.

function chk-dndate returns logical(p-value as date).
    if p-value = ? then do:
        msg-err = " Введите дату документа!".
        return false.
    end.
    if p-value < vccontrs.ctdate then do:
        msg-err = " Дата документа не может быть меньше даты контракта!". return false. end.
        if (vccontrs.cttype = '3' or vccontrs.cttype = '6' or vccontrs.cttype = '11') then do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
            if avail vcrslc then do:
                if p-value > vcrslc.lastdate then do:
                msg-err = " Дата документа не может быть больше последней даты РС/СУ! ".
                return false.
            end.
        end.
    end.
    if p-value > vccontrs.lastdate and (vccontrs.cttype <> '1' or  vccontrs.lastdate <> ?) then do:
        msg-err = " Дата документа не может быть больше последней даты контракта!".
        return false.
    end.
    if can-find(b-vcdocs where b-vcdocs.contract = s-contract and b-vcdocs.dntype = vcdocs.dntype and trim(b-vcdocs.dnnum) = trim(vcdocs.dnnum) and b-vcdocs.dndate = p-value and
    b-vcdocs.docs <> vcdocs.docs no-lock) then do:
        msg-err = " Уже есть документ с таким номером и датой по данному контракту!".
        return false.
    end.
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
    if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-value then do:
        msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) + " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.
    return true.
end.

function summplat returns decimal.
    def var pc like vcdocs.sum.
    pc = 0.
    if vccontrs.cttype <> '6' then do:
        for each b-vcdocs where b-vcdocs.contract = s-contract and lookup(b-vcdocs.dntype, s-vcdoctypes) > 0 and b-vcdocs.docs <> vcdocs.docs no-lock break by b-vcdocs.payret:
            accumulate b-vcdocs.sum / b-vcdocs.cursdoc-con (sub-total by b-vcdocs.payret).
            if last-of(b-vcdocs.payret) then do:
                if b-vcdocs.payret then pc = pc - (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
                else pc = pc + (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
            end.
        end.
    end.
    if vccontrs.cttype = '6' then do:
        for each b-vcdocs where b-vcdocs.contract = s-contract and lookup(b-vcdocs.dntype, s-vcdoctypes) > 0 and b-vcdocs.docs <> vcdocs.docs and (if vccontrs.expimp = 'i' then
        b-vcdocs.dntype = '03' else b-vcdocs.dntype = '02') and b-vcdocs.info[2] = '1' no-lock break by b-vcdocs.payret:
            accumulate b-vcdocs.sum / b-vcdocs.cursdoc-con (sub-total by b-vcdocs.payret).
            if last-of(b-vcdocs.payret) then do:
                if b-vcdocs.payret then pc = pc - (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
                else pc = pc + (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
            end.
        end.
    end.
    return pc.
end.

function chk-crc returns logical (p-value as integer, p1-value as char).
    def var pd like vcdocs.sum.
    def var pc like vcdocs.sum.
    def var v-curs as deci.
    find ncrc where ncrc.crc = p-value no-lock no-error.
    if not avail ncrc then do:
        msg-err = " Недопустимый код валюты!". return false.
    end.

    if (p1-value = "17" or p1-value = "18" or p1-value = "20" or p1-value = "30" or p1-value = "23" or p1-value = "24") and  lookup(ncrc.code, vccontrs.ctvalpl) = 0
    and lookup(string(ncrc.crc), string(vccontrs.ncrc)) = 0 then do:
        msg-err = " Выбранная валюта не входит в список валют платежа по данному контракту!".
        return false.
    end.
    if (p1-value = "02" or p1-value = "03" or p1-value = "26" or p1-value = "27") and  lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
        msg-err = " Выбранная валюта не входит в список валют платежа по данному контракту!".
        return false.
    end.
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = p-value no-lock no-error.
    if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vcdocs.dndate then do:
        msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) + " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.

    if index(s-dnvid, "p") > 0 then do:
        pc = summplat().
        run crosscurs(p-value, vccontrs.ncrc, vcdocs.dndate, output v-curs).

        if vccontrs.cttype = '6' then do:
            pd = pc.
            if  vccontrs.expimp = 'i' and vcdocs.dntype = '03' and vcdocs.info[2] = '1' then do:
                if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
                else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
            end.
            if vccontrs.expimp = 'e' and vcdocs.dntype = '02' and vcdocs.info[2] = '1' then do:
                if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
                else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
            end.
        end.
        else do:
            if vcdocs.payret then pd = pc - p-value / vcdocs.cursdoc-con.
            else pd = pc + p-value / vcdocs.cursdoc-con.
        end.

        if pd > vccontrs.ctsum and vccontrs.cttype <> '7' and (vccontrs.ctsum > 0 and vccontrs.cttype <> '3') then do:
            msg-err = " Общая сумма платежей " + string(pd) + " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
            return false.
        end.
        if pd < 0 then do:
            msg-err = " Сумма возвратов не может быть больше суммы проплат! Общая сумма платежей " + string(pd).
            return false.
        end.
    end.
    return true.
end.

function chk-knp returns logical (p-str as char).
    return p-str = "" or (p-str <> "msc" and can-find(codfr where codfr.codfr = "spnpl" and codfr.code = p-str no-lock)).
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

function chk-sum returns logical (p-value as decimal).
    def var pd like vcdocs.sum.
    def var pc like vcdocs.sum.
    if p-value = 0 then do:
        msg-err = " Сумма не должна быть нулевой!".
        return false.
    end.

    if index(s-dnvid, "p") > 0 then do:
        pc = summplat().

        if vccontrs.cttype = '6' then do:
            pd = pc.
            if  vccontrs.expimp = 'i' and vcdocs.dntype = '03' and vcdocs.info[2] = '1' then do:
                if not vcdocs.payret then pd = pd + p-value / vcdocs.cursdoc-con.
                else pd = pd - p-value / vcdocs.cursdoc-con.
            end.
            if vccontrs.expimp = 'e' and vcdocs.dntype = '02' and vcdocs.info[2] = '1' then do:
                if not vcdocs.payret then pd = pd + p-value / vcdocs.cursdoc-con.
                else pd = pd - p-value / vcdocs.cursdoc-con.
            end.
        end.
        else do:
            if vcdocs.payret then pd = pc - p-value / vcdocs.cursdoc-con.
            else pd = pc + p-value / vcdocs.cursdoc-con.
        end.
        if not (vccontrs.ctsum = 0 and vccontrs.cttype = '3') then do:
            if pd > vccontrs.ctsum and vccontrs.cttype <> '7' and (vccontrs.cttype = '1' or vccontrs.cttype = '2' or vccontrs.cttype = '3' or vccontrs.cttype = '6' or vccontrs.cttype = '11')
            then do:
                msg-err = " Общая сумма платежей " + string(pd) + " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
                return false.
            end.
            else return true.
            if pd < 0 then do:
                msg-err = " Сумма возвратов не может быть больше суммы проплат! Общая сумма платежей " + string(pd).
                return false.
            end.
        end.
    end.
    return true.
end.

function chk-curs returns logical (p-value as decimal).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.

  if p-value = 0 then do:
    msg-err = " Курс не может быть нулевым!".
    return false.
  end.

  if index(s-dnvid, "p") > 0 then do:
    pc = summplat().

    if vccontrs.cttype = '6' then do:
      pd = pc.
      if  vccontrs.expimp = 'i' and vcdocs.dntype = '03' and vcdocs.info[2] = '1' then do:
         if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
         else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
      end.
      if vccontrs.expimp = 'e' and vcdocs.dntype = '02' and vcdocs.info[2] = '1' then do:
         if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
         else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
      end.
    end.
    else do:
      if vcdocs.payret then pd = pc - p-value / vcdocs.cursdoc-con.
      else pd = pc + p-value / vcdocs.cursdoc-con.
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

function summakt returns decimal.
  def var pc like vcdocs.sum.
  pc = 0.
  for each b-vcdocs where b-vcdocs.contract = s-contract and
      b-vcdocs.dntype = vcdocs.dntype and b-vcdocs.docs <> vcdocs.docs
      no-lock break by b-vcdocs.payret:
    accumulate b-vcdocs.sum / b-vcdocs.cursdoc-con (sub-total by b-vcdocs.payret).
    if last-of(b-vcdocs.payret) then do:
      if b-vcdocs.payret then
        pc = pc - (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
      else
        pc = pc + (accum sub-total by b-vcdocs.payret b-vcdocs.sum / b-vcdocs.cursdoc-con).
    end.
  end.
  return pc.
end.

function chk-payret returns logical (p-value as logical).
  def var pd like vcdocs.sum.
  def var pc like vcdocs.sum.
  def var v-curs as deci.

  if index(s-dnvid, "p") > 0 then do:
    pc = summplat().
    if vccontrs.cttype = '6' then do:
      pd = pc.
      if  vccontrs.expimp = 'i' and vcdocs.dntype = '03' and vcdocs.info[2] = '1' then do:
         if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
         else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
      end.
      if vccontrs.expimp = 'e' and vcdocs.dntype = '02' and vcdocs.info[2] = '1' then do:
         if not vcdocs.payret then pd = pd + vcdocs.sum / vcdocs.cursdoc-con.
         else pd = pd - vcdocs.sum / vcdocs.cursdoc-con.
      end.

    end.
    else do:
      if vcdocs.payret then pd = pc - vcdocs.sum / vcdocs.cursdoc-con.
      else pd = pc + vcdocs.sum / vcdocs.cursdoc-con.
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

  if vcdocs.dntype = "17" then do:
    pc = summakt().
    if p-value then pd = pc - vcdocs.sum / vcdocs.cursdoc-con.
    else pd = pc + vcdocs.sum / vcdocs.cursdoc-con.
    if pd > vccontrs.ctsum and (vccontrs.ctsum > 0 and vccontrs.cttype <> '3') then do:
      msg-err = " Общая сумма актов " + string(pd) +
          " превышает сумму контракта " + string(vccontrs.ctsum) + " !".
      return false.
    end.
    if pd < 0 then do:
      msg-err = " Сумма возвратов не может быть больше суммы актов! Общая сумма актов " + string(pd).
      return false.
    end.
  end.
  return true.
end.


form
    vcdocs.dntype colon 12 format "xx" validate(chk-dntype(vcdocs.dntype), msg-err)
    v-dntypename format "x(15)" no-label
    vcdocs.rdt label "РЕГ." colon 39
    vcdocs.rwho no-label colon 50 skip
    vcdocs.opertype label "ТИП ОПЕР" colon 12 validate(index("12",vcdocs.opertype) > 0, "Невозможный тип операции, выберите 1 или 2 !" )
    vcdocs.cdt label "АКЦ." colon 39
    vcdocs.cwho no-label colon 50 skip
    vcdocs.dtcorrect label "ДАТА КОРР." colon 12 skip
    vcdocs.dnnum colon 12 format "x(50)" label "НОМЕР" validate(chk-dnnum(vcdocs.dnnum), msg-err) skip
    vcdocs.dndate colon 12 validate(chk-dndate(vcdocs.dndate), msg-err)
    vcdocs.sumpercent colon 39 format "x(18)" validate(chk-percent(vcdocs.sumpercent), msg-err) skip
    vcdocs.payret colon 12 validate(chk-payret(vcdocs.payret), msg-err)
    v-locatben colon 39 label "БЕНЕФ-Р РЕЗ-Т?" skip
    vcdocs.info[2] colon 39 format "x" label "ОПЛАТА%" validate(index('12',vcdocs.info[2]) > 0, "Неверный код оплаты процентов!")
    v-procent format "x(3)" no-label skip
    vcdocs.pcrc colon 12 format ">>9" label "ВАЛЮТА" /*validate(chk-crc(vcdocs.pcrc, vcdocs.dntype), msg-err)*/
    v-crckod format "xxx" no-label
    vcdocs.sum colon 39 validate(chk-sum(vcdocs.sum), msg-err) skip
    vcdocs.cursdoc-con label "К ВАЛ.КОН." colon 12 format ">>>>>>>>>9.9999<<" /*validate(chk-curs(vcdocs.cursdoc-con), msg-err)*/
    v-sumdoccon format ">>>,>>>,>>>,>>>,>>9.99" label "В ВАЛ.КОН" colon 39 skip
    vcdocs.info[4] label "ИНОПАРТНЕР" format "x(10)" colon 12 validate (can-find (vcpartners where vcpartners.partner = vcdocs.info[4] no-lock) , " Неверный код инопартнера!")
    v-partner no-label colon 23 format "x(35)" skip
    vcdocs.knp colon 12 validate(chk-knp(vcdocs.knp), " Недопустимый код назначения платежа!") help " F2 - справочник кодов назначения платежа"
    /*vcdocs.origin colon 12 label "ЕСТЬ ОРИГ?"*/
    /*vcdocs.kod14 colon 39 validate(chk-kod14(vcdocs.kod14),"Недопустимый код строки отчета - должно быть целое число!") skip*/
    /*vcdocs.zachet  label "ЗАЧЕТ" format "да/нет" colon 12 help "Выберите да/нет !" skip
    vcdocs.ustupka label "УСТУПКА" format "да/нет"    colon 12 help "Выберите да/нет !" skip
    vcdocs.perdolga label "ПЕР. ДОЛГА" format "да/нет" colon 12 help "Выберите да/нет !" skip*/
    vcdocs.kod14 colon 12 label "ФОРМА РАСЧ." /*validate(chk-forms(vcdocs.dntype,vcdocs.kod14),"Форма расчетов не соответсвует указанной в конракте!")*/ help " F2 - формы расчетов по данному контракту"
    vcdocs.numobyaz label "№ ОБЯЗ" colon 39 format ">>>>>>>9" skip
    vcdocs.info[1] colon 12 format "x(50)" label "ПРИМЕЧАНИЕ" skip
with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcdndocs.

form
    vcdocs.info[4] label "ИНОПАРТНЕР" format "x(10)" skip
    v-ordben label "Наименование/ФИО" format "x(80)" skip
    v-country label "Страна" format "x(2)" skip
with row 18 column 1 width 100 overlay side-label title "ОТПРАВИТЕЛЬ/ПОЛУЧАТЕЛЬ" frame country.

{vc-summf.i}

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*
Значение в comm.vcdocs.info2[1].

11-Страна отправителя денег/товара
12-Страна бенефициара
13-Дата платежа/исполнения обязательств
14-Сумма платежа/обязательств
15-Валюта платежа
16-Способ расчетов
17-Признак платежа - исходящий/входящий
18-Номер основания для зачета или уступки или иного исполнения
19-Дата основания для зачета или уступки или иного исполнения
20-Дата оформления нового ПС
21-Номер нового ПС
22-Примечание
23-Наименование/ФИО отправителя денег/товаров
24-Наименование/ФИО получателя денег/товаров
*/
do s = 1 to 10:
    find t-chg where t-chg.k = s no-lock no-error.
    if not avail t-chg then do:
        create t-chg.
        t-chg.k = s.
        if s = 1 then do: t-chg.nam = "Наименование/ФИО отправителя денег/товаров". t-chg.cod = "23". end.
        if s = 2 then do: t-chg.nam = "Страна отправителя денег/товара". t-chg.cod = "11". end.
        if s = 3 then do: t-chg.nam = "Наименование/ФИО получателя денег/товаров". t-chg.cod = "24". end.
        if s = 4 then do: t-chg.nam = "Страна бенефициара". t-chg.cod = "12". end.
        if s = 5 then do: t-chg.nam = "Дата платежа/исполнения обязательств". t-chg.cod = "13". end.
        if s = 6 then do: t-chg.nam = "Сумма платежа/обязательств". t-chg.cod = "14". end.
        if s = 7 then do: t-chg.nam = "Валюта платежа". t-chg.cod = "15". end.
        if s = 8 then do: t-chg.nam = "Способ расчетов". t-chg.cod = "16". end.
        if s = 9 then do: t-chg.nam = "Признак платежа - исходящий/входящий". t-chg.cod = "17". end.
        if s = 10 then do: t-chg.nam = "Примечание". t-chg.cod = "22". end.
    end.
end.
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
on help of vcdocs.info[4] in frame vcdndocs,frame country do:
    run h-partner.
    vcdocs.info[4] = return-value.
    displ vcdocs.info[4] with frame vcdndocs.
    displ vcdocs.info[4] with frame country.
end.

on help of vcdocs.kod14  in frame vcdndocs do:
    def var v-forms as char.
    def var v-selp as integer.
    def var i as integer.
    find current vccontrs no-lock.
    if v-forms = '' then do:
        do i = 1 to num-entries(vccontrs.ctformrs):
            find codfr where codfr.codfr = 'vcfpay' and codfr.code = entry(i,vccontrs.ctformrs) no-lock no-error.
            if v-forms <> '' then v-forms = v-forms + '|'.
            v-forms = v-forms + codfr.code + " " + codfr.name[1].
        end.
    end.
    run sel2 (' ФОРМА РАСЧЕТА ', v-forms, output v-selp).
    if v-selp <> 0 then vcdocs.kod14  = entry(1,entry(v-selp,v-forms,'|'),' ').
    displ vcdocs.kod14  with frame vcdndocs.
end.

on help of vcdocs.opertype in frame vcdndocs do:
    if g-today - vcdocs.rdt > 180 then do:
        message "Превышение срока исправления ранее направленной информации" view-as alert-box information buttons ok.
        leave.
    end.

    v-s = 0.
    for each t-chg no-lock:
        if v-plreas <> "" then v-plreas = v-plreas + "|".
        v-plreas = v-plreas + t-chg.nam.
        v-s = v-s + 1.
    end.
    v-sel = "".
    run sel_mt2("Insert - выбор изменненной графы,Delete - отменить выбор",v-plreas,vcdocs.docs,v-s,output v-sel).
    if v-sel <> "" then do:
        if lookup('1',v-sel) > 0 then do: v-cod = "". run Fchg("1",output v-cod). run Cdoc(v-cod). end.
        if lookup('2',v-sel) > 0 then do: v-cod = "". run Fchg("2",output v-cod). run Cdoc(v-cod). end.
        if lookup('3',v-sel) > 0 then do: v-cod = "". run Fchg("3",output v-cod). run Cdoc(v-cod). end.
        if lookup('4',v-sel) > 0 then do: v-cod = "". run Fchg("4",output v-cod). run Cdoc(v-cod). end.
        if lookup('5',v-sel) > 0 then do: v-cod = "". run Fchg("5",output v-cod). run Cdoc(v-cod). end.
        if lookup('6',v-sel) > 0 then do: v-cod = "". run Fchg("6",output v-cod). run Cdoc(v-cod). end.
        if lookup('7',v-sel) > 0 then do: v-cod = "". run Fchg("7",output v-cod). run Cdoc(v-cod). end.
        if lookup('8',v-sel) > 0 then do: v-cod = "". run Fchg("8",output v-cod). run Cdoc(v-cod). end.
        if lookup('9',v-sel) > 0 then do: v-cod = "". run Fchg("9",output v-cod). run Cdoc(v-cod). end.
        if lookup('10',v-sel) > 0 then do: v-cod = "". run Fchg("10",output v-cod). run Cdoc(v-cod). end.
    end.
end.
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

procedure Cdoc:
    def input parameter cod as char.

    if not lookup(cod,vcdocs.info2[1]) > 0 then do:
        if vcdocs.info2[1] <> "" then vcdocs.info2[1] = vcdocs.info2[1] + ',' + cod.
        else vcdocs.info2[1] = cod.
    end.
end procedure.

procedure Fchg:
    def input parameter sel as char.
    def output parameter cod as char.

    find t-chg where t-chg.k = inte(sel) no-lock no-error.
    if avail t-chg then cod = t-chg.cod.
end procedure.

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
