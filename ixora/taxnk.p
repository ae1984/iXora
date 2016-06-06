/* taxnk.p
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

{comm-txb.i}

DEFINE QUERY q1 FOR comm.taxnk.
def var ourbank as char.
ourbank = comm-txb().

def browse b1 
    query q1 no-lock
    display 
        comm.taxnk.rnn label "РНН" 
        comm.taxnk.name label "Наименование" format 'x(55)'
        with 13 down title "RNN".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each comm.taxnk where comm.taxnk.bank = ourbank.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден РНН".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return rnn.

