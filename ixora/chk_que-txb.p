/* chk_que-txb.p
 * MODULE
        проверка очередей на наличие зависших платежей
 * DESCRIPTION
        Описание
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
        12.06.2012 evseev
 * BASES
        COMM TXB
 * CHANGES
*/

def input  parameter v-paramin  as char.



def shared var s-errque as char no-undo.
def var v-nwt  as int no-undo.
def var i as int no-undo.
def var v-timeout as int no-undo.
def var v-des as char no-undo.
def var v-bnk as char no-undo.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-bnk = txb.sysc.chval. else v-bnk = "Банк не определён!".

for each txb.sts where txb.sts.nw > 0 no-lock.
  if txb.sts.nw + txb.sts.nf <> 0 then v-nwt = ( time - txb.sts.upd + (today - txb.sts.dupd ) * 86400 ) + txb.sts.nwt  / (txb.sts.nw + txb.sts.nf ). else v-nwt = 0 .
  /*v-timeout = 86399.*/
  v-timeout = 600.
  if num-entries(v-paramin) >= 2 then do:
     do i = 1 to num-entries(v-paramin):
        if entry(i,v-paramin) = trim(txb.sts.pid) then do:
           v-timeout = int(entry(i + 1,v-paramin)) no-error.
           /*message entry(i,v-paramin) " " entry(i + 1,v-paramin) "   " v-timeout " " v-nwt. pause.*/
        end.
     end.
  end.
  if v-nwt > v-timeout then do:
     if s-errque <> "" then s-errque = s-errque + "~n".
     find first txb.fproc where txb.fproc.pid = txb.sts.pid no-lock no-error.
     if avail txb.fproc then v-des = txb.fproc.des. else v-des = "".
     s-errque = s-errque + v-bnk + "   " + txb.sts.pid + "   " + string(txb.sts.nw) + "   " + string(v-nwt ,"HH:MM:SS") + "   " + string(v-nwt) + "   " + string(v-timeout) + "   " + v-des.
  end.
end.