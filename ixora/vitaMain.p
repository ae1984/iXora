/* vitaGet.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Витамин->Иксора
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
        02/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        28/09/2011 madiyar - не выгружаем проводки со счетами ГК 111111
        29/08/2012 madiyar - при большом количестве операций не хватало емкости типа char, отправляем в несколько порций по 100 операций
        04/09/2013 galina - ТЗ1885 добавила обработку для платежей по погашению кредита "Астана бонус"
*/

/*
compile vitaGet.p save.
compile vitaMain.p save.
run vitaMain.
*/

{mainhead.i}
{xmlParser.i}

def buffer bt-node for t-node.

def var v-sel as integer no-undo.
def var v-year as integer no-undo.
def var v-month as integer no-undo.
def var v-type as integer no-undo. /* вид запроса: 1 - МЖР, 2 - ОКН */
def var v-bank as char no-undo.
def var v-msg as char no-undo.
def var v-batchid as integer no-undo.
def var v-opid as char no-undo.

def var v-errorDes as char no-undo. /* описание ошибки, если пусто - ошибок нет */
def var v-xml as char no-undo.
def var i as integer no-undo.

def var v-wt as char no-undo.

def temp-table wrk like vita.

def new shared temp-table t-xml no-undo
  field num as integer
  field xml as char
  index idx is primary num.

define query qt for wrk.

define browse bt query qt
       displ wrk.id label "nn" format ">>9"
             wrk.period label "Период" format "x(10)"
             wrk.jdt label "ДатаЗапр" format "99/99/9999"
             wrk.dtAcc label "СчетДт" format "x(20)"
             wrk.ctAcc label "СчетКт" format "x(20)"
             wrk.amt label "Сумма" format ">,>>>,>>>,>>9.99"
             wrk.bank1 label "Фил1" format "x(5)"
             wrk.bank2 label "Фил2" format "x(5)"
             wrk.trxtype label "trx" format "x(3)"
             /* wrk.qc label "qc" format "x(5)" */
             with 29 down overlay no-label title " Проводки ".

def button btn-rep label "Отчет".
def button btn-f1 label "Провести транзакции".
def button btn-f4 label "Отмена".

define frame ft bt skip btn-rep btn-f1 btn-f4 with width 110 row 3 overlay no-label no-box.

def stream rep.

procedure exp2deci.
    def input parameter parm1 as char no-undo.
    def input parameter parm2 as integer no-undo.
    def output parameter res as deci no-undo.
    def output parameter errmsg as char no-undo.
    res = 0.
    errmsg = ''.
    def var str1 as char no-undo.
    def var str2 as char no-undo.
    str1 = entry(1,parm1,'E').
    str2 = entry(2,parm1,'E').
    res = deci(str1) * exp(10,integer(str2)) no-error.
    if error-status:error then do:
        res = 0.
        errmsg = "Строка " + string(parm2) + " - Ошибка конвертации суммы (E), значение=" + parm1.
    end.
end procedure.

function getMonthName returns char (input p-month as integer).
    def var v-res as char no-undo.
    v-res = ''.
    def var v-monthList as char no-undo.
    v-monthList = "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
    if p-month >= 1 and p-month <= 12 then v-res = entry(p-month,v-monthList).
    return v-res.
end function.

function str2date returns date (input p-str as char).
    def var v-res as date no-undo.
    v-res = ?.
    if length(p-str) > 10 then p-str = substring(p-str,1,10).
    if num-entries(p-str,'-') > 2 then do:
        v-res = date(integer(entry(2,p-str,'-')),integer(entry(3,p-str,'-')),integer(entry(1,p-str,'-'))) no-error.
    end.
    return v-res.
end function.

