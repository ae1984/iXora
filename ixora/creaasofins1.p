/* creaasofins1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        12/05/2011 evseev - добавление в aas с занесением в aas-hist РПРО
 * BASES
        COMM TXB
 * CHANGES
        16.05.2011 evseev - исправил BASES
        17.05.2011 evseev - добавил propath v-propath
        08/06/2011 evseev - переход на ИИН/БИН
        02/05/2012 evseev - логирование значения aaa.hbal
        02/05/2012 evseev - добавил процедуру логирования proc_savelog
        21.06.2012 evseev - добавил mn.
*/

def input parameter i-ref like insin.ref no-undo.
def input parameter i-aaa like txb.aaa.aaa no-undo.
def input parameter i-regno like txb.ofc.regno no-undo.

def buffer b-insin for insin.
def buffer b-aash for txb.aas_hist.

def shared var g-today  as date.
def shared var g-ofc    like txb.ofc.ofc.

def var s-aaa like txb.aaa.aaa no-undo.
def var op_kod as char format "x(1)" no-undo.

procedure proc_savelog:
    define input parameter v-logfile as char.
    define input parameter v-mess as char.
    def var v-dbpath as char.
    find txb.sysc where txb.sysc.sysc = "stglog" no-lock no-error.
    v-dbpath = txb.sysc.chval.
    if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
    output to value(v-dbpath + v-logfile + "." + string(today, "99.99.9999" ) + ".log") append.
        put unformatted
        today " "
        string(time, "hh:mm:ss") " "
        userid("txb") format "x(8)" " "
        v-mess
        skip.
    output close.
end procedure.

{aas2his.i &db = "txb"}

def var v-propath as char no-undo.
v-propath = propath.
propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.

find first insin where insin.ref eq i-ref no-lock no-error.


if insin.stat eq 1 then do transaction on error undo, return:
   find first txb.aaa where txb.aaa.aaa eq i-aaa exclusive-lock no-error.
   find first txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
   create txb.aas.
   find last b-aash where b-aash.aaa = txb.aaa.aaa and b-aash.ln <> 7777777  use-index aaaln no-lock no-error.
   if available b-aash then txb.aas.ln = b-aash.ln + 1. else txb.aas.ln = 1.
   txb.aas.aaa = txb.aaa.aaa.
   txb.aas.regdt = g-today.
   txb.aas.docdat = insin.dtr.
   txb.aas.dpname = insin.nkrnn. /* РНН НК */
   txb.aas.nkbin = insin.nkbin. /* БИН НК */
   txb.aas.bnf = insin.nkname. /* Название НК */
   txb.aas.docnum = string(insin.numr).
   txb.aas.chkamt = 100000000000.00 . /* блокируем счет */
   if insin.type = 'AC'then  do: txb.aas.sta = 2.  txb.aas.mn = "91000". end.
   if insin.type = 'ACP'then do: txb.aas.sta = 16. txb.aas.mn = "92000". end.
   if insin.type = 'ASD'then do: txb.aas.sta = 17. txb.aas.mn = "93000". end.

    txb.aas.activ = True.
    txb.aas.contr = False.
    txb.aas.tim   = time.
    txb.aas.whn   = g-today.
    txb.aas.who   = g-ofc.
    txb.aas.sic   = 'HB'.
    s-aaa = aaa.aaa.
    if avail txb.aaa then do:
       run proc_savelog("aaahbal", "creaasofins1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(txb.aaa.hbal + txb.aas.chkamt) + " ; " + string(txb.aas.chkamt)).
       txb.aaa.hbal = txb.aaa.hbal + txb.aas.chkamt.
    end.
    find current txb.aaa no-lock.
    txb.aas.cif = txb.cif.cif.
    if insin.type = 'AC' then do:
        txb.aas.payee = 'Расп.о.приост.расх.опер.налогопл.'.
    end.
    if insin.type = 'ACP' then do:
       txb.aas.payee = 'Расп.о.приост.расх.опер.аг.ОПВ'.
    end.
    if insin.type = 'ASD' then do:
       txb.aas.payee = 'Расп.о.приост.расх.опер.плат.СО'.
    end.

    find first b-insin where b-insin.ref = insin.ref exclusive-lock no-error.
    if avail b-insin then do:
        if b-insin.mnu <>  "blk" then b-insin.mnu = "blk".
        if b-insin.blkaaa <> '' then b-insin.blkaaa = b-insin.blkaaa + ','.
        b-insin.blkaaa = b-insin.blkaaa + i-aaa.
        find current b-insin no-lock.
    end.
    else run proc_savelog("insps", "INSP_ps: [err]Статус Blk не проставился!" + " ref=" + insin.ref).

    txb.aas.point = i-regno / 1000 - 0.5.
    txb.aas.depart = i-regno MODULO 1000.
    op_kod = 'A'.
    RUN aas2his.

end. /* transaction */

propath = v-propath no-error.