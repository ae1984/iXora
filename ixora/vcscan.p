/* vcscan.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
def shared var s-contract like comm.vccontrs.contract.

def var v-head as char init "vccontrs".

run vc-oper("2",trim(string(s-contract)),v-head).



