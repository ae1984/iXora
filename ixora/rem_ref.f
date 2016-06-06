/* rem_ref.f
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

/* rem_ref.f */

update nrem with frame fremit.
run chkboxps (input nrem, input "ock", output remcode).
    if not remcode then undo, retry.

find remtrz where remtrz.remtrz eq nrem no-lock.
find crc where crc.crc eq remtrz.tcrc no-lock.
display remtrz.payment remtrz.tcrc remtrz.detpay[1] remtrz.detpay[2]
    remtrz.detpay[3] remtrz.detpay[4] crc.des with frame fremit.

repeat on endkey undo, return:
    update nref with frame fremit.
    find crefer where crefer.crefer eq nref no-lock no-error.
        if not available crefer then do:
            message "Vёstules numurs nav atrasts b–zё.". 
            undo, retry.
        end.                                 
        if crefer.csts ne "A" then do:
            message "Vёstule nebija akceptёta...".
            undo, retry.
        end.
        else leave.
end.

display crefer except crefer qock chinca rem adate ddate comiss amount jh3 jh2
    brefer with frame fremit.
display crefer.jh2 @ q-jh crefer.jh3 @ z-jh with frame fremit.
find chtype where chtype.chtype eq crefer.chtype no-lock.
display chtype.chdes with frame fremit.
find bankl where bankl.bank eq crefer.sbank no-lock no-error.
    if available bankl then display bankl.name with frame fremit.
    else display "" @ bankl.name with frame fremit.

find bcrc where bcrc.crc eq crefer.ccrc no-lock.
display bcrc.des with frame fremit. 

