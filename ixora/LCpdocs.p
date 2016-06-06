/*LCpdocs .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        формирование документов
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
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        09/12/2010 galina - выводим номер аккредитива заглавными буквами
        10/02/2011 id00810 - обработка критериев AccInsOp, BenInsOp
        01/03/2011 id00810 - уточнение формата критериев AccIns, BenIns
        25/11/2011 id00810 - учет реквизита ComAmt
        10/02/2012 id00810 - 2 реквизита ComAmtI и ComAmtE для учета комиссий
        06.04.2012 Lyubov  - добавила печать ордера для лимитов
*/

{global.i}
def shared var s-lc    like lc.lc.
def shared var s-lcpay like lcpay.lcpay.
def shared var v-cif   as char.

def var v-sel    as int  no-undo.
def var v-amt    as deci no-undo.
def var i        as int  no-undo.
def var k        as int  no-undo.
def var v-crc    as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-list   as char no-undo.
def var v-opt    as char no-undo.
def var v-com    as deci no-undo.
def var v-bank   as char no-undo.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var s-jh like jh.jh .
def stream out.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

v-crc = 0.
find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else return.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = integer(lch.value1).

v-list = ' MT 202 | MT 756 | Memorial statement'.
if v-crc = 1 then v-list = v-list + '  | Payment Order '.
run sel2('Docs',v-list, output v-sel).

