/* LCstspay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        смена статуса платежа
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
    21/01/2011 id00810 - определение LCsts.expimp
    08/07/2011 id00810 - статус PAY заменен на BO2
    09/11/2011 id00810 - отправка сообщения (перенесена из LCpauth2.p)
    29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
*/
{mainhead.i}

def input parameter v-lcstsold as char.
def input parameter v-lcstsnew as char.
def shared var s-lc       like LC.LC.
def shared var s-paysts   like lcpay.sts.
def shared var s-lcpay    like lcpay.lcpay.
def shared var s-lcprod   as char.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lcdtexp  as date.
def var v-yes      as logi no-undo.

def var v-str      as char no-undo.
def var v-sp       as char no-undo.
def var v-applic   as char no-undo.
def var i          as int  no-undo.
def var k          as int  no-undo.
def var v-maillist as char no-undo extent 2.
def var v-sum      as deci no-undo.

if v-lcstsnew <> 'FIN' and v-lcstsnew <> 'ERR' and v-lcstsnew <> 'BO2' then do:
    message 'Do you want to change Payment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
end.

if s-paysts = v-lcstsold  then do:

    s-paysts = v-lcstsnew.

    find first LCpay where LCpay.LC = s-lc and LCpay.lcpay = s-lcpay no-lock no-error.
    if avail lcpay then do:
        find current lcpay exclusive-lock no-error.
        LCpay.sts = v-lcstsnew.
        find current LCpay no-lock no-error.
    end.
    find LC where LC.lc = s-lc no-lock no-error.

    create LCsts.
    assign LCsts.LCnum  = s-lc
           LCsts.num    = s-lcpay
           LCsts.type   = 'PAY'
           LCsts.sts    = v-lcstsnew
           LCsts.whn    = g-today
           LCsts.who    = g-ofc
           LCsts.expimp = LC.LCtype
           LCsts.tim    = time.
    find current lcsts no-lock no-error.
end.
if v-lcstsnew = 'FIN' then do:
    /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
    if avail bookcod then do:
       do k = 1 to num-entries(bookcod.name,','):
          v-sp = entry(k,bookcod.name,',').
          do i = 1 to num-entries(v-sp):
             if trim(entry(i,v-sp)) <> '' then do:
                if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
                v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)).
             end.
          end.
       end.
    end.
    if v-maillist[1] <> '' then do:

        find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
        if avail lcpayh and lcpayh.value1 <> '' then assign v-sum = deci(lcpayh.value1).

        v-str = 'Референс инструмента: ' + s-lc + '~n' + '~n' + 'Аппликант: ' .

        find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
        if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Бенефициар: '.
        else  v-str = v-str + '~n' + '~n' + 'Бенефициар: '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
        if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Сумма сделки(первоначальная): '.
        else  v-str = v-str + '~n' + '~n' + 'Сумма сделки(первоначальная: '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
        if avail lch then do:
            v-lcsumorg = deci(lch.value1).
            v-lcsumcur = deci(lch.value1).
            v-str = v-str + trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Сумма оплаты: '.
        end.
        else  v-str = v-str + '~n' + '~n' + 'Сумма оплаты: '.
        v-str = v-str +  trim(replace(string(v-sum,'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Сумма сделки(текущая): '.

        /*amendment*/
        if s-lcprod <> 'pg' then
        for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
            find first jh where jh.jh = lcamendres.jh no-lock no-error.
            if not avail jh then next.

            if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
            if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
        end.
        else
        for each lcamendres where lcamendres.lc = s-lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
           find first jh where jh.jh = lcamendres.jh no-lock no-error.
           if not avail jh then next.
           if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsumcur = v-lcsumcur + lcamendres.amt.
           else v-lcsumcur = v-lcsumcur - lcamendres.amt.
        end.

        /*payment*/
        for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
            find first jh where jh.jh = lcpayres.jh no-lock no-error.
            if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
        end.
        /*event*/
        for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
            find first jh where jh.jh = lceventres.jh no-lock no-error.
            if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
        end.
        v-str = v-str + trim(replace(string(v-lcsumcur,'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Валюта сделки: '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
        if avail lch then do:
           find first crc where crc.crc = integer(lch.value1) no-lock no-error.
           if avail crc then v-str = v-str + crc.code + '~n' + '~n' + 'Дата выпуска аккредитива: '.
        end.
        else  v-str = v-str + '~n' + '~n' + 'Дата выпуска аккредитива: '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
        if avail lch then v-str = v-str + lch.value1 + '~n' + '~n' + 'Дата истечения аккредитива: '.
        else  v-str = v-str + '~n' + '~n' + 'Дата истечения аккредитива: '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
        if avail lch then do:
            v-lcdtexp = date(lch.value1).
            find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
            if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
            v-str = v-str + lch.value1 + '~n'.
        end.
        else  v-str = v-str + '~n'.

        run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", 'Оплата аккредитива',v-str, "", "","").
        if v-maillist[2] <> '' then
        run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", 'Оплата аккредитива',v-str, "", "","").

    end.
end.
