/* h-pcontract.p
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

/* h-pcontract.p Валютный контроль
   Поиск контракта по любому виду или по паспорту сделки

   25.10.2002 nadejda создан
*/

{vc.i}
{global.i}

define var vselect as cha format "x".

message "N)Номер  Y)Год  E)Экспорт  I)Импорт  T)Тип  P)Паспорт сделки" update vselect.

if vselect = "P" then
  run h-pcontrps.
else 
  run h-pcontrs(vselect).



