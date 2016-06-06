/* AMLoff_f.p
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
        01/09/2010 galina - скопировала из AMLoff.p с изменениями
 * BASES
        BANK COMM
 * CHANGES
        21/10/2010 galina - сиключила пополнение транзитного 287032 через кассу
                            выгружаем операции, если нет дебитового клиента
        03/03/2011 madiyar - выгрузка операций по залогам
        04/03/2011 madiyar - подправил выборку doch
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

def shared var v-dt1 as date.
def shared var v-dt2 as date.
def var v-rmzf as char no-undo.


{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

hide message no-pause.
message sysc.chval + " - jou".

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
def var v-z as char no-undo.


for each joudoc where joudoc.whn >= v-dt1 and joudoc.whn <= v-dt2 no-lock:
    if joudoc.jh = ? then next.
    find first jh where jh.jh = joudoc.jh no-lock no-error.
    if (not avail jh) or (jh.jdt < v-dt1) or (jh.jdt > v-dt2) then next.

    if joudoc.cracctype = "5" then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = joudoc.docnum and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-bnname = ''.

    v-fmCash = no.
    v-fmCashDir = ''.
    if joudoc.dracctype = "1" or joudoc.cracctype = "1" or joudoc.dracctype = "4" or joudoc.cracctype = "4" then do:
        if joudoc.dracctype = "1" then do:
            v-fmCash = yes.
            v-fmCashDir = 'D'.
        end.
        else
        if joudoc.dracctype = "4" then do:
            find first arp where arp.arp = joudoc.dracc no-lock no-error.
            if avail arp and arp.gl = 100200 then do:
                v-fmCash = yes.
                v-fmCashDir = 'D'.
            end.
        end.

        if joudoc.cracctype = "1" then do:
            v-fmCash = yes.
            if v-fmCashDir = 'D' then v-fmCashDir = 'B'.
            else v-fmCashDir = 'C'.
        end.
        else
        if joudoc.cracctype = "4" then do:
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            if avail arp and arp.gl = 100200 then do:
                v-fmCash = yes.
                if v-fmCashDir = 'D' then v-fmCashDir = 'B'.
                else v-fmCashDir = 'C'.
            end.
        end.
    end.

    v-fmAcc = no.
    v-fmAccDir = ''.
    if joudoc.dracctype = "2" or joudoc.cracctype = "2" then do:
        v-fmAcc = yes.
        if joudoc.dracctype = "2" and joudoc.cracctype = "2" then v-fmAccDir = 'B'.
        else do:
            if joudoc.dracctype = "2" then v-fmAccDir = 'D'.
            else v-fmAccDir = 'C'.
        end.
    end.

    v-fmCifCheck = ''.
    v-fmSameClient = no.
    if v-fmAcc and v-fmAccDir = 'B' then do:
        find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
        if avail aaa then do:
            find first cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then v-fmCifCheck = cif.cif.
        end.
        find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
        if avail aaa then do:
            find first cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then do:
                if v-fmCifCheck = cif.cif then v-fmSameClient = yes.
            end.
        end.
    end.

    v-fmTrNoAcc = no.
    v-fmTrNoAccDir = ''.
    if v-fmCash and (joudoc.dracctype = "4" or joudoc.cracctype = "4") then do:
        if v-fmCashDir = "D" then do:
            if joudoc.cracctype = "4" then do:
                find first arp where arp.arp = joudoc.cracc no-lock no-error.
                if avail arp and arp.gl = 287032 then next.
                if avail arp and (arp.gl = 287034 or arp.gl = 287035 or arp.gl = 287036 or arp.gl = 287037 or arp.gl = 287033 /*or arp.gl = 287032*/ ) then do:
                    v-fmTrNoAcc = yes.
                    v-fmTrNoAccDir = 'C'.
                end.
            end.
        end.
        else
        if v-fmCashDir = "C" then do:
            if joudoc.dracctype = "4" then do:
                find first arp where arp.arp = joudoc.dracc no-lock no-error.
                if avail arp and (arp.gl = 287032 or arp.gl = 187034 or arp.gl = 187035 or arp.gl = 187036 or arp.gl = 187037 or arp.gl = 187033) then do:
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
            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            if avail aaa then do:
                if lookup(aaa.lgr,lgrList) > 0 then assign v-dClientType = 'bank' v-debitClientId = sysc.chval.
                else assign v-dClientType = 'cif' v-debitClientId = aaa.cif.
                if v-fmCash and v-fmCashDir = 'C' then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        if cif.type = 'B' then v-docType = '9'.
                        else v-docType = '7'.
                    end.
                end.
                if v-fmAccDir = 'D' and not v-fmCash then do:
                    v-doctype = '5'.
                    v-creditClientId = sysc.chval.
                    v-cClientType = 'bank'.
                end.
                if v-fmAccDir = 'B' then v-doctype = '5'.
            end.
        end.
        if v-fmAccDir = 'C' or v-fmAccDir = 'B' then do:
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            if avail aaa then do:
                if lookup(aaa.lgr,lgrList) > 0 then assign v-cClientType = 'bank' v-creditClientId = sysc.chval.
                else assign v-cClientType = 'cif' v-creditClientId = aaa.cif.
                if v-fmCash and v-fmCashDir = 'D' then do:
                    find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
                    if avail lgr then do:
                        if (lgr.led = 'CDA' or lgr.led = 'TDA') then do:
                            find first pipl where pipl.cif = aaa.cif no-lock no-error.
                            if avail pipl then v-docType = '8'.
                            else v-docType = '6'.
                        end.
                        else v-docType = '6'.
                    end.
                    else /* !!!!!!!!!! */ next.
                end.
                if v-fmAccDir = 'C' and not v-fmCash then do:
                    v-doctype = '5'.
                    v-debitClientId = sysc.chval.
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
                v-debitClientId = joudoc.kfmcif.
                if v-debitClientId begins 'cm' then v-dClientType = 'cifm'.
                else  v-dClientType = 'cif'.
            end.
            else do:
                v-creditClientId = joudoc.kfmcif.
                if v-creditClientId begins 'cm' then v-cClientType = 'cifm'.
                else  v-cClientType = 'cif'.

            end.
        end.
        else if v-fmCashDir = 'B' and joudoc.dracctype = "1" and joudoc.cracctype = "1" then do:
            v-docType = '5'.
            v-docC = 'exc'.
             v-debitClientId = joudoc.kfmcif.
             if v-debitClientId begins 'cm' then v-dClientType = 'cifm'.
             else v-dClientType = 'cif'.
             v-creditClientId = v-debitClientId.
             v-cClientType = v-dClientType.
        end.
        else if v-fmCashDir = 'B' and (joudoc.dracctype <> "1" or joudoc.cracctype <> "1") then next.
        else do:
            if v-fmCash then v-doctype = '4'.
            else v-doctype = '5'.
            v-debitClientId = sysc.chval.
            v-dClientType = 'bank'.
            v-creditClientId = sysc.chval.
            v-cClientType = 'bank'.
        end.
    end.

    run kfmAMLOffline(sysc.chval,
                      joudoc.docnum,      /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      v-docC,          /*категория документа*/
                      v-docType,         /*тип документа*/
                      joudoc.who,
                      sysc.chval,
                      '',
                      '').
