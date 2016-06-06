/* delaasofins.p
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
        12/05/2011 evseev - удаление из aas с занесением в aas-hist отзывов РПРО
 * BASES
        COMM TXB
 * CHANGES
        16.05.2011 evseev - исправил BASES
        17.05.2011 evseev - добавил propath v-propath
        08/06/2011 evseev - переход на ИИН/БИН
        28/04/2012 evseev - логирование значения aaa.hbal
        02/05/2012 evseev - добавил процедуру логирования proc_savelog
        21.06.2012 evseev - добавил mn.
*/

def input parameter i-ref like insin.ref no-undo.

def shared var g-today  as date.
def shared var g-ofc    like txb.ofc.ofc.
def var op_kod      as char no-undo.
def var i as integer no-undo.
def var s-aaa like txb.aaa.aaa no-undo.

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

find first insin where insin.ref = i-ref no-lock no-error.
find first insrec where insrec.insref = i-ref no-lock no-error.

if  avail insin and avail insrec then

do i = 1 to num-entries(insin.blkaaa) /*transaction*/:
     find last txb.aas where txb.aas.aaa = entry(i,insin.blkaaa) and txb.aas.docnum = insin.numr exclusive-lock no-error.
     find last txb.aaa where txb.aaa.aaa = entry(i,insin.blkaaa) exclusive-lock no-error.
     if avail txb.aaa then find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
     if avail txb.aas and (avail txb.aaa and txb.aaa.sta <> 'C' and txb.aaa.sta <> 'E') and avail txb.cif then do:
        assign
        txb.aas.docnum1 = insrec.num
        txb.aas.docdat1 = insrec.dt
        txb.aas.docprim1 = "отозван".
        op_kod= 'D'.
        txb.aas.who = g-ofc.
        txb.aas.whn = g-today.
        txb.aas.tim = time.
        txb.aas.mn = substr(txb.aas.mn,1,4) + "1".
        s-aaa = txb.aaa.aaa.
        RUN aas2his.
        run proc_savelog("aaahbal", "delaasofins1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(txb.aaa.hbal - txb.aas.chkamt) + " ; " + string(txb.aas.chkamt)).
        txb.aaa.hbal = txb.aaa.hbal - txb.aas.chkamt.
        delete txb.aas.
     end.

end. /* do i */

propath = v-propath no-error.