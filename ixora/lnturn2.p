/* lnturn2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Динамика оборотов заемщиков в периодах
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        lnturn.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        02/09/2004 madiar
 * CHANGES
        03/09/2004 madiar - изменил расчет оборотов
        02/12/2004 madiar - изменил расчет дебетовых оборотов по ссудным счетам
        03/12/2004 madiar - исправил ошибку при расчете дебетовых оборотов по ссудным счетам
        02/09/2005 madiar - учет выдач кредитов в валюте
*/

def input parameter dat as date.

def shared temp-table wrk
  field bank        as   char
  field cif         like txb.lon.cif
  field klname      as   char
  field lon         like txb.lon.lon
  field crc         like txb.lon.crc
  field ostatok     as   deci
  field rdt         like txb.lon.rdt
  field duedt       like txb.lon.duedt
  field prem        like txb.lon.prem
  field turnover    as   deci extent 6
  index ind is primary bank cif.

def buffer b-lon for txb.lon.
def var clc as logi.
def var b-turn as deci extent 6.

def var i as int.
def var mesa as int.
def var bilance as decimal.
def var bdat1 as date.
def var bdat2 as date.
def var v-found as logical.

find first txb.cmp no-lock no-error.

mesa = 0.
for each txb.lon no-lock break by txb.lon.cif:
   if first-of(txb.lon.cif) then clc = yes.
   if txb.lon.dam[1] = 0 then next.
   /* Для ускорения формирования отчета пропускаем все кредиты с 3-ей и 4-ой схемами */
   if txb.lon.plan = 3 or txb.lon.plan = 5 then next.
   /* отчет только по юр. лицам */
   find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
   find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnsts' no-lock.
   if txb.sub-cod.ccode = '1' then next.
   
   run lon_txb2 (txb.lon.lon, dat - 1, output bilance). /* остаток ОД */
   if bilance <= 0 then next.
   
   create wrk.
   wrk.bank = txb.cmp.name.
   wrk.cif = txb.cif.cif.
   wrk.klname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
   wrk.lon = txb.lon.lon.
   wrk.crc = txb.lon.crc.
   wrk.ostatok = bilance.
   wrk.rdt = txb.lon.rdt.
   wrk.duedt = txb.lon.duedt.
   wrk.prem = txb.lon.prem.
   
   if clc then do:
   
   b-turn = 0.
   bdat1 = date(month(dat),1,year(dat)).
   do i = 6 to 1 by -1:
     
     bdat2 = bdat1 - 1.
     bdat1 = date(month(bdat2),1,year(bdat2)).
     
     /*for each txb.lgr where txb.lgr.led = "DDA" or txb.lgr.led = "SAV" no-lock,
         each txb.aaa of txb.lgr where txb.aaa.cif = wrk.cif and txb.aaa.crc = 1 no-lock.
       for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl and txb.jl.jdt >= bdat1 and txb.jl.jdt <= bdat2 no-lock use-index acc:
           if txb.jl.dc = 'C' then do:
              find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
              if avail txb.jh then 
                if txb.jh.ref begins 'RMZ' then wrk.turnover[i] = wrk.turnover[i] + jl.cam.
           end.
       end.
     end.*/
     
     for each txb.aaa where txb.aaa.cif = wrk.cif and txb.aaa.crc = 1 no-lock:
       if txb.aaa.lgr begins '5' then next.
       for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl and txb.jl.jdt >= bdat1 and txb.jl.jdt <= bdat2 no-lock.
         if not (txb.jl.crc = 1 and (txb.jl.lev = 1 or txb.jl.lev = 2)) then next.
         accumulate txb.jl.cam (TOTAL).
       end.
       b-turn[i] = b-turn[i] + accum total txb.jl.cam.
     end.
     
     /*
     for each b-lon where b-lon.cif = wrk.cif no-lock.
       for each txb.jl where txb.jl.acc = b-lon.lon and txb.jl.gl = b-lon.gl and txb.jl.jdt >= bdat1 and txb.jl.jdt <= bdat2 no-lock.
         if not (txb.jl.crc = 1 and (txb.jl.lev = 1 or txb.jl.lev = 2)) then next.
         accumulate txb.jl.dam (TOTAL).
       end.
       b-turn[i] = b-turn[i] - accum total txb.jl.dam.
     end.
     */
     for each b-lon where b-lon.cif = wrk.cif no-lock:
        for each txb.lnscg where txb.lnscg.lng = b-lon.lon and txb.lnscg.stdat >= bdat1 and txb.lnscg.stdat <= bdat2 no-lock:
          v-found = no.
          if txb.lnscg.jh > 0 then do:
            if b-lon.crc = 1 then b-turn[i] = b-turn[i] - txb.lnscg.paid.
            else do:
              find last txb.crchis where txb.crchis.crc = b-lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
              for each txb.aaa where txb.aaa.cif = wrk.cif and txb.aaa.crc = 1 no-lock:
                for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl and txb.jl.jdt = txb.lnscg.stdat no-lock:
                  if txb.jl.dc <> 'C' then next.
                  if absolute(txb.jl.cam - txb.lnscg.paid * txb.crchis.rate[1]) < 0.02 then do:
                    v-found = yes.
                    b-turn[i] = b-turn[i] - txb.jl.cam.
                    /*
                    displ b-lon.cif b-lon.lon txb.aaa.aaa txb.jl.jh.
                    pause.
                    */
                    leave.
                  end.
                  if v-found then leave.
                end. /* for each txb.jl */
                if v-found then leave.
              end. /* for each txb.aaa */
            end.
          end. /* if txb.lnscg.jh > 0 */
        end. /* for each txb.lnscg */
     end. /* for each b-lon */
     
   end. /* do i = 1 to 6 */
   
   end. /* if clc */
   
   do i = 1 to 6:
     wrk.turnover[i] = b-turn[i].
   end.
   
   mesa = mesa + 1.
   /*if (mesa / 5) - integer (mesa / 5) = 0 then do:*/
      hide message no-pause.
      message txb.cmp.name + ': обработано ' + string(mesa) + ' кредитов'.
   /*end.*/
   
end. /* for each txb.lon */

