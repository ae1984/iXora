/* a_ppsend.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование файлов по длительным платежным поручениям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню
 * AUTHOR
        16/07/2013 Luiza
 * BASES
        BANK COMM
 * CHANGES
         30/09/2013 Luiza  - ТЗ 2047
 */

{global.i}
{srvcheck.i}

def var v-bank     as char no-undo.
def var v-bcode    as char no-undo.
def var v-fcode    as char no-undo.
def var i          as int  no-undo.
def var v-crc3     as char no-undo.
def var file-cntr  as char format "x(2)".
def var file-date  as char format "x(3)".
def var file-year  as char format "x(4)".
def var file-month as char format "x(2)".
def var file-day   as char format "x(2)".
def var file-time  as char format "x(6)".
def var file-name  as char no-undo.
def var file-mail  as char no-undo.
def var crlf       as char no-undo.
def var s0         as char no-undo.
def var rcd        as char no-undo.
def var num-orders as int.
def var cur-order-num as int.
def var v-cnt as int.

def new shared temp-table t-pcpay no-undo
    field aaa   like pcpay.aaa
    field amt   like jl.dam
    field crc   as   char
    field rnn   as   char
    field sname as   char
    field ref   as   char
    field id    as   int
    field bnk   as   char.
def new shared temp-table t-payitog no-undo
    field crc   as char
    field crcc  as char
    field kol   as int
    field amt   as deci.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PPOUT", " There is not parameter ourbnk sysc!").
    return.
end.
v-bank = sysc.chval.
find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'bankcode'
                     no-lock no-error.
if avail bookcod then v-bcode = bookcod.name.
else do:
    run savelog( "PPOUT", " There is not code <bankcode> in <pc> !").
    return.
end.

find first sysc where sysc.sysc = "ppout10" no-lock no-error.
if not avail sysc then do:
    run savelog( "PPOUT", " There is not parameter ppout10 sysc!").
    return.
end.

find first sysc where sysc.sysc = "ppout13" no-lock no-error.
if not avail sysc then do:
    run savelog( "PPOUT", " There is not parameter ppout13 sysc!").
    return.
end.

