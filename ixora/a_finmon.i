/* a_finmon.i
 * MODULE
        Фин. мониторинг
 * DESCRIPTION
        Описание программы
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
        21/04/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        28.04.11 Luiza Создана по примеру jm_finmon.i
        06/02/2012 Luiza проверка в случае если knp = 119 или назначение "мат помощь"
        07/05/2012 Luiza если база тестовая OnLine проверку клиента не выполняем
        10/05/2012 Luiza отключила проверку на 7 млн
        28/06/2012 Luiza отменила транзакц. блок
        11/10/2012 Luiza - ТЗ изменение пороговых сумм c 2000000 до 6000000 для кнп 119
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        14/05/2013 Luiza -  ТЗ № 1838 все проверки по финмон отключаем, будут проверяться в AML
        10/06/2013 Luiza - ТЗ 1727 добавляем проверку на 30 млн тенге при расходе со счета клиента наличными
        19/06/2013 Luiza  - ТЗ 1887
*/

if joudoc.drcur = 1 then v-monamt = joudoc.dramt.
else do:
    find first crc where crc.crc = joudoc.drcur no-lock no-error.
    if avail crc then v-monamt = joudoc.dramt * crc.rate[1].
end.
def var v-usdamt as deci no-undo.
def var v-askdopinfo as logi no-undo.

find first cmp no-lock no-error.
find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

def var v-fmRem as char no-undo.
v-fmRem = joudoc.remark[1] + ' ' + joudoc.remark[2] + ' ' + joudoc.rescha[3].

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
def var v-blagot as logi no-undo.
def var v-blagotDir as char no-undo.
def var v-bank as char no-undo.
def var l-operId as int no-undo.
def var v-bname as char no-undo.
def var v-maillist as char no-undo.
def var v-i as int.

find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc then do:
    message "" view-as alert-box.
    return.
end.
v-bank = sysc.chval.

v-fmCash = no.
v-fmCashDir = ''.
if joudoc.dracctype = "1" or joudoc.cracctype = "1" or joudoc.dracctype = "4" or joudoc.cracctype = "4" then do:
    if joudoc.dracctype = "1" then do:
        v-fmCash = yes.
        v-fmCashDir = 'D'.
    end.
    else do:
        if joudoc.dracctype = "4" then do:
            find first arp where arp.arp = joudoc.dracc no-lock no-error.
            v-fmCash = yes.
            v-fmCashDir = 'C'.
        end.
    end.
    if joudoc.cracctype = "1" then do:
        v-fmCash = yes.
        v-fmCashDir = 'C'.
    end.
    else do:
        if joudoc.cracctype = "4" then do:
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            v-fmCash = yes.
            v-fmCashDir = 'D'.
        end.
    end.
end.
v-fmAcc = no.
v-blagot = no.
v-blagotDir = ''.

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
if v-fmCash and (joudoc.dracctype = "4" or joudoc.cracctype = "4") then do:
    if v-fmCashDir = "D" then do:
        if joudoc.cracctype = "4" then do:
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            if avail arp and (arp.gl = 287032 or arp.gl = 287034 or arp.gl = 287035 or arp.gl = 287036 or arp.gl = 287037 or arp.gl = 287033 /*or arp.gl = 287032*/) then do:
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
/*проверка на терроризм*/
def var v-senderNameList as char.
def var v-benNameList as char.
def var v-benCountry as char.
def var v-benName as char.
def var v-senderCountry as char.
def var v-senderName as char.
def var v-pttype as integer.
def var v-errorDes as char.
def var v-operId as char.
def var v-operStatus as char.
def var v-operComment as char.
def var v-clid as char.
def var v-passp as char.
def var v-passpwho as char.
        /***********/
