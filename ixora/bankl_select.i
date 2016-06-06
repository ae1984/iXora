/* bankl_select.i
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
        11/01/2005 kanat
 * CHANGES
*/                                      

define temp-table cms like bankl.

procedure bankl_select.

for each cms:
delete cms.
end.
  
for each bankl no-lock:
    do transaction on error undo, next:
        create cms.
        cms.name = bankl.name no-error.
        if error-status:error then undo, next.
        cms.bank = bankl.bank no-error.
    end.
end.
        
def query q1 for cms.

def browse b1 
    query q1 no-lock
    display 
        cms.bank label "БИК" format "x(10)" 
        cms.name label "Наименование" format 'x(60)'
        with 10 down title "Список банков".

def frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  

                    
open query q1 for each cms.

if num-results("q1")=0 then
do:
    MESSAGE "Справочник банков пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms.bank.

end.
