/* tr-vcdolgsd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vcdolgs
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
        24/06/04 saltanat
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vcdolgs.

def var v-dntypename as char.
run deftypename(vcdolgs.dntype).

run vc2hisdolgs(vcdolgs.dolgs, "Документ удален, номер " + vcdolgs.dnnum + ", дата " + string(vcdolgs.dndate, "99/99/9999")).
run vc2hisct(vcdolgs.contract,'Документ удален. Тип - ' + vcdolgs.dntype + '(' + v-dntypename + '); Номер - ' + vcdolgs.dnnum + ", дата " + string(vcdolgs.dndate, "99/99/9999")).

procedure deftypename.
    def input parameter dntype as char.
    dntype = trim(dntype).
    find first codfr where codfr.codfr = "vcdoc" and codfr.code = dntype no-lock no-error.
    if avail codfr then v-dntypename = trim(codfr.name[2]).
end procedure.

