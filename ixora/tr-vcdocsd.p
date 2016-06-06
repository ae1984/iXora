/* tr-vcdocsd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vcdocs
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
        09.12.2002 nadejda
 * CHANGES
        11/08/2009 galina - запись в историю, если удалили документ
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vcdocs.

def var v-dntypename as char.
run deftypename(vcdocs.dntype).

run vc2hisdocs(vcdocs.docs, "Документ удален, номер " + vcdocs.dnnum + ", дата " + string(vcdocs.dndate, "99/99/9999")).
run vc2hisct(vcdocs.contract,'Документ удален. Тип - ' + vcdocs.dntype + '(' + v-dntypename + '); Номер - ' + vcdocs.dnnum + ", дата " + string(vcdocs.dndate, "99/99/9999")).

procedure deftypename.
    def input parameter dntype as char.
    dntype = trim(dntype).
    find first codfr where codfr.codfr = "vcdoc" and codfr.code = dntype no-lock no-error.
    if avail codfr then v-dntypename = trim(codfr.name[2]).
end procedure.