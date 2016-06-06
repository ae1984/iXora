/* reinfcor.p
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
        18.12.2005 tsoy     - добавил время создания платежа.
        22.01.09   marina   - в названии убрала "в Астане"  
*/

/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
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

find first bankt where bankt.acc = v-cacc no-lock no-error.
if not avail bankt then do:
    v-mess = " There isn't LORO in bankt file !!! " + v-cacc.
    v-err = true.
    return.
end.
find first aaa where aaa = v-cacc no-lock no-error.
if not avail aaa then do:
    v-mess = " There isn't LORO in aaa file !!! " + v-cacc.
    v-err = true.
    return.
end.
find first crc where crc.crc = aaa.crc no-lock no-error.
find first bankl where bank = bankt.cbank no-lock no-error.
if not avail bankl then do:
    v-mess =  " There isn't bank in bankl file !!! " + bankt.cbank.
    v-err = true.
    return.
end.
find first banka where banka.bank = bankl.bank and banka.crc = aaa.crc no-lock no-error.
if not avail banka then do:
    v-mess = " There isn't account in banka file !!! " + bankl.bank + 
    " CRC: " + string(aaa.crc).
    v-err = true.
    return.
end.
find first arp where arp = banka.dacc no-lock no-error.
if not avail arp then do:
    v-mess = " There isn't account in arp file !!! " + banka.dacc.
    v-err = true.
    return.
end.
                        
find first cif where cif.cif = aaa.cif no-lock no-error.
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
    amt = v-summ.
    payment = v-summ.
    bb[1] = trim(bankl.name).
    bb[2] = trim(bankl.addr[1]).
    bn[1] = trim(trim(cif.prefix) + " " + trim(cif.name)).
    bn[3] = '/RNN/' + cif.jss.
    v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
    ord = 'Расчеты с филиалом '.
    chg = 7.
    cover = 5. 
    outcode = 6.
    fcrc = aaa.crc.
    tcrc = fcrc.
    sbank = ourbank.
    rbank = bankl.bank.
    sacc = banka.dacc.
    drgl = arp.gl.
    remtrz.cracc = v-cacc.
    crgl = aaa.gl.
    dracc = sacc.
    scbank = ourbank.
    rcbank = bankl.cbank.
    rsub = "arp".
    remtrz.racc = banka.cacc.
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
    detpay[1] = "Пополнение кор.счета филиала".
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
    sub-cod.rcode = '14,14,130'. 
    
    run rmzque.
end.

v-mess = "Сформирован платеж: " + 
s-remtrz + 
". " + detpay[1] + " " + v-cacc +
". Cумма: " + trim(string(amt, ">>>>>>>>>>99.99")) + " " + crc.code + ".".
return.

