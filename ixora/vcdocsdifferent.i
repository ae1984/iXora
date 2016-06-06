/* vcdocsdifferent.i
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание - Определение суммы платежей по типам документов Валютного Контроля, используется совместно с vcdocsdiffcoll_txb.i.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vccomexpdat.p,vccomcreddat.p,vccontrs.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/

def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumakt as deci.
def var v-sum as deci.
def var v-sumcheck as deci.

/* сумма ГТД по контракту */
v-sumgtd = 0.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsgtd) > 0 and vcdocs.dndate < s-dte no-lock:
    v-sumcheck = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

    if vcdocs.payret then v-sum = - v-sumcheck.
    else v-sum = v-sumcheck.

    accumulate v-sum(total).
end.
v-sumgtd = (accum total v-sum).

/* сумма платежных документов по контракту */
v-sumplat = 0.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and vcdocs.dndate < s-dte no-lock:
    v-sumcheck = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

    if vcdocs.payret then v-sum = - v-sumcheck.
    else v-sum = v-sumcheck.

    accumulate v-sum(total).
end.
v-sumplat = (accum total v-sum).

/*сумма актов по контракту */
v-sumakt = 0.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsakt) > 0 and vcdocs.dndate < s-dte no-lock:
    v-sumcheck = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

    if vcdocs.payret then v-sum = - v-sumcheck.
    else v-sum = v-sumcheck.

    accumulate v-sum(total).
end.
v-sumakt = (accum total v-sum).


