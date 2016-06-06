/* vccomp.p
 * MODULE
        Название модуля - Валютный контроль.
 * DESCRIPTION
        Описание - Сверка оборотов по счету клиента и платежей Валютного Контроля.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 9.4.4.
 * AUTHOR
        16.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        29.01.2013 damir - Полностью переделал. Оптимизация кода. Внедрено Техническое Задание.
*/

{mainhead.i}

{vccomparevar.i "new"}

def frame fparam
   v-dt1 label "с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной') skip
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
with centered side-label row 5 title " ПАРАМЕТРЫ ОТЧЕТА".

v-dt1 = g-today.
v-dt2 = g-today.

update v-dt1 with frame fparam.
update v-dt2 with frame fparam.

p-type = "rep".

run vccompare.