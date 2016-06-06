/* chdis.f
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

/* chdis.f */
 
    if not available ock then do:
        message "°eks ar t–d–m pazЁmёm nav atrasts...".
        pause 3.
        hide message.
        return.
    end.
          
    find chtype where chtype.chtype eq ock.ctype no-lock no-error.
    if ock.sbank ne "" then do:
        find bankl where bankl.bank eq ock.sbank no-lock no-error.
            if available bankl then blname = bankl.name.
    end.
    if ock.cbank ne "" then do:
        find bankl where bankl.bank eq ock.cbank no-lock no-error.
            if available bankl then display bankl.name with frame fchqc.
    end.
    find crc where crc.crc eq ock.crc no-lock.
    display crc.des with frame fchqc.
    display blname with frame fchqc.
    display ock.cheque ock.chdate ock.bn_br ock.branch ock.csts ock.ctype
        ock.crc ock.cowner ock.camt ock.cwhn ock.cwho ock.swhn ock.swho 
        ock.jh1 ock.jh2 ock.cbank ock.sbank ock.caddr ock.cinf ock.creg
        ock.cpers ock.cfj ock.aaa ock.crefer ock.chdate ock.point 
        ock.ock @ v-ock ock.payee ock.cam[4] ock.reason with frame fchqc.

    display chtype.chdes with frame fchqc.

