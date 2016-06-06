/* taxaccnt.p
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

define temp-table taxaccnt
    field point like point.point
    field name like ppoint.name
    field depart like ppoint.depart
    field accnt like depaccnt.accnt.

for each ppoint:
    find first depaccnt where depaccnt.point = ppoint.point and
    depaccnt.depart = ppoint.depart no-lock no-error.
    if not avail depaccnt then do transaction:
        create depaccnt.
        assign
            depaccnt.point = ppoint.point
            depaccnt.depart = ppoint.depart.
    end.
    create taxaccnt.
    assign 
        taxaccnt.point = depaccnt.point
        taxaccnt.depart = depaccnt.depart
        taxaccnt.name = ppoint.name
        taxaccnt.accnt = depaccnt.accnt.
end.

for each depaccnt:
    find first taxaccnt where taxaccnt.point = depaccnt.point and
        taxaccnt.depart = depaccnt.depar no-lock no-error.
    if not avail taxaccnt then delete depaccnt.
end.
    
def query q1 for taxaccnt.

/*
define button bnew label "Добавить".
define button bedt label "Изменить".
define button bdel label "Удалить".
*/

def browse b1 
    query q1 no-lock
    display 
        taxaccnt.name label "Департамент"
        taxaccnt.accnt label "Транз.счет" format '999999999'
        with 7 down title "Транзитные счета для налоговых платежей".

def frame fr1 
    b1
    /*
    bnew skip
    bedt skip
    bdel
    */
    with no-labels centered overlay.
    
on return of b1 in frame fr1
    do: 
        find first depaccnt where taxaccnt.point = depaccnt.point and
                taxaccnt.depart = depaccnt.depar no-error.
        update taxaccnt.accnt format "999999999"  label "Транзитный счет" 
        validate(can-find(first arp where arp.arp = taxaccnt.accnt),
        "Карточка ARP " + taxaccnt.accnt +  " не найдена.")
        with side-labels centered frame fr2 view-as dialog-box.
        update depaccnt.accnt = taxaccnt.accnt.
        hide frame fr2.
        open query q1 for each taxaccnt.
    end.  


open query q1 for each taxaccnt.
/*
if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Настройте комиссию".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
*/
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return.

