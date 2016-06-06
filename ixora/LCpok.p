/* LCpok.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка платежа на авторизацию
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
   23/12/2010 Vera   - изменился frame frpay (добавлено 1 новое поле)
   21/01/2011 id00810 - убрала фрейм, изменила присваиваемый статус на MD1
   10/02/2011 id00810 - обязательные критерии AccInsOp,BenInsOp
   22/02/2011 ids0810 - обязательные критерии Insto202,Insto756
   04/03/2011 id00810 - дополнила обязательные критерии для тенге
   20/06/2011 id00810 - обязательный критерий PType
   30/11/2011 id00810 - убрала обязательность критерия BenAcc
   01/12/2011 id00810 - обязательный критерий ComAccT, если заполнен ComAmt
   06/01/2012 id00810 - обязательный критерий CollAcc для v-ptype = '3'
   11/01/2012 id00810 - обязательный критерий ComAccTI(ComAccT), если заполнен ComAmtI(ComAmtE)
   13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
*/

{mainhead.i}

def shared var s-lc     like LC.LC.
def shared var s-paysts like lcpay.sts.
def shared var s-lcpay  like lcpay.lcpay.
def shared var s-ourbank as char no-undo.
def shared var s-namef    as char.

def var v-mlist  as char no-undo.
def var v-mlist2 as char no-undo.
def var v-avail  as logi no-undo.
def var i        as int  no-undo.
def var v-lccov  as char no-undo.
def var v-crc    as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-ptype  as char no-undo.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

if s-paysts ne 'new' then return.
/*тут проверка на заполнение всех необходимых полей */
find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PType' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Payment Type is empty!" view-as alert-box error.
    return.
end.
v-ptype = lcpayh.value1.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
v-crc = integer(lcpayh.value1).
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
v-mlist = 'TRNum,VDate,PAmt,KBE,KNP'.
if v-crc > 1 then do:
    if v-ptype <= '3' then v-mlist = v-mlist + ',' + 'SCor202'.
    if v-ptype = '3' then v-mlist = v-mlist + ',' + 'CollAcc'.
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT202' no-lock no-error.
    if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-mlist = v-mlist + ',' + 'RRef' + ',' + 'Insto202' + ','  + 'BenInsOp'  + ',' + 'BenIns'  + ',' /*+ 'BenAcc' + ','*/ + 'SRInf202'.
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT756' no-lock no-error.
    if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-mlist = v-mlist + ',' + 'Insto756' +  ',' + 'TPAmt'.
end.
if v-crc = 1 then v-mlist = v-mlist + ',' + 'BenAcc,BenIns,BenRNN,Benpay'.

do i = 1 to num-entries(v-mlist):
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lcpayh or lcpayh.value1 = '' then do:
        find first lckrit where lckrit.datacode = entry(i,v-mlist) no-lock no-error.
        if avail lckrit then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
            if lckrit.datacode = 'CollAcc' then v-mlist2 = v-mlist2 + "Client's Account".
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
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a Payment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.
