﻿/* AAA20_ps.p
 * MODULE
        Выгрузка уведомлений об изменении счетов юр.лиц с 9-тизначного на 20-тизначный
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
        17.06.2009 galina
 * BASES 
        BANK        
 * CHANGES
        
*/



if time >= 36000 then do:
   run MT998aaa20_out.
   run MT998aaa20end.
end.
