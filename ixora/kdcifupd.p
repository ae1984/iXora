/* kdcifupd.p
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
    05/09/06   marinav - добавление индексов
*/

/* kdcifupd.p Электронное кредитное досье
      "Редактирование" верхнего меню 
 
     21.07.03 marinav

*/

{global.i}
{kd.i}

define new shared variable s-newrec as logical.
s-newrec = true.
run kdcifnew.