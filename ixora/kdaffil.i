/* kdaffil.i   Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
       ИНФОРМАЦИЯ ОБ АФФИЛИИРОВАННОЙ КОМПАНИИ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-2 Аффилир
 * AUTHOR
        22.12.2003 mairnav
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
        01.03.05 marinav - переделано для связи досье и мониторинга
    05/09/06   marinav - добавление индексов
*/
   




if s-kdcif = '' then return.

find first {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") 
     no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


define frame fr skip(1)
       {1}.affilate label "АФФИЛИР-ТЬ" VIEW-AS EDITOR SIZE 60 by 3  skip(1)
       {1}.info[1]  label "ИНФОРМАЦИЯ" VIEW-AS EDITOR SIZE 60 by 10 skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ ОБ АФФИЛИИРОВАННОЙ КОМПАНИИ" .



define variable s_rowid as rowid.


{jabrw.i 
&start     = " "
&head      = "{1}"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "{5}"
&framename = "kdaffil1"
&where     = " {1}.kdcif = s-kdcif and {3} and {1}.code = '02' "

&addcon    = "(s-ourbank = {2}.bank)"
&deletecon = "(s-ourbank = {2}.bank)"
&precreate = " "
&postadd   = "    {3}. {1}.bank = s-ourbank. {1}.code = '02'. {1}.kdcif = s-kdcif. {1}.who = g-ofc. {1}.whn = g-today.
                  update {1}.name with frame kdaffil1 .
                  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                  displ {1}.affilate {1}.info[1] {1}.whn  {1}.who with frame fr.
                  update {1}.affilate with frame fr .
                  update {1}.info[1] with frame fr."
                 
&prechoose = "message 'F4-Выход,   INS-Вставка.'."

&postdisplay = " "

&display   = "{1}.name " 

&highlight = " {1}.name "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                            if s-ourbank = {2}.bank then do:
                              update {1}.name with frame kdaffil1.
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                              displ {1}.affilate {1}.info[1] {1}.whn  {1}.who with frame fr.
                              update {1}.affilate with frame fr scrollable.
                              update {1}.info[1]  with frame fr scrollable. 
                              {1}.who = g-ofc. {1}.whn = g-today.
                              hide frame fr no-pause.
                            end.
                            else do:
                              displ {1}.affilate {1}.info[1] {1}.whn  {1}.who with frame fr.
                              pause.
                              hide frame fr no-pause. 
                            end.
                      end. "

&end = "hide frame kdaffil1. 
         hide frame fr."
}
hide message.


            

