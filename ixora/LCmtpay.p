/* LCmtpay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT756 и МТ202
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
        26/11/2010 galina - поправила копирование в swift
        09/12/2010 galina - выводи номер аккредитива заглавными буквами
        10/12/2010 galina - поправила копирование в swift
        28/12/2010 Vera   - временно закомментировала удаление s-value1
        29/12/2010 Vera   - перекомпиляция
        30/12/2010 madiyar - исправил копирование файла в Swift Alliance
        03/02/2011 id00810 - исправила копирование для 202 сообщения
        10/02/2011 id00810 - обработка критериев AccInsOp, BenInsOp
        22/02/2011 id00810 - исправила ошибку при разборе результата копирования
        01/03/2011 id00810 - уточнение формата критериев AccIns, BenIns
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        25/11/2011 id00810 - учет реквизита ComAmt
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
*/

{global.i}
def shared var s-lc    like LC.LC.
def shared var s-lcpay like lcpay.lcpay.
def var v-bank   as char no-undo.
def var s-value1 as char no-undo.
def var v-file0  as char no-undo.
def var v-result as char no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-opt    as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var v-amt    as deci no-undo.
def var v-com    as deci no-undo.
def var v-swt    as char no-undo.
def stream out.

{cr-swthead.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
v-bank = trim(sysc.chval).
v-swt = get-path('swtpath').

find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmt' no-lock no-error.
if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
else do:
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
    if avail lcpayh and lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
    if avail lcpayh and lcpayh.value1 ne '' then v-com = v-com + deci(lcpayh.value1).
end.
/*find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmt' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).
*/
/*MT202*/
find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT202' no-lock no-error.
if avail lcpayh and lookup(lcpayh.value1,v-logsno) > 0 then message 'MT202 was not been created because you had made such a choice!' view-as alert-box info.

else do:
    v-file0 = 'MT202'.
    s-value1 = ''.
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Numpay' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then s-value1 = replace(s-lc,"/", "_") + lcpayh.value1 + '202'.

    output stream out to value(v-file0).
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'InsTo202' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted cr-swthead ('202',trim(lcpayh.value1)).

    put stream out unformatted '\{4:' skip.
    put stream out unformatted ":20:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TRNum' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted caps(lcpayh.value1) skip.

    put stream out unformatted ":21:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RRef' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted lcpayh.value1 skip.

    put stream out unformatted ":32A:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'VDate' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted  datestr(lcpayh.value1).

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then do:
        find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
        if avail codfr then put stream out unformatted codfr.name[1].
    end.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then  do:
        v-amt = deci(lcpayh.value1) - v-com.
        put stream out unformatted replace(trim(string(v-amt,'>>>>>>>>9.99')),'.',',') skip.
    end.
    put stream out unformatted ":53B:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SCor202' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted '/' + lcpayh.value1 skip.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'Intermid' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted ":56A:" + lcpayh.value1 skip.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'AccInsOp' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then v-opt = trim(lcpayh.value1).

    put stream out unformatted ":57" + v-opt + ":".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'AccIns' no-lock no-error.
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

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenInsOp' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then v-opt = trim(lcpayh.value1).

    put stream out unformatted ":58" + v-opt + ":".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenAcc' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted '/' + lcpayh.value1 skip.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'BenIns' no-lock no-error.
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

    put stream out unformatted ':72:'.
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SRInf202' no-lock no-error.
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

    put stream out unformatted "-}" skip.
    output stream out close.

    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -q -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " " + v-swt + ";echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
        unix silent rm -f value (s-value1).
        unix silent rm -f value (v-file0).
        return error.
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mtpay;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then
    message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mtpay." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
end.

/****MT756*****/
find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT756' no-lock no-error.
if avail lcpayh and lookup(lcpayh.value1,v-logsno) > 0 then message 'MT756 was not been created because you had made such a choice!' view-as alert-box.
else do:
    v-file0 = 'MT756'.
    s-value1 = ''.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Numpay' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then s-value1 = replace(s-lc,"/", "_") + lcpayh.value1 + '756'.

    output stream out to value(v-file0).
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'InsTo756' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted cr-swthead ('756',trim(lcpayh.value1)).

    put stream out unformatted '\{4:' skip.
    put stream out unformatted ":20:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TRNum' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted caps(lcpayh.value1) skip.

    put stream out unformatted ":21:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RRef' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted lcpayh.value1 skip.

    put stream out unformatted ":32B:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then do:
        find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
        if avail codfr then put stream out unformatted codfr.name[1].
    end.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'TPAmt' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted replace(trim(string(deci(lcpayh.value1),'>>>>>>>>9.99')),'.',',') skip.

    put stream out unformatted ":33A:".
    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'VDate' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted  datestr(lcpayh.value1).

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then do:
        find first codfr where codfr.codfr = 'lccrc' and codfr.code = lcpayh.value1 no-lock no-error.
        if avail codfr then put stream out unformatted codfr.name[1].
    end.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then  do:
        v-amt = deci(lcpayh.value1) - v-com.
        put stream out unformatted replace(trim(string(v-amt,'>>>>>>>>9.99')),'.',',') skip.
    end.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SCor756' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted ":53A:" + lcpayh.value1 skip.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'RCor' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted ":54A:" + lcpayh.value1 skip.

    find first lcpayh where lcpayh.bank = v-bank and lcpayh.lc = s-lc and lcpayh.lcpay= s-lcpay and lcpayh.kritcode = 'SRInf756' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then do:
        put stream out unformatted ':72:'.
        k = length(lcpayh.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lcpayh.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    put stream out unformatted "-}" skip.
    output stream out close.

    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -q -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " " + v-swt + ";echo $?").
    repeat:
        import unformatted v-result.
    end.

    if v-result <> "0" then do:
        message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
        unix silent rm -f value (s-value1).
        unix silent rm -f value (v-file0).
        return error.
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mtpay;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then
    message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mtpay." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
end.