v-benCountry  = ''.
v-benName = ''.
v-senderCountry = ''.
v-senderName = ''.
v-benNameList = ''.
v-senderNameList = ''.
v-errorDes = ''.
v-operId = ''.
v-operStatus = ''.
v-operComment = ''.
if v-fmAcc and (v-fmAccDir = 'B' or v-fmCash) then do:
    if joudoc.dracctype = "2" then do:
        find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
        find first cif where cif.cif = aaa.cif no-lock no-error.
        run defclparam.
        v-senderCountry = v-res.

        if cif.type = 'B' then do:
            v-senderNameList = ''.
            if cif.cgr <> 403 then do:
                for each founder where founder.cif = cif.cif no-lock:
                    if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                    if founder.ftype = 'B' then v-senderNameList = v-senderNameList + founder.name.
                    if founder.ftype = 'P' then v-senderNameList = v-senderNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                end.
            end.
            if cif.cgr = 403 then do:
                if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                if v-prtFLNam <> '' then v-senderNameList = v-senderNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
            end.

            if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
        end.
        if v-cltype = '01' then v-senderName = v-clnameU.
        if v-cltype = '02' then v-senderName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
        if v-cltype = '03' then v-senderName = trim(cif.prefix) + ' ' + trim(cif.name).
    end.
    if joudoc.cracctype = "2" and not v-fmSameClient then do:
        find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
        find first cif where cif.cif = aaa.cif no-lock no-error.
        run defclparam.
        v-benCountry  = v-res.

        if cif.type = 'B' then do:
            v-benNameList = ''.
            if cif.cgr <> 403 then do:
                for each founder where founder.cif = cif.cif no-lock:
                    if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                    if founder.ftype = 'B' then v-benNameList = v-benNameList + founder.name.
                    if founder.ftype = 'P' then v-benNameList = v-benNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                end.
            end.
            if cif.cgr = 403 then do:
                if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                if v-prtFLNam <> '' then v-benNameList = v-benNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
            end.

            if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
        end.

        if v-cltype = '01' then v-benName = v-clnameU.
        if v-cltype = '02' then v-benName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
        if v-cltype = '03' then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).
    end.
end.


if (joudoc.dracctype = "4" or joudoc.cracctype = "4") and (not v-fmTrNoAcc) then do:

    if joudoc.cracctype = "4" and v-fmCash and v-fmCashDir = 'D' then do:
        find first arp where arp.arp = joudoc.cracc no-lock no-error.
        if avail arp and arp.gl = 287051 then do:
            find first cif where cif.cif = arp.cif no-lock no-error.
            if avail cif then do:
                run defclparam.
                v-benCountry  = v-res.
                if cif.type = 'B' then do:
                    v-benNameList = ''.
                    if cif.cgr <> 403 then do:
                        for each founder where founder.cif = cif.cif no-lock:
                            if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                            if founder.ftype = 'B' then v-benNameList = v-benNameList + founder.name.
                            if founder.ftype = 'P' then v-benNameList = v-benNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                        end.
                    end.
                    if cif.cgr = 403 then do:
                        if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                        if v-prtFLNam <> '' then v-benNameList = v-benNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                    end.
                    if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                end.

                if v-cltype = '01' then v-benName = v-clnameU.
                if v-cltype = '02' then v-benName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                if v-cltype = '03' then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).

            end.
        end.

    end.

    if v-fmAcc then do:
        if joudoc.dracctype = "2" then do:
            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-senderCountry = v-res.

            if cif.type = 'B' then do:
                v-senderNameList = ''.

                if cif.cgr <> 403 then do:
                    for each founder where founder.cif = cif.cif no-lock:
                        if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                        if founder.ftype = 'B' then v-senderNameList = v-senderNameList + founder.name.
                        if founder.ftype = 'P' then v-senderNameList = v-senderNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                    end.
                end.
                if cif.cgr = 403 then do:
                    if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                    if v-prtFLNam <> '' then v-senderNameList = v-senderNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                end.

                if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
            end.
            if v-cltype = '01' then v-senderName = v-clnameU.
            if v-cltype = '02' then v-senderName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
            if v-cltype = '03' then v-senderName = trim(cif.prefix) + ' ' + trim(cif.name).


        end.

        if joudoc.cracctype = "2" then do:
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-benCountry  = v-res.

            if cif.type = 'B' then do:
                if cif.cgr <> 403 then do:
                    v-benNameList = ''.
                    for each founder where founder.cif = cif.cif no-lock:
                        if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                        if founder.ftype = 'B' then v-benNameList = v-benNameList + founder.name.
                        if founder.ftype = 'P' then v-benNameList = v-benNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                    end.
                end.
                if cif.cgr = 403 then do:
                    if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                    if v-prtFLNam <> '' then v-benNameList = v-benNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                end.

                if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
            end.

            if v-cltype = '01' then v-benName = v-clnameU.
            if v-cltype = '02' then v-benName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
            if v-cltype = '03' then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).
        end.
    end.
