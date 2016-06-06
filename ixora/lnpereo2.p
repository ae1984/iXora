/* lnpereo2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Переоценка кредитного портфеля
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
        25/02/2005 madiyar
 * CHANGES
        28/02/2005 madiyar - забыл про просроченный ОД
        10/06/2008 madiyar - код валюты 11 -> 3
*/

define input parameter dt1 as date.
define input parameter dt2 as date.

define shared temp-table wrk
  field dt as date
  field sum_usd as deci extent 3
  field sum_eur as deci extent 3
  index idx is primary dt.

define shared var g-today as date.

function myglday returns decimal (input v-gl as integer, input v-crc as integer, input v-dt as date).
  def var v-bal as deci.
  v-bal = 0.
  find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = v-crc and txb.glday.gdt < v-dt no-lock no-error.
  if avail txb.glday then v-bal = txb.glday.bal.
  return v-bal.
end.

def var cdt as date.

do cdt = dt1 to dt2:
  
  /*message string(cdt, "99/99/9999") + " " + string(dt1, "99/99/9999") + " " string(dt2, "99/99/9999") view-as alert-box buttons ok.*/
  
  find first txb.cls where txb.cls.whn = cdt and txb.cls.del no-lock no-error.
  if avail txb.cls then do:  
    find first wrk where wrk.dt = cdt no-error.
    if not avail wrk then do:
      create wrk.
      wrk.dt = cdt.
      if cdt = g-today then do:
        find first txb.crc where txb.crc.crc = 2 no-lock no-error.
        wrk.sum_usd[1] = txb.crc.rate[1].
        find first txb.crc where txb.crc.crc = 3 no-lock no-error.
        wrk.sum_eur[1] = txb.crc.rate[1].
      end.
      else do:
        find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.regdt <= cdt no-lock no-error.
        wrk.sum_usd[1] = txb.crchis.rate[1].
        find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.regdt <= cdt no-lock no-error.
        wrk.sum_eur[1] = txb.crchis.rate[1].
      end.
    end.
    
    wrk.sum_usd[2] = wrk.sum_usd[2] + myglday(141110,2,cdt) + myglday(141710,2,cdt). /* юр USD */
    wrk.sum_usd[2] = wrk.sum_usd[2] + myglday(142410,2,cdt). /* проср юр USD */
    wrk.sum_usd[3] = wrk.sum_usd[3] + myglday(141120,2,cdt) + myglday(141720,2,cdt). /* физ USD */
    wrk.sum_usd[3] = wrk.sum_usd[3] + myglday(142420,2,cdt). /* проср физ USD */
    wrk.sum_eur[2] = wrk.sum_eur[2] + myglday(141110,3,cdt) + myglday(141710,3,cdt). /* юр EUR */
    wrk.sum_eur[2] = wrk.sum_eur[2] + myglday(142410,3,cdt). /* проср юр EUR */
    wrk.sum_eur[3] = wrk.sum_eur[3] + myglday(141120,3,cdt) + myglday(141720,3,cdt). /* физ EUR */
    wrk.sum_eur[3] = wrk.sum_eur[3] + myglday(142420,3,cdt). /* проср физ EUR */
  end. /* if avail txb.cls */
  
end. /* do dt */
