/* AMLoff.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Оффлайновая выгрузка операций за период
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
        29/06/2010 galina
 * BASES
        BANK COMM TXB
 * CHANGES
        12/07/2010 galina - выгрузка операций без открытия счета (включая переводы метроэкспресс)
        16/07/2010 galina - исх. операции без открытия счета - исключили ГК 287032
        19/07/2010 galina - исправление по обменным операциям
        22/07/2010 galina - добавила поля regwho и regbank
        28/07/2010 galina - оправила определение номера rmz на филиале
        26/08/2010 madiyar - новые параметры в вызове kfmAMLOffline (пока не заполняются)
        27/08/2010 madiyar - заполняем новые параметры
        31/08/2010 galina - убрала повторную выгрузку
        21/10/2010 galina - сиключила пополнение транзитного 287032 через кассу
                            выгружаем операции, если нет дебитового клиента
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор

*/

def shared var v-dt1 as date.
def shared var v-dt2 as date.
def var v-rmzf as char no-undo.

def var v-clecod as char no-undo.
v-clecod = "".
find txb.sysc where txb.sysc.sysc = "clecod" no-lock no-error.
if avail txb.sysc then v-clecod = txb.sysc.chval.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

hide message no-pause.
message txb.sysc.chval + " - jou".

def var lgrList as char no-undo init "181,182,183,184,189,190,191,192,193,198,199".

def var v-path as char no-undo.
v-path = '/data/b'.

def var v-fmCash as logi no-undo. /* касса */
def var v-fmCashDir as char no-undo.
def var v-fmAcc as logi no-undo. /* клиентский счет */
def var v-fmAccDir as char no-undo.
def var v-fmTrNoAcc as logi no-undo. /* перевод без открытия счета */
def var v-fmTrNoAccDir as char no-undo.

def var v-fmNewClient as logi no-undo.
def var v-fmMessage as char no-undo.
def var v-fmCifCheck as char no-undo.
def var v-fmSameClient as logi no-undo.
def var v-fmBreak as logi no-undo.

def var v-dClientType as char no-undo.     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
def var v-cClientType as char no-undo.     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
def var v-debitClientId as char no-undo.   /* id клиента Дт */
def var v-creditClientId as char no-undo.  /* id клиента Кт */
def var v-docType as char no-undo.
def var v-docC as char no-undo.
def var v-bnname as char no-undo.
def var v-regwho as char no-undo.

def var v-debitBank as char no-undo.
def var v-creditBank as char no-undo.


