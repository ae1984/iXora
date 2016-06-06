/* retcor.p
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        18.12.2005 tsoy     - добавил время создания платежа.
*/

/*
   17.03.2003 nadejda - поиск РНН в cmp
*/

{lgps.i new}
def input parameter v-cacc as char.
def input parameter v-summ as deci.
def output parameter v-err as logical init false.
def output parameter v-mess as char.
def new shared var s-remtrz like remtrz.remtrz.
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var ourbank like bankl.bank.
def var clcen like bankl.bank.
def var v-bb as char.
def var s-ndoc as int.
def var swaddr as char init "KAZAKHSTAN".

m_pid = "2T".

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    v-mess = " There isn't record OURBNK in sysc file !!!".
    v-err = true.
    return.
end.
ourbank = sysc.chval.
find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    v-mess = " There isn't record OURBNK in sysc file !!!".
    v-err = true.
    return.
end.
clcen = sysc.chval.
find first arp where arp = v-cacc no-lock no-error.
if not avail arp then do:
    v-mess = " There isn't arp !!! " + v-cacc.
    v-err = true.
    return.
end.
find first banka where banka.bank = ourbank and banka.crc = arp.crc and
banka.cacc = arp.arp no-lock no-error.
if not avail banka then do:
    v-mess = " There isn't account in banka file !!! " + clcen +
    " CRC: " + string(arp.crc).
    v-err = true.
    return.
end.
find first crc where crc.crc = arp.crc no-lock no-error.
find first bankl where bankl.bank = clcen no-lock no-error.
if not avail bankl then do:
    v-mess =  " There isn't bank in bankl file !!! " + clcen.
    v-err = true.
    return.
end.
find first bankt where bankt.cbank = bankl.bank and bankt.crc = arp.crc 
no-lock no-error.
if not avail bankt then do:
    v-mess = " There isn't record in bankt file !!! ".
    v-err = true.
    return.
end.
find first dfb where dfb = bankt.acc no-lock no-error.
if not avail dfb then do:
    v-mess = " There isn't record in dfb file !!! ".
    v-err = true.
    return.
end.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
find point where point.point = 1 no-lock no-error.
find ppoint where ppoint.depart = 1 and ppoint.point = 1 no-lock no-error.                                      
find sysc where sysc.sysc = "swadd4" no-lock no-error.          
if avail sysc then swaddr = sysc.chval.

do transaction.
    find sysc where sysc.sysc = "reinfcor" exclusive-lock no-error .
    if not avail sysc then create sysc.
    if sysc.daval <> g-today then do:
        assign
        sysc = "REINFCOR"
        deval = 0
        daval = g-today.
    end.
    sysc.inval = sysc.inval + 1.
    s-ndoc = sysc.inval.
    run n-remtrz.p.
    create remtrz.
    remtrz.rtim = time.
    remtrz = s-remtrz.
    ptype = "4".
    remtrz.rdt = g-today.
    valdt1 = g-today.
    valdt2 = g-today.
    remtrz.rwho = g-ofc.
    rtim = time.
    remtrz.amt = v-summ.
    payment = v-summ.
    bb[1] = trim(bankl.name).
    bb[2] = trim(bankl.addr[1]).
    bn[1] = bankl.name.

    /* 17.03.2003 nadejda - поиск РНН в cmp */
    find first cmp no-lock no-error.
    bn[3] = '/RNN/' + trim(cmp.addr[2]).

    v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
    ord = arp.des.
    chg = 7.
    cover = 5. 
    outcode = 6.
    fcrc = arp.crc.
    tcrc = fcrc.
    sbank = ourbank.
    rbank = bankl.bank.
    sacc = banka.cacc.
    drgl = arp.gl.
    remtrz.cracc = bankt.acc.
    crgl = dfb.gl.
    dracc = sacc.
    scbank = ourbank.
    rcbank = bankl.cbank.
    rsub = "arp".
    remtrz.racc = banka.dacc.
    remtrz.ba = "/" + remtrz.racc.
    ordcst[1] = ord.
    
    remtrz.ordins[1] = point.name.                         
    remtrz.ordins[2] = ppoint.name.                        
    remtrz.ordins[3] = point.addr[1].                      
    remtrz.ordins[4] = swaddr.                         

    actins[1] = "/" + substr(v-bb,1,34) .
    actins[2] = substr(v-bb,35,35) .     
    actins[3] = substr(v-bb,70,35) .     
    actins[4] = substr(v-bb,105,35) .    
    actinsact = rbank.
    remtrz.ben[1] = bn[1] + bn[3].
    detpay[1] = "Погашение кредита".
    detpay[2] = "головному офису".
    sqn = trim(ourbank) + "." + trim(remtrz) + ".." + 
          trim(string(s-ndoc, ">>>>>>>>9" )).
    raddr = bankl.crbank.
    source = "P" + string(integer(truncate(ofc.regno / 1000 , 0)),'99').
    cwho = "".

    remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
    + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
    fill(' ' , 12 - length(trim(remtrz.sbank))) +
    (trim(remtrz.dracc) + fill(' ' , 10 - length(trim(remtrz.dracc)))) +
    substring(string(g-today),1,2) + substring(string(g-today),4,2) +
    substring(string(g-today),7,2).
    
    /* проставим ЕКНП */
    create sub-cod.          
    sub-cod.acc   = s-remtrz.
    sub-cod.sub   = 'rmz'.   
    sub-cod.d-cod = 'eknp'.  
    sub-cod.ccode = 'eknp' . 
    sub-cod.rcode = '14,14,190'. 
    
    run rmzque.
end.

v-mess = "Сформирован платеж: " + 
s-remtrz + 
". " + detpay[1] + " " + detpay[2] +
". Cумма: " + trim(string(remtrz.amt, ">>>>>>>>>>99.99")) + 
" " + crc.code + ".".

return.


