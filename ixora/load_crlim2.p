/* load_crlim2.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Загрузка остатков по кредитным лимитам из файлов Open Way
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
        16.09.2013 dmitriy - Дополнение к ТЗ 1640 от 02.09.2013 - Добавление новых столбцов в загружаемый файл
*/

def shared temp-table wrk-dat no-undo
    field num as int
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

    index idx is primary num.

def var v-bnk as char.

def buffer b-crlim for txb.pc_crlim.
def buffer b-limbal for txb.pc_crlimbal.

function st-de returns decimal (input v-st as char).
    if index(v-st, ",") > 0 and index(v-st, ".") > 0 then do:
        v-st = trim(v-st).
        v-st = replace(v-st, chr(160) , "").
        v-st = replace(v-st, " " , "").
        v-st = replace(v-st, "," , "").
    end.
    else do:
        v-st = trim(v-st).
        v-st = replace(v-st, chr(160) , "").
        v-st = replace(v-st, " " , "").
        v-st = replace(v-st, "," , ".").
    end.
    return decimal(v-st).
end.


find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-bnk = txb.sysc.chval.


/* Загрузка и обновление данных */
for each wrk-dat where substr(wrk-dat.CONTRACT_NUMBER, 19, 2) = substr(v-bnk, 4, 2) no-lock:
    for each txb.pc_parname no-lock:
        case txb.pc_parname.id:
            when 2 then do:
                find last txb.pc_crlim where txb.pc_crlim.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlim.id = pc_parname.id and txb.pc_crlim.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlim and txb.pc_crlim.chval = wrk-dat.PRODUCT  then next.
                if (not avail txb.pc_crlim) or (avail txb.pc_crlim and txb.pc_crlim.chval <> wrk-dat.PRODUCT and txb.pc_crlim.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-crlim.
                        b-crlim.acc = wrk-dat.CONTRACT_NUMBER.
                        b-crlim.dt = wrk-dat.dt.
                        b-crlim.id = pc_parname.id.
                        b-crlim.chval = wrk-dat.PRODUCT.
                        b-crlim.daval = ?.
                    end.
                end.
            end.
            when 28 then do:
                find last txb.pc_crlim where txb.pc_crlim.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlim.id = pc_parname.id and txb.pc_crlim.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlim and txb.pc_crlim.chval = wrk-dat.CONTRACT_NAME  then next.
                if (not avail txb.pc_crlim) or (avail txb.pc_crlim and txb.pc_crlim.chval <> wrk-dat.CONTRACT_NAME and txb.pc_crlim.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-crlim.
                        b-crlim.acc = wrk-dat.CONTRACT_NUMBER.
                        b-crlim.dt = wrk-dat.dt.
                        b-crlim.id = pc_parname.id.
                        b-crlim.chval = wrk-dat.CONTRACT_NAME.
                        b-crlim.daval = ?.
                    end.
                end.
            end.
            when 6 then do:
                find last txb.pc_crlim where txb.pc_crlim.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlim.id = pc_parname.id and txb.pc_crlim.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlim and txb.pc_crlim.chval = wrk-dat.CONTR_STATUS  then next.
                if (not avail txb.pc_crlim) or (avail txb.pc_crlim and txb.pc_crlim.chval <> wrk-dat.CONTR_STATUS and txb.pc_crlim.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-crlim.
                        b-crlim.acc = wrk-dat.CONTRACT_NUMBER.
                        b-crlim.dt = wrk-dat.dt.
                        b-crlim.id = pc_parname.id.
                        b-crlim.chval = wrk-dat.CONTR_STATUS.
                        b-crlim.daval = ?.
                    end.
                end.
            end.
            when 5 then do:
                find last txb.pc_crlim where txb.pc_crlim.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlim.id = pc_parname.id and txb.pc_crlim.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlim and txb.pc_crlim.daval = date(wrk-dat.DATE_CR_LIM)  then next.
                if (not avail txb.pc_crlim) or (avail txb.pc_crlim and txb.pc_crlim.daval <> date(wrk-dat.DATE_CR_LIM) and txb.pc_crlim.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-crlim.
                        b-crlim.acc = wrk-dat.CONTRACT_NUMBER.
                        b-crlim.dt = wrk-dat.dt.
                        b-crlim.id = pc_parname.id.
                        b-crlim.chval = "".
                        b-crlim.daval = date(wrk-dat.DATE_CR_LIM).
                    end.
                end.
            end.
            when 3 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.DEPOSIT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.DEPOSIT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.DEPOSIT).
                    end.
                end.
            end.
            when 4 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.CR_LIMIT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.CR_LIMIT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.CR_LIMIT).
                    end.
                end.
            end.
            when 7 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.AMOUNT_AVAILABLE) then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.AMOUNT_AVAILABLE) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.AMOUNT_AVAILABLE).
                    end.
                end.
            end.
            when 8 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.LOAN)   then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.LOAN) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.LOAN).
                    end.
                end.
            end.
            when 9 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.PAYM_DUE)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.PAYM_DUE) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.PAYM_DUE).
                    end.
                end.
            end.
            when 10 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVL)   then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVL) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVL).
                    end.
                end.
            end.
            when 11 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVL_OVD)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVL_OVD) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVL_OVD).
                    end.
                end.
            end.
            when 12 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_30)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_30) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_30).
                    end.
                end.
            end.
            when 13 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_MORE_30)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_MORE_30) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_MORE_30).
                    end.
                end.
            end.
            when 14 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_MORE_60)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_MORE_60) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_MORE_60).
                    end.
                end.
            end.
            when 15 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_MORE_90)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_MORE_90) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_MORE_90).
                    end.
                end.
            end.
            when 16 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_OUT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_OUT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_OUT).
                    end.
                end.
            end.
            when 17 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.LOAN_INT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.LOAN_INT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.LOAN_INT).
                    end.
                end.
            end.
            when 18 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_RP)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_RP) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_RP).
                    end.
                end.
            end.
            when 22 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.OVD_PENALTY_INT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.OVD_PENALTY_INT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.OVD_PENALTY_INT).
                    end.
                end.
            end.
            when 23 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_OVD_30)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_OVD_30) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_OVD_30).
                    end.
                end.
            end.
            when 24 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_OVD_MORE_30)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_OVD_MORE_30) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_OVD_MORE_30).
                    end.
                end.
            end.
            when 25 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_OVD_MORE_60)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_OVD_MORE_60) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_OVD_MORE_60).
                    end.
                end.
            end.
            when 26 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_OVD_MORE_90)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_OVD_MORE_90) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_OVD_MORE_90).
                    end.
                end.
            end.
            when 27 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.INT_OVD_OUT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.INT_OVD_OUT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.INT_OVD_OUT).
                    end.
                end.
            end.
            when 29 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.SUMM_ALL_WRITING)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.SUMM_ALL_WRITING) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.SUMM_ALL_WRITING).
                    end.
                end.
            end.
            when 30 then do:
                find last txb.pc_crlim where txb.pc_crlim.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlim.id = pc_parname.id and txb.pc_crlim.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlim and txb.pc_crlim.daval = date(wrk-dat.DATE_LAST_REPAYMENT)  then next.
                if (not avail txb.pc_crlim) or (avail txb.pc_crlim and txb.pc_crlim.daval <> date(wrk-dat.DATE_LAST_REPAYMENT) and txb.pc_crlim.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-crlim.
                        b-crlim.acc = wrk-dat.CONTRACT_NUMBER.
                        b-crlim.dt = wrk-dat.dt.
                        b-crlim.id = pc_parname.id.
                        b-crlim.chval = "".
                        b-crlim.daval = date(wrk-dat.DATE_LAST_REPAYMENT).
                    end.
                end.
            end.
            when 31 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.LAST_SUMM_REPAYMENT)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.LAST_SUMM_REPAYMENT) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.LAST_SUMM_REPAYMENT).
                    end.
                end.
            end.
            when 32 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.SUMM_ALL_ACCRUAL_REWARD)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.SUMM_ALL_ACCRUAL_REWARD) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.SUMM_ALL_ACCRUAL_REWARD).
                    end.
                end.
            end.
            when 33 then do:
                find last txb.pc_crlimbal where txb.pc_crlimbal.acc = wrk-dat.CONTRACT_NUMBER and txb.pc_crlimbal.id = pc_parname.id and txb.pc_crlimbal.dt <= wrk-dat.dt no-lock no-error.
                if avail txb.pc_crlimbal and txb.pc_crlimbal.deval = st-de(wrk-dat.SUMM_ALL_RECEIVE_REWARD)  then next.
                if (not avail txb.pc_crlimbal) or (avail txb.pc_crlimbal and txb.pc_crlimbal.deval <> st-de(wrk-dat.SUMM_ALL_RECEIVE_REWARD) and txb.pc_crlimbal.dt <> wrk-dat.dt) then do:
                    do transaction:
                        create b-limbal.
                        b-limbal.acc = wrk-dat.CONTRACT_NUMBER.
                        b-limbal.dt = wrk-dat.dt.
                        b-limbal.id = pc_parname.id.
                        b-limbal.deval = st-de(wrk-dat.SUMM_ALL_RECEIVE_REWARD).
                    end.
                end.
            end.
        end case.
    end.
end.