for each txb.joudoc where txb.joudoc.whn >= v-dt1 and txb.joudoc.whn <= v-dt2 no-lock:
    if txb.joudoc.jh = ? then next.
    find first txb.jh where txb.jh.jh = txb.joudoc.jh no-lock no-error.
    if (not avail txb.jh) or (txb.jh.jdt < v-dt1) or (txb.jh.jdt > v-dt2) then next.

    if txb.joudoc.cracctype = "5" then next.

    find first amloffline where amloffline.bank = txb.sysc.chval and amloffline.operCode = txb.joudoc.docnum and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-bnname = ''.

    v-fmCash = no.
    v-fmCashDir = ''.
    if txb.joudoc.dracctype = "1" or txb.joudoc.cracctype = "1" or txb.joudoc.dracctype = "4" or txb.joudoc.cracctype = "4" then do:
        if txb.joudoc.dracctype = "1" then do:
            v-fmCash = yes.
            v-fmCashDir = 'D'.
        end.
        else
        if txb.joudoc.dracctype = "4" then do:
            find first txb.arp where txb.arp.arp = txb.joudoc.dracc no-lock no-error.
            if avail txb.arp and txb.arp.gl = 100200 then do:
                v-fmCash = yes.
                v-fmCashDir = 'D'.
            end.
        end.

        if txb.joudoc.cracctype = "1" then do:
            v-fmCash = yes.
            if v-fmCashDir = 'D' then v-fmCashDir = 'B'.
            else v-fmCashDir = 'C'.
        end.
        else
        if txb.joudoc.cracctype = "4" then do:
            find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
            if avail txb.arp and txb.arp.gl = 100200 then do:
                v-fmCash = yes.
                if v-fmCashDir = 'D' then v-fmCashDir = 'B'.
                else v-fmCashDir = 'C'.
            end.
        end.
    end.

    v-fmAcc = no.
    v-fmAccDir = ''.
    if txb.joudoc.dracctype = "2" or txb.joudoc.cracctype = "2" then do:
        v-fmAcc = yes.
        if txb.joudoc.dracctype = "2" and txb.joudoc.cracctype = "2" then v-fmAccDir = 'B'.
        else do:
            if txb.joudoc.dracctype = "2" then v-fmAccDir = 'D'.
            else v-fmAccDir = 'C'.
        end.
    end.

    v-fmCifCheck = ''.
    v-fmSameClient = no.
    if v-fmAcc and v-fmAccDir = 'B' then do:
        find first txb.aaa where txb.aaa.aaa = txb.joudoc.dracc no-lock no-error.
        if avail txb.aaa then do:
            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            if avail txb.cif then v-fmCifCheck = txb.cif.cif.
        end.
        find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
        if avail txb.aaa then do:
            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            if avail txb.cif then do:
                if v-fmCifCheck = txb.cif.cif then v-fmSameClient = yes.
            end.
        end.
    end.

    v-fmTrNoAcc = no.
    v-fmTrNoAccDir = ''.
    if v-fmCash and (txb.joudoc.dracctype = "4" or txb.joudoc.cracctype = "4") then do:
        if v-fmCashDir = "D" then do:
            if txb.joudoc.cracctype = "4" then do:
                find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
                if avail arp and arp.gl = 287032 then next.
                if avail txb.arp and (txb.arp.gl = 287034 or txb.arp.gl = 287035 or txb.arp.gl = 287036 or txb.arp.gl = 287037 or txb.arp.gl = 287033 /*or arp.gl = 287032*/ ) then do:
                    v-fmTrNoAcc = yes.
                    v-fmTrNoAccDir = 'C'.
                end.
            end.
        end.
        else
        if v-fmCashDir = "C" then do:
            if txb.joudoc.dracctype = "4" then do:
                find first txb.arp where txb.arp.arp = txb.joudoc.dracc no-lock no-error.
                if avail txb.arp and (txb.arp.gl = 287032 or txb.arp.gl = 187034 or txb.arp.gl = 187035 or txb.arp.gl = 187036 or txb.arp.gl = 187037 or txb.arp.gl = 187033) then do:
                    v-fmTrNoAcc = yes.
                    v-fmTrNoAccDir = 'D'.
                end.
            end.
        end.
    end.

    /*if v-fmTrNoAcc then next.
    if v-fmCashDir = 'B' then next.*/
    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-docC = ''.

    if v-fmAcc then do:
        if v-fmAccDir = 'D' or v-fmAccDir = 'B' then do:
            find first txb.aaa where txb.aaa.aaa = txb.joudoc.dracc no-lock no-error.
            if avail txb.aaa then do:
                if lookup(txb.aaa.lgr,lgrList) > 0 then assign v-dClientType = 'bank' v-debitClientId = txb.sysc.chval.
                else assign v-dClientType = 'cif' v-debitClientId = txb.aaa.cif.
                if v-fmCash and v-fmCashDir = 'C' then do:
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif then do:
                        if txb.cif.type = 'B' then v-docType = '9'.
                        else v-docType = '7'.
                    end.
                end.
                if v-fmAccDir = 'D' and not v-fmCash then do:
                    v-doctype = '5'.
                    v-creditClientId = txb.sysc.chval.
                    v-cClientType = 'bank'.
                end.
                if v-fmAccDir = 'B' then v-doctype = '5'.
            end.
        end.
        if v-fmAccDir = 'C' or v-fmAccDir = 'B' then do:
            find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
            if avail txb.aaa then do:
                if lookup(txb.aaa.lgr,lgrList) > 0 then assign v-cClientType = 'bank' v-creditClientId = txb.sysc.chval.
                else assign v-cClientType = 'cif' v-creditClientId = txb.aaa.cif.
                if v-fmCash and v-fmCashDir = 'D' then do:
                    find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
                    if avail txb.lgr then do:
                        if (txb.lgr.led = 'CDA' or txb.lgr.led = 'TDA') then do:
                            find first txb.pipl where txb.pipl.cif = txb.aaa.cif no-lock no-error.
                            if avail txb.pipl then v-docType = '8'.
                            else v-docType = '6'.
                        end.
                        else v-docType = '6'.
                    end.
                    else /* !!!!!!!!!! */ next.
                end.
                if v-fmAccDir = 'C' and not v-fmCash then do:
                    v-doctype = '5'.
                    v-debitClientId = txb.sysc.chval.
                    v-dClientType = 'bank'.
                end.
            end.
        end.
    end.
    v-docC = 'jou'.
    if not v-fmAcc then do:
        if v-fmTrNoAcc then do:
            v-docType = '10'.
            if v-fmTrNoAccDir = 'C' then do:
                v-debitClientId = txb.joudoc.kfmcif.
                if v-debitClientId begins 'cm' then v-dClientType = 'cifm'.
                else  v-dClientType = 'cif'.
            end.
            else do:
                v-creditClientId = txb.joudoc.kfmcif.
                if v-creditClientId begins 'cm' then v-cClientType = 'cifm'.
                else  v-cClientType = 'cif'.

            end.
        end.
        else if v-fmCashDir = 'B' and txb.joudoc.dracctype = "1" and txb.joudoc.cracctype = "1" then do:
            v-docType = '5'.
            v-docC = 'exc'.
             v-debitClientId = txb.joudoc.kfmcif.
             if v-debitClientId begins 'cm' then v-dClientType = 'cifm'.
             else v-dClientType = 'cif'.
             v-creditClientId = v-debitClientId.
             v-cClientType = v-dClientType.
        end.
        else if v-fmCashDir = 'B' and (txb.joudoc.dracctype <> "1" or txb.joudoc.cracctype <> "1") then next.
        else do:
            if v-fmCash then v-doctype = '4'.
            else v-doctype = '5'.
            v-debitClientId = txb.sysc.chval.
            v-dClientType = 'bank'.
            v-creditClientId = txb.sysc.chval.
            v-cClientType = 'bank'.
        end.
    end.

    run kfmAMLOffline(txb.sysc.chval,
                      txb.joudoc.docnum,      /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      v-docC,          /*категория документа*/
                      v-docType,         /*тип документа*/
                      txb.joudoc.who,
                      txb.sysc.chval,
                      '',
                      '').
