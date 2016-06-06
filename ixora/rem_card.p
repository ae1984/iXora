/* rem_card.p
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

/** rem_card.p **/


{mainhead.i}
{ir_card.i "shared"}

define new shared variable t_recid  as recid.
define new shared variable retcode  as character.

define variable remcod  as logical.
define variable ask     as logical format "J–/Nё".

nrem = "".
update nrem with frame fremit.
find remtrz where remtrz.remtrz eq nrem no-lock no-error.
    if not available remtrz then do:
        message "P–rvedums nav atrasts.".
        undo, retry.
    end.  
find crc where crc.crc eq remtrz.tcrc no-lock.
atli = remtrz.payment.
s-jh = remtrz.jh2.

display remtrz.payment remtrz.bn[2] remtrz.detpay[1] remtrz.detpay[2]
    remtrz.detpay[3] remtrz.detpay[4] s-jh crc.des atli remtrz.bn[1]
    with frame fremit.
  
run chkboxps (input nrem, input "crcard", output remcod).
    if not remcod then undo, retry.

{jabre.i
&start = " "
&head = "t_card"
&where = "true"
&formname = "rem_card"
&framename = "fcards"
&addcon = "true"
&deletecon = "true"
&display = "t_card.card t_card.code t_card.exdate t_card.owner t_card.amount
            t_card.payment"
&highlight = "t_card.card t_card.code t_card.exdate t_card.owner t_card.amount
                t_card.payment"
&postadd = "t_recid = recid (t_card).
REPEAT on endkey undo, leave upper:
    update t_card.card with frame fcards.
    run get_card (input t_card.card, output remcod).
        if retcode eq '2' then do:
            undo, next.
        end.
        if remcod then leave.
        else do:
            message 'KARTE NEDER§GA.'.   /*, IESKAIT§T SUMMU ?'*/
            undo, next.
            /*
            update ask.
                if not ask then undo, next.
                else leave. */
        end.
END. 
run amt_card."
&postdelete = "atli = remtrz.payment.
                for each t_card:
                    atli = atli - t_card.amount.
                end.
                display atli with frame fremit."            
&prechoose = "message
    'F4 - –r–;  INSERT, CURSOR-DOWN - papild.;  F10 - dzёst;  ENTER - labot '."
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do transaction:
    t_recid = recid (t_card).
    REPEAT on endkey undo, leave upper:
        update t_card.card with frame fcards.
        run get_card (input t_card.card, output remcod).
            if retcode eq '2' then do:
                undo, next.
            end.
            if remcod then leave.
            else do:
                message 'KARTE NEDER§GA. '. /*, IESKAIT§T SUMMU ?'*/
                undo, next.
                /*
                update ask.
                    if not ask then undo, next.
                    else leave.*/
            end.
    END. 
    run amt_card. 
end."
&end = "for each t_card:
            if t_card.amount eq 0 and t_card.payment eq 0 then delete t_card.
        end.
        hide frame fcards.
        for each t_card:
            display t_card.card label 'KARTES'
            t_card.exdate label 'L§DZ'
            t_card.owner label 'KARTES §PA№NIEKS'
            t_card.amount label 'SUMMA'
            t_card.payment label 'IESK.SUMMA'
            t_card.code label 'VAL.'
            with frame fcards2 down.
            pause 0.
        end."
}
  