end.


hide message no-pause.
message sysc.chval + " - rmz".


for each remtrz where ((remtrz.valdt1 >= v-dt1) and (remtrz.valdt1 <= v-dt2)) or ((remtrz.valdt2 >= v-dt1) and (remtrz.valdt2 <= v-dt2)) no-lock:
    if /*remtrz.sbank <> sysc.chval and*/ remtrz.rbank <> sysc.chval then next.
    if (remtrz.jh1 = ?) or (remtrz.jh2 = ?) then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = remtrz.remtrz and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.
    /*
    if remtrz.sbank = sysc.chval then do:
        if remtrz.rbank begins 'TXB' and length(remtrz.rbank) = 5 then next.
            --только для единоразовой выгрузки--
        if remtrz.outcode = 1 then next.
        if remtrz.outcode = 6 then do:
            if remtrz.drgl = 287032 then next.
            v-dClientType = 'bank'.
            v-debitClientId = sysc.chval.
        end.

        if remtrz.outcode = 3 then do:
            find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
            if not avail aaa then next.
            if lookup(aaa.lgr,lgrList) > 0 then assign v-dClientType = 'bank' v-debitClientId = sysc.chval.
            else assign v-dClientType = 'cif' v-debitClientId = aaa.cif.
        end.

        v-docType = '2'.
    end.
    */

    if remtrz.rbank = sysc.chval then do:
        find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
        if not avail aaa then do:
            find first arp where arp.arp = remtrz.cracc no-lock no-error.
            if avail arp then do:
                if arp.gl = 287032 or arp.gl = 287034 or arp.gl = 287035 or arp.gl = 287036 or arp.gl = 287037 or arp.gl = 287033 then next.
                v-cClientType = 'bank'.
                v-creditClientId = sysc.chval.
            end.
        end.
        else do:
            if lookup(aaa.lgr,lgrList) > 0 then assign v-cClientType = 'bank' v-creditClientId = sysc.chval.
            else assign v-cClientType = 'cif' v-creditClientId = aaa.cif.
        end.
        v-rmzf = ''.
        if remtrz.sbank begins 'TXB' and length(remtrz.sbank) = 5 then do:
            if remtrz.sbank = remtrz.rbank then assign v-docType = '5' v-rmzf = remtrz.remtrz.
            else assign v-docType = '3' v-rmzf = substr(remtrz.sqn,index(remtrz.sqn,'RMZ'),10).

            if connected ("ast") then disconnect "ast".
            find first comm.txb where comm.txb.bank = remtrz.sbank and comm.txb.consolid no-lock no-error.
            if avail comm.txb then connect value ("-db " + replace(comm.txb.path,'/data/',v-path) + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password).
            run findtxbcif(remtrz.sacc,v-rmzf, output v-dClientType, output v-debitClientId, output v-regwho).
            if connected ("ast") then disconnect "ast".
            /*if v-dClientType = "cif" and v-debitClientId = "" then next.*/
        end.
        else do:
            v-docType = '1'.
            v-bnname = entry(1,remtrz.ord,'/').
        end.

        find first jh where jh.jh = remtrz.jh2 no-lock no-error.
        if avail jh then v-regwho = jh.who.
    end.

    if v-dClientType = "bank" and v-cClientType = "bank" then next.

    if (remtrz.sbank begins "txb") and (length(remtrz.sbank) = 5) then v-debitBank = v-clecod.
    else v-debitBank = remtrz.sbank.
    v-creditBank = v-clecod.

    run kfmAMLOffline(sysc.chval,
                      remtrz.remtrz, /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'rmz',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,
                      sysc.chval,
                      v-debitBank,
                      v-creditBank).

