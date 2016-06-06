/* ap_trx.p
 * MODULE
        Платежи - Авангард-Плат
 * DESCRIPTION
        Отправка платежа в Авангард-Плат
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
        13/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        24/11/2010 madiyar - по ИВЦ документ формируется аналогично АЛСЕКО
        15/12/2010 madiyar - изменения для провайдера АлматыЭнергоСбыт (229)
        22.12.2010 k.gitalov - добавление провайдера Казахтелеком  (298)
        16.02.2011 k.gitalov добавил ЖесказганЭнергоСбыт и Астана ЕРЦ
        03.10.2012 damir - изменения по провайдеру ICON (поставил комплексную онлайн проверку). На основании С.З. от 03.10.2012.
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.
        14.11.2012 damir - Добавление к изменению 07.11.2012. Variable - v-Suppcom,v-acc,v-payacc.
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
        10.04.2013 damir - Внедрено Т.З. № 1577,1571.
*/

{classes.i}
{apterm.i}

def input parameter Doc as class COMPAYDOCClass.
def output parameter p-errcode as integer no-undo init 0.
def output parameter p-errdes as char no-undo init ''.

def var supp_ap_id as integer no-undo.
def var v-request as char no-undo.
def var v-reply as char no-undo.
def var v-reply2 as char no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-Suppcom as char init '' no-undo.
def var v-acc as char init '' no-undo.
def var v-payacc as char no-undo.
def var v-userId as integer no-undo.
v-userId = getUserId("aptcp").

function getErrorDes returns char (input err_code as integer).
    def var res as char no-undo.
    find first aperrlist where aperrlist.errcode = err_code no-lock no-error.
    if avail aperrlist then res = aperrlist.errdes. else res = string(err_code) + ": неизвестная ошибка".
    return res.
end function.

function getDateTime returns char.
    def var res as char no-undo.
    res = string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + replace(string(time,"hh:mm:ss"),':','').
    return res.
end function.

/*
function getStringNum returns char (input p-docnum as integer).
    def var res as char no-undo.
    res = string(p-docnum).
    if length(res) < 8 then res = fill('0',8 - length(res)) + res.
    return res.
end function.
*/

find first suppcom where suppcom.supp_id = Doc:supp_id no-lock no-error.
if avail suppcom then do:
    if suppcom.ap_code <= 0 then do:
        p-errcode = 9000. /* Отправка в Авангард-Плат запроса по провайдеру, не обслуживаемому Авангард-Плат */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    else supp_ap_id = suppcom.ap_code.
    if suppcom.type = 0 then do:
        p-errcode = 9001. /* Провайдер отмечен в iXora как неактивный */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    if Doc:state <> 0 then do:
        p-errcode = 9016. /* Некорректный статус документа */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    if length(Doc:payacc) < suppcom.minlen or length(Doc:payacc) > suppcom.maxlen then do:
        p-errcode = 9002. /* Некорректная длина номера счета/телефона */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    if Doc:summ < suppcom.minsum then do:
        p-errcode = 9003. /* Сумма платежа меньше минимально допустимой */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    /* if Alseco or IVC or ICON*/
    if (supp_ap_id = 8) or (supp_ap_id = 113) or (supp_ap_id = 4) then do:
        if Doc:ExData:Count <= 0 then do:
            p-errcode = 9007. /* В документе отсутствует информация по суб-сервисам */
            p-errdes = getErrorDes(p-errcode).
            return.
        end.
    end.
end.
else do:
    p-errcode = 9017. /* Некорректный провайдер */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

v-payacc = Doc:payacc.

case supp_ap_id:
    when 530 then v-acc = trim(Doc:type_pay) + ";" + trim(Doc:code_reg). /*Шыгысэнерготрейд*/
    when 536 then v-acc = trim(Doc:type_pay). /*Нурсат*/
end case.

/*В теге <ac></ac> передаются кроме лицевого счета и другие параметры*/
v-Suppcom = '530,536'.
if lookup(trim(string(supp_ap_id)),v-Suppcom) > 0 then if not Doc:AddStr(v-acc) then message "Doc:AddStr method failed!" view-as alert-box.

