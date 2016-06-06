/* printper.p
 * MODULE
        Повторная печать проводки
 * DESCRIPTION
        Повторная печать проводки
 * RUN
        cancel-per.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
       5-8-9
 * AUTHOR
        15.07.2005 nataly
 * BASES
        BANK COMM
 * CHANGES
        13.01.2012 damir - добавил keyord.i, printord.p
        07.03.2012 damir - добавил входной параметр в printord.p.

*/

{keyord.i} /*Переход на новые и старые форматы ордеров*/

define new shared var s-jh like jh.jh .

update s-jh  label 'Введите номер проводки' with frame www centered  row 5.

if v-noord = no then run vou_bank2(2,2, "").
else run printord(s-jh,"").

