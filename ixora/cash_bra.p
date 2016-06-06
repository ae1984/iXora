/* cash_bra.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
       18.12.2004 tsoy     - добавил время создания платежа.
       25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
       13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

/** cash_bra.p **/

{mainhead.i}

define button jh_1 label "P…RVEDUMS".
define button jh_2 label "VAUCHERS ".
define button jh_3 label " IZMEST  ".
define button jh_4 label "AKCEPTЁT ".

define buffer bcrc for crc.

define frame jh_but
    jh_1 jh_2 jh_3 jh_4 with row 1 centered no-box overlay.

define variable z_remtrz like remtrz.remtrz.
define new shared variable s-remtrz like remtrz.remtrz.
define new shared variable s-remo   like remtrz.remtrz.
define new shared variable s-jh     like jh.jh.

define buffer tgl  for gl.
define buffer acrc for crc.
define buffer ccrc for crc.
define buffer t-bankl for bankl.

define variable acode   like crc.code.
define variable v-reg5  as char format "x(13)".
define variable bcode   like crc.code.
define variable pakal   as character.
define variable v-chg   as integer.
define variable ourbank like bankl.bank.
define variable sender  as cha.
define variable prilist as character.
{zrmzx.f}

{lgps.i new}
u_pid  = 'OCF_ps'.
m_pid = 'OCF'.

define variable brnch     as logical initial false.
define variable clecod    as character.
define variable d_gl      like gl.gl.
define variable branch    like ock.bn_br.
define variable brefer    as character format "x(10)".
define variable rem_amt   like jl.dam.
define variable rem_crc   like crc.crc.
define variable v-weekbeg as integer.
define variable v-weekend as integer.
define variable receiver  as character.
define variable v-ba      as character.
define variable cheques   as integer.
define variable vdel      as character initial "^".
define variable vparam    as character.
define variable rcode     as integer.
define variable rdes      as character.
define variable foot      like jl.rem.
define variable quest     as logical format "J–/Nё".
define variable i         as integer format "9".
define variable vremo     like que.remtrz.
define variable vcrc      like crc.crc.
define variable v-sts     like jh.sts .

find sysc "WKEND" no-lock no-error.
    if available sysc then v-weekend = sysc.inval.
    else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
    if available sysc then v-weekbeg = sysc.inval.
    else v-weekbeg = 2.

define frame fbra
    branch label "    FILI…LE "
        validate ((can-find (bankl where bankl.bank eq branch) and
        branch begins "RKB"), "")
    bankl.name no-label format "x(30)" skip
    brefer label "VЁSTULES Nr." skip
    vcrc   label "VAL®TA      "  bcrc.des no-label
    with side-label row 7 col 20 no-box.

define frame fdet
    remtrz.detpay[1] label "PIEZ§MES" remtrz.detpay[2] label "PIEZ§MES"
    with centered row 17 side-labels overlay.

define temp-table bras
    field wbra  like ock.bn_br
    field wock  like ock.ock
    field wcrc  like ock.crc
    field wamt  like ock.camt.

on "help" of branch do:
    run help-bran.
