/*  pfurlist.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Процедура регистрации пенсионных платежей юр лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        30.06.2005 marinav
 * CHANGES
        26.09.2005 dpuchkov - добавил возможность удаление специнструкций по комиссиям если есть ограничение в п 1.6.2.9 (Т.З.ї131)
        10/02/2010 galina - расширила на весь экран brose b1
        01.02.2011 marinav - изменения в связи с переходом на БИН/ИИН
        02/05/2012 evseev - логирование значения aaa.hbal
        24.07.2012 evseev - ТЗ-1233
        27.08.2012 evseev - иин/бин
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}


def var op_kod as char.
def var s-aaa as char.

def shared var g-today as date.
def shared var g-ofc as character.
def var alldoc as logical.
alldoc = false.
def var rid as rowid.
def stream m-out.
def var ofc_name like ofc.name.
def var dat as date.
def var v-sel as integer .
def var s_rid as char.
def var s_payment as char.
def var d_whole_sum as decimal init 0.
define variable docdnum as int.
define variable docuid as char.
define variable docdate as date.

{aas2his.i &db = "bank"}

dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

DEFINE QUERY q1 FOR pay_ur.
def browse b1
    query q1 no-lock
    display pay_ur.whn label "Дата" format "99/99/99"
        pay_ur.nom label "No" format ">>>>>>9"
        pay_ur.rnn  label "ИИН/БИН" format "999999999999" /*"x(12)"*/
        pay_ur.name label "Ф.И.О" format "x(23)"
        /*cod  label "К" format '>>9'*/
        pay_ur.sum format ">>>>>>>>>>>9.99" label "Сумма"
        pay_ur.com format ">>>>>>>>>>>9.99" label "Ком"
        pay_ur.sum + pay_ur.com format ">>>>>>>>>>>9.99" label "Всего"
        with 25 down title "Платежи в пенсионный фонд" no-labels.

DEFINE BUTTON bedt LABEL "См./Изм.".
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bdel LABEL "Удал.".
DEFINE BUTTON bacc LABEL "Итог".

def frame f1 b1 skip bedt bnew bdel bacc with width 110.

ON CHOOSE OF bedt IN FRAME f1 do:
   run pfurinput (false, rowid(pay_ur), dat, v-sel).
   b1:refresh().
end.

ON CHOOSE OF bnew IN FRAME f1 do:
   run pfurinput (true, rowid(pay_ur),dat, v-sel).
   if return-value <> "" then do:
      open query q1 for each pay_ur where pay_ur.txb = seltxb and pay_ur.pf_soc = v-sel and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank")) and pay_ur.del = ? no-lock by pay_ur.nom descending.
      get last q1.
      reposition q1 to rowid to-rowid(return-value) no-error.
      b1:refresh().
   end.
end.

ON CHOOSE OF bdel IN FRAME f1 do:
   MESSAGE "Удалить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE choice as logical.
   if choice = true then do:
      rid = rowid(pay_ur).
      FIND pay_ur WHERE ROWID(pay_ur) = rid EXCLUSIVE-LOCK.
      if not avail pay_ur then leave.
      message skip " Не забудьте вернуть комиссию! " skip(1) view-as alert-box button ok title " ВНИМАНИЕ ".
      find first aas where aas.aaa = pay_ur.acc and aas.ln = pay_ur.ln exclusive-lock no-error.
      if avail aas then do:
         aas.mn = substr(aas.mn,1,3) + "a9".
         aas.payee  = aas.payee + ' Удалили неверный платеж.'.
         op_kod = "D".
         s-aaa = aas.aaa.
         run aas2his.
         if aas.sic = 'HB' then do:
            find first aaa where aaa.aaa = aas.aaa exclusive-lock.
            if avail aaa then do:
               run savelog("aaahbal", "pfurlist ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
               aaa.hbal = aaa.hbal - aas.chkamt.
            end.
         end.
         delete aas.
      end.
      find first aas where aas.aaa = pay_ur.acc and aas.ln = integer(pay_ur.info[10]) exclusive-lock no-error.
      if avail aas then do:
         aas.mn = substr(aas.mn,1,3) + "a9".
         aas.payee  = aas.payee + ' Удалили неверный платеж.'.
         op_kod = "D".
         s-aaa = aas.aaa.
         run aas2his.
         if aas.sic = 'HB' then do:
            find first aaa where aaa.aaa = aas.aaa exclusive-lock.
            if avail aaa then do:
               run savelog("aaahbal", "pfurlist ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
               aaa.hbal = aaa.hbal - aas.chkamt.
            end.
         end.
         delete aas.
      end.
      delete pay_ur.
      RELEASE pay_ur.
      open query q1 for each pay_ur where pay_ur.txb = seltxb and pay_ur.pf_soc = v-sel and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank"))  and pay_ur.del = ? no-lock by pay_ur.nom descending.
      b1:refresh().
   end.
end.

ON CHOOSE OF bacc IN FRAME f1 do:
    rid = rowid(pay_ur).
    FOR each pay_ur where pay_ur.txb = seltxb and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank")) no-lock:
        ACCUMULATE pay_ur.sum (TOTAL COUNT).
    END.
    FOR each pay_ur where pay_ur.txb = seltxb and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank")) no-lock:
        ACCUMULATE pay_ur.com (TOTAL).
    END.
    FOR each pay_ur where pay_ur.txb = seltxb and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank")) no-lock:
        ACCUMULATE pay_ur.com + pay_ur.sum (TOTAL COUNT).
    END.
    totalt=(accum total pay_ur.sum).
    MESSAGE "Количество платежей: " (accum count pay_ur.sum) skip
        "Hа сумму: " totalt skip
        "Комиссия: " (accum total pay_ur.com) skip
        "Всего:    " (accum total pay_ur.com + pay_ur.sum) skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Платежи ПФ и др.компаний" .
    find pay_ur where rowid(pay_ur) = rid.
end.

run sel ("Платежи :", " 1. Пенсионные юр. лиц  | 2. Социальные юр. лиц  ").
v-sel = inte(return-value).

open query q1 for each pay_ur where pay_ur.txb = seltxb and pay_ur.pf_soc = v-sel and pay_ur.whn = dat and (alldoc or pay_ur.who = userid("bank"))  and pay_ur.del = ? no-lock by pay_ur.nom.
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.




