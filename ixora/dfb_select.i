/* dfb_select.i
 * MODULE
        Платежная система
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        oper_category.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        26/01/2005 kanat
 * CHANGES
*/                                      

define temp-table dfb-temp like dfb.

procedure dfb_select.

for each dfb-temp:
delete dfb-temp.
end.
  
for each dfb no-lock:
    do transaction on error undo, next:
        create dfb-temp.
        dfb-temp.name = dfb.name no-error.
        if error-status:error then undo, next.
        dfb-temp.dfb  = dfb.dfb no-error.
    end.
end.
        
def query q1 for dfb-temp.

def browse b1 
    query q1 no-lock
    display 
        dfb-temp.dfb  label "БИК" format "x(10)" 
        dfb-temp.name label "Наименование" format 'x(60)'
        with 10 down title "Список корр. счетов".

def frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  

                    
open query q1 for each dfb-temp.

if num-results("q1")=0 then
do:
    MESSAGE "Справочник корр. счетов пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return dfb-temp.dfb.

end.

