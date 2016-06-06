/* kdfound.i
 * MODULE
        Электронное Кредитное Досье
 * DESCRIPTION
        Учредители клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-2  Учредит
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


if s-kdcif = '' then return.

find {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var sum% as deci.
define frame fr
       {1}.info[1] no-label VIEW-AS EDITOR SIZE 55 by 10 skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 58 side-labels column 12 row 5 title "ИНФОРМАЦИЯ ОБ УЧРЕДИТЕЛЕ" .



define variable s_rowid as rowid.


repeat:

{jabrw.i 
&start     = " "
&head      = "{1}"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "{5}"
&framename = "kdaffil"
&where     = " {1}.kdcif = s-kdcif and {3} and {1}.code = '01' "

&addcon    = "(s-ourbank = {2}.bank)"
&deletecon = "(s-ourbank = {2}.bank)"
&precreate = " "
&postadd   = "  {3}. {1}.bank = s-ourbank. {1}.code = '01'. {1}.kdcif = s-kdcif.  {1}.who = g-ofc. {1}.whn = g-today.
                update {1}.name {1}.amount with frame kdaffil .
                message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                displ {1}.info[1] {1}.whn  {1}.who with frame fr.
                update {1}.info[1] with frame fr."
                 
&prechoose = "message 'F4-Выход,   INS-Вставка.'."

&postdisplay = " "

&display   = "{1}.name {1}.amount " 

&highlight = " {1}.name "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              if s-ourbank = {2}.bank then do:
                                update {1}.name {1}.amount with frame kdaffil.
                                message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                                displ {1}.info[1] {1}.whn  {1}.who with frame fr.
                                update {1}.info[1] with frame fr scrollable.
                                {1}.who = g-ofc. {1}.whn = g-today.
                              end.
                              else do:
                                /* display kdaffil.name kdaffil.amount with frame kdaffil. */
                                displ {1}.info[1] {1}.whn {1}.who with frame fr.
                                pause.
                              end.
                              hide frame fr no-pause.
                      end. "

&end = "hide frame kdaffil. 
         hide frame fr."
}

sum% = 0.
for each {1} where {1}.kdcif = s-kdcif and {3} and {1}.code = '01' no-lock.
    sum% = sum% + {1}.amount.
end.
if sum% = 100 then leave. 
              else do:
                 message skip " Сумма долей учредителей не равна 100 % !" skip(1)
                 view-as alert-box warning buttons ok-cancel title " ПРЕДУПРЕЖДЕНИЕ ! " update choice as logical.
                 if choice then leave.
              end.
end.
hide message.

