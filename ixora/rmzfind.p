/* rmzfind.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        TXB COMM
 * AUTHOR
        29/04/2011 id00004
 * CHANGES
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода. Добавлена GetRnnRmz.i.
*/
def input parameter premtrz as char no-undo.

def var i as inte.
def var v-payer_bic as char.
def var v-payer_code as char.
def var v-rcpnt_code as char.
def var v-payer_bank_name as char.
def var v-rspnt_name as char.
def var v-rspnt_rnn as char.
def var v-bbbb as char.
def var v-rcpnt_account as char.
def var rcpnt_bank_name as char.
def var v-bs2 as char.
def var rcpnt_bank_bic as char.
def var v-payer_rnn as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-bn as char.
def var v-ordcust as char.
def var s-jh as inte.
def var aaa as char.
def var v-code as char.
def var namebank as char.
def var rnn as char.
def var v-bnkbin as char.
def var v-bnkrnn as char.
def var v-ccode as char.

find first txb.jl no-lock no-error.

{replacebnk.i}
{nbankBik-txb.i}
{iovypshared.i}
{chbin_txb.i}
{iovypfunc_txb.i}
{GetRnnRmz.i}

find first txb.cmp no-lock no-error.
find last txb.remtrz where txb.remtrz.remtrz = premtrz no-lock no-error.
if avail txb.remtrz then do:
    v-KOd = "". v-KBe = "". v-KNP = "". v-payer_bank_name = "". v-rspnt_name = "". v-rspnt_rnn = "". v-payer_rnn = "".

    run Get_EKNP("rmz",txb.remtrz.remtrz,"eknp",output v-KOd,output v-KBe,output v-KNP).
    v-payer_code = v-KOd.
    v-rcpnt_code = v-KBe.
    v-payer_bic = GetBicBnk(trim(txb.remtrz.sbank)).
    rcpnt_bank_bic = GetBicBnk(trim(txb.remtrz.rbank)).

    if txb.remtrz.ptype eq "6" then v-payer_bank_name = trim(txb.cmp.name) + ' ' + trim(txb.cmp.addr[1]).
    else do.
        do i = 1 to 4:
            v-bbbb = trim(txb.remtrz.ordins[i]).
            v-payer_bank_name = v-payer_bank_name + if length(v-bbbb) = 35 then v-bbbb else v-bbbb + ' '.
        end.
    end.
    v-bn = trim(txb.remtrz.bn[1] + txb.remtrz.bn[2] + txb.remtrz.bn[3]).
    v-ordcust = trim(txb.remtrz.ord).

    v-rspnt_name = GetNameBenOrd(v-bn).
    v-rspnt_rnn = GetRnnBenOrd(v-bn).
    v-payer_rnn = GetRnnBenOrd(v-ordcust).

    if substr(trim(txb.remtrz.ba),1,1) = '/' then v-rcpnt_account = trim(substr(trim(txb.remtrz.ba),2,length(trim(txb.remtrz.ba)))).
    else v-rcpnt_account = trim(txb.remtrz.ba).

    v-bs2 = ''.
    do i = 1 to 3:
        v-bbbb = trim(txb.remtrz.bb[i]).
        v-bbbb = if substring( v-bbbb, 1, 1 ) = '/' then substring(v-bbbb, 2 ) else v-bbbb.
        v-bs2  = v-bs2 + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + ' '.
    end.
    run stl( v-bs2,1,55,' ',output rcpnt_bank_name,output i).

    create t-payment.
    t-payment.num_doc = string(trim(substr(txb.remtrz.sqn,19,8))).
    t-payment.date_doc = txb.remtrz.valdt1.
    t-payment.payer_name = trim(substr(txb.remtrz.ord,1,i - 1)).
    t-payment.payer_rnn = v-payer_rnn.
    t-payment.payer_account = trim(if txb.remtrz.sacc <> '' then txb.remtrz.sacc else txb.remtrz.dracc).
    t-payment.payer_code = v-payer_code.
    t-payment.amount = trim(string(txb.remtrz.payment,">>>>>>>>>>>9.99")) .
    t-payment.value_date = txb.remtrz.valdt1.
    t-payment.payer_bank_bic =  v-payer_bic.
    t-payment.payer_bank_name = v-payer_bank_name.
    t-payment.rcpnt_name =  v-rspnt_name.
    t-payment.rcpnt_rnn = v-rspnt_rnn.
    t-payment.rcpnt_account = v-rcpnt_account.
    t-payment.rcpnt_code = v-rcpnt_code.
    t-payment.rcpnt_bank_name = rcpnt_bank_name.
    t-payment.rcpnt_bank_bic = rcpnt_bank_bic.
    t-payment.payments_details = txb.remtrz.det[1] + txb.remtrz.det[2] + txb.remtrz.det[3] + txb.remtrz.det[4].
    t-payment.destination_code = v-KNP.
end.
