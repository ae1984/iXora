/* inktax.p
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
        20/12/2004 dpuchkov
 * CHANGES
        07.10.2005 dpuchkov добавил проверку на филиалы
        07/11/2008 madiyar - поиск bankt по коду txb00 для всех филиалов
        11/11/2008 madiyar - поиск bankt еще и по валюте
        13/11/2008 madiyar - перекомпиляция
        31/12/2008 alex - убрал проверку на оплату 31 декабря
        26.06.2009 galina - добавила признак ОПВ и СО в поле rcvinfo[1]
        25/03/2010 galina - поправила признак ОПВ и СО на PSJINK
        06/06/2011 evseev - переход на ИИН/БИН
        24/10/2011 evseev - сокращение бенефециара до РГКП ГЦВП.
        21/12/2011 evseev - ТЗ-929. Оплата ИР с вал. счетов
        15.06.2012 evseev - ТЗ-1397. Отправитель из s-fiozer, а не из справочника РНН.
        26.06.2012 evseev - добавил ветвление на бин
        08.02.2013 evseev - tz-1710
*/

{comm-txb.i}
{chbin.i}

def shared var      s_l_inkopl as logical. /* переменная оплаты ИР */
define     variable seltxb     as int.
seltxb = comm-cod().

def new shared var      s-remtrz like remtrz.remtrz.
def new shared var      s-jh     like jh.jh.
def new shared var      v-text   as char.
def new shared var      m_hst    as char.
def new shared var      m_copy   as char.
def new shared var      u_pid    as char.
def new shared var      m_pid    like bank.que.pid.
def shared     var      g-ofc    like ofc.ofc.
def shared     var      g-today  as date.
def shared     var      s-rmzir  as char.

def            var      ourbank  like bankl.bank.
def            var      rcode    as int.
def            var      rdes     as char.
def            var      v-bb     as char.
def            var      s-npl    as char.
def            var      s-rem    as char.
def            var      s-rsub   as char.
def            var      ii       as integer init 1.

define         variable s-vtime  as integer. /* sasco - время для сверки транспорта */

/* Входные параметры */
def input parameter s-ndoc as char.    /* Номер документа */
def input parameter s-sum as deci.    /* Сумма платежа */
def input parameter s-aaa as char.    /* Счет отправителя*/

def input parameter s-rbank as char.  /* Банк получателя */
def input parameter s-racc as char.   /* Счет получателя */
def input parameter s-kb as int.      /* КБК */
def input parameter s-bud as logical. /* Тип бюджета - проверяется если есть КБК */
def input parameter s-bn as char format "x(33)".     /* Бенефициар */
def input parameter s-bnrnn as char.  /* РНН Бенефициара */
def input parameter s-knp as char format "x(3)".  /* KNP */
def input parameter s-kod as char format "x(2)".  /* Kod */
def input parameter s-kbe as char format "x(2)".  /* Kbe */
def input parameter s-nplin as char.  /* Назначение платежа */
def input parameter s-pid as char format "x(3)". /* Код очереди */
def input parameter s-prn as integer. /* Кол-во экз. */
def input parameter s-cov as integer. /* remtrz.cover (для проверки даты валютирования
                                         т.е. 1-CLEAR00 или 2-SGROSS00) */
def input parameter s-rnn as char.    /* РНН отправителя */
def input parameter s-fiozer as char.
def input parameter s-bnbin as char.  /* БИН Бенефициара */
def input parameter s-bin as char.    /* БИН отправителя */

run savelog('inktax.p', '86. ').

if s-cov = 5 and substr(s-rbank,1,3) = "TXB"
    then s-rsub = "cif". /* Выбираем полочку для операционниста */
else s-rsub = "".

def    var      v-weekbeg as int.
def    var      v-weekend as int.
def    var      retval    as char    init ''.

define variable v-o       as logical.

m_pid = s-pid.   /* Код очереди */

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then
do:
    display " This isn't record OURBNK in sysc file !!".
    pause.
    s_l_inkopl = False.
    /*message '-11 '. pause.*/
    return retval.
end.
ourbank = trim(sysc.chval).

/*message '3'. pause.*/

run savelog('inktax.p', '120. ').
if v-bin then
do:
    find first rnn where rnn.bin = s-bin no-lock no-error.
    find first rnnu where rnnu.bin = s-bin no-lock no-error.
end.
else
do:
    find first rnn where rnn.trn = s-rnn no-lock no-error.
    find first rnnu where rnnu.trn = s-rnn no-lock no-error.
end.
/*message '4'. pause.*/

