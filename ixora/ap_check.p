/* ap_check.p
 * MODULE
        Платежи - Авангард-Плат
 * DESCRIPTION
        Запрос инвойса Авангард-Плат
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
        15/12/2010 madiyar - изменения для провайдера АлматыЭнергоСбыт (229)
        16.02.2011 k.gitalov добавил ЖесказганЭнергоСбыт и Астана ЕРЦ
        03.03.2011 k.gitalov добавил обработку пробелов в Астана ЕРЦ и вывод названий субсервисов в алсеко
        10.05.2011 k.gitalov изменил AKTIV KCELL
        02.04.2012 k.gitalov добавил Digital TV и diji АЛМАТЫ
        27.04.2012 k.gitalov добавил [diji] АСТАНА [diji] АКТАУ [diji] КАРАГАНДА [diji] ТАРАЗ [diji] УРАЛЬСК
        23.05.2012 k.gitalov добавил обработку казахских символов для Астана ЕРЦ
        13/09/2012 madiyar - парсинг XML, перекодировка строк UTF-8 -> KZ-1048
        03.10.2012 damir - изменения по провайдеру ICON (поставил комплексную онлайн проверку). На основании С.З. от 03.10.2012.
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.
        14.11.2012 damir - Добавление к изменению 07.11.2012. Variable - v-Suppcom,v-acc,v-accrec.
        10.12.2012 damir - Добавление к изменению 07.11.2012. По провайдеру Костанайский Энергоцентр заменил код 532 на 608. Единственный провайдер код
                           которого на тестовом и боевом сервере АвангардПлат отличается.
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
        10.04.2013 damir - Внедрено Т.З. № 1577,1571.
        31.07.2013 damir - Внедрено Т.З. № 1989. Изменение кодов с 185,186 на 503,504. Activ,KCell.
*/
{classes.i}

def input parameter Usr as class ACCOUNTClass.    /* Класс данных плательщиков */
def output parameter p-errcode as integer no-undo init 0.
def output parameter p-errdes as char no-undo init ''.

{apterm.i}
{xmlParser.i}

def buffer bt-node for t-node.
def buffer bt1-node for t-node.
def buffer bt2-node for t-node.
def buffer bt3-node for t-node.

{compayshared.i}

def var supp_ap_id as integer no-undo.
def var v-invoiceId as char no-undo.
def var supp_sum as deci no-undo.
def var v-txt as char no-undo.

def var v-termId as integer no-undo.
def var v-userId as integer no-undo.
def var v-pass as char no-undo.
def var v-request as char no-undo.
def var v-reply as char no-undo.
def var v-parseErr as char no-undo.
def var v-str as char no-undo.
def var v-code as char no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var k as integer no-undo.
def var v-Suppcom as char init '' no-undo.
def var v-acc as char init '' no-undo.
def var v-accrec as char no-undo.
def var v-Type_1 as char.
def var v-Type_2 as char.
def var v-Type_3 as char.
def var v-Type_4 as char.
def var v-Type_5 as char.
def var v-Type_6 as char.
def var v-parValue as inte.
def var v-prevCountDate as char.
def var v-lastCountDate as char.

v-termId = getTermId("aphttp").
v-userId = getUserId("aphttp").
v-pass = getPass("aphttp").

function getErrorDes returns char (input err_code as integer).
    def var res as char no-undo.
    find first aperrlist where aperrlist.errcode = err_code no-lock no-error.
    if avail aperrlist then res = aperrlist.errdes. else res = string(err_code) + ": неизвестная ошибка".
    return res.
end function.

function NormalName returns char (input c-name as char, input id as int).
    def var rez as char.
    case id:
        when 8 or when 137 then do:
            if index(c-name,"|") gt 0 then rez = substr(c-name,index(c-name,"|") + 1,length(c-name)).
            else if index(c-name,"/") gt 0 then rez = substr(c-name,index(c-name,"/") + 1,length(c-name)).
        end.
        otherwise rez = c-name.
    end case.
    return rez.
end function.

