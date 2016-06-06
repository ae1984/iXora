/* kdosn.i
 * MODULE
        ЭКД 
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        Внесение баланса по активу
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
        01.03.2005 marinav
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


define frame fr skip(1)
       {1}.info[1]  label "ОПИСАНИЕ" VIEW-AS EDITOR SIZE 60 by 7 skip(1)
       {1}.amount      label "БАЛАНСОВАЯ СТ-ТЬ" skip
       {1}.amount_bank label "РЫНОЧНАЯ   СТ-ТЬ" skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ ОБ ОСНОВНОМ СРЕДСТВЕ" .

   define var v-dat as date.
   define var stitle as char.

   form stitle format 'x(50)' at 5 skip (1)
    "Дата" at 10 v-dat skip  
    with centered row 0 no-label frame f-cif1.

   v-dat = g-today.
   stitle = 'Основные средства к балансу на дату :'.
    display stitle with frame f-cif1.
    update v-dat with frame f-cif1.


define variable s_rowid as rowid.
define var sum as deci.
define var sumb as deci.
define var w-lon as deci extent 27.
define var i as inte.

 i = 1.
 for each bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = v-dat and bal_cif.nom begins 'a' use-index nom no-lock:
     w-lon[i] = bal_cif.amount.
     i = i + 1.
 end.
 sumb = w-lon[6].


{jabrw.i 
&start     = " "
&head      = "{1}"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "{5}"
&framename = "kdaffil15"
&where     = " {1}.kdcif = s-kdcif and {3} and {1}.code = '15' and {1}.dat = v-dat "

&addcon    = "(s-ourbank = {2}.bank)"
&deletecon = "(s-ourbank = {2}.bank)"
&precreate = " "
&postadd   = "  {3}. {1}.bank = s-ourbank. {1}.code = '15'. {1}.kdcif = s-kdcif. {1}.who = g-ofc. {1}.whn = g-today. {1}.dat = v-dat.
                update {1}.name with frame kdaffil15 .
                message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                displ {1}.info[1] {1}.amount {1}.amount_bank {1}.whn {1}.who with frame fr.
                update {1}.info[1] with frame fr.
                update {1}.amount with frame fr.
                update {1}.amount_bank with frame fr."
                 
&prechoose = "s_rowid = rowid({1}). sum = 0. for each {1} where {1}.bank = s-ourbank and {1}.code = '15' and {1}.kdcif = s-kdcif and {3} and {1}.dat = v-dat. 
              sum = sum + {1}.amount. end. find {1} where rowid({1}) = s_rowid no-lock no-error.
              put screen row 23 ' Итого основных ср-тв  ' .
              if sum = sumb then put screen row 23 column 35 string(sum) + ' тг.'.
                            else put screen color messages row 23 column 35 string(sum) + ' тг.'.
              put screen row 23 column 50 '   В балансе  ' + string(sumb) + ' тг.'. "

&postdisplay = " "

&display   = "{1}.name " 

&highlight = " {1}.name "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                         if s-ourbank = {2}.bank then do:
                              update {1}.name with frame kdaffil15.
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                         end.
                         displ {1}.info[1] {1}.amount {1}.amount_bank  {1}.whn  {1}.who with frame fr.
                         if s-ourbank = {2}.bank then do:
                              update {1}.info[1] with frame fr.
                              update {1}.amount {1}.amount_bank  with frame fr. 
                              {1}.who = g-ofc. {1}.whn = g-today.
                         end.
                         else pause.
                         hide frame fr no-pause. 
                      end. "

&end = "hide frame kdaffil15. 
         hide frame fr."
}
hide message.


            

