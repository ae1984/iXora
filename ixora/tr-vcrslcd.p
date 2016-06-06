/* tr-vcrslcd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vcrslc
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
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vcrslc.

def var v-dntypename as char.
run deftypename(vcrslc.dntype).

for each vcps where vcps.rslc = vcrslc.rslc exclusive-lock:
    vcps.rslc = 0.
end.

run vc2hisrslc(vcrslc.rslc, "Документ удален").
run vc2hisct(vcrslc.contract,'Документ удален. Тип - ' + vcrslc.dntype + '(' + v-dntypename + '); Номер - ' + vcrslc.dnnum + ", дата " + string(vcrslc.dndate, "99/99/9999") + '.').

procedure deftypename.
    def input parameter dntype as char.
    dntype = trim(dntype).
    find first codfr where codfr.codfr = "vcdoc" and codfr.code = dntype no-lock no-error.
    if avail codfr then v-dntypename = trim(codfr.name[2]).
end procedure.