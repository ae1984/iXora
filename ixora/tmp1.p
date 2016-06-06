/* tmp1.p
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
        31/12/99 pragma
 * CHANGES
*/

for each aaa where aaa.aaa eq "14141414":
aaa.stadt = ?.
update aaa.aaa aaa.cr[1] aaa.dr[1] aaa.cbal  aaa.opnamt
       aaa.regdt aaa.sta aaa.accrued aaa.stadt aaa.expdt.
end.
