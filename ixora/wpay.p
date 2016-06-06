/* wpay.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
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
        BANK COMM IB
 * AUTHOR
       30/06/2010 id00004
 * CHANGES

*/

{comm-txb.i}

define shared variable s_l_inkopl as logical. /* переменная оплаты ИР */
define        variable seltxb     as integer.
seltxb = comm-cod().

define new shared variable s-remtrz like remtrz.remtrz.
define new shared variable s-jh     like jh.jh.
define new shared variable v-text   as character.
define new shared variable m_hst    as character.
define new shared variable m_copy   as character.
define new shared variable u_pid    as character.
define new shared variable m_pid    like bank.que.pid.
define shared     variable g-ofc    like ofc.ofc.
define shared     variable g-today  as date.
define shared     variable s-rmzir  as character.

define            variable ourbank  like bankl.bank.
define            variable rcode    as integer.
define            variable rdes     as character.
define            variable v-bb     as character.
define            variable s-npl    as character.
define            variable s-rem    as character.
define            variable s-rsub   as character.
define            variable ii       as integer   init 1.

define            variable s-vtime  as integer. /* sasco - время для сверки транспорта */

/* Входные параметры */
define input parameter s-ndoc as character.    /* Номер документа */
define input parameter s-sum as decimal.    /* Сумма платежа */
define input parameter s-aaa as character.    /* Счет отправителя*/

define input parameter s-rbank as character.  /* Банк получателя */
define input parameter s-racc as character.   /* Счет получателя */
define input parameter s-kb as integer.      /* КБК */
define input parameter s-bud as logical. /* Тип бюджета - проверяется если есть КБК */
define input parameter s-bn as character format "x(33)".     /* Бенефициар */
define input parameter s-bnrnn as character.  /* РНН Бенефициара */
define input parameter s-knp as character format "x(3)".  /* KNP */
define input parameter s-kod as character format "x(2)".  /* Kod */
define input parameter s-kbe as character format "x(2)".  /* Kbe */
define input parameter s-nplin as character.  /* Назначение платежа */
define input parameter s-pid as character format "x(3)". /* Код очереди */
define input parameter s-prn as integer. /* Кол-во экз. */
define input parameter s-cov as integer. /* remtrz.cover (для проверки даты валютирования
                                         т.е. 1-CLEAR00 или 2-SGROSS00) */
define input parameter s-rnn as character.    /* РНН отправителя */
define input parameter s-fiozer as character.


if s-cov = 5 and substr(s-rbank,1,3) = "TXB"
    then s-rsub = "cif". /* Выбираем полочку для операционниста */
else s-rsub = "".

define variable v-weekbeg as integer.
define variable v-weekend as integer.
define variable retval    as character init ''.

define variable v-o       as logical.

m_pid = s-pid.   /* Код очереди */

/* Проверка на БИК / счет */
/*run acc-ctr(string(integer(s-racc), "999999999"), s-rbank, output v-o).
if not v-o and SUBSTR (CAPS(s-rbank), 1, 3) <> "TXB" then do:
   message "Счет " s-racc " не соответствует БИК " s-rbank.
   m_pid = "31".
end. */

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not available sysc or sysc.chval = "" then 
do:
    display " This isn't record OURBNK in sysc file !!".
    pause.
    return retval.
end.

ourbank = trim(sysc.chval).

find first rnn where rnn.trn = s-rnn no-lock no-error.
find first rnnu where rnnu.trn = s-rnn no-lock no-error.

