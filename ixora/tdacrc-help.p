/* tdacrc-help.p
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
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def shared var g-lang as char.

{jabro.i
&start = " "
&head = "crc"
&headkey = "crc"
&where = "crc.sts <> 9"
&index = "crc"
&formname = "tdacrc-help"
&framename = "crc"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " "
&display = "crc.crc crc.code crc.des"
&highlight = "crc.crc"
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              frame-value = crc.crc.
              leave upper.
            end."
&end = "hide frame crc. hide message."
}