function getRem returns char (input p-period as char, input p-dt as char, input p-ct as char).
    def var v-res as char no-undo.
    def var v-monthi as integer no-undo.
    def var v-monthc as char no-undo.
    def var v-sname as char no-undo.

    def var arps_promvyp as char no-undo.
    arps_promvyp = "KZ55470191854A021100,KZ89470191854A022816,KZ40470191854A013901,KZ29470191854A013808,KZ95470191854A013105,KZ42470191854A012507," +
                   "KZ95470191854A013202,KZ27470191854A011904,KZ37470191854A012403,KZ20470191854A012806,KZ36470191854A012809,KZ74470191854A012610," +
                   "KZ47470191854A012611,KZ36470191854A012712,KZ90470191854A012613,KZ30470191854A013014,KZ36470191854A012615".
    def var arps_nach_uder as char no-undo.
    arps_nach_uder = "KZ33470192854A021200,KZ67470192854A022916,KZ18470192854A014001,KZ07470192854A013908,KZ73470192854A013205,KZ20470192854A012607," +
                     "KZ73470192854A013302,KZ05470192854A012004,KZ15470192854A012503,KZ95470192854A012906,KZ14470192854A012909,KZ52470192854A012710," +
                     "KZ25470192854A012711,KZ14470192854A012812,KZ68470192854A012713,KZ08470192854A013114,KZ14470192854A012715".

    def var arps_ipn as char no-undo.
    arps_ipn = "KZ37470112851A007900,KZ02470112851A002516,KZ05470112851A001201,KZ42470112851A001408,KZ56470112851A002805,KZ51470112851A002507," +
               "KZ24470112851A002702,KZ84470112851A002204,KZ46470112851A002403,KZ45470112851A002906,KZ45470112851A002809,KZ83470112851A002610," +
               "KZ72470112851A002711,KZ13470112851A002512,KZ67470112851A002413,KZ39470112851A003014,KZ12470112851A003015".
    def var arps_pens as char no-undo.
    arps_pens = "KZ61470122851A008000,KZ18470112851A002616,KZ77470122851A001601,KZ17470122851A001808,KZ57470112851A002205,KZ83470112851A002707," +
                "KZ72470112851A003002,KZ51470112851A002604,KZ30470112851A002303,KZ30470112851A002206,KZ62470112851A002309,KZ35470112851A002310," +
                "KZ07470112851A002911,KZ78470112851A002312,KZ18470112851A002713,KZ40470112851A002414,KZ28470112851A003115".
    def var arps_alim as char no-undo.
    arps_alim = "KZ42470192854A006100,KZ83470192854A023016,KZ34470192854A014101,KZ23470192854A014008,KZ76470192854A001705,KZ36470192854A012707," +
                "KZ76470192854A001802,KZ21470192854A012104,KZ31470192854A012603,KZ14470192854A013006,KZ30470192854A013009,KZ68470192854A012810," +
                "KZ11470192854A001711,KZ30470192854A012912,KZ84470192854A012813,KZ24470192854A013214,KZ16470192854A001815".
    def var arps_misc as char no-undo.
    arps_misc = "KZ56470191854A020500,KZ78470191854A019716,KZ24470191854A013801,KZ13470191854A013708,KZ63470191854A012905,KZ26470191854A012407," +
                "KZ79470191854A013102,KZ11470191854A011804,KZ21470191854A012303,KZ04470191854A012706,KZ20470191854A012709,KZ58470191854A012510," +
                "KZ31470191854A012511,KZ20470191854A012612,KZ74470191854A012513,KZ14470191854A012914,KZ20470191854A012515".
    def var arps_prom as char no-undo.
    arps_prom = "KZ55470191854A021100,KZ89470191854A022816,KZ40470191854A013901,KZ29470191854A013808,KZ95470191854A013105,KZ42470191854A012507," +
                "KZ95470191854A013202,KZ27470191854A011904,KZ37470191854A012403,KZ20470191854A012806,KZ36470191854A012809,KZ74470191854A012610," +
                "KZ47470191854A012611,KZ36470191854A012712,KZ90470191854A012613,KZ30470191854A013014,KZ36470191854A012615".
    def var arps_vypl as char no-undo.
    arps_vypl = "KZ02470192854A020400,KZ08470192854A009816," +
                "KZ08470192854A009816," +
                "KZ72470192854A010701," +
                "KZ12470192854A010908," +
                "KZ46470192854A010005," +
                "KZ57470192854A009807," +
                "KZ46470192854A010102," +
                "KZ10470192854A009004," +
                "KZ86470192854A008703," +
                "KZ53470192854A009006," +
                "KZ03470192854A009809," +
                "KZ57470192854A009710," +
                "KZ30470192854A009711," +
                "KZ03470192854A009712," +
                "KZ73470192854A009713," +
                "KZ13470192854A010114," +
                "KZ35470192854A009815".

    def var arps_socnal as char no-undo.
    arps_socnal = "KZ69470112851A008100,KZ34470112851A002716,KZ85470112851A001701,KZ41470112851A002008,KZ89470112851A002405,KZ84470112851A002107," +
                  "KZ56470112851A002902,KZ83470112851A002804,KZ78470112851A002603,KZ46470112851A002306,KZ78470112851A002409,KZ67470112851A002510," +
                  "KZ89470112851A002211,KZ29470112851A002612,KZ83470112851A002513,KZ88470112851A002714,KZ77470112851A002815".
    def var arps_socotch as char no-undo.
    arps_socotch = "KZ93470122851A008200,KZ50470112851A002816,KZ61470122851A001501,KZ34470122851A001308,KZ73470112851A002305,KZ35470112851A002407," +
                   "KZ73470112851A002402,KZ68470112851A002104,KZ14470112851A002203,KZ94470112851A002606,KZ29470112851A002709,KZ19470112851A002210," +
                   "KZ56470112851A002611,KZ61470112851A002812,KZ35470112851A002213,KZ23470112851A002914,KZ93470112851A002915".

    v-monthi = 0.
    if num-entries(p-period,'-') > 1 then v-monthi = integer(entry(2,p-period,'-')) no-error.
    if (v-monthi <> 0) and (v-monthi <> ?) then v-monthc = getMonthName(v-monthi).
    else v-monthc = getMonthName(month(g-today)).
    if lookup(p-dt,arps_promvyp) > 0 then v-res = "Выплата заработной платы за " + v-monthc.
    else
    if lookup(p-ct,arps_nach_uder) > 0 then do:
        case p-dt:
            when "572151" then v-res = "Заработная плата за " + v-monthc.
            when "572910" then v-res = "Премия".
            when "572930" then v-res = "Материальная помощь".
            when "572940" then v-res = "Больничные листы".
            when "572153" then v-res = "Компенсация".
        end.
    end.
    else
    if lookup(p-dt,arps_nach_uder) > 0 then do:
        if lookup(p-ct,arps_ipn) > 0 then v-res = "ИПН с зарплаты за " + v-monthc.
        else
        if lookup(p-ct,arps_pens) > 0 then v-res = "Пенсионные отчисления с зарплаты за " + v-monthc.
        else
        if lookup(p-ct,arps_alim) > 0 then v-res = "Алименты с зарплаты за " + v-monthc.
        else
        if lookup(p-ct,arps_misc) > 0 then v-res = "Прочие удержания с зарплаты за " + v-monthc.
        else
        if lookup(p-ct,arps_prom) > 0 then v-res = "Промежуточные выплаты по заработной плате за " + v-monthc.
        else
        if lookup(p-ct,arps_vypl) > 0 then v-res = "Выплата заработной платы за " + v-monthc.
    end.
    else
    if p-dt = "576300" and lookup(p-ct,arps_socnal) > 0 then v-res = "Социальный налог за " + v-monthc.
    else
    if p-dt = "572210" and lookup(p-ct,arps_socotch) > 0 then v-res = "Социальные отчисления за " + v-monthc.

    if lookup(p-dt,'KZ33470192854A021200,KZ07470192854A013908') > 0 and substr(p-ct,10,4) = '2205' then do:
        find first txb where txb.bank =  'TXB' + substr(p-ct,19,2) no-lock no-error.
        if avail txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            run getcifsname(p-ct, output v-sname).
            if connected ("txb") then disconnect "txb".
        end.
        v-res = "3%+сумма ОД+сумма субсидированного вознаграждения  согл Пр№1 от 29.06.12 из зарплаты за " + v-monthc  + ' ' + entry(1,p-period,'-')+ 'г - ' + v-sname.
    end.

    if v-res = '' then v-res = "ПО Витамин->iXora, за " + v-monthc.
    return v-res.
