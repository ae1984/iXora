/* ord_help.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Помощь полю - Отправитель
 * RUN
        psror-2.f
 * CALLER
        psror-2.f
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-14
 * AUTHOR
        24.06.2005 saltanat 
 * CHANGES
*/
{global.i}
define input  parameter s-cif as char.
define output parameter v-rnn as char.

{jabro.i
&start     =  " "
&head      =  "clfilials"
&headkey   =  "clfilials"
&index     =  "id"
&formname  =  "ord_help"
&framename =  "fr"
&where     =  " clfilials.cif = s-cif"
&addcon    =  "false"
&deletecon =  "false"
&predelete =  " " 
&precreate =  " "
&postadd   =  " "
&prechoose =  " "
&predisplay = " "
&display   =  " clfilials.namefil clfilials.forma_sobst clfilials.rnn "
&highlight =  "clfilials.namefil"
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    frame-value = clfilials.namefil.
                    v-rnn = clfilials.rnn.
                    leave upper.
                end."
&end =        " hide frame fr."
}