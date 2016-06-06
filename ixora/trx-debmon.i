/* trx-debmon.i
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Обработка дебиторов после создания записи в jl / jh
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
        23/12/2003 sasco
 * CHANGES
        05.03.2004 recompile
*/

for each tmon:
    create debmon.
    buffer-copy tmon to debmon.
    delete tmon.
    debmon.jh = s-jh.
end.
