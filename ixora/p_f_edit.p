/* p_f_edit.p
 * MODULE
        СПРАВОЧНИКИ	
 * DESCRIPTION
	Справочник пенсионных фондов
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
	3-2-10-8-7 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	04/05/2005 u00121 заблокировал функцию удаления фондов
	11/08/2005 u00121 исключил возможность изменения ID фонда при редактировании записиси
*/


{yes-no.i}


DEFINE QUERY q1 FOR p_f_list.

define buffer buf for p_f_list.


def browse b1 
     query q1 
     displ p_f_list.name label "Наименование фонда" format 'x(55)' with 13 
     down title "Пенсионный фонды".

def frame fr1 
     b1 help "F1-добавить, F8-удалить, ENTER-изменить" with centered overlay.

on return of b1 in frame fr1 do:
   find buf where rowid (p_f_list) = rowid (buf) exclusive-lock.
   update buf except buf.id with side-labels centered row 5 frame getlist.
   hide frame getlist.
   close query q1.
   open query q1 for each p_f_list.
   browse b1:refresh().
end.  

def var id_next as int init 0.
on go of b1 in frame fr1 do:
	find last p_f_list no-lock no-error.
	id_next = p_f_list.id + 1.
   create p_f_list.
	p_f_list.id = id_next.
   update p_f_list except p_f_list.id with side-labels centered row 5 frame getlist.
   hide frame getlist.
   close query q1.
   open query q1 for each p_f_list.
   browse b1:refresh().
end.

on clear of b1 in frame fr1 do:
/*
   if yes-no ("WARNING!", "DELETE RECORD?")
   then do:
       find buf where rowid (buf) = rowid (p_f_list) exclusive-lock.
       delete buf.
       close query q1.
       open query q1 for each p_f_list.
       browse b1:refresh().
   end.
*/
   message "Запрещено удалять записи!" VIEW-AS ALERT-BOX INFORMATION BUTTONS ok.
end.

open query q1 for each p_f_list.

if num-results("q1")=0 then
do:
     MESSAGE "1:Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найден РНН ПФ".
     return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.




