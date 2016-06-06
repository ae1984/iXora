/* pkanklon.p
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
        30/09/2005 madiar - исключение по бизнес-кредитам физ-лиц - другое верхнее меню
        19/04/2006 NatalyaD. - перекомпиляция
*/

/* pkanklon.p ПотребКредит
   Операции с кредитом

   05.02.2003 nadejda
*/

{mainhead.i}

{pk.i "new"}

{pknlvar.i new " "}
s-main = 'PKANKMN'. s-opt = 'PKANKLON'. s-page = 1.
if s-credtype = '8' then s-opt = 'PKANKBUS'.

run pkdogsgn.

s-nodel = false.

{pkankmn.i}

