/* seq-number.p
 * MODULE
        Операционист
 * DESCRIPTION
        Список всех документов UJO текущего офицера (сделанных в 2.8)
 * RUN
        вызывается при нажатии F2
 * CALLER
        uni_main
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2.8
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12.08.2003 nadejda - изменен индекс с тем, чтобы выводились документы в обратном порядке
        03/12/08 marinav - размер фрейма 

*/

/**** seq-number.p ****/


{global.i}

define variable template  as character format "x(7)".
define variable vtime     as character.

{aapbra.i

&head      = "ujo"
&index     = "whowd no-lock "
&formname  = "seq-number"
&framename = "fujo"
&where     = "ujo.who eq g-ofc"
&addcon    = "false"
&deletecon = "false"
&predisplay = "template = ujo.sys + ujo.code.
                vtime = string (ujo.tim, 'HH:MM:SS')."

&display   = "ujo.docnum ujo.whn vtime ujo.jh template" 
&highlight = "ujo.docnum ujo.whn vtime ujo.jh template"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    frame-value = ujo.docnum.
                    hide frame fujo.
                    return.  
              end."
&end = "hide frame fujo."
}

