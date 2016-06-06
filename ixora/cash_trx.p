/* cash_trx.p
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
*/

/** cash_trx.p **/

{mainhead.i}

define buffer bcrc for crc.

define new shared variable s-aaa like aaa.aaa.

define shared variable v-ock like ock.ock.
define shared variable tt1   as character format "x(60)".
define shared variable tt2   as character format "x(60)".
define shared variable s-jh  like jh.jh.

define variable rcode   as integer.
define variable comamt  like ock.comamt.
define variable comcon  like ock.comamt.
define variable rdes    as character.
define variable vdel    as character initial "^".
define variable vparam  as character.
define variable c_aaa  like aaa.aaa.
define variable chqamt like ock.camt.
define variable chqcon like ock.camt.
define variable ask    as logical format "J–/Nё".
define variable askc   as logical format "J–/Nё".
define variable cha    as integer format "9".
define variable foot   like jl.rem.
define variable csour  as integer format "9".
define variable chb    like crc.crc.
define variable crccd  like crc.des.
define variable comaaa like ock.comamt.
define variable v-cash as logical.
def var v-cifsname like cif.sname.
def var v-cifname like cif.name.

def var comm like comamt.
def var chqq like chqamt.

define frame cashock
    comamt label "KOMISIJAS SUMMA" 
    chqamt label "SUMMA IZMAKSAI "
    with overlay row 18 side-labels centered.

define frame cash
    comamt label "KOMISIJAS SUMMA" 
    crccd  no-label
    with overlay row 18 side-labels centered.

define frame fchb
    chb label "K–d– val­t–?" 
    with row 22 no-box col 25 side-labels overlay.

define frame account
    s-aaa     label "     KONTS#"
    crc.des   label "     VAL®TA" skip
    tt1       label "PILNAIS    "
    tt2       label "  NOSAUKUMS"
    v-cifsname label "SA§SINATAIS" format "x(60)"
    cif.pss   label "IDENT.KARTE"
    cif.jss   label "REІ.NUMURS"  format "x(13)"
    with overlay row 5 side-labels centered title "KONTA INFORM…CIJA  ".

on help of chb do:
    run help-crc1.
end.

on pf4 anywhere do:
    hide frame cash.
end.

find ock where ock.ock eq v-ock exclusive-lock no-wait no-error.
    if not available ock then do:
        message "OCK# ir aiz‡emts.".
        pause 3.
        hide message.
        undo, return.
    end.
    if ock.csts ne "R" then do:
        message "IzpildЁt nedrЁkst!".
        pause 3.
        hide message.
        undo, return. 
    end.
    find sysc where sysc.sysc eq "OURBNK" no-lock no-error.
        if not available sysc then do:
            message "Fail– <SYSC> ""OURBNK"" neeksistё.".
            undo, return.
        end.

    if ock.bn_br ne sysc.chval then do:
        find bankl where bankl.bank eq ock.bn_br no-lock. 
        message "IzpildЁt nedrЁkst! °eks pieder " + bankl.name.
        pause 3.
        hide message.
        undo, return. 
    end.
        
find crc where crc.crc eq ock.crc no-lock no-error.

run cash_com (input ock.ctype, input ock.camt, input ock.crc, input "r",
    input 0, output chqamt, output comamt). 

    if chqamt eq 0 and comamt eq 0 then undo, return.

display comamt /*chqamt*/ crc.des @ crccd with frame cash.

comm = comamt.
chqq = chqamt.

message "Komisijas summa :" update comamt.
chqamt = chqamt + (comm - comamt).

    if chqamt lt 0 then do:
        message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
        pause 3.
        undo, return.
    end.
    else
        display comamt /*chqamt*/ crc.des @ crccd with frame cash.

pause 0.

csour = 3.
if comamt ne 0 then repeat on endkey undo, return:
    message "Komisijas iemaksa  1)Kase  2)Konts  3)°eks " update csour.
        if csour ge 1 and csour le 3 then leave.
end.


foot[1] = "°eka Nr. " + ock.ock + " apmaksa.".

/** komisija no kases **/
IF csour eq 1 then do:
    chb = 1.
    update chb with frame fchb.
    find bcrc where bcrc.crc eq chb no-lock no-error.
        if not available bcrc then do:
            message "Val­tas kods neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.
        else do:
            comamt = comamt * crc.rate[1] / crc.rate[9] /
                bcrc.rate[1] * bcrc.rate[9].
            crccd = bcrc.des.
            display comamt crccd with frame cash.
        end.

    ask = false.
    message "Veidot tranzakciju?" update ask.
        if not ask then do:
            hide frame cash.
            undo, return.
        end.
    
    vparam = string (comamt) + vdel + string (bcrc.crc) + vdel + 
        string (ock.ock) + vdel + foot[1].
          
    s-jh = 0.
    run trxgen 
        ("ock0020", vdel, vparam, output rcode, output rdes, input-output s-jh).
        
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
END.

