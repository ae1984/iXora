 /* vcshowct.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Вывод контрактов и запись платежей в соотв-ий контракт
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
        07.02.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
                          07/09/2011 Luiza  - расширила формат  вывода порядкового номера контракта до 3 знаков
                                            (menu.num label '№' format "999") строка 61.
        11.10.2011 damir - добавил сохранение в vcdocshismt при создании ПлатДк.
        04.11.2011 damir - добавил vcdocscp.p.
        07.11.2011 damir - добавил присвоение номера исп.обязательств по порядку
        06.01.2012 damir - корректировки.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308..
*/


{global.i}
{vc-crosscurs.i}
{funcvc.i}

def input parameter p-cif as char.
def input parameter p-remtrz as char.
def input parameter p-remtrz-rdt as date.
def input parameter p-remtrz-crc as integer.
def input parameter p-remtrz-sum as decimal.
def input parameter p-knp as char.
def output parameter v-pr as logic initial no.
def var v-status   as logic initial no.
def var v-max      as inte.
def var num as inte.

def buffer b-bufdocs     for vcdocs.
def buffer b-bufvccontrs for vccontrs.
def buffer b-nmbrs for comm.nmbrs.

define new shared temp-table menu
    field num as int
    field contract as int
    field ctnum as char
    field ctdate as date
    field ctvalpl as char
    field crc as integer.

def var i as int init 0.

for each vccontrs where vccontrs.cif = p-cif no-lock break by vccontrs.ctdate:
    i = i + 1.
    create menu.
    assign menu.num = i.
    menu.contract = vccontrs.contract.
    menu.ctnum = vccontrs.ctnum.
    menu.ctdate = vccontrs.ctdate.
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.num label '№' format "999"
        menu.ctnum label 'Номер контракта' format "x(40)"
        menu.ctdate label 'Дата контракта'
        with 8 down width 70 title "Выберите контракт:".

def frame fr1
    b1
    with no-labels centered overlay width 75 row 8 view-as dialog-box.

on return of b1 in frame fr1 do:
    v-status = yes.
    apply "endkey" to frame fr1.
end.
open query q1 for each menu.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Ошибка".
    return.
end.

b1:title = "Выберите контракт:".
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.

def var v-sum-opl as decimal.
def var v-sum-gtd as decimal.
def var v-sum-akt as decimal.
def var vp-sum as decimal.
def var v-sumost as decimal.
def var v-sumplat as decimal.
def var v-curs as decimal.
def var p-remtrz-crc-new as decimal.
def new shared var s-docs as inte.
def buffer b-ncrchis for ncrchis.
def buffer b-vcdocs  for vcdocs.
if v-status = yes then do:
    v-sum-opl = 0.
    v-sum-gtd = 0.
    v-sum-akt = 0.
    for each vcdocs where vcdocs.contract = menu.contract and
    (vcdocs.dntype = "03" or vcdocs.dntype = "02") no-lock:
    if vcdocs.payret then vp-sum = - vcdocs.sum.
    else vp-sum = vcdocs.sum.
    vp-sum = vp-sum / vcdocs.cursdoc-con.
    v-sum-opl = v-sum-opl + vp-sum .
    end.
    find first vccontrs where vccontrs.contract = menu.contract no-lock no-error.
    if avail vccontrs then do:
        for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
            find last ncrchis where ncrchis.rdt <= vcdocs.dndate and ncrchis.crc = vccontrs.ncrc no-lock no-error.
            if avail ncrchis then do:
                find last b-ncrchis where b-ncrchis.rdt <= vcdocs.dndate and b-ncrchis.crc = vcdocs.pcrc no-lock
                no-error.
                if avail b-ncrchis then do:
                   if vcdocs.dntype = "14" then v-sum-gtd = v-sum-gtd + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
                   if vcdocs.dntype = "17" then v-sum-akt = v-sum-akt + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
                end.
            end.
        end.
    end.
    p-remtrz-crc-new = 0.
    v-sumost = (v-sum-gtd + v-sum-akt) - v-sum-opl.
    find first vccontrs where vccontrs.contract = menu.contract no-lock no-error.
    if avail vccontrs then do:
    if vccontrs.lastdate < g-today then do:
        message "Дата контракта истекла," skip
            "обратитесь к менеджеру валютного контроля!"  view-as alert-box title "Внимание!!!".
        return.
    end.
    run crosscurs(p-remtrz-crc, vccontrs.ncrc, p-remtrz-rdt, output v-curs).
        p-remtrz-crc-new = p-remtrz-sum / v-curs.
        if (vccontrs.ctsum < v-sum-opl +  p-remtrz-crc-new) or (/*v-sumost*/ vccontrs.ctsum <  p-remtrz-crc-new ) then do:
            message "Сумма платежа превышает сумму контракта," skip
            "обратитесь к менеджеру валютного контроля!"  view-as alert-box title "Внимание!!!".
            return.
        end.
    end.
    find first vcdocs where vcdocs.dnnum = p-remtrz no-lock no-error.
    if not avail vcdocs then do:
        find first vccontrs where vccontrs.contract = menu.contract no-lock no-error.
        if avail vccontrs then do:
            find ncrc where ncrc.crc = p-remtrz-crc no-lock no-error.
            if not avail ncrc then do:
                message " Недопустимый код валюты!" view-as alert-box.
                return.
            end.
            if lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
                message " Выбранная валюта не входит в список валют платежа по данному контракту!" view-as alert-box.
                return.
            end.

            /*--------------------------------------------------*/
            s-docs = 0.
            create vcdocs.
            assign
            vcdocs.docs = next-value(vc-docs).
            s-docs = vcdocs.docs.
            vcdocs.contract = menu.contract.
            if p-knp = '710' or (int(p-knp) >= 810 and int(p-knp) <= 870) or p-knp = '890' then vcdocs.dntype = "03".
            if p-knp = '880' then vcdocs.dntype = "02".
            if p-knp = '780' then vcdocs.dntype = "03".

            find cif where cif.cif = vccontrs.cif no-lock no-error.
            if not avail cif then do:
                message "Клиент " vccontrs.cif " отсутствует в базе" view-as alert-box.
                return.
            end.
            def var v-term as inte.
            if vccontrs.cttype = "6" and (vcdocs.dntype = "02" or vcdocs.dntype = "03") then do:
                v-term = 0.
                run check_term (vccontrs.contract, ?, ?, ?, ?, ?, output v-term).
                if vccontrs.expimp = "I" then do:
                    if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and (check_term(vccontrs.ctterm) > 180 or v-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                        find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
                        if not avail vcrslc then do:
                            message "В контракте отсутствует РС!" skip
                                    "Нельзя проводить платеж без РС!" view-as alert-box buttons ok.
                            return.
                        end.
                    end.
                end.
                else if vccontrs.expimp = "E" then do:
                    if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and (check_term(vccontrs.ctterm) > 180 or v-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                        find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
                        if not avail vcrslc then do:
                            message "В контракте отсутствует РС!" skip
                                    "Нельзя проводить платеж без РС!" view-as alert-box buttons ok.
                            return.
                        end.
                    end.
                end.
            end.

            vcdocs.rwho = g-ofc.
            vcdocs.rdt = g-today.
            vcdocs.dnnum = substr(p-remtrz,4,6).
            vcdocs.dndate = p-remtrz-rdt.
            if p-knp = '710' or (int(p-knp) >= 810 and int(p-knp) <= 870) or p-knp = '890' then vcdocs.payret = no.
            if p-knp = '780' or p-knp = '880' then vcdocs.payret = yes.
            vcdocs.sumpercent = "100".
            vcdocs.pcrc = p-remtrz-crc.
            vcdocs.sum = p-remtrz-sum.
            vcdocs.cursdoc-con = v-curs.
            vcdocs.cursdoc-usd = p-remtrz-sum / v-curs.
            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = p-remtrz
            and sub-cod.d-cod = 'eknp' no-lock no-error.
            if avail sub-cod then vcdocs.knp = substr(sub-cod.rcode,7,3).
            find first vccontrs where vccontrs.contract = menu.contract no-lock no-error.
            if avail vccontrs then vcdocs.info[4] = vccontrs.partner.
            vcdocs.origin = yes.
            if v-sum-gtd > v-sum-opl then vcdocs.kod14 = "13".
            if v-sum-gtd < v-sum-opl then vcdocs.kod14 = "14".
            v-pr = yes.

            if lookup(vcdocs.dntype,"02,03") > 0 then do:
                num = 0.
                run Ndoc("02,03,17,07",output num).
                find b-nmbrs where b-nmbrs.ccode = string(vccontrs.contract) exclusive-lock no-error.
                if not avail b-nmbrs then do:
                    create b-nmbrs.
                    b-nmbrs.ccode = string(vccontrs.contract).
                    b-nmbrs.descode = "Контракт ВалКон".
                    b-nmbrs.nmbr = num.
                end.
                b-nmbrs.nmbr = b-nmbrs.nmbr + 1.
                vcdocs.numobyaz = b-nmbrs.nmbr.
                release b-nmbrs.
            end.
        end.
    end.
end.

procedure Ndoc:
    def input parameter typ as char.
    def output parameter num as inte.
    def buffer b-vcdocs for comm.vcdocs.
    num = 0.
    for each b-vcdocs where b-vcdocs.contract = vccontrs.contract no-lock:
        if lookup(b-vcdocs.dntype,typ) = 0 then next.
        num = num + 1.
    end.
end procedure.
