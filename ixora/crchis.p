/* crchis.p
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

/* crchis.p
*/
def shared var s-crc like crc.crc.

{mainhead.i}

find crc where crc.crc eq s-crc.

{mult.i
&head = "crchis"
&headkey = "rdt"
&where = "crchis.crc eq s-crc"
&index = "crcrdt"
&type = "string"
&datetype = "string"
&formname = "crch"
&framename = "hist"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&start = " "
&viewframe = " "
&predisplay = " "
&display = "crchis.rdt crchis.rate[1]"
&postdisplay = " "
&numprg = "prompt"
&preadd = " "
&postadd = "crchis.crc = s-crc."
&newpreupdate = " "
&preupdate = " "
&update = "crchis.rate[1] label 'КУРС' format 'zzz9.9999' crchis.rdt label 'РЕГ.ДАТА'"
&postupdate = "update crchis.rate[2] crchis.rate[3]
                      crchis.rate[4] crchis.rate[5] crchis.rate[6]
                      crchis.rate[7]
                      with frame crch no-label.
               crchis.who = userid('bank'). crchis.whn = g-today."
&newpostupdate = " "
&predelete = " "
&postdelete = " "
&get = " "
&put = " "
&end = " "
}
