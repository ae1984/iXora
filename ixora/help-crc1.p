/* help-crc1.p
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

/**** help-crc1.p ****/

{global.i}
               /*
define shared variable v-ock like ock.ock.
define shared variable nref  like crefer.crefer.

define buffer bcrefer for crefer.
find bcrefer where bcrefer.crefer eq nref no-lock no-error.
                 */
{aapbra.i

&start     = " "
&head      = "crc"
&headkey   = "crc"
&index     = "crc no-lock "
&formname  = "hcrc1"
&framename = "hcrc1"
&where     = "crc.sts ne 9"
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "crc.crc crc.code crc.des" 
&highlight = "crc.crc crc.code crc.des"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    frame-value = crc.crc.
                    hide frame hcrc1.
                    return.
              end."
&end = "hide frame hcrc1."
}

