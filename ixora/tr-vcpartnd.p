/* tr-vcpartnd.p
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
 * BASES
        BANK COMM 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tr-vcctd.p  Валютный контроль
   Триггер на удаление записи из vccontrs

   09.12.2002 nadejda
*/

trigger procedure for delete of vcpartners.

{vc.i}

for each vccontrs where vccontrs.partner = vcpartners.partner exclusive-lock:
  vccontrs.partner = "".
end.