/* build request string */
v-request = '[PaysXML]<rq>'.
if Doc:prev_docno <> ? then v-request = v-request + '<p n="' + string(Doc:prev_docno) + '" su="' + string(v-userId) + '" prv="' + string(supp_ap_id) + '"'.
else v-request = v-request + '<p n="' + string(Doc:docno) + '" su="' + string(v-userId) + '" prv="' + string(supp_ap_id) + '"'.

/*if (Doc:prev_docno <> ?) and (Doc:prev_docno <> 0) then v-request = v-request + ' rsu="' + string(v-userId) + '" rsn="' + string(Doc:prev_docno) + '"'.*/

v-request = v-request + '>'.
v-request = v-request + '<ac>' + trim(Doc:payacc) + '</ac><am>' + trim(string(Doc:summ,">>>>>>>>9.99")) + '</am><cm>0</cm><d>' + getDateTime() + '</d>' + '<cmnt></cmnt>'.

Doc:payacc = v-payacc.

/* asibo */
if supp_ap_id = 57 then do:
    v-request = v-request + "<addings>".
    v-request = v-request + "<adding>".
    v-request = v-request + "<Constr>" + /* address */ Doc:payaddr + "</Constr>".
    v-request = v-request + "<SubServ>0</SubServ>".
    v-request = v-request + "<Am0>"  + trim(string(Doc:summ,">>>>>>>>9.99")) + "</Am0>".
    v-request = v-request + "<Am1>0</Am1>".
    v-request = v-request + "<Am2>0</Am2>".
    v-request = v-request + "<Com>0</Com>".
    v-request = v-request + "</adding>".
    v-request = v-request + "</addings>".
end.

/* ШыгысЭнергоТрейд */
/*
if supp_ap_id = 270 or supp_ap_id = 271 or supp_ap_id = 272 or supp_ap_id = 273 then do:
    v-request = v-request + "<addings>".
    v-request = v-request + "<adding>".
    v-request = v-request + "<Constr>" + /* address */ Doc:payaddr + "</Constr>".
    v-request = v-request + "<SubServ>0</SubServ>".
    v-request = v-request + "<Am0>"  + trim(string(Doc:summ,">>>>>>>>9.99")) + "</Am0>".
    v-request = v-request + "<Am1>0</Am1>".
    v-request = v-request + "<Am2>0</Am2>".
    v-request = v-request + "<Com>0</Com>".
    v-request = v-request + "</adding>".
    v-request = v-request + "</addings>".
end.
*/

/* otis */
if supp_ap_id = 58 then do:
    v-request = v-request + "<addings>".
    v-request = v-request + "<adding>".
    v-request = v-request + "<Constr>" + /* contract ID */ entry(1,Doc:note1,' ') + "</Constr>".
    v-request = v-request + "<SubServ>0</SubServ>".
    v-request = v-request + "<Am0>"  + trim(string(Doc:summ,">>>>>>>>9.99")) + "</Am0>".
    v-request = v-request + "<Am1>0</Am1>".
    v-request = v-request + "<Am2>0</Am2>".
    v-request = v-request + "<Com>0</Com>".
    v-request = v-request + "</adding>".
    v-request = v-request + "</addings>".
end.

/*Kazaxtelecom*/
if supp_ap_id = 298 then do:
    v-request = v-request + "<addings>".
    v-request = v-request + "<adding>".
    v-request = v-request + "<Constr>" + /* abonent ID */ Doc:payname + "</Constr>".
    v-request = v-request + "<SubServ>0</SubServ>".
    v-request = v-request + "<Am0>"  + trim(string(Doc:summ,">>>>>>>>9.99")) + "</Am0>".
    v-request = v-request + "<Am1>0</Am1>".
    v-request = v-request + "<Am2>0</Am2>".
    v-request = v-request + "<Com>0</Com>".
    v-request = v-request + "</adding>".
    v-request = v-request + "</addings>".
