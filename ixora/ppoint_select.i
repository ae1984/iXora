/* ppoint_select.i
 * MODULE
       ДРР
 * DESCRIPTION
       Список мелких департаментов 
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        30/09/04 kanat
 * CHANGES
*/

define var v-depcode as char init "1,2,3,4,35,36,37". 
define temp-table cms
       field id as char
       field name as char
       index name is unique primary name.

procedure select_ppoint.  
for each ppoint where lookup(string(ppoint.depart), v-depcode) = 0 no-lock:
    do transaction on error undo, next:
        create cms.
        cms.name = ppoint.name no-error.
        if error-status:error then undo, next.
        cms.id = string(ppoint.depart).
    end.
end.       

def query q1 for cms.

def browse b1 
    query q1 no-lock
    display 
        cms.id   no-label format '>>'
        cms.name no-label format 'x(30)'
        with 7 down title "Список СПФ".

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
    MESSAGE "Информация по департаментам отсутствует."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms.id.
end.

