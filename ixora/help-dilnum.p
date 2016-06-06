/* help-dilnum.p
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

/*

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
       b_list.

on 'return' of b_list in frame f1
do:
  APPLY "WINDOW-CLOSE" TO frame f1.
end.


open query q_list 
     for each dealing_doc 
         where dealing_doc.who_cr eq g-ofc and 
               dealing_doc.doctype eq dType 
               by dealing_doc.docno DESCENDING.


/*view frame f1.*/
enable all with frame f1.
WAIT-FOR WINDOW-CLOSE /* RETURN*/ OF CURRENT-WINDOW.

  readkey pause 0.
  apply lastkey.
  frame-value = dealing_doc.docno.
