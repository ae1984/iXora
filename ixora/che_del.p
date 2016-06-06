/* che_del.p
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

/* che_del.p */

{mainhead.i}

define button del_1 label "ANULЁT".
define button del_2 label "VAU°ERS".
define button del_3 label "IZMEST".

define new shared variable s-jh     like jh.jh.

define shared variable v-ock   like ock.ock.
define shared variable ourbank as character.
                                                  
define variable blname like bankl.name.
define variable delch  as logical format "J–/Nё".
define variable rcode  as integer.
define variable rdes   as character.
define variable vdel   as character initial "^".
define variable vparam as character.
define variable foot   like jl.rem.

define frame f_del del_1 del_2 del_3 
    with row 3 centered no-box side-labels.

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
         

/**  ANULЁT  **/
on choose of del_1 do:
    run procd_1.
end.

/** VAU°ERS  **/
on choose of del_2 do:
    run procd_2.
end.

/** IZMEST  **/
on choose of del_3 do:
    run procd_3.
end.

find ock where ock.ock eq v-ock no-lock no-error.

enable all with frame f_del.
wait-for window-close of current-window. 

procedure procd_1:
    do transaction:
    find ock where ock.ock eq v-ock exclusive-lock no-error.
        if ock.csts eq "L" then do:
            message "°eks jau anulёts!".
            pause 3.
            hide message.
            undo, return.
        end.
        if ock.csts ne "C" and ock.bn_br eq ourbank then do:
            message "Anulёt nedrЁkst!".
            pause 3.
            hide message.
            undo, return.
        end.
        if ock.csts ne "R" and ock.bn_br ne ourbank then do:
            message "Anulёt nedrЁkst!".
            pause 3.
            hide message.
            undo, return.
        end.
        
    delch = false.
    message "Anulёt ўeku?" update delch.
        if not delch then return.

    IF ock.bn_br eq ourbank then do:
    
    foot[1] = "°eka " + ock.ock + " anulёЅana.".
    vparam = string (ock.camt - ock.cam[4]) + vdel + ock.ock + vdel + ock.ock +
        vdel + foot[1] + vdel + string (ock.cam[4]) + vdel + foot[1].

    s-jh = 0.
    run trxgen 
        ("ock0004", vdel, vparam, output rcode, output rdes, input-output s-jh).
        
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        else do:
            find ock where ock.ock eq v-ock exclusive-lock no-error.
            ock.csts = "L".
            ock.jh2  = s-jh.
            display ock.csts ock.jh2 with frame fchqc.
            pause 0.

            run x-jlvo.

            release ock.
        end.
    END.
    ELSE DO:
        ock.csts = "L".
        display ock.csts with frame fchqc.
        pause 0.
        release ock.
    END.

    find ock where ock.ock eq v-ock no-lock no-error.
    hide message.
    end.
end.

procedure procd_2:
    define variable i as integer format "9".

    s-jh = ock.jh2.
        if s-jh eq ? then do:
            message "Tranzakcija neeksistё!".
            pause 3.
            hide message.
            return.
        end.

    message "Uzr–diet vauўeru skaitu: " update i.
        if i eq 0 then undo, retry.

    repeat while i ne 0 on error undo, retry:
        run x-jlvo.
        i = i - 1.
    end.
end.

procedure procd_3:
    do transaction:
    find ock where ock.ock eq v-ock exclusive-lock no-error.
    s-jh = ock.jh2.
        if s-jh eq ? and ock.bn_br eq ourbank then do:
            message "Tranzakcija neeksistё!".
            pause 3.
            hide message.
            return.
        end.
    
    if ock.bn_br eq ourbank then do:
        find jh where jh.jh eq s-jh no-lock no-error.
            if jh.who ne g-ofc then do:
                message "T– nav j­su tranzakcija. Dzёst nedrЁkst!".
                pause 3.
                hide message.
                return.
            end.
    end.
    if ock.bn_br ne ourbank and ock.csts ne "L" then do:
        message "MainЁt statusu nedrЁikst.".
        pause 3.
        hide message.
        return.
    end.

    delch = false.
    message "Dzёst tranzakciju?" update delch.
        if not delch then undo, return.
                
    IF ock.bn_br eq ourbank then do:
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
            find ock where ock.ock eq v-ock exclusive-lock.
            ock.jh2 = ?.
            ock.csts = "C".
            display ock.jh2 ock.csts with frame fchqc.
            pause 0.

            release ock.
        end.
    END.
    ELSE DO:
        ock.csts = "R".
        display ock.csts with frame fchqc.
        pause 0.
        release ock.
    END.
    
    find ock where ock.ock eq v-ock no-lock no-error.
    return.
    end.
end.