case v-sel:
    when 1 then do:
        if v-crc = 1 then do:
            message 'This operation is valid only for the Letter of credit ~n in the foreign currency !' view-as alert-box.
            return.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT202' no-lock no-error.
        if avail lcpayh and lookup(lcpayh.value1,v-logsno) > 0 then do:
            message 'Your choice had not been to create this type of message!' view-as alert-box.
            return.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmt' no-lock no-error.
        if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
        else do:
            find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
            if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
            find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
            if avail lcpayh and lcpayh.value1 ne '' then v-com = v-com + deci(lcpayh.value1).
        end.

        output stream out to MT202.txt.
        put stream out unformatted 'MT202: General Financial Institution Transfer' skip(2)
                                    'To Institution '.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'InsTo202' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lcpayh.value1 skip.
        end.

        put stream out unformatted 'Priority N' skip(2).

        put stream out unformatted "20:Transaction Reference Number" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TRNum' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted caps(lcpayh.value1) skip.

        put stream out unformatted "21:Related Reference" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RRef' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted lcpayh.value1 skip.

        put stream out unformatted "32A:Value Date, Currency Code, Amount " skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'VDate' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted  datestr(lcpayh.value1).

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
            if avail codfr then put stream out unformatted codfr.name[1].
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then  do:
            v-amt = deci(lcpayh.value1) - v-com.
            put stream out unformatted replace(trim(string(v-amt,'>>>>>>>>9.99')),'.',',') skip.
        end.
        else put stream out unformatted skip.

        put stream out unformatted "53B:Sender's Correspondent" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SCor202' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted '/' + lcpayh.value1 skip.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'Intermid' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            put stream out unformatted "56A:Intermediary " skip.
            find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lcpayh.value1 skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'AccInsOp' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            v-opt = trim(lcpayh.value1).
            put stream out unformatted "57" + v-opt + ":Account With Institution" skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'AccIns' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            if v-opt = 'A' then do:
                find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
                if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            end.
            else do:
                k = length(lcpayh.value1).
                i = 1.
                repeat:
                    put stream out unformatted trim(caps(substr(lcpayh.value1,i,35))) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
            /*else put stream out unformatted lcpayh.value1 skip.*/
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenInsOp' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            v-opt = trim(lcpayh.value1).
            put stream out unformatted "58" + v-opt + ":Beneficiary Institution" skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenAcc' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted '/' + lcpayh.value1 skip.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenIns' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            if v-opt = 'A' then do:
                find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
                if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            end.
            else do:
                k = length(lcpayh.value1).
                i = 1.
                repeat:
                    put stream out unformatted trim(caps(substr(lcpayh.value1,i,35))) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
            /*else put stream out unformatted lcpayh.value1 skip.*/
        end.

        put stream out unformatted '72:Sender to Receiver Information' skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SRInf202' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:

            k = length(lcpayh.value1).
            i = 1.
            repeat:
                put stream out unformatted trim(caps(substr(lcpayh.value1,i,35))) SKIP.
                k = k - 35.
                if k <= 0 then leave.
                i = i + 35.
            end.
        end.

        output stream out close.
        unix silent cptwin MT202.txt winword.
        unix silent rm -f MT202.txt.
    end.
    when 2 then do:
        if v-crc = 1 then do:
            message 'This operation is valid only for the Letter of credit ~n in the foreign currency !' view-as alert-box.
            return.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT756' no-lock no-error.
        if avail lcpayh and lookup(lcpayh.value1,v-logsno) > 0 then do:
            message 'Your choice had not been to create this type of message!' view-as alert-box.
            return.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmt' no-lock no-error.
        if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
        else do:
            find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
            if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
            find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
            if avail lcpayh and lcpayh.value1 ne '' then v-com = v-com + deci(lcpayh.value1).
        end.

        output stream out to MT756.txt.
        put stream out unformatted 'MT756:Advice of Reimbursement or Payment' skip(2)
                                    'To Institution '.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'InsTo756' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lcpayh.value1 skip.
        end.

        put stream out unformatted 'Priority N' skip(2).

        put stream out unformatted "20:Sender's Reference" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TRNum' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted caps(lcpayh.value1) skip.

        put stream out unformatted "21:Presenting Bank's Reference" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RRef' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted lcpayh.value1 skip.

        put stream out unformatted "32B:Total Amount Claimed" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
            if avail codfr then put stream out unformatted codfr.name[1].
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TPAmt' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then  put stream out unformatted replace(trim(string(deci(lcpayh.value1),'>>>>>>>>9.99')),'.',',') skip.

        put stream out unformatted "33A:Amount Reimbursed or Paid" skip.
        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'VDate' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted  datestr(lcpayh.value1).

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
            if avail codfr then put stream out unformatted codfr.name[1].
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            v-amt = deci(lcpayh.value1) - v-com.
            put stream out unformatted replace(trim(string(v-amt,'>>>>>>>>9.99')),'.',',') skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SCor756' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            put stream out unformatted "53A:Sender's Correspondent" skip.
            find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lcpayh.value1 skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RCor' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            put stream out unformatted "54A:Receiver's Correspondent " skip.
            find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lcpayh.value1 skip.
        end.

        find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SRInf756' no-lock no-error.
        if avail lcpayh and trim(lcpayh.value1) <> '' then do:
            put stream out unformatted '72:Sender to Receiver Information' skip.
            k = length(lcpayh.value1).
            i = 1.
            repeat:
                put stream out unformatted trim(caps(substr(lcpayh.value1,i,35))) SKIP.
                k = k - 35.
                if k <= 0 then leave.
                i = i + 35.
            end.
        end.

        output stream out close.
        unix silent cptwin MT756.txt winword.
        unix silent rm -f MT756.txt.
    end.
    when 3 then do:
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock no-error.
        if avail lcpayres then do:
            for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock:
                s-jh  = 0.
                find first jh where jh.jh = lcpayres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
    when 4 then do:
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock no-error.
        if avail lcpayres then do:
            for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock:
                if lcpayres.info[1] = '' then next.
                else do:
                    s-remtrz = lcpayres.info[1].
                    run prtpp.
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.

        find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
        if avail lch then do:
            find first lclimitres where lclimitres.bank = v-bank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.jh > 0 and lclimitres.lc = s-lc and lclimitres.info[1] = 'pay' no-lock no-error.
            if avail lclimitres then do:
                s-jh  = 0.
                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.
    end.
end case.