/* kfmSendSdfo.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Отправка сообщения
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        27/05/2010 galina - перекомпиляция
        06/08/2010 madiyar - перешли на transferVersionId=2
*/

{global.i}

def input parameter p-operId as integer no-undo.
def output parameter p-opErr as logi no-undo.
def output parameter p-opErrDes as char no-undo.

p-opErr = yes.
p-opErrDes = "Неизвестная ошибка".

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var i as integer no-undo.
def var v-msg as char no-undo.
v-msg = string(p-operId).

def var v-cif as char no-undo.
def var v-fio as char no-undo.

def new shared temp-table t-msgParam no-undo
  field paramType as char
  field paramName as char
  field paramValue as char.


procedure createParamCountry.
    def input parameter p-n as integer no-undo.
    def input parameter p-dataCode as char no-undo.
    def input parameter p-dataValue as char no-undo.
    def var v-paramTypeEx as char no-undo.
    def var v-paramName as char no-undo.
    def var v-paramValue as char no-undo.
    v-paramTypeEx = ''. v-paramName = ''. v-paramValue = ''.
    find first codfr where codfr.codfr = "iso3166" and codfr.code = p-dataValue no-lock no-error.
    if avail codfr then do:
        v-paramName = p-dataCode.
        /*
        if p-dataCode = "prtBCoun" then assign v-paramTypeEx = 'c' v-paramValue = codfr.name[1].
        else do:
            v-paramTypeEx = 'i'.
            find first code-st where code-st.code = p-dataValue no-lock no-error.
            if avail code-st then do:
                v-paramValue = code-st.cod-ch.
            end.
            else v-paramValue = '0'.
        end.
        */
        if p-dataCode = "prtBCoun" then v-paramTypeEx = 'c'.
        else v-paramTypeEx = 'i'.
        find first code-st where code-st.code = p-dataValue no-lock no-error.
        if avail code-st then do:
            v-paramValue = code-st.cod-ch.
        end.
        else v-paramValue = '0'.
    end.
    if v-paramTypeEx <> '' and v-paramName <> '' then do:
        /* message "3.... " + p-dataCode + ' ' + v-paramName + ' ' + v-paramValue view-as alert-box. */
        run createParam(v-paramTypeEx, v-paramName + "_" + string(p-n), v-paramValue).
    end.
end procedure. /* createParamCountry */

procedure createParam.
    def input parameter p-paramType as char no-undo.
    def input parameter p-paramName as char no-undo.
    def input parameter p-paramValue as char no-undo.
    create t-msgParam.
    assign t-msgParam.paramType = p-paramType
           t-msgParam.paramName = p-paramName
           t-msgParam.paramValue = p-paramValue.
end procedure. /* createParam */

procedure parseAddress.
    def input parameter p-dataCode as char no-undo.
    def input parameter suffix as char no-undo.
    def input parameter p-dataValue as char no-undo.

    def var v-country2 as char no-undo init ''.
    def var v-country_cod as char no-undo init '0'.
    def var v-region as char no-undo init ''.
    def var v-city as char no-undo init ''.
    def var v-street as char no-undo init ''.
    def var v-house as char no-undo init ''.
    def var v-office as char no-undo init ''.
    def var v-index  as char no-undo init '0'.

    if num-entries(p-dataValue) = 7 then do:
        v-country2 = entry(1,p-dataValue).
        if num-entries(v-country2,"(") = 2 then v-country_cod = substr(entry(2,entry(1,p-dataValue),"("),1,2).
        assign v-country2 = trim(entry(1,entry(1,p-dataValue),"("))
              v-region = entry(2,p-dataValue)
              v-city = entry(3,p-dataValue)
              v-street = entry(4,p-dataValue)
              v-house = entry(5,p-dataValue)
              v-office = entry(6,p-dataValue)
              v-index = entry(7,p-dataValue).
    end.

    find first code-st where code-st.code = v-country_cod no-lock no-error.
    if avail code-st then v-country_cod = code-st.cod-ch.

    run createParam("i", p-dataCode + "_ccode_" + suffix,  v-country_cod).
    run createParam("c", p-dataCode + "_region_" + suffix, v-region).
    run createParam("c", p-dataCode + "_city_" + suffix,   v-city).
    run createParam("c", p-dataCode + "_street_" + suffix, v-street).
    run createParam("c", p-dataCode + "_house_" + suffix,  v-house).
    run createParam("c", p-dataCode + "_office_" + suffix, v-office).
    run createParam("i", p-dataCode + "_index_" + suffix,  v-index).
