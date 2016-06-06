/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2009 madiyar
 * BASES
        BANK TXB COMM
 * CHANGES
        25.02.2011 damir - изменил поля временой таблицы
                           добавил выборку, входные параметра rbr-filial
                           добавил вывод номер ЛКБК, дата ЛКБК.
                           все что  в комментах - это закомментил.

*/

{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.
def input parameter v-dte as date.


def shared temp-table rmztmp
    field cif like txb.cif.cif
    field depart as integer
    field cifname as char                   /* наименование клиента */
    field contract like vccontrs.contract
    field ctei as char
    field ctnum as char                     /* номер контракта */
    field ctdate as date                    /* дата контракта */
    field psnum as char                     /* номер паспорта сделки */
    field psnumnum as integer
    field ncrc like txb.ncrc.crc            /* валюта контракта */
    field cardnum as char                   /* номер лицевой карточки */
    field cardnumdt as char                 /* дата лицевой карточки */
    index main is primary cifname cif ctdate ctnum contract.

    /*field rmztmp_name     as char
    field rmztmp_k        as char
    field rmztmp_nc       as char
    field rmztmp_dt       as date
    field rmztmp_nps      as char
    field rmztmp_ncrc     as char
    field rmztmp_nlc      as char
    field rmztmp_sumlc    as deci
    field rmztmp_sumlcUSD as deci.*/

def shared var v-reptype as char.
def var v-depart as integer.

for each vccontrs where (vccontrs.bank = p-vcbank) and vccontrs.cardnum <> "" and vccontrs.ctdate <= v-dte
use-index main no-lock break by vccontrs.cif: /* контракты имеющие лицевые карточки */
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        /*v-depart = integer(txb.cif.jame) mod 1000.*/
        /*if p-depart <> 0 and v-depart <> p-depart then next.
        if vccontrs.ctdate > v-dte then next.*/
        /*if v-reptype <> "A" and vccontrs.cardtype <> v-reptype then next.*/ /*если не все - A и типа не соответствует N то переходим к следующему*/

        /*v-name = ''.
        v-pssd = ''.*/
        /*if avail vccontrs then ctnum   = vccontrs.ctnum.*/    /* номер контракта */
        /*if avail vccontrs then ctdate  = vccontrs.ctdate.*/   /* дата контракта */
        /*if avail vccontrs then cardnum = vccontrs.cardnum.*/ /* номер лицевой карточки */
        /*find first txb.cif where txb.cif.cif = vccontrs.cif no-lock  no-error.*/  /* Наименование клиента */
        /*if avail txb.cif then do:
            v-dep = integer(txb.cif.jame).
            v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
        end.
        else v-name = vccontrs.cif.*/  /* если не найден, то выводим cif клиента */
        /*v-dep = v-dep - 1000.*/

        /* Номер паспорта сделки */

        create rmztmp.
        assign
        rmztmp.cif = txb.cif.cif
        rmztmp.depart = integer(txb.cif.jame) mod 1000
        rmztmp.cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix))
        rmztmp.contract = vccontrs.contract
        rmztmp.ctei = vccontrs.expimp
        rmztmp.ctnum = vccontrs.ctnum
        rmztmp.ctdate = vccontrs.ctdate.
        rmztmp.ncrc = vccontrs.ncrc.
        find first vcps where vcps.contract = rmztmp.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then do:
            rmztmp.psnum = vcps.dnnum.
            rmztmp.psnumnum = vcps.num.
        end.
        else
        rmztmp.psnum = "".
        find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "40" no-lock no-error.
        if avail vcdocs then do:
            rmztmp.cardnum = vccontrs.cardnum.
            rmztmp.cardnumdt = vccontrs.cardformmc.
        end.
        else
        rmztmp.psnum = "".
    end.
end.




        /* Валюта платежа */
        /*find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.*/

        /* Сумма лицевой карточки */
        /*def var v-sum as deci no-undo.
        def var v-failsum as deci no-undo.
        def var v-failsumUSD as deci no-undo.

        def temp-table t-docs0
            field docs like vcdocs.docs
            field dndate like vcdocs.dndate
            field dnnum like vcdocs.dnnum
            index main is primary dndate dnnum docs.

        def temp-table t-docs
            field data20 as date
            field sum20 as deci
            field sumret20 as deci
            field data30 as date
            field sum30 as deci
            field sumret30 as deci.*/

        /*платеж*/
            /*for each t-docs0 no-lock:
                delete t-docs0.
            end.
            for each t-docs:
                delete t-docs.
            end.
            for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03")
            and vcdocs.dndate <= v-dt no-lock:
                create t-docs0.
                buffer-copy vcdocs to t-docs0.
            end.
            for each t-docs0:
                create t-docs.
                find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.
                v-sum = vcdocs.sum / vcdocs.cursdoc-con.
            end.
            if vccontrs.expimp = "i" then do:
                if vcdocs.payret then t-docs.sumret20 = v-sum.
                else t-docs.sum20 = v-sum.
            end.
            else do:
                if vcdocs.payret then t-docs.sumret30 = v-sum.
                else t-docs.sum30 = v-sum.
            end.*/


            /*ГТД*/
            /*for each t-docs0. delete t-docs0. end.
            for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "14"
            and vcdocs.dndate <= v-dt no-lock:
            create t-docs0.
            buffer-copy vcdocs to t-docs0.
            end.

            for each t-docs0:
            create t-docs.
            find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.
            v-sum = vcdocs.sum / vcdocs.cursdoc-con.
            if vccontrs.expimp = "i" then do:
            if vcdocs.payret then t-docs.sumret30 = v-sum.
            else t-docs.sum30 = v-sum.
            end.
            else do:
            if vcdocs.payret then t-docs.sumret20 = v-sum.
            else t-docs.sum20 = v-sum.
            end.
            end.
            for each t-docs:
            accumulate (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30) (total).
            end.
            v-failsum = accum total (t-docs.sum20 - t-docs.sumret20) - (t-docs.sum30 - t-docs.sumret30).*/

            /* Сумма лицевой карточки (эквивалент в USD) */
            /*if vccontrs.ncrc = 2 then
            v-failsumUSD = v-failsum.
            else do:
            find last crchis where crchis.crc = vccontrs.ncrc and crchis.regdt <= v-dt no-lock no-error.
            if avail crchis then v-failsumUSD = v-failsum * crchis.rate[1].
            find last crchis where crchis.crc = 2 and crchis.regdt <= v-dt no-lock no-error.
            if avail crchis then v-failsumUSD = v-failsumUSD / crchis.rate[1].
            end.*/

          /*create  rmztmp.
            assign rmztmp.rmztmp_name  =  v-name.
                   rmztmp.rmztmp_k     =  '1'.
                   rmztmp.rmztmp_nc    =  vccontrs.ctnum.
                   rmztmp.rmztmp_dt    =  vccontrs.ctdate.
                   rmztmp.rmztmp_nps   =  v-pssd.
                   rmztmp.rmztmp_ncrc  =  ncrc.code.
                   rmztmp.rmztmp_nlc   =  vccontrs.cardnum.
                   rmztmp.rmztmp_sumlc =  v-failsum.
                   rmztmp.rmztmp_sumlcUSD = v-failsumUSD.*/

