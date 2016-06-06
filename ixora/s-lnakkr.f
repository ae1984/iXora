/* s-lnakkr.f
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

/*----------------------------------
  Заведение аккредитива и гарантии в кредитном модуле
----------------------------------*/
/*def new shared var s-lon like lon.lon.
s-lon = '000144342'.  
*/
define shared variable s-lon    as character.
define shared variable g-today  as date.

define new shared variable m-ln as integer init 1.
define new shared variable grp as integer init 6.

define variable s1   like lon.opnamt.
define variable s2   as decimal format "zz9.99".
define variable s3   as decimal format "zz9.99".
define variable s4   like lon.opnamt.
define variable dzest as logical.

form
    lnakkred.uno    label "Код"
  help "F2-код; F1-далее; F4-выход; вверх/вниз-поиск"
    lnakkred.regdt       label "С "
  help "F1-далее; F4-выход; вверх/вниз-поиск"
    lnakkred.duedt       label "По  "
  help "F1-далее; F4-выход; вверх/вниз-поиск"
    lnakkred.crc       label "Валюта"
  help "F2-валюта; F1-далее; F4-выход; вверх/вниз-поиск"
    lnakkred.amount    label "Сумма"
  help "F1-далее; F4-выход; вверх/вниз-поиск"
    with 6 down row 7 column 15 overlay scroll 1
    title "Ввод аккредитива и гарантии " + s-lon frame akkr.

