/* io-trebal.p
 * MODULE
        Название модуля
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
        BANK COMM TXB
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
define input param pCif as char.
define input param pAcc as char.

def shared temp-table balance
    field acc as char
    field crc as char
    field cif as char
    field cifname as char
    field avail-balance as deci
    field total-balance as deci
    field over as deci
    field used_over as deci.

/******************************************************************************************************************/
function GetCifName returns char ( input icif as char):
    def buffer b-cif for txb.cif.
    def buffer b-sysc for txb.sysc.
    def var citi as char init "".
    find b-sysc where b-sysc.sysc = 'citi' no-lock no-error.
    if avail b-sysc then do:
    citi = "г." + trim(b-sysc.chval).
    end.

    find b-cif where b-cif.cif eq icif no-lock no-error.
    if avail b-cif then
    do:
    return citi + " " + trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
    end.
    else return icif.
end function.
/******************************************************************************************************************/
function CreateRec returns int (input iCif as char , input iAcc as char ):
    def buffer b-aaa for txb.aaa.
    def buffer b-crc for txb.crc.
    def buffer b-lgr for txb.lgr.
    def var vbal as deci. /*Остаток*/
    def var vavl as deci. /*Доступный остаток*/
    def var vhbal as deci.
    def var vfbal as deci.
    def var vcrline as deci. /*Овердрафт*/
    def var vcrlused as deci. /*Использованный овердрафт*/
    def var vooo as char.

    if iAcc = "ALL" then do:
        m1:
        for each b-aaa where b-aaa.cif = iCif no-lock:
            if b-aaa.sta = 'C' then next m1.
            find first b-lgr where b-lgr.lgr = b-aaa.lgr no-lock no-error.
            if avail b-lgr then do: if b-lgr.led = "ODA" then next m1. end.
            else next m1.

            find last b-crc where b-crc.crc = b-aaa.crc no-lock no-error.

            run bal-txb (input b-aaa.aaa,output vbal,output vavl,output vhbal,output vfbal,output vcrline,output vcrlused,output vooo).

            find first balance where balance.acc = b-aaa.aaa and balance.cif = iCif no-lock no-error.
            if not avail balance then do:
                create balance.
                balance.acc = b-aaa.aaa.
                balance.crc = b-crc.code.
                balance.cif = iCif.
                balance.cifname = GetCifName(b-aaa.cif).
                balance.avail-balance = vavl.
                balance.total-balance = vbal.
                balance.over = vcrline.
                balance.used_over = vcrlused.
            end.
        end.
    end.
    else do:
        find first b-aaa where b-aaa.cif = iCif and b-aaa.aaa = iAcc no-lock no-error.
        find last b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
        if avail b-aaa and avail b-crc then
        do:
            run bal-txb (input b-aaa.aaa,output vbal,output vavl,output vhbal,output vfbal,output vcrline,output vcrlused,output vooo).

            find first balance where balance.acc = b-aaa.aaa and balance.cif = iCif no-lock no-error.
            if not avail balance then do:
                create balance.
                balance.acc = iAcc.
                balance.crc = b-crc.code.
                balance.cif = iCif.
                balance.cifname = GetCifName(b-aaa.cif).
                balance.avail-balance = vavl.
                balance.total-balance = vbal.
                balance.over = vcrline.
                balance.used_over = vcrlused.
            end.
        end.
    end.
    return 0.
end function.
/******************************************************************************************************************/

CreateRec(pCif,pAcc).