do transaction:
    run n-remtrz.
    create remtrz.
    remtrz.remtrz = s-remtrz.

    /*  if ourbank = "TXB00" then remtrz.ptype = "6".
                             else remtrz.ptype = "4". */

    if ourbank = "TXB00" then 
    do:
        find first bankl where bankl.bank = s-rbank and bankl.nu = 'u' no-lock no-error.
        if available bankl then remtrz.ptype = "4".
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
        remtrz.sacc   = string(s-aaa)
        remtrz.racc   = string(s-racc)
        remtrz.dracc  = sacc.


    /* Получим корсчет банка */
    find first bankt where bankt.cbank = "txb00" and bankt.racc = "1" and bankt.crc = 1 no-lock no-error.
    remtrz.cracc = bankt.acc .    /*  Корсчет банка "900161014" */

    find first dfb where dfb.dfb = bankt.acc no-lock no-error.
    remtrz.crgl = dfb.gl. /* 105100 */

    find aaa where aaa = sacc no-lock no-error.
    if not available aaa then 
    do:

        bell. 
        undo. 
        return retval. 
    end.
    remtrz.drgl = aaa.gl.


    if s-rnn = "000000000000" then  remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
    else do:
       /*  if avail rnn then remtrz.ord = caps(trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname )) + " /RNN/" + s-rnn.
          else*/
        if available rnnu then remtrz.ord = caps(trim( comm.rnnu.busname )) + " /RNN/" + s-rnn.
        else remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
    end.

    if remtrz.ord = ? then 
    do:
        run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "wpay.p 157-165", "1", "", "").
    end.

    remtrz.amt = s-sum.
    remtrz.payment = s-sum.
    remtrz.svca = 0.
    remtrz.svcp = 0.
    remtrz.fcrc = 1.
    remtrz.tcrc = 1.
    remtrz.cover = s-cov. /* 2.*/
    remtrz.chg = 7.
    remtrz.outcode = 6.


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
    if not available bankl then
        find first bankl where substr(bankl.bank,7,3)=remtrz.rbank no-lock no-error.
    if not available bankl then 
    do:

        bell. 
        undo. 
        return. 
    end.
    remtrz.rcbank = bankl.cbank.
    remtrz.bb[1] = bankl.name.
    remtrz.bb[2] = bankl.addr[1].
    remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
    find bankl where bankl.bank = remtrz.sbank no-lock no-error.
    if not available bankl then 
    do:

        bell. 
        undo. 
        return.
    end.
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
    /*  remtrz.ordins[2] = bankl.addr[1].
      remtrz.ordins[3] =  bankl.addr[2].
      remtrz.ordins[4] = bankl.addr[3]. */
    end.




    remtrz.ordcst[1] = ord.



    remtrz.bn[1] = s-bn.
    remtrz.bn[3] = " /RNN/" + s-bnrnn.
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

    v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
    remtrz.actins[1] = "/" + substr(v-bb,1,34) .
    remtrz.actins[2] = substr(v-bb,35,35) .
    remtrz.actins[3] = substr(v-bb,70,35) .
    remtrz.actins[4] = substr(v-bb,105,35).
    remtrz.actinsact = remtrz.rbank.

    find first budcode where code = s-kb use-index code no-lock no-error .
    /*
      if avail budcode and (s-aaa <> '000904883' or s-aaa <> '000904786' )
       then do:
        s-npl = budcode.name.
        if budcode.hand then s-npl = s-npl + " (" + (if s-bud then "местный" else "республиканский") + " бюджет)".
      end.
    */
    s-npl = trim(s-npl) + " " + s-nplin.
    remtrz.detpay[1] = substring(s-npl, 1, 35).
    remtrz.detpay[2] = substring(s-npl, 36, 35).
    remtrz.detpay[3] = substring(s-npl, 71, 35).
    remtrz.detpay[4] = substring(s-npl, 106, 35).

    s-rem = remtrz.remtrz + " " + s-npl + " " + /*arp.des*/ "".
    find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc and
        bankt.racc = "1" no-lock no-error.
    if not available bankt then 
    do:
        message "Отсутствует запись в таблице BANKT!".
        pause.

        undo,return.
    end.

    /*--- sasco : корректировка времени по клирингу */
    s-vtime = bankt.vtime.
    if ourbank <> "TXB00" and bankt.cbank = "TXB00" then 
    do:
        find sysc where sysc.sysc = "PSJTIM" no-lock no-error.
        if available sysc then s-vtime = sysc.inval.
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

    create sub-cod.
    sub-cod.acc = s-remtrz.
    sub-cod.sub = 'rmz'.
    sub-cod.d-cod = 'eknp'.
    sub-cod.ccode = 'eknp'.
    sub-cod.rcode = s-kod + ',' + s-kbe + ',' + s-knp.

    run rmzque.
end.

if m_pid <> "31" then 
do:
    do transaction:
        find first remtrz where remtrz.remtrz = s-remtrz share-lock.
        find first que of remtrz share-lock.

        s-jh = 0.
        define variable dlm as character init "|".
        s-rmzir = remtrz.remtrz.
        /*
             run trxgen("PSY0042", dlm, string(remtrz.amt) + dlm + s-aaa , "rmz", remtrz.remtrz, output rcode, output rdes, input-output s-jh).
               if rcode ne 0 then do:
                  v-text = " Ошибка проводки rcode = " + string(rcode) + ":" + rdes + " " + remtrz.remtrz + " " + remtrz.dracc.
                  delete remtrz.
                  message v-text. pause.
                  s_l_inkopl = False.
                  return.
               end.
               remtrz.jh1 = s-jh.
        */

        retval = remtrz.remtrz.
        release remtrz.
        release que.
    end.


/* проверка на счета для Алматы и на Уральск */
/*    if (s-aaa <> '000904883' and s-aaa <> '000904786' and (seltxb <> 0 or not s-racc matches '...080...')) and seltxb <> 2
    then run x-jlvouPl.


    find first jh where jh.jh = s-jh no-error.
    if available jh and jh.sts = 5 then do:
       for each jl of jh:
           jl.sts = 6.
           jl.teller = g-ofc.
       end.
       jh.sts = 6.
    end.
    do ii = 1 to s-prn:
       run payprn.
    end.
*/
end. /* проверка на соответствие БИК */
else 
do:
    v-text = remtrz.remtrz + "Несоответствие счета получателя БИКу! Перенос на 31 очередь".
    run lgps.
    retval = remtrz.remtrz.
    release remtrz.
    release que.
end.

return retval.
