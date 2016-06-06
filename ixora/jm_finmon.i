/* jm_finmon.i
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
        24/04/2010 madiyar - не отлавливалась мат. помощь без открытия счета по кассе в пути, исправил
        27/04/2010 madiyar - исправил ошибку (расчет суммы)
        28/04/2010 madiyar - неверное количество параметров в вызове kfmdopinf
        28/04/2010 galina - добавила подозрительные операции
        29/04/2010 galina - пропускаем подозрительные операции, если они удалены из фин.мониторинга
                            подкорректировала инкассацию собственных средств банка
        29/04/2010 madiyar - подправил определение переводов без открытия счета
        30/04/2010 galina - мониторим снятие со счета по кнп 411,413,419
        23/06/2010 galina - запрос дополнительной информации по клиенту для переводов без открытия счета
        02/07/2010 galina - добавила поле kfmcif для Фин.Мониторинга
        13/07/2010 galina - online запрос по спискам террористов
        14/07/2010 galina - отсылаем собщение комплаенс по почте раньше сообщения менеджеру
        20/07/2010 galina - добавила переменную s-operType
        22/07/2010 galina - добавила парметр kfmprt_cre
        28/07/2010 galina - добавила переводы благотвор.организаций для фин.мониторинга
                            проверяем логическую переменную kfmOn в справочнике pksysc перед запросом в AML
        18/11/2010 madiyar - частично отключаем фин. мониторинг (пока только закомментил, на всякий случай)
        23/11/2010 madiyar - запрос заполнения мини-карточки только при обмене более USD10,000 и переводе без открытия счета более USD1,000
        02/12/2010 madiyar - исправил расчет эквивалента в долларах
        10/12/2010 galina - поправила расчет эквивалента в тенге
        19/01/2012 evseev - добавил логирование
        11/10/2012 Luiza - ТЗ изменение пороговых сумм c 2000000 до 6000000 для кнп 119
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        02/01/2013 madiyar - добавил v-iin
        14/05/2013 Luiza -  ТЗ № 1838 заполнение миникарточки при обмене наличности >= 1000$ и
                            все проверки по финмон отключаем, будут проверяться в AML
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
v-blagot = no.
v-blagotDir = ''.
if joudoc.dracctype = "2" or joudoc.cracctype = "2" then do:
    v-fmAcc = yes.
    if joudoc.dracctype = "2" and joudoc.cracctype = "2" then v-fmAccDir = 'B'.
    else do:
        if joudoc.dracctype = "2" then v-fmAccDir = 'D'.
        else v-fmAccDir = 'C'.
    end.

    if joudoc.dracctype = "2" then do:
        find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
        if avail aaa then find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod and sub-cod.ccode = '8' then do:
            v-blagot = yes.
            v-blagotDir = 'D'.
        end.
    end.
    if joudoc.cracctype = "2" and v-blagot = no then do:
        find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
        if avail aaa then find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod and sub-cod.ccode = '8' then do:
            v-blagot = yes.
            v-blagotDir = 'C'.
        end.
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
if v-fmCash and (joudoc.dracctype = "4" or joudoc.cracctype = "4") then do:
    if v-fmCashDir = "D" then do:
        if joudoc.cracctype = "4" then do:
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            if avail arp and (arp.gl = 287034 or arp.gl = 287035 or arp.gl = 287036 or arp.gl = 287037 or arp.gl = 287033 /*or arp.gl = 287032*/) then do:
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


if v-fmTrNoAcc or g-fname = 'obmen' then do:
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

    if g-fname = 'obmen' then v-pttype = 3.
    else do:
        if v-fmTrNoAccDir  = 'C' then v-pttype = 2.
        if v-fmTrNoAccDir  = 'D' then v-pttype = 1.
    end.
    if trim(joudoc.passp) <> '' then do:
        v-passp = entry(1,joudoc.passp).
        if num-entries(joudoc.passp) > 1 then v-passpwho = entry(2,joudoc.passp).
    end.
    else assign v-passp = '' v-passpwho = ''.

    v-usdamt = 0. v-askdopinfo = no.
    find first crc where crc.crc = 2 no-lock no-error.
    if avail crc then v-usdamt = v-monamt / crc.rate[1].
    if g-fname = 'obmen' then do:
        if v-usdamt >= 10000 then v-askdopinfo = yes.
        v-prtFLNam = joudoc.info.
        v-benName = joudoc.info.
    end.
    else
    if v-fmTrNoAcc then do:
        if v-usdamt >= 1000 then v-askdopinfo = yes.
    end.

    if v-askdopinfo then do:
        run kfmdopinf(joudoc.info,joudoc.perkod,v-passp,joudoc.passpdt,v-passpwho,'','','',v-pttype,output v-prtFLNam,output v-prtFFNam,output v-prtFMNam,output v-iin,output v-prtUdN,output v-regdt,output v-prtUdIs,output v-dtbth,output v-bplace,output v-res2,output v-res,output v-clfam2,output v-clname2,output v-clmname2,output v-addr,output v-prtPhone,output v-publicf,output v-prtUD, output v-clid).
        if not v-dopres then do:
            frame f_main:visible = yes.
            return.
        end.
    end.

    if trim(v-clid) <> '' then do transact:
        find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
        if avail joudoc then do:
            joudoc.kfmcif = v-clid.
            if trim(v-clfam2) <> '' or trim(v-clname2) <> '' or trim(v-clmname2) <> '' then joudoc.benName = trim(trim(v-clfam2) + ' ' + trim(v-clname2) + ' ' + trim(v-clmname2)).
        end.
        find current joudoc no-lock no-error.
    end.
    v-senderCountry = v-res.
    v-senderName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
    v-benCountry  = ''.
    v-benName = v-clfam2 + ' ' + v-clname2  + ' ' + v-clmname2.
