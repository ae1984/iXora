/* gromain.p
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

/* gromain.p */

define var vbank like bank.name label "".
define new shared var s-jh like jh.jh.

{mainhead.i}

{main.i
 &option  = "UBP"
 &head    = "gro"
 &headkey = "gro"
 &framename = "gro"
 &formname = "gro"
 &findcon = "true"
 &addcon = "true"
 &start = " "
 &clearframe = " "
 &viewframe = " "
 &prefind = " "
 &postfind = " "
 &numprg = "n-gro"
 &preadd = "for each gro where gro.billno eq """":
 delete gro. end."
 &postadd = " "
 &subprg = "grosub"
 &end = " "
 }
