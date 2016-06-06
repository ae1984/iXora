/* tr-vcctw.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        21.04.2008 galina - изменение валюты и кросс-курса в ПС перенесено в vccontrs, чтобы изменения в доп.листе не влияли на ПС.
        18.05.2009 galina - убрала транзакцию внутри транзакции
        13/08/2009 galina - добавила запись в историю для поля cadrnum
        09.10.2013 damir - Т.З. № 1670.
*/

/* tr-vcctw.p Валютный контроль
   Триггер на изменение записи в vccontrs

   09.12.2002 nadejda
*/

trigger procedure for write of vccontrs old oldvccontrs.

{vc.i}
{global.i}
{vc-crosscurs.i}

def var v-msg as char.
def var v-ourbnk as char.

function DelQues returns char(input str as char).
    if str = ? then return "".
    else return str.
end function.

v-msg = "".
do:
    vccontrs.udt = today.
    vccontrs.uwho = userid("bank").
end.

if vccontrs.contract <> oldvccontrs.contract and oldvccontrs.contract = 0 then do:
    vccontrs.ctregdt = g-today.
    vccontrs.ctdate = g-today.
    vccontrs.rdt = g-today.
    vccontrs.rwho = g-ofc.
    vccontrs.lastdate = date(12, 31, year(g-today)).

    run CorrAdd("CSTS",DelQues(vccontrs.sts),"Статус контракта",vccontrs.ctregdt).
    run CorrAdd("COPERTYP",DelQues(string(vccontrs.opertyp)),"Тип операции",vccontrs.ctregdt).

    run vc2hisct(vccontrs.contract, "Контракт зарегистрирован").
