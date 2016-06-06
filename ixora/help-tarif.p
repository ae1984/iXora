/* help-tarif.p
 * MODULE
        Пвяювпке Тфръфвоопрър Ордину
 * DESCRIPTION
        Пвяпвёепке тфръфвооэ, рткхвпке тфрзедиф к ципмзкл
 * RUN
        Хтрхрч юэярюв тфръфвооэ, рткхвпке твфвоежфрю, тфкоефэ юэярюв
 * CALLER
        Хткхрм тфрзедиф, юэяэювбЁкй шжрж цвлн
 * SCRIPT
        Хткхрм хмфктжрю, юэяэювбЁкй шжрж цвлн
 * INHERIT
        Хткхрм юэяэювеоэй тфрзедиф
 * MENU
        Тефеёепы типмжрю Оепб Тфвъоэ 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08.12.2004 saltanat - чефижыху жвфкцэ хр хжвжихро "r" - фвчрёкл.
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
*/

def shared var g-lang as char.
def var v-uslug as char format "x(10)".
def var pakal like tarif2.pakalp.
def new shared var ee5 as char format "x".
ee5 = '*'.
                      /*
define frame fee5 ee5 with frame fee5 side-label no-box row 2.
on help of ee5 in frame fee5 do:
    pause 1000.
    run help-num.
end.
update ee5 label "   Имвгкже мрд ъфиттэ жвфкцрю  (F2 - трорЁы, * - юхе ъфиттэ)" 
    with frame fee5.    */

{jabra.i

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tar2"
&framename = "tar2"
&where     = "(substring(num,1,1) = ee5 or ee5 = '*') and tarif2.stat = 'r' "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " "

&prechoose = "/*message 'RETURN-izvёlёt un гrг, P-drukгt.'.*/"
              /*find tarif where tarif.num = tarif2.num no-lock no-error.
              if available tarif then message tarif.pakalp.
              disp tarif.pakalp with centered
                row 18 no-label no-box color messages overlay frame tarr.
              end.*/"
&predisplay = " "

&display   = " tarif2.str5
               tarif2.kont
               tarif2.punkt
               tarif2.pakalp
               tarif2.ost
               tarif2.proc
               tarif2.min1
               tarif2.max1 "

&highlight = " tarif2.str5 tarif2.kont tarif2.pakalp "

&postkey   = "
            else if keyfunction(LASTKEY) = 'RETURN'
            then
             do :
             v-uslug = trim(tarif2.num) + trim(tarif2.kod).
            frame-value = v-uslug.
            hide frame tar2.
            return.
            end.
            /*
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
                       title 'PеRSKAIT§JUMI '  column 1 row 7 11 down
                       frame uuu.

                end.
                hide frame uuu.
               output close.
               output to terminal.
               unix silent prit tar2.img .
               pause 0.
               hide message.
               return.
               end.*/
            "

&end = "hide frame tar2.
return."
}
