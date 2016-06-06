/* AMLoff_HQ.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Оффлайновая выгрузка операций за период - ЦО
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
        BANK COMM
 * CHANGES
        22/07/2010 galina - добавила поля regwho и regbank
        28/07/2010 galina - оправила определение номера rmz на филиале
        26/08/2010 madiyar - новые параметры в вызове kfmAMLOffline (пока не заполняются)
        27/08/2010 madiyar - заполняем новые параметры
        31/08/2010 galina - убрала повторную выгрузку
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

def var lgrList as char no-undo init "181,182,183,184,189,190,191,192,193,198,199".
def shared var v-dt1 as date.
def shared var v-dt2 as date.
def var v-path as char no-undo.
def var v-dClientType as char no-undo.     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
def var v-cClientType as char no-undo.     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
def var v-debitClientId as char no-undo.   /* id клиента Дт */
def var v-creditClientId as char no-undo.  /* id клиента Кт */
def var v-docType as char no-undo.
def var v-bnname as char no-undo.
def var v-regwho as char no-undo.
v-path = '/data/b'.
def var v-rmzf as char no-undo.

def var v-debitBank as char no-undo.
def var v-creditBank as char no-undo.

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
message sysc.chval + " - rmz".

for each remtrz where ((remtrz.valdt1 >= v-dt1) and (remtrz.valdt1 <= v-dt2)) or ((remtrz.valdt2 >= v-dt1) and (remtrz.valdt2 <= v-dt2)) no-lock:
    if remtrz.rbank = sysc.chval then next.
    if remtrz.rbank begins 'TXB' and length(remtrz.rbank) = 5 then next.
    if (remtrz.jh1 = ?) or (remtrz.jh2 = ?) then next.

    find first amloffline where amloffline.bank = sysc.chval and amloffline.operCode = remtrz.remtrz and amloffline.sts <> "del" no-lock no-error.
    if avail amloffline then next.

    v-dClientType = ''.
    v-cClientType = ''.
    v-debitClientId = ''.
    v-creditClientId = ''.
    v-docType = ''.
    v-bnname = ''.
    v-regwho = ''.
    v-rmzf = ''.
    if remtrz.sbank = sysc.chval then do /*Наш банк->НеУчастник*/ :

        /*--только для единоразовой выгрузки--*/
        if remtrz.outcode = 1 then do:
            v-debitClientId = remtrz.kfmcif.
            if v-debitClientId begins "cm" then v-dClientType = "cifm".
            v-docType = '10'.
        end.

        if remtrz.outcode = 6 then do:
            if remtrz.drgl = 287032 then do:
                v-debitClientId = remtrz.kfmcif.
                if v-debitClientId begins "cm" then v-dClientType = "cifm".
                v-docType = '10'.
            end.
            else do:
                v-dClientType = 'bank'.
                v-debitClientId = sysc.chval.
                v-docType = '2'.
            end.
        end.

        if remtrz.outcode = 3 then do:
            find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
            if not avail aaa then next.
            if lookup(aaa.lgr,lgrList) > 0 then assign v-dClientType = 'bank' v-debitClientId = sysc.chval.
            else assign v-dClientType = 'cif' v-debitClientId = aaa.cif.
            v-docType = '2'.
        end.
        if remtrz.rwho <> '' and caps(remtrz.rwho) <> 'SUPERMAN' then v-regwho = remtrz.rwho.
        else do:
            find first jh where jh.jh = remtrz.jh1 no-lock no-error.
            if avail jh then v-regwho = jh.who.
        end.
    end.
    else do:
        /*Участник->НеУчастник*/
        if remtrz.sbank begins 'TXB' and length(remtrz.sbank) = 5 then do:

            v-rmzf = substr(remtrz.sqn,index(remtrz.sqn,'RMZ'),10).
            /*if remtrz.sacc = '' then next.*/ /*перевод с кассы*/
            if connected ("ast") then disconnect "ast".
            find first txb where txb.bank = remtrz.sbank and consolid no-lock no-error.
            if avail txb then connect value ("-db " + replace(path,'/data/',v-path) + " -ld ast -U " + login + " -P " + password).
            run findtxbcif(remtrz.sacc, v-rmzf, output v-dClientType, output v-debitClientId, output v-regwho).
            if connected ("ast") then disconnect "ast".
            if v-dClientType = "cif" and v-debitClientId = "" then next. /*исключаем переводы с кассы в пути и без открытия счета*/
            if v-dClientType = "cifm" then v-docType = '10'.
            else v-docType = '2'.
        end.
        else next. /*НеУчастник->НеУчастник*/
    end.
    v-bnname = entry(1,remtrz.bn[1] + ' ' + remtrz.bn[2],'/').

    /*if remtrz.rbank = sysc.chval then do:
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

        if remtrz.sbank begins 'TXB' and length(remtrz.sbank) = 5 then do:
            v-docType = '3'.
            if connected ("ast") then disconnect "ast".
            find first txb where bank = remtrz.sbank and consolid no-lock no-error.
            if avail txb then connect value ("-db " + replace(path,'/data/',v-path) + " -ld ast -U " + login + " -P " + password).
            run findtxbcif(remtrz.sacc, output v-dClientType, output v-debitClientId).
            if connected ("ast") then disconnect "ast".
        end.
        else v-docType = '1'.
    end.*/

    if v-dClientType = "bank" and v-cClientType = "bank" then next.

    run kfmAMLOffline(sysc.chval,
                      remtrz.remtrz,      /* jou000073a */
                      1,
                      v-dClientType,     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
                      v-cClientType,     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
                      v-debitClientId,   /* id клиента Дт */
                      v-creditClientId,  /* id клиента Кт */
                      v-bnname,          /* Имя бенефициара */
                      'rmz',             /* категория документа */
                      v-docType,          /* тип документа */
                      v-regwho,           /*кто провел операцию*/
                      remtrz.sbank,       /*банк отправитель*/
                      v-clecod,
                      remtrz.rbank).

end.





