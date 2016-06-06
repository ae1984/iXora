/* sel_br.p 
 * Модуль
     BASE
 * Назначение
     вывод вертикального меню для выбора, 
     выбранное значение возвращается как параметр - в отличие от sel.p, где идет return-value
 * Применение
     
 * Вызов
     передается заголовок и список строк меню через | из справочника филиалов и их БИКов, возвращается номер выбранного элемента
 * Меню
     
   6.9.1
 * Автор
     u00571
 * Дата создания:
     20.02.2006
 * Изменения
*/



def input parameter ttl as char.
/*def input parameter str as char.*/
def output parameter selitem as integer init 0.


define temp-table menu no-undo
    field num as int
    field itm as char.
        
def var i as int init 0.
def var dlm as char init "|".

for each spr_branch no-lock by id.

    create menu.
    assign menu.num = spr_branch.id menu.itm = string(spr_branch.name,'x(25)') + '  ' + string(spr_branch.bik,'999999999') + '  ' + string(spr_branch.bik_nb,'999999999') .
end.
    
def query q1 for menu.

def browse b1 
    query q1 no-lock
    display 
        menu.itm label 'Назавание                  БИК        БИК НБ ' format "x(50)"
        with 17 down title ttl.
        
def frame fr1 
    b1
    with no-labels centered overlay row 8 view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  

                    
open query q1 for each menu.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Ошибка".
    return.                 
end.

b1:title = ttl.
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.

selitem = menu.num.


