/* pkrefin.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Процедура для определения, подходит ли клиент для рефинансирования
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
        13/10/2008 madiyar - подправил расчет суммы нового кредита, отказ при рефинансировании кредита коммерсанту
*/

{global.i}

define input parameter v-rnn as char no-undo.
define input parameter v-lon as char no-undo.
define input parameter v-ln_skip as integer no-undo.
define output parameter v-res as integer no-undo init 2. /* статус; 0 - подходит для рефинансирования, 1 - не подходит по просрочкам, 2 - не подходит */
define output parameter v-sum as deci no-undo init 0. /* сумма рефинансирования */
define output parameter v-numpr as integer no-undo. /* количество просрочек */
define output parameter v-maxpr as integer no-undo. /* максимальная просрочка */

def var balance as deci no-undo.
def var v-respr as integer no-undo.
def var v-lnlast as integer no-undo.

find first lon where lon.lon = v-lon no-lock no-error.
if avail lon then do:
  if lon.plan = 4 then return. /* возврат с отказом - кредиты коммерсантам не рефинансируем */
  find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
  find next lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
  find next lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
  if not avail lnsch then return. /* возврат с отказом */
  if g-today < lnsch.stdat + 1 then return. /* прошло менее 3-х месяцев с момента выдачи рефинансируемого кредита - возврат с отказом */
  run lonbal("lon",lon.lon,g-today,"7,9,16,13,14,30",yes,output balance).
  if balance > 0 then return. /* имеется текущая просрочка - возврат с отказом */
  run lonbalcrc("lon",lon.lon,g-today,"1,7,13",yes,lon.crc,output balance).
  if balance / lon.opnamt * 100 > 70 then return. /* погашено менее 30% ОД (остаток более 70%) - возврат с отказом */
  else do:
    run pkdiscount(v-rnn, v-ln_skip, no, output v-respr, output v-numpr, output v-maxpr, output v-lnlast).
    v-res = 1.
    if v-numpr = 0 and lon.opnamt <= 150000 then v-sum = lon.opnamt * 2.
    else
    if lon.opnamt <= 300000 then v-sum = lon.opnamt * 1.5.
    else
    if lon.opnamt <= 500000 then v-sum = lon.opnamt * 1.3.
    else
    if lon.opnamt <= 2400000 then v-sum = lon.opnamt * 1.25.
    else v-sum = 3000000.
    /* анализ просрочек */
    /*
    просрочки до 5 дней - без ограничения
    от 6 до 10 - не более 5 раз
    от 11 до 15 - не более 3 раз
    от 16 до 20 - не более 2 раз
    от 21 до 25 - не более 1 раза
    от 6 до 10 - не более 5 раз
    */
    if v-maxpr > 25 then return. /* возврат с отказом по просрочкам */
    if v-maxpr > 20 and v-numpr > 1 then return. /* возврат с отказом по просрочкам */
    if v-maxpr > 15 and v-numpr > 2 then return. /* возврат с отказом по просрочкам */
    if v-maxpr > 10 and v-numpr > 3 then return. /* возврат с отказом по просрочкам */
    if v-maxpr > 5 and v-numpr > 5 then return. /* возврат с отказом по просрочкам */
    
    v-res = 0.
  end.
end.

