/* tr-vccomsd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vcctcoms
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
        09.01.2002 nadejda
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vcctcoms.
{sum2str.i}

find vcparams where vcparams.parcode = vcctcoms.codcomiss no-lock no-error.
run vc2hisct(vcctcoms.contract, "Удалена запись о снятии комиссии " + if avail vcparams then entry(1,vcparams.valchar) else "" + ", сумма " + sum2str(vcctcoms.sum) + " от " +
string(vcctcoms.datecomiss, "99/99/99")).