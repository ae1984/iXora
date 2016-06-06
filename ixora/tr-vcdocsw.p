/* tr-vcdocsw.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на изменение записи в vcdocs.
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
        14.08.2008 galina - поле код14 заменено на Форма расчета
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for write of vcdocs old oldvcdocs.

def var v-msg as char.
def var v-dntypename as char.
run deftypename(vcdocs.dntype).

vcdocs.udt = today.
vcdocs.uwho = userid("bank").

if vcdocs.contract <> oldvcdocs.contract then do:
    run vc2hisdocs(vcdocs.docs, "Документ зарегистрирован, номер " + vcdocs.dnnum + ", дата " + string(vcdocs.dndate, "99/99/9999")).
    run vc2hisct(vcdocs.contract,'Документ зарегистрирован. Тип - ' + vcdocs.dntype + '(' + v-dntypename + '); Номер - ' + vcdocs.dnnum  + ", дата " + string(vcdocs.dndate, "99/99/9999") + '.').
end.
else do:
    v-msg = "".
    if vcdocs.dntype <> oldvcdocs.dntype then run str2msg("тип", oldvcdocs.dntype, vcdocs.dntype).
    if vcdocs.dnnum <> oldvcdocs.dnnum then run str2msg("номер", oldvcdocs.dnnum, vcdocs.dnnum).
    if vcdocs.dndate <> oldvcdocs.dndate then run str2msg("дата", string(oldvcdocs.dndate, "99/99/9999"), string(vcdocs.dndate, "99/99/9999")).
    if vcdocs.pcrc <> oldvcdocs.pcrc then run str2msg("валюта", string(oldvcdocs.pcrc), string(vcdocs.pcrc)).
    if vcdocs.cursdoc-con <> oldvcdocs.cursdoc-con then run str2msg("кросс-курс", trim(string(oldvcdocs.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.999999")), trim(string(vcdocs.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.999999"))).
    if vcdocs.sum <> oldvcdocs.sum then run str2msg("сумма", trim(string(oldvcdocs.sum, ">>>,>>>,>>>,>>>,>>9.999999")), trim(string(vcdocs.sum, ">>>,>>>,>>>,>>>,>>9.999999"))).
    if vcdocs.sumpercent <> oldvcdocs.sumpercent then run str2msg("проценты от суммы", oldvcdocs.sumpercent, vcdocs.sumpercent).
    if trim(vcdocs.info[1]) <> trim(oldvcdocs.info[1]) then run str2msg("примечание", oldvcdocs.info[1], vcdocs.info[1]).
    if vcdocs.payret <> oldvcdocs.payret then run str2msg("возврат", string(oldvcdocs.payret), string(vcdocs.payret)).
    if vcdocs.knp <> oldvcdocs.knp then run str2msg("КНП", oldvcdocs.knp, vcdocs.knp).
    if vcdocs.kod14 <> oldvcdocs.kod14 then run str2msg("форма расчета", oldvcdocs.kod14, vcdocs.kod14).
    if vcdocs.remtrz <> oldvcdocs.remtrz then run str2msg("REMTRZ", oldvcdocs.remtrz, vcdocs.remtrz).
    if trim(vcdocs.info[2]) <> trim(oldvcdocs.info[2]) then run str2msg("код оплаты процентов", oldvcdocs.info[2], vcdocs.info[2]).
    if trim(vcdocs.info[4]) <> trim(oldvcdocs.info[4]) then run str2msg("инопартнер", oldvcdocs.info[4], vcdocs.info[4]).
    if trim(vcdocs.numdc) <> trim(oldvcdocs.numdc) then run str2msg("номер ДС", oldvcdocs.numdc, vcdocs.numdc).
    if vcdocs.datedc <> oldvcdocs.datedc then run str2msg("дата ДС", string(oldvcdocs.datedc, "99/99/9999"), string(vcdocs.datedc, "99/99/9999")).
    if trim(vcdocs.numnewps) <> trim(oldvcdocs.numnewps) then run str2msg("номер ПС", oldvcdocs.numnewps, vcdocs.numnewps).
    if vcdocs.datenewps <> oldvcdocs.datenewps then run str2msg("дата ПС", string(oldvcdocs.datenewps, "99/99/9999"), string(vcdocs.datenewps, "99/99/9999")).

    if v-msg <> "" then do:
        run vc2hisdocs(vcdocs.docs, "Изменен документ : " + v-msg).
        run vc2hisct(vcdocs.contract,'Изменен документ. Тип - ' + vcdocs.dntype + '(' + v-dntypename + '); Номер - ' + vcdocs.dnnum + ", дата " + string(vcdocs.dndate, "99/99/9999") + '.' + v-msg).
    end.
end.

procedure str2msg.
    def input parameter p-field as char.
    def input parameter p-old as char.
    def input parameter p-new as char.

    if v-msg <> "" then v-msg = v-msg + ", ".
    v-msg = v-msg + p-field + " с '" + p-old + "' на '" + p-new + "'".
end procedure.

procedure deftypename.
    def input parameter dntype as char.
    dntype = trim(dntype).
    find first codfr where codfr.codfr = "vcdoc" and codfr.code = dntype no-lock no-error.
    if avail codfr then v-dntypename = trim(codfr.name[2]).
end procedure.

