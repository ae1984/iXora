/* h-tarif.p
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
        26.09.2003 nadejda  - добавила условие для исключения неактивных тарифов
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

def shared var g-lang as char.
def var v-uslug as char format "x(10)".
def var pakal like tarif2.pakalp.
def shared var ee5 as char format "x".

{jabra.i

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "h-tarif"
&framename = "tarif"
&where     = "(substring(tarif2.pakalp,1,3) <> 'N/A') and tarif2.stat = 'r' "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " "

&prechoose = "message 'RETURN-выбрать, P-печать'."

&predisplay = " "

&display   = " tarif2.str5
           tarif2.kont
           tarif2.pakalp
       /*    tarif2.ost
           tarif2.proc
           tarif2.min1
           tarif2.max1*/ "

&highlight = " tarif2.str5 tarif2.kont tarif2.pakalp "

&postkey   = "
        else if keyfunction(LASTKEY) = 'RETURN' then do :
          v-uslug = tarif2.str5.
              frame-value = v-uslug.
          return v-uslug.
        end.
        else if keyfunction(lastkey) = 'P' then do:
           output to tar2.img .
           for each tarif2
          /* where substring (tarif2.num,1,1) = ee5*/ :
           display tarif2.str5  label 'КОД'
               tarif2.kont  label 'СЧЕТ ГК'
               tarif2.pakalp format 'x(28)' label 'НАЗВАНИЕ'
/*             tarif2.ost  'СУММА'
               tarif2.proc '%'
               tarif2.min1   format 'zz9.99' 'МИН'
               tarif2.max1  format 'zz9.99'  'МАКС' */
                 with overlay title 'ТАРИФЫ'  column 1 row 7 11 down frame uuu.

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

&end = "hide frame tarif."
}