do trans:

    run n-remtrz.
    run savelog('inktax.p', '136. ' + s-remtrz).

    create remtrz.
    remtrz.remtrz = s-remtrz.

    if ourbank = "TXB00" then
    do:
        find first bankl where bankl.bank = s-rbank and bankl.nu = 'u' no-lock no-error.
        if avail bankl then remtrz.ptype = "4".
        else remtrz.ptype = "6".
    end. else
        remtrz.ptype = "4".


    assign
        remtrz.rsub   = s-rsub
        remtrz.rdt    = g-today
        remtrz.valdt1 = g-today
        remtrz.rtim   = time
        remtrz.rwho   = g-ofc
        remtrz.sbank  = ourbank
        remtrz.rbank  = s-rbank
        remtrz.sacc   = string(s-aaa,'x(20)')
        remtrz.racc   = string(s-racc,'x(20)')
        remtrz.dracc  = sacc.


    /* Получим корсчет банка */
    find first bankt where bankt.cbank = "txb00" and bankt.racc = "1" and bankt.crc = 1 no-lock no-error.
    remtrz.cracc = bankt.acc .    /*  Корсчет банка "900161014" */

    find first dfb where dfb.dfb = bankt.acc no-lock no-error.
    remtrz.crgl = dfb.gl. /* 105100 */

    find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
    /*message remtrz.sacc + " " + sacc . pause.*/
    if not avail aaa then
    do:
       find first arp where arp.arp = remtrz.sacc no-lock no-error.
       if not avail arp then
       do:
           /*message '-6 ' + retval . pause.*/
           s_l_inkopl = False.
           bell.
           undo.
           return retval.
       end.
    end.
    if available aaa then remtrz.drgl = aaa.gl.
    if available arp then remtrz.drgl = arp.gl.
    /*message '7'. pause. */
    if v-bin then remtrz.ord =  s-fiozer + " /RNN/" + s-bin. else remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.

    if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "inktax.p 183", "1", "", "").
    end.
    run savelog('inktax.p', '192. ' + s-remtrz).
    /*if v-bin then
    do:
        if s-bin = "000000000000" then
            remtrz.ord =  s-fiozer + " /RNN/" + s-bin.
        else
        do:
            if avail rnnu then remtrz.ord = caps(trim( comm.rnnu.busname )) + " /RNN/" + s-bin.
            else remtrz.ord =  s-fiozer + " /RNN/" + s-bin.
        end.
    end.
    else
    do:
        if s-rnn = "000000000000" then
            remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
        else
        do:
            if avail rnnu then remtrz.ord = caps(trim( comm.rnnu.busname )) + " /RNN/" + s-rnn.
            else
                remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
        end.
    end.*/

    remtrz.amt = s-sum.
    remtrz.payment = s-sum.
    remtrz.svca = 0.
    remtrz.svcp = 0.
    remtrz.fcrc = 1.
    remtrz.tcrc = 1.
    remtrz.cover = s-cov. /* 2.*/
    remtrz.chg = 7.
    remtrz.outcode = 6.

    run savelog('inktax.p', '225. ' + s-remtrz).
    find ofc where ofc.ofc eq g-ofc no-lock.

    remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
        + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
        fill(' ' , 12 - length(trim(remtrz.sbank))) +
        (trim(remtrz.dracc) + fill(' ' , 10 - length(trim(remtrz.dracc)))) +
        substring(string(g-today),1,2) + substring(string(g-today),4,2) +
        substring(string(g-today),7,2).
    remtrz.source = "INK".  /*m_pid + string(integer(truncate(ofc.regno / 1000 , 0)),'99').*/
    remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." +
        trim(string(s-ndoc)).
    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

    if not avail bankl then
    do:

        find first bankl where substr(bankl.bank,7,3)=remtrz.rbank no-lock no-error.
        if not avail bankl then
        do:
            run savelog('inktax.p', '245. ' + s-remtrz).
            /*message '-12 '. pause.*/
            s_l_inkopl = False.
            bell.
            undo.

            return.
        end.
    end.
    remtrz.rcbank = bankl.cbank.
    remtrz.bb[1] = bankl.name.
    remtrz.bb[2] = bankl.addr[1].
    remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
    find bankl where bankl.bank = remtrz.sbank no-lock no-error.
    if not available bankl then
    do:
        /*message '-13 '. pause.*/
        run savelog('inktax.p', '262. ' + s-remtrz).
        s_l_inkopl = False.
        bell.
        undo.

        return.
    end.
    run savelog('inktax.p', '269. ' + s-remtrz).
    remtrz.scbank = bankl.cbank.
    if ourbank = "TXB00" then
    do:
        remtrz.ordins[1] = "Зал 1".
        remtrz.ordins[2] = "Департамент 1".
        remtrz.ordins[3] = "г.Алматы".
        remtrz.ordins[4] = "KAZAKHSTAN".
    end.
    else
    do:
        remtrz.ordins[1] = bankl.name.
    end.

    remtrz.ordcst[1] = ord.

    if s-bn matches '*Республиканское государственное казенное предприятие "Госуда*' then
        remtrz.bn[1] = "РГКП ГЦВП".
    else
        remtrz.bn[1] = s-bn.
    if v-bin then remtrz.bn[3] = " /RNN/" + s-bnbin.
    else remtrz.bn[3] = " /RNN/" + s-bnrnn.
    remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].

    if s-kb = 0 then
    do:
        remtrz.rcvinfo[1] = "".
        remtrz.ba = "/" + remtrz.racc + "/".
    end.
    else
    do:
        remtrz.rcvinfo[1] = "/TAX/" .
        remtrz.ba = "/" + remtrz.racc + "/" + string(s-kb, "999999" ).
    end.
    if integer(s-knp) = 10 or integer(s-knp) = 19 or integer(s-knp) = 12 or integer(s-knp) = 17 then
    do:
        remtrz.rcvinfo[1] = "/PSJINK/".
    end.
    run savelog('inktax.p', '307. ' + s-remtrz).
    v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
    remtrz.actins[1] = "/" + substr(v-bb,1,34) .
    remtrz.actins[2] = substr(v-bb,35,35) .
    remtrz.actins[3] = substr(v-bb,70,35) .
    remtrz.actins[4] = substr(v-bb,105,35).
    remtrz.actinsact = remtrz.rbank.

    find first budcode where code = s-kb use-index code no-lock no-error .
    s-npl = trim(s-npl) + " " + s-nplin.
    remtrz.detpay[1] = substring(s-npl, 1, 35).
    remtrz.detpay[2] = substring(s-npl, 36, 35).
    remtrz.detpay[3] = substring(s-npl, 71, 35).
    remtrz.detpay[4] = substring(s-npl, 106, 35).

    s-rem = remtrz.remtrz + " " + s-npl + " " + /*arp.des*/ "".
    find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc and
        bankt.racc = "1" no-lock no-error.
    if not avail bankt then
    do:
        message "Отсутствует запись в таблице BANKT!".
        pause.
        s_l_inkopl = False.
        /*message '-14 '. pause.*/
        run savelog('inktax.p', '331. ' + s-remtrz).
        undo,return.
    end.
    /*message '8'. pause.*/
    /*--- sasco : корректировка времени по клирингу */
    s-vtime = bankt.vtime.
    if ourbank <> "TXB00" and bankt.cbank = "TXB00" then
    do:
        find sysc where sysc.sysc = "PSJTIM" no-lock no-error.
        if avail sysc then s-vtime = sysc.inval.
    end.
    /*---*/
    if remtrz.cover = 1 then
    do:
        if remtrz.valdt1 >= g-today then  remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
                                else  remtrz.valdt2 = g-today + bankt.vdate .
        if remtrz.valdt2 = g-today and
       /* здесь сверяем не с bankt.vtime, s-vtime */
            s-vtime < time then remtrz.valdt2 = remtrz.valdt2 + 1 .
    end.
    else
    do:
        if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1. else remtrz.valdt2 = g-today.
    end.

    repeat:
        find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
        if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and
            weekday(remtrz.valdt2) le v-weekend then leave.
        else remtrz.valdt2 = remtrz.valdt2 + 1.
    end.
    /*message '9'. pause.*/
    create sub-cod.
    sub-cod.acc = s-remtrz.
    sub-cod.sub = 'rmz'.
    sub-cod.d-cod = 'eknp'.
    sub-cod.ccode = 'eknp'.
    sub-cod.rcode = s-kod + ',' + s-kbe + ',' + s-knp.
    run savelog('inktax.p', '369. ' + s-remtrz).
    run rmzque.
    /*message '10'. pause.*/
    run savelog('inktax.p', '372. ' + s-remtrz).
end.
run savelog('inktax.p', '374. ' + s-remtrz).
if m_pid <> "31" then
do:
    do trans:
        /*message '11 ' + s-remtrz. pause.  */
        find first remtrz where remtrz.remtrz = s-remtrz share-lock.
        find first que of remtrz share-lock.

        s-jh = 0.
        def var dlm as char init "|".
        s-rmzir = remtrz.remtrz.
        retval = remtrz.remtrz.
        release remtrz.
        release que.
    end.
end. /* проверка на соответствие БИК */
else
do:
    v-text = remtrz.remtrz + "Несоответствие счета получателя БИКу! Перенос на 31 очередь".
    run lgps.
    retval = remtrz.remtrz.
    release remtrz.
    release que.
end.
s_l_inkopl = True.
/*message '12 ' + retval. pause.*/
run savelog('inktax.p', '400. ' + s-remtrz).
return retval.
