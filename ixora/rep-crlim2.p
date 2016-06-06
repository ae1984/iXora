/* rep-crlim2.p
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
       17.07.2013 dmitriy. ТЗ 1640
 * BASES
        BANK COMM TXB
 * CHANGES
        18.09.2013 dmitriy - Дополнение к ТЗ 1640 от 02.09.2013 - Добавление новых столбцов в загружаемый файл
*/

def shared temp-table wrk-dat no-undo
    field bank as char
    field dt  as date
    field CONTRACT_NUMBER as char
    field CONTRACT_NAME as char
    field PRODUCT as char
    field DEPOSIT as char
    field CR_LIMIT as char
    field DATE_CR_LIM as char
    field CONTR_STATUS as char
    field AMOUNT_AVAILABLE as char
    field LOAN as char
    field PAYM_DUE as char
    field OVL as char
    field OVL_OVD as char
    field OVD_30 as char
    field OVD_MORE_30 as char
    field OVD_MORE_60 as char
    field OVD_MORE_90 as char
    field OVD_OUT as char
    field LOAN_INT as char
    field INT_RP as char
    field OVD_PENALTY_INT as char
    field INT_OVD_30 as char
    field INT_OVD_MORE_30 as char
    field INT_OVD_MORE_60 as char
    field INT_OVD_MORE_90 as char
    field INT_OVD_OUT as char
    field SUMM_ALL_WRITING as char
    field DATE_LAST_REPAYMENT as char
    field LAST_SUMM_REPAYMENT as char
    field SUMM_ALL_ACCRUAL_REWARD as char
    field SUMM_ALL_RECEIVE_REWARD as char
    index idx is primary bank ascending CONTRACT_NUMBER ascending.

def shared var s-dt as date.
def var i as int.

def buffer b-crlim for txb.pc_crlim.
def buffer b-limbal for txb.pc_crlimbal.

find first txb.cmp no-lock no-error.

for each txb.pc_crlim break by txb.pc_crlim.acc.
    if first-of(txb.pc_crlim.acc) then do:
        create wrk-dat.
        wrk-dat.bank = txb.cmp.name.
        wrk-dat.CONTRACT_NUMBER = txb.pc_crlim.acc.

        find last b-crlim where b-crlim.acc = txb.pc_crlim.acc and b-crlim.id = 2 and b-crlim.dt <= s-dt no-lock no-error.
        if avail b-crlim then wrk-dat.PRODUCT = b-crlim.chval.

        find last b-crlim where b-crlim.acc = txb.pc_crlim.acc and b-crlim.id = 28 and b-crlim.dt <= s-dt no-lock no-error.
        if avail b-crlim then wrk-dat.CONTRACT_NAME = b-crlim.chval.

        find last b-crlim where b-crlim.acc = txb.pc_crlim.acc and b-crlim.id = 6 and b-crlim.dt <= s-dt no-lock no-error.
        if avail b-crlim then wrk-dat.CONTR_STATUS = b-crlim.chval.

        find last b-crlim where b-crlim.acc = txb.pc_crlim.acc and b-crlim.id = 5 and b-crlim.dt <= s-dt no-lock no-error.
        if avail b-crlim then wrk-dat.DATE_CR_LIM = string(b-crlim.daval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 3 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.DEPOSIT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 4 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.CR_LIMIT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 7 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.AMOUNT_AVAILABLE = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 8 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.LOAN = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 9 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.PAYM_DUE = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 10 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVL = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 11 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVL_OVD = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 12 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_30 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 13 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_MORE_30 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 14 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_MORE_60 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 15 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_MORE_90 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 16 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_OUT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 17 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.LOAN_INT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 18 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_RP = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 22 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.OVD_PENALTY_INT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 23 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_OVD_30 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 24 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_OVD_MORE_30 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 25 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_OVD_MORE_60 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 26 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_OVD_MORE_90 = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 27 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.INT_OVD_OUT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 29 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.SUMM_ALL_WRITING = string(b-limbal.deval).

        find last b-crlim where b-crlim.acc = txb.pc_crlim.acc and b-crlim.id = 30 and b-crlim.dt <= s-dt no-lock no-error.
        if avail b-crlim then wrk-dat.DATE_LAST_REPAYMENT = string(b-crlim.daval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 31 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.LAST_SUMM_REPAYMENT = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 32 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.SUMM_ALL_ACCRUAL_REWARD = string(b-limbal.deval).

        find last b-limbal where b-limbal.acc = txb.pc_crlim.acc and b-limbal.id = 33 and b-limbal.dt <= s-dt no-lock no-error.
        if avail b-limbal then wrk-dat.SUMM_ALL_RECEIVE_REWARD = string(b-limbal.deval).
    end.
end.