end function.

procedure printRep:
    def input parameter p-batchid as integer no-undo.
    def input parameter p-real as logi no-undo.

    if p-real then do:
        find first vita where vita.batchid = p-batchid no-lock no-error.
        if not avail vita then do:
            message "Нет операций с указанным номером пакета!" view-as alert-box error.
            return.
        end.
    end.

    output stream rep to rep.htm.
    put stream rep unformatted
        "<html><head>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
        "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
        "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
        "</head><body>" skip.
    if p-batchid > 0 then put stream rep unformatted "<b>Номер пакета: " p-batchid "</b><BR><BR>" skip.
    put stream rep unformatted
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td>Период</td>" skip
        "<td>Дата</td>" skip
        "<td>Счет-Дт</td>" skip
        "<td>Счет-Кт</td>" skip
        "<td>Сумма</td>" skip
        "<td>Филиал-Отпр</td>" skip
        "<td>Филиал-Получ</td>" skip
        "<td>Тип операции</td>" skip
        "<td>Примечание</td>" skip
        "<td>Ошибки</td>" skip.
    if p-real then do:
        put stream rep unformatted
            "<td>Статус</td>" skip
            "<td>JH/RMZ</td>" skip.
    end.
        put stream rep unformatted "</tr>" skip.

    if p-real then do:
        for each vita where vita.batchid = p-batchid no-lock:
            v-opid = ''.
            if vita.trxtype = "jou" then do:
                if vita.jh > 0 then v-opid = string(vita.jh).
            end.
            else v-opid = vita.remtrz.

            put stream rep unformatted
                "<tr>" skip
                "<td>" vita.period "</td>" skip
                "<td>" vita.jdt "</td>" skip
                "<td>" vita.dtAcc "</td>" skip
                "<td>" vita.ctAcc "</td>" skip
                "<td>" replace(trim(string(vita.amt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                "<td>" vita.bank1 "</td>" skip
                "<td>" vita.bank2 "</td>" skip
                "<td>" vita.trxtype "</td>" skip
                "<td>" vita.rem "</td>" skip
                "<td>" vita.err2 "</td>" skip
                "<td>" vita.sts "</td>" skip
                "<td>" v-opid "</td>" skip
                "</tr>" skip.
        end.
    end.
    else do:
        for each wrk no-lock:
            put stream rep unformatted
                "<tr>" skip
                "<td>" wrk.period "</td>" skip
                "<td>" wrk.jdt "</td>" skip
                "<td>" wrk.dtAcc "</td>" skip
                "<td>" wrk.ctAcc "</td>" skip
                "<td>" replace(trim(string(wrk.amt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                "<td>" wrk.bank1 "</td>" skip
                "<td>" wrk.bank2 "</td>" skip
                "<td>" wrk.trxtype "</td>" skip
                "<td>" wrk.rem "</td>" skip
                "<td>" wrk.err "</td>" skip
                "</tr>" skip.
        end.
    end.
    put stream rep unformatted "</table></body></html>" skip.
    output stream rep close.
    unix silent cptwin rep.htm excel.
end procedure.



/* отчет */
on choose of btn-rep in frame ft do:
    run printRep(0, no).
    return.
end.

/* на проводки */
on choose of btn-f1 in frame ft do:

    run vitaGet("CLEAR",output v-errorDes).
    if v-errorDes <> '' then do:
        message v-errorDes view-as alert-box error.
        return.
    end.

    message "Завершено!" view-as alert-box.

    find last vita use-index batch no-lock no-error.
    if avail vita then i = vita.batchid + 1.
    else i = 1.
    for each wrk where wrk.dtAcc <> "111111" and wrk.ctAcc <> "111111" no-lock:
        do transaction:
            create vita.
            buffer-copy wrk except wrk.batchid wrk.sts to vita.
            vita.batchid = i.
            vita.sts = "new".
            vita.who = g-ofc.
            vita.rdt = today.
            vita.rtim = time.
        end.
    end.
    run printRep(i, no).
    message "Выгрузка прошла успешно!" view-as alert-box warning.
    return.
end.

/* отмена */
on choose of btn-f4 in frame ft do:
   /* message "Для повторной выгрузки данных за указанный период снимите с проводок в ПО 'Витамин' отметки о выгрузке!" view-as alert-box warning.*/
    return.
end.

on END-ERROR of frame ft do:
   /* message "Для повторной выгрузки данных за указанный период снимите с проводок в ПО 'Витамин' отметки о выгрузке!" view-as alert-box warning.*/
    return.
end.

run sel2 (" ВЫБЕРИТЕ: ", " 1. Отчет по пакету | 2. Выгрузка операций | 3. Выход ", output v-sel).

if v-sel = 1 then do:
    v-batchid = 0.
    update v-batchid label "Укажите номер пакета" format ">>>>>9" with centered side-labels row 13 frame frb.
    run printRep(v-batchid, yes).
end. /* if v-sel = 1 */
else
if v-sel = 2 then do:
    v-year = year(date(month(g-today),1,year(g-today)) - 1).
    v-month = month(date(month(g-today),1,year(g-today)) - 1).
    v-type = 1.

    empty temp-table t-xml.
    run vitaGet("READ",output v-errorDes).
    if v-errorDes <> '' then do:
        message v-errorDes view-as alert-box error.
        return.
    end.

    find first t-xml no-lock no-error.
    if not avail t-xml then do:
        message "Процедура vitaGet не вернула записей xml" view-as alert-box error.
        return.
    end.

    empty temp-table wrk.

    i = 0.
    for each t-xml no-lock:
        v-xml = t-xml.xml.
        run parseCharXML(v-xml,output v-errorDes).
        if v-errorDes <> '' then do:
            message v-errorDes + "~nОшибка xml-парсинга порции " + string(t-xml.num) view-as alert-box error.
            next.
        end.

        find first t-node where t-node.nodeName = 'item' no-lock no-error.
        if not avail t-node then do:
            message "Запрос не вернул данных, или ошибка парсинга!" view-as alert-box error.
            return.
        end.

        for each t-node where t-node.nodeName = 'item' /*no-lock*/:
            create wrk.
            i = i + 1.
            wrk.id = i.

            for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
                if bt-node.nodeName = "period" then wrk.period = trim(bt-node.nodeValue).
                if bt-node.nodeName = "jdt" then wrk.jdt = str2date(trim(bt-node.nodeValue)).
                if bt-node.nodeName = "dt" then do:
                    /*
                    if i = 18 then bt-node.nodeValue = '23452345'.
                    if i = 23 then bt-node.nodeValue = '12345678901234567890'.
                    */
                    wrk.dtAcc = trim(bt-node.nodeValue).
                    if (length(wrk.dtAcc) <> 6) and (length(wrk.dtAcc) <> 20) then do:
                        if wrk.err <> '' then wrk.err = wrk.err + '; '.
                        wrk.err = wrk.err + "Строка " + string(i) + " - Некорректный номер счета, значение=" + wrk.dtAcc.
                    end.
                end.
                if bt-node.nodeName = "ct" then do:
                    /*
                    if i = 18 then bt-node.nodeValue = '23452345acscawe'.
                    */
                    wrk.ctAcc = trim(bt-node.nodeValue).
                    if (length(wrk.ctAcc) <> 6) and (length(wrk.ctAcc) <> 20) then do:
                        if wrk.err <> '' then wrk.err = wrk.err + '; '.
                        wrk.err = wrk.err + "Строка " + string(i) + " - Некорректный номер счета, значение=" + wrk.ctAcc.
                    end.
                end.
                if bt-node.nodeName = "amt" then do:
                    /*
                    if i = 15 then bt-node.nodeValue = '1.43EA5'.
                    if i = 23 then bt-node.nodeValue = '1.567b5'.
                    */
                    if index(trim(bt-node.nodeValue),'E') = 0 then do:
                        wrk.amt = deci(trim(bt-node.nodeValue)) no-error.
                        if error-status:error then do:
                            wrk.amt = 0.
                            if wrk.err <> '' then wrk.err = wrk.err + '; '.
                            wrk.err = wrk.err + "Строка " + string(i) + " - Ошибка конвертации суммы, значение=" + trim(bt-node.nodeValue).
                        end.
                    end.
                    else do:
                        run exp2deci(trim(bt-node.nodeValue), i, output wrk.amt, output v-msg).
                        if v-msg <> '' then do:
                            if wrk.err <> '' then wrk.err = wrk.err + '; '.
                            wrk.err = wrk.err + v-msg.
                        end.
                    end.
                end.
                /*if bt-node.nodeName = "qc" then wrk.qc = trim(bt-node.nodeValue).*/
            end.
        end.

    end.

    /*
    for each wrk where wrk.
    */

    find first wrk no-lock no-error.
    if not avail wrk then do:
        message "Записи в таблице проводок отсутствуют!" view-as alert-box error.
        return.
    end.

    for each wrk:

        if length(wrk.dtAcc) = 20 then do:
            v-bank = "txb" + substring(wrk.dtAcc,19,2).
            find first txb where txb.bank = v-bank and txb.consolid no-lock no-error.
            if avail txb then wrk.bank1 = v-bank.
            else do:
                if wrk.err <> '' then wrk.err = wrk.err + '; '.
                wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Некорректный код филиала в номере счета " + wrk.dtAcc.
            end.
        end.
        else
        if length(wrk.dtAcc) <> 6 then do:
            if wrk.err <> '' then wrk.err = wrk.err + '; '.
            wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Некорректный номер счета по дебету, " + wrk.dtAcc.
        end.
        else if wrk.dtAcc = "111111" then wrk.bank1 = "TXB00".

        if length(wrk.ctAcc) = 20 then do:
            v-bank = "txb" + substring(wrk.ctAcc,19,2).
            find first txb where txb.bank = v-bank and txb.consolid no-lock no-error.
            if avail txb then wrk.bank2 = v-bank.
            else do:
                if wrk.err <> '' then wrk.err = wrk.err + '; '.
                wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Некорректный код филиала в номере счета " + wrk.ctAcc.
            end.
        end.
        else
        if length(wrk.ctAcc) <> 6 then do:
            if wrk.err <> '' then wrk.err = wrk.err + '; '.
            wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Некорректный номер счета по кредиту, " + wrk.ctAcc.
        end.
        else if wrk.ctAcc = "111111" then wrk.bank1 = "TXB00".

        if wrk.bank1 = '' and wrk.bank2 = '' then do:
            if wrk.err <> '' then wrk.err = wrk.err + '; '.
            wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Не определен код филиала".
        end.
        else do:
            if (wrk.bank1 = '') or (wrk.bank2 = '') then do:
                wrk.trxtype = "jou".
                if wrk.bank1 = '' then assign wrk.bank = wrk.bank2 wrk.bank1 = wrk.bank2.
                else assign wrk.bank = wrk.bank1 wrk.bank2 = wrk.bank1.
            end.
            else do:
                if wrk.bank1 = wrk.bank2 then assign wrk.trxtype = "jou" wrk.bank = wrk.bank1.
                else do:
                    wrk.trxtype = "rmz".
                    wrk.bank = wrk.bank1.
                    if (wrk.bank1 <> "txb00") and (wrk.bank2 <> "txb00") then do:
                        if wrk.err <> '' then wrk.err = wrk.err + '; '.
                        wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Нет счета ЦО!".
                    end.
                end.
            end.
        end.

        wrk.rem = getRem(wrk.period,wrk.dtAcc,wrk.ctAcc).
    end.

    for each wrk:
        v-wt = string(length(wrk.dtAcc)) + string(length(wrk.ctAcc)).
        if wrk.trxtype = "jou" then do:
            case v-wt:
                when "2020" then do:
                    if substr(wrk.ctAcc,10,4) = '2205' then wrk.templ = "jou0033".
                    else wrk.templ = "jou0036".
                END.
                when "620" then wrk.templ = "uni0004".
                when "206" then wrk.templ = "uni0003".
                when "66" then wrk.templ = "uni0001".
                otherwise do:
                    if wrk.err <> '' then wrk.err = wrk.err + '; '.
                    wrk.err = wrk.err + "Строка " + string(wrk.id) + " - Ошибка выбора шаблона!".
                    next.
                end.
            end case.
        end.
        else do:
            /* rmz */

        end.
    end.

    v-msg = ''.
    for each wrk where wrk.err <> '' no-lock:
        if v-msg <> '' then v-msg = v-msg + '~n'.
        v-msg = v-msg + replace(wrk.err,';','~n').
    end.
    if v-msg <> '' then message v-msg view-as alert-box error title "Ошибки".

    open query qt for each wrk no-lock.
    enable bt btn-rep with frame ft.
    if v-msg = '' then enable btn-f1 with frame ft.
    enable btn-f4 with frame ft.

    wait-for window-close of current-window or choose of btn-f1 or choose of btn-f4.
    pause 0.
end.