function getSortOrder returns integer (input subId as integer).
    /*13 - Электроэнергия,8 - Отопление,14 - Гор.вода СЧЕТЧИК,12 - Хол.вода СЧЕТЧИК,25 - Канализация хол. воды Счетчик,6 - Канализация гор. воды СЧЕТЧИК,
    114 - Канализация,5 - Холодная вода,1 - Расходы на содержание жилища,22 - ВДГО,36 - Газ,4 - Радио,11 - Вывоз ТБО,128 - Домофон,102 - Служба спасения,
    144 - Телевидение АЛМА-ТВ*/
    def var res as integer no-undo.
    def var pos as integer no-undo.
    def var ids as char no-undo init "13,8,14,12,25,6,114,5,1,22,36,4,11,128,102,144".
    pos = lookup(trim(string(subId)),ids).
    if pos > 0 then res = pos.
    else res = 999999.
    return res.
end function.

find first suppcom where suppcom.supp_id = Usr:supp_id no-lock no-error.
if avail suppcom then do:
    if suppcom.ap_code <= 0 then do:
        p-errcode = 9000. /* Отправка в Авангард-Плат запроса по провайдеру, не обслуживаемому Авангард-Плат */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    else supp_ap_id = suppcom.ap_code.
    if suppcom.type <= 0 then do:
        p-errcode = 9001. /* Провайдер отмечен в iXora как неактивный */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    if length(Usr:acc) < suppcom.minlen or length(Usr:acc) > suppcom.maxlen then do:
        p-errcode = 9002. /* Некорректная длина номера счета/телефона */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
    supp_sum = suppcom.minsum + 100.
    if suppcom.ap_check <= 0 then do:
        p-errcode = 9004. /* У данного провайдера отсутствует онлайн-проверка */
        p-errdes = getErrorDes(p-errcode).
        return.
    end.
end.

v-acc = Usr:acc.

case supp_ap_id:
    when 530 then v-accrec = trim(Usr:type_pay) + ";" + trim(Usr:code_reg). /*Шыгысэнерготрейд*/
    when 536 then v-accrec = trim(Usr:type_pay). /*Нурсат*/
end case.

/*В теге <acc></acc> передаются кроме лицевого счета и другие параметры*/
v-Suppcom = '530,536'.
if lookup(trim(string(supp_ap_id)),v-Suppcom) > 0 then if not Usr:AddStr(v-accrec) then message "Doc:AddStr method failed!" view-as alert-box.

/* build request string */
v-request = '<?xml version="1.0" encoding="utf-8"?><rq v="2"><rt>3</rt><id su="' + string(v-userId) + '" p="' + v-pass + '">' + string(v-termId) + '</id>'.
v-request = v-request + '<acc prv="' + string(supp_ap_id) + '" sum="' + trim(string(supp_sum,">>>>>>>>9.99")) + '">' + Usr:acc + '</acc>'.
v-request = v-request + '</rq>'.

Usr:acc = v-acc.

run savelog('ap','ap_check->' + v-request).
run ap_send("http",no,v-request,output v-reply).
run savelog('ap','ap_check<-' + v-reply).

/*{Testing.i}*/

hide frame f1.

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
if v-reply = '?' then do:
    p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    p-errdes = '(?) ' + getErrorDes(p-errcode).
    return.
end.
if trim(v-reply) = '' then do:
    p-errcode = 9005. /* Сервис вернул пустую строку */
    p-errdes = getErrorDes(p-errcode).
    return.
end.
if v-reply matches "*<err>*" then do:
    run parseCharXML(v-reply,output v-parseErr).
    if v-parseErr <> '' then run savelog('ap','ap_check 1 parseXML: ' + v-parseErr).
    find first t-node where t-node.nodeName = 'err' no-lock no-error.
    if avail t-node then do:
        p-errcode = integer(t-node.nodeValue). /* код ошибки возвращается сервисом Авангард-Плат */
        p-errdes = getErrorDes(p-errcode).
    end.
    else do:
        p-errcode = 9011. /* Ошибка обработки ответа на запрос */
        p-errdes = getErrorDes(p-errcode).
    end.
end.
else if v-reply matches "*<er>*" then do:
    run parseCharXML(v-reply,output v-parseErr).
    if v-parseErr <> '' then run savelog('ap','ap_check 1 parseXML: ' + v-parseErr).
    find first t-node where t-node.nodeName = 'er' no-lock no-error.
    if avail t-node then do:
        p-errcode = integer(t-node.nodeValue). /* код ошибки возвращается сервисом Авангард-Плат */
        p-errdes = getErrorDes(p-errcode).
    end.
    else do:
        p-errcode = 9011. /* Ошибка обработки ответа на запрос */
        p-errdes = getErrorDes(p-errcode).
    end.
