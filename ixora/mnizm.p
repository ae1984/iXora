/* mnizm.p
 * MODULE
        ЭКД Мониторинг
        Мониторинг заемщика
 * DESCRIPTION
        Изменение условий кредитоаания
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
        01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}
{kdsysc1.f}


if s-kdcif = '' then return.

find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom and (kdcifhis.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcifhis then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


define frame fr skip(1)
       kdaffilh.info[1] label "УСЛОВИЯ" VIEW-AS EDITOR SIZE 60 by 5 skip(1)
       kdaffilh.info[2] label "ПРИМЕЧАНИЕ" VIEW-AS EDITOR SIZE 60 by 5 skip(1)
       kdaffilh.whn     label "ПРОВЕДЕНО " kdaffilh.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ " .


define variable s_rowid as rowid.

{jabrw.i 
&start     = " on help of kdaffilh.kdlon in frame kdaffil62 do: 
                 run h-mnlon. kdaffilh.kdlon:screen-value = return-value.
                 kdaffilh.kdlon = kdaffilh.kdlon:screen-value. 
                 end. "
&head      = "kdaffilh"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "kdsysc1"
&framename = "kdaffil62"
&where     = " kdaffilh.kdcif = s-kdcif and kdaffilh.nom = s-nom and kdaffilh.code = '62' "

&addcon    = "(s-ourbank = kdcifhis.bank)"
&deletecon = "(s-ourbank = kdcifhis.bank)"
&precreate = " "
&postadd   = "  kdaffilh.nom = s-nom. kdaffilh.bank = s-ourbank. kdaffilh.code = '62'. kdaffilh.kdcif = s-kdcif. 
                kdaffilh.who = g-ofc. kdaffilh.whn = g-today. kdaffilh.dat = g-today.
                update kdaffilh.kdlon kdaffilh.dat kdaffilh.name with frame kdaffil62 .
                message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                displ kdaffilh.info[1] kdaffilh.info[2] kdaffilh.whn kdaffilh.who with frame fr.
                update kdaffilh.info[1] with frame fr.
                update kdaffilh.info[2] with frame fr."
                 
&prechoose = "message 'F4-Выход, INS-Вставка.'."

&postdisplay = " "

&display   = " kdaffilh.kdlon kdaffilh.dat kdaffilh.name " 

&highlight = " kdaffilh.kdlon kdaffilh.dat kdaffilh.name "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                         if s-ourbank = kdcifhis.bank then do:
                              update kdaffilh.kdlon kdaffilh.dat kdaffilh.name with frame kdaffil62.
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                         end.
                         displ kdaffilh.info[1] kdaffilh.info[2]  kdaffilh.whn  kdaffilh.who with frame fr.
                         if s-ourbank = kdcifhis.bank then do:
                              update kdaffilh.info[1] with frame fr.
                              update kdaffilh.info[2] with frame fr. 
                              kdaffilh.who = g-ofc. kdaffilh.whn = g-today.
                         end.
                         else pause.
                         hide frame fr no-pause. 
                      end. "

&end = "hide frame kdaffil62. 
         hide frame fr."
}
hide message.


            

