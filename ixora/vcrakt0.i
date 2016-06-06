/* vcrakt0.i
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
*/

/* vcrakt.i  Валютный контроль
   Акт сверки
   Запрос данных для фильтрации

   24.01.2003 nadejda - вырезан кусок из vcraktpa.p
*/


def var v-god as integer format "9999" init 2000.
def var v-rnnfind as char format "x(12)" init "".

update skip(1) 
   v-god label "  ГОД СВЕРКИ" "  " skip(1) 
   v-rnnfind label "  НАЧАЛО РНН" "  " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ГОД ОТЧЕТА : ".

v-rnnfind = trim(v-rnnfind).