end.
else do:
    p-errcode = 0.
    run parseCharXML(v-reply,output v-parseErr).
    if v-parseErr <> '' then run savelog('ap','ap_check 2 parseXML: ' + v-parseErr).

    /*Общая (простая) структура ответа*/
    v-Type_1 = "503,504,5,526,545,546,547,548,549,530,608,536,538,550,539,551,552,537,541,531,540,534,543,523,506,533,535,588,604,618,553,554,555,556,557,558,559,560,561,562,563,564,565," +
    "566,567,568,569,585,591,592,593,598,607,609,610,611,612,613,614,615,617,620,570,572,573,542,622,623,624,625,626,627,628,629,635,636,637,638,639,640,641,642,643,644,645,646,647," +
    "648,649,650,654,655,656,657,525,529,589,590,594,595,597,600,603,605,606,651,652,653".
    if lookup(string(supp_ap_id),v-Type_1) gt 0 then do:
        find first bt-node where bt-node.nodeName = 'account' no-lock no-error.
        if avail bt-node then do:
            find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "st" no-lock no-error.
            if avail t-nodeAttr then p-errcode = inte(t-nodeAttr.nodeAttrValue).
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.

    /*Структура ответа для комплексной схемы*/
    v-Type_2 = "8,113,229,232,137,4,465,619".
    if lookup(string(supp_ap_id),v-Type_2) gt 0 then do:
        find first t-node where t-node.nodeName = 'account' no-lock no-error.
        if avail t-node then do:
            if t-node.NumChildren > 0 then do:
                find first t-node where t-node.nodeName = "param" no-lock no-error.
                if avail t-node then do:
                    find first bt-node where bt-node.nodeParentId = t-node.nodeId and bt-node.nodeName = "parValue" no-lock no-error.
                    if avail bt-node then v-parValue = inte(bt-node.nodeValue) no-error.
                end.
                find first t-node where t-node.nodeName = 'invoice' no-lock no-error.
                if avail t-node then do:
                    for each t-node where t-node.nodeName = 'invoice' no-lock:
                        for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
                            if bt-node.nodeName = "invoiceId" then v-invoiceId = cp-convert(bt-node.nodeValue).
                            if bt-node.nodeName = "services" then do:
                                for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                                    if bt1-node.nodeName = "service" then do:
                                        create wrk.
                                        wrk.Invoice = v-invoiceId.
                                        wrk.parValue = v-parValue.
                                        for each bt2-node where bt2-node.nodeParentId = bt1-node.nodeId no-lock:
                                            case bt2-node.nodeName:
                                                when "serviceId" then do:
                                                    wrk.IdSub = inte(bt2-node.nodeValue) no-error.
                                                    wrk.sortOrder = getSortOrder(wrk.IdSub).
                                                end.
                                                when "serviceName" then wrk.NamSub = NormalName(cp-convert(bt2-node.nodeValue), supp_ap_id).
                                                when "IsCounterService" then wrk.Counter = inte(bt2-node.nodeValue) no-error.
                                                when "measure" then wrk.Unit = cp-convert(bt2-node.nodeValue).
                                                when "tariff" then wrk.Price = deci(bt2-node.nodeValue) no-error.
                                                when "debtInfo" then wrk.Duty = cp-convert(bt2-node.nodeValue).
                                                when "fixSum" then do:
                                                    wrk.Pay = deci(bt2-node.nodeValue) no-error.
                                                    wrk.ForPay = deci(bt2-node.nodeValue) no-error.
                                                end.
                                                when "fixCount" then wrk.Amount = deci(bt2-node.nodeValue) no-error.
                                                when "prevCount" then wrk.Prev = deci(bt2-node.nodeValue) no-error.
                                                when "lastCount" then wrk.Curr = deci(bt2-node.nodeValue) no-error.
                                                when "tKoef" then wrk.tKoef = deci(bt2-node.nodeValue) no-error.
                                                when "lossesCount" then wrk.lossesCount = deci(bt2-node.nodeValue) no-error.
                                                when "prevCountDate" then do:
                                                    v-prevCountDate = cp-convert(bt2-node.nodeValue).
                                                    if v-prevCountDate <> "" then wrk.prevCountDate = date(inte(substr(trim(v-prevCountDate),5,2)),
                                                    inte(substr(trim(v-prevCountDate),7,2)),inte(substr(trim(v-prevCountDate),1,4))).
                                                    else wrk.prevCountDate = ?.
                                                end.
                                                when "lastCountDate" then do:
                                                    v-lastCountDate = cp-convert(bt2-node.nodeValue).
                                                    if v-lastCountDate <> "" then wrk.lastCountDate = date(inte(substr(trim(v-lastCountDate),5,2)),
                                                    inte(substr(trim(v-lastCountDate),7,2)),inte(substr(trim(v-lastCountDate),1,4))).
                                                    else wrk.prevCountDate = ?.
                                                end.
                                            end case.
                                            if bt2-node.nodeName = "tariff" then do:
                                                for each bt3-node where bt3-node.nodeParentId = bt2-node.nodeId no-lock:
                                                    case bt3-node.nodeName:
                                                        when "minTariffValue" then wrk.minTariffValue = deci(bt3-node.nodeValue) no-error.
                                                        when "minTariffThreshold" then wrk.minTariffThreshold = deci(bt3-node.nodeValue) no-error.
                                                        when "maxTariffValue" then wrk.maxTariffValue = deci(bt3-node.nodeValue) no-error.
                                                        when "middleTariffValue" then wrk.middleTariffValue = deci(bt3-node.nodeValue) no-error.
                                                        when "middleTariffThreshold" then wrk.middleTariffThreshold = deci(bt3-node.nodeValue) no-error.
                                                    end case.
                                                end.
                                            end.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                    find first t-node where t-node.nodeName = 'address' no-lock no-error.
                    if avail t-node then do:
                        v-txt = cp-convert(t-node.nodeValue).
                        if supp_ap_id = 137 then do: /*Астана ЕРЦ  бывает много пробелов  0726311  */
                            def var i-pos as inte.
                            def var c-tmp as char.
                            do i-pos = 1 to length(v-txt):
                                if not (substr(v-txt, i-pos, 1) = " " and substr(v-txt, i-pos + 1, 1) = "") then c-tmp = c-tmp + substr(v-txt, i-pos, 1).
                            end.
                            Usr:name = "".
                            Usr:addr = c-tmp.
                        end.
                        else do:
                            Usr:name = substring(v-txt,1,index(v-txt,' г.') - 1).
                            Usr:addr = substring(v-txt,index(v-txt,' г.') + 1).
                        end.
                    end.
                end.
                else p-errcode = 9030. /* Нет выставленных к оплате инвойсов */
            end.
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.
    /*Структура ответа для схемы с выбором контракта*/
    v-Type_3 = "58".
    if lookup(string(supp_ap_id),v-Type_3) gt 0 then do:
        find first t-node where t-node.nodeName = 'account' no-lock no-error.
        if avail t-node then do:
            find first t-nodeAttr where t-nodeAttr.nodeId = t-node.nodeId and t-nodeAttr.nodeAttrName = "name" no-lock no-error.
            if avail t-nodeAttr then Usr:name = cp-convert(t-nodeAttr.nodeAttrValue).
            if t-node.NumChildren > 0 then do:
                find first bt-node where bt-node.nodeName = 'invoice' and bt-node.nodeParentId = t-node.nodeId no-lock no-error.
                if avail bt-node then do:
                    for each bt-node where bt-node.nodeName = 'invoice' and bt-node.nodeParentId = t-node.nodeId no-lock:
                        create wrk.
                        wrk.Counter = 0.
                        for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                            case bt1-node.nodeName:
                                when "ID" then wrk.Invoice = cp-convert(bt1-node.nodeValue).
                                when "num" then wrk.NamSub = cp-convert(bt1-node.nodeValue).
                                when "sum" then assign wrk.Pay = deci(bt1-node.nodeValue) wrk.ForPay = deci(bt1-node.nodeValue).
                                when "date" then wrk.Unit = cp-convert(bt1-node.nodeValue).
                            end case.
                        end.
                    end.
                end.
                else p-errcode = 9030. /* Нет выставленных к оплате инвойсов */
            end.
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.
    /*Структура ответа для уточняющей схемы*/
    v-Type_4 = "57".
    if lookup(string(supp_ap_id),v-Type_4) gt 0 then do:
        find first t-node where t-node.nodeName = 'accounts' no-lock no-error.
        if avail t-node then do:
            if t-node.NumChildren > 0 then do:
                find first bt-node where bt-node.nodeName = 'account' and bt-node.nodeParentId = t-node.nodeId no-lock no-error.
                if avail bt-node then do:
                    /*find first t-nodeAttr where t-nodeAttr.nodeId = t-node.nodeId and t-nodeAttr.nodeAttrName = "name" no-lock no-error.
                    if avail t-nodeAttr then Usr:name = t-nodeAttr.nodeAttrValue.*/
                    for each bt-node where bt-node.nodeName = 'account' and bt-node.nodeParentId = t-node.nodeId no-lock:
                        create wrk.
                        find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "id" no-lock no-error.
                        if avail t-nodeAttr then wrk.Invoice = cp-convert(t-nodeAttr.nodeAttrValue).
                        for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                            case bt1-node.nodeName:
                                when "name" then wrk.NamSub = cp-convert(bt1-node.nodeValue).
                                when "address" then wrk.Unit = cp-convert(bt1-node.nodeValue).
                            end case.
                        end.
                    end.
                end.
                else p-errcode = 9006. /* Номер/лицевой счет не найден */
            end.
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.
    /*when 270 or when 271 or when 272 or when 273 then do:  ШыгысЭнергоТрейд
        find first t-node where t-node.nodeName = 'account' no-lock no-error.
        if avail t-node then do:
            if t-node.NumChildren > 0 then do:
                create wrk.
                for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
                    case bt-node.nodeName:
                        when "name" then wrk.NamSub = cp-convert(bt-node.nodeValue).
                        when "address" then wrk.Unit = cp-convert(bt-node.nodeValue).
                    end case.
                end.
            end.
            else p-errcode = 9006.  Номер/лицевой счет не найден
        end.
        else p-errcode = 9011.  Ошибка обработки ответа на запрос
    end.*/
    /*Структура ответа для схемы «Kaztelecom»*/
    v-Type_5 = "298".
    if lookup(string(supp_ap_id),v-Type_5) gt 0 then do:
        find first bt-node where bt-node.nodeName = 'account' no-lock no-error.
        if avail bt-node then do:
            if bt-node.NumChildren > 0 then do:
                create wrk.
                find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "id2" no-lock no-error.
                if avail t-nodeAttr then wrk.NamSub = cp-convert(t-nodeAttr.nodeAttrValue).

                find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "id" no-lock no-error.
                if avail t-nodeAttr then wrk.Invoice = cp-convert(t-nodeAttr.nodeAttrValue).

                find first bt1-node where bt1-node.nodeName = 'name' and bt1-node.nodeParentId = bt-node.nodeId no-lock no-error.
                if avail bt1-node then do:
                    v-txt = cp-convert(bt1-node.nodeValue).
                    wrk.Unit = substring(v-txt,1,index(v-txt,', ') - 1).
                    wrk.ForPay = deci(substring(v-txt,index(v-txt,'Сумма задолженности: ') + 21)).
                end.
            end.
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.
    /*Структура ответа для схемы "С подтверждением и клавиатурой" «Параграф-WWW»*/
    v-Type_6 = "544".
    if lookup(string(supp_ap_id),v-Type_6) gt 0 then do:
        find first t-node where t-node.nodeName = 'accounts' no-lock no-error.
        if avail t-node then do:
            if t-node.NumChildren > 0 then do:
                find first bt-node where bt-node.nodeName = 'account' and bt-node.nodeParentId = t-node.nodeId no-lock no-error.
                if avail bt-node then do:
                    for each bt-node where bt-node.nodeName = 'account' and bt-node.nodeParentId = t-node.nodeId no-lock:
                        create wrk.
                        find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "st" no-lock no-error.
                        if avail t-nodeAttr then p-errcode = inte(cp-convert(t-nodeAttr.nodeAttrValue)).
                        find first t-nodeAttr where t-nodeAttr.nodeId = bt-node.nodeId and t-nodeAttr.nodeAttrName = "id" no-lock no-error.
                        if avail t-nodeAttr then wrk.Invoice = cp-convert(t-nodeAttr.nodeAttrValue).
                        for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                            case bt1-node.nodeName:
                                when "name" then wrk.NamSub = cp-convert(bt1-node.nodeValue).
                            end case.
                        end.
                    end.
                end.
                else p-errcode = 9006. /* Номер/лицевой счет не найден */
            end.
            else p-errcode = 9006. /* Номер/лицевой счет не найден */
        end.
        else p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    end.

    if p-errcode > 0 then p-errdes = getErrorDes(p-errcode).
end.

