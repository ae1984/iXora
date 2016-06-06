/* r-obrez.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       16/12/05 marinav
*/

/* r-obrez.p
   Обороты по счетам ГК за период с выделением резидентов/нерезидентов,
   счета только группы 220000
   изменения от 05.05.2000 */

{mainhead.i}
define new shared variable fdate as date.
define new shared  variable tdate as date.

define new shared variable v-gl like bank.jl.gl.

fdate = g-today.
tdate = g-today.


def stream m-out.
output stream m-out to rpt.img.
output stream m-out close.


display v-gl label "Счет Г/К"
        fdate label " с "
        tdate label " по "
        with row 8 centered  side-labels frame opt title "Введите :".

update v-gl validate (v-gl ne 0 and can-find(gl where gl.gl = v-gl) and 
            substr(string(v-gl),1,2) eq  '22',
            "Не существует счет или счет не входит в 220000 ") with frame opt. 
                               
update fdate
       validate(fdate <= g-today,"За завтра невозможно получить отчет !")
       with frame opt.
              
update tdate validate(tdate >= fdate and tdate <= g-today,
       "Должно быть: Начало <= Конец <= Сегодня")
        with frame opt.

hide frame opt.
display '   Ждите...   '  with row 5 frame ww centered .


run txbs("r-obrez-txb").


if  not g-batch then do:
    pause 0 before-hide.
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
