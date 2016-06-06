/* c-lon1.f
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

define variable m-ln       like lonsec.ln init 0.
define variable old-lonsec like lonsec.lonsec.
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
define variable ja-ne      as logical.
define variable v-apz      like lonsec.apz.
define variable v-lonsec   like lonsec.lonsec.
define variable v-des      like lonsec.des.
define variable v-des1     like lonsec.des1.
define variable v-risk     like lonsec.risk.

form
    lonsec.apz       label "Вид."
               help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    lonsec.lonsec    label "Код"
               help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"              lonsec.des       label "Название"
               help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    lonsec.des1      label "Сокращение"
               help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    lonsec.risk      label "Риск"
               help "F1,F4-выход; вверх/вниз-поиск; F10-удалить строку"
    with centered down row 3 overlay scroll 1 title
    "Ввод/редактирование видов обеспечения" frame sec.
