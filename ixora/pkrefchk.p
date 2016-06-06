/* pkrefchk.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Проверка на соответсвие клиента условиям программы рефинансирования по БД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        12/05/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        12/09/2006 madiyar - подправил расчет даты возможного рефинансирования
        14/09/2006 madiyar - еще раз подправил расчет даты возможного рефинансирования
        13/10/2008 madiyar - подправил расчет суммы нового кредита
*/

{global.i}

def var v-cif like cif.cif no-undo.
def var v-rnn like cif.jss no-undo.
def var v-fio as char no-undo format "x(60)".
def var v-iik like aaa.aaa no-undo.
def var v-sum_aaa as deci no-undo.
def var v-dog as char no-undo format "x(10)".
def var v-crc as char no-undo format "xxx".
def var v-lon like lon.lon no-undo.
def var v-opnamt as deci no-undo.
def var v-od as deci no-undo.
def var v-bal as deci no-undo.
def var v-perc as deci no-undo.
def var v-prosr as deci no-undo.

def var v-respr as integer no-undo.
def var v-numpr as integer no-undo.
def var v-maxpr as integer no-undo.
def var v-lnlast as integer no-undo.

def var v-resprdes as char no-undo.
def var v-ok as logical no-undo.
def var v-refdat as date no-undo.
def var v-refsum as deci no-undo.
def var v-dat as date no-undo.

form
  v-cif label "Клиент........" validate (can-find(cif where cif.cif = v-cif), "Нет такого клиента!") help "Код клиента; F2-код; F4-вых; F1-далее"
  "                  " v-rnn label "РНН" skip
  v-fio label "ФИО..........." format "x(61)" skip(1)
  v-iik label "ИИК..........."
  v-sum_aaa label "Тек.остаток..." format ">>>,>>>,>>>,>>>,>>9.99" at 41 skip(1)
  v-dog label "Договор......." format "x(23)"
  v-crc label "Валюта........" at 41 skip
  v-lon label "Ссудный счет.."  
  v-opnamt label "Сумма займа..." format ">>>,>>>,>>>,>>>,>>9.99" at 41 skip
  v-od label "Остаток ОД...." format ">>>,>>>,>>>,>>>,>>9.99"
  v-perc label "% от выд.суммы" format ">>9.99" at 41 skip
  v-prosr label "Задолж(KZT)..." format ">>>,>>>,>>>,>>>,>>9.99" skip(1)
  
  v-numpr label "Кол.просроч..." format ">>>,>>9"
  v-maxpr label "Макс.проср(дн)" format ">>>,>>9" at 41 skip(1)
  
  v-resprdes no-label format "x(70)" skip
  v-refdat label "Дата возможного рефинансирования" format "99/99/9999" skip
  v-refsum label "Сумма рефинансирования" format ">>>,>>>,>>>,>>>,>>9.99" skip
with side-label no-hide /*4 columns*/ column 1 /*no-box*/ row 3 frame pkcas.

update v-cif with frame pkcas.

v-lon = ''.
for each lon where lon.cif = v-cif no-lock:
  if lon.opnamt <= 0 then next.
  if not(lon.grp = 90 or lon.grp = 92) then next.
  run lonbal('lon',lon.lon,g-today,"1,7,2,9,16,4,5",yes,output v-od).
  run lonbal('lon',lon.lon,g-today,"13,14,30",yes,output v-bal).
  if v-od + v-bal <= 0 then next.
  v-lon = lon.lon. v-iik = lon.aaa. leave.
end.

if v-lon = '' then do:
  message "У данного клиента нет действующих кредитов БД" view-as alert-box buttons ok title " Внимание! ".
  return.
end.

find first cif where cif.cif = v-cif no-lock no-error.
if avail cif then do:
  v-fio = trim(cif.name).
  v-rnn = cif.jss.
end.

find first aaa where aaa.aaa = v-iik no-lock no-error.
if avail aaa then do:
  run lonbalcrc('cif',aaa.aaa,g-today,"1",yes,aaa.crc,output v-sum_aaa).
  v-sum_aaa = - v-sum_aaa.
