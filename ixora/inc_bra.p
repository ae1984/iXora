/* inc_bra.p
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
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        18.12.2005 tsoy     - добавил время создания платежа.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

/***** inc_bra.p *****/

{mainhead.i}

define new shared variable s-remtrz like remtrz.remtrz.
define new shared variable s-remo like remtrz.remtrz.

define buffer acrc for crc.
define buffer ccrc for crc.
define buffer t-bankl for bankl.
define buffer tgl for gl.

define button but_1 label "N…KO№AIS".
define button but_2 label "IZPILD§T".

define button jh_1 label "P…RVEDUMS".
define button jh_2 label "VAUCHERS ".
define button jh_3 label " IZMEST  ".
define button jh_4 label "AKCEPTЁT ".

define shared frame f_but
    but_1 but_2 with row 3 centered no-box.

define frame jh_but
    jh_1 jh_2 jh_3 jh_4 with row 1 centered no-box overlay.

define frame fdet
    remtrz.detpay[1] label "PIEZ§MES" remtrz.detpay[2] label "PIEZ§MES"
    with centered row 17 side-labels overlay.

define new shared variable v-ock like ock.ock.
define new shared variable s-jh  like jh.jh.
define new shared variable tt1   as character format "x(60)".
define new shared variable tt2   as character format "x(60)".
define new shared variable acc   like aaa.aaa.
define new shared variable nref  like crefer.crefer.
define new shared variable tail  like jl.rem.

define variable comamt like ock.comamt.
define variable tcode  as integer.
define variable tdes   as character.
define variable quest  as logical format "J–/Nё".
define variable blname like bankl.name.
define variable i      as integer format "9".
define variable n      as integer format "9".
define variable kaskon as integer format "9".
define variable vdel   as character initial "^".
define variable vparam as character.
define variable rcode  as integer.
define variable rdes   as character.
define variable vremo  like que.remtrz.
define variable brnch  as logical initial false.
define variable clecod as character.
define variable v-weekbeg as integer.
define variable v-weekend as integer.
define variable v-ba as character.
define variable receiver as character.
define variable v-det as character.
define variable obank like sysc.chval.
define variable v-sts like jh.sts .

find sysc "WKEND" no-lock no-error.
    if available sysc then v-weekend = sysc.inval.
    else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
    if available sysc then v-weekbeg = sysc.inval.
    else v-weekbeg = 2.

find sysc where sysc.sysc eq "ourbnk" no-lock no-error.
obank = sysc.chval.

define new shared frame account
    acc       label "     KONTS#"
    crc.des   label "     VAL®TA" skip
    tt1       label "PILNAIS    "
    tt2       label "  NOSAUKUMS"
    cif.sname label "SA§SINATAIS" format "x(60)"
    cif.pss   label "IDENT.KARTE"
    cif.jss   label "REІ.NUMURS"  format "x(13)"
    with overlay row 5 side-labels centered title "  KONTA INFORM…CIJA  ".

