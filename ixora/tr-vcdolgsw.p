/* tr-vcdolgsw.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на изменение записи в vcdolgs.
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
        24.06.2004 saltanat
 * BASES
        BANK COMM
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for write of vcdolgs old oldvcdolgs.

def var v-msg as char.
def var v-oldsv as char.
def var v-newsv as char.

vcdolgs.udt = today.
vcdolgs.uwho = userid("bank").
v-oldsv = "".
v-newsv = "".

def var v-dntypename as char.
run deftypename(vcdolgs.dntype).

if vcdolgs.contract <> oldvcdolgs.contract then do:
    run vc2hisdolgs(vcdolgs.dolgs, "Документ зарегистрирован, номер " + vcdolgs.dnnum + ", дата " + string(vcdolgs.dndate, "99/99/9999")).
    run vc2hisct(vcdolgs.contract,'Документ зарегистрирован. Тип - ' + vcdolgs.dntype + '(' + v-dntypename + '); Номер - ' + vcdolgs.dnnum + ", дата " + string(vcdolgs.dndate, "99/99/9999") + '.').
end.
else do:
    v-msg = "".
    if vcdolgs.dntype <> oldvcdolgs.dntype then run str2msg("тип", oldvcdolgs.dntype, vcdolgs.dntype).
    if vcdolgs.dnnum <> oldvcdolgs.dnnum then run str2msg("номер", oldvcdolgs.dnnum, vcdolgs.dnnum).
    if vcdolgs.dnvn <> oldvcdolgs.dnvn then run str2msg("дата внесения", string(oldvcdolgs.dnvn, "99/99/9999"), string(vcdolgs.dnvn, "99/99/9999")).
    if vcdolgs.dnpg <> oldvcdolgs.dnpg then run str2msg("дата погаш. долга", string(oldvcdolgs.dnpg, "99/99/9999"), string(vcdolgs.dnpg, "99/99/9999")).
    if vcdolgs.pdt <> oldvcdolgs.pdt then run str2msg("дата погашения", string(oldvcdolgs.pdt, "99/99/9999"), string(vcdolgs.pdt, "99/99/9999")).
    if vcdolgs.pwho <> oldvcdolgs.pwho then run str2msg("кто погасил", oldvcdolgs.pwho, vcdolgs.pwho).
    if vcdolgs.dndate <> oldvcdolgs.dndate then run str2msg("дата", string(oldvcdolgs.dndate, "99/99/9999"), string(vcdolgs.dndate, "99/99/9999")).
    if vcdolgs.sumpercent <> oldvcdolgs.sumpercent then run str2msg("проценты от суммы", oldvcdolgs.sumpercent, vcdolgs.sumpercent).
    if trim(vcdolgs.info[2]) <> trim(oldvcdolgs.info[2]) then run str2msg("код оплаты процентов", oldvcdolgs.info[2], vcdolgs.info[2]).
    if vcdolgs.pcrc <> oldvcdolgs.pcrc then run str2msg("валюта", string(oldvcdolgs.pcrc), string(vcdolgs.pcrc)).
    if vcdolgs.sum <> oldvcdolgs.sum then run str2msg("сумма", string(oldvcdolgs.sum,'>>>,>>>,>>>,>>>,>>9.999999'), string(vcdolgs.sum,'>>>,>>>,>>>,>>>,>>9.999999')).
    if vcdolgs.cursdoc-con <> oldvcdolgs.cursdoc-con then run str2msg("кросс-курс", string(oldvcdolgs.cursdoc-con,'>>>,>>>,>>>,>>>,>>9.999999'), string(vcdolgs.cursdoc-con,'>>>,>>>,>>>,>>>,>>9.999999')).
    if trim(vcdolgs.info[4]) <> trim(oldvcdolgs.info[4]) then run str2msg("инопартнер", oldvcdolgs.info[4], vcdolgs.info[4]).
    if vcdolgs.knp <> oldvcdolgs.knp then run str2msg("код назначения платежа", oldvcdolgs.knp, vcdolgs.knp).
    if vcdolgs.origin <> oldvcdolgs.origin then run str2msg("оригинал", string(oldvcdolgs.origin), string(vcdolgs.origin)).
    if vcdolgs.kod14 <> oldvcdolgs.kod14 then run str2msg("форма расчетов", oldvcdolgs.kod14, vcdolgs.kod14).

    v-oldsv = oldvcdolgs.dopsv + " " + oldvcdolgs.info[1] + " " + oldvcdolgs.info[3].
    v-newsv = vcdolgs.dopsv + " " + vcdolgs.info[1] + " " + vcdolgs.info[3].
    if v-oldsv <> v-newsv then run str2msg("примечание", v-oldsv, v-newsv).

    if v-msg <> "" then do:
        run vc2hisdolgs(vcdolgs.dolgs, "Изменен документ : " + v-msg).
        run vc2hisct(vcdolgs.contract,'Изменен документ. Тип - ' + vcdolgs.dntype + '(' + v-dntypename + '); Номер - ' + vcdolgs.dnnum + ", дата " + string(vcdolgs.dndate, "99/99/9999") + '.' + v-msg).
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