v-cnt = 0.
for each txb where txb.bank begins "TXB" no-lock.
    v-fcode = substr(v-bcode,1,2) + substr(txb.bank,4,2).
    empty temp-table t-payitog.
    empty temp-table t-pcpay.
    for each pplist where pplist.txb = txb.bank and (trim(pplist.stat) = 'Новый' or trim(pplist.stat) = 'Не обработан') and time < 61200 and g-today = today no-lock break by pplist.crc:
        if first-of(pplist.crc) then do:
            assign i       = 0
                   v-crc3  = ''.
            find first bookcod where bookcod.bookcod = 'pc'
                                 and bookcod.code    = 'crc'
                                 no-lock no-error.
            if avail bookcod then i = lookup(string(pplist.crc),bookcod.name).
            if i > 0 then do:
                find first bookcod where bookcod.bookcod = 'pc'
                                     and bookcod.code    = 'crc3'
                                     no-lock no-error.
                if avail bookcod and num-entries(bookcod.name) >= i then v-crc3 = entry(i,bookcod.name).
            end.
            if v-crc3 = '' then do:
                run savelog( "PPOUT", " Нет соответствия кодов <crc> и <crc3> в справочнике <pc> для кода валюты "  + string(pplist.crc) + "!").
                return.
            end.
            find first crc where crc.crc = pplist.crc no-lock no-error.

            create t-payitog.
            assign t-payitog.crc  = v-crc3
                   t-payitog.crcc = if avail crc then substr(crc.code,1,2) else '' .
        end.

        assign t-payitog.kol  = t-payitog.kol + 1
               t-payitog.amt  = t-payitog.amt + pplist.sum.
        create t-pcpay.
            assign t-pcpay.aaa = pplist.aaa
                   t-pcpay.amt = pplist.sum
                   t-pcpay.crc = v-crc3
                   t-pcpay.ref = ""
                   t-pcpay.id  = pplist.id
                   t-pcpay.bnk = substr(v-bcode,1,2) + substring(pplist.txb,4,2).
        find first pcstaff0 where pcstaff0.aaa = pplist.aaa no-lock no-error.
        if avail pcstaff0 then assign t-pcpay.rnn = pcstaff0.iin
                                     t-pcpay.sname = trim(pcstaff0.sname) + " " + substring(trim(pcstaff0.fname),1,1) +
                                                    "." + substring(trim(pcstaff0.mname),1,1) + ".".
    end.

    /* формирование файла  и его выгрузка */
    find first t-payitog where t-payitog.kol > 0 no-lock no-error.
    if avail t-payitog then assign crlf       = chr(13) + chr(10)
                                   file-date  = string(g-today - date(01,01, year(g-today)) + 1, "999")
                                   file-year  = string(year(g-today), "9999")
                                   file-month = string(month(g-today), "99")
                                   file-day   = string(day(g-today), "99")
                                   file-time  = string(time, "hh:mm:ss").
    else next.

    for each t-payitog where t-payitog.kol > 0 no-lock:
        find first pccounters where pccounters.type = "payment_file" no-lock no-error.
        if avail pccounters then do:
            find current pccounters exclusive-lock.
            if pccounters.dat <> g-today then assign pccounters.dat = g-today
                                                     pccounters.counter = 1.
            else pccounters.counter = pccounters.counter + 1.
        end.
        else do:
            create pccounters.
            assign pccounters.type = "payment_file"
                   pccounters.dat = g-today
                   pccounters.counter = 1.
        end.
        find current pccounters no-lock.
        assign file-cntr  = string(pccounters.counter, "999")
               s0         = "IIC_DOCUMENTS_1100PAY1100" + file-year + file-month + file-day + "_" + file-cntr + ".xml"
               file-name  = s0.
               file-mail  = file-mail + " ; " + s0.  /* запоминаем названия файлов для сообщения департ ПК */
        output to pay.xml.

        /* FileHeader */
        s0 = "<DocFile xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">" + crlf +
             "<FileHeader>" + crlf +
             "<FileLabel>PAYMENT</FileLabel>" + crlf +
             "<FormatVersion>2.1</FormatVersion>" + crlf +
             "<Sender>PAY" + v-bcode  /*v-fcode*/ + "</Sender>" + crlf +
             "<CreationDate>" + file-year + "-" + file-month + "-" + file-day + "</CreationDate>" + crlf +
             "<CreationTime>" + file-time + "</CreationTime>" + crlf +
             "<FileSeqNumber>" + file-cntr + "</FileSeqNumber>" + crlf +
             "<Receiver>" + v-bcode + "</Receiver>" + crlf +
             "</FileHeader>" + crlf.

        put unformatted s0.
        /* DocList DocBatch */
        s0 = "<DocList>" +  crlf +
             "<DocBatch>"  + crlf +
             "<BatchHeader>"  + crlf +
             "<TransType>"  + crlf +
             "<TransCode>"  + crlf +
             "<MsgCode>PAYMFDPP</MsgCode>"  + crlf +
             "<FinCategory>N</FinCategory>"  + crlf +
             "<RequestCategory>P</RequestCategory>"  + crlf +
             "<ServiceClass>T</ServiceClass>"  + crlf +
             "</TransCode>"  + crlf +
             "</TransType>"  + crlf +
             "<DocRefSet>"  + crlf +
             "<Parm>"  + crlf +
             "<ParmCode>SRN</ParmCode>"  + crlf +
             "<Value />"  + crlf +
             "</Parm>"  + crlf +
             "</DocRefSet>"  + crlf +
             "<LocalDt>" + file-year + "-" + file-month + "-" + file-day + " " + file-time + "</LocalDt>" + crlf +
             "<Description>" + "Payment from Card for payment order" + "</Description>" + crlf +
             "<Source>" + crlf +
             "<MemberId>PAY" + v-fcode + "</MemberId>"  + crlf +
             "</Source>"  + crlf +
             "<Transaction>"  + crlf +
             "<PhaseDate>" + file-year + "-" + file-month + "-" + file-day + "</PhaseDate>"  + crlf +
             "<Currency>" + t-payitog.crc + "</Currency>"  + crlf +
             "<Amount>" + trim(string(t-payitog.amt,'>>>>>>>>>>>9.99')) + "</Amount>"   + crlf +
             "</Transaction>"   + crlf +
             "</BatchHeader>"   + crlf +
             "<DocList>" + crlf .
        put unformatted s0.
        for each t-pcpay where t-pcpay.crc = t-payitog.crc no-lock:
        s0 = "<Doc>"  + crlf +
             "<TransType>"  + crlf +
             "<TransCode>"  + crlf +
             "<MsgCode>PAYMFDPP</MsgCode>"  + crlf +
             "<FinCategory>N</FinCategory>"  + crlf +
             "<RequestCategory>P</RequestCategory>" + crlf +
             "<ServiceClass>T</ServiceClass>"  + crlf +
             "</TransCode>" + crlf +
             "<DisputeRules>"  + crlf +
             "<ReasonDetails/>" + crlf +
             "</DisputeRules>" + crlf +
             "</TransType>"  + crlf +
             "<DocRefSet>" + crlf +
             "<Parm>"  + crlf +
             "<ParmCode>SRN</ParmCode>"  + crlf +
             "<Value />" + crlf +
             "</Parm>" + crlf +
             "</DocRefSet>" + crlf +
             "<LocalDt>" + file-year + "-" + file-month + "-" + file-day + " " + file-time + "</LocalDt>" + crlf +
             "<Description>" + "Payment from Card for payment order" + "</Description>" + crlf +
             "<Originator>" + crlf +
            /* "<MemberId>PAY" + v-bcode + "</MemberId>"  + crlf +*/
             "<MemberId>PAY" + v-fcode + "</MemberId>"  + crlf +
             "</Originator>" + crlf +
             "<Destination>" + crlf +
             "<ContractNumber>" + t-pcpay.aaa + "</ContractNumber>" + crlf +
             "<Client>" + crlf +
             "<ClientInfo>" + crlf +
             "<ShortName>" + t-pcpay.sname + "</ShortName>" + crlf +
             "</ClientInfo>" + crlf +
             "</Client>" + crlf +
             /*"<MemberId>" + t-pcpay.bnk + "</MemberId>" + crlf +*/
             "<MemberId>" + v-fcode + "</MemberId>" + crlf +
             "</Destination>" + crlf +
             "<Transaction>" + crlf +
             "<PhaseDate>" + file-year + "-" + file-month + "-" + file-day + "</PhaseDate>" + crlf +
             "<Currency>" + t-pcpay.crc + "</Currency>" + crlf +
             "<Amount>" + trim(string(t-pcpay.amt,'>>>>>>>>>>>9.99')) + "</Amount>" + crlf +
             "</Transaction>" + crlf +
             "</Doc>" + crlf.
           put unformatted s0.
        end.
        s0 = "</DocList>" + crlf +
             "<BatchTrailer>" + crlf +
             "<CheckSum>" + crlf +
             "<RecsCount>" + string(t-payitog.kol) + "</RecsCount>" + crlf +
             "<HashTotalAmount>" + trim(string((t-payitog.amt + t-payitog.amt),'>>>>>>>>>>>9.99')) + "</HashTotalAmount>"  + crlf +
             "</CheckSum>"  + crlf +
             "</BatchTrailer>" + crlf +
             "</DocBatch>" + crlf +
             "</DocList>" + crlf.
        put unformatted s0.
        /* FileTrailer */
        s0 = "<FileTrailer>" + crlf +
             "<CheckSum>" + crlf +
             "<BatchesCount>1</BatchesCount>" + crlf +
             "<RecsCount>" + string(t-payitog.kol) + "</RecsCount>" + crlf +
             "<HashTotalAmount>" + trim(string((t-payitog.amt + t-payitog.amt),'>>>>>>>>>>>9.99')) + "</HashTotalAmount>"  + crlf +
             "</CheckSum>" + crlf +
             "</FileTrailer>" + crlf +
             "</DocFile>" + crlf.
        put unformatted s0.
        output close.

        unix silent value("koi2utf pay.xml" +  " " + file-name).

        if isProductionServer() then do:
            input through value("scp " + file-name + " Administrator@fs01.metrobank.kz:" + "D:\\\\euraz\\\\Cards\\\\Out\\\\PAYMFROM\\\\;echo $?").
        end.
        else do:
            input through value("scp " + file-name + " Administrator@fs01.metrobank.kz:" + "D:\\\\euraz\\\\Cards\\\\Out\\\\test\\\\PAYMFROM\\\\;echo $?").
        end.

        repeat:
            import unformatted rcd.
        end.
        if rcd <> "0" then do:
            run savelog( "PPOUT", " Error when copying files " + file-name + ". code " + rcd + ".").
        end.
        else do:
            for each t-pcpay where t-pcpay.crc = t-payitog.crc no-lock:
                find first pplist where pplist.txb = txb.bank  and (trim(pplist.stat) = 'Новый' or trim(pplist.stat) = 'Не обработан') and
                pplist.id = t-pcpay.id  exclusive-lock no-error.
                if avail pplist then do:
                    v-cnt = v-cnt + 1.
                    assign pplist.stat = 'OW'
                           pplist.namefout = file-name.
                           pplist.dtout    = g-today.
                           pplist.timout   = time.        /* время отправки */
                    find current pplist no-lock no-error.
                end.
            end.
        end.
    end.