form
    v-ock          label "OCK#  "
    ock.cheque  label "°EKA Nr." validate (ock.cheque ne "", "")
    ock.csts    label "STATUSS"
    ock.valdt   label " IZMAKS…T" skip
    ock.chdate  label "IZDOTS" validate (ock.chdate le g-today, "")
    space(35)
    ock.jh1     label " 1TRX" skip
    ock.ctype   label "°EKA TIPS         "
        validate (can-find(chtype where chtype.chtype eq ock.ctype),
        "P–rbaudiet ўeka tipu.")
    chtype.chdes   no-label
    ock.jh2     label "2TRX" skip
        space(23)
    ock.aaa     label " IZM.UZ KONTU"
        validate (can-find (aaa where aaa.aaa eq ock.aaa) or ock.aaa eq "", "")
    space(4)
    ock.jh3     label "  3TRX" skip
    ock.bn_br   label "CENTR.OF./FILI…LE "
        validate (can-find (bankl where bankl.bank eq ock.bn_br)
        and ock.bn_br begins "RKB", "")
    ock.branch  no-label format "x(24)"
    ock.jh4     label "4TRX" skip
    ock.cowner  label "IESNIEDZ  " skip
    ock.caddr   label "ADRESE    " skip
    ock.cinf    label "PASES DATI" skip
    ock.cfj     label "FIZ/JUR PERSONA"
    space(5)
    ock.cpers   label "PERS.KODS "
    ock.creg    label "REG.Nr." skip(1)
    ock.camt    label "SUMMA        " format "zzz,zzz,zzz,z99.99"
        validate (ock.camt gt 0, "P–rbaudiet summu.")
    ock.crc    label "   VAL®TA"
        validate (can-find (crc where crc.crc eq ock.crc),
        "P–rbaudiet val­tu.")
    crc.des        no-label skip
    ock.cam[4]  label "KOMISIJA     " skip
    ock.cbank   label "IZDEV. BANKA "
        validate (can-find(bankl where bankl.bank eq ock.cbank)
        or ock.cbank eq "", "")
    bankl.name     no-label skip
    ock.cwhn    label "REG.DATUMS   "
    space(7)
    ock.point   label "PUNKTS "
    space(1)
    ock.dpt     label "DEPART."
    ock.cwho    label "   PIEјЁMA" skip
    ock.sbank   label "MAKS. BANKA  "
    blname     no-label skip
    ock.crefer  label "VЁSTULES Nr. "
    ock.swhn    label "INKASO DATUMS"
        validate (ock.swhn ge g-today, "P–rbaudiet datumu.")
    ock.swho    label "IZPILD."
    with frame fchq row 4 side-labels centered.


{lgps.i new}
u_pid  = 'OCF_ps'.
m_pid = 'OCF'.

define variable acode   like crc.code.
define variable v-reg5  as char format "x(13)".
define variable bcode   like crc.code.
define variable pakal   as character.
define variable v-chg   as integer.
define variable ourbank like bankl.bank.
define variable sender  as cha.
define variable prilist as character.
{rmzx.f}

on "help" of v-ock do:
    run help-ock3.
end.

/** N…KO№AIS **/
on choose of but_1 do:
    hide frame f_but.
    disable all with frame f_but.
    {inbccc.f}
    display ock.valdt with frame fchq.
    view frame f_but.
    enable all with frame f_but.
    apply "cursor-right" to frame f_but.
end.