end.

hide message no-pause.
message sysc.chval + " - translat".

for each translat where translat.jh > 0 no-lock:
    if translat.jh-voz > 0 then next.
    find nmbr where nmbr.code = "translat" no-lock no-error.
    if not avail nmbr then next.
    if substr(translat.nomer,1,4) <> nmbr.pref then next.
    find first jh where jh.jh = translat.jh no-lock no-error.
    if not avail jh then next.
    if jh.jdt < v-dt1 or jh.jdt > v-dt2 then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = translat.nomer and amloffline.sts <> "del" no-lock no-error.
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
    v-regwho = jh.who.

    run kfmAMLOffline(sysc.chval,
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
                      sysc.chval,
                      '',
                      '').
end.

hide message no-pause.
message sysc.chval + " - r-translat".

for each r-translat where r-translat.jh > 0 no-lock:

    if r-translat.dt-otm <> ? then next.

    find nmbr where nmbr.code = "translat" no-lock no-error.
    if not avail nmbr then next.
    if r-translat.rec-code <> nmbr.pref then next.
    find first jh where jh.jh = r-translat.jh no-lock no-error.
    if not avail jh then next.
    if jh.jdt < v-dt1 or jh.jdt > v-dt2 then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = r-translat.nomer and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-regwho = ''.
    v-regwho = jh.who.
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

    run kfmAMLOffline(sysc.chval,
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
                      sysc.chval,
                      '',
                      '').

end.

for each doch where doch.rdt >= v-dt1 and doch.rdt <= v-dt2 and (doch.templ = "lon0067") or (doch.templ = "lon0068") no-lock:
    if (doch.jh = ?) or (doch.jh = 0) then next.
    find first jl where jl.jh = doch.jh no-lock no-error.
    if not avail jl then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = doch.docid and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-regwho = doch.rwho.
    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.


    v-docType = '11'.

    find first lon where lon.lon = doch.acc no-lock no-error.
    if avail lon then do:
        if doch.templ = "lon0067" then do:
            v-dClientType = 'cif'.
            v-debitClientId = lon.cif.
        end.
        else
        if doch.templ = "lon0068" then do:
            v-cClientType = 'cif'.
            v-creditClientId = lon.cif.
        end.
    end.

    v-z = ''.
    if doch.info[2] <> '' then do:
        find first lonsec1 where lonsec1.lon = doch.acc and lonsec1.ln = integer(doch.info[2]) and (lonsec1.lonsec <> 5) and (lonsec1.lonsec <> 6) no-lock no-error.
        if avail lonsec1 then do:
            find first lonsec1zal where lonsec1zal.lon = doch.acc and lonsec1zal.ln = lonsec1.ln no-lock no-error.
            if avail lonsec1zal then v-z = lonsec1zal.cif.
        end.
    end.
    if v-z <> '' then do:
        if doch.templ = "lon0067" then do:
            v-cClientType = 'cif'.
            v-creditClientId = v-z.
        end.
        else
        if doch.templ = "lon0068" then do:
            v-dClientType = 'cif'.
            v-debitClientId = v-z.
        end.
    end.

    run kfmAMLOffline(sysc.chval,
                      doch.docid, /* d0000007a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'doc',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,
                      sysc.chval,
                      '',
                      '').

end.