end.


hide message no-pause.
message txb.sysc.chval + " - rmz".


for each txb.remtrz where ((txb.remtrz.valdt1 >= v-dt1) and (txb.remtrz.valdt1 <= v-dt2)) or ((txb.remtrz.valdt2 >= v-dt1) and (txb.remtrz.valdt2 <= v-dt2)) no-lock:
    if /*txb.remtrz.sbank <> txb.sysc.chval and*/ txb.remtrz.rbank <> txb.sysc.chval then next.
    if (txb.remtrz.jh1 = ?) or (txb.remtrz.jh2 = ?) then next.

    find first amloffline where amloffline.bank = txb.sysc.chval and amloffline.operCode = txb.remtrz.remtrz and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.
    /*
    if txb.remtrz.sbank = txb.sysc.chval then do:
        if txb.remtrz.rbank begins 'TXB' and length(txb.remtrz.rbank) = 5 then next.
            --только для единоразовой выгрузки--
        if txb.remtrz.outcode = 1 then next.
        if txb.remtrz.outcode = 6 then do:
            if txb.remtrz.drgl = 287032 then next.
            v-dClientType = 'bank'.
            v-debitClientId = txb.sysc.chval.
        end.

        if txb.remtrz.outcode = 3 then do:
            find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
            if not avail txb.aaa then next.
            if lookup(txb.aaa.lgr,lgrList) > 0 then assign v-dClientType = 'bank' v-debitClientId = txb.sysc.chval.
            else assign v-dClientType = 'cif' v-debitClientId = txb.aaa.cif.
        end.

        v-docType = '2'.
    end.
    */

    if txb.remtrz.rbank = txb.sysc.chval then do:
        find first txb.aaa where txb.aaa.aaa = txb.remtrz.cracc no-lock no-error.
        if not avail txb.aaa then do:
            find first txb.arp where txb.arp.arp = txb.remtrz.cracc no-lock no-error.
            if avail txb.arp then do:
                if txb.arp.gl = 287032 or txb.arp.gl = 287034 or txb.arp.gl = 287035 or txb.arp.gl = 287036 or txb.arp.gl = 287037 or txb.arp.gl = 287033 then next.
                v-cClientType = 'bank'.
                v-creditClientId = txb.sysc.chval.
            end.
        end.
        else do:
            if lookup(txb.aaa.lgr,lgrList) > 0 then assign v-cClientType = 'bank' v-creditClientId = txb.sysc.chval.
            else assign v-cClientType = 'cif' v-creditClientId = txb.aaa.cif.
        end.
        v-rmzf = ''.
        if txb.remtrz.sbank begins 'TXB' and length(txb.remtrz.sbank) = 5 then do:
            if txb.remtrz.sbank = txb.remtrz.rbank then assign v-docType = '5' v-rmzf = remtrz.remtrz.
            else assign v-docType = '3' v-rmzf = substr(txb.remtrz.sqn,index(txb.remtrz.sqn,'RMZ'),10).

            if connected ("ast") then disconnect "ast".
            find first comm.txb where comm.txb.bank = txb.remtrz.sbank and comm.txb.consolid no-lock no-error.
            if avail comm.txb then connect value ("-db " + replace(comm.txb.path,'/data/',v-path) + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password).
            run findtxbcif(txb.remtrz.sacc,v-rmzf, output v-dClientType, output v-debitClientId, output v-regwho).
            if connected ("ast") then disconnect "ast".
            /*if v-dClientType = "cif" and v-debitClientId = "" then next.*/
        end.
        else do:
            v-docType = '1'.
            v-bnname = entry(1,txb.remtrz.ord,'/').
        end.

        find first txb.jh where txb.jh.jh = txb.remtrz.jh2 no-lock no-error.
        if avail txb.jh then v-regwho = txb.jh.who.
    end.

    if v-dClientType = "bank" and v-cClientType = "bank" then next.

    if (txb.remtrz.sbank begins "txb") and (length(txb.remtrz.sbank) = 5) then v-debitBank = v-clecod.
    else v-debitBank = txb.remtrz.sbank.
    v-creditBank = v-clecod.

    run kfmAMLOffline(txb.sysc.chval,
                      txb.remtrz.remtrz, /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'rmz',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,
                      txb.sysc.chval,
                      v-debitBank,
                      v-creditBank).

