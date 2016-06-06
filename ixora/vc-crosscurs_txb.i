/* vc-crosscurs.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        vc-crosscurs_txb.i Валютный контроль
   Функция вычисления кросс-курса валют на заданную дату 
   с внесением новых курсов в историю валют для базы TXB

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
        06.08.2008 galina
 * CHANGES
*/


procedure valid-curs.
  def input parameter p-crc as integer.
  def input parameter p-dt as date.
  def output parameter vp-c as decimal format ">>>>>>9.99<<<<".
  def var vp-rec as recid.
  def buffer b-his for txb.ncrchis.

  find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-dt 
     no-lock no-error. 
  /* валидность курса */
  /* если найден ненулевой курс на данную дату - хорошо */
  /* валюты с 1 по 12 и введено после 16/12/99 - хорошо */
  /* валюты после 15 и дата после записи с 0 - хорошо */
  if (avail txb.ncrchis and txb.ncrchis.rdt = p-dt and txb.ncrchis.rate[1] > 0) or
     (p-crc >=1 and p-crc <= 12 and avail txb.ncrchis and txb.ncrchis.whn >= 12/16/99) or
     (p-crc >= 15 and avail ncrchis and 
       can-find(first b-his where b-his.crc = p-crc and b-his.rate[1] = 0 and 
       b-his.rdt <= p-dt)) 
     then do:
    vp-c = txb.ncrchis.rate[1].
  end.
  else do:
    if avail txb.ncrchis then vp-c = txb.ncrchis.rate[1].
    find txb.ncrc where txb.ncrc.crc = p-crc no-lock no-error.

    /* запросить курс */
    message " Введите курс валюты " txb.ncrc.code " на " p-dt " " update vp-c.
    if vp-c < 0 then vp-c = 0.
    if vp-c > 0 then do transaction:
      if not avail txb.ncrchis or txb.ncrchis.rdt <> p-dt then do:
        /* создать запись в истории за этот день */
        create txb.ncrchis.
        assign txb.ncrchis.rdt = p-dt
               txb.ncrchis.crc = p-crc
               txb.ncrchis.des = ncrc.des
               txb.ncrchis.who = g-ofc
               txb.ncrchis.whn = today
               txb.ncrchis.sts = ncrc.sts
               txb.ncrchis.tim = time
               txb.ncrchis.stn = ncrc.stn
               txb.ncrchis.regdt = g-today
               txb.ncrchis.prefix = ncrc.prefix
               txb.ncrchis.code = ncrc.code
               txb.ncrchis.decpnt = ncrc.decpnt
               txb.ncrchis.rate[9] = ncrc.rate[9].
      end.
      vp-rec = recid(txb.ncrchis).
      find txb.ncrchis where vp-rec = recid(txb.ncrchis) exclusive-lock no-error. 
      txb.ncrchis.rate[1] = vp-c.
      release txb.ncrchis.
    end.
  end.
end.

function valid-euro returns logical (p-crc as integer, p-dt as date).
  /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
  find txb.ncrc where txb.ncrc.crc = p-crc no-lock no-error.
  if txb.ncrc.prefix <> "" and date(entry(2, txb.ncrc.prefix)) <= p-dt then do:
    message skip "Валюта " txb.ncrc.code " после " entry(2, txb.ncrc.prefix) " не действительна!" skip(1)
        "Выберите другую валюту !" skip view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return true.
  end.
  return false.
end.


procedure crosscurs.
  def input parameter p-crcdoc as integer. 
  def input parameter p-crcbase as integer.
  def input parameter p-cursdt as date.
  def output parameter vp-curs as deci. 
  def var vp-cursdoc as decimal.
  def var vp-cursbas as decimal.

  if p-crcdoc = p-crcbase then vp-curs = 1.
  else do: 
    if valid-euro(p-crcbase, p-cursdt) then do: vp-curs = 0. return. end.
    if valid-euro(p-crcdoc, p-cursdt) then do: vp-curs = 0. return. end.

    if p-crcbase = 1 then vp-cursbas = 1. 
    else do:
      run valid-curs(p-crcbase, p-cursdt, output vp-cursbas).
      if vp-cursbas = 0 then do:
        find txb.ncrc where txb.ncrc.crc = p-crcbase no-lock no-error.
        message skip "Требуется ввод курса валюты " txb.ncrc.code " на " p-cursdt " !" skip
             view-as alert-box button ok title " ВНИМАНИЕ ! ".
        return.
      end.
    end.

    if p-crcdoc = 1 then vp-cursdoc = 1. 
    else do:
      run valid-curs(p-crcdoc, p-cursdt, output vp-cursdoc).
      if vp-cursdoc = 0 then do:
        find txb.ncrc where txb.ncrc.crc = p-crcdoc no-lock no-error.
        message skip "Требуется ввод курса валюты " txb.ncrc.code " на " p-cursdt " !" skip
             view-as alert-box button ok title " ВНИМАНИЕ ! ".
        return.
      end.
    end.

    vp-curs = vp-cursbas / vp-cursdoc. /* vp-cursdoc / vp-cursbas. */
  end. 
end.



