/* c-lon2.f
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

define variable m-ln      like lonstat.ln init 0.
define variable v-lonstat like lonstat.lonstat.
define variable v-apz     like lonstat.apz.
define variable v-prc     like lonstat.prc.
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
define variable ja-ne as logical.
form
    lonstat.lonstat   label "Код "
    help "F1,F4-отменить; стрелка верх/вниз-поиск; F10-удалить строку"
    lonstat.apz       label "Описание"
    help "F1,F4-отменить; стрелка верх/вниз-поиск; F10-удалить строку"
    lonstat.prc       format "zz9.99" label "% накоплен."
    help "F1,F4-отменить; стрелка верх/вниз-поиск; F10-удалить строку"
    lonstat.who       label "Исполнит."
    lonstat.whn       format "99/99/9999" label "  Дата"
    with down row 3 centered overlay scroll 1 frame stat.
