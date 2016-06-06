/* inka_trx.p
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

/** inka_trx.p **/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

{mainhead.i}

define new shared variable s-aaa like aaa.aaa.

define shared variable s-jh  like jh.jh.
define shared variable v-ock like ock.ock.
define shared variable tt1   as character format "x(60)".
define shared variable tt2   as character format "x(60)".

define variable v-cash as logical.
define variable ask    as logical format "J–/Nё".
define variable vdel   as character initial "^".
define variable vparam as character.
define variable rcode  as integer.
define variable rdes   as character.               
define variable hha    as integer format "9".
define variable comamt like ock.comamt.
define variable chqamt like ock.camt.
define variable comcon like ock.comamt.
define variable chqcon like ock.camt.
define variable comaaa like ock.comamt.
define variable crccd  like crc.des.
define variable chb    like crc.crc.
define variable foot   like jl.rem.
define variable ourbank like sysc.chval.

def var comm like comamt.
def var chqq like chqamt.


define buffer bcrc for crc.

define frame fchb
    chb label "K–d– val­t–?" 
    with row 22 no-box col 25 side-labels overlay.

define frame cash
    comamt label "KOMISIJAS SUMMA" 
    crccd  no-label
    with overlay row 18 side-labels centered.

define frame account
    s-aaa     label "     KONTS#" 
    crc.des   label "     VAL®TA" skip
    tt1       label "PILNAIS    "
    tt2       label "  NOSAUKUMS"
    cif.sname label "SA§SINATAIS" format "x(60)"
    cif.pss   label "IDENT.KARTE"
    cif.jss   label "REІ.NUMURS"  format "x(13)" 
    with overlay row 5 side-labels centered title "  KONTA INFORM…CIJA  ".
  
on help of chb do:
    run help-crc1.
end.


find sysc where sysc.sysc eq "ourbnk" no-lock.
ourbank = sysc.chval.

find ock where ock.ock eq v-ock exclusive-lock no-wait no-error.
    if not available ock then do:
        message "OCK# ir aiz‡emts.".
        pause 3.
        hide message.
        return.
    end.
    if ock.csts ne "R" then do:
        message "IzpildЁt nedrЁkst!".
        pause 3.
        hide message.
        return. 
    end.
    if ock.bn_br ne ourbank then do:
        message "IzpildЁt nedrЁkst! Fili–les tranzakcija!".
        pause 3.
        hide message.
        return. 
    end.

run cash_com (input ock.ctype, input ock.camt, input ock.crc, input "r",
    input 1, output chqamt, output comamt). 
    if chqamt eq 0 and comamt eq 0 then undo, return.

crccd = "Lati".
display comamt crccd with frame cash.


comm = comamt.
chqq = chqamt.

message "Komisijas summa :" update comamt.
/*
chqamt = chqamt + (comm - comamt).

    if chqamt lt 0 then do:
        message "Komisijas summa nevar b­t liel–ka par ўeka summu.".
        pause 3.
        undo, return.
    end.
    else
        display comamt with frame cash.
  */


foot[1] = "Inkaso ўeka Nr. " + ock.ock + " pie‡emЅana.".

/**   jurid. pers.   **/
if ock.cfj then do:
    foot[2] = ock.creg.
    foot[3] = ock.cinf.
end.
/**   fizis. pers.   **/
else do:
    foot[2] = ock.cpers.
    foot[3] = ock.cinf.
end.


hha = 0.
repeat while not (hha eq 1 or hha eq 2) on endkey undo, return:
    message "Komisijas iemaksa:  1)Kase  2)Konts " update hha.
end.

if hha eq 1 then do:
    chb = 1.
    update chb with frame fchb.
    find crc where crc.crc eq chb no-lock no-error.
        if not available crc then do:
            message "Val­tas kods neeksistё.".
            pause 3.
            hide message.
            undo, retry.
        end.
        else do:
            comamt = comamt / crc.rate[1] * crc.rate[9].
            crccd = crc.des.
            display comamt crccd with frame cash.
        end.

    ask = false.
    message "Veidot tranzakciju?" update ask.
        if not ask then do:
            hide frame cash.
            undo, return.
        end.
    
    /*foot[1] = "Inkaso ўeka Nr. " + ock.ock + " pie‡emЅana.".*/

    vparam = string (comamt) + vdel + string (crc.crc) + vdel + 
        string (ock.ock) + vdel + foot[1] + 
        foot[2] + foot[3].
          
    s-jh = 0.
    run trxgen 
        ("ock0020", vdel, vparam, output rcode, output rdes, input-output s-jh).
        
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
end.
else if hha eq 2 then do:
    
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
    tt1 = substring (trim(trim(cif.prefix) + " " + trim(cif.name)), 1, 60).
    tt2 = substring (trim(trim(cif.prefix) + " " + trim(cif.name)), 61, 60).
           
    chqcon = chqamt.
    comcon = comamt.

    find bcrc where bcrc.crc eq aaa.crc no-lock no-error.
    display tt1 tt2 trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname cif.pss cif.jss bcrc.des @ crc.des 
        with frame account.
    
    if aaa.crc ne 1 then do:
        ask = false.
        message "Komisijas un konta val­tas nesakrЁt!" + 
            " Konvertёt komisiju konta val­t–?" update ask.
            if not ask then do:
                hide message.
                undo, retry.
            end.
    end.

    ask = false.
    message "Veidot tranzakciju?" update ask.
        if not ask then do:
            hide frame cash.
            undo, return.
        end.
    
    if aaa.crc eq 1 then do:
        /*foot[1] = "Inkaso ўeka Nr. " + ock.ock + " pie‡emЅanaa.".*/

        vparam = string (comcon) + vdel + s-aaa + vdel + ock.ock +
            vdel + foot[1] + foot[2] + foot[3].

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
        find crc where crc.crc eq aaa.crc no-lock no-error.
        comaaa = comcon / crc.rate[1] * crc.rate[9].

        /*foot[1] = "Inkaso ўeka Nr. " + ock.ock + " pie‡emЅana.".*/

        vparam = string (comaaa) + vdel + string (aaa.crc) + vdel +
            aaa.aaa + vdel + ock.ock + vdel + foot[1] +
            foot[2] + foot[3].

        s-jh = 0.
        run trxgen ("ock0022", vdel, vparam, 
            output rcode, output rdes, input-output s-jh).
            
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
    end.
end.
           
vparam = string (ock.camt) + vdel + ock.ock + vdel.
          
run trxgen ("ock0003", vdel, vparam, 
    output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message rdes.
        pause.
        undo, return.
    end.

    else if rcode eq 0 then do:
        run trxsts (input s-jh, input hha + 4, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.  

        if comamt eq 0 then do:
            run trxsts (input s-jh, 6, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.  
        end.

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



