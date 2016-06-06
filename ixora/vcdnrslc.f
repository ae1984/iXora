/* vcdnrslc.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма просмотра и редактирования рег.свид-ва/лицензии
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        18.10.2002 nadejda
 * CHANGES
        29.09.2003 nadejda  - добавлены поля валюты, курса и признака состояния лицензии
        18.04.2008 galina - проверка типа контракта - если тип контракта 7, можно указать нулевую сумму
                            если тип контракта не равен 7, то сумма не может быть нулевой        
*/


def var v-dntypename as char.
def var v-nbcrc as integer.
def var v-nbcrckod as char.
def var v-sumdoccon as decimal.
def var v-stsname as char.
def buffer b-vcrslc for vcrslc.
def var msg-err as char.

{vc-crosscurs.i}

function chk-dndate returns logical (p-value as date).
 if p-value = ? then do: 
   msg-err = " Введите дату документа!". return false. end.
 if p-value < vccontrs.ctdate then do:
   msg-err = " Дата документа не может быть меньше даты контракта!". return false. end.
 if can-find(b-vcrslc where b-vcrslc.contract = s-contract and 
         b-vcrslc.dntype = vcrslc.dntype and b-vcrslc.dnnum = vcrslc.dnnum and 
         b-vcrslc.dndate = p-value and b-vcrslc.rslc <> vcrslc.rslc no-lock) then do:
    msg-err = " Уже есть документ с таким номером и датой по данному контракту!". return false. end.
  return true.
end.

function chk-dnnum returns logical (p-value as char).
  if p-value = "" then do:
    msg-err = " Введите номер документа!". return false. end.
  if can-find(b-vcrslc where b-vcrslc.contract = s-contract and 
         b-vcrslc.dntype = vcrslc.dntype and b-vcrslc.dnnum = p-value and 
         b-vcrslc.dndate = vcrslc.dndate and b-vcrslc.rslc <> vcrslc.rslc no-lock) then do:
    msg-err = " Уже есть документ с таким номером и датой по данному контракту!". return false. end.
  return true.
end.

function chk-crc returns logical (p-value as integer).
  def var v-curs as deci.

  find ncrc where ncrc.crc = p-value no-lock no-error.
  if not avail ncrc then do:
    msg-err = "Недопустимый код валюты!". return false. end.
/*
  if p-value <> vccontrs.ncrc and lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
    msg-err = "Выбранная валюта не является валютой контракта и не входит в список валют платежа!".
    return false.
  end.
*/
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find ncrc where ncrc.crc = p-value no-lock no-error.
  if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vcps.dndate then do:
    msg-err = "Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) + 
       " - заменена " + entry(1, ncrc.prefix) + " !".
    return false.
  end.

  return true. 
end.

function check-summ return logical(p-summ as decimal, p-type as char).
 if p-type = '7' then return true.
 else if p-summ = 0 then do:
   msg-err = "Сумма не может быть нулевой!".
   return false.
 end.
  return true.   
end.

form 
  vcrslc.dntype colon 12 format "xx" validate(vcrslc.dntype <> "" and vcrslc.dntype <> "msc" and
      can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = vcrslc.dntype and 
      codfr.name[5] = "d" no-lock),
      " Неверный тип документа !")
  v-dntypename colon 15 format "x(15)" no-label 
         vcrslc.rdt label "РЕГ." colon 39 vcrslc.rwho no-label colon 50 skip
         vcrslc.cdt label "АКЦ." colon 39 vcrslc.cwho no-label colon 50 skip
  vcrslc.dnnum colon 12 format "x(50)" label "НОМЕР" validate(chk-dnnum(vcrslc.dnnum), msg-err) skip
  vcrslc.dndate colon 12 validate(chk-dndate(vcrslc.dndate), msg-err)
  vcrslc.lastdate colon 39 
      help " Рег/свид - последняя дата контракта, лицензии - срок действия"
      validate(vcrslc.lastdate = ? or vcrslc.lastdate >= vcrslc.dndate, " Последняя дата не может быть меньше даты документа!") 
      skip
  vcrslc.ncrc colon 12 format ">>9" label "ВАЛЮТА" validate(chk-crc(vcrslc.ncrc), msg-err) 
       v-nbcrckod format "xxx" no-label colon 16
  vcrslc.sum colon 39 label "СУММА" validate(check-summ(vcrslc.sum, vccontrs.cttype), " Сумма должна быть больше 0!") skip
  vcrslc.cursdoc-con label "К ВАЛ.КОН." colon 12 format ">>>>>>>>>9.9999<<"
        validate(vcrslc.cursdoc-con > 0, "Курс не может быть нулевым!")
      v-sumdoccon format ">>>,>>>,>>>,>>>,>>9.99" label "В ВАЛ.КОН" colon 39 skip
  vcrslc.info[1] colon 12 label "РАБ/ЗАВЕРШ" format "x" help " Состояние лицензии: R - рабочая, Z - завершена" 
      validate (can-find(bookcod where bookcod.bookcod = "vclic" and bookcod.code = vcrslc.info[1] no-lock), 
                " Неверный признак состояния лицензии!")
      v-stsname colon 15 no-label format "x(30)"
  skip(4)
  with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcdnrslc.




