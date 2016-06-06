/* h-uslug.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

def shared var g-lang as char.
def shared var v-uslug as char format "x(10)".
def shared var pakal like tarif2.pakalp.
def shared var ee5 as char format "x".
{jabra.i

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tar2"
&framename = "tar2"
&where     = "substring(num,1,1) = ee5 and tarif2.stat = 'r' "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " "

&prechoose = "message 'RETURN-izvёlёt un –r–, P-druk–t.'."
              /*find tarif where tarif.num = tarif2.num no-lock no-error.
              if available tarif then message tarif.pakalp.
              disp tarif.pakalp with centered
                row 18 no-label no-box color messages overlay frame tarr.
              end.*/"
&predisplay = " "

&display   = " tarif2.str5
               tarif2.kont
               tarif2.pakalp
               tarif2.ost
               tarif2.proc
               tarif2.min1
               tarif2.max1 "

&highlight = " tarif2.str5 tarif2.kont tarif2.pakalp "



&postkey   = "
            else if keyfunction(LASTKEY) = 'RETURN'
            then do transaction on endkey undo, leave:
            v-uslug = trim(tarif2.num) + trim(tarif2.kod).
            pakal = tarif2.pakalp.

            hide frame tar2.
            frame-value = v-uslug.
            return.
            end.
            else if keyfunction(lastkey) = 'P' then do:
               output to tar2.img .
               for each tarif2
               where substring (tarif2.num,1,1) = ee5 :
               display tarif2.str5  label 'Kods'
                       tarif2.kont
                       tarif2.pakalp format 'x(28)'
                       tarif2.ost
                       tarif2.proc
                       tarif2.min1   format 'zz9.99'
                       tarif2.max1  format 'zz9.99' with overlay
                       title 'P…RSKAIT§JUMI '  column 1 row 7 11 down
                       frame uuu.

                end.
                hide frame uuu.
               output close.
               output to terminal.
               unix silent prit tar2.img .
               pause 0.
               hide message.
               return.
               end.
            "

&end = "hide frame tar2."
}