end.
/* alseco or ivc or almatyenergosbyt or ЖесказганЭнергоСбыт or Астана ЕРЦ or ICON or АстанаЭнергоСбыт or Оскемен-Водоканал ГКП*/
if lookup(string(supp_ap_id),"8,113,229,232,137,4,465,619") gt 0 then do:
    v-request = v-request + "<addings>".
    do i = 1 to Doc:ExData:Count:
        if Doc:ExData:ElementBy(i):Pay > 0 then do:
            v-request = v-request + "<adding>".
            v-request = v-request + "<Constr>" + Doc:ExData:ElementBy(i):Invoice + "</Constr>".
            v-request = v-request + "<SubServ>" + string(Doc:ExData:ElementBy(i):IdSub) + "</SubServ>".
            v-request = v-request + "<Am0>" + trim(string(Doc:ExData:ElementBy(i):Pay,">>>>>>>>9.99")) + "</Am0>".
            v-request = v-request + "<Am1>" + string(Doc:ExData:ElementBy(i):Curr) + "</Am1>".
            v-request = v-request + "<Am2>" + trim(string(Doc:ExData:ElementBy(i):Amount,">>>>>>>>9.99")) + "</Am2>".
            v-request = v-request + "<Com>0</Com>".

            if Doc:ExData:ElementBy(i):lastCountDate ne ? then
            v-request = v-request + "<LastCountDate>" + substr(string(Doc:ExData:ElementBy(i):lastCountDate,"99/99/9999"),7,4) +
            substr(string(Doc:ExData:ElementBy(i):lastCountDate,"99/99/9999"),4,2) +
            substr(string(Doc:ExData:ElementBy(i):lastCountDate,"99/99/9999"),1,2) + "000000" + "</LastCountDate>".

            v-request = v-request + "</adding>".
        end.
    end.
    v-request = v-request + "</addings>".
end.

v-request = v-request + '</p>'.
v-request = v-request + '</rq>'.

/*output to 1.xml.
put unformatted v-request.
output close.*/

run savelog('ap','ap_trx->' + v-request).
run ap_send("tcp",yes,v-request,output v-reply).
run savelog('ap','ap_trx<-' + v-reply).

hide frame f1.

/*Testing*/
/*if Doc:prev_docno <> ? then v-reply = "[PaysXML]" + string(Doc:prev_docno) + "," + string(v-userId).
else v-reply = "[PaysXML]" + string(Doc:docno) + "," + string(v-userId).*/

p-errcode = 0.
if v-reply matches "mcberr*" then do:
    p-errcode = integer(entry(2,v-reply,'=')) no-error. /* код ошибки возвращается ESB-сервисом */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

if v-reply = v-request then do:
    p-errcode = 9010. /* Сервис недоступен */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

if v-reply matches '?*' then do:
    p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    p-errdes = '(?) ' + getErrorDes(p-errcode).
    return.
end.

if trim(v-reply) = '' then do:
    p-errcode = 9005. /* Сервис вернул пустую строку */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

if Doc:prev_docno <> ? then do:
    if v-reply = "[PaysXML]" + string(Doc:prev_docno) + "," + string(v-userId) then do:
        if not(Doc:SetState(1,?,0)) then do:
            p-errcode = 9031. /* Ошибка проставления статуса документа */
            p-errdes = '(?) ' + getErrorDes(p-errcode).
        end.
    end.
    else do:
        p-errcode = 9011. /* Ошибка обработки ответа на запрос */
        p-errdes = getErrorDes(p-errcode).
    end.
end.
else do:
    if v-reply = "[PaysXML]" + string(Doc:docno) + "," + string(v-userId) then do:
        if not(Doc:SetState(1,?,0)) then do:
            p-errcode = 9031. /* Ошибка проставления статуса документа */
            p-errdes = '(?) ' + getErrorDes(p-errcode).
        end.
    end.
    else do:
        p-errcode = 9011. /* Ошибка обработки ответа на запрос */
        p-errdes = getErrorDes(p-errcode).
    end.
end.