/** komisija no konta **/
ELSE IF csour eq 2 then do:

    s-aaa = "".
    clear frame account.

    update s-aaa with frame account. 
    find aaa where aaa.aaa = s-aaa no-lock no-error. 
        if not available aaa then do:
            message "Konts nav atrasts!".
            pause 3.
            hide message.
            undo,retry.
        end.
        if aaa.sta eq "C" then do:
            message "Konts ir aizvёrts!".
            pause 3.
            hide message.
            undo,retry.
        end.              

    run aaa-aas.
    find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
        if available aas then do: 
            message "STOP PAYMENT".
            pause 3. 
            undo,retry. 
        end.
            
    find cif of aaa no-lock no-error.
    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
    tt1 = substring (v-cifname, 1, 60).
    tt2 = substring (v-cifname, 61, 60).
           
    chqcon = chqamt.
    comcon = comamt.

    find bcrc where bcrc.crc eq aaa.crc no-lock no-error.
    v-cifsname = trim(trim(cif.prefix) + " " + trim(cif.sname)).
    display tt1 tt2 v-cifsname cif.pss cif.jss bcrc.des @ crc.des 
        with frame account.

    if aaa.crc eq ock.crc then do:
        ask = false.
        message "Veidot tranzakciju?" update ask.
            if not ask then do:
                hide frame cash.
                undo, return.
            end.

        vparam = string (comcon) + vdel + s-aaa + vdel + ock.ock +
            vdel + foot[1].

        s-jh = 0.
        run trxgen ("ock0021", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
            
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
    end.
    else do:
        askc = false.
        message "Komisijas un konta val­tas nesakrЁt!" + 
            " Konvertёt komisiju konta val­t–?" update askc.
            if not askc then do:
                hide message.
                undo, retry.
            end.

        find bcrc where bcrc.crc eq aaa.crc no-lock no-error.
        comaaa = comcon * crc.rate[1] / crc.rate[9] /
            bcrc.rate[1] * bcrc.rate[9].

        vparam = string (comaaa) + vdel + string (aaa.crc) + vdel +
            aaa.aaa + vdel + ock.ock + vdel + foot[1].

        s-jh = 0.
        run trxgen ("ock0022", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
            
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
    end.
END.

/** komisija no ўeka summas **/
ELSE IF csour eq 3 then do:

display comamt chqamt with frame cashock.

ask = false.
message "Veidot ўekam izmaksas tranzakciju?" update ask.
    if not ask then do:
        hide frame cash.
        return.
    end.

if ock.aaa eq "" then do:

    vparam = string (chqamt) + vdel + ock.ock  + vdel + foot[1] + vdel + 
        string (comamt) + vdel + foot[1]. 

    s-jh = 0.
    run trxgen 
        ("ock0001", vdel, vparam, output rcode, output rdes, input-output s-jh).
        
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
    
    run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
end.
else if ock.aaa ne "" then do:
    find aaa where aaa.aaa eq ock.aaa no-lock no-error.
        if aaa.crc eq ock.crc then do:
            foot[1] = "°eka Nr. " + ock.ock + " apmaksa.".
                
            vparam = string (chqamt) + vdel + ock.ock  + vdel + aaa.aaa + 
                vdel + foot[1]  + vdel + string (comamt) + vdel + foot[1].

            s-jh = 0.
            run trxgen ("ock0002", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
            
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            run trxsts (input s-jh, input 5, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
        end.
        else if aaa.crc ne ock.crc then do:
            ask = false.
            message "°eka un konta val­tas nesakrЁt!" + 
                " Konvertёt summu konta val­t–?" update ask.
                if not ask then do:
                    hide message.
                    undo, retry.
                end.
                
            foot[1] = "°eka Nr. " + ock.ock + " apmaksa.".

            vparam = string (comamt) + vdel + ock.ock + vdel + foot[1] + 
                vdel + string (chqamt) + vdel + foot[1] + vdel + 
                aaa.aaa + vdel + foot[1].

            s-jh = 0.
            run trxgen ("ock0011", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
            
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            run trxsts (input s-jh, input 5, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
        end.
end.
END.

    
/** ieskaitЁt kont– vai izmaks–t no kases visu summu **/
if csour eq 1 or csour eq 2 then do:
    
    if ock.aaa eq "" then do:
        vparam = string (ock.camt) + vdel + ock.ock  + vdel + foot[1] + vdel + 
            string (0) + vdel + foot[1]. 

        run trxgen ("ock0001", vdel, vparam, output rcode, output rdes, 
            input-output s-jh).
        
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        run trxsts (input s-jh, input 5, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

    end.
    else if ock.aaa ne "" then do:
        find aaa where aaa.aaa eq ock.aaa no-lock no-error.
        if aaa.crc eq ock.crc then do:
            vparam = string (ock.camt) + vdel + ock.ock  + vdel + aaa.aaa + 
                vdel + foot[1]  + vdel + string (0) + vdel + foot[1].

            run trxgen ("ock0002", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
            
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            run trxsts (input s-jh, input 5, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
        end.
        else if aaa.crc ne ock.crc then do:
            
            if not askc then do:
                message "°eka un konta val­tas nesakrЁt!" + 
                    " Konvertёt summu konta val­t–?" update askc.
                    if not askc then do:
                        hide message.
                        undo, retry.
                    end.
            end.

            vparam = string (0) + vdel + ock.ock + vdel + foot[1] + 
                vdel + string (ock.camt) + vdel + foot[1] + vdel + 
                aaa.aaa + vdel + foot[1].

            run trxgen ("ock0011", vdel, vparam, 
                output rcode, output rdes, input-output s-jh).
            
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            run trxsts (input s-jh, input 5, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
        end.
    end.
end.
    
if rcode eq 0 then do on error undo, retry:
    find ock where ock.ock eq v-ock exclusive-lock.
    ock.jh1 = s-jh.
    ock.csts = "C".

    release ock.

    run x-jlcho.
end.
      
release ock.


find sysc where sysc.sysc eq "CASHGL" no-lock.
v-cash = no.
for each jl where jl.jh eq s-jh no-lock.
    if jl.gl eq sysc.inval then v-cash = true.
end.

if v-cash then do:
    run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
end.
else do:
    run trxsts (input s-jh, input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
end.



