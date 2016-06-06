/* repMT998call.p
 * MODULE
       Платежная система 
 * DESCRIPTION
        отчеты по уведомлениям об откр/закр счетов ЮЛ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
       
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
      1.3.10.2
 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK COMM
 * CHANGES
*/
{mainhead.i}
def var v-reptype as char init "1".

form 
 v-reptype format "x(1)" label "Вид отчета" help "1 - Увед-ния об открытие счета; 2 - Увед-ния о закрытие счета" validate(lookup(v-reptype,'1,2') > 0,"Неверный вид операции!") skip
with centered side-label width 40 row 10 title "ВИД ОТЧЕТА" frame f-rep.  

display v-reptype with frame f-rep.
update v-reptype with frame f-rep.

if v-reptype = "1" then run repMT998(2).
else run repMT998(3).

hide all no-pause.

 