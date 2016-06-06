/* tr-vcpsd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vcps
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
        09.12.2002 nadejda
 * BASES
        BANK COMM
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vcps.

def buffer b-vcps for vcps.

def var v-dntypename as char.
run deftypename(vcps.dntype).

if vcps.dntype = "01" then do:
    find vcctcoms where vcctcoms.contract = vcps.contract and vcctcoms.codcomiss = "com-ps" no-error.
    if avail vcctcoms then delete vcctcoms.
end.

run vc2hisps (vcps.ps, "Документ удален").
run vc2hisct(vcps.contract,'Документ удален. Тип - ' + vcps.dntype + '(' + v-dntypename + '); Номер - ' + vcps.dnnum + string(vcps.num) + ", дата " + string(vcps.dndate, "99/99/9999") + '.').

find vccontrs where vccontrs.contract = vcps.contract no-lock no-error.
if avail vccontrs then do:
    find last b-vcps where b-vcps.contract = vcps.contract and b-vcps.ps <> vcps.ps use-index main no-lock no-error.
    if avail b-vcps and ((vccontrs.ctsum <> b-vcps.sum / b-vcps.cursdoc-con) or (vccontrs.lastdate <> b-vcps.lastdate)) then do transaction on error undo, retry:
        find current vccontrs exclusive-lock.
        update vccontrs.ctsum = b-vcps.sum / b-vcps.cursdoc-con vccontrs.lastdate = b-vcps.lastdate.
        find current vccontrs no-lock.
    end.
end.

procedure deftypename.
    def input parameter dntype as char.
    dntype = trim(dntype).
    find first codfr where codfr.codfr = "vcdoc" and codfr.code = dntype no-lock no-error.
    if avail codfr then v-dntypename = trim(codfr.name[2]).
end procedure.




