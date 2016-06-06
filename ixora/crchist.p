/* crchist.p
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
 * BASES
        BANK COMM
 * CHANGES
        20.04.2011 aigul - добавила BASES BANK COMM
*/

/* crchist.p */

def var t9 as char format "x(1)".
{mainhead.i}

{mult.i
&head = "crc"
&headkey = "crc"
&where = "true"
&index = "crc"
&type = "trim"
&datetype = "string"
&formname = "crc"
&framename = "crc"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&start = " "
&viewframe = " "
&predisplay = "find last crchis where crchis.crc eq crc.crc no-error."
&display = "crc.crc crc.des crc.rate[1] crc.decpnt
            crchis.rdt when available crchis crc.code crc.sts"
&numprg = "prompt"
&preadd = " "
&postadd = " "
&newpreupdate = " "
&preupdate = " "
&update = " "
&postupdate = "crc.who = userid('bank').  crc.whn = g-today.
               s-crc = crc.crc.
               run crchis.
               find last crchis where crchis.crc eq s-crc no-error.
               if available crchis then do:
                 crc.rate[1] = crchis.rate[1].
                 display crc.rate[1]  crchis.rdt with frame crc.
               end."
&newpostupdate = " "
&predelete = " "
&postdelete = " "
&get = " "
&put = " "
&end = " "
}