end.


if v-fmTrNoAcc or lookup(trim(joudop.type),"OBM,BOM") > 0 then do:
    v-prtFLNam = ''.
    v-prtFFNam = ''.
    v-prtFMNam = ''.
    v-rnn = ''.
    v-prtUdN = ''.
    v-regdt = ?.
    v-prtUdIs = ''.
    v-dtbth = ?.
    v-bplace = ''.
    v-res2 = ''.
    v-res = ''.
    v-clfam2 = ''.
    v-clname2 = ''.
    v-clmname2 = ''.
    v-addr = ''.
    v-prtPhone = ''.
    v-publicf = ''.
    v-prtUD = ''.

        if v-fmTrNoAccDir  = 'C' then v-pttype = 2.
        if v-fmTrNoAccDir  = 'D' then v-pttype = 1.
    if trim(joudoc.passp) <> '' then do:
        v-passp = entry(1,joudoc.passp).
        if num-entries(joudoc.passp) > 1 then v-passpwho = entry(2,joudoc.passp).
    end.
    else assign v-passp = '' v-passpwho = ''.

    v-usdamt = 0. v-askdopinfo = no.
    find first crc where crc.crc = 2 no-lock no-error.
    if avail crc then v-usdamt = v-monamt / crc.rate[1].
    if lookup(trim(joudop.type),"OBM,BOM") > 0 then do:
        if v-usdamt >= 10000 then v-askdopinfo = yes.
        v_lname1 = joudoc.info.
        v_lname = joudoc.info.
    end.
    else
    if v-fmTrNoAcc then do:
        if v-usdamt >= 1000 then v-askdopinfo = yes.
    end.

    if v-askdopinfo then do:
        if joudoc.kfmcif = "" then run a_kfmdopinf(joudoc.info,joudoc.perkod,v-passp,joudoc.passpdt,v-passpwho,'','','',v-pttype,
          output v-prtFLNam,output v-prtFFNam,output v-prtFMNam,output v-rnn,output v-prtUdN,output v-regdt,output v-prtUdIs,
          output v-dtbth,output v-bplace,output v-res2,output v-res,output v-clfam2 ,output v-clname2,output v-clmname2,
          output v-addr,output v-prtPhone,output v-publicf,output v-prtUD, output v-clid).
        else do:
          /*вся доп информац в cifmin уже есть.*/
            v-prtFLNam = trim(v_lname).
            v-prtFFNam = trim(v_name).
            v-prtFMNam = trim(v_mname).
            v-rnn = v_rnn.
            v-prtUdN = v_doc_num.
            v-regdt = v_docdt.
            v-prtUdIs = v_docwho.
            v-dtbth = v-bdt1.
            v-bplace = v-bplace.
            v-res2 = v_rez.
            v-res = v_countr.
            v-clfam2 = v_lname1.
            v-clname2 = v_name1.
            v-clmname2 = v_mname1.
            v-addr = v_addr.
            v-prtPhone = v_tel.
            v-publicf = v_public.
            v-prtUD = v_doctype.
            v-clid = v-cifmin.
        end.
        v-dopres = yes.
        if not v-dopres then do:
            frame f_main:visible = yes.
            return.
        end.
    end.
    if trim(v-clid) <> '' then do:
        find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
        if avail joudoc then do:
            joudoc.kfmcif = v-clid.
            /*if trim(v-clfam2) <> '' or trim(v-clname2) <> '' or trim(v-clmname2) <> '' then joudoc.benName = trim(trim(v-clfam2) + ' ' + trim(v-clname2) + ' ' + trim(v-clmname2)).*/
        end.
        find current joudoc no-lock no-error.
    end.
    v-senderCountry = v-res.
    v-senderName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
    v-benCountry  = ''.
    v-benName = v-clfam2 + ' ' + v-clname2  + ' ' + v-clmname2.
