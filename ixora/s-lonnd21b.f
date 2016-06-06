/* s-lonnd21b.f
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

if index(lonsec1.prm,"&") > 0
then prm = substring(lonsec1.prm,1,index(lonsec1.prm,"&") - 1).
else prm = lonsec1.prm.
form
    lonsec1.pielikums
            help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    with no-labels title "Ввод приложения " + s-lon + " " + prm
    1 down row 7 column 15 overlay no-hide frame pielik.