end. /*for each txb where txb.bank begins "TXB" */

if v-cnt > 0 then do:
    find first bookcod where bookcod.bookcod = 'pc'
                         and bookcod.code    = 'txb00'
                         no-lock no-error.
    if avail bookcod then run mail( entry(1,bookcod.name) + "@fortebank.com","bankadm@fortebank.com", "Автоматические проводки по длительным платежным поручениям "
    + v-bank,"Файлы по длительным платежным поручениям для отправки в Евразийский банк сформировались, названия: '" +
                file-mail + "'", "", "","").
    /* меняем признак отправки файла в 10-00*/
    find first sysc where sysc.sysc = "ppout10" no-lock no-error.
    if sysc.loval = no and time >= 36000 and time < 46800 then do:
        find first sysc where sysc.sysc = "ppout10" exclusive-lock no-error.
        sysc.loval = yes.
        sysc.inval = 0.
        find first sysc where sysc.sysc = "ppout10" no-lock no-error.
    end.

    /* меняем признак отправки файла в 13-00*/
    find first sysc where sysc.sysc = "ppout13" no-lock no-error.
    if sysc.loval = no and time >= 46800 then do:
        find first sysc where sysc.sysc = "ppout13" exclusive-lock no-error.
        sysc.loval = yes.
        sysc.inval = 0.
        find first sysc where sysc.sysc = "ppout13" no-lock no-error.
    end.
end.


