/* che_reg.p
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
*/

/* che_reg.p */

{mainhead.i}

define button del_1 label "P…RREGISTRЁT".
define button del_2 label "VAU°ERS".
define button del_3 label "IZMEST".

define buffer bchtype for chtype.

define new shared variable s-jh   like jh.jh.
define new shared variable s-aah  like aal.aah.
define new shared variable s-line as integer. 

define shared variable v-ock like ock.ock.
define shared variable ourbank as character.

define variable blname like bankl.name.
define variable delch  as logical format "J–/Nё".
define variable chqamt like ock.camt.
define variable comamt like ock.camt.
define variable a_nosk like jl.dam.
define variable l_nosk like jl.cam.
define variable a_conv like jl.dam.
define variable a_crc  like arp.crc.
define variable l_crc  like arp.crc.
define variable vln    as integer.
define variable tt-ock like ock.ock.
define variable tt-cty like ock.ctype.
define variable tt-inc like ock.in_cash.
define variable tt-bbr like ock.bn_br.
define variable tt-crc like ock.ccrc.
define variable tt-bnk like ock.cbank.
define variable tt-cfj like ock.cfj.
define variable tt-che like ock.cheque.
define variable tt-cda like ock.chdate.
define variable tt-own like ock.cowner.
define variable tt-add like ock.caddr.
define variable tt-inf like ock.cinf.
define variable tt-per like ock.cpers.
define variable tt-reg like ock.creg.
define variable tt-amt like ock.camt.
define variable tt-com like ock.camt.
define variable tt-sts like ock.csts.
define variable vparam as character.
define variable rcode  as integer.
define variable rdes   as character.
define variable vdel   as character initial "^".
define variable foot   like jl.rem.
define variable o_let  as character.
define variable comm   like comamt.
define variable diff_amt like comamt.

define frame f_del del_1 del_2 del_3 with row 3 centered no-box side-labels.

define shared frame fchqc 
    v-ock          label "OCK#  "
    ock.cheque  label "°EKA Nr." validate (ock.cheque ne "", "") 
    ock.csts    label " STATUSS" skip 
    ock.chdate  label "IZDOTS" validate (ock.chdate le g-today, "")
    ock.reason  label "P…RREGISTRЁTS" format "x(10)"
    space(9)
    ock.jh1     label " 1TRX" skip
    ock.ctype   label "°EKA TIPS         " 
        validate (can-find(chtype where chtype.chtype eq ock.ctype), 
        "P–rbaudiet ўeka tipu.")
    chtype.chdes   no-label 
    ock.jh2     label "2TRX" skip
        space(24)
    ock.aaa     label "IZM.UZ KONTU" 
    space(4)
    ock.jh3     label "  3TRX" skip
    ock.bn_br   label "CENTR.OF./FILI…LE " 
        validate (can-find (bankl where bankl.bank eq ock.bn_br) 
        and ock.bn_br begins "RKB", "")
    ock.branch  format "x(25)" no-label
    ock.payee label "VЁST." format "x(16)" skip
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
    with row 4 side-labels centered.


on choose of del_1 do:
    run procd_1.
end.
on choose of del_2 do:
    run procd_2.
end.
on choose of del_3 do:
    run procd_3.
end.

find ock where ock.ock eq v-ock no-lock no-error.
  
enable all with frame f_del.
wait-for window-close of current-window. 
    
