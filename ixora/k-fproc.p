/* k-fproc.p
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
        06.10.2003 nadejda  - изменила формат вывода (побольше символов для кода процесса)
*/

/* 
   <Insert> - вставка новой строки . <F4> - выход из режима вставки.
   <F10> или <CTRL D>- удалить строку. 
*/
           
{global.i}  /*
{ps-prmt.i}   */
def var v-ans as logi.
def var ss as char init "*".
def new shared var s-fproc as int .
hide all .
display " Классификатор процессов  " with overlay row 0 centered .
pause 0 .

tab :
repeat:

{jabra.i
&start = " "
&head = "fproc"
&headkey = "pid"
&where = " "
&index = "pid"
&formname = "fproc"
&framename = "fproc"
&addcon = "true"
&deletecon = "true"
&predisplay = " "
&display = "fproc.pid fproc.des fproc.sname nprc tout"
&highlight = "fproc.pid"
&postcreate = " "
&postdisplay = " "
&postadd = "update fproc.pid fproc.des fproc.sname nprc tout
            with frame fproc. "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do transaction :
            update fproc.pid fproc.des fproc.sname nprc tout
            with frame fproc. end.
            else if keyfunction(lastkey) ne 'RETURN'
             then do:
              s-fproc = recid(fproc).
              run p-else . end . "
&end = "hide all. leave tab."
}
 end.
