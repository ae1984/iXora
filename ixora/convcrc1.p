/* comnvcrc1.p
 * MODULE
        Конвертация
 * DESCRIPTION
        Копирование кросс-курсов валют на филиалы при изменениях в головном
 * RUN

 * CALLER
        convcrc.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        25.12.08 marinav
 * CHANGES
        26/10/2010 k.gitalov добавил USD->RUB RUB->USD EUR->RUB RUB->EUR
        15.05.2012 k.gitalov добавил валюту ZAR по сз от 14.05.2012
        09.07.2012 damir - добавил валюту CAD по сз от 14.05.2012.
*/


find txb.sysc where txb.sysc.sysc = 'OURBNK' no-lock no-error.
if avail txb.sysc then do:
    if txb.sysc.chval = "TXB00" then do:
        /* message "ЦО не обрабатывается!" view-as alert-box.*/
        return.
    end.
end.
else do: message "Нет переменной OURBNK" view-as alert-box. return. end.

find txb.sysc  where txb.sysc.sysc  = 'ECUSD' no-error.
find bank.sysc where bank.sysc.sysc = 'ECUSD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCUSD'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCUSD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCUSD' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCUSD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCUSD' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCUSD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECEUR' no-error.
find bank.sysc where bank.sysc.sysc = 'ECEUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCEUR'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCEUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCEUR' no-error.
find bank.sysc where bank.sysc.sysc = 'ERCEUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCEUR' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCEUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECRUR' no-error.
find bank.sysc where bank.sysc.sysc = 'ECRUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCRUR'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCRUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCRUR'  no-error.
find bank.sysc where bank.sysc.sysc = 'ERCRUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCRUR' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCRUR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCGBP' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCGBP' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCGBP' no-error.
find bank.sysc where bank.sysc.sysc = 'ERCGBP' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCGBP' no-error.
find bank.sysc where bank.sysc.sysc = 'OCGBP' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECGBP' no-error.
find bank.sysc where bank.sysc.sysc = 'ECGBP' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

/**/
find txb.sysc  where txb.sysc.sysc  = 'ECSEK' no-error.
find bank.sysc where bank.sysc.sysc = 'ECSEK' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCSEK'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCSEK' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCSEK' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCSEK' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCSEK' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCSEK' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECAUD' no-error.
find bank.sysc where bank.sysc.sysc = 'ECAUD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCAUD'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCAUD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCAUD' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCAUD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCAUD' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCAUD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECCHF' no-error.
find bank.sysc where bank.sysc.sysc = 'ECCHF' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCCHF'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCCHF' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCCHF' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCCHF' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCCHF' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCCHF' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECZAR' no-error.
find bank.sysc where bank.sysc.sysc = 'ECZAR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCZAR'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCZAR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCZAR' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCZAR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCZAR' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCZAR' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ECCAD' no-error.
find bank.sysc where bank.sysc.sysc = 'ECCAD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'OCCAD'  no-error.
find bank.sysc where bank.sysc.sysc = 'OCCAD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ERCCAD' no-error .
find bank.sysc where bank.sysc.sysc = 'ERCCAD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = 'ORCCAD' no-error.
find bank.sysc where bank.sysc.sysc = 'ORCCAD' no-lock no-error.
txb.sysc.deval = bank.sysc.deval.

find txb.sysc  where txb.sysc.sysc  = '2to3c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to3c'.
end.
find bank.sysc where bank.sysc.sysc = '2to3c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '3to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '3to2c'.
end.
find bank.sysc where bank.sysc.sysc = '3to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to1c'  no-error.
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to1c'.
end.
find bank.sysc where bank.sysc.sysc = '2to1c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '1to2c'  no-error.
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '1to2c'.
end.
find bank.sysc where bank.sysc.sysc = '1to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '3to1c'  no-error.
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '3to1c'.
end.
find bank.sysc where bank.sysc.sysc = '3to1c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '1to3c'  no-error.
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '1to3c'.
end.
find bank.sysc where bank.sysc.sysc = '1to3c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '2to4c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '2to4c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to4c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.


find bank.sysc where bank.sysc.sysc = '4to2c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '4to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '4to2c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.


find bank.sysc where bank.sysc.sysc = '3to4c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '3to4c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '4to2c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.


find bank.sysc where bank.sysc.sysc = '4to3c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '4to3c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '4to3c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '2to6c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '2to6c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to6c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '6to2c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '6to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '6to2c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '3to6c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '3to6c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '3to6c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '6to3c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '6to3c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '6to3c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '4to6c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '4to6c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '4to6c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find bank.sysc where bank.sysc.sysc = '6to4c' no-lock no-error.
find txb.sysc  where txb.sysc.sysc  = '6to4c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '6to4c'.
    txb.sysc.des = bank.sysc.des.
end.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to7c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to7c'.
end.
find bank.sysc where bank.sysc.sysc = '2to7c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to8c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to8c'.
end.
find bank.sysc where bank.sysc.sysc = '2to8c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to9c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to9c'.
end.
find bank.sysc where bank.sysc.sysc = '2to9c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '7to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '7to2c'.
end.
find bank.sysc where bank.sysc.sysc = '7to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '8to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '8to2c'.
end.
find bank.sysc where bank.sysc.sysc = '8to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '9to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '9to2c'.
end.
find bank.sysc where bank.sysc.sysc = '9to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to10c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to10c'.
end.
find bank.sysc where bank.sysc.sysc = '2to10c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '10to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '10to2c'.
end.
find bank.sysc where bank.sysc.sysc = '10to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '2to11c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '2to11c'.
end.
find bank.sysc where bank.sysc.sysc = '2to11c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.

find txb.sysc  where txb.sysc.sysc  = '11to2c' no-error .
if not avail txb.sysc then do:
    create txb.sysc.
    txb.sysc.sysc = '11to2c'.
end.
find bank.sysc where bank.sysc.sysc = '11to2c' no-lock no-error.
txb.sysc.chval = bank.sysc.chval.