end.
/* онлайн-запрос в AML */
if v-askdopinfo = no then do:
    v-benCountry = v_countr1.
    v-benName = trim(v_lname1) + " " + trim(v_name1) + " " + trim(v_mname1).
    v-senderCountry = v_countr.
    v-senderName = trim(v_lname) + " " + trim(v_name) + " " + trim(v_mname).
end.

if trim(v-benCountry  + v-benName + v-senderCountry + v-senderName + v-benNameList + v-senderNameList) <> '' then do:
    if trim(v-benCountry) <> '' then do:
        find first code-st where code-st.code = v-benCountry no-lock no-error.
        if avail code-st then v-benCountry = code-st.cod-ch.
    end.
    if trim(v-senderCountry) <> '' then do:
        find first code-st where code-st.code = v-senderCountry no-lock no-error.
        if avail code-st then v-senderCountry = code-st.cod-ch.
    end.
    find first pksysc where pksysc.sysc = 'kfmOn' no-lock no-error.
    if avail pksysc and pksysc.loval then do:
        /*if isProductionServer() then do:*/ /* если тестовая база - Online проверку не выполняем  */
            display "" skip(2) "          ПОДОЖДИТЕ" skip "    ИДЕТ ПРОВЕРКА КЛИЕНТА     " skip(2) "" with frame f1 centered overlay row 10 title 'ВНИМАНИЕ'.
            run kfmAMLOnline(joudoc.docnum,
                          v-benCountry,
                          v-benName,
                          v-benNameList,
                          '1',
                          '1',
                          v-senderCountry,
                          v-senderName,
                          v-senderNameList,
                          output v-errorDes,
                          output v-operId,
                          output v-operStatus,
                          output v-operComment).
            hide frame f1 no-pause.
            if trim(v-errorDes) <> '' then do:
                message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
                frame f_main:visible = yes.
                return.
            end.

            if v-operStatus = '0' then do:
                run kfmOnlineMail(joudoc.docnum).
                message "Операция приостановлена для анализа! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                frame f_main:visible = yes.
                return.
            end.

            if v-operStatus = '2' then do:
                run kfmOnlineMail(joudoc.docnum).
                message "Проведение операции запрещено! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                frame f_main:visible = yes.
                return.
            end.
        /*end. */ /* if isProductionServer() */
    end.
end.
/*конец - проверка на терроризм*/

