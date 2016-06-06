/* sel.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       12.04.2005 marinav - пустая строка между заголовком и данными (так красивее)
       27/07/2006 u00568 Evgeniy - добавил реакцию на F4 иначе никакого return не получалось и в блоке, где обрабатывалась эта функция return-value не обнулялся, а сохранялл старое значение. от этого были ошибки.
*/



def input parameter ttl as char.
def input parameter str as char.

define temp-table menu no-undo
    field num as int
    field itm as char.
        
def var i as int init 0.
def var dlm as char init "|".

do i = 1 to num-entries(str, dlm):
    create menu.
    assign menu.num = i menu.itm = entry(i, str, dlm).
end.
    
def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.itm label ' ' format "x(40)"
        with 9 down title ttl.
        
def frame fr1
    b1
    with no-labels centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do:
        apply "endkey" to frame fr1.
    end.

on end-error of b1 in frame fr1 /*F4*/
    do:
      return.
    end.


open query q1 for each menu.

if num-results("q1")=0 then
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

return string(menu.num).