end.


/* онлайн-запрос в AML */
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
        display "" skip(2) "          ПОДОЖДИТЕ" skip "    ИДЕТ ПРОВЕРКА КЛИЕНТА     " skip(2) "" with frame f1 centered overlay row 10 title 'ВНИМАНИЕ'.

        disable b1 b2 b3 b4 b5 b6 b7 with frame a2.
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
        enable b1 b2 b3 b4 b5 b6 b7 with frame a2.
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
            if joudoc.dracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,v-iin,'','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','01').
            else run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,v-iin,'','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','02').
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
        if v-fmTrNoAcc or g-fname = 'obmen' then do:
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
            run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'02','1','','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','',v-iin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'','01',v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').
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
           run savelog( "finmon", "1. jm_finmon.i " + joudoc.docnum + " " + v-operId).
           run kfmcopy(v-operId,joudoc.docnum,'su',0).
        end.
        return.
    end.
end.
/*конец -подозрительные операции*/


/*

-- проверяем на новое ЮЛ --

if not v-kfm then do:
    if v-fmAcc then do:
        if v-monamt >= 7000000 then do:

            v-fmNewClient = no.
            v-fmMessage = ''.

            if joudoc.dracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                if avail cif and cif.type = 'B' and cif.cgr <> 403 and g-today - cif.expdt < 90 then do:
                    v-fmNewClient = yes.
                    v-fmMessage = "~nЮЛ " + cif.cif + ' ' + trim(cif.prefix) + ' ' + trim(cif.name).
                end.
            end.

            if joudoc.cracctype = "2" then do:
                if not v-fmSameClient then do:
                    find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        if cif.type = 'B' and cif.cgr <> 403 and g-today - cif.expdt < 90 then do:
                            v-fmNewClient = yes.
                            v-fmMessage = v-fmMessage + "~nЮЛ " + cif.cif + ' ' + trim(cif.prefix) + ' ' + trim(cif.name).
                        end.
                    end.
                end.
            end.

            if v-fmNewClient then do:
                message 'Прошло менее 3 месяцев с момента регистрации ' + v-fmMessage + '~nОперация на сумму >= 7000000 тенге подлежит фин. мониторингу!' view-as alert-box title 'ВНИМАНИЕ'.
                v-oper = '11'.
                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                v-opSumKZT = ''.
                if joudoc.drcur <> 1 then v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                v-num = 0.

                if joudoc.dracctype = "2" then do:
                    find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    v-num = 0.
                    run defclparam.
                    v-num = v-num + 1.
                    run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
                end.

                if joudoc.dracctype = "4" or joudoc.cracctype = "4" then do:
                    if joudoc.dracctype = "4" then find first arp where arp.arp = joudoc.dracc no-lock no-error.
                    else find first arp where arp.arp = joudoc.cracc no-lock no-error.
                    if avail arp and arp.gl <> 100200 then do:
                        run deffilial.
                        v-num = v-num + 1.
                        if joudoc.dracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
                        else run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','02').
                    end.
                end.

                if joudoc.cracctype = "2" then do:
                    if not v-fmSameClient then do:
                        find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        run defclparam.
                        v-num = v-num + 1.
                        run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
                    end.
                end.
                s-operType = 'fm'.
                run kfmoper_cre(v-operId).
                frame f_main:visible = yes.
                if not kfmres then return.
                v-kfm = yes.
            end.
        end. -- if v-monamt >= 7000000 --
    end.
end.

-- пополнение депозита в пользу третьего лица - касса 100100 --
if not v-kfm then do:
    if joudoc.dracctype = "1" and joudoc.cracctype = "2" then do:
        find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
        if avail aaa then do:
            find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
            if avail lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') then do:
                find first pipl where pipl.cif = aaa.cif no-lock no-error.
                if avail pipl then do:
                    v-mess = 0.
                    v-monamt2 = v-monamt.
                    if v-monamt < 7000000 then do:
                        for each b-jl where b-jl.acc = joudoc.cracc and b-jl.dc = 'C' and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                            find first bb-jl where bb-jl.jh = b-jl.jh and bb-jl.ln = b-jl.ln - 1 no-lock no-error.
                            if not avail bb-jl then next.
                            if bb-jl.gl <> 100100 and bb-jl.gl <> 100200 then next.

                            if bb-jl.crc = 1 then v-monamt2 = v-monamt2 + bb-jl.dam.
                            else do:
                                find last crchis where crchis.crc = bb-jl.crc and crchis.rdt < bb-jl.jdt no-lock no-error.
                                if avail crchis then v-monamt2 = v-monamt2 + bb-jl.dam * crchis.rate[1].
                            end.
                            v-mess = 1.
                        end.
                    end.

                    if v-monamt2 >= 7000000 then do:
                        if v-mess = 1 then message 'Общая сумма пополнения депозита в пользу третьего лица за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                        else message "Пополнение депозита в пользу третьего лица на сумму  ~n >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                        v-oper = '08'.
                        empty temp-table t-kfmoperh.
                        empty temp-table t-kfmprt.
                        empty temp-table t-kfmprth.

                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                        v-opSumKZT = ''.
                        if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                        do transaction:
                            run kfmoperh_cre('01', --состояние операции--
                                             '01', --основание для подачи--
                                             joudoc.docnum, --номер операции (jou,rmz)--
                                             v-oper, --вид операции--
                                             v-knpval, --КНП--
                                             '1', --кол-во участников--
                                             codfr.code, --валюта--
                                             trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')), --сумма операции--
                                             v-opSumKZT, --сумма в тенге--
                                             '', --основание совершения операции--
                                             '', --№ документа на основании которого совершается операция--
                                             '', --дата документа на основании которого совершается операция--
                                             '', --1-й код подозрительности--
                                             '', --2-й код подозрительности--
                                             '', --3-й код подозрительности--
                                             '', --описание затруднений--
                                             '', --доп.информ.по операции--
                                             '',
                                             output v-operId).
                        end. -- transaction --
                        run defclparam.

                        run kfmprt_cre(v-operId, --ИД операции--
                                       1, --ИД участника--
                                       '01', --вид участника по фин влиянию--
                                       '02', --клиент или нет--
                                       '57', --вид участника--
                                       v-res2, --резиденство--
                                       v-res, --резиденство код страны--
                                       v-cltype, --Юр, Физ, ИП--
                                       v-publicf, --иностр.публ.лицо--
                                       '',
                                       joudoc.cracc, --номер счета--
                                       cmp.name, --наим. банка--
                                       trim(sysc.chval), --бик банка--
                                       'KZ', --страна банка--
                                       '', --корр.счет--
                                       '', --банк корресп.--
                                       '', --БИК банка корресп.--
                                       '', --страна банка корресп--
                                       v-clnameU, --наимен. ЮЛ--
                                       v-FIO1U, --ФИО первого руководителя--
                                       cif.jss, --РНН--
                                       v-prtOKPO,
                                       v-OKED, --ОКЭД--
                                       cif.bin, --ИИН/БИН--
                                       v-prtFLNam, --ФИО ФЛ или ИП--
                                       v-prtFFNam,
                                       v-prtFMNam,
                                       v-prtPhone,
                                       v-prtEmail,
                                       v-prtUD, --докумен для ФЛ и ИП--
                                       v-prtUdN, --номер документа--
                                       '', --Серия документа--
                                       v-prtUdIs, --Орган выдачи--
                                       v-prtUdDt, --Когда выдан--
                                       v-bdt, --дата рождения--
                                       v-bplace, --место рождения--
                                       cif.addr[1], --Юр. адрес--
                                       cif.addr[2], --физ.адрес--
                                       '', --доп.инфо.--
                                       '01').
                        s-operType = 'fm'.
                        run kfmoper_cre(v-operId).
                        frame f_main:visible = yes.
                        if not kfmres then return.
                        v-kfm = yes.
                    end.
                end.
            end.
        end.
    end.
end.

-- пополнение депозита в пользу третьего лица - касса и касса в пути --
if not v-kfm then do:
    if (joudoc.dracctype = "1" or joudoc.dracctype = "4") and joudoc.cracctype = "2" then do:
        v-fmBreak = no.
        if joudoc.dracctype = "4" then do:
            find first arp where arp.arp = joudoc.dracc no-lock no-error.
            if not avail arp then v-fmBreak = yes.
            else do:
                if arp.gl <> 100200 then v-fmBreak = yes.
            end.
        end.
        if not v-fmBreak then do:
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            if avail aaa then do:
                find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
                if avail lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') then do:
                    find first pipl where pipl.cif = aaa.cif no-lock no-error.
                    if avail pipl then do:
                        v-mess = 0.
                        v-monamt2 = v-monamt.
                        if v-monamt < 7000000 then do:
                            for each b-jl where b-jl.acc = joudoc.cracc and b-jl.dc = 'C' and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                                find first bb-jl where bb-jl.jh = b-jl.jh and bb-jl.ln = b-jl.ln - 1 no-lock no-error.
                                if not avail bb-jl then next.
                                if bb-jl.gl <> 100100 and bb-jl.gl <> 100200 then next.

                                if bb-jl.crc = 1 then v-monamt2 = v-monamt2 + bb-jl.dam.
                                else do:
                                    find last crchis where crchis.crc = bb-jl.crc and crchis.rdt < bb-jl.jdt no-lock no-error.
                                    if avail crchis then v-monamt2 = v-monamt2 + bb-jl.dam * crchis.rate[1].
                                end.
                                v-mess = 1.
                            end.
                        end.

                        if v-monamt2 >= 7000000 then do:
                            if v-mess = 1 then message 'Общая сумма пополнения депозита в пользу третьего лица за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                            else message "Пополнение депозита в пользу третьего лица на сумму  ~n >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                            v-oper = '08'.
                            empty temp-table t-kfmoperh.
                            empty temp-table t-kfmprt.
                            empty temp-table t-kfmprth.

                            find first cif where cif.cif = aaa.cif no-lock no-error.
                            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                            v-opSumKZT = ''.
                            if joudoc.drcur <> 1 then v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                            do transaction:
                                run kfmoperh_cre('01',
                                                 '01',
                                                 joudoc.docnum,
                                                 v-oper,
                                                 v-knpval,
                                                 '1',
                                                 codfr.code,
                                                 trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),
                                                 v-opSumKZT,
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 '',
                                                 output v-operId).
                            end.
                            run defclparam.

                            run kfmprt_cre(v-operId,
                                           1,
                                           '01',
                                           '02',
                                           '57',
                                           v-res2,
                                           v-res,
                                           v-cltype,
                                           v-publicf,
                                           '',
                                           joudoc.cracc,
                                           cmp.name,
                                           trim(sysc.chval),
                                           'KZ',
                                           '',
                                           '',
                                           '',
                                           '',
                                           v-clnameU,
                                           v-FIO1U,
                                           cif.jss,
                                           v-prtOKPO,
                                           v-OKED,
                                           cif.bin,
                                           v-prtFLNam,
                                           v-prtFFNam,
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
                        end.
                    end.
                end.
            end.
        end.
    end.
end.

--оплата инкассации--
if not v-kfm then do:
    if joudoc.dracctype = "1" and joudoc.cracctype = "4" then do:
        find first arp where arp.arp = joudoc.cracc no-lock no-error.
        if avail arp then do:
            if arp.gl = 287051 then do:
                v-mess = 0.
                v-monamt2 = v-monamt.
                if v-monamt < 7000000 then do:
                    for each b-jl where b-jl.acc = joudoc.cracc and b-jl.dc = 'C' and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                        find first bb-jl where bb-jl.jh = b-jl.jh and bb-jl.ln = b-jl.ln - 1 no-lock no-error.
                        if not avail bb-jl then next.
                        if bb-jl.gl <> 100100 and bb-jl.gl <> 100200 then next.

                        if bb-jl.crc = 1 then v-monamt2 = v-monamt2 + bb-jl.dam.
                        else do:
                            find last crchis where crchis.crc = bb-jl.crc and crchis.rdt < bb-jl.jdt no-lock no-error.
                            if avail crchis then v-monamt2 = v-monamt2 + bb-jl.dam * crchis.rate[1].
                        end.
                        v-mess = 1.
                    end.
                end.

                if v-monamt2 >= 7000000 then do:
                    if v-mess = 1 then message 'Общая сумма инкассации за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                    else message "Сумма инкассации >= 7000000 тенге ~n подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                    empty temp-table t-kfmoperh.
                    empty temp-table t-kfmprt.
                    empty temp-table t-kfmprth.

                    v-oper = '16'.
                    find first cif where cif.cif = arp.cif no-lock no-error.
                    find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                    v-opSumKZT = ''.
                    if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                    run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','',output v-operId).

                    run defclparam.

                    run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
                    s-operType = 'fm'.
                    run kfmoper_cre(v-operId).
                    frame f_main:visible = yes.
                    if not kfmres then return.
                    v-kfm = yes.
                end.
            end.
        end.
    end.
end.

--инкассация собственных средств банков--
if not v-kfm then do:
    if joudoc.dracctype = "1" and joudoc.cracctype = "4" then do:
        find first arp where arp.arp = joudoc.cracc no-lock no-error.
        if avail arp and (arp.gl = 187030 or arp.gl = 286010) then do:
            if v-monamt >= 7000000 then do:
                message "Сумма инкассации >= 7000000 тенге ~n подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                v-oper = '16'.

                v-opSumKZT = ''.
                find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
                run deffilial.

                run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
                s-operType = 'fm'.
                run kfmoper_cre(v-operId).
                frame f_main:visible = yes.
                if not kfmres then return.
                v-kfm = yes.
            end.
        end.
    end.
end.
*/

