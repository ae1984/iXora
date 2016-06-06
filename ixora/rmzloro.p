/* rmzloro.p
 * MODULE
        Название модуля
 * DESCRIPTION
        На основе rmzcre для платежей с Лоро-счета
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
        28/10/2013 galina - ТЗ1891
 * BASES
        BANK
 * CHANGES
*/

def new shared var s-remtrz like remtrz.remtrz.
def new shared var s-jh like jh.jh.
def shared var v-text as char.
def shared var m_hst as char.
def shared var m_copy as char.
def shared var u_pid as char.
def shared var m_pid like bank.que.pid.
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var ourbank like bankl.bank no-undo.
def var rcode as int no-undo.
def var rdes  as char no-undo.
def var v-bb  as char no-undo.
def var s-npl as char no-undo.
def var s-rem as char no-undo.
def var s-rsub as char no-undo.

def var s-crc as integer no-undo.
def var v-tmpl as char no-undo.
def buffer b-aaa for aaa.


/* Входные параметры */

def input parameter s-sum as deci.               /*  2 Сумма платежа */
def input parameter s-account as char.           /*  3 Счет отправителя т.е. АРП или текущий счет*/

def input parameter s-fiozer as char.            /* 18 ФИО отпр. если не найдено в базе RNN */

def input parameter s-rbank as char.             /*  4 Банк получателя */
def input parameter s-racc as char.              /*  5 Счет получателя */
def input parameter s-bn as char format "x(33)". /*  8 получатель */
def input parameter s-bnrnn as char.             /*  9 РНН получателя */

def input parameter s-knp as char format "x(3)". /* 10 KNP */
def input parameter s-kod as char format "x(2)". /* 11 Kod */
def input parameter s-kbe as char format "x(2)". /* 12 Kbe */
def input parameter s-nplin as char.             /* 13 Назначение платежа */
def input parameter s-pid as char format "x(3)". /* 14 Код очереди */
def input parameter s-cov as integer.            /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) 5 -внутр */

def input parameter s-source as char. /*источник*/
def input parameter s-trx as logi. /*создавать или не создавать проводку*/
def input parameter s-ref as int. /*референс*/
def input parameter s-countrybn as char. /*страна получателя*/
def input parameter s-sumcom as deci.
def input parameter s-codcom as char.
def input parameter s-acccom as char.
def input parameter s-gldoh as int.

define variable v-o as logical no-undo.
def var mcbank as char.
def var retval as char init "" no-undo.
def var v-bankname as char  no-undo.
def var dlm as char init "|".
def var CommStr as char no-undo.
def var vparam as char no-undo.

/* для использования BIN */
{chbin.i}

m_pid = s-pid.   /* Код очереди */

/* Проверка на БИК / счет */
if s-racc <> '' and s-rbank <> '' then do:
    run acc-ctr(s-racc, s-rbank, output v-o).
    if not v-o and SUBSTR (CAPS(s-rbank), 1, 3) <> "TXB" then do:
       message "Счет " s-racc " не соответствует БИК " s-rbank.
       m_pid = "31".
    end.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " This isn't record OURBNK in sysc file !!".
    pause.
    return retval.
end.
ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

find first aaa where aaa.aaa = s-account no-lock no-error.
if not avail aaa then do:

    display " Не найден счет " + s-account.
    pause.
    return retval.
end.

if s-rbank <> '' then do:
   find first bankl where bankl.bank = s-rbank no-lock no-error.
   if not avail bankl then do:
        display " Не найден Банк " + s-rbank.
        pause.
        return retval.
   end.
end.

do trans:
    run n-remtrz.
    create remtrz.
    remtrz.rtim = time.
    remtrz.remtrz = s-remtrz.


    if s-rbank = "TXB00" then assign remtrz.ptype = '7' s-rsub = 'valcon'.
    if s-rbank = '' then assign remtrz.ptype = 'N' s-rsub = ''.
    if s-rbank begins 'TXB' and s-rbank <> "TXB00" then assign remtrz.ptype = '4' s-rsub = 'valcon'.


    assign remtrz.rsub = s-rsub
           remtrz.rdt = g-today
           remtrz.valdt1 = g-today
           remtrz.valdt2 = g-today
           remtrz.rtim = time
           remtrz.rwho = g-ofc
           remtrz.sbank = ourbank
           remtrz.rbank = s-rbank
           remtrz.sacc = s-account
           remtrz.racc = s-racc
           remtrz.dracc = sacc
           remtrz.svccgr = int(s-codcom)
           remtrz.svca = s-sumcom
           remtrz.svcaaa = s-acccom
           remtrz.svccgl = s-gldoh.

    find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
    assign remtrz.drgl = aaa.gl
           s-crc = aaa.crc
           v-tmpl = "PSY0042". /*"PSY0042".*/

    if s-rbank <> '' then do:
        mcbank = if ourbank <> 'txb00' then 'TXB00' else s-rbank.
        find first bankt where bankt.cbank = mcbank and bankt.racc = "1" and bankt.crc = s-crc no-lock no-error.
        if avail bankt then do:
            remtrz.cracc = bankt.acc .    /*  Корсчет банка */
            if remtrz.ptype = 'N' or ourbank <> 'txb00' then do:
                find first dfb where dfb.dfb = bankt.acc no-lock no-error.
                remtrz.crgl = dfb.gl. /* 105100 */
            end.
            else do:
                find first b-aaa where b-aaa.aaa = bankt.acc no-lock no-error.
                remtrz.crgl = b-aaa.gl.
            end.
        end.
    end.


    if trim(s-fiozer) = "" then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then remtrz.ord = trim(CAPS(cif.pref  + ' ' + cif.name)).
    end.
    else remtrz.ord = s-fiozer.
    if s-racc <> '' and avail cif and trim(s-fiozer) = "" then remtrz.ord = remtrz.ord + (if v-bin = no then cif.jss else cif.bin).

    remtrz.amt = s-sum.
    remtrz.payment = s-sum.
    remtrz.svcp = 0.
    remtrz.fcrc = s-crc.
    remtrz.tcrc = s-crc.
    remtrz.cover = s-cov. /* 2.*/
    remtrz.chg = 7.
    remtrz.outcode = 3.

    find ofc where ofc.ofc eq g-ofc no-lock.
    remtrz.ref = string(s-ref).
    remtrz.source = s-source.
    remtrz.sqn = "TXB00." + trim(remtrz.remtrz) + ".." + trim(string(s-ref, ">>>>>>>>9" )).
    if s-rbank <> '' then do:
        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
        remtrz.rcbank = bankl.cbank.
        remtrz.bb[1] = bankl.name.
        remtrz.bb[2] = bankl.addr[1].
        remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
    end.

    find bankl where bankl.bank = remtrz.sbank no-lock no-error.
    remtrz.scbank = bankl.cbank.
    remtrz.ordins[1] = 'АО ' + v-bankname.
    remtrz.ordins[2] = " ".
    remtrz.ordins[3] = "".
    remtrz.ordins[4] = "".

    remtrz.ordcst[1]   =  substr(remtrz.ord,1, 35).
    remtrz.ordcst[2]   =  substr(remtrz.ord,36, 35).
    remtrz.ordcst[3]   =  substr(remtrz.ord,71, 35).
    remtrz.ordcst[4]   =  substr(remtrz.ord,106, 35).


    if s-bn <> '' and s-bnrnn <> '' then do:
        remtrz.bn[1] = s-bn.
        remtrz.bn[3] = " /RNN/" + s-bnrnn.
        remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].
    end.
    if s-racc <> '' then remtrz.ba = "/" + remtrz.racc + "/".



    if s-rbank <> '' then do:
        v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
        remtrz.actins[1] = "/" + substr(v-bb,1,34) .
        remtrz.actins[2] = substr(v-bb,35,35) .
        remtrz.actins[3] = substr(v-bb,70,35) .
        remtrz.actins[4] = substr(v-bb,105,35) .
        remtrz.actinsact = remtrz.rbank.
        remtrz.ben[1]      =  remtrz.bn[1] + remtrz.bn[3].
    end.
    assign remtrz.detpay[1]   =  substring(s-nplin, 1, 70)
           remtrz.detpay[2]   =  substring(s-nplin, 71, 70)
           remtrz.detpay[3]   =  substring(s-nplin, 141, 70)
           remtrz.detpay[4]   =  substring(s-nplin, 211, length(s-nplin))

    s-rem = remtrz.remtrz + " " + s-npl.

    create sub-cod.
           sub-cod.acc = s-remtrz.
           sub-cod.sub = "rmz".
           sub-cod.d-cod = "eknp".
           sub-cod.ccode = "eknp".
           sub-cod.rcode = s-kod + "," + s-kbe + "," + s-knp.

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
    if not available sub-cod then do:
        create sub-cod.
        sub-cod.acc = s-remtrz.
        sub-cod.sub = "rmz".
        sub-cod.d-cod = "pdoctng".
        sub-cod.ccode = "19".
    end.
    if s-countrybn <> 'msc' then do:
        create sub-cod.
        assign sub-cod.acc = s-remtrz
               sub-cod.sub = "rmz"
               sub-cod.d-cod = "iso3166"
               sub-cod.ccode = s-countrybn
               sub-cod.rcode = "".
    end.

    run rmzque.
end.

if  m_pid <> "31" then do:
    if not s-trx then retval = remtrz.remtrz.
    if s-trx then do trans:
        find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
        find first que of remtrz share-lock.

        s-jh = 0.
        run trxgen(v-tmpl, dlm, remtrz.remtrz + dlm + string(remtrz.amt) + dlm + s-account + dlm + substr(s-rem, 1, 55 ) + dlm +
                   substr(s-rem, 56, 55 ) + dlm + substr(s-rem, 111, 55 ) + dlm + substr(s-rem, 166, 55 ) + dlm + substr(s-rem, 221, 55 ),
                   "rmz", remtrz.remtrz, output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do :
            message '1 ' remtrz.amt remtrz.remtrz rcode " " rdes.
            delete remtrz.
            return.
        end.
        remtrz.jh1 = s-jh.
        retval = remtrz.remtrz.
        find current remtrz no-lock.
         release que.
        /*end.*/
        /*do transaction:*/
            find first jh where jh.jh = s-jh no-error.
            if available jh then do :
               for each jl of jh:
                  jl.sts = 0.
                  jl.teller = g-ofc.
               end.
               assign jh.sts = 0 jh.post = false.
               release jh.
            end.
        /*end.*/

    end.
    do transaction:

        find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
        if avail tarif2 then CommStr = tarif2.pakalp + ' ' + s-remtrz.
        else CommStr = remtrz.remtrz + " " + replace(trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2]) +  ' ' +  trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]) +  substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) + substr(remtrz.ord,71),"^"," ")  .
        vparam =  string(remtrz.svca)
                  + dlm + (if remtrz.svcaaa eq "" then string(remtrz.svcrc) else remtrz.svcaaa)
                  + dlm + string(remtrz.svccgl)
                  + dlm + CommStr.

        run trxgen('PSY0025',dlm,vparam,"rmz",remtrz.remtrz, output rcode, output rdes,input-output s-jh).
        if rcode > 0  then  do:
            message '2 ' remtrz.remtrz rcode " " rdes.
            return .
        end.
        find first jl where jl.jh = s-jh and jl.ln = 2 no-lock no-error.
        if avail jl then do:
            find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
            remtrz.info[10] = string(jl.gl) .
            if remtrz.info[6] matches "*payment*" then remtrz.info[6] = "TRXGEN PSY0025 payment". else remtrz.info[6] = "TRXGEN PSY0025 amt".
            release remtrz.
        end.
    end.

      /* Штампует транзакцию */
        do transaction:
            find first jh where jh.jh = s-jh no-error.
            if available jh and jh.sts = 5 then do :
               for each jl of jh:
                  jl.sts = 6.
                  jl.teller = g-ofc.
               end.
               jh.sts = 6.
            end.
        end.
        /***************/

end.
/* проверка на соответствие БИК */
if m_pid = "31" then do:
    v-text = remtrz.remtrz + "Несоответствие счета получателя БИКу! Перенос на 31 очередь".
    run lgps.
    retval = remtrz.remtrz.
    release remtrz.
    release que.
end.

return retval.
