/* tr-vcpsw.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на изменение записи vcps
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
        19.08.2003 nadejda - перенесла в редактирование ПС/ДЛ сверку валюты/суммы ПС/ДЛ с контрактом, а то триггеры зацикливались
        18.04.2008 galina - добавлена история для полей  СРОКИ, ВАЛЮТ.ОГОВОРКА, ФОРМЫ РАСЧЕТОВ, ВАЛЮТЫ ПЛАТЕЖА
        11.03.2011 damir  - перекомпиляцияв связи с добавлением поля opertyp
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for write of vcps old oldvcps.

{global.i}
{vc-crosscurs.i}

def var v-msg as char.
def var vp-num as integer.
def var sp as deci.
def var v-dntypename as char.
run deftypename(vcps.dntype).

def buffer buf-vcps for vcps.

vcps.udt = today.
vcps.uwho = userid("bank").

if vcps.contract <> oldvcps.contract then do:
    run vc2hisps (vcps.ps, "Документ зарегистрирован, номер " + vcps.dnnum + ", дата " + string(vcps.dndate, "99/99/9999")).
    run vc2hisct(vcps.contract,'Документ зарегистрирован. Тип - ' + vcps.dntype + '(' + v-dntypename + '); Номер - ' + vcps.dnnum + string(vcps.num) + ", дата " + string(vcps.dndate, "99/99/9999") + '.').
end.
else do:
    v-msg = "".
    if vcps.cdt <> oldvcps.cdt or vcps.cwho <> oldvcps.cwho then do:
        if vcps.cdt = ? then v-msg = "снят акцепт".
        else v-msg = "АКЦЕПТ".
    end.
    else do:
        if vcps.sum <> oldvcps.sum then run str2msg("сумма", trim(string(oldvcps.sum, ">>>,>>>,>>>,>>>,>>9.99")), trim(string(vcps.sum, ">>>,>>>,>>>,>>>,>>9.99"))).
        if vcps.ctvalpl <> oldvcps.ctvalpl then run str2msg("Валюты платежа", oldvcps.ctvalpl, vcps.ctvalpl).
        if vcps.ctvalogr <> oldvcps.ctvalogr then run str2msg("Валютyная оговорка", oldvcps.ctvalogr, vcps.ctvalogr).
        if vcps.ctterm <> oldvcps.ctterm then run str2msg("Сроки", oldvcps.ctterm, vcps.ctterm).
        if vcps.ctformrs <> oldvcps.ctformrs then run str2msg("Формы расчетов", oldvcps.ctformrs, vcps.ctformrs).
        if vcps.lastdate <> oldvcps.lastdate then run str2msg("посл.дата", string(oldvcps.lastdate, "99/99/9999"), string(vcps.lastdate, "99/99/9999")).
        if vcps.ncrc <> oldvcps.ncrc then run str2msg("валюта", string(oldvcps.ncrc), string(vcps.ncrc)).
        if vcps.dntype <> oldvcps.dntype then run str2msg("тип", oldvcps.dntype, vcps.dntype).
        if vcps.dnnum <> oldvcps.dnnum then run str2msg("номер", oldvcps.dnnum, vcps.dnnum).
        if vcps.dndate <> oldvcps.dndate then run str2msg("дата", string(oldvcps.dndate, "99/99/9999"), string(vcps.dndate, "99/99/9999")).
        if vcps.cursdoc-con <> oldvcps.cursdoc-con then run str2msg("кросс-курс", trim(string(oldvcps.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.999999")), trim(string(vcps.cursdoc-con, ">>>,>>>,>>>,>>>,>>9.999999"))).
        if vcps.dnnote[1] <> oldvcps.dnnote[1] then run str2msg("подпись от банка", oldvcps.dnnote[1], vcps.dnnote[1]).
        if vcps.dnnote[2] <> oldvcps.dnnote[2] then run str2msg("подпись от клиента", oldvcps.dnnote[2], vcps.dnnote[2]).
        if vcps.dnnote[3] <> oldvcps.dnnote[3] then run str2msg("подпись от таможни", oldvcps.dnnote[3], vcps.dnnote[3]).
        if vcps.dnnote[5] <> oldvcps.dnnote[5] then run str2msg("особые отметки", oldvcps.dnnote[5], vcps.dnnote[5]).
        if vcps.rslc <> oldvcps.rslc then do:
            if v-msg <> "" then v-msg = v-msg + ", ".
            if oldvcps.rslc = 0 then v-msg = v-msg + "добавлен документ : ".
            else do:
                find vcrslc where vcrslc.rslc = oldvcps.rslc no-lock no-error.
                if avail vcrslc then do:
                    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcrslc.dntype no-lock no-error.
                    v-msg = v-msg + trim(codfr.name[2]) + " N " + vcrslc.dnnum + " от " + string(vcrslc.dndate, "99/99/9999") + " на ".
                end.
            end.
            if vcps.rslc = 0 then v-msg = v-msg + " - документ удален".
            else do:
                find vcrslc where vcrslc.rslc = vcps.rslc no-lock no-error.
                if avail vcrslc then do:
                    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcrslc.dntype no-lock no-error.
                    v-msg = v-msg + trim(codfr.name[2]) + " N " + vcrslc.dnnum + " от " + string(vcrslc.dndate, "99/99/9999").
                end.
            end.
        end.
    end.

    if v-msg <> "" then do:
        run vc2hisps (vcps.ps, "Изменен документ : " + v-msg).
        run vc2hisct(vcps.contract,'Изменен документ. Тип - ' + vcps.dntype + '(' + v-dntypename + '); Номер - ' + vcps.dnnum + string(vcps.num) + ", дата " + string(vcps.dndate, "99/99/9999") + '.' + v-msg).
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


