/* r-cashsp.p
 * MODULE
         Транзакции по счетам главной книги
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 lyubov
 * CHANGES
                   lyubov - вынесла все вычисления в другую программу, добавила сортировку данных
        19/01/2012 lyubov - добавила возможность выбора счета ГК, задать период
        02.08.2012 Lyubov - выборка по ГК предоставляется филиалам, где есть хоть один ЭК
*/
def new shared var vgl as int.
def var v-sel as int.

find sysc where sysc.sysc = 'ourbnk' no-lock no-error.
find first cslist where cslist.bank = sysc.chval no-lock no-error.
if avail cslist then do:

    run sel2 (" Выбор ГК ", " 1. 100100| 2. 100500| ВЫХОД ", output v-sel).
    if v-sel = 0 then return.
    if v-sel = 1 then do:
        vgl = 100100.
        message " No - сортировка по суммам ".
        message "Сортировать по номеру счета ГК? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
        if b = true then
        run r-cashsp1.
        else run r-cashsp2.
    end.
    if v-sel = 2 then do:
        vgl = 100500.
        message " No - сортировка по суммам ".
        message "Сортировать по номеру счета ГК? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE c AS LOGICAL.
        if c = true then
        run ec-cashsp1.
        else run ec-cashsp2.
    end.
end.
else do:
    message " No - сортировка по суммам ".
    message "Сортировать по номеру счета ГК? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE d AS LOGICAL.
    if d = true then
    run r-cashsp1.
    else run r-cashsp2.
end.