end.
else do:
    if vccontrs.ctnum <> oldvccontrs.ctnum then run str2msg("номер", oldvccontrs.ctnum, vccontrs.ctnum).
    vccontrs.sts = caps(vccontrs.sts).
    if vccontrs.sts <> oldvccontrs.sts then do:
        vccontrs.stsdt = g-today.
        run str2msg("статус", oldvccontrs.sts, vccontrs.sts).
        run CorrAdd("CSTS",DelQues(vccontrs.sts),"Статус контракта",if (vccontrs.sts = "C" or (vccontrs.sts <> "C" and vccontrs.opertyp = 3)) then vccontrs.stsdt else vccontrs.ctregdt).
    end.
    if vccontrs.opertyp <> oldvccontrs.opertyp then do:
        run str2msg("тип операции", oldvccontrs.opertyp, vccontrs.opertyp).
        run CorrAdd("COPERTYP",DelQues(string(vccontrs.opertyp)),"Тип операции",g-today).
    end.
    if vccontrs.cttype <> oldvccontrs.cttype then run str2msg("тип", oldvccontrs.cttype, vccontrs.cttype).
    if vccontrs.ctregnom <> oldvccontrs.ctregnom then run str2msg("номер по журналу", string(oldvccontrs.ctregnom, ">>>>>9"), string(vccontrs.ctregnom, ">>>>>9")).
    if vccontrs.ctregdt <> oldvccontrs.ctregdt then run str2msg("дата по журналу", string(oldvccontrs.ctregdt, "99/99/9999"), string(vccontrs.ctregdt, "99/99/9999")).
    if vccontrs.ctdate <> oldvccontrs.ctdate then run str2msg("дата", string(oldvccontrs.ctdate, "99/99/9999"), string(vccontrs.ctdate, "99/99/9999")).
    if vccontrs.ncrc <> oldvccontrs.ncrc then run str2msg("валюта", string(oldvccontrs.ncrc), string(vccontrs.ncrc)).
    if vccontrs.ctsum <> oldvccontrs.ctsum then do:
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" and (vcps.sum = 0 or vcps.sum = 1) and vcps.sum <> vccontrs.ctsum no-lock no-error.
        if avail vcps then do:
            message skip "Найден паспорт сделки с суммой, равной 0.00 или 1.00 !" skip(1)
                         "Присвоить паспорту сделки сумму контракта ?" skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! "
            update v-ch as logical.
            if v-ch then do:
                find current vcps exclusive-lock.
                vcps.sum = vccontrs.ctsum.
                find current vcps no-lock.
            end.
        end.
        run str2msg("сумма", trim(string(oldvccontrs.ctsum, ">>>,>>>,>>>,>>>,>>9.99")),trim(string(vccontrs.ctsum, ">>>,>>>,>>>,>>>,>>9.99"))).
    end.

    if vccontrs.cursdoc-usd <> oldvccontrs.cursdoc-usd then do:
        /* изменить кросс-курсы во всех документах */
        for each vcdocs where vcdocs.contract = vccontrs.contract share-lock:
            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
        end.

        for each vcps where vcps.contract = vccontrs.contract and vcps.dntype <> "01" share-lock:
            run crosscurs(vcps.ncrc, vccontrs.ncrc, vcps.dndate, output vcps.cursdoc-con).
        end.

        run str2msg("кросс-курс",trim(string(oldvccontrs.cursdoc-usd, ">>>,>>>,>>>,>>>,>>9.999999")),trim(string(vccontrs.cursdoc-usd, ">>>,>>>,>>>,>>>,>>9.999999"))).
    end.
    vccontrs.expimp = caps(vccontrs.expimp).
    if vccontrs.expimp <> oldvccontrs.expimp then run str2msg("эксп/имп", oldvccontrs.expimp, vccontrs.expimp).
    if vccontrs.lastdate <> oldvccontrs.lastdate then run str2msg("посл.дата", string(oldvccontrs.lastdate, "99/99/9999"),string(vccontrs.lastdate, "99/99/9999")).
    vccontrs.ctvalpl = caps(vccontrs.ctvalpl).
    if vccontrs.ctvalpl <> oldvccontrs.ctvalpl then run str2msg("валюты платежа", oldvccontrs.ctvalpl, vccontrs.ctvalpl).
    if vccontrs.ctformrs <> oldvccontrs.ctformrs then run str2msg("формы расчетов", oldvccontrs.ctformrs, vccontrs.ctformrs).
    if vccontrs.ctterm <> oldvccontrs.ctterm then run str2msg("сроки", oldvccontrs.ctterm, vccontrs.ctterm).
    if vccontrs.partner <> oldvccontrs.partner then run str2msg("партнер", oldvccontrs.partner, vccontrs.partner).
    if vccontrs.aaa <> oldvccontrs.aaa then run str2msg("счет для комиссии", oldvccontrs.aaa, vccontrs.aaa).
    if vccontrs.info[1] <> oldvccontrs.info[1] then run str2msg("валют.оговорка", oldvccontrs.info[1], vccontrs.info[1]).
    if vccontrs.info[2] <> oldvccontrs.info[2] then run str2msg("товар", oldvccontrs.info[2], vccontrs.info[2]).
    if vccontrs.info[3] <> oldvccontrs.info[3] then run str2msg("порт", oldvccontrs.info[3], vccontrs.info[3]).
    if vccontrs.cardnum <> oldvccontrs.cardnum then run str2msg("Номер ЛКБК", oldvccontrs.cardnum, vccontrs.cardnum).
    /*if vccontrs.sent105 <> oldvccontrs.sent105 then
    run str2msg("отправл.105", oldvccontrs.sent105, vccontrs.sent105).*/
    if v-msg <> "" then do:
        run vc2hisct(vccontrs.contract, "Изменен контракт : " + v-msg).
    end.
end.

procedure str2msg.
  def input parameter p-field as char.
  def input parameter p-old as char.
  def input parameter p-new as char.

  if v-msg <> "" then v-msg = v-msg + ", ".
  v-msg = v-msg + p-field + " с '" + p-old + "' на '" + p-new + "'".
end procedure.

procedure CorrAdd:
    def input parameter nm as char.
    def input parameter cr as char.
    def input parameter ds as char.
    def input parameter correctdt as date.

    create vccorrecthis.
    vccorrecthis.num = next-value(correct).
    vccorrecthis.contract = vccontrs.contract.
    vccorrecthis.correctdt = correctdt.
    vccorrecthis.who = g-ofc.
    vccorrecthis.bank = vccontrs.bank.
    vccorrecthis.sub = nm.
    vccorrecthis.corrfield = cr.
    vccorrecthis.des = ds.
    release vccorrecthis.
end procedure.