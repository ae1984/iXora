/* ch-rmz.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Выводит список валютных платежей для выбора разблокируемого 
        платежа при проводке с транзитного ARP-счета валютного контроля на счет клиента
 * RUN
        
 * CALLER
        jou42-aasnew.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-1
 * AUTHOR
        13.10.2003 nadejda
 * CHANGES
*/


def shared temp-table t-rmz
  field remtrz like remtrz.remtrz
  field rdt as date
  field crc as char
  field amt as decimal
  field name as char
  field acc as char
  index remtrz is primary unique name rdt remtrz.

def shared var s-remtrz like remtrz.remtrz.


DEFINE QUERY q1 FOR t-rmz.

def browse b1 
    query q1 no-lock
    display 
        t-rmz.remtrz label "РЕФЕРЕНС"    format "x(10)"
        t-rmz.rdt    label "ДАТА РЕГ"    format "99/99/99"
        t-rmz.crc    label "ВАЛ"         format "x(3)"
        t-rmz.amt    label "СУММА"       format "zzz,zzz,zz9.99"
        t-rmz.name   label "ПОЛУЧАТЕЛЬ"  format "x(22)"
        t-rmz.acc    label "СЧЕТ ПОЛУЧ"  format "x(10)"
        with 10 down title " ВАЛЮТНЫЙ КОНТРОЛЬ - УКАЖИТЕ РАЗБЛОКИРУЕМЫЙ ВХОДЯЩИЙ ВАЛЮТНЫЙ ПЛАТЕЖ ".

def frame fr1 
    b1
    with centered overlay row 7 view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each t-rmz.

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

s-remtrz = t-rmz.remtrz.

