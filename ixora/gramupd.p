/* gramupd.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def var v-aaa like aaa.aaa.
update v-aaa.
find aaa where aaa.aaa eq v-aaa no-lock no-error .
if not available aaa then 
find first aaa where aaa.name eq v-aaa no-lock no-error.
for each gram where gram.cif eq aaa.cif :
update gram.
end.