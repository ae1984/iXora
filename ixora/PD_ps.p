/* PD_ps.p
 * MODULE
        Название Программного Модуля
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{global.i}
{lgps.i }
def new shared var s-remtrz like remtrz.remtrz.

def var v-rez as logical.

def var exitcod as cha .
def var ibhost as cha.
def var v-sqn as cha .
def var buf as cha .
def buffer our for sysc .
def new shared stream m-doc.
def var brnch as log initial false .
def shared var n-list as int .

def var vdatu as char format "x(13)".
def var i as int.
def var j as int.
def var ij as int.
def var v-mudate as char format "x(20)".  /* v-valdt ? */
def var v-ref  as char format "x(12)".
def var v-m1 as char format "x(32)".  /* v-ord */
def var v-m2 as char format "x(43)".  /* v-ord */
def var v-m3 as char format "x(43)".  /* v-ord */
def var v-bm1 as char format "x(28)". /* v-ordins */
def var v-bm2 as char format "x(43)". /* v-ordins */
def var v-bm3 as char format "x(43)". /* v-ordins */
def var v-bbbb as char format "x(43)".
def var v-crccode like crc.code.
def var v-km as char format "x(15)".
def var v-km1 as char format "x(15)".  /* номер счета плательщика */
def var v-kbm as char format "x(9)".  /* код банка плательщика */
def var v-sm as char format "x(16)".  /* v-payment */
def var v-s1 as char format "x(33)".  /* v-bn */
def var v-s2 as char format "x(43)".  /* v-bn */
def var v-s3 as char format "x(43)".  /* v-bn */
def var v-bs1 as char format "x(28)".  /* v-bb */
def var v-bs2 as char format "x(43)".  /* v-bb */
def var v-bs3 as char format "x(43)".  /* v-bb */
def var v-ks as char format "x(15)".   /* v-ba */
def var v-ks1 as char format "x(15)".  /* v-ba */
def var v-ks3 as  char  format "x(15)".
def var v-kbs as char format "x(9)".   /* v-bb */
def var v-strtmp as char.
def var v-detpay like remtrz.detpay.
def var v-sumt as char extent 6 format "x(56)".
def var v-numurs as char format "x(19)".
def var ourbcode like sysc.chval.
def var ourbank like sysc.chval.
def var v-tt like sbank.bic.


find first sysc where sysc.sysc = "PR-DIR" no-lock no-error.

if not avail sysc then do:
    v-text = " Записи PR-DIR нет в файле sysc  ".
    run lgps.
    return.
end.

do transaction:
    find first que where que.pid = m_pid and que.con = "W" use-index fprc exclusive-lock no-error.
    if avail que then do:
        que.dw = today.
        que.tw = time.
        que.con = "P".

        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
        s-remtrz = remtrz.remtrz.

        v-text = " BEGIN PD " + s-remtrz.
        run lgps.

        /*  Beginning of main program body */
        if search ( sysc.chval + "/PDPR.log" ) <> ( sysc.chval + "/PDPR.log" ) then do:
            output stream m-doc to value(sysc.chval + "/PDPR.log").
            put stream m-doc unformatted chr(27) + "(1L" +  chr(27) + "(s0p12.00h10.0v0s0b0T" + chr(12).
            n-list = 1.
        end.
        else output stream m-doc to value(sysc.chval + "/PDPR.log") append.

        find jh where jh.jh = remtrz.jh2 no-lock no-error.
        if not available jh then do:
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.rcod = "1".
            v-text = "Нет 2 проводки для платежа " + remtrz.remtrz.
            run lgps.
            return.
        end.

        find sysc where sysc.sysc = "CLECOD" no-lock no-error.
        if not avail sysc then do:
            message  " Записи CLECOD нет в файле sysc  ".
            pause.
            return.
        end.
        ourbcode = trim(sysc.chval).

        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        if not avail sysc or sysc.chval = "" then do:
            message " Записи OURBNK нет в файле sysc  !! ".
            pause.
            return.
        end.
        ourbank = sysc.chval.

        find sysc where sysc.sysc = "clcen" no-lock no-error.
        if avail sysc and trim(sysc.chval) ne trim(ourbank) then brnch = true.

        find first remtrz where remtrz.remtrz = s-remtrz no-lock.
        run stampdatr(output vdatu).
        find crc where crc.crc = remtrz.tcrc no-lock.

        v-mudate = string(remtrz.valdt1).

        v-ref = remtrz.remtrz.
        v-numurs = trim(substring(remtrz.sqn,19)).
        if v-numurs <> ' ' then v-ref = '(' + v-ref + ')'.
        else do:
            v-numurs = v-ref.
            v-ref = ''.
        end.
        v-numurs = "Nr." + v-numurs.

        v-m1 = trim(remtrz.ord).
        v-m2 = v-m1.
        v-m1 = substring(v-m1,1,32).
        i = r-index(v-m1," ").
        if i <> 0 then do:
            v-m1 = substring(v-m1,1,i - 1).
            v-m2 = substring(v-m2,i + 1).
        end.
        else v-m2 = substring(v-m2,33).

        v-m3 = v-m2.
        v-m2 = substring(v-m2,1,43).
        i = r-index(v-m2," ").
        if i <> 0 then do:
            v-m2 = substring(v-m2,1,i - 1).
            v-m3 = substring(v-m3,i + 1).
        end.
        else v-m3 = substring(v-m3,77).

        if remtrz.sbank = ourbcode then do:
            find first cmp no-lock no-error.
            v-bm1 = trim(cmp.name).
            v-bm2 = trim(cmp.addr[1]) + ' ' + trim(cmp.addr[2]).
            if remtrz.sbank <> ourbank then do:
                find bankl where bankl.bank = remtrz.sbank no-lock no-error.
                if avail bankl then v-bm3 = trim(bankl.name).
            end.
        end.
        else do:
            find bankl where bankl.bank = remtrz.sbank no-lock no-error.
            v-bm1 = bankl.name.
            v-bm2 = trim(bankl.addr[1]) + " " + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
        end.
        if remtrz.sbank begins "RKB" then v-kbm = ourbcode.
        else v-kbm = remtrz.sbank.
        v-crccode = crc.code.

        if remtrz.sacc <> "" then v-km = trim(remtrz.sacc).
        else v-km = trim(remtrz.dracc).
        v-km1 = v-km.
        if index(v-km1,"/") <> 0 then do:
            v-km = entry(1,v-km,"/").
            v-km1 = entry(2,v-km1,"/").
        end.
        else do:
            if index(v-km1," ") <> 0 then do:
                v-km  = entry(1,v-km," ").
                v-km1 = entry(2,v-km1," ").
            end.
            else do:
                if length(v-km1) > 15 then do:
                    v-km1 = substr(v-km1,16,15).
                    v-km  = substr(v-km,1,15).
                end.
                else v-km1 = " ".
            end.
        end.

        v-sm = string(remtrz.payment,">>>>>>>>>>>>9.99").
        v-s1 = remtrz.bn[1] + " " + remtrz.bn[2] + " " + remtrz.bn[3] + " ".
        v-s2 = v-s1.
        v-s1 = substring(v-s1,1,34).
        i = r-index(v-s1," ").
        if i <> 0 then do:
            v-s1 = substring(v-s1,1,i - 1).
            v-s2 = substring(v-s2,i + 1).
        end.
        else v-s2 = substring(v-s2,34,43).

        v-s3 = v-s2.
        v-s2 = substring(v-s2,1,43).
        i = r-index(v-s2," ").
        if i <> 0 then do:
            v-s2 = substring(v-s2,1,i - 1).
            v-s3 = substring(v-s3,i + 1).
        end.
        else v-s3 = substring(v-s3,78).

        if remtrz.rbank = ourbcode or remtrz.rbank begins "RKB" then v-kbs = ourbcode.
        else do:
            if remtrz.rbank begins "310101" then v-kbs = remtrz.rbank.
            else v-kbs = "310101" + trim(remtrz.rbank).
        end.

        find bankl where bankl.bank = remtrz.rbank no-lock no-error.

        if available bankl then do:
            if remtrz.bb[1] begins v-kbs then v-bs1 = substr(remtrz.bb[1],length(v-kbs) + 1) + " " + remtrz.bb[2] + " " + remtrz.bb[3] .
            else v-bs1 = remtrz.bb[1] + " " + remtrz.bb[2] + " " + remtrz.bb[3].
        end.
        else v-bs1 = substr(remtrz.actins[1],2) + " " + remtrz.actins[2] + " " + remtrz.actins[3] + " " + remtrz.actins[4] + " ".

        v-bs2 = v-bs1.
        v-bs1 = substring(v-bs1,1,29).
        i = r-index(v-bs1," ").
        if i <> 0 then do:
            v-bs1 = substring(v-bs1,1,i - 1).
            v-bs2 = substring(v-bs2,i + 1).
        end.
        else v-bs2 = substring(v-bs2,29,43).
        v-bs3 = v-bs2.
        v-bs2 = substring(v-bs2,1,43).
        i = r-index(v-bs2," ").
        if i <> 0 then do:
            v-bs2 = substring(v-bs2,1,i - 1).
            v-bs3 = substring(v-bs3,i + 1).
        end.
        else v-bs3 = substring(v-bs3,73).
        if substr(remtrz.ba,1,1) = "/" then v-ks = trim(substr(remtrz.ba,2)).
        else v-ks = trim(remtrz.ba).

        v-ks1 = v-ks.
        if index(v-ks1,"/") <> 0 then do:
            v-ks = substring(v-ks,1,index(v-ks,"/") - 1).
            v-ks1 = substring(v-ks1,index(v-ks1,"/") + 1).
            if index (v-ks1,"/") <> 0 then do:
                v-ks3 = v-ks1.
                v-ks1 = substr(v-ks1,1,index(v-ks1,"/") - 1).
                v-ks3 = substr(v-ks3,index(v-ks3,"/") +  1).
            end.
        end.
        else do:
            if index(v-ks1," ") <> 0 then do:
                v-ks = substring(v-ks,1,index(v-ks," ") - 1).
                v-ks1 = substring(v-ks1,index(v-ks1," ") + 1).
                if index(v-ks1," ") <> 0 then do:
                    v-ks3 = v-ks1.
                    v-ks1 = substr(v-ks1,1,index(v-ks1," ") - 1).
                    v-ks3 = substr(v-ks3,index(v-ks3," ") +  1).
                end.
            end.
            else do:
                if length(v-ks1) > 15 then do:
                    v-ks3 = substr(v-ks,31,15).
                    v-ks1 = substr(v-ks,16,15).
                    v-ks = substr(v-ks,1,15).
                end.
                else v-ks1 = " ".
            end.
        end.

        run Sm-vrd(input truncate(remtrz.payment,0),output v-strtmp).
        v-strtmp = v-strtmp + " " + substring(v-crccode,1,3) + string(remtrz.payment - truncate(remtrz.payment,0),".99") + ".".

        i = 1.
        v-sumt[1] = "" .
        j = 4.
        repeat while i <= 2:
            ij = index(v-strtmp," ").
            if ij = 0 then ij = length(v-strtmp).
            if j + ij > 56 then do:
                i = i + 1.
                j = 0.
            end.
            v-sumt[i] = v-sumt[i] + substring(v-strtmp,1,ij).
            j = j + ij.
            v-strtmp = substring(v-strtmp,ij + 1).
            if length(v-strtmp) = 0 then leave.
        end.

        v-detpay[1] = remtrz.detpay[1].
        v-detpay[2] = remtrz.detpay[2].
        v-detpay[3] = remtrz.detpay[3].
        v-detpay[4] = remtrz.detpay[4].

        {pmujps11.f}
        pause 0.

        /*  End of program body */
        que.dp = today.
        que.tp = time.
        que.con = "F".
        que.rcod = "0".
        v-text = " Платежный документ сформирован для платежа " + remtrz.remtrz.
        run lgps.
        put stream m-doc unformatted "CRD-5".
        output stream m-doc close.
    end. /* if avail que */
end. /* transaction */

