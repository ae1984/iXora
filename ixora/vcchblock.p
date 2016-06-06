/* vcchblock.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Выводит список проведенных транзакций по разблокировке сумм на транзитных счетах - выбор транзакции для отмены разблокировки
 * RUN
        
 * CALLER
        vcblk076.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-7
 * AUTHOR
        16.10.2003 nadejda
 * CHANGES
*/

def output parameter p-remtrz like remtrz.remtrz.

def shared temp-table t-block like vcblock.


DEFINE QUERY q1 FOR t-block, crc.

def browse b1 
    query q1 no-lock
    display 
        t-block.jh2      column-label "ТРНЗ"           format "zzzzzzz9"
        t-block.deldt    column-label "ДАТА ТРН"       format "99/99/99"
        t-block.amt      column-label "СУММА"          format "zzz,zzz,zz9.99"
        crc.code         column-label "ВАЛ"            format "x(3)"
        t-block.acc      column-label "СЧЕТ ПОЛУЧ"     format "x(10)"
        t-block.remname  column-label "ПОЛУЧАТЕЛЬ"     format "x(17)"
        t-block.delwho   column-label "РАЗБЛК"         format "x(8)"
        with 12 down no-box no-row-markers.

def frame fr1 
    b1
    with centered overlay row 6 view-as dialog-box title " ВЫБЕРИТЕ ТРАНЗАКЦИЮ ДЛЯ ОТМЕНЫ РАЗБЛОКИРОВКИ ".
    
on return of b1 in frame fr1 do: 
  apply "endkey" to frame fr1.
end.  
                    
open query q1 for each t-block use-index jh2, each crc where crc.crc = t-block.crc no-lock.

if num-results("q1")=0 then
do:
    MESSAGE " Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE " ОШИБКА ! ".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.

p-remtrz = t-block.remtrz.

