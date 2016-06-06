/* pklonnew.p
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

/* pklonnew.p ПотребКредит
   Выдача кредита

   08.02.2003 nadejda
*/

{mainhead.i}

{pk.i "new"}

/**
s-credtype = "4".
**/

{pknlvar.i new
"s-main = 'PKANKMN'. s-opt = 'PKLONNEW'. s-page = 1."}

run pkdogsgn.

s-nodel = true.

{pkankmn.i}