end.

find first lon where lon.lon = v-lon no-lock no-error.
if avail lon then do:
  v-opnamt = lon.opnamt.
  run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-od).
  v-perc = v-od / v-opnamt * 100.
  run lonbalcrc('lon',lon.lon,g-today,"7,9,13,14,4,5",yes,lon.crc,output v-prosr).
  find first crc where crc.crc = lon.crc no-lock no-error.
  if avail crc then do:
    v-prosr = v-prosr * crc.rate[1].
    v-crc = crc.code.
  end.
  run lonbalcrc('lon',lon.lon,g-today,"16,30",yes,1,output v-bal).
  v-prosr = v-prosr + v-bal.
  find first loncon where loncon.lon = lon.lon no-lock no-error.
  if avail loncon then v-dog = loncon.lcnt.
end.


run pkdiscount(v-rnn, -1, no, output v-respr, output v-numpr, output v-maxpr, output v-lnlast).
/*
run pkrefin(v-rnn, v-lon, -1, output v-respr, output v-sum, output v-numpr, output v-maxpr).
*/


/* анализ просрочек */
v-ok = yes.
/*
просрочки до 5 дней - без ограничения
от 6 до 10 - не более 5 раз
от 11 до 15 - не более 3 раз
от 16 до 20 - не более 2 раз
от 21 до 25 - не более 1 раза
от 6 до 10 - не более 5 раз
*/
if v-maxpr > 25 then v-ok = no. /* возврат с отказом по просрочкам */
if v-maxpr > 20 and v-numpr > 1 then v-ok = no. /* возврат с отказом по просрочкам */
if v-maxpr > 15 and v-numpr > 2 then v-ok = no. /* возврат с отказом по просрочкам */
if v-maxpr > 10 and v-numpr > 3 then v-ok = no. /* возврат с отказом по просрочкам */
if v-maxpr > 5 and v-numpr > 5 then v-ok = no. /* возврат с отказом по просрочкам */

if v-ok then do:
  /* расчет суммы */
  if v-numpr = 0 and lon.opnamt <= 150000 then v-refsum = lon.opnamt * 2.
  else
  if lon.opnamt <= 300000 then v-refsum = lon.opnamt * 1.5.
  else
  if lon.opnamt <= 500000 then v-refsum = lon.opnamt * 1.3.
  else
  if lon.opnamt <= 2400000 then v-refsum = lon.opnamt * 1.25.
  else v-refsum = 3000000.
  
  v-refdat = ?.
  find first lnsch where lnsch.lnn = v-lon and lnsch.f0 > 0 no-lock no-error.
  find next lnsch where lnsch.lnn = v-lon and lnsch.f0 > 0 no-lock no-error.
  find next lnsch where lnsch.lnn = v-lon and lnsch.f0 > 0 no-lock no-error.
  if not avail lnsch then do:
    message " Ошибка при анализе графика погашения! " view-as alert-box error.
    return.
  end.
  if lnsch.stdat + 1 > g-today then v-refdat = lnsch.stdat.
  
  if v-perc > 70 then do:
    v-bal = v-opnamt.
    for each lnsch where lnsch.lnn = v-lon and lnsch.f0 > 0 no-lock:
      v-bal = v-bal - lnsch.stval.
      if v-bal / v-opnamt * 100 <= 70 then do:
        if v-refdat = ? or (v-refdat <> ? and lnsch.stdat > v-refdat) then v-refdat = lnsch.stdat.
        leave.
      end.
    end.
  end.
end. /* if v-ok */

v-refdat = v-refdat + 1.

if not(v-ok) then v-resprdes = "Рефинансирование невозможно (просрочки)".
else do:
  if v-refdat <= g-today then v-resprdes = "Клиент удовлетворяет условиям рефинансирования".
  else v-resprdes = "Рефинансирование возможно начиная с указанной даты".
end.

displ v-cif v-rnn v-fio v-iik v-sum_aaa v-dog v-crc v-lon v-opnamt v-od v-perc v-prosr v-numpr v-maxpr v-resprdes v-refdat v-refsum with frame pkcas.
pause.

