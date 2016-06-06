/* tr-vcrslcw.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на изменение записи в vcrslc
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        09.12.2002 nadejda
 * CHANGES
        29.09.2003 nadejda  - добавлена запись в историю при изменении признака состояния лицензии
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for write of vcrslc old oldvcrslc.

def var v-msg as char.
def var v-dntypename as char.
run deftypename(vcrslc.dntype).

vcrslc.udt = today.
vcrslc.uwho = userid("bank").

if vcrslc.contract <> oldvcrslc.contract then do:
    run vc2hisrslc (vcrslc.rslc, "Документ зарегистрирован, номер " + vcrslc.dnnum + ", дата " + string(vcrslc.dndate, "99/99/9999")).
    run vc2hisct(vcrslc.contract,'Документ зарегистрирован. Тип - ' + vcrslc.dntype + '(' + v-dntypename + '); Номер - ' + vcrslc.dnnum + ", дата " + string(vcrslc.dndate, "99/99/9999")).
end.
else do:
    v-msg = "".
    if vcrslc.dntype <> oldvcrslc.dntype then run str2msg("тип", oldvcrslc.dntype, vcrslc.dntype).
    if vcrslc.dnnum <> oldvcrslc.dnnum then run str2msg("номер", oldvcrslc.dnnum, vcrslc.dnnum).
    if vcrslc.dndate <> oldvcrslc.dndate then run str2msg("дата", if oldvcrslc.dndate = ? then "?" else string(oldvcrslc.dndate, "99/99/9999"), if vcrslc.dndate = ? then "?" else string(vcrslc.dndate, "99/99/9999")).
    if vcrslc.lastdate <> oldvcrslc.lastdate then run str2msg("посл.дата", if oldvcrslc.lastdate = ? then "?" else string(oldvcrslc.lastdate, "99/99/9999"), if vcrslc.lastdate = ? then "?" else string(vcrslc.lastdate, "99/99/9999")).
    if vcrslc.sum <> oldvcrslc.sum then run str2msg("сумма", trim(string(oldvcrslc.sum, ">>>,>>>,>>>,>>>,>>9.99")), trim(string(vcrslc.sum, ">>>,>>>,>>>,>>>,>>9.99"))).
    if vcrslc.info[1] <> oldvcrslc.info[1] then run str2msg("признак состояния", oldvcrslc.info[1], vcrslc.info[1]).
    if vcrslc.ncrc <> oldvcrslc.ncrc then run str2msg("валюта", string(oldvcrslc.ncrc), string(vcrslc.ncrc)).
    if vcrslc.cursdoc-con <> oldvcrslc.cursdoc-con then run str2msg("кросс-курс", trim(string(oldvcrslc.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.99")), trim(string(vcrslc.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.99"))).

    if v-msg <> "" then do:
        run vc2hisrslc(vcrslc.rslc, "Изменен документ : " + v-msg).
        run vc2hisct(vcrslc.contract,'Изменен документ. Тип - ' + vcrslc.dntype + '(' + v-dntypename + '); Номер - ' + vcrslc.dnnum + ", дата " + string(vcrslc.dndate, "99/99/9999") + '.' + v-msg).
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

