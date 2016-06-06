/* s-lonhr1.f
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

/*---------------------------------------------------------------------------
  #3.Bilance kredЁta aprakst–
---------------------------------------------------------------------------*/
define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable s-dt     as date.

define new shared variable m-ln as integer init 1.

define variable cifs     like cif.cif.
define variable m-dt     like lonhar.fdt.
define variable m-finrez like lonhar.finrez.
define variable m-akc    like lonhar.akc.
define variable dzest    as logical.

form
    lonhar.fdt       label "С "
           help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    format "99/99/9999"
    lonhar.finrez    label "Фин.рез."
    help "F3-неопределенность; F1,F4-выход;вверх/вниз-поиск;F10-удалить строку"
    lonhar.akc  label "Акционер"
           help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    lonhar.who       label "Исполн."
    lonhar.whn       label "Дата "
    with down row 7 column 15 overlay scroll 1 title "Ввод данных о клиенте "
         frame har.
