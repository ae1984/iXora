/* help-convdoc.p
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

{global.i}


def shared var dType as integer.


define query q_list for dealing_doc.
define browse b_list query q_list no-lock 
  display dealing_doc.docno label "Номер"
          dealing_doc.whn_mod label "Дата"
          string (dealing_doc.time_mod, 'HH:MM:SS') label "Время"
          dealing_doc.jh label "Транз-1"
          dealing_doc.jh2 label "Транз-2"
  with title "Список документов" 15 down centered overlay no-row-markers.

define frame f1
       b_list 
       with no-labels centered overlay view-as dialog-box.

 on return of b_list in frame f1
 do: 
   apply "endkey" to frame f1.
   return dealing_doc.docno.
 end.  


open query q_list 
     for each dealing_doc 
         where dealing_doc.who_cr eq g-ofc and 
               dealing_doc.doctype eq dType 
               by dealing_doc.docno DESCENDING.



enable all with frame f1.
apply "value-changed" to b_list in frame f1.
WAIT-FOR endkey of frame f1.
hide frame f1.

   