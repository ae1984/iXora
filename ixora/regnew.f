/* regnew.f
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

/** regnew.f **/

    define buffer fock for ock.

    find ock where ock.ock eq v-ock exclusive-lock no-wait.
    {chdis.f}
        if not (ock.csts eq "C" or ock.csts eq "I") and ock.bn_br eq ourbank
            then do:
            message "Re¦istrёt jaunu ўeku nedrЁkst!".
            pause 3.
            hide message.
            undo, retry.
        end.
        if ock.bn_br ne ourbank and ock.csts ne "R" then do:
            message "Re¦istrёt jaunu ўeku nedrЁkst!".
            pause 3.
            hide message.
            undo, retry.
        end.
        
    find fock where fock.csts eq "L" and fock.jh2 eq ock.jh1 no-lock no-error.
        if available fock then do:
            message "°eks p–rre¦istrёts! " + fock.ock + " - " + fock.cheque +
                ". Re¦istrёt jaunu ўeku nedrЁkst!".
            pause 3.
            hide message.
            undo, retry.
        end.

    prompt-for ock.cheque with frame fchqc.

    tt-che = input frame fchqc ock.cheque.
    
    prompt-for ock.ctype with frame fchqc.
    tt-cty = input frame fchqc ock.ctype.
    find chtype where chtype.chtype eq tt-cty no-lock.
    find bchtype where bchtype.chtype eq ock.ctype no-lock.
        if bchtype.chinca ne chtype.chinca then undo, retry.
    display chtype.chdes with frame fchqc.

    if tt-cty ne "tc" then do:
        prompt-for ock.chdate with frame fchqc.
        tt-cda = input frame fchqc ock.chdate.
    end.
    
    tt-inc = chtype.chinca.

    prompt-for ock.bn_br with frame fchqc.
    tt-bbr = input frame fchqc ock.bn_br.
    find bankl where bankl.bank eq tt-bbr no-lock.
    display bankl.name @ ock.branch with frame fchqc.

    prompt-for ock.cowner ock.caddr ock.cinf ock.cfj 
        help "F - fizisk– persona  J - juridisk– persona"
        with frame fchqc.
    tt-own = input frame fchqc ock.cowner.
    tt-add = input frame fchqc ock.caddr.
    tt-inf = input frame fchqc ock.cinf.
    tt-cfj = input frame fchqc ock.cfj.
        if tt-cfj then do:
            display "" @ ock.cpers with frame fchqc.
            prompt-for ock.creg with frame fchqc.
            tt-reg = input frame fchqc ock.creg.
        end.
        else do:
            display "" @ ock.creg with frame fchqc.
            prompt-for ock.cpers with frame fchqc.
            tt-per = input frame fchqc ock.cpers.
        end.
                                
    prompt-for ock.camt ock.crc with frame fchqc.
    tt-amt = input frame fchqc ock.camt.
    tt-crc = input frame fchqc ock.crc.
    find crc where crc.crc eq tt-crc no-lock.
    display crc.des with frame fchqc. 

    if tt-amt eq ock.camt and tt-crc eq ock.crc then do:
        prompt-for ock.cam[4] with frame fchqc.
        tt-com = input frame fchqc ock.cam[4].
    end.

    prompt-for ock.cbank with frame fchqc.
    tt-bnk = input frame fchqc ock.cbank.
    find bankl where bankl.bank eq tt-bnk no-lock no-error.
        if available bankl then display bankl.name with frame fchqc.
    /*
    if tt-amt ne ock.camt or tt-crc ne ock.crc and ock.in_cash eq "C" then do:
        delch = false.
        message "Veidot anulёЅanas tranzakciju un jauna ўeka re¦istr–ciju?"
            update delch.

            if not delch then undo, return.
    end.
      */