/*подозрительные операции*/
find first sub-cod where sub-cod.acc = joudoc.docnum and sub-cod.sub = "jou" and sub-cod.d-cod = "kfmsusp1" use-index dcod no-lock no-error .
if avail sub-cod and sub-cod.ccode = '01' then do:
    find first kfmoper where kfmoper.bank = v-bank and kfmoper.operDoc = joudoc.docnum no-lock no-error.
    if avail kfmoper then do:
       if kfmoper.sts <> 99 and kfmoper.sts <> 90 then do:
           message "Операция является подозрительной и находится на контроле у службы Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.
           return.
       end.
    end.
    else do:

        message "Операция является подозрительной и подлежит финансовому мониторингу.~nОбратитесь в службу Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.
        v-oper = ''.
        /***********/
        if v-fmAcc and (v-fmAccDir = 'B' or v-fmCash) then do:
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then do:
                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            end.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            if v-fmAccDir = 'B' then run kfmoperh_cre('03','03',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            else run kfmoperh_cre('03','03',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.
            if joudoc.dracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

            end.
            if joudoc.cracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
            end.
        end.
        if (joudoc.dracctype = "4" or joudoc.cracctype = "4") and (not v-fmTrNoAcc) then do:
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then do:
                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            end.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            if v-fmAcc then run kfmoperh_cre('03','03',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            else run kfmoperh_cre('03','03',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            run deffilial.
            v-num = v-num + 1.
            if joudoc.dracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','01').
            else run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','02').
            if joudoc.dracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
            end.

            if joudoc.cracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
            end.
        end.
        if v-fmTrNoAcc then do:
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  do:
                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            end.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('03','03',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'02','1','','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'','01',v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'02','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','02').
        end.
/*        if v-fmCash and not v-fmTrNoAcc then do:

        end.*/
        s-operType = 'su'.
        run kfmoper_cre(v-operId).
        frame f_main:visible = yes.
        if not kfmres then return.
        v-kfm = yes.
        if v-kfm then do:
           /*run savelog( "finmon", "1. a_finmon.i " + joudoc.docnum + " " + v-operId).*/
               /*if s-jh > 0 then*/ run kfmcopy(v-operId,joudoc.docnum,'su',0).
            hide all no-pause.
            view frame f_main.
        end.
        return.
    end.
end.
/*конец -подозрительные операции*/


/* выдача наличных средств со счетов физ и юр лиц >= 30000000 тенге */
if lookup(trim(joudop.type),"CS2,EK2,CS6,EK6,CS9,EK9") > 0 then do:
    if v-monamt >= 30000000  then do:
        find first kfmoper where kfmoper.operDoc = joudoc.docnum no-lock no-error.
        if not available kfmoper then do:
            message "Внимание! Данная операция приостановлена и требует согласования со Службой комплаенс!" view-as alert-box.
            l-operId = next-value(kfmOperId).
            create kfmoper.
            assign kfmoper.bank = v-bank
                   kfmoper.operId = l-operId
                   kfmoper.operDoc = joudoc.docnum
                   kfmoper.sts = 0
                   kfmoper.rwho = g-ofc
                   kfmoper.rwhn = g-today
                   kfmoper.operType = "cs"
                   kfmoper.rem[1] = joudoc.benname
                   kfmoper.rem[2] = trim(joudoc.remark[1]).
                   kfmoper.rtim = time.
            find first kfmoper where kfmoper.operDoc = joudoc.docnum no-lock no-error.
            v-operStatus = '0'.
            v-kfm = no.

            /*отправляем сообщение комплайнс менеджеру*/
            v-bname = ''.
            find first txb where txb.consolid and txb.bank = v-bank no-lock no-error.
            if avail txb then v-bname = txb.info.
            v-maillist = ''.
            find first sysc where sysc.sysc = "kfmmail" no-lock no-error.
            if avail sysc and trim(sysc.chval) <> '' then do:
                do v-i = 1 to num-entries(sysc.chval):
                    if trim(entry(v-i,sysc.chval)) <> '' then do:
                        if v-maillist <> '' then v-maillist = v-maillist + ','.
                        v-maillist = v-maillist + trim(entry(v-i,sysc.chval)) + "@fortebank.com".
                    end.
                end.
                if v-maillist <> '' then do:
                    run mail(v-maillist ,g-ofc + "@fortebank.com","Необходимо в п.м. 13.1 проверить операцию расхода со счета клиента","Филиал: " + v-bname + "\n" +
                        "Необходимо в п.м. 13.1 проверить операцию расхода со счета клиента на сумму " +
                        string(v-monamt) + " тенге \n " + "Номер документа в iXora: " + joudoc.docnum, "1", "","").
                end.
            end.
        end.
        else do:
            if kfmoper.sts  = 1 then do:
                v-kfm = no.
                v-operStatus = '1'.
            end.
            if kfmoper.sts  = 98 then do:
                v-kfm = no.
                v-operStatus = '2'.
                message "Проведение операции запрещено! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
            end.
            if kfmoper.sts  = 0 then do:
                v-kfm = no.
                v-operStatus = '0'.
                message "Операция приостановлена для анализа! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
            end.
        end.
    end.
end.

/* Платежи и переводы в пользу другого лица на безвозмездной основе */
/*if not v-kfm then do:
    if v-fmTrNoAcc and v-fmTrNoAccDir = 'C' then do:
        if (checkkey2 (v-fmRem,"kfmkey") or v-knpval = '119') and v-monamt >= 6000000  then do:
            message "Платежи и переводы в пользу другого лица на безвозмездной основе ~nсуммой >= 6000000 тенге подлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '09'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  do:
                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            end.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').

            run kfmprt_cre(v-operId,2,'01','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','02').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
            if v-kfm then do:
               if s-jh > 0 then run kfmcopy(v-operId,joudoc.docnum,'fm',0).
            end.
        end.
    end.
end.*/

/* Платежи и переводы в пользу другого лица на безвозмездной основе */
/*if not v-kfm then do:
    if v-fmTrNoAcc and v-fmTrNoAccDir = 'D' then do:
        if (checkkey2 (v-fmRem,"kfmkey") or v-knpval = '119') and v-monamt >= 6000000 then do:
            message "Платежи и переводы в пользу другого лица на безвозмездной основе ~nсуммой >= 6000000 тенге подлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '09'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then do:
                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            end.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).

            run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','02').

            run kfmprt_cre(v-operId,2,'02','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','01').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
            if v-kfm then do:
               if s-jh > 0 then run kfmcopy(v-operId,joudoc.docnum,'fm',0).
            end.
        end.

    end.
end.*/

/* платежи на сумму более 7000000 тенге (пополнение счет, инкасация и т.д.)*/
/*find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
if not available joudop then do:
    message "Не найдена запись в joudop. Обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
    frame f_main:visible = yes.
    return.
end.
def var v-stslistD as char.
def var v-stslistC as char.
v-stslistD = "CS2,EK2,CM2,MC2".
v-stslistC = "CS1,EK1,INC,NIC".
if lookup(trim(joudop.type),v-stslistD) > 0 then do:
    find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
    if avail aaa then do:
        if v-monamt >= 7000000 then do:
            message 'Общая сумма операции >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

            v-oper = '03'.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            find first cif where cif.cif = aaa.cif no-lock no-error.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

            do transaction:
                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','',output v-operId).
            end.
            run defclparam.

            run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,
                           v-prtFMNam,
                           v-prtPhone,
                           v-prtEmail,
                           v-prtUD,
                           v-prtUdN,
                           '',
                           v-prtUdIs,
                           v-prtUdDt,
                           v-bdt,
                           v-bplace,
                           cif.addr[1],
                           cif.addr[2],
                           '',
                           '01').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
            if v-kfm then do:
               if s-jh > 0 then run kfmcopy(v-operId,joudoc.docnum,'fm',0).
            end.
        end.
    end.
end.
if lookup(trim(joudop.type),v-stslistC) > 0 then do:
    find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
    if avail aaa then do:
        if v-monamt >= 7000000 then do:
            message 'Общая сумма операции >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

            v-oper = '08'.
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            find first cif where cif.cif = aaa.cif no-lock no-error.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then v-opSumKZT = trim(string(joudoc.cramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

            do transaction:
                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.cramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','',output v-operId).
            end.
            run defclparam.

            run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,
                           v-prtFMNam,
                           v-prtPhone,
                           v-prtEmail,
                           v-prtUD,
                           v-prtUdN,
                           '',
                           v-prtUdIs,
                           v-prtUdDt,
                           v-bdt,
                           v-bplace,
                           cif.addr[1],
                           cif.addr[2],
                           '',
                           '01').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
            if v-kfm then do:
               if s-jh > 0 then run kfmcopy(v-operId,joudoc.docnum,'fm',0).
            end.
        end.
    end.
end.*/