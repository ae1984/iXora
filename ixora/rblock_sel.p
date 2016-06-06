/* rblock_sel.p
 * MODULE
         Заблокированные счета и остатки
 * DESCRIPTION
        Меню для выбора критерия, для составления отчета.
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
        15.02.2011 ruslan
 * BASES
        BANK
 * CHANGES
        25.02.2011 ruslan убрал ненужные переменные
*/

{global.i}

def var v-sel as integer no-undo.
def var v-path as char no-undo.
def var v-bankname as char.
def var v-filials as char no-undo.
def var v-select as integer no-undo.

    v-sel = 0.
    run sel2 (" Выбор ", " 1. По филиалу| 2. По ID менеджера| ВЫХОД ", output v-sel).
    if v-sel = 0 then return.
    if v-sel = 1 then run rblock.
    if v-sel = 2 then run r-blok.