/* vcctsumm.p
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
*/      /* vcctsumm.p Валютный контроль
        Вычисление всяких сумм по контракту - оплаты, ГТД, контрольная, остаток и т.п.

        18.10.2002 nadejda создан
        05.12.2002 nadejda сумма с исключением заменена на сумму заемных средств (сумма с искл не используется)
        13.05.2008 galina - добавлен расчет суммы займа, оплаты процентов и платежей для контрактов типа 6  и конрольной суммы для конрактов типа 3
        06.06.2008 galina - добавления поля остаток непереведенных средств
        10.11.2008 galina - остаток неперведенных средств не считается, если не указана сумма контракта
        22.01.2009 galina - сумма актов равна акты минус возвраты актов
        21/06/2010 galina - отнимаем зачет- (тип документа 23) от платежей, прибавляем зачет+ (тип документа 24) к платежам
        07/09/2010 galina - учет актов по контарктам с ПС, если инопартнер в России или Белоруссии
        06.12.2010 aigul  - вывод в контрол суммы актов от Инопартнеров России или Белоруссии
        27.12.2010 aigul  - вывод суммы залогов
        27.01.2011 aigul  - в связи с изменением в vcdndlgs.p измнение вывода суммы залогов
        11.03.2011 damir  - перекомпиляция в связи с добавлением нового пля opertyp
        11.04.2011 damir  - изменен расчет КОНТРОЛ(v-sumkon) только экспортные по запросу Марины Нигматулиной
        29.06.2012 damir  - СУММА АКТОВ = СУММА Типов документов 17 и 07.
        13.07.2012 damir  - убрал проверку на страну инопартнера при расчете КОНТРОЛЬ - v-sumkon, ТИП Контракта 1.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        */
{vc.i}

def shared var s-contract   like vccontrs.contract.
def shared var v-sumgtd     as deci.
def shared var v-suminv     as deci.
def shared var v-suminv%    as deci.
def shared var v-sumplat    as deci.
def shared var v-sumkon     as deci.
def shared var v-sumost     as deci.
def shared var v-sumexc     as deci.
def shared var v-sumakt     as deci.
def shared var v-sumexc%    as deci.
def shared var v-sumzalog   as deci.
def shared var v-sumexc_6   as deci.
def shared var v-sumost1    as deci.


def var vp-sum as deci.
def var i as integer.
def var v-sts as char.
def var v-sumzachm as deci. /*зачет -*/
def var v-sumzachp as deci. /*зачет +*/

def temp-table t-dntype
    field dntype as char
    index dntype is primary dntype.

def var v-status as logic initial yes.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.

/* статус */
if lookup(vccontrs.sts, "a,s") > 0 or vccontrs.sts = "n" then do:
    find first vcps where vcps.contract = s-contract no-lock no-error.
    find first vcdocs where vcdocs.contract = s-contract no-lock no-error.
    if (lookup(vccontrs.sts, "a,s") > 0 and (not avail vcps) and (not avail vcdocs)) or (vccontrs.sts = "n" and ((avail vcps) or (avail vcdocs)))
    then do transaction on error undo, retry:
        v-sts = caps(vccontrs.sts).
        find current vccontrs exclusive-lock.
        if avail vccontrs then do:
            if lookup(vccontrs.sts, "a,s") > 0 then vccontrs.sts = "N".
            else vccontrs.sts = "A".
        end.
        find current vccontrs no-lock.
    end.
end.

if vccontrs.sts <> "N" then do:
    /* Инвойсы и др */
    for each t-dntype. delete t-dntype. end.
    for each codfr where codfr.codfr = "vcdoc" and (codfr.name[5] = "i" or codfr.name[5] = "u") no-lock:
        create t-dntype.
        t-dntype.dntype = codfr.code.
    end.
    v-suminv = 0.
    for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock:
        accumulate vcdocs.sum / vcdocs.cursdoc-con (total).
    end.
    v-suminv = (accum total vcdocs.sum / vcdocs.cursdoc-con).

    /* ГТД */
    for each t-dntype. delete t-dntype. end.
    for each codfr where codfr.codfr = "vcdoc" and codfr.name[5] = "g" no-lock:
        create t-dntype.
        t-dntype.dntype = codfr.code.
    end.
    v-sumgtd = 0.
    for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock:
        if vcdocs.payret then vp-sum = - vcdocs.sum.
        else vp-sum = vcdocs.sum.
        vp-sum = vp-sum / vcdocs.cursdoc-con.
        accumulate vp-sum (total).
    end.
    v-sumgtd = (accum total vp-sum).

    if vccontrs.cttype = '6' then do:
        /*сумма процентов по займу*/
        for each t-dntype. delete t-dntype. end.
        for each codfr where codfr.codfr = "vcdoc" and codfr.name[5] = "p" no-lock:
            create t-dntype.
            t-dntype.dntype = codfr.code.
        end.
        v-sumexc% = 0.
        for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and vcdocs.info[2] = '2' no-lock:
            if vcdocs.payret then vp-sum = - vcdocs.sum.
            else vp-sum = vcdocs.sum.
            vp-sum = vp-sum / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
        end.
        v-sumexc% = (accum total vp-sum).

        /*сумма полученного займа*/
        for each t-dntype. delete t-dntype. end.
        for each codfr where codfr.codfr = "vcdoc" and codfr.name[5] = "p" no-lock:
            create t-dntype.
            t-dntype.dntype = codfr.code.
        end.
        v-sumexc_6 = 0.
        for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and
        (if vccontrs.expimp = 'i' then vcdocs.dntype = '02' else vcdocs.dntype = '03') and vcdocs.info[2] = '1' no-lock:
            if vcdocs.payret then vp-sum = - vcdocs.sum.
            else vp-sum = vcdocs.sum.
            vp-sum = vp-sum / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
        end.
        v-sumexc_6 = (accum total vp-sum).

        /*погашение займа*/
        for each t-dntype. delete t-dntype. end.
        for each codfr where codfr.codfr = "vcdoc" and codfr.name[5] = "p" no-lock:
            create t-dntype.
            t-dntype.dntype = codfr.code.
        end.
        v-sumplat = 0.
        for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and
        (if vccontrs.expimp = 'i' then vcdocs.dntype = '03' else vcdocs.dntype = '02') and vcdocs.info[2] = '1' no-lock:
            if vcdocs.payret then vp-sum = - vcdocs.sum.
            else vp-sum = vcdocs.sum.
            vp-sum = vp-sum / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
        end.
        v-sumplat = (accum total vp-sum).
    end.
    else do:
        v-sumexc% = 0.
        v-sumexc_6 = 0.
    end.

    /* Платежные док-ты */
    if vccontrs.cttype <> '6' then do:
        for each t-dntype. delete t-dntype. end.
        for each codfr where codfr.codfr = "vcdoc" and codfr.name[5] = "p" no-lock:
            create t-dntype.
            t-dntype.dntype = codfr.code.
        end.
        v-sumplat = 0.
        for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock:
            if vcdocs.payret then vp-sum = - vcdocs.sum.
            else vp-sum = vcdocs.sum.
            vp-sum = vp-sum / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
        end.
        v-sumplat = (accum total vp-sum).
    end.

    /* Инвойсы и коносаменты - % от суммы */
    for each t-dntype. delete t-dntype. end.
    for each codfr where codfr.codfr = "vcdoc" and (codfr.name[5] = "i" or codfr.name[5] = "k") no-lock:
        create t-dntype.
        t-dntype.dntype = codfr.code.
    end.
    v-suminv% = 0.
    for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock:
        do i = 1 to num-entries(vcdocs.sumpercent) :
            vp-sum = vcdocs.sum * integer(entry(i, vcdocs.sumpercent)) / 100 / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
        end.
    end.
    v-suminv% = (accum total vp-sum).

    /* Акты */
    v-sumakt = 0.
    for each vcdocs where vcdocs.contract = s-contract and (vcdocs.dntype = "17" or vcdocs.dntype = "07") no-lock:
        /*accumulate vcdocs.sum / vcdocs.cursdoc-con (total).*/
        if vcdocs.payret then vp-sum = - vcdocs.sum.
        else vp-sum = vcdocs.sum.
        vp-sum = vp-sum / vcdocs.cursdoc-con.
        accumulate vp-sum (total).
    end.
    /*v-sumakt = (accum total vcdocs.sum / vcdocs.cursdoc-con).*/
    v-sumakt = (accum total vp-sum).

    /* Заемные средства */
    v-sumexc = 0.
    for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "30" no-lock:
        accumulate vcdocs.sum / vcdocs.cursdoc-con (total).
    end.
    v-sumexc = (accum total vcdocs.sum / vcdocs.cursdoc-con).
    /*зачет + и -*/
    v-sumzachm = 0.
    for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "23" no-lock:
        if vcdocs.payret then vp-sum = - vcdocs.sum.
        else vp-sum = vcdocs.sum.
        vp-sum = vp-sum / vcdocs.cursdoc-con.
        accumulate vp-sum (total).
    end.
    v-sumzachm = (accum total vp-sum).

    v-sumzachp = 0.
    for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "24" no-lock:
        if vcdocs.payret then vp-sum = - vcdocs.sum.
        else vp-sum = vcdocs.sum.
        vp-sum = vp-sum / vcdocs.cursdoc-con.
        accumulate vp-sum (total).
    end.
    v-sumzachp = (accum total vp-sum).
end.
else do:
    v-sumgtd = 0.
    v-sumplat = 0.
    v-suminv = 0.
    v-suminv% = 0.
    v-sumexc = 0.
    v-sumexc% = 0.
    v-sumexc_6 = 0.
end.

if entry(1, vccontrs.ctformrs) = "00" and (num-entries(vccontrs.ctformrs) = 1 or entry(2, vccontrs.ctformrs) = "00") then do:
    if v-suminv% > 0 then v-sumkon = v-suminv%.
    else v-sumkon = vccontrs.ctsum.
