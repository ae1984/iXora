/* txnkmail.i
 * MODULE
        Налоговые 
 * DESCRIPTION
        Обшая для процедур отправки e-mail для налоговых комитетов
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
        28/01/04 sasco
 * CHANGES
*/

DEF BUFFER btaxnk for taxnk.
DEFINE QUERY q1 FOR taxnk.

define browse b1 query q1 
              display taxnk.name label "Налоговый комитет" 
              with 14 down no-label title "Выберите".

define frame fr1 b1 help "ENTER - {&operation} e-mail"
    with centered overlay no-label no-box.
    
define variable v-mail as char format "x(50)" label "E-mail".

define frame fm v-mail with row 5 centered overlay side-labels title "Ввод e-mail".

on "return" of b1 in frame fr1
    do: 
       if not avail taxnk then leave.
       {&proc}
    end.  
                    
     
open query q1 for each taxnk where taxnk.bank = "TXB00" no-lock. 
ENABLE all with frame fr1.
wait-for window-close of current-window focus browse b1.

