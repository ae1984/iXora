/* holiday.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29.12.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        04.01.2012 aigul - добавила индекс
*/

{mainhead.i}
{comm-txb.i}

def buffer v-holiday for holiday.
def new shared frame v-holiday.
def var t4 as char initial "F4-выход,INS-дополн.,Ctrl+D-удалить".
def var v-center as logical.
def var v-chng as logical.

def temp-table t-holiday like holiday.
v-center = yes.
{apbra-holiday.i
&head =      "holiday"
&index =     "md"
&formname =  "holiday"
&framename = "holiday"
&where =     ""
&addcon =    "v-center"
&deletecon = "v-center"

&postadd =   " buffer-copy holiday to t-holiday.
             holiday.whn = g-today.
             holiday.who = g-ofc.
             if v-center then do transaction on endkey undo, leave:
                update holiday.hday holiday.hmonth with frame holiday.
                run crcupd-after.
             end.
             "

&prechoose = "message t4."

&predisplay = " "
&display =    "holiday.hday holiday.hmonth"
&highlight =  "holiday.hday"
&predelete =  " "
&postdelete = " "
&postkey =    "else if keyfunction(lastkey) = 'RETURN' then do:
                  buffer-copy holiday to t-holiday.
                  if v-center then do transaction on endkey undo, leave:
                        update holiday.hday
                        holiday.hmonth
                        with frame holiday.
                        /*run crcupd-after.*/
                  end.
               end. "

&end = "hide frame holiday.  "
}

hide message.

procedure crcupd-after.
  v-chng = v-center and
    (holiday.hday <> t-holiday.hday or holiday.hmonth <> t-holiday.hmonth).
end procedure.




