/* bnkrel-chk1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        добавление информации о клиентах связанных с банком особыми отношениями
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cif-new.p cif-joi.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
       05/08/2013 - Luiza ТЗ 1728
 * BASES
        BANK COMM
 * CHANGES
            07/08/2013 Luiza - перекомпиляция

*/

{global.i}

def input parameter ss-cif like cif.cif.
def output parameter s-resp as int.

def var v-bank as char no-undo.
def var v-bname as char no-undo.
def var v-maillist as char no-undo.
def var v-sv as char no-undo.
def var v-ot as char no-undo.
def var l-operId as int no-undo.
def var v-i as int.

def temp-table wrk
field bin as char
field name as char
field sv as char
field ot as char
field pr as int.

find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc then do:
    message "" view-as alert-box.
    return.
end.
v-bank = sysc.chval.
{chk12_innbin.i}

find first cif where cif.cif = ss-cif no-lock no-error.
if not avail cif  then do:
    message "Cif-код клиента не найден!" view-as alert-box title "Внимание".
    s-resp = 1.
    return.
end.
v-sv = "".
create wrk.
wrk.bin = cif.bin.
wrk.name = trim(cif.prefix) + " " + trim(cif.name).
wrk.pr = 1.
wrk.sv = "".

/* данные по первому руководителю */
find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'clnchf' and sub-cod.ccode = 'chief' no-lock no-error.
if avail sub-cod then do:
    create wrk.
    wrk.name = sub-cod.rcode.
    wrk.pr = 2.
    wrk.sv = "".
    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'clnchfrnn' and sub-cod.ccode = 'chfrnn' no-lock no-error.
    if avail sub-cod and sub-cod.rcode <> "" then  wrk.bin = sub-cod.rcode.

end.
/* по учередителям */
for each founder where founder.cif = cif.cif no-lock.
    create wrk.
    wrk.bin = founder.bin.
    wrk.name = founder.name.
    wrk.pr = 3.
    wrk.sv = "".
end.
for each wrk.
    if chk12_innbin(trim(wrk.bin)) then find first prisv where trim(prisv.rnn) = trim(wrk.bin)  no-lock no-error.
    else find first prisv where trim(prisv.name) = trim(wrk.name) use-index name no-lock no-error. /* если ИИН некорректный или нерезидент */
    if avail prisv then do:
        if wrk.pr = 1 then do:
            if cif.type = "B" then wrk.sv = "по компании".
            else wrk.sv = "по фамилии или ИИН".
            if cif.type = "B" then v-sv = "по компании".
            else v-sv = "по фамилии или ИИН".

            find first codfr where (codfr.codfr = "affil") and (codfr.code = prisv.specrel) no-lock no-error.
            if available codfr then do:
                wrk.ot = codfr.name[1].
                v-ot = codfr.name[1].
            end.
        end.
        if wrk.pr = 2 then do:
            wrk.sv = "по первому руководителю".
            if v-sv = "" then v-sv = "по первому руководителю".
            else v-sv = v-sv + " и первому руководителю".
            find first codfr where (codfr.codfr = "affil") and (codfr.code = prisv.specrel) no-lock no-error.
            if available codfr then do:
                wrk.ot = codfr.name[1].
                if v-ot = "" then v-ot = codfr.name[1].
                else v-ot = v-ot  + "; " + codfr.name[1].
            end.
        end.
        if wrk.pr = 3 then do:
            wrk.sv = "по учередителю".
            if v-sv = "" then v-sv = "по учередителю".
            else if not v-sv matches "*учередителю*" then  v-sv = v-sv + " и учередителю".
            find first codfr where (codfr.codfr = "affil") and (codfr.code = prisv.specrel) no-lock no-error.
            if available codfr then do:
                wrk.ot = codfr.name[1].
                if v-ot = "" then v-ot = codfr.name[1].
                else v-ot = v-ot  + "; " + codfr.name[1].
            end.
        end.
    end.
end.
for each wrk where wrk.sv <> "" no-lock.
    find first kfmoper where kfmoper.operDoc = ss-cif and kfmoper.rwhn = g-today no-lock no-error.
    if not available kfmoper then do:
        if wrk.pr = 1 then message "Внимание! Данный клиент связан с банком особыми отношениями, операция приостановлена и требует согласования со Службой комплаенс!" view-as alert-box.
        else message "Внимание! Руководитель или учередители связаны с банком особыми отношениями, операция приостановлена и требует согласования со Службой комплаенс!" view-as alert-box.
        /*подключение comm */
        find sysc where sysc.sysc = 'CMHOST' no-lock no-error.
        if avail sysc then connect value (sysc.chval) no-error.
        /*--------------------------------------------------------*/
        l-operId = next-value(kfmOperId,COMM).
        create kfmoper.
        assign kfmoper.bank = v-bank
               kfmoper.operId = l-operId
               kfmoper.operDoc = ss-cif
               kfmoper.sts = 0
               kfmoper.rwho = g-ofc
               kfmoper.rwhn = g-today
               kfmoper.operType = "br"
               kfmoper.rem[1] = cif.sname
               kfmoper.rem[2] = cif.bin.
               kfmoper.rtim = time.
        find current kfmoper no-lock no-error.
        s-resp = 1.

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
                run mail(v-maillist ,g-ofc + "@fortebank.com","Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу","Филиал: " + v-bname + "\n" +
                "Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу " + trim(cif.prefix) + " " + trim(cif.name) +
                " хочет открыть банковский счет, в связи с чем просим вас вынести вопрос на рассмотрение Совета директоров.
                \nПризнак связанности: " + v-ot + "\n" +
                "\nПараметр связанности: "  + v-sv  + ". " ,"1", "","").

            end.
        end.
        return.
    end.
    else do:
        if kfmoper.sts  = 1 then do:
            s-resp = 0.
        end.
        if kfmoper.sts  = 98 then do:
            s-resp = 1.
            message "Проведение операции запрещено! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
        end.
        if kfmoper.sts  = 0 then do:
            s-resp = 1.
            message "Операция приостановлена для анализа! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
        end.
    end.
end.