end procedure. /* parseAddress */

/*
procedure processFounders:
    def input parameter p-n as integer no-undo.
    def input parameter p-cif as char no-undo.
    def var founder_prefix as char no-undo init "founder".
    def var suffix as char no-undo.
    def var v-country_cod as char no-undo.
    def var k as integer no-undo.
    k = 0.
    for each founder where founder.cif = p-cif no-lock:
        k = k + 1.
        suffix = string(p-n) + "_" + string(k).
        if founder.ftype = 'B' then do:
            run createParam("i", founder_prefix + "Type_" + suffix, "1").
            run createParam("c", founder_prefix + "BIN_" + suffix, founder.bin).
            run createParam("c", founder_prefix + "UName_" + suffix, founder.name).
            run createParam("i", founder_prefix + "URes_" + suffix, string(founder.res)).
            v-country_cod = '0'.
            find first code-st where code-st.code = founder.country no-lock no-error.
            if avail code-st then v-country_cod = code-st.cod-ch.
            run createParam("i", founder_prefix + "UResC_" + suffix, v-country_cod).
            run createParam("c", founder_prefix + "URegWho_" + suffix, founder.orgreg).
            run createParam("c", founder_prefix + "URegNum_" + suffix, founder.numreg).
            run createParam("d", founder_prefix + "URegWhn_" + suffix, string(founder.dtreg,"99/99/9999")).
            run createParam("c", founder_prefix + "URNN_" + suffix, founder.rnn).

            run parseAddress("addrReg", suffix, founder.adress).
        end.
        else do:
            run createParam("i", founder_prefix + "Type_" + suffix, "2").
            run createParam("c", founder_prefix + "BIN_" + suffix, founder.bin).

            run createParam("c", founder_prefix + "FLNam_" + suffix, founder.sname).
            run createParam("c", founder_prefix + "FFNam_" + suffix, founder.fname).
            run createParam("c", founder_prefix + "FMNam_" + suffix, founder.mname).
            run createParam("d", founder_prefix + "FBdt_" + suffix, string(founder.dtbth,"99/99/9999")).
            run createParam("c", founder_prefix + "FPssNum_" + suffix, founder.numreg).
            run createParam("c", founder_prefix + "FPssSer_" + suffix, founder.pserial).
            run createParam("c", founder_prefix + "FPssWho_" + suffix, founder .orgreg).
            run createParam("d", founder_prefix + "FPssWhn_" + suffix, string(founder.dtreg,"99/99/9999")).

            run parseAddress("addrReg", suffix, founder.adress).
        end.
    end.

    run createParam("i", "uFndCount_" + string(p-n), string(k)).

end procedure.
*/

procedure processFounders:
    def input parameter p-n as integer no-undo.
    def input parameter p-cif as char no-undo.
    def var founder_prefix as char no-undo init "founder".
    def var suffix as char no-undo.
    def var v-country_cod as char no-undo.
    def var k as integer no-undo.
    k = 0.
    for each founder where founder.cif = p-cif no-lock:
        k = k + 1.
        suffix = string(p-n) + "_" + string(k).
        if founder.ftype = 'B' then do:
            run createParam("i", founder_prefix + "Type_" + suffix, "1").
            run createParam("c", founder_prefix + "UName_" + suffix, founder.name).
        end.
        else do:
            run createParam("i", founder_prefix + "Type_" + suffix, "2").
            run createParam("c", founder_prefix + "UName_" + suffix, trim(trim(founder.sname + ' ' + founder.fname) + ' ' + founder.mname)).
        end.
        v-country_cod = '0'.
        find first code-st where code-st.code = founder.country no-lock no-error.
        if avail code-st then v-country_cod = code-st.cod-ch.
        run createParam("i", founder_prefix + "UResC_" + suffix, v-country_cod).
    end.

    run createParam("i", "uFndCount_" + string(p-n), string(k)).

end procedure.


find first kfmoper where kfmoper.bank = s-ourbank and kfmoper.operId = p-operId no-lock no-error.
if not avail kfmoper then do:
    p-opErrDes = "Операция не найдена".
    return.
end.

if kfmoper.sts <> 1 /* проверена */ then do:
    p-opErrDes = "Некорректный статус операции для выгрузки в СДФО".
    return.
end.

