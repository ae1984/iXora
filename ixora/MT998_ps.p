﻿/* MT998_ps.p
 * MODULE
        Выгрузка уведомлений об открытии/закрытии счетов юр.лиц
 * DESCRIPTION
        Процесс, запускающий все отчеты в pushrep по графику
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        12.09.2008 galina
 * BASES
        BANK
 * CHANGES
        16.09.2008 galina - убийство процеса вынесено в отдельную программу
        31/07/2013 galina - ТЗ 1994 перенесла запуск программы inkclose из psrun
        31/07/2013 galina - ТЗ 1994 ошиблась запуск inkclose перенесла в PUSH_ps


*/

if time >= 36000 then do:
   run MT998_400_out.
   run MT998end.
end.