end.
/** p–rvedums **/
on choose of jh_1 do:
    if rem_amt eq 0 then update z_remtrz with frame remtrz.
    else z_remtrz = "".

    IF z_remtrz eq "" then do transaction:
        if rem_amt eq 0 then do:
            message "Nav atrasts neviens neapmaks–tais ўeks.".
            undo, return.
        end.

    run n-remtrz.
    create remtrz.
    remtrz.rtim = time.
    remtrz.remtrz = s-remtrz.
    z_remtrz = s-remtrz.

    find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        if not available sysc or sysc.chval = "" then do:
            display " This isn't record OURBNK in sysc file !!".
            undo, return.
        end.
    ourbank = sysc.chval.

    s-remo = s-remtrz.
    remtrz.rdt = g-today.

    do on error undo,retry:
        remtrz.sqn =
            trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + brefer.
        remtrz.cover = 3.
    end.

    MM:
    do on error undo,retry:
        remtrz.fcrc  = rem_crc.

        find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0
            no-lock no-error.
            if not available acrc then do:
                message "Val­tas status <> 0 " .
                undo, retry.
            end.

        acode = acrc.code.
        remtrz.amt = round (rem_amt , acrc.decpnt).
        remtrz.payment = remtrz.amt.
        remtrz.tcrc = remtrz.fcrc.
        find crc where crc.crc = remtrz.tcrc and crc.sts = 0
            no-lock no-error.
            if not available crc then do:
                message "Val­tas status <> 0 " .
                undo, retry.
            end.
        bcode = crc.code.
        find ccrc where ccrc.crc = remtrz.tcrc no-lock.
        remtrz.margb = 0. remtrz.margs = 0.

        if remtrz.amt = 0 then do:
            message "Summa = 0.".
            undo, retry.
        end.

        find acrc where acrc.crc = remtrz.fcrc no-lock.
        find ccrc where ccrc.crc = remtrz.tcrc no-lock.
        find crc  where crc.crc  = remtrz.tcrc no-lock.
    end.

    find sysc where sysc.sysc eq "CHEQA" no-lock no-error.
        if not available sysc then do:
            message "<CHEQA> fail–  sysc  neeksistё.".
            undo, return.
        end.

    remtrz.outcode = 3.
    remtrz.drgl = sysc.inval.
    remtrz.dracc = "".  /*ock.ock.*/
    remtrz.sacc = "".   /*ock.ock.*/
    remtrz.ord = "Vёstules Nr." + brefer + " " + ourbank.
    if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "cash_bra.p 197", "1", "", "").
    end.

    remtrz.bn[1] = ourbank.
    v-reg5 = "".  /*trim (ock.cpers) + trim (ock.creg).*/
    remtrz.bn[1]  = trim(remtrz.bn[1]) + ' Re¦.' + trim(v-reg5).
    remtrz.sbank = ourbank. sender = "o".
    remtrz.scbank = ourbank.
    remtrz.detpay[1] = ' P–rvedums apmaks–tiem ўekiem uz ' +
        branch + '. ' + brefer.
    remtrz.valdt1 = g-today .
    remtrz.source = 'OCF'.
    remtrz.rwho  = g-ofc.
    remtrz.chg = 7.
    remtrz.bi = "non".

    find sysc where sysc.sysc = "clcen" no-lock no-error.
        if not available sysc or sysc.chval = "" then do:
            v-text = " ERROR !!! There isn't record CLCEN in sysc file !! ".
            message v-text.
            return.
        end.
    clecod = sysc.chval.

    if clecod ne ourbank then brnch = true.

    if branch eq "" and not brnch then  do:
        v-text = remtrz.remtrz +
            " WARNING !!! There is not BENEFICIARY BANK CODE ! " .
        message v-text.
    end.
    else do:
        /*  known RECEIVER  */
        find first bankl where bankl.bank = branch no-lock no-error.
            if not available bankl then do:
                v-text = remtrz.remtrz +
                    " WARNING !!! There isn't BANKL for HOME " +
                    branch + "  !!! , 3 bit retcode = 1 ".
                message v-text.
            end.
            else if bankl.bank ne ourbank then do:
                find first crc where crc.crc = remtrz.tcrc.
                bcode = crc.code.
                message bankl.bank bankl.cbank remtrz.tcrc .

                find first bankt where bankt.cbank = bankl.cbank and
                    bankt.crc = remtrz.tcrc and bankt.racc = "1"
                    no-lock no-error .

                    if not available bankt then do:
                        v-text = remtrz.remtrz + " HOME " +
                            " WARNING !!! There isn't BANKT " + bankl.cbank +
                            " for CRC = " + bcode  + " record !!!  ".
                        message v-text.
                    end.
                    else do:
                        if remtrz.valdt1 >= g-today then
                            remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
                        else
                            remtrz.valdt2 = g-today + bankt.vdate.

                        if remtrz.valdt2 = g-today and bankt.vtime < time
                            then remtrz.valdt2 = remtrz.valdt2 + 1.

                        REPEAT:
                        find hol where hol.hol eq remtrz.valdt2
                            no-lock no-error.
                            if not available hol and
                                weekday(remtrz.valdt2) ge v-weekbeg and
                                weekday(remtrz.valdt2) le v-weekend then
                                 leave.
                            else remtrz.valdt2 = remtrz.valdt2 + 1.
                        END.

                        find first t-bankl where t-bankl.bank = bankt.cbank
                            no-lock.
                        remtrz.rcbank = t-bankl.bank.

                        if t-bankl.nu = "u" then do:
                            receiver = "u".
                            remtrz.rsub = "cif".
                        end.
                        else do:
                            receiver = "n".
                            remtrz.ba = "/" +  v-ba.
                        end.

                        remtrz.rcbank = t-bankl.bank.
                        remtrz.raddr = t-bankl.crbank.
                        remtrz.cracc = bankt.acc.

                        if bankt.subl = "dfb" then do:
                            find first dfb where dfb.dfb = bankt.acc
                                no-lock no-error .
                                if not available dfb  then do:
                                    v-text = remtrz.remtrz +
                                        " WARNING !!! There isn't DFB " +
                                        bankt.acc  +
                                        " for HOME " + branch + " !!! ".
                                    message v-text.
                                end.
                                else do:
                                    remtrz.crgl = dfb.gl.
                                    find tgl where tgl.gl = remtrz.crgl no-lock.
                                end.
                        end.
                        if bankt.subl = "cif" then do:
                            find first aaa where aaa.aaa = bankt.acc
                                no-lock no-error .
                                if not available aaa then do:
                                    v-text = remtrz.remtrz +
                                        " WARNING !!! There isn't AAA " +
                                        bankt.acc  + " for HOME " +
                                        branch + "  !!!  ".
                                    message v-text.
                                end.
                                else do:
                                    remtrz.crgl = aaa.gl.
                                    find tgl where tgl.gl = remtrz.crgl no-lock.
                                end.
                        end.
                    end.

                find first bankl where bankl.bank = branch no-lock no-error.
            end.     /* rbank isn't our bank  */
        end.

    remtrz.rbank = branch.
    remtrz.racc = "".

    if remtrz.rbank = ourbank then remtrz.rcbank = ourbank.
    if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank.
    if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .

    find first bankl where bankl.bank = remtrz.scbank  no-lock no-error.
        if available bankl then
            if bankl.nu = "u" then sender = "u".
            else sender = "n".

    find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
        if available bankl then
            if bankl.nu = "u" then receiver  = "u".
            else receiver  = "n".

    if remtrz.scbank = ourbank then sender = "o".
    if remtrz.rcbank = ourbank then receiver  = "o".
    find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
        no-lock no-error.
        if available ptyp then remtrz.ptype = ptyp.ptype.
        else remtrz.ptype = "N".
            /*
        if remtrz.ptype = "4" then do:
            v-det = trim(remtrz.ba) + " " + v-det.
            remtrz.det[1] = substr(v-det,1,35).
            remtrz.det[2] = substr(v-det,36,35).
            remtrz.det[3] = substr(v-det,71,35).
            remtrz.det[4] = substr(v-det,106,35).
        end.
        else do:
            remtrz.det[1] = substr(v-det,1,35).
            remtrz.det[2] = substr(v-det,36,35).
            remtrz.det[3] = substr(v-det,71,35).
            remtrz.det[4] = substr(v-det,106,35).
        end.  */

    find bankl where bankl.bank = remtrz.sbank no-lock no-error.
        if available bankl then do:
            remtrz.ordins[1] = bankl.name.
            remtrz.ordins[2] = bankl.addr[1].
            remtrz.ordins[3] = bankl.addr[2].
            remtrz.ordins[4] = bankl.addr[3].
        end.
    find bankl where bankl.bank = remtrz.rbank no-lock no-error.
        if available bankl then do:
            remtrz.bb[1] = bankl.name.
            remtrz.bb[2] = bankl.addr[1].
            remtrz.bb[3] = bankl.addr[2].
            /*remtrz.bb[4] = bankl.addr[3].*/
        end.

    remtrz.rsub = "OCK".
    find gl where gl.gl = remtrz.drgl no-lock no-error.
    find tgl where tgl.gl = remtrz.crgl no-lock no-error.

    display remtrz.ord remtrz.drgl remtrz.dracc remtrz.valdt1 remtrz.rdt
        remtrz.sbank @ v-psbank remtrz.scbank remtrz.bb
        remtrz.cover remtrz.fcrc acode remtrz.amt remtrz.payment bcode
        remtrz.tcrc remtrz.valdt2 remtrz.rcbank remtrz.rbank remtrz.scbank
        remtrz.ba remtrz.cracc remtrz.crgl gl.sub tgl.sub remtrz.ptype
        remtrz.racc remtrz.sacc remtrz.sqn remtrz.rsub remtrz.remtrz @ z_remtrz
        with frame remtrz.

    run rmzque.
    find sysc where sysc.sysc = 'PRI_PS' no-lock no-error.
        if not available sysc or sysc.chval = '' then do:
            display ' This is not record PRI_PS in sysc file !! '.
            pause.
            undo. return.
        end.
    prilist = sysc.chval.

    find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        if available que then
            v-priory = entry(3 - int(que.pri / 10000 - 0.5 ), prilist).
        else
            v-priory = entry(1, prilist).
    display v-priory with frame remtrz.
    pause 0.

    find sysc where sysc.sysc eq "PSPYGL" no-lock.
    remtrz.info[10] = string (sysc.inval).

    foot[1] = "".
    vparam = string (cheques) + vdel.
    for each bras:
        vparam = vparam + string (bras.wamt) + vdel + bras.wock + vdel +
        string (sysc.inval) + vdel + foot[1] + vdel.
    end.

    update remtrz.detpay[1] remtrz.detpay[2] with frame fdet.

    quest = false.
    message "Veidot transakciju ?" update quest.
        if not quest then do:
            hide frame fdet.
            clear frame remtrz.
            undo, return.
        end.

    s-jh = 0.
    run trxgen ("ock0042", vdel, vparam, output rcode,
        output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message rdes.
            pause 3.
            undo, return.
        end.

    display s-jh @ remtrz.jh1 with frame remtrz.
    pause 0.

    find jh where jh.jh = s-jh exclusive-lock.
    jh.party = remtrz.remtrz + "  (" + trim(substr(remtrz.sqn, 19)) + ")".

    v-text = string(s-jh) + " 1-TRX " + remtrz.remtrz +
        " " + remtrz.dracc + " " + string(remtrz.amt) + " CRC = " +
        string(remtrz.fcrc) + " was made by " + g-ofc .
    run lgps.

    for each jl where jl.jh = s-jh exclusive-lock.
        jl.rem[1] = remtrz.remtrz + " " + remtrz.detpay[1] + remtrz.detpay[2].
        jl.rem[2] = substr(remtrz.ord,1,35).
        jl.rem[3] = substr(remtrz.ord,36,70).
        jl.rem[4] = substr(remtrz.ord,71).
    end.

    remtrz.jh1 = s-jh.

    for each bras:
        find ock where ock.ock eq bras.wock exclusive-lock.
        ock.aaa = s-remtrz.
        ock.jh1 = s-jh.
    end.
    rem_amt = 0.

    release ock.
    release remtrz.
    release jh.
    release jl.

    run v-rmtrzN.
    pause 0.
    END. /** transaction **/

    /** remittance eksistё **/
    ELSE do:
        find remtrz where remtrz.remtrz eq z_remtrz no-lock no-error.
            if not available remtrz then do:
                message "P–rvedums neeksistё.".
                pause 3.
                hide message.
                clear frame remtrz.
                undo, retry.
            end.

        find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0 no-lock no-error.
                 acode = acrc.code.
        find crc where crc.crc = remtrz.tcrc and crc.sts = 0 no-lock no-error.
        bcode = crc.code.
        find gl where gl.gl = remtrz.drgl no-lock no-error.
        find tgl where tgl.gl = remtrz.crgl no-lock no-error.

        find sysc where sysc.sysc = 'PRI_PS' no-lock no-error.
            if not available sysc or sysc.chval = '' then do:
                display ' This is not record PRI_PS in sysc file !! '.
                pause.
                undo. return.
        end.
        prilist = sysc.chval.

        find first que where que.remtrz = remtrz.remtrz no-lock no-error.
            if available que then
                v-priory = entry(3 - int(que.pri / 10000 - 0.5 ), prilist).
            else
                v-priory = entry(1, prilist).

        display remtrz.ord remtrz.drgl remtrz.dracc remtrz.valdt1 remtrz.rdt
            remtrz.sbank @ v-psbank remtrz.scbank remtrz.bb
            remtrz.cover remtrz.fcrc acode remtrz.amt remtrz.payment bcode
            remtrz.tcrc remtrz.valdt2 remtrz.rcbank remtrz.rbank remtrz.scbank
            remtrz.ba remtrz.cracc remtrz.crgl gl.sub tgl.sub remtrz.ptype
            remtrz.racc remtrz.sacc remtrz.sqn remtrz.rsub v-priory
            remtrz.jh1 z_remtrz with frame remtrz.
    END.
end.

/** vauўers **/
on choose of jh_2 do:
    if z_remtrz eq "" then do:
        message "Uzr–diet p–rvedumu.".
        pause 3.
        hide message.
        undo, retry.
    end.

    find remtrz where remtrz.remtrz eq z_remtrz no-lock no-error.
        if remtrz.jh1 eq ? then do:
            message "P–rvedumam pirm– transakcija neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.

    s-jh = remtrz.jh1.
    s-remtrz = remtrz.remtrz.
    i = 0.
    repeat while i eq 0 on endkey undo, return:
        message "Uzr–diet vauўeru skaitu:" update i.
    end.

    repeat while i ne 0:
        run v-rmtrzN.
        i = i - 1.
    end.
end.

/** izmest **/
on choose of jh_3 do:
    if z_remtrz eq "" then do:
        message "Uzr–diet p–rvedumu.".
        pause 3.
        hide message.
        undo, retry.
    end.

    find remtrz where remtrz.remtrz eq z_remtrz no-lock no-error.
        if remtrz.jh1 eq ? then do:
            message "P–rvedumam pirm– transakcija neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.

    s-jh = remtrz.jh1.
    s-remtrz = remtrz.remtrz.

    find que where que.remtrz eq s-remtrz no-lock no-error.
        if not available que then do:
            message "P–rvedums nav atrasts.".
            pause 3.
            hide message.
            undo, return.
        end.
        if not (que.con eq "W" and que.pid eq m_pid) then do:
            message "Dzёst transakciju nedrЁkst.".
            pause 3.
            hide message.
            undo, return.
        end.

    vremo = s-remtrz.

    do transaction on error undo, return:
        find jh where jh.jh eq s-jh no-lock no-error.
            if jh.who ne g-ofc then do:
                message "T– nav j­su tranzakcija.".
                pause 3.
                hide message.
                return.
            end.
        find first jl where jl.jh eq s-jh no-lock no-error.
            if jl.trx ne "ock0042" then do:
                message "Transakcija izveidota cit– re·Ёm–.".
                pause 3.
                hide message.
                undo, return.
            end.

        for each bras:
            delete bras.
        end.

        for each jl where jl.jh eq s-jh and jl.acc begins "ock" no-lock:
            create bras.
            bras.wock = jl.acc.
        end.

        quest = false.
        message "Dzёst tranzakciju?" update quest.
            if not quest then undo, return.

        v-sts = jh.sts.
        run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo,return.
            end.
        run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                if rcode = 50 then do:
                   run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                   for each bras:
            		delete bras.
                   end.
                   return.
                end.
   				else undo, return.
            end.

        for each bras:
            find ock where ock.ock eq bras.wock exclusive-lock no-error.
            ock.jh1  = ?.
            ock.csts = "A".
            ock.aaa  = "".
        end.

        find remtrz where remtrz.remtrz eq vremo exclusive-lock no-error.
            if not available remtrz then do:
                message "REMTRZ nav atrasts.".
                pause 3.
                hide message.
                undo, return.
            end.
        find que where que.remtrz eq vremo exclusive-lock no-error.
            if not available que then do:
                message "QUE nav atrasts.".
                pause 3.
                hide message.
                undo, return.
            end.

        v-text = string(s-jh) + " 1-TRX " + remtrz.remtrz +
            " " + remtrz.dracc + " " + string(remtrz.amt) + " CRC = " +
            string(remtrz.fcrc) + " was deleted by " + g-ofc .
        run lgps.

        delete remtrz.
        delete que.

        release ock.
        z_remtrz = "".
        s-jh = ?.
        clear frame remtrz.
        return.
    end.
end.

/** akceptёt **/
on choose of jh_4 do:
    if z_remtrz eq "" then do:
        message "Uzr–diet p–rvedumu.".
        pause 3.
        hide message.
        undo, retry.
    end.
    find remtrz where remtrz.remtrz eq z_remtrz no-lock no-error.
        if remtrz.jh1 eq ? then do:
            message "P–rvedumam pirm– transakcija neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.
    find que where que.remtrz eq z_remtrz no-lock no-error.
        if not available que then do:
            message "P–rvedums nav atrasts.".
            pause 3.
            hide message.
            undo, return.
        end.
        if que.pid ne m_pid then do:
            message substitute ("P–rvedumu akceptёt nedrЁkst, PID - &1 ",                 que.pid).
            pause 3.
            hide message.
            undo, return.
        end.

    quest = false.
    message "Akceptёt p–rvedumu?" update quest.
        if not quest then undo, return.

    do transaction:
        find que of remtrz exclusive-lock no-error.
        que.rcod  = '0'.
        que.con = "F".
        que.dp = today.
        que.tp = time.

        v-text =
            " Send " + remtrz.remtrz + " by route , rcod = " + que.rcod.
        run lgps.

        release que.
    end.
end.

/*z_remtrz = "".*/
update branch with frame fbra.
find bankl where bankl.bank eq branch no-lock.
display bankl.name with frame fbra.
update brefer with frame fbra.
update vcrc with frame fbra.
find bcrc where bcrc.crc eq vcrc no-lock no-error.
    if not available bcrc then do:
        message "Val­tas kods neeksistё.".
        pause 3.
        undo, retry.
    end.
display bcrc.des with frame fbra.

rem_amt = 0.
cheques = 0.
rem_crc = vcrc.

for each ock where ock.csts eq "A" and ock.in_cash eq "C" and
    ock.bn_br eq branch and ock.payee eq brefer and ock.jh1 eq ?
    and ock.crc eq vcrc no-lock:

    create bras.
    bras.wbra  = ock.bn_br.
    bras.wock  = ock.ock.
    bras.wcrc  = ock.crc.
    bras.wamt  = ock.camt.

    cheques = cheques + 1.
    rem_amt = rem_amt + ock.camt.
end.

if rem_amt eq 0 then do:
    message "Nav atrasts neviens neapmaks–tais ўeks.".
    /*undo, return.*/
end.

output to branches.
put bcrc.des skip(1).
for each bras:
    put bras.wock " " bras.wamt skip.
end.
put rem_amt skip(15).
output close.
unix silent prit branches.

view frame remtrz.
enable all with frame jh_but.
wait-for window-close of current-window.


