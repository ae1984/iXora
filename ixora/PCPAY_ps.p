/* PCPAY_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование файлов на пополнение платежных карт
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
        13/08/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        12.10.2012 Lyubov - исправила ошибку в поле <Description>
        06.11.2012 id00810 - заполнение поля MemberId в зависимости от pcpay.info[1]
        23.11.2012 id00810 - возврат к старому варианту MemberId
        22.08.2013 Lyubov - ТЗ 2031, сохраняем файл в data/export/pc, на сервер в euraz ложим только с боевого
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
def var crlf       as char no-undo.
def var s0         as char no-undo.
def var rcd        as char no-undo.
def var v-arc      as char no-undo.
def var num-orders as int.
def var cur-order-num as int.

def new shared temp-table t-pcpay no-undo
    field aaa   like pcpay.aaa
    field amt   like jl.dam
    field crc   as   char
    field rnn   as   char
    field sname as   char
    field ref   as   char
    field bnk   as   char.
def new shared temp-table t-payitog no-undo
    field crc   as char
    field crcc  as char
    field kol   as int
    field amt   as deci.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PCPAY", " Нет параметра ourbnk sysc!").
    return.
end.
v-bank = sysc.chval.
find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'bankcode'
                     no-lock no-error.
if avail bookcod then v-bcode = bookcod.name.
else do:
    run savelog( "PCPAY", " Нет кода <bankcode> в справочнике <pc> !").
    return.
end.
v-fcode = substr(v-bcode,1,2) + substr(v-bank,4,2).
for each pcpay where pcpay.bank = v-bank and pcpay.sts = 'ready' no-lock break by pcpay.crc:
    if first-of(pcpay.crc) then do:
        assign i       = 0
               v-crc3  = ''.
        find first bookcod where bookcod.bookcod = 'pc'
                             and bookcod.code    = 'crc'
                             no-lock no-error.
        if avail bookcod then i = lookup(string(pcpay.crc),bookcod.name).
        if i > 0 then do:
            find first bookcod where bookcod.bookcod = 'pc'
                                 and bookcod.code    = 'crc3'
                                 no-lock no-error.
            if avail bookcod and num-entries(bookcod.name) >= i then v-crc3 = entry(i,bookcod.name).
        end.
        if v-crc3 = '' then do:
            run savelog( "PCPAY", " Нет соответствия кодов <crc> и <crc3> в справочнике <pc> для кода валюты "  + string(pcpay.crc) + "!").
            return.
        end.
        find first crc where crc.crc = pcpay.crc no-lock no-error.

        create t-payitog.
        assign t-payitog.crc  = v-crc3
               t-payitog.crcc = if avail crc then substr(crc.code,1,2) else '' .
    end.

    /*find first jh where jh.jh = pcpay.jh no-lock no-error.
    if avail jh and jh.sts = 6 then do:*/
        assign t-payitog.kol  = t-payitog.kol + 1
               t-payitog.amt  = t-payitog.amt + pcpay.amt.
        create t-pcpay.
            assign t-pcpay.aaa = pcpay.aaa
                   t-pcpay.amt = pcpay.amt
                   t-pcpay.crc = v-crc3
                   t-pcpay.ref = pcpay.ref
                   t-pcpay.bnk = if pcpay.info[1] ne '' then v-fcode else v-bcode.
        find first pccards where pccards.aaa = pcpay.aaa no-lock no-error.
        if avail pccards then assign t-pcpay.rnn = pccards.rnn
                                     t-pcpay.sname = pccards.sname.
    /*end.*/
end.

/* формирование файла  и его выгрузка */
find first t-payitog where t-payitog.kol > 0 no-lock no-error.
if avail t-payitog then assign crlf       = chr(13) + chr(10)
                               file-date  = string(g-today - date(01,01, year(g-today)) + 1, "999")
                               file-year  = string(year(g-today), "9999")
                               file-month = string(month(g-today), "99")
                               file-day   = string(day(g-today), "99")
                               file-time  = string(time, "hh:mm:ss").
else return.

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
    output to pay.xml.

    /* FileHeader */
    s0 = "<DocFile xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">" + crlf +
         "<FileHeader>" + crlf +
         "<FileLabel>PAYMENT</FileLabel>" + crlf +
         "<FormatVersion>2.1</FormatVersion>" + crlf +
         "<Sender>" + v-fcode + "</Sender>" + crlf +
         "<CreationDate>" + file-year + "-" + file-month + "-" + file-day + "</CreationDate>" + crlf +
         "<CreationTime>" + file-time + "</CreationTime>" + crlf +
         "<FileSeqNumber>" + file-cntr + "</FileSeqNumber>" + crlf +
         "<Receiver>PAY" + v-bcode + "</Receiver>" + crlf +
         "</FileHeader>" + crlf.

    put unformatted s0.
    /* DocList DocBatch */
    s0 = "<DocList>" +  crlf +
         "<DocBatch>"  + crlf +
         "<BatchHeader>"  + crlf +
         "<TransType>"  + crlf +
         "<TransCode>"  + crlf +
         "<MsgCode>PAYACC</MsgCode>"  + crlf +
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
         "<Description>" + "Payment to Card" + "</Description>" + crlf +
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
             "<MsgCode>PAYACC</MsgCode>"  + crlf +
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
             "<Description>" + "Payment to Card" + "</Description>" + crlf +
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
        input through value("scp " + file-name + " Administrator@fs01.metrobank.kz:" + "D:\\\\euraz\\\\Cards\\\\Out\\\\;echo $?").

        repeat:
            import unformatted rcd.
        end.
    end.

    if rcd <> "0" then do:
        run savelog( "PCPAY", " Ошибка копирования файла " + file-name + ". Код " + rcd + ".").
    end.
    else do:
        for each t-pcpay where t-pcpay.crc = t-payitog.crc no-lock:
            find first pcpay where pcpay.ref = t-pcpay.ref exclusive-lock no-error.
            if avail pcpay then do:
                assign pcpay.sts = 'send'
                       pcpay.namefout = file-name
                       pcpay.who      = g-ofc
                       pcpay.whn      = g-today.
                find current pcpay no-lock no-error.
            end.
        end.
    end.

    v-arc = "/data/export/pc/".
    input through value( "find " + v-arc + ";echo $?").
    repeat:
        import unformatted rcd.
    end.
    if rcd <> "0" then do:
        unix silent value ("mkdir " + v-arc).
        unix silent value ("chmod 777 " + v-arc).
    end.

    v-arc = "/data/export/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
    input through value( "find " + v-arc + ";echo $?").
    repeat:
        import unformatted rcd.
    end.
    if rcd <> "0" then do:
        unix silent value ("mkdir " + v-arc).
        unix silent value ("chmod 777 " + v-arc).
    end.
    unix silent value('cp ' + file-name + ' ' + v-arc).
end.