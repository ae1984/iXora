/* cif-sign.p
 * MODULE
        Название Программного Модуля
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
        06/06/2013 yerganat
 * BASES
        BANK
 * CHANGES

*/
def shared var s-cif like cif.cif.
def var v-sel    as int  no-undo init -1.

find first cif where cif.cif = s-cif no-lock no-error.

if avail cif then if cif.cgr=403 and cif.type = 'b' then
    run sel2('Выбрать из списка',' С печатью | Без печати ', output v-sel).


if v-sel<>0 then
    run cif-kart(v-sel).
