/* r-lncif.p
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
        28.11.2003 marinav учет просрочки при выводе действующих кредитов
        19.12.2003 marinav добавление нового показателя в баланс , увеличение размерности врем массивов
        04/06/2004 madiar - добавил возможность формирования этого отчета задним числом
*/

/* Кредитный рейтинг клиента

*/


{mainhead.i}
def var v-cif like cif.cif.
def var stitle as char format "x(25)".
def var v-indat as date.

v-indat = g-today.

form
    stitle at 10 skip
    "Клиент" v-cif help "Код клиента; F2-код; F4-выход; F1-далее" skip
    "Дата  " v-indat help "Введите дату; F4-выход; F1-далее" validate(v-indat <= g-today , " Дата не может быть позднее сегодняшней! ") skip
    cif.sname  skip
    with centered row 0 no-label frame f-cif.

stitle = 'Кредитный рейтинг клиента'.

display stitle with frame f-cif.
update v-cif with frame f-cif.
if keyfunction(lastkey) eq "end-error" then do: hide frame f-cif. return. end.
find cif where cif.cif = v-cif no-lock no-error.
display cif.sname with frame f-cif.
update v-indat with frame f-cif.

pause 0.
hide frame f-cif.

message " Формируется отчет... ".

run r-lncifot (v-cif, v-indat).

hide message no-pause.