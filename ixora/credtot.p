/* credtot.p
 * MODULE
        1.1.1 для групп счетов 236 и 237
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        03.05.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        20.05.2011 ruslan перекомпиляция
        13.06.2011 aigul - перекомпиляция в связи с изменениями с cif.f
        05/02/2013 sayat - перекомпиляция в связи с изменениями в s-cifot
*/

{mainhead.i CFENT}

{sixn.i
 &head = cif
 &headkey = cif
 &option = CIF
 &numsys = auto
 &numprg = xxx
 &keytype = string
 &nmbrcode = CIF
 &subprg = s-cifot
 &cred = yes
 &no-add = leave.
}