end.
else do:
    if entry(1, vccontrs.ctformrs) <> "00" then v-sumkon = v-sumgtd.
    else if vccontrs.expimp = "i" then v-sumkon = v-suminv% + v-sumgtd - v-sumexc.
    else if v-suminv% = 0 then v-sumkon = vccontrs.ctsum.
    else v-sumkon = v-suminv% - v-sumgtd.
end.

if vccontrs.cttype = '3' then do:
    v-sumkon = v-sumakt.
end.
if vccontrs.cttype = '1'  then do:
    v-sumkon = v-sumkon + v-sumakt.
end.

find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
if vccontrs.cttype = '2' then if avail vcpartner and (vcpartner.country = 'RU' or vcpartner.country = 'BY') then v-sumkon = v-sumkon + v-sumakt.

if vccontrs.cttype = '6' then do:
    v-sumost = v-sumplat - v-sumexc_6.
end.
else do:
    if vccontrs.expimp = "E" then v-sumost = v-sumakt + v-sumgtd - v-sumplat.
    else v-sumost = v-sumkon - v-sumplat.
end.

if vccontrs.ctsum > 0 then v-sumost1 = vccontrs.ctsum - v-sumplat.

v-sumzalog = 0.
def var v-sumout as decimal.
def var v-sumin as decimal.

for each vcdolgs where vcdolgs.contract = s-contract and ((vccontrs.expimp = 'i' and vcdolgs.dntype = '26') or
(vccontrs.expimp = 'e' and vcdolgs.dntype = '27') ) no-lock:
    if vcdolgs.payret then v-sumout = - vcdolgs.sum.
    else v-sumout = vcdolgs.sum.
    v-sumout = v-sumout / vcdolgs.cursdoc-con.
    accumulate v-sumout (total).
end.

for each vcdolgs where vcdolgs.contract = s-contract and
((vccontrs.expimp = 'i' and vcdolgs.dntype = '27') or (vccontrs.expimp = 'e' and vcdolgs.dntype = '26')) no-lock:
    if vcdolgs.payret = no then v-sumin = - vcdolgs.sum.
    else v-sumin = vcdolgs.sum.
    v-sumin = v-sumin / vcdolgs.cursdoc-con.
    accumulate v-sumin (total).
end.

v-sumzalog = ((accum total v-sumout) - (accum total v-sumin)).

def var v-count as integer.
def var v-st as logic initial no.
def var v-st1 as logic initial no.
def var v-checksum as decimal initial 0.

for each vcdolgs where vcdolgs.contract = s-contract and vccontrs.expimp = 'i' and vcdolgs.dntype = '26' no-lock:
    if vcdolgs.pcrc = 2 then v-checksum = vcdolgs.sum.
    else v-checksum = vcdolgs.sum / vcdolgs.cursdoc-con.
    if v-checksum > 100000 then do:
        if vcdolgs.pdt <> ? then do:
            v-count = integer(vcdolgs.pdt) - integer(vcdolgs.dndate).
            if (vcdolgs.pdt > vcdolgs.dndate) and (v-count > 180) then do:
                find first vcrslc where vcrslc.contract = vcdolgs.contract no-lock no-error.
                if not avail vcrslc then v-st = yes.
            end.
        end.
        else do:
           v-count = integer(today) - integer(vcdolgs.dndate).
           if v-count > 180 then do:
                find first vcrslc where vcrslc.contract = vcdolgs.contract no-lock no-error.
                if not avail vcrslc then v-st = yes.
            end.
        end.
    end.
end.

find first vcrslc where vcrslc.contract = s-contract no-lock no-error.
if not avail vcrslc then do:
    if v-st and v-sumzalog <> 0 then message "Срок возврата залога превышает 180 дней, сумма более 100 000!" SKIP
    "Необходима Регистрация в НБРК!" skip
    "Нельзя проводить платеж без РС!" view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end.

for each vcdolgs where vcdolgs.contract = s-contract and vccontrs.expimp = 'e' and vcdolgs.dntype = '27' no-lock:
    if vcdolgs.pcrc = 2 then v-checksum = vcdolgs.sum.
    else v-checksum = vcdolgs.sum / vcdolgs.cursdoc-con.
    if v-checksum > 500000 then do:
        if vcdolgs.pdt <> ? then do:
            v-count = integer(vcdolgs.pdt) - integer(vcdolgs.dndate).
            if (vcdolgs.pdt > vcdolgs.dndate) and (v-count > 180) then do:
                find first vcrslc where vcrslc.contract = vcdolgs.contract no-lock no-error.
                if not avail vcrslc then v-st1 = yes.
            end.
        end.
        else do:
           v-count = integer(today) - integer(vcdolgs.dndate).
           if v-count > 180 then do:
                find first vcrslc where vcrslc.contract = vcdolgs.contract no-lock no-error.
                if not avail vcrslc then v-st1 = yes.
            end.
        end.
    end.
end.

find first vcrslc where vcrslc.contract = s-contract no-lock no-error.
if not avail vcrslc then do:
    if v-st1 and v-sumzalog <> 0 then message "Срок возврата залога превышает 180 дней, сумма более 500 000!" SKIP
    "Необходима Регистрация в НБРК!" skip
    "Нельзя проводить платеж без РС!" view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end.


