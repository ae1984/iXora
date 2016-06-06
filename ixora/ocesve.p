/* ocesve.p
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
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

/** ocesve.p **/

{mainhead.i}

define button but_1 label "N…KO№AIS".
define button but_2 label "LABO№ANA".
define button but_3 label "VAU°ERS".
define button but_4 label "IZMEST".

define frame f_but but_1 but_2 but_3 but_4
    with row 3 centered no-box side-labels.

define buffer bock for ock.
define buffer bcrefer for crefer.

define new shared variable s-jh   like jh.jh.
define new shared variable v-ock like ock.ock.
define new shared variable tt-ock like ock.ock.

define variable blname like bankl.name.
define variable vparam as character.
define variable rcode  as integer.
define variable rdes   as character.
define variable vdel   as character initial "^".
define variable tt-amt like ock.camt.
define variable tt-crc like ock.crc.
define variable ask    as logical format "J–/Nё".
define variable foot   like jl.rem.
define variable conv   as logical.
define variable delock like ock.ock.
define variable v-dex  as integer.
define variable t-crc  like crc.crc.
define variable i      as integer format "9".
define variable diff_amt like ock.camt.
define variable v-sts like jh.sts .

define frame fchqc 
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
    ock.branch  format "x(24)" no-label
    ock.jh4     label "4TRX" skip
    ock.cowner  label "IESNIEDZ  " format "x(41)"
    ock.payee label "VЁST." format "x(16)" skip
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
        validate (ock.cbank ne "", "")
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

on help of v-ock in frame fchqc do:
    run help-ock6.
end.
        
on choose of but_1 do:
    v-ock = "".
    clear frame fchqc.
    update v-ock with frame fchqc.
    find ock where ock.ock eq v-ock no-lock no-error.
    {chdis.f} 
    display ock.jh4 with frame fchqc.
    if not (ock.csts eq "Q" or ock.csts eq "L") then do:
        message substitute ("°eku ar statusu &1 Ѕaj– re·Ёm– apstr–d–t nedrЁkst"
        , ock.csts).
        undo, retry.
    end.
    
    if ock.csts eq "Q" then s-jh = ?.
    else if ock.csts eq "L" then s-jh = ock.jh4.
end.
on choose of but_2 do:
    do transaction:
    find ock where ock.ock eq v-ock exclusive-lock no-error no-wait.
        if locked ock then do:
            message "°eks ir aiz‡emts.".
            pause 3.
            hide message.
            undo, retry.
        end.
        if not available ock then do:
            message "°eks neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.    
        if ock.csts ne "Q" then do:
            message "Labot nedrЁkst.".
            pause 3.
            hide message.
            undo, retry.
        end.    
    
    prompt-for ock.camt with frame fchqc.
    tt-amt = input frame fchqc ock.camt.
    prompt-for ock.crc with frame fchqc.
    tt-crc = input frame fchqc ock.crc.
    
        if ock.camt eq tt-amt and ock.crc eq tt-crc then undo, return.
    find crc where crc.crc eq tt-crc no-lock no-error.
    display crc.des with frame fchqc.

    if ock.in_cash eq "C" then do:
        run proc_copy.
        run proc_che.
    end.
    else if ock.in_cash eq "I" then do:
        run proc_copy.
        run proc_inc.
    end.
    
    find ock where ock.ock eq tt-ock no-lock no-error.
    {chdis.f}
    
    release ock.
    release crefer.
    end.
end.
on choose of but_3 do:
    if s-jh eq ? then do:
        message "Transakcija neeksistё.".
        pause 3.
        hide message.
        undo, return. 
    end.

    i = 1.
    message "Uzr–diet vauўeru skaitu:" update i.
    repeat while i ne 0: 
        run x-jlvo.
        i = i - 1.
    end.
