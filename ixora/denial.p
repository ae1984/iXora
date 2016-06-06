/* denial.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Отказ кдиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        18.11.2013 Lyubov (ТЗ 1830)
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-cls      as logi no-undo.

message "Внимание! Вы подтверждаете, что клиент отказывается от кредита?" view-as alert-box question buttons yes-no update b as logical.
if b then do:
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.credtype = '10' and pkanketa.ln = s-ln exclusive-lock no-error.
    if avail pkanketa and pkanketa.sts = '40' then do:
        message 'Нельзя отказаться от кредита после выдачи средств!' view-as alert-box.
        return.
    end.
    else pkanketa.sts = '111'.
end.