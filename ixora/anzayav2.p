/* anzayav2.p
 * MODULE
        Потребительские Кредиты - Сравнительный анализ обработанных заявок клиентов по программе "Быстрые деньги" за период
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
        07/12/2004 madiyar
 * CHANGES
        23/05/2005 madiyar - пропускаем интернет-анкеты в TXB00
        01/08/2005 madiyar - добавил данных для проверки
        28/10/2005 madiyar - {pk0.i}
        27/01/2006 madiyar - разброс по РКО по суммам и выданным кредитам - не по cwho, а по rwho
        30/03/2006 madiyar - интернет-анкеты и казпочта - как отдельные РКО
        30/05/2006 madiyar - в астане тоже разбрасываем по рко-шкам; no-undo
        13/06/2006 madiyar - в атырау тоже разбрасываем по рко-шкам, список филиалов с рко-шками в txb-rko
        04/08/2006 madiyar - актобе, рко-шки
        25/08/2006 madiyar - уральск, рко-шки
        28/09/2006 madiyar - раскладка по казпочтовым РУПСам
*/

{pk0.i}

def input parameter dat1 as date no-undo.
def input parameter dat2 as date no-undo.

def shared var anksts as integer no-undo extent 100.
def shared var txb-rko as char no-undo.

def shared temp-table wrk no-undo
   field bank as char
   field bankn as char
   field depart as int
   field departn as char
   field accepted as int
   field issued_f as int
   field issued as int extent 2
   field issued_sum as deci extent 2
   field rejected as int
   field disclaimed as int
   field aux as int extent 4
   field kp_point as char
   index main is primary bank depart kp_point.

def var bag as integer no-undo extent 4.
def var addi as integer no-undo extent 4.
def var vyd_sum as deci no-undo extent 2.
def var v-dep as integer no-undo.
def var v-kp_point as char no-undo.

define var s-ourbank as char no-undo init "".
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if not avail txb.sysc or txb.sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
end.
else s-ourbank = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
hide message no-pause.
message ' Обработка ' + txb.cmp.name + ' '.

vyd_sum = 0.
if lookup(s-ourbank,txb-rko) = 0 then do:
   bag = 0. addi = 0.
   for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and
            pkanketa.rdt >= dat1 and pkanketa.rdt <= dat2 no-lock.
       
       bag[1] = bag[1] + 1.
       if pkanketa.sts = "00" then bag[3] = bag[3] + 1.
       if pkanketa.sts = "15" then bag[4] = bag[4] + 1.
       if pkanketa.sts = "99" then addi[2] = addi[2] + 1. /* выдано из рассмотренных */
       
   end. /* for each pkanketa */
   
   for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and
            pkanketa.docdt >= dat1 and pkanketa.docdt <= dat2 no-lock.
       
       if pkanketa.lon <> '' then do:
          bag[2] = bag[2] + 1.
          vyd_sum[1] = vyd_sum[1] + pkanketa.summa.
          if pkanketa.rdt >= dat1 and pkanketa.rdt <= dat2 then do:
            addi[1] = addi[1] + 1. /* сколько выданных из рассмотренных именно в этом месяце */
            vyd_sum[2] = vyd_sum[2] + pkanketa.summa.
          end.
          
       end.
       
   end. /* for each pkanketa */
   
   create wrk.
   wrk.bank = s-ourbank.
   wrk.bankn = txb.cmp.name.
   wrk.departn = txb.cmp.name.
   wrk.accepted = bag[1].
   wrk.issued_f = addi[2].
   wrk.issued[1] = bag[2].
   wrk.issued_sum[1] = vyd_sum[1].
   wrk.issued[2] = addi[1].
   wrk.issued_sum[2] = vyd_sum[2].
   wrk.rejected = bag[3].
   wrk.disclaimed = bag[4].