procedure procd_1:
    define variable old_gl  like ock.gl.
    define variable old_crc like ock.crc.
    define variable o_ock   like ock.camt.
    define variable c_ock   like ock.camt.
    define variable dr_ock  like ock.camt.
    define variable cr_ock  like ock.camt.
    define variable o_com   like ock.comamt.
    define variable o_camt  like oc.camt.

    do transaction on error undo, retry on endkey undo, return:

        {regnew.f}

        find ofc where ofc.ofc eq g-ofc no-lock no-error.

        IF (tt-amt eq ock.camt and tt-crc eq ock.crc and tt-com eq ock.cam[4])
            or ock.bn_br ne ourbank THEN DO:
        
            ock.cheque  = tt-che.
            ock.cwho    = g-ofc.
            ock.cwhn    = g-today.
            ock.chdate  = tt-cda.
            ock.ctype   = tt-cty.
            ock.in_cash = tt-inc.
            ock.bn_br   = tt-bbr.
            ock.cfj     = tt-cfj.
            ock.cown    = tt-own.
            ock.cinf    = tt-inf.
            ock.caddr   = tt-add.
            ock.cpers   = tt-per.
            ock.creg    = tt-reg.
            ock.cbank   = tt-bnk.
            ock.point   = ofc.regno / 1000 - 0.5.
            ock.dpt     = ofc.regno MODULO 1000.
            ock.payee   = o_let.
        END.
     
        /** CITA SUMMA, KOMISIJA VAI VAL®TA **/
        ELSE DO:

        old_gl  = ock.gl.
        old_crc = ock.crc.
        o_ock   = ock.camt - ock.cam[4].
        o_com   = ock.cam[4].
        o_let   = ock.payee.
        o_camt  = ock.camt.

        find sysc where sysc.sysc eq "CHEQA" no-lock no-error.
        find gl where gl.gl eq sysc.inval no-lock no-error.
        find nmbr where nmbr.code eq gl.code exclusive-lock.
        tt-ock = nmbr.prefix + string (nmbr.nmbr, "9999999").
        nmbr.nmbr = nmbr.nmbr + 1.
        release nmbr.

        create ock.
        ock.ock     = tt-ock.
        ock.gl      = old_gl.
        ock.cheque  = tt-che.
        ock.cwho    = g-ofc.
        ock.cwhn    = g-today.
        ock.chdate  = tt-cda.
        ock.ctype   = tt-cty.
        ock.in_cash = tt-inc.
        ock.bn_br   = tt-bbr.
        ock.cfj     = tt-cfj.
        ock.cown    = tt-own.
        ock.cinf    = tt-inf.
        ock.caddr   = tt-add.
        ock.cpers   = tt-per.
        ock.creg    = tt-reg.
        ock.cbank   = tt-bnk.
        ock.camt    = tt-amt.
        ock.crc     = tt-crc.
        ock.csts    = "R".
        ock.point   = ofc.regno / 1000 - 0.5.
        ock.dpt     = ofc.regno MODULO 1000.
        ock.payee   = o_let.

        if tt-com ne ock.cam[4] then do:
            comamt = tt-com.
            chqamt = ock.camt - comamt.
        end.
        else do:
            run cash_com (input ock.ctype, input ock.camt, input ock.crc,
                input "r", input 0, output chqamt, output comamt).

                if chqamt eq 0 and comamt eq 0 then undo, return.
        end.

        comm = comamt.

        message "Komisijas summa :" update comamt.
        chqamt = chqamt + (comm - comamt).

            if chqamt lt 0 then do:
                message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
                pause 3.
                undo, return.
            end.
    
        if o_camt ne ock.camt or old_crc ne ock.crc or o_com ne comamt then do:
            delch = false.
            message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju?"
                update delch.

                if not delch then undo, return.
        end.

        release ock.

        find ock where ock.ock eq tt-ock no-lock no-error.

        if old_crc eq ock.crc then do:
        
            find crc where crc.crc eq ock.crc no-lock no-error.
            foot[1] = "Anulёt– ўeka Nr." + v-ock + " P–rreg. ўeka Nr." + 
                tt-ock.  
            if minimum (o_ock, ock.camt - comamt) eq o_ock then
                foot[2] = "Cekam nav samaks–ts " +
                    string ((ock.camt - comamt) - o_ock) + " " + crc.code.
            else if maximum (o_ock, ock.camt - comamt) eq o_ock then
                foot[2] = "Cekam ir p–rmaks–ts " +
                    string (o_ock - (ock.camt - comamt)) + " " + crc.code.
            
            vparam =
                string (o_ock) + vdel + v-ock + vdel + foot[1] + vdel + foot[2]
                + vdel + string (o_com) + vdel + foot[1] + vdel + foot[2] +
                vdel + string (ock.camt - comamt) + vdel + ock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel + string (comamt) + vdel +
                foot[1] + vdel + foot[2] + vdel + string (minimum (o_ock,
                ock.camt - comamt)) + vdel + foot[1] + vdel + foot[2].

            s-jh = 0.
            run trxgen ("ock0006", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
        end.  
        else if old_crc ne ock.crc then do:
            find crc where crc.crc eq old_crc no-lock no-error.
            c_ock = o_ock * crc.rate[1] / crc.rate[9].
            find crc where crc.crc eq ock.crc no-lock no-error.
            c_ock = c_ock / crc.rate[1] * crc.rate[9].

            /* izmaks–ts maz–k */
            if c_ock le ock.camt - comamt then do:
                cr_ock = o_ock.
                dr_ock = c_ock.
                foot[2] = "Cekam nav samaks–ts " +
                    string ((ock.camt - comamt) - c_ock) + " " + crc.code.
            end.
            /* izmaks–ts vair–k */
            else do:
                diff_amt = c_ock - (ock.camt - comamt).
                find crc where crc.crc eq ock.crc no-lock no-error.
                c_ock = (ock.camt - comamt) * crc.rate[1] / crc.rate[9].
                diff_amt = diff_amt * crc.rate[1] / crc.rate[9].
                find crc where crc.crc eq old_crc no-lock no-error.
                c_ock = c_ock / crc.rate[1] * crc.rate[9].
                diff_amt = diff_amt / crc.rate[1] * crc.rate[9].
                cr_ock = c_ock.
                dr_ock = ock.camt - comamt.
                foot[2] = "Cekam ir p–rmaks–ts " +
                    string (diff_amt, "zzz9.99") + " " + crc.code.
            end.

            foot[1] = "Anulёt– ўeka Nr." + v-ock + " P–rreg. ўeka Nr." + 
                tt-ock.  

            vparam =
                string (o_ock) + vdel + v-ock + vdel +
                foot[1] + vdel + foot[2] + vdel + string (o_com) +
                vdel + foot[1] + vdel + foot[2] + vdel +
                string (ock.camt - comamt) + vdel + ock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel + string (comamt) + vdel +
                foot[1] + vdel + foot[2] + vdel +
                string (cr_ock) + vdel + foot[1] + vdel + foot[2] + vdel +
                string (dr_ock) + vdel + foot[1] + vdel + foot[2].

            s-jh = 0.
            run trxgen ("ock0015", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
        end.

        /* new ock */
        find ock where ock.ock eq tt-ock exclusive-lock no-error.
        ock.jh1    = s-jh.
        ock.csts   = "C".
        ock.reason = v-ock.
        display ock.ock @ v-ock ock.csts ock.jh1 ock.cam[4] ock.reason
            with frame fchqc.

        release ock.

        /* anulёtajs ўeks */
        find ock where ock.ock eq v-ock exclusive-lock no-error.
        ock.csts   = "L".
        ock.jh2    = s-jh.
        ock.reason = tt-ock.

        release ock.

        v-ock = tt-ock.

        run x-jlvo.
        END.
    end.  /** transaction **/
end.

/** VOUCHER **/
procedure procd_2:
    define variable i as integer format "9".

    find ock where ock.ock eq v-ock no-lock no-error.
    s-jh = ock.jh2.
        if s-jh eq ? then do:
            message "Tranzakcija neeksistё!".
            pause 3.
            hide message.
            return.
        end.

    message "Uzr–diet vauўeru skaitu: " update i.
        if i eq 0 then undo, retry.

    repeat while i ne 0:
        run x-jlvo.
        i = i - 1.
    end.
    return.
end.

/** DELETE  **/
procedure procd_3:
    
    define variable d_ock like ock.ock.

    DO transaction:

    find ock where ock.ock eq v-ock exclusive-lock no-error.
    s-jh = ock.jh2.
        if s-jh eq ? then do:
            message "Tranzakcija neeksistё!".
            pause 3.
            hide message.
            return.
        end.

    /*
    find jh where jh.jh eq s-jh no-lock no-error.
        if jh.sts eq 6 then do:
            message "Tranzakcijas statuss - 6. Dzёst nedrЁkst!".
            pause 3.
            hide message.
            return.
        end.*/

    delch = false.
    message "Dzёst tranzakciju?" update delch.
        if not delch then undo, return.
                
    run trxsts (input s-jh, input 0, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            return.
        end.    
    run trxdel (input s-jh, input true, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            return.
        end.
        else do:
            d_ock = substring (ock.reason, 1, 10).
            find ock where ock.ock eq d_ock exclusive-lock.         
            delete ock.

            find ock where ock.ock eq v-ock exclusive-lock.
            ock.jh2    = ?.
            ock.csts   = "C".
            ock.reason = "".

            release ock.
        end.
    
    find ock where ock.ock eq v-ock no-lock no-error.
    {chdis.f}
    return.
    END.
end.