end.
on choose of but_4 do:
    if s-jh eq ? then do:
        message "Transakcija neeksistё.".
        pause 3.
        hide message.
        undo, return. 
    end.

    ask = false.
    message "Dzёst transakciju? " update ask.
        if not ask then undo, return.
    Do transaction:    
    conv = false.
    find sysc where sysc.sysc eq "fxbuy" no-lock.
    find first jl where jl.jh eq s-jh no-lock.
    t-crc = jl.crc.
    
    for each jl where jl.jh eq s-jh no-lock:
    
        if not (jl.trx eq "ock0038" or jl.trx eq "ock0039" or 
            jl.trx eq "ock0040" or jl.trx eq "ock0041" or jl.trx eq "ock0012") 
            then do:
            
            message "Transakcija izveidota cit– re·Ёm–. Dzёst nedrЁkst.".
            pause 3.
            hide message.
            undo, return.
        end.
                     
        if t-crc ne jl.crc then conv = true.    
        
        if jl.gl eq sysc.inval then do:
            conv = true.
        end.
        find ock where ock.ock eq v-ock no-lock no-error.
            if available ock then delock = ock.reason.
    end.
                     
    find ock where ock.ock eq delock no-lock no-error.

    find jh where jh.jh = s-jh no-error.
    if avail jh then v-sts = jh.sts.
    
    run trxsts (input s-jh, input 0, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
    
    run trxdel (input s-jh, input true, output rcode, output rdes).  
        if rcode ne 0 then do:
            message rdes.
            pause.
            if rcode = 50 then do:
                               run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                               return.
                          end.     
            else undo, return.
        end.
    
    if ock.in_cash eq "C" then do:
        if conv then do:
            find bock where bock.ock eq delock no-lock.
            find ock where ock.ock eq bock.reason exclusive-lock.
            ock.jh4 = ?.
            ock.csts = "Q".
            ock.reason = "".
            overlay (ock.crefer, r-index (ock.crefer, "*D"), 2) = "  ".
            find crefer where crefer.crefer eq ock.crefer exclusive-lock.
            v-dex = r-index (crefer.qock, ",").
            substring (crefer.qock, v-dex + 1) = ock.ock + ",".
            crefer.camt = crefer.camt + ock.camt.
            find crefer where crefer.crefer eq bock.crefer exclusive-lock.
            delete crefer.
            find ock where ock.ock eq delock exclusive-lock.
            delete ock.
        end.
        else do:
            find bock where bock.ock eq delock no-lock.
            find ock where ock.ock eq bock.reason exclusive-lock.
            ock.jh4 = ?.
            ock.csts = "Q".
            ock.reason = "".
            overlay (ock.crefer, r-index (ock.crefer, "*D"), 2) = "  ".
            find crefer where crefer.crefer eq ock.crefer exclusive-lock.
            substring (crefer.qock, index (crefer.qock, bock.ock), 10) = 
                ock.ock.
            crefer.camt = crefer.camt - bock.camt + ock.camt.
            find ock where ock.ock eq delock exclusive-lock.
            delete ock.
        end.
    end.
    else if ock.in_cash eq "I" then do:
        if conv then do:
            find bock where bock.ock eq delock no-lock.
            find ock where ock.ock eq bock.reason exclusive-lock.
            ock.jh4 = ?.
            ock.csts = "Q".
            ock.reason = "".
            overlay (ock.crefer, r-index (ock.crefer, "*D"), 2) = "  ".
            find crefer where crefer.crefer eq ock.crefer exclusive-lock.
            v-dex = r-index (crefer.qock, ",").
            substring (crefer.qock, v-dex + 1) = ock.ock + ",".
            crefer.camt = crefer.camt + ock.camt.
            find crefer where crefer.crefer eq bock.crefer exclusive-lock.
            delete crefer.
            find ock where ock.ock eq delock exclusive-lock.
            delete ock.
        end.
        else do:
            find bock where bock.ock eq delock no-lock no-error.
            find ock where ock.ock eq bock.reason exclusive-lock.
            ock.jh4 = ?.
            ock.csts = "Q".
            ock.reason = "".
            overlay (ock.crefer, r-index (ock.crefer, "*D"), 2) = "  ".
            find crefer where crefer.crefer eq ock.crefer exclusive-lock.
            substring (crefer.qock, index (crefer.qock, bock.ock), 10) = 
                ock.ock.
            crefer.camt = crefer.camt - bock.camt + ock.camt.
            find ock where ock.ock eq delock exclusive-lock.
            delete ock.
        end.
    end.
    s-jh = ?.
    find ock where ock.ock eq v-ock no-lock.
    display ock.jh4 ock.csts ock.reason ock.crefer with frame fchqc.
    end. /* transaction */
end.

view frame fchqc.
s-jh = ?.

enable all with frame f_but.
wait-for window-close of current-window. 


procedure proc_copy.
    if ock.in_cash eq "C" then
        find sysc where sysc.sysc eq "CHEQA" no-lock no-error.
    else if ock.in_cash eq "I" then
        find sysc where sysc.sysc eq "CHEQL" no-lock no-error.
                    
    find gl where gl.gl eq sysc.inval no-lock no-error.
    find nmbr where nmbr.code eq gl.code exclusive-lock.
    tt-ock = nmbr.prefix + string (nmbr.nmbr, "9999999").
    nmbr.nmbr = nmbr.nmbr + 1.
    release nmbr.
                        
    buffer-copy ock except ock.ock ock.camt ock.crc ock.dam ock.cam to bock 
        assign bock.ock = tt-ock bock.camt = tt-amt bock.crc = tt-crc.
    
    ock.reason = tt-ock.
    bock.reason = ock.ock.
    bock.csts = "R".
    bock.jh1 = ?.
    bock.jh2 = ?.
end.

procedure proc_che.
    define variable o_ock  like ock.camt.
    define variable c_ock  like ock.camt.
    define variable r_ock  like ock.camt.
    define variable dr_ock like ock.camt.
    define variable cr_ock like ock.camt.
    define variable comamt like ock.camt.
    define variable chqamt like ock.camt.
    define variable comm   like ock.camt.

    find crefer where crefer.crefer eq bock.crefer exclusive-lock.
    foot[1] = "Anulёt– ўeka Nr." + v-ock + " P–rreg. ўeka Nr." + tt-ock.

    if bock.crc eq crefer.ccrc then do:
        ask = false.
        message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju?"
            update ask.
            if not ask then undo, return.
         
        run cash_com (input bock.ctype, input bock.camt, input bock.crc,
            input "r", input 0, output chqamt, output comamt).
                        
            if chqamt eq 0 and comamt eq 0 then undo, return.

        comm = comamt.
        message "Komisijas summa :" update comamt.
        chqamt = chqamt + (comm - comamt).
            if chqamt lt 0 then do:
                message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
                pause 3.
                undo, return.
            end.
                                            
        find crc where crc.crc eq ock.crc no-lock no-error.
        foot[1] = "Anulёt– ўeka Nr." + ock.ock + " P–rreg. ўeka Nr." +                   bock.ock.  
        if minimum (ock.camt - ock.cam[4], bock.camt - comamt) eq 
            ock.camt - ock.cam[4] then foot[2] = 
                "Cekam nav samaks–ts " +
                string ((bock.camt - comamt) - (ock.camt - ock.cam[4])) + 
                " " + crc.code.
        else if maximum (ock.camt - ock.cam[4], bock.camt - comamt) eq 
            (ock.camt - ock.cam[4]) then foot[2] = 
                "Cekam ir p–rmaks–ts " +
                string ((ock.camt - ock.cam[4]) - (bock.camt - comamt)) + 
                " " + crc.code.
            
        vparam =
            string (ock.camt - ock.cam[4]) + vdel + ock.ock + vdel + 
            foot[1] + vdel + foot[2] + vdel +
            string (ock.cam[4]) + vdel + foot[1] + vdel + foot[2] + vdel +
            string (bock.camt - comamt) + vdel + bock.ock + vdel +
            foot[1] + vdel + foot[2] + vdel + 
            string (comamt) + vdel +
            foot[1] + vdel + foot[2] + vdel + 
            string (minimum (ock.camt - ock.cam[4], bock.camt - comamt)) + 
            vdel + foot[1] + vdel + foot[2].

            s-jh = 0.
            run trxgen ("ock0038", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.

                
         
         /*
         comamt = ock.cam[4].
         o_ock = ock.camt - ock.cam[4].
         find crc where crc.crc eq ock.crc no-lock no-error.
         if minimum (o_ock, bock.camt - ock.cam[4]) eq o_ock then
            foot[2] = "Cekam nav samaks–ts " +
                string ((bock.camt - ock.cam[4]) - o_ock) + " " + crc.code.
                
         else if maximum (o_ock, bock.camt - ock.cam[4]) eq  o_ock then
            foot[2] = "Cekam ir p–rmaks–ts " +
                string (o_ock - (bock.camt - ock.cam[4])) + " " + crc.code.
            
         vparam =
            string (o_ock) + vdel + v-ock + vdel + foot[1] + vdel + foot[2]
            + vdel + string (0) + vdel + foot[1] + vdel + foot[2] +
            vdel + string (bock.camt - ock.cam[4]) + vdel + bock.ock + vdel 
            + foot[1] + vdel + foot[2] + vdel + string (0) + vdel +
            foot[1] + vdel + foot[2] + vdel + string (minimum (o_ock,
            bock.camt - ock.cam[4])) + vdel + foot[1] + vdel + foot[2].

            s-jh = 0.
            run trxgen ("ock0038", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.        */
        bock.csts = "Q".        
    end.
    else do:
         ask = false.
         message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju " +
            "jaunaj– vёstulё?" update ask.
            if not ask then undo, return.
    
        run cash_com (input bock.ctype, input bock.camt, input bock.crc,
            input "r", input 0, output chqamt, output comamt).
                        
            if chqamt eq 0 and comamt eq 0 then undo, return.

        comm = comamt.
        message "Komisijas summa :" update comamt.
        chqamt = chqamt + (comm - comamt).
            if chqamt lt 0 then do:
                message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
                pause 3.
                undo, return.
            end.

        find crc where crc.crc eq ock.crc no-lock no-error.
        c_ock = (ock.camt - ock.cam[4]) * crc.rate[1] / crc.rate[9].
        find crc where crc.crc eq bock.crc no-lock no-error.
        c_ock = c_ock / crc.rate[1] * crc.rate[9].

        /* izmaks–ts maz–k */
        if c_ock le bock.camt - comamt then do:
            cr_ock = (ock.camt - ock.cam[4]).
            dr_ock = c_ock.
            foot[2] = "Cekam nav samaks–ts " +
                string ((bock.camt - comamt) - c_ock) + " " + crc.code.
        end.
        /* izmaks–ts vair–k */
        else do:
            diff_amt = c_ock - (bock.camt - comamt).
            find crc where crc.crc eq bock.crc no-lock no-error.
            c_ock = (bock.camt - comamt) * crc.rate[1] / crc.rate[9].
            diff_amt = diff_amt * crc.rate[1] / crc.rate[9].
            find crc where crc.crc eq ock.crc no-lock no-error.
            c_ock = c_ock / crc.rate[1] * crc.rate[9].
            diff_amt = diff_amt / crc.rate[1] * crc.rate[9].
            cr_ock = c_ock.
            dr_ock = bock.camt - comamt.
            foot[2] = "Cekam ir p–rmaks–ts " +
                string (diff_amt, "zzz9.99") + " " + crc.code.
            end.

            foot[1] = "Anulёt– ўeka Nr." + ock.ock + " P–rreg. ўeka Nr." + 
                bock.ock.  

            vparam =
                string (ock.camt - ock.cam[4]) + vdel + ock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel + string (ock.cam[4]) +
                vdel + foot[1] + vdel + foot[2] + vdel +
                string (bock.camt - comamt) + vdel + bock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel + string (comamt) + vdel +
                foot[1] + vdel + foot[2] + vdel +
                string (cr_ock) + vdel + foot[1] + vdel + foot[2] + vdel +
                string (dr_ock) + vdel + foot[1] + vdel + foot[2].

            s-jh = 0.
            run trxgen ("ock0039", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.

/*

        o_ock = ock.camt - ock.cam[4].
        find crc where crc.crc eq ock.crc no-lock no-error.
        c_ock = o_ock * crc.rate[1] / crc.rate[9].
        r_ock = ock.cam[4] * crc.rate[1] / crc.rate[9].
        find crc where crc.crc eq bock.crc no-lock no-error.
        c_ock = c_ock / crc.rate[1] * crc.rate[9].
        r_ock = r_ock / crc.rate[1] * crc.rate[9].

        /* izmaks–ts maz–k */
        if c_ock le bock.camt - r_ock then do:
            cr_ock = o_ock.
            dr_ock = c_ock.
            foot[2] = "Cekam nav samaks–ts " +
                string ((bock.camt - r_ock) - c_ock) + " " + crc.code.
        end.
        /* izmaks–ts vair–k */
        else do:
            diff_amt = c_ock - (bock.camt - r_ock).
            find crc where crc.crc eq bock.crc no-lock no-error.
            c_ock = (ock.camt - r_ock) * crc.rate[1] / crc.rate[9].
            diff_amt = diff_amt * crc.rate[1] / crc.rate[9].
            find crc where crc.crc eq ock.crc no-lock no-error.
            c_ock = c_ock / crc.rate[1] * crc.rate[9].
            diff_amt = diff_amt / crc.rate[1] * crc.rate[9].
            cr_ock = c_ock.
            dr_ock = ock.camt - r_ock.
            foot[2] = "Cekam ir p–rmaks–ts " +
                string (diff_amt, "zzz9.99") + " " + crc.code.
        end.

        vparam =
            string (o_ock) + vdel + v-ock + vdel +
            foot[1] + vdel + foot[2] + vdel + string (0) +
            vdel + foot[1] + vdel + foot[2] + vdel +
            string (bock.camt - r_ock) + vdel + bock.ock + vdel +
            foot[1] + vdel + foot[2] + vdel + string (0) + vdel +
            foot[1] + vdel + foot[2] + vdel +
            string (cr_ock) + vdel + foot[1] + vdel + foot[2] + vdel +
            string (dr_ock) + vdel + foot[1] + vdel + foot[2].
        
/*
output to oo.
put vparam format "x(600)".
output close.*/


        s-jh = 0.
        run trxgen ("ock0039", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
                
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.*/
        bock.csts = "S".
    end.

    /*bock.csts = "S".*/
    bock.jh1  = s-jh.
    
    ock.csts  = "L".
    ock.jh4   = s-jh.

    /* vec– vёstule */
    if bock.crc eq crefer.ccrc then do:
        crefer.camt = crefer.camt - ock.camt + bock.camt.
        substring (crefer.qock, index (crefer.qock, ock.ock), 10) = bock.ock.
        ock.crefer = trim(ock.crefer) + "*D".
    end.
    /* jaun– vёstule */
    else do:
        find crefer where crefer.crefer eq ock.crefer exclusive-lock.
        crefer.camt = crefer.camt - ock.camt.  
        v-dex = index (crefer.qock, ock.ock).            
        substring (crefer.qock, v-dex, 11) = "           ".  /* space(11)*/
        substring (crefer.qock,v-dex,1000) = substring (crefer.qock,v-dex + 11).
        
        i = 4.
        repeat:
            if substring (ock.ock, i, 1) ne "0" then leave.
            i = i + 1.
        end.
        
        buffer-copy crefer except crefer.crefer to bcrefer 
            assign bcrefer.crefer = crefer.crefer + "*" + 
                substring (ock.ock, i, 10 - i + 1).
        bcrefer.amount = 0.
        bcrefer.camt   = bock.camt.
        bcrefer.ccrc   = bock.crc.
        bcrefer.comiss = 0.
        bcrefer.csts   = "A".
        bcrefer.ddate  = ?.
        bcrefer.jh2    = ?.
        bcrefer.jh3    = ?.
        bcrefer.qock   = bock.ock + ",".
        bcrefer.rdate  = ?.
        bcrefer.rem    = "".
        
        bock.crefer    = bcrefer.crefer.
        message ock.ock ock.crefer. pause 333.
        ock.crefer = trim(ock.crefer) + "*D".
        message ock.ock ock.crefer. pause 335.
    end.
    
    run x-jlvo.
end.

procedure proc_inc.
    define variable comamt like ock.camt.
    define variable chqamt like ock.camt.
    define variable comm   like ock.camt.
    define variable c_ock  like ock.camt.
    define variable dr_ock like ock.camt.
    define variable cr_ock like ock.camt.


    find crefer where crefer.crefer eq bock.crefer exclusive-lock.
    foot[1] = "Anulёt– ўeka Nr." + v-ock + " P–rreg. ўeka Nr." + tt-ock.

    if bock.crc eq crefer.ccrc then do:
        ask = false.
        message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju?"
            update ask.
            if not ask then undo, return.
    
        run cash_com (input bock.ctype, input bock.camt, input bock.crc,
            input "r", input 0, output chqamt, output comamt).
            if chqamt eq 0 and comamt eq 0 then undo, return.

        comm = comamt.
        message "Komisijas summa :" update comamt.
        chqamt = chqamt + (comm - comamt).
            if chqamt lt 0 then do:
                message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
                pause 3.
                undo, return.
            end.
        
        find crc where crc.crc eq ock.crc no-lock no-error.
        foot[1] = "Anulёt– ўeka Nr." + ock.ock + " P–rreg. ўeka Nr." + bock.ock.

        if minimum (ock.cam[4], comamt) eq ock.cam[4] then foot[2] = 
           "Cekam nav samaks–ta komisija par " + string (comamt - ock.cam[4]) + 
           " " + crc.code.
        else if maximum (ock.cam[4], comamt) eq ock.cam[4] then foot[2] = 
            "Cekam ir p–rmaks–ta komisijas par " + string (ock.cam[4] - comamt)
            + " " + crc.code.

        vparam = string (ock.cam[4]) + vdel + ock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel +
                string (comamt) + vdel + bock.ock + vdel + 
                foot[1] + vdel + foot[2] + vdel +
                string (minimum (ock.cam[4], comamt)) + vdel + foot[1] + vdel +
                foot[2].

        s-jh = 0.
        run trxgen ("ock0040", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
                
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        /*
        vparam = string (ock.camt) + vdel + v-ock + vdel + string (bock.camt) + 
            vdel + bock.ock + vdel.

        run trxgen ("ock0040", vdel, vparam,
            output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.*/
            
        bock.csts = "Q".    
    end.
    else do:
         ask = false.
         message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju " +
            "jaunaj– vёstulё?" update ask.
            if not ask then undo, return.

        run cash_com (input bock.ctype, input bock.camt, input bock.crc,
            input "r", input 0, output chqamt, output comamt).
            if chqamt eq 0 and comamt eq 0 then undo, return.

        comm = comamt.
        message "Komisijas summa :" update comamt.
        chqamt = chqamt + (comm - comamt).
            if chqamt lt 0 then do:
                message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
                pause 3.
                undo, return.
            end.
     
        find crc where crc.crc eq ock.crc no-lock no-error.
        c_ock = ock.cam[4] * crc.rate[1] / crc.rate[9].
        find crc where crc.crc eq bock.crc no-lock no-error.
        c_ock = c_ock / crc.rate[1] * crc.rate[9].

        foot[1] = "Anulёt– ўeka Nr." + ock.ock + " P–rreg. ўeka Nr." + bock.ock.

        /* samaks–ts maz–k */
        if ock.cam[4] le comamt then do:
            foot[2] = "Cekam nav samaks–ta komisija par " + 
                string (comamt - c_ock, "zzz9.99") + " " + crc.code.
            cr_ock = c_ock.
            dr_ock = ock.cam[4].
        end.
        /* samaks–ts vair–k */
        else do:                                            
            diff_amt = c_ock - comamt.
                
            find crc where crc.crc eq bock.crc no-lock no-error.
            c_ock = comamt * crc.rate[1] / crc.rate[9].
            diff_amt = diff_amt * crc.rate[1] / crc.rate[9].
            find crc where crc.crc eq ock.crc no-lock no-error.
            c_ock = c_ock / crc.rate[1] * crc.rate[9].
            diff_amt = diff_amt / crc.rate[1] * crc.rate[9].
            cr_ock = comamt.
            dr_ock = c_ock.
            foot[2] = "Cekam ir p–rmaks–ta komisija par " + 
                string (diff_amt, "zzz9.99") + " " + crc.code.
        end.
            
        vparam = string (ock.cam[4]) + vdel + ock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel +
                string (comamt) + vdel + bock.ock + vdel +
                foot[1] + vdel + foot[2] + vdel +
                string (cr_ock) + vdel + foot[1] + vdel + foot[2] + vdel +
                string (dr_ock) + vdel + foot[1] + vdel + foot[2].

            run trxgen ("ock0041", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
                
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.

    
 /*   
        vparam = string (ock.camt) + vdel + v-ock + vdel + string (bock.camt) + 
            vdel + bock.ock + vdel.

        run trxgen ("ock0040", vdel, vparam,
            output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.*/
        bock.csts = "S".
    end.

 /*   bock.csts = "Q".*/
    bock.jh1  = s-jh.
    
    ock.csts  = "L".
    ock.jh4   = s-jh.

    /* vec– vёstule */
    if bock.crc eq crefer.ccrc then do:
        crefer.camt = crefer.camt - ock.camt + bock.camt.
        substring (crefer.qock, index (crefer.qock, ock.ock), 10) = bock.ock.
        ock.crefer = trim(ock.crefer) + "*D".
    end.
    /* jaun– vёstule */
    else do:
        find crefer where crefer.crefer eq ock.crefer exclusive-lock.
        crefer.camt = crefer.camt - ock.camt.  
        v-dex = index (crefer.qock, ock.ock).            
        substring (crefer.qock, v-dex, 11) = "           ".  /* space(11)*/
        substring (crefer.qock,v-dex,1000) = substring (crefer.qock,v-dex + 11).
        
        i = 4.
        repeat:
            if substring (ock.ock, i, 1) ne "0" then leave.
            i = i + 1.
        end.
        
        buffer-copy crefer except crefer.crefer to bcrefer 
            assign bcrefer.crefer = crefer.crefer + "*" + 
                substring (ock.ock, i, 10 - i + 1).
                
        bcrefer.amount = 0.
        bcrefer.camt   = bock.camt.
        bcrefer.ccrc   = bock.crc.
        bcrefer.comiss = 0.
        bcrefer.csts   = "A".
        bcrefer.ddate  = ?.
        bcrefer.jh2    = ?.
        bcrefer.jh3    = ?.
        bcrefer.qock   = bock.ock + ",".
        bcrefer.rdate  = ?.
        bcrefer.rem    = "".
        
        bock.crefer    = bcrefer.crefer.
        ock.crefer = trim(ock.crefer) + "*D".
    end.
                        
    /** –rpusbilance **/
    vparam = 
        string (ock.camt) + vdel + ock.ock + vdel +
        string (bock.camt) + vdel + bock.ock + vdel.

        run trxgen ("ock0012", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.

        /*
        /* new ock */
        find ock where ock.ock eq tt-ock exclusive-lock no-error.
        ock.jh1     = s-jh.
        ock.csts    = "C".
        ock.reason  = v-ock.
        display ock.ock @ v-ock ock.csts ock.jh1 ock.cam[4] ock.reason 
            with frame fchqc.

        release ock.

        /* anulёtajs ўeks */
        find ock where ock.ock eq v-ock exclusive-lock no-error.
        ock.csts   = "L".
        ock.jh2    = s-jh.
        ock.reason = tt-ock.

        release ock.
 */


    run x-jlvo.
end.
