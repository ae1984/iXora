/* dcpmd1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: смена статуса NEW - MD1
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
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-lc     like LC.LC.
def shared var s-paysts like lcpay.sts.
def shared var s-lcpay  like lcpay.lcpay.
def shared var s-ourbank as char no-undo.
def shared var s-namef   as char.
def shared var s-lcprod  as char.
def var v-mlist    as char no-undo.
def var v-mlist2   as char no-undo.
def var v-logsno   as char no-undo init "no,n,нет,н,1".
def var i          as int  no-undo.
def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

if s-paysts ne 'new' then return.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccT' no-lock no-error.
    if not avail lcpayh or lcpayh.value1 = '' then do:
        message "Field Commission Account Type(amt excl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.
find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccTI' no-lock no-error.
    if not avail lcpayh or lcpayh.value1 = '' then do:
        message "Field Commission Account Type(amt incl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.

v-mlist = 'TRNum,VDate,CurCode,PAmt,CollAcc,SCor202'.
if s-lcprod = 'idc' then do:
    v-mlist = v-mlist  + ',' + 'KNP'.
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT400' no-lock no-error.
    if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-mlist = v-mlist + ',' + 'RRef' + ',' + 'RemBnk' +  ',' + 'AmtRem'.
end.

do i = 1 to num-entries(v-mlist):
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lcpayh or lcpayh.value1 = '' then do:
        find first lckrit where lckrit.datacode = entry(i,v-mlist) no-lock no-error.
        if avail lckrit then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
                 if lckrit.datacode = 'CollAcc' then v-mlist2 = v-mlist2 + if s-lcprod = 'odc' then "Drawer's Account" else "Document Account".
            else if lckrit.datacode = 'PAmt'    then v-mlist2 = v-mlist2 + if s-lcprod = 'odc' then "Amount"           else "Amount Collected".
            else if lckrit.datacode = 'SCor202' then v-mlist2 = v-mlist2 + "Correspondent Bank".
            else v-mlist2 = v-mlist2 + lckrit.dataName.
        end.
    end.
end.
if trim(v-mlist2) <> '' then do:
    message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box.
    return.
end.

pause 0.
run LCstspay(s-paysts,'MD1').

/* сообщение */
find last lcpay where lcpay.lc = s-lc no-lock no-error.
if avail lcpay and lcpay.sts = 'MD1' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
    if avail bookcod then v-maillist = bookcod.name.
    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a Payment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.