end.
else do:
   
   for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and
            pkanketa.rdt >= dat1 and pkanketa.rdt <= dat2 no-lock:
     
     v-dep = 0. v-kp_point = ''.
     if pkanketa.rwho = "i-net" then v-dep = -1.
     else if pkanketa.id_org = "kazpost" then do:
       v-dep = -2.
       find first extuser where extuser.login = pkanketa.rwho no-lock no-error.
       if avail extuser then v-kp_point = extuser.id_dept. else v-kp_point = "unknown".
     end.
     else do:
       find last txb.ofchis where txb.ofchis.ofc = pkanketa.rwho and txb.ofchis.regdt <= pkanketa.rdt use-index ofchis no-lock no-error.
       if not avail txb.ofchis then
       find first txb.ofchis where txb.ofchis.ofc = pkanketa.rwho and txb.ofchis.regdt <= pkanketa.rdt use-index ofchis no-lock no-error.
       if avail txb.ofchis then v-dep = txb.ofchis.depart.
     end.
     
     find first wrk where wrk.bank = s-ourbank and wrk.depart = v-dep and wrk.kp_point = v-kp_point no-error.
     if not avail wrk then do:
         create wrk.
         wrk.bank = s-ourbank.
         wrk.bankn = txb.cmp.name.
         wrk.depart = v-dep.
         wrk.kp_point = v-kp_point.
         if v-dep >= 0 then do:
           find first txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.
           if avail txb.ppoint then wrk.departn = txb.ppoint.name.
         end.
         else do:
           if v-dep = -1 then wrk.departn = "internet".
           else if v-dep = -2 then wrk.departn = "kazpost".
         end.
     end.
     
     /* accepted */
     wrk.accepted = wrk.accepted + 1.
     
     /* rejected */
     if pkanketa.sts = "00" then wrk.rejected = wrk.rejected + 1.
     
     /* disclaimed */
     if pkanketa.sts = "15" then wrk.disclaimed = wrk.disclaimed + 1.
     
     /* выдано из рассмотренных */
     if pkanketa.sts = "99" then wrk.issued_f = wrk.issued_f + 1.
     
     anksts[integer(pkanketa.sts) + 1] = anksts[integer(pkanketa.sts) + 1] + 1.
     
   end. /* for each pkanketa */
   
   for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and
            pkanketa.docdt >= dat1 and pkanketa.docdt <= dat2 no-lock.
     
     v-dep = 0. v-kp_point = ''.
     if pkanketa.rwho = "i-net" then v-dep = -1.
     else if pkanketa.id_org = "kazpost" then do:
       v-dep = -2.
       find first extuser where extuser.login = pkanketa.rwho no-lock no-error.
       if avail extuser then v-kp_point = extuser.id_dept. else v-kp_point = "unknown".
     end.
     else do:
       find last txb.ofchis where txb.ofchis.ofc = pkanketa.rwho and txb.ofchis.regdt <= pkanketa.rdt use-index ofchis no-lock no-error.
       if not avail txb.ofchis then
       find first txb.ofchis where txb.ofchis.ofc = pkanketa.rwho and txb.ofchis.regdt <= pkanketa.rdt use-index ofchis no-lock no-error.
       if avail txb.ofchis then v-dep = txb.ofchis.depart.
     end.
     
     /* issued */
     if pkanketa.lon <> '' then do:
          find first wrk where wrk.bank = s-ourbank and wrk.depart = v-dep and wrk.kp_point = v-kp_point no-error.
          if not avail wrk then do:
            create wrk.
            wrk.bank = s-ourbank.
            wrk.bankn = txb.cmp.name.
            wrk.depart = v-dep.
            wrk.kp_point = v-kp_point.
            if v-dep >= 0 then do:
              find first txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.
              if avail txb.ppoint then wrk.departn = txb.ppoint.name.
            end.
            else do:
              if v-dep = -1 then wrk.departn = "internet".
              else if v-dep = -2 then wrk.departn = "kazpost".
            end.
          end.
          wrk.issued[1] = wrk.issued[1] + 1.
          wrk.issued_sum[1] = wrk.issued_sum[1] + pkanketa.summa.
          if pkanketa.rdt >= dat1 and pkanketa.rdt <= dat2 then do:
            wrk.issued[2] = wrk.issued[2] + 1. /* сколько выданных из рассмотренных именно в этом месяце */
            wrk.issued_sum[2] = wrk.issued_sum[2] + pkanketa.summa.
          end.
     end.
      
   end. /* for each pkanketa */
   
end.