end.

hide message no-pause.
message txb.sysc.chval + " - translat".

for each translat where translat.jh > 0 no-lock:
    if translat.jh-voz > 0 then next.
    find txb.nmbr where txb.nmbr.code = "translat" no-lock no-error.
    if not avail txb.nmbr then next.
    if substr(translat.nomer,1,4) <> txb.nmbr.pref then next.
    find first txb.jh where txb.jh.jh = translat.jh no-lock no-error.
    if not avail txb.jh then next.
    if txb.jh.jdt < v-dt1 or txb.jh.jdt > v-dt2 then next.

    find first amloffline where amloffline.bank = txb.sysc.chval and amloffline.operCode = translat.nomer and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.

    v-bnname = trim(trim(translat.rec-fam) + ' ' + trim(translat.rec-name) + ' ' + trim(translat.rec-otch)).
    v-debitClientId = translat.kfmcif.
    if v-debitClientId begins 'cm' then v-dClientType = 'cifm'.
    else v-dClientType = 'cif'.
    v-docType = '10'.
    v-regwho = ''.
    v-regwho = txb.jh.who.

    run kfmAMLOffline(txb.sysc.chval,
                      translat.nomer, /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'mxp',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,
                      txb.sysc.chval,
                      '',
                      '').
end.

hide message no-pause.
message txb.sysc.chval + " - r-translat".

for each r-translat where r-translat.jh > 0 no-lock:

    if r-translat.dt-otm <> ? then next.

    find txb.nmbr where txb.nmbr.code = "translat" no-lock no-error.
    if not avail txb.nmbr then next.
    if r-translat.rec-code <> txb.nmbr.pref then next.
    find first txb.jh where txb.jh.jh = r-translat.jh no-lock no-error.
    if not avail txb.jh then next.
    if txb.jh.jdt < v-dt1 or txb.jh.jdt > v-dt2 then next.

    find first amloffline where amloffline.bank = txb.sysc.chval and amloffline.operCode = r-translat.nomer and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-regwho = ''.
    v-regwho = txb.jh.who.
    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.

    v-bnname = trim(trim(r-translat.rec-fam) + ' ' + trim(r-translat.rec-name) + ' ' + trim(r-translat.rec-otch)).
    v-creditClientId = r-translat.kfmcif.
    if v-creditClientId begins 'cm' then v-cClientType = 'cifm'.
    else v-cClientType = 'cif'.
    v-docType = '10'.

    run kfmAMLOffline(txb.sysc.chval,
                      r-translat.nomer, /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'mxp',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,
                      txb.sysc.chval,
                      '',
                      '').

end.