/** IZPILD§T **/
on choose of but_2 do:

    on end-error of frame jh_but do:
        disable all with frame jh_but.
        hide message.
        hide frame jh_but.
        enable all with frame f_but.
        find ock where ock.ock eq v-ock no-lock no-error.
        display ock.jh4 ock.aaa with frame fchq.
        pause 0.
    end.

    /** p–rvedums **/
    on choose of jh_1 do:

    find ock where ock.ock eq v-ock no-lock no-error.
    if ock.jh4 ne ? then do:
        message "P–rvedums jau izveidots. ".
        pause 3.
        hide message.
        undo, retry.
    end.
    else do transaction:
        run n-remtrz.

        create remtrz.
        remtrz.rtim = time.

        remtrz.remtrz = s-remtrz.

        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
            if not available sysc or sysc.chval = "" then do:
                display " This isn't record OURBNK in sysc file !!".
                undo, return.
            end.
        ourbank = sysc.chval.

        s-remo = s-remtrz.
        remtrz.rdt = g-today.

        do on error undo,retry:
            /*v-ref = ock.cheque.*/
            remtrz.sqn =
                trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + ock.cheque.
            remtrz.cover = 3.
        end.

        MM:
        do on error undo,retry:
            remtrz.fcrc  = ock.crc.

            find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0
                no-lock no-error.
                if not available acrc then do:
                    message "Val­tas status <> 0 " .
                    undo, retry.
                end.

            acode = acrc.code.
            remtrz.amt = round (ock.camt , acrc.decpnt).
            remtrz.payment = remtrz.amt.
            remtrz.tcrc = remtrz.fcrc.
            find crc where crc.crc = remtrz.tcrc and crc.sts = 0
                no-lock no-error.
                if not available crc then do:
                    message "Val­tas status <> 0 " .
                    undo, retry.
                end.
            bcode = crc.code.
            find ccrc where ccrc.crc = remtrz.tcrc no-lock no-error.
            remtrz.margb = 0. remtrz.margs = 0.

            if remtrz.amt = 0 then do:
                message "Summa = 0.".
                undo, retry.
            end.

            find acrc where acrc.crc = remtrz.fcrc no-lock no-error.
            find ccrc where ccrc.crc = remtrz.tcrc no-lock no-error.
            find crc  where crc.crc  = remtrz.tcrc no-lock no-error.
        end.

        remtrz.outcode = 3.
        remtrz.drgl = ock.gl.
        remtrz.dracc = ock.ock.
        remtrz.sacc = ock.ock.
        remtrz.ord = "°eka Nr." + ock.cheque + " " + ourbank.
        if remtrz.ord = ? then do:
         run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "inc_bra.p 280", "1", "", "").
        end.
        remtrz.bn[1] = ock.cowner.
        v-reg5 = trim (ock.cpers) + trim (ock.creg).
        remtrz.bn[1]  = trim(remtrz.bn[1]) + ' Re¦.' + trim(v-reg5).
        remtrz.sbank = ourbank. sender = "o".
        remtrz.scbank = ourbank.
        remtrz.detpay[1] = ' P–rvedums inkaso ўeka uz ' +
            ock.branch + '. ' + ock.ock.
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

        if ock.bn_br eq "" and not brnch then  do:
            v-text = remtrz.remtrz +
                " WARNING !!! There is not BENEFICIARY BANK CODE ! " .
            message v-text.
        end.
        else do:
            /*  known RECEIVER  */
            find first bankl where bankl.bank = ock.bn_br no-lock no-error.
                if not available bankl then do:
                    v-text = remtrz.remtrz +
                        " WARNING !!! There isn't BANKL for HOME " +
                        ock.bn_br + "  !!! , 3 bit retcode = 1 ".
                    message v-text.
                end.
                else if bankl.bank ne ourbank then do:
                    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                    bcode = crc.code.
                    find first bankt where bankt.cbank = bankl.cbank and
                        bankt.crc = remtrz.tcrc and bankt.racc = "1"
                        no-lock no-error .

                        if not available bankt then do:
                            v-text = remtrz.remtrz + " HOME " +
                                " WARNING !!! There isn't BANKT " +
                                bankl.cbank + " for CRC = " + bcode  +
                                " record !!!  ".
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
                                            " for HOME " + ock.bn_br + " !!! ".
                                        message v-text.
                                    end.
                                    else do:
                                        remtrz.crgl = dfb.gl.
                                        find tgl where tgl.gl = remtrz.crgl
                                            no-lock  no-error.
                                    end.
                            end.
                            if bankt.subl = "cif" then do:
                                find first aaa where aaa.aaa = bankt.acc
                                    no-lock no-error .
                                    if not available aaa then do:
                                        v-text = remtrz.remtrz +
                                            " WARNING !!! There isn't AAA " +
                                            bankt.acc  + " for HOME " +
                                            ock.bn_br + "  !!!  ".
                                        message v-text.
                                    end.
                                    else do:
                                        remtrz.crgl = aaa.gl.
                                        find tgl where tgl.gl = remtrz.crgl
                                            no-lock  no-error.
                                    end.
                            end.
                        end.
                    find first bankl where bankl.bank = ock.bn_br
                        no-lock no-error.
                end.     /* rbank isn't our bank  */
        end.

        remtrz.rbank = ock.bn_br.
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
            remtrz.sbank @ v-psbank remtrz.scbank remtrz.bb remtrz.remtrz
            remtrz.cover remtrz.fcrc acode remtrz.amt remtrz.payment bcode
            remtrz.tcrc remtrz.valdt2 remtrz.rcbank remtrz.rbank remtrz.scbank
            remtrz.ba remtrz.cracc remtrz.crgl gl.sub tgl.sub remtrz.ptype
            remtrz.racc remtrz.sacc remtrz.sqn remtrz.rsub
            with frame remtrz.

            /*
         display
                remtrz.jh1         detpay[]
                remtrz.jh2
                remtrz.svcrc remtrz.svccgr pakal remtrz.svca remtrz.svcaaa
                remtrz.svccgl
                remtrz.bn
                remtrz.bi
                with frame remtrz.
              */


        run rmzque .
        find first que where que.remtrz = remtrz.remtrz no-lock no-error.
            if available que then
                v-priory = entry(3 - int(que.pri / 10000 - 0.5 ), prilist).
            else
                v-priory = entry(1, prilist).
        display v-priory with frame remtrz.
        pause 0.

        find sysc where sysc.sysc eq "PSPYGL" no-lock  no-error.

        vparam = string(1) + vdel + string (remtrz.payment) + vdel + ock.ock
            + vdel + string (sysc.inval).

        update remtrz.detpay[1] remtrz.detpay[2] with frame fdet.

        quest = false.
        message "Veidot transakciju ?" update quest.
            if not quest then undo, return.

        s-jh = 0.
        run trxgen ("ock0036", vdel, vparam, output rcode,
            output rdes, input-output s-jh).

            if rcode ne 0 then do:
                message rdes.
                pause 3.
                undo, return.
            end.

        display s-jh @ remtrz.jh1 with frame remtrz.
        pause 0.

        find jh where jh.jh = s-jh exclusive-lock  no-error.
        jh.party = remtrz.remtrz + "  (" + trim(substr(remtrz.sqn, 19)) + ")".

        v-text = string(s-jh) + " 1-TRX " + remtrz.remtrz +
            " " + remtrz.dracc + " " + string(remtrz.amt) + " CRC = " +
            string(remtrz.fcrc) + " was made by " + g-ofc .
        run lgps.

        for each jl where jl.jh = s-jh exclusive-lock.
            jl.rem[1] =
                remtrz.remtrz + " " + remtrz.detpay[1] + remtrz.detpay[2].
            jl.rem[2] = substr(remtrz.ord,1,35).
            jl.rem[3] = substr(remtrz.ord,36,70).
            jl.rem[4] = substr(remtrz.ord,71).
        end.

        remtrz.jh1 = s-jh.

        ock.aaa = s-remtrz.
        ock.jh4 = s-jh.

        release ock.
        release remtrz.
        release jh.
        release jl.

        run v-rmtrzN.
        pause 0.
    end.  /* transaction */

    end.

    /** voucher **/
    on choose of jh_2 do:
        hide message.
        find ock where ock.ock eq v-ock no-lock no-error.
            if not available ock then do:
                message "OCK# neeksistё".
                pause 3.
                hide message.
                return.
            end.
            if ock.jh4 eq ? then do:
                message "Tranzakcijas nav, nav ko druk–t.".
                pause 3.
                hide message.
                return.
            end.
        s-jh = ock.jh4.

        i = 0.
        repeat while i eq 0 on endkey undo, return:
            message "Uzr–diet vauўeru skaitu:" update i.
        end.

        do transaction on error undo, retry:
            repeat while i ne 0:
                run v-rmtrzN.
                i = i - 1.
            end.
        end.
    end.

    /** izmest **/
    on choose of jh_3 do:

        find ock where ock.ock eq v-ock no-lock no-error.
            if ock.jh4 eq ? then do:
                message "Transakcija neeksistё.".
                pause 3.
                hide message.
                undo, retry.
            end.
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

        s-jh = ock.jh4.
        vremo = s-remtrz.

        DO TRANSACTION :
        find jh where jh.jh eq s-jh no-lock no-error.
            if jh.who ne g-ofc then do:
                message "T– nav j­su tranzakcija.".
                pause 3.
                hide message.
                return.
            end.

        quest = false.
        message "Dzёst tranzakciju?" update quest.
            if not quest then undo, return.

        v-sts = jh.sts.
        run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
        run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                if rcode = 50 then do:
                                   run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                                   return.
                              end.
                else undo, return.
            end.

        find ock where ock.ock eq v-ock exclusive-lock no-error.
        ock.jh4  = ?.
        ock.aaa  = "".

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
        clear frame remtrz.
        END.
    end.

    /* akcepts */
    on choose of jh_4 do:

        find ock where ock.ock eq v-ock no-lock no-error.
            if ock.aaa eq "" or substring (ock.aaa, 1, 3) ne "RMZ" then do:
                message "P–rvedums neeksistё.".
                pause 3.
                hide message.
                undo, retry.
            end.
        find que where que.remtrz eq ock.aaa no-lock no-error.
            if not available que then do:
                message "P–rvedums nav atrasts.".
                pause 3.
                hide message.
                undo, return.
            end.
            if que.pid ne m_pid then do:
                message "P–rvedums jau akceptёts.".
                pause 3.
                hide message.
                undo, return.
            end.
        find remtrz where remtrz.remtrz eq ock.aaa no-lock no-error.
            if not available remtrz then do:
                message "P–rvedums neeksistё.".
                pause 3.
                hide message.
                undo, return.
            end.
            if remtrz.jh1 eq ? then do:
                message "P–rvedumam 1 trx neeksistё.".
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

    if v-ock eq "" then undo, retry.

    find ock where ock.ock eq v-ock no-lock no-error.
        if ock.csts ne "Z" then do:
            message "IzpildЁt nedrЁkst!".
            pause 3.
            hide message.
            undo, return.
        end.
        if ock.valdt gt g-today then do:
            message "Izmaks–t tikai no " + string (ock.valdt).
            pause 3.
            hide message.
            undo, return.
        end.
        if ock.jh4 ne ? then do:
            find jh where jh.jh eq ock.jh4 no-lock no-error.
                if not (jh.party begins "RMZ") then do:
                    message "°eks jau apmaks–ts!".
                    pause 3.
                    hide message.
                    undo, return.
                end.

            s-remtrz = substring (jh.party, 1, 10).

            find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
                if not available remtrz then do:
                    message "P–rvedums nav atrasts.".
                    pause 3.
                    hide message.
                    undo, return.
                end.

            find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
                if available ptyp then display ptyp.des with frame remtrz.
            find gl where gl.gl = remtrz.drgl no-lock no-error.
            find tgl where tgl.gl = remtrz.crgl no-lock no-error.
            find crc where crc.crc = remtrz.fcrc no-lock no-error.
                if available crc then acode = crc.code.
            find crc where crc.crc = remtrz.tcrc no-lock no-error.
                if available crc then bcode = crc.code.
            find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr)
                                and tarif2.stat = 'r' no-lock no-error.
                if available tarif2 then pakal = tarif2.pakalp.
                else pakal = ' '.
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

            display remtrz.remtrz remtrz.sqn remtrz.rdt remtrz.ptype
                remtrz.cover  remtrz.sbank @ v-psbank remtrz.scbank
                remtrz.rcbank remtrz.rbank remtrz.drgl gl.sub remtrz.crgl
                tgl.sub remtrz.rsub remtrz.dracc remtrz.fcrc acode remtrz.cracc
                remtrz.tcrc bcode remtrz.valdt1 remtrz.jh1 remtrz.valdt2
                remtrz.jh2 remtrz.sacc remtrz.racc remtrz.amt remtrz.payment
                remtrz.svcrc remtrz.svccgr pakal remtrz.svca remtrz.svcaaa
                remtrz.svccgl remtrz.ord remtrz.bb remtrz.ba remtrz.bn
                remtrz.bi v-priory
                with frame remtrz.
            pause 0.
        end.


    hide frame f_but.
    disable all with frame f_but.
    enable all with frame jh_but.
    pause 0.
    view frame remtrz.
    wait-for window-close of current-window.
end.

view frame fchq.
enable all with frame f_but.
wait-for window-close of current-window.

