/* r-ost.p
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
        
 * BASES
        BANK COMM
 * CHANGES
*/


{mainhead.i}
{functions-def.i}


define new shared variable v-dt as date.
v-dt = today.
update v-dt label  " Отчетная дата " with side-label centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

display '   Ждите...   '  with row 5 frame ww centered .

def new shared stream m-out.
output stream m-out to rpt.img.


{r-brfilial.i &proc="r-ost0"}


output stream m-out close.
if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
{functions-end.i}