/* Платежи и переводы в пользу другого лица на безвозмездной основе */
/*if not v-kfm then do:
    if v-fmTrNoAcc and v-fmTrNoAccDir = 'C' then do:
        if checkkey2 (v-fmRem,"kfmkey") and v-monamt >= 6000000 and v-knpval = '119' then do:
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

            run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','',v-iin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').

            run kfmprt_cre(v-operId,2,'01','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','02').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.
    end.
end.*/

/* Платежи и переводы в пользу другого лица на безвозмездной основе */
/*if not v-kfm then do:
    if v-fmTrNoAcc and v-fmTrNoAccDir = 'D' then do:
        if checkkey2 (v-fmRem,"kfmkey") and v-monamt >= 6000000 and v-knpval = '119' then do:
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

            run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','',v-iin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','02').

            run kfmprt_cre(v-operId,2,'02','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','01').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.


        if v-monamt >= 1000000 and (lookup(v-knpval,'119') > 0 and checkkey2(v-fmRem,'kfmk2')) then do:
            message 'Получение выигрыша на сумму >= 1000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
            v-oper = '01'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
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
        end.

    end.
end.*/

/*

--инкассация собственных средств банка--
if not v-kfm then do:
    if joudoc.dracctype = "4" and joudoc.cracctype = "1" then do:
        find first arp where arp.arp = joudoc.dracc no-lock no-error.
        if avail arp and (arp.gl = 286010) then do:
            if v-monamt >= 7000000 then do:
                message "Сумма инкассации >= 7000000 тенге ~n подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                v-oper = '16'.

                v-opSumKZT = ''.
                find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
                run deffilial.

                run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
                s-operType = 'fm'.
                run kfmoper_cre(v-operId).
                frame f_main:visible = yes.
                if not kfmres then return.
                v-kfm = yes.
            end.
        end.
    end.
end.

-- инкассация через кассу в пути --
if not v-kfm then do:
    if joudoc.dracctype = "4" and joudoc.cracctype = "4" then do:
       find first arp where  arp.arp = joudoc.dracc no-lock no-error.
       if avail arp then do:
           if arp.gl = 186010 then do:
               find first arp where  arp.arp = joudoc.cracc no-lock no-error.
               if avail arp and arp.gl = 100200 then do:
                   if v-monamt >= 7000000 then do:
                         message "Сумма инкассации >= 7000000 тенге ~n подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                         v-oper = '16'.

                         v-opSumKZT = ''.
                         find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                         if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                         empty temp-table t-kfmoperh.
                         empty temp-table t-kfmprt.
                         empty temp-table t-kfmprth.

                         run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
                         run deffilial.

                         run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
                         s-operType = 'fm'.
                         run kfmoper_cre(v-operId).
                         frame f_main:visible = yes.
                         if not kfmres then return.
                         v-kfm = yes.
                   end.
               end.
           end.
       end.
    end.
end.

-- расход со счета клиента - касса и касса в пути --
if not v-kfm then do:
    if joudoc.dracctype = "2" and (joudoc.cracctype = "1" or joudoc.cracctype = "4") then do:
       v-fmBreak = no.
        if joudoc.cracctype = "4" then do:
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            if not avail arp then v-fmBreak = yes.
            else do:
                if arp.gl <> 100200 then v-fmBreak = yes.
            end.
        end.
        if not v-fmBreak then do:

            v-mess = 0.
            v-monamt2 = v-monamt.
            if v-monamt < 7000000 then do:
                for each b-jl where b-jl.acc = joudoc.dracc and b-jl.dc = 'D' and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                    find first bb-jl where bb-jl.jh = b-jl.jh and bb-jl.ln = b-jl.ln + 1 no-lock no-error.
                    if not avail bb-jl then next.

                    if bb-jl.gl <> 100100 and bb-jl.gl <> 100200 then next.

                    if b-jl.crc = 1 then v-monamt2 = v-monamt2 + b-jl.dam.
                    else do:
                        find last crchis where crchis.crc = b-jl.crc and crchis.rdt < b-jl.jdt no-lock no-error.
                        v-monamt2 = v-monamt2 + b-jl.dam * crchis.rate[1].
                    end.
                    v-mess = 1.
                end.
            end.
            if v-monamt2 >= 7000000 then do:
                if v-mess = 1 then message 'Общая сумма снятия средств со счета за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                else message "Снятие со счета >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.

                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.

                v-oper = ''.
                if v-cltype = '01' then do:
                    if v-knpval = '321' then v-oper = '03' .
                    else  v-oper = '05'.
                end.
                else v-oper = '05'.

                find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                v-opSumKZT = ''.
                if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
                s-operType = 'fm'.
                run kfmoper_cre(v-operId).
                frame f_main:visible = yes.
                if not kfmres then return.
                v-kfm = yes.
            end.

        end.
    end.
end.

-- приход на счет клиента - касса и касса в пути --
if not v-kfm then do:
    if (joudoc.dracctype = "1" or joudoc.dracctype = "4") and joudoc.cracctype = "2" then do:
        v-fmBreak = no.
        if joudoc.dracctype = "4" then do:
            find first arp where arp.arp = joudoc.dracc no-lock no-error.
            if not avail arp then v-fmBreak = yes.
            else do:
                if arp.gl <> 100200 then v-fmBreak = yes.
            end.
        end.
        if not v-fmBreak then do:
            v-mess = 0.
            v-monamt2 = v-monamt.
            if v-monamt < 7000000 then do:
                for each b-jl where b-jl.acc = joudoc.cracc and b-jl.dc = 'C' and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                    find first bb-jl where bb-jl.jh = b-jl.jh and bb-jl.ln = b-jl.ln - 1 no-lock no-error.
                    if not avail bb-jl then next.

                    if bb-jl.gl <> 100100 and bb-jl.gl <> 100200 then next.

                    if bb-jl.crc = 1 then v-monamt2 = v-monamt2 + bb-jl.dam.
                    else do:
                        find last crchis where crchis.crc = bb-jl.crc and crchis.rdt < bb-jl.jdt no-lock no-error.
                        v-monamt2 = v-monamt2 + bb-jl.dam * crchis.rate[1].
                    end.
                    v-mess = 1.
                end.
            end.

            if v-monamt2 >= 7000000 then do:
                if v-mess = 1 then message 'Общая сумма зачисления на счет за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                else message "Зачисление на счет >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box  title 'ВНИМАНИЕ'.

                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.

                v-oper = '05'.

                find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                v-opSumKZT = ''.
                if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                run defclparam.

                run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
                s-operType = 'fm'.
                run kfmoper_cre(v-operId).
                frame f_main:visible = yes.
                if not kfmres then return.
                v-kfm = yes.
            end.
        end.
    end.
end.

if not v-kfm then do:
    if g-fname = 'obmen' then do:
        --анализ обменных операций для ФМ--
        if v-monamt >= 7000000 then do:
            --тут вызываем заполнение формы ФМ1--
            message "Обмен валюты >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box title "ВНИМАНИЕ".
            v-oper = '02'.

            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

            run kfmprt_cre(v-operId,1,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,'','',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.
    end.
end.

-- мат. помощь --
if not v-kfm then do:
    if joudoc.dracctype = "2" and joudoc.cracctype = "2" then do:
        if v-knpval = '119' then do:
            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            if aaa.cif = cif.cif then next.

            if v-monamt >= 2000000 then do:
                --проверка по ключевым словам - мат.помощь--
                if checkkey2 (v-fmRem,"kfmkey") then do:
                    message "Платежи и переводы в пользу другого лица на безвозмездной основе ~nсуммой >= 2000000 тенге подлежат финансовому мониторингу!" view-as alert-box.
                    v-oper = '09'.
                    empty temp-table t-kfmoperh.
                    empty temp-table t-kfmprt.
                    empty temp-table t-kfmprth.

                    find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

                    v-opSumKZT = ''.
                    if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                    if joudoc.dracctype = "2" and joudoc.cracctype = "2" then v-numprt  = '2'.
                    else v-numprt  = '1'.
                    run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,v-numprt,codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                    v-num = 0.
                    find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    run defclparam.
                    v-num = v-num + 1.
                    run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

                    find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    run defclparam.
                    v-num = v-num + 1.
                    run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
                    s-operType = 'fm'.
                    run kfmoper_cre(v-operId).
                    frame f_main:visible = yes.
                    if not kfmres then return.
                    v-kfm = yes.
                end.
            end.
        end.
    end.
end.

--собственные операции банка - оплата услуг (банк платит клиенту) --
if not v-kfm then do:
    if joudoc.dracctype = "4" and joudoc.cracctype = "2" then do:
        find first arp where arp.arp = joudoc.dracc no-lock no-error.
        if avail arp and (arp.gl  = 186710 or arp.gl = 187020) then do:
            if v-monamt >= 7000000 then do:
               --сделки по оказанию услуг--
               if lookup(v-knpval,'740,819,820,830,840,851,852,859,869,890,810,811,812,813,814,815,816,817,818,819,820,840,850,851,852,854,855,856,859,860,861,862,869,870,880') > 0  or (lookup(v-knpval,'120,290') > 0 and checkkey2(v-fmRem,'kfmk1')) then do:
                  message 'Платеж/перевод за оказание услуг на сумму >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

                  empty temp-table t-kfmoperh.
                  empty temp-table t-kfmprt.
                  empty temp-table t-kfmprth.

                  run deffilial.

                  v-oper = '16'.

                  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                  v-opSumKZT = ''.
                  if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                  run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                  run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').

                  find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                  find first cif where cif.cif = aaa.cif no-lock no-error.
                  run defclparam.
                  run kfmprt_cre(v-operId,2,'02','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
                  s-operType = 'fm'.
                  run kfmoper_cre(v-operId).
                  frame f_main:visible = yes.
                  if not kfmres then return.
                  v-kfm = yes.
               end.
            end.
        end.
        --получение выигрыша от нашего банка - пока не понятно как отлавливать--
        --
        if v-monamt >= 1000000 then do:
           if (lookup(v-knpval,'119') > 0 and checkkey2(v-fmRem,'kfmk2')) then do:
              message 'Получение выигрыша на сумму >= 1000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
               find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

               v-opSumKZT = ''.
               if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
               empty temp-table t-kfmoperh.
               empty temp-table t-kfmprt.
               empty temp-table t-kfmprth.

               run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).

               run deffilial.
               run kfmprt_cre(v-operId,1,'01','01','05',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','').

               --надо указать отправителя--
               find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
               find first cif where cif.cif = aaa.cif no-lock no-error.
               run defclparam.
               run kfmprt_cre(v-operId,2,'02','02','05',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'').

               run kfmoper_cre(v-operId).
               frame f_main:visible = yes.
               if not kfmres then return.
               v-kfm = yes.
           end.
        end.
        --
    end.
end.

-- сделки по оказанию услуг (клиент платит банку) --
if not v-kfm then do:
    if joudoc.dracctype = "2" and joudoc.cracctype = "4" then do:
        find first arp where arp.arp = joudoc.cracc no-lock no-error.
        if avail arp and arp.gl  = 286710 then do:
            if v-monamt >= 7000000 then do:
               --сделки по оказанию услуг--
               if lookup(v-knpval,'740,819,820,830,840,851,852,859,869,890,810,811,812,813,814,815,816,817,818,819,820,840,850,851,852,854,855,856,859,860,861,862,869,870,880') > 0  or (lookup(v-knpval,'120,290') > 0 and checkkey2(v-fmRem,'kfmk1')) then do:
                  message 'Платеж/перевод за оказание услуг на сумму >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

                  empty temp-table t-kfmoperh.
                  empty temp-table t-kfmprt.
                  empty temp-table t-kfmprth.

                  run deffilial.

                  v-oper = '16'.

                  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
                  v-opSumKZT = ''.
                  if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

                  run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

                  run kfmprt_cre(v-operId,1,'02','02','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').

                  find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                  find first cif where cif.cif = aaa.cif no-lock no-error.
                  run defclparam.
                  run kfmprt_cre(v-operId,2,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
                  s-operType = 'fm'.
                  run kfmoper_cre(v-operId).
                  frame f_main:visible = yes.
                  if not kfmres then return.
                  v-kfm = yes.
               end.
            end.
        end.
    end.
end.

if not v-kfm then do:
    if joudoc.dracctype = "2" and joudoc.cracctype = "2" then do:

        --операции между клиентами банка - оплата услуг--
        if v-monamt >= 7000000 then do:
           if lookup(v-knpval,'740,819,820,830,840,851,852,859,869,890,810,811,812,813,814,815,816,817,818,819,820,840,850,851,852,854,855,856,859,860,861,862,869,870,880') > 0  or (lookup(v-knpval,'120,290') > 0 and checkkey2(v-fmRem,'kfmk1')) then do:
              message 'Платеж/перевод за оказание услуг на сумму >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

              empty temp-table t-kfmoperh.
              empty temp-table t-kfmprt.
              empty temp-table t-kfmprth.

              find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
              find first cif where cif.cif = aaa.cif no-lock no-error.
              run defclparam.

              v-oper = '16'.

              find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
              v-opSumKZT = ''.
              if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

              run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

              run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

              find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
              find first cif where cif.cif = aaa.cif no-lock no-error.
              run defclparam.
              run kfmprt_cre(v-operId,2,'02','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
              s-operType = 'fm'.
              run kfmoper_cre(v-operId).
              frame f_main:visible = yes.
              if not kfmres then return.
              v-kfm = yes.
           end.
        end.
        --получение выигрыша--
        if v-monamt >= 1000000 then do:
           if v-knpval = '119'  and checkkey2(v-fmRem,'kfmk2') then do:
              message 'Получение выигрыша на сумму >= 1000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

              empty temp-table t-kfmoperh.
              empty temp-table t-kfmprt.
              empty temp-table t-kfmprth.

              find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
              find first cif where cif.cif = aaa.cif no-lock no-error.
              run defclparam.

              v-oper = '01'.

              find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.
              v-opSumKZT = ''.
              if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).

              run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'2',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','','', output v-operId).

              run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

              find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
              find first cif where cif.cif = aaa.cif no-lock no-error.
              run defclparam.
              run kfmprt_cre(v-operId,2,'02','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
              s-operType = 'fm'.
              run kfmoper_cre(v-operId).
              frame f_main:visible = yes.
              if not kfmres then return.
              v-kfm = yes.
           end.
        end.

    end.
end.

-- приобретение, продажа культ. ценностей (счет-счет, платежи без открытия счета) --
if not v-kfm then do:
    if v-monamt >= 7000000 and ((v-fmAcc and v-fmAccDir = 'B' and not v-fmSameClient) or v-fmTrNoAcc) then do:
        if checkkey2(v-fmRem,'kfmk3') then do:
            message "Платежи и переводы, связанные с покупкой или продажей культ. ценностей~nподлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '10'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            if v-fmAcc then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
            end.

            if v-fmTrNoAcc then do:
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'02','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','02').
            end.
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.
    end.
end.

-- страховая выплата или премия --
if not v-kfm then do:
    if v-fmAcc and v-fmAccDir = 'B' and v-monamt >= 7000000 then do:
        if lookup(v-knpval,"027,046,048,830,831,832,833,834,835,836,837,839") > 0 then do:
            message "Осуществление страховой выплаты или получение страховой премии~nподлежит финансовому мониторингу!" view-as alert-box.
            v-oper = '13'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.
    end.
end.

-- драгоценные камни и металлы --
if not v-kfm then do:
    if  (v-monamt >= 7000000) and ((v-fmAcc and v-fmAccDir = 'B' and not v-fmSameClient) or v-fmTrNoAcc) then do:
        if (v-knpval = "290" and checkkey2(v-fmRem,'kfmk4')) or (lookup(v-knpval,"219,220,229") > 0) then do:
            message "Платежи и переводы, связанные с покупкой или продажей~nдрагоценных металлов и драгоценных камней~nподлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '17'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            if v-fmAcc then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                v-num = 0.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
            end.

            if v-fmTrNoAcc then do:
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'02',v-publicf,'','',cmp.name,trim(sysc.chval),'KZ','','','','','','',v-rnn,'','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,'',v-prtUD,v-prtUdN,'',v-prtUdIs,string(v-regdt,'99/99/9999'),string(v-dtbth,'99/99/9999'),v-bplace,v-addr,'','','01').
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'02','01','57','','','','1','','','','','','','','','','','','','','','',v-clfam2,v-clname2,v-clmname2,'','','','','','','','','','','','','02').
            end.
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.
    end.
end.

-- сделки с недвижимым имуществом --
if not v-kfm then do:
    if lookup(v-knpval,"720,721,722") > 0 and v-monamt >= 45000000 then do:
        if (v-fmAcc and v-fmAccDir = 'B') then do:
            message "Сделки с недвижимым и иным имуществом,~nподлежащим обязательной гос. регистрации,~nподлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '18'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.
            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').

            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            find first cif where cif.cif = aaa.cif no-lock no-error.
            run defclparam.
            v-num = v-num + 1.
            run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
        end.
        if (joudoc.dracctype = "4" or joudoc.cracctype = "4") and (not v-fmCash) and (not v-fmTrNoAcc) then do:
            message "Сделки с недвижимым и иным имуществом,~nподлежащим обязательной гос. регистрации,~nподлежат финансовому мониторингу!" view-as alert-box.
            v-oper = '18'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            run deffilial.
            v-num = v-num + 1.
            if joudoc.dracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
            else run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','02').

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
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,v-prtOKPO,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
            end.
        end.
        s-operType = 'fm'.
        run kfmoper_cre(v-operId).
        frame f_main:visible = yes.
        if not kfmres then return.
        v-kfm = yes.
    end.
end.

def var v-fmaaa as char no-undo.
if not v-kfm then do:
    if v-blagot and not v-fmSameClient and not v-fmcash then do:
        v-monamt2 = v-monamt.
        if v-blagotDir = 'D' then v-fmaaa = joudoc.dracc.
        else v-fmaaa = joudoc.cracc.
        if v-monamt2 < 2000000 then do:
            for each b-jl where b-jl.acc = v-fmaaa and b-jl.dc = v-blagotDir and b-jl.jdt > (g-today - 7) and b-jl.jdt <= g-today no-lock:
                if b-jl.crc = 1 then do:
                    if v-blagotDir = 'D' then v-monamt2 = v-monamt2 + b-jl.dam.
                    else v-monamt2 = v-monamt2 + b-jl.cam.
                end.
                else do:
                    find last crchis where crchis.crc = b-jl.crc and crchis.rdt < b-jl.jdt no-lock no-error.
                    if avail crchis then do:
                        if v-blagotDir = 'D' then v-monamt2 = v-monamt2 + b-jl.dam * crchis.rate[1].
                        else v-monamt2 = v-monamt2 + b-jl.cam * crchis.rate[1].
                    end.
                end.
            end.
            v-mess = 1.
        end.
        if v-monamt2 >= 2000000 then do:
            if v-mess = 1 then message 'Общая сумма переводов благотворительной организации за последние 7 дней >= 2000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
            else message "Перевод благотворительной организации на сумму >= 2000000 тенге подлежит финансовому мониторингу!" view-as alert-box  title 'ВНИМАНИЕ'.

            v-oper = '09'.
            find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(joudoc.drcur) no-lock no-error.

            v-opSumKZT = ''.
            if joudoc.drcur <> 1 then  v-opSumKZT = trim(string(joudoc.dramt * crc.rate[1],'>>>>>>>>>>>>9.99')).
            empty temp-table t-kfmoperh.
            empty temp-table t-kfmprt.
            empty temp-table t-kfmprth.

            run kfmoperh_cre('01','01',joudoc.docnum,v-oper,v-knpval,'1',codfr.code,trim(string(joudoc.dramt,'>>>>>>>>>>>>9.99')),v-opSumKZT,'','','','','','','','', '',output v-operId).
            v-num = 0.

            run deffilial.
            v-num = v-num + 1.
            if joudoc.dracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
            if joudoc.cracctype = "4" then run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','02').

            if joudoc.dracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.dracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
            end.

            if joudoc.cracctype = "2" then do:
                find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                find first cif where cif.cif = aaa.cif no-lock no-error.
                run defclparam.
                v-num = v-num + 1.
                run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',joudoc.cracc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
            end.
            s-operType = 'fm'.
            run kfmoper_cre(v-operId).
            frame f_main:visible = yes.
            if not kfmres then return.
            v-kfm = yes.
        end.

    end.

end.

*/
