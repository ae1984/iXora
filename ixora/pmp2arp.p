/* pmp2arp.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Зачисление на транзитный счет пенсионных платежей (соц. отчисления)
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
        14/01/05 kanat
 * CHANGES
        18/01/05 kanat - изменение в формирование транзакции
        19/01/05 kanat - АРП счета для соц. отчислений берутся по департаментам
        20/01/05 kanat - убрал выходной параметр в процедуре
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        25.04.2005 kanat - добавил дополнительное инкассирование для социальных платежей
        18/08/05 kanat - убрал формирование операционных ордеров т.к. у менеджеров в конце зачислений формируется единый прих. ордер
        01.02.2012 lyubov - изменила символ кассплана (180 на 100)

*/


{comm-txb.i}
{sysc.i}

def input parameter dat as date.
def input parameter uu as char.

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp_pmp.i}

def shared var g-today as date.
def var tsum as decimal.
def var tsum1 as decimal.

def var tsum_0 as decimal.
def var cho as logical init false.
def new shared var s-jh like jh.jh.

def var i_temp_dep as integer.
def var s_account_a as char.
def var s_account_b as char.
def var s_dep_cash as char.
def var v-kaslkm as char.

def buffer tcommonpl for commonpl.


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


if seltxb = 0 then do:
            s_account_a = '100100'.
            s_account_b = ''.
end.


if seltxb = 1 then do:
     assign s_account_a = ''
            s_account_b = '150076778'.
end.

if seltxb = 2 then do:
     assign s_account_a = ''
            s_account_b = '250076676'.
end.

hide all.


for each commonpl where commonpl.txb    = seltxb and
                        commonpl.date   = dat    and
                        commonpl.joudoc = ?      and
                        commonpl.uid    = uu     and
                        commonpl.deluid = ?      and
                        commonpl.grp    = 15     and
                        commonpl.chval[2] <> "1" no-lock:
    ACCUMULATE commonpl.comsum + commonpl.sum (total).
    ACCUMULATE commonpl.sum (total).
end.
tsum = (accum total commonpl.comsum + commonpl.sum).


for each tcommonpl where tcommonpl.txb    = seltxb and
                         tcommonpl.date   = dat    and
                         tcommonpl.joudoc = ?      and
                         tcommonpl.uid    = uu     and
                         tcommonpl.deluid = ?      and
                         tcommonpl.grp    = 15     and
                         tcommonpl.chval[2] = "1" no-lock:
    ACCUMULATE tcommonpl.comsum + tcommonpl.sum (total).
    ACCUMULATE tcommonpl.sum (total).
end.
tsum1 = (accum total tcommonpl.comsum + tcommonpl.sum).


do transaction:
if tsum <> 0 then do:
    MESSAGE "Сформировать кассовый ордер на сумму " tsum " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи соц. отчислений" UPDATE choice3 as logical.
    case choice3:
        when true then do:

            run trx (
            6,                                          /* 150904824 - TXB01 */
            tsum,
            1,
            s_account_a, /*if cho then '100100' else '',*/
            s_account_b, /*if cho then '' else '000061302',*/
            '',
            deparp_pmp(get-dep(uu,dat)),
            'Зачисление на транзитный счет соц. отчислений','14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            run setcsymb (s-jh, 100).
            run jou.

            if return-value begins "Not cash" then do:
                message "Возможно, что произошла ошибка при зачислении!" skip
                   "свяжитесь с Департаментом Информационных Технологий"
                        view-as alert-box title "ВНИМАНИЕ".
                undo, return.
            end.

            if return-value = "" then undo, return.

            for each commonpl where commonpl.txb = seltxb and
                                    commonpl.date = dat and
                                    commonpl.joudoc = ? and
                                    commonpl.uid = uu and
                                    commonpl.deluid = ? and
                                    commonpl.grp = 15 and
                                    commonpl.chval[2] <> "1" exclusive-lock:
                assign commonpl.joudoc = return-value.
            end.
            release commonpl.

/*
            run vou_import.
*/

            end.
        when false then undo.
        end.
end.
end.


/* предварительно инкассированные */

            if seltxb = 0 then do:
            s_account_a = ''.
            s_account_b = v-kaslkm.
            end.

do transaction:
if tsum1 <> 0 then do:
    MESSAGE "Зачислить с АРП " v-kaslkm " сумму в " tsum " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи соц. отчислений" UPDATE choice4 as logical.
    case choice4:
        when true then do:

            run trx (
            6,                                          /* 150904824 - TXB01 */
            tsum1,
            1,
            s_account_a, /*if cho then '100100' else '',*/
            s_account_b, /*if cho then '' else '000061302',*/
            '',
            deparp_pmp(get-dep(uu,dat)),
            'Зачисление на транзитный счет соц. отчислений','14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            run setcsymb (s-jh, 100).
            run jou.

            if return-value begins "Not cash" then do:
                message "Возможно, что произошла ошибка при зачислении!" skip
                   "свяжитесь с Департаментом Информационных Технологий"
                        view-as alert-box title "ВНИМАНИЕ".
                undo, return.
            end.

            if return-value = "" then undo, return.

            for each commonpl where commonpl.txb = seltxb and
                                    commonpl.date = dat and
                                    commonpl.joudoc = ? and
                                    commonpl.uid = uu and
                                    commonpl.deluid = ? and
                                    commonpl.grp = 15 and
                                    commonpl.chval[2] = "1" exclusive-lock:
                assign commonpl.joudoc = return-value.
            end.
            release commonpl.

/*
            run vou_import.
*/

            end.
        when false then undo.
        end.
end.
end.