for each kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId no-lock:
    if lookup(kfmoperh.dataCode,"fm1Num,fm1Date") > 0 then next.
    find first kfmkrit where kfmkrit.dataCode = kfmoperh.dataCode and kfmkrit.priz = 0 no-lock no-error.
    if avail kfmkrit then run createParam(kfmkrit.dataTypeEx, kfmoperh.dataCode, kfmoperh.dataValue).
end.

/* если не проставлен КНП или вообще нет такого признака, то проставляем признак "невозможно указать КНП" */
find first kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId and kfmoperh.dataCode = "opEknp" no-lock no-error.
if (not avail kfmoperh) or (trim(kfmoperh.dataValue) = '') then run createParam("i", "isNotIdTyped", "1").
else run createParam("i", "isNotIdTyped", "0").

if kfmoper.rwhn <> ? then run createParam("d", "poper_trans_date", string(kfmoper.rwhn,"99/99/9999") + ' ' + string(kfmoper.rtim,"hh:mm:ss")).
else do:
    find first kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId and kfmoperh.dataCode = "opDocDt" no-lock no-error.
    if avail kfmoperh then run createParam("d", "poper_trans_date", kfmoperh.dataValue + " 00:00:00").
    else do:
        p-opErrDes = "Не найдена дата документа".
        return.
    end.
end.

/*
for each t-msgParam where t-msgParam.paramName = "poper_trans_date" no-lock:
    displ t-msgParam.paramValue format "x(50)" with overlay frame ffffr.
    displ t-msgParam with overlay frame ffffr.
end.
pause.
*/

i = 0.
for each kfmprt where kfmprt.bank = kfmoper.bank and kfmprt.operId = kfmoper.operId no-lock:
    i = i + 1.
    for each kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId and kfmprth.partId = kfmprt.partId no-lock:
        case kfmprth.dataCode:
            when "prtFrom" then next.
            when "prtRsdC" or when "prtBCoun" then run createParamCountry(i,kfmprth.dataCode,kfmprth.dataValue).
            when "prtAddrU" or when "prtAddrF" then run parseAddress(kfmprth.dataCode,string(i),kfmprth.dataValue).
            otherwise do:
                find first kfmkrit where kfmkrit.dataCode = kfmprth.dataCode and kfmkrit.priz = 1 no-lock no-error.
                if avail kfmkrit then run createParam(kfmkrit.dataTypeEx, kfmprth.dataCode + "_" + string(i), kfmprth.dataValue).
            end.
        end case.
    end.

    run createParam("i", "isNotNamed_" + string(i), "0").

    find first kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = "prtType" no-lock no-error.
    if avail kfmprth and kfmprth.dataValue <> '01' then do:
        v-fio = ''.
        find first kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = "prtFLNam" no-lock no-error.
        if avail kfmprth then v-fio = kfmprth.dataValue.
        find first kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = "prtFFNam" no-lock no-error.
        if avail kfmprth then v-fio = trim(v-fio + ' ' + kfmprth.dataValue).
        find first kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = "prtFMNam" no-lock no-error.
        if avail kfmprth then v-fio = trim(v-fio + ' ' + kfmprth.dataValue).
        if v-fio <> '' then do:
            find first t-msgParam where t-msgParam.paramName = "prtNameU" + "_" + string(i).
            t-msgParam.paramValue = v-fio.
        end.
    end.

    v-cif = ''.
    find first kfmprth where kfmprth.bank = s-ourbank and kfmprth.operId = kfmprt.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = "prtBAcc" no-lock no-error.
    if avail kfmprth and kfmprth.dataValue <> '' then do:
        find first aaa where aaa.aaa = kfmprth.dataValue no-lock no-error.
        if avail aaa then v-cif = aaa.cif.
        else do:
            find first arp where arp.arp = kfmprth.dataValue no-lock no-error.
            if avail arp then v-cif = arp.cif.
        end.
    end.
    /*message "1.." + v-cif view-as alert-box.*/
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        /*message "2.." + v-cif view-as alert-box.*/
        find first founder where founder.cif = v-cif no-lock no-error.
        if avail founder then run processFounders(i,v-cif).
        else run createParam("i", "uFndCount_" + string(i), '0').
    end.

end.




run kfmSendSdfo2(v-msg,output p-opErr, output p-opErrDes).

/*
for each t-msgParam no-lock:
displ t-msgParam.paramType t-msgParam.paramName format "x(30)" t-msgParam.paramValue format "x(30)".
end.
*/




