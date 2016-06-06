/* pos2arp.p
 * MODULE
        Offline PragmaTX
 * DESCRIPTION
        Выдача наличных через POS (зачисление со счетов возмещений)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/05/05 kanat
 * CHANGES
        26/01/2006 marinav - зачисление платежей по Алмате
        30.01.2006 marinav - печать расходного ордера
        01.02.2012 lyubov - изменила символ кассплана (180 на 100)
*/

{global.i}
{comm-txb.i}
{sysc.i}

def input parameter dat as date.
def input parameter uu as char.

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp_pmp.i}

def var tsum as decimal.

def var tsum_0 as decimal.
def var cho as logical init false.
def new shared var s-jh like jh.jh.

def var i_temp_dep as integer.
def var s_account_a as char.
def var s_account_b as char.

def var s_account_c as char.
def var s_account_d as char.

def var s_dep_cash as char.
def var v-kaslkm as char.

   def var temp as char.
   def var StrTemp as char.
   def var StrAmount as char.
   def var str1 as char.
   def var str2 as char.

def buffer tcommonpl for commonpl.
def buffer ttcommonpl for commonpl.

def new shared var v-poscrc like crc.crc.

if seltxb = 0 then do:
find first sysc where sysc.sysc = "KASLKM" no-lock no-error.
if avail sysc then
v-kaslkm = trim(sysc.chval).
else do:
message "Отсутствует запись sysc.chval = KASLKM" view-as alert-box title "Внимание".
return.
end.
end.

if get-dep(uu,dat) = ? then do:
message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.

if deparp_pmp(get-dep(uu,dat)) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.
hide all.

output to prihod.img.

for each tcommonpl where tcommonpl.txb     = seltxb and
                         tcommonpl.date    = dat    and
                         tcommonpl.sum     > 0      and
                         tcommonpl.joudoc  = ?      and
                         tcommonpl.uid     = uu     and
                         tcommonpl.deluid  = ?      and
                         tcommonpl.deldate = ?      and
                         tcommonpl.grp     = 16     no-lock:

do transaction:

/* Алматы */
if seltxb = 0 then do:
if tcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '000904621'
            s_account_c = '187060'
            s_account_d = '003904424'.
if tcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '000076656'
            s_account_c = '187060'
            s_account_d = '003076255'.
end.

/* Астана */
if seltxb = 1 then do:
if tcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '150904918'
            s_account_c = '187060'
            s_account_d = '150076723'.
if tcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '150076011'
            s_account_c = '187060'
            s_account_d = '150076341'.
end.


/* Уральск */
if seltxb = 2 then do:
if tcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '250904816'
            s_account_c = '187060'
            s_account_d = '250076951'.
if tcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '250076809'
            s_account_c = '187060'
            s_account_d = '250076016'.
end.


/* Атырау */
if seltxb = 3 then do:
return.
/*
if commonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '350904204'.
if commonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '350076200'.
*/
end.
            s-jh = 0.
            run trx (6,
            tcommonpl.sum,
            tcommonpl.typegrp,
            s_account_c,
            s_account_d,
            '100100',
            '',
            'Выдача наличных через POS ' + trim(tcommonpl.chval[2]) + ' ' + trim(tcommonpl.fioadr),'14','14','856').

            s-jh = int(return-value).
            run setcsymb (s-jh, 100).
            v-poscrc = tcommonpl.typegrp.
            run posjou.


            s-jh = 0.
            run trx (6,
            tcommonpl.sum,
            tcommonpl.typegrp,
            s_account_a,
            s_account_b,
            s_account_c,
            s_account_d,
            'Выдача наличных через POS ' + trim(tcommonpl.chval[2]) + ' ' + trim(tcommonpl.fioadr),'14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            run setcsymb (s-jh, 100).
            v-poscrc = tcommonpl.typegrp.
            run posjou.

            if return-value = "" then undo, return.

find first commonpl where commonpl.txb    = seltxb and
                          commonpl.date   = dat   and
                          commonpl.dnum   = tcommonpl.dnum and
                          commonpl.joudoc = ?     and
                          commonpl.uid    = uu    and
                          commonpl.deluid = ?     and
                          commonpl.deldate = ?    and
                          commonpl.grp    = 16    exclusive-lock.
            if avail commonpl then
            assign commonpl.joudoc = return-value.
            release commonpl.

          /*  run vou_import.*/
end.
end.

   output close.
   unix silent prit prihod.img.

for each ttcommonpl where ttcommonpl.txb     = seltxb and
                          ttcommonpl.date    = dat    and
                          ttcommonpl.comsum  > 0      and
                          ttcommonpl.joudoc  <> ?     and
                          ttcommonpl.uid     = uu     and
                          ttcommonpl.deluid  = ?      and
                          ttcommonpl.deldate = ?      and
                          ttcommonpl.grp     = 16     no-lock.
do transaction:

/* Алматы */
if seltxb = 0 then do:
if ttcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '000904621'.
if ttcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '000076656'.
end.

/* Астана */
if seltxb = 1 then do:
if ttcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '150904918'.
if ttcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '150076011'.
end.


/* Уральск */
if seltxb = 2 then do:
if ttcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '250904816'.
if ttcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '250076809'.
end.


/* Атырау */
if seltxb = 3 then do:
if ttcommonpl.typegrp = 1 then
     assign s_account_a = '186034'
            s_account_b = '350904204'.
if ttcommonpl.typegrp = 2 then
     assign s_account_a = '186034'
            s_account_b = '350076200'.
end.

            s-jh = 0.
            run trx (6,
            ttcommonpl.comsum,
            ttcommonpl.typegrp,
            s_account_a,
            s_account_b,
            '460813',
            '',
            'Комиссия за выдачу наличных через POS ' + trim(ttcommonpl.chval[2]) + ' ' + trim(ttcommonpl.fioadr),'14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

find first commonpl where commonpl.txb    = ttcommonpl.txb and
                          commonpl.date   = ttcommonpl.date   and
                          commonpl.dnum   = ttcommonpl.dnum and
                          commonpl.typegrp = ttcommonpl.typegrp and
                          commonpl.type = ttcommonpl.type  and
                          commonpl.uid    = ttcommonpl.uid   and
                          commonpl.deluid = ?     and
                          commonpl.deldate = ?    and
                          commonpl.grp    = 16    exclusive-lock no-error.
            if avail commonpl then
            assign commonpl.comdoc = string(return-value).

            release commonpl.
end.
end.


