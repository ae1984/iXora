/* inbccc.f
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

/** inbccc.f **/

v-ock = "".
clear frame fchq.

message "F2 - palЁdzЁba izvёlёties ўeku".
update v-ock with frame fchq.

find ock where ock.ock eq v-ock no-lock no-error.
    if not available ock then do:
        message "OCK# nav atrasts b–zё.".
        pause 3.
        hide message.
        undo, retry.
    end.
    if ock.bn_br eq obank then do:
        message "№aj– re·Ёm– drЁkst apstr–d–t tikai ўekus no fili–lёm.".
        pause 3.
        hide message.
        undo, retry.
    end.
    if ock.in_cash ne "I" then do:
        message "№aj– re·Ёm– drЁkst apstr–d–t tikai inkaso ўekus.".
        pause 3.
        hide message.
        undo, retry.
    end.

find chtype where chtype.chtype eq ock.ctype no-lock.
if ock.sbank ne "" then do:
    find bankl where bankl.bank eq ock.sbank no-lock no-error.
        if available bankl then blname = bankl.name.
        else blname = "".
end.
if ock.cbank ne "" then do:
    find bankl where bankl.bank eq ock.cbank no-lock no-error.
        if available bankl then display bankl.name with frame fchq.
        else display "" @ bankl.name with frame fchq.
end.
        
find crc where crc.crc eq ock.crc no-lock.
display crc.des with frame fchq.
display blname with frame fchq.
display ock.cheque ock.chdate ock.bn_br ock.branch ock.csts ock.ctype
    ock.crc ock.cowner ock.camt ock.cwhn ock.cwho ock.swhn ock.swho 
    ock.jh1 ock.jh2 ock.cbank ock.sbank ock.caddr ock.cinf ock.creg ock.jh4
    ock.cpers ock.cfj ock.aaa ock.crefer ock.chdate ock.point ock.jh3 ock.dpt
    ock.cam[4] with frame fchq.
display chtype.chdes with frame fchq.

