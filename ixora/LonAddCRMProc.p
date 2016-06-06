/*
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        --/--/2011
 * BASES
        BANK COMM TXB
 * CHANGES
*/

DEF SHARED VAR vCif AS CHAR NO-UNDO.
DEF SHARED VAR vStaffId AS CHAR NO-UNDO.
DEF SHARED VAR vPasePier AS CHAR NO-UNDO.
DEF SHARED VAR vGoal AS CHAR NO-UNDO.
DEF SHARED VAR vLongrp AS INTEGER.
DEF SHARED VAR vGua AS CHAR NO-UNDO.
DEF SHARED VAR vAaa AS CHAR NO-UNDO.
DEF SHARED VAR vLcnt AS CHAR NO-UNDO.
DEF SHARED VAR vDateDog AS DATE NO-UNDO.
DEF SHARED VAR vRdt AS DATE NO-UNDO.
DEF SHARED VAR vDuedt AS DATE NO-UNDO.
DEF SHARED VAR vOpnnamt AS DECIMAL NO-UNDO.
DEF SHARED VAR vPrem AS DECIMAL NO-UNDO.
DEF SHARED VAR vDay AS INTEGER NO-UNDO.
DEF SHARED VAR vPlan AS INTEGER NO-UNDO.
DEF SHARED VAR vCrc AS INTEGER NO-UNDO.
DEF SHARED VAR vPenprem AS DECIMAL NO-UNDO.
DEF SHARED VAR vPenprem7 AS DECIMAL NO-UNDO.
DEF SHARED VAR vLonSec AS CHAR NO-UNDO.
DEF SHARED VAR vIsCifExist AS logical.
DEF SHARED VAR vIsAAAExist AS logical.
DEF SHARED VAR vLon AS CHAR NO-UNDO.
DEF SHARED VAR vAaaList AS CHAR NO-UNDO.
DEF SHARED VAR vAaaLast AS CHAR NO-UNDO.
DEF SHARED VAR vLonSecType AS INTEGER NO-UNDO.


DEF SHARED VAR vLndtkk AS DATE NO-UNDO. /*  Дата утверждения КК */
DEF SHARED VAR vLnprod AS CHAR NO-UNDO. /*Продукты из справочника*/

/*DEF SHARED VAR vLnrate AS CHAR NO-UNDO. из сетки  */


DEF SHARED VAR vErrorsProgress AS CHAR NO-UNDO.
def var londays as int no-undo.
def var dn2 as deci no-undo.
def var lonsrok as int no-undo.

DEF SHARED VAR g-today2 AS date NO-UNDO.
DEF NEW SHARED VAR s-lgr AS char.

find first txb.cif where txb.cif.cif = vCif no-lock no-error.
    if not avail txb.cif then
        vIsCifExist = false.
    else
        vIsCifExist = true.

find last txb.aaa where (txb.aaa.cif = vCif) and (txb.aaa.aaa = vAaa) no-lock no-error.
    if not avail txb.aaa then
        vIsAAAExist = false.
    else
        vIsAAAExist = true.
vAaaList = "".
vAaaLast = "".
if vIsAAAExist = false and vIsCifExist then
do:
for each txb.aaa where txb.aaa.cif = vCif no-lock.
    vAaaList = vAaaList + txb.aaa.aaa + ",".
    end.
find last txb.aaa where txb.aaa.cif = vCif no-lock no-error.
    if avail txb.aaa then
        vAaaLast = aaa.aaa.
end.

if  (vIsCifExist) and  (vIsAAAExist = true) then
    do:
            find txb.longrp where txb.longrp.longrp = vLongrp no-lock no-error.
            find txb.gl of txb.longrp no-lock no-error.
            /*gl.gl = 141120           05115178   05115108 05115138 */

            run acng2(txb.gl.gl, false, output vLon).
            vErrorsProgress = vErrorsProgress + "Ошибка транзакции,".
            find txb.cif where txb.cif.cif = vCif no-lock no-error.
            do transaction on error undo, return:
                find txb.lon where txb.lon.lon eq vLon exclusive-lock.
                assign
                        /*lon.lon = vLon*/
                       txb.lon.grp = vLongrp
                       txb.lon.cif = vCif
                       txb.lon.aaa = vAaa
                       txb.lon.gl = longrp.gl
                       txb.lon.rdt = g-today2
                       txb.lon.extdt = today
                       txb.lon.base = "F"
                       txb.lon.prnmos = 2
                       txb.lon.who = vStaffId
                       txb.lon.whn = g-today2
                       txb.lon.prem = vPrem
                       txb.lon.duedt = vDuedt
                       txb.lon.loncat = 0
                       txb.lon.opnamt = vOpnnamt
                       txb.lon.crc = vCrc
                       txb.lon.gua = vGua
                       txb.lon.day = vDay
                       txb.lon.plan = vPlan
                       /*lon.basedy = get-pksysc-int ("pkbase") пересмотреть надо видимо*/
                       txb.lon.penprem = vPenprem
                       txb.lon.penprem7 = vPenprem7.
                       if (txb.cif.type = "P") then
                            txb.lon.clnsts = 1.
                        else
                        if (txb.cif.type = "B" and txb.cif.cgr = 403) then
                            txb.lon.clnsts = 2.
                        else
                            txb.lon.clnsts = 0.
                        txb.lon.sts = "A".
                create txb.loncon no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

                assign txb.loncon.lon = vLon
                       txb.loncon.cif =  vCif
                       txb.loncon.rez-char[9] = txb.cif.jss
                       txb.loncon.who = vStaffId
                       txb.loncon.pase-pier = vPasePier
                       txb.loncon.whn = g-today2
                       txb.loncon.objekts = vGoal
                       txb.loncon.lcnt = vLcnt  /*entry (1, pkanketa.rescha[1], ","). нумерация договоров вопрос открытый или вручную или автоматом*/
                       txb.loncon.sods1 = vPenprem.
                find first txb.lonstat no-lock.
                create txb.lonhar no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                assign txb.lonhar.lon = vLon
                       txb.lonhar.ln = 1
                       txb.lonhar.lonstat = txb.lonstat.lonstat
                       txb.lonhar.fdt = date(1, 1, 1901)
                       txb.lonhar.cif = vCif
                       txb.lonhar.akc = no
                       txb.lonhar.who = vStaffId
                       txb.lonhar.whn = g-today2.
                find first txb.lonhar where txb.lonhar.lon = vCif no-lock no-error.
                if not available txb.lonhar then do:
                    create txb.lonhar no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                    assign txb.lonhar.lon = vCif
                           txb.lonhar.ln = 2
                           txb.lonhar.fdt = date(1, 1, 1901)
                           txb.lonhar.cif = vCif
                           txb.lonhar.akc = no
                           txb.lonhar.finrez = 999999999999.99
                           txb.lonhar.who = vStaffId
                           txb.lonhar.whn = g-today2.
                end.
                find first txb.ln%his where txb.ln%his.lon = vLon no-lock no-error.
                if not avail txb.ln%his then do:
                    create txb.ln%his no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                    assign txb.ln%his.stdat = g-today2
                           txb.ln%his.who = vStaffId
                           txb.ln%his.whn = g-today2
                           txb.ln%his.lon = vLon
                           txb.ln%his.f0 = 1
                           txb.ln%his.intrate = txb.lon.prem
                           txb.ln%his.opnamt = txb.lon.opnamt
                           txb.ln%his.rdt = g-today2
                           txb.ln%his.duedt = txb.lon.duedt
                           txb.ln%his.cif = vCif
                           txb.ln%his.lcnt = txb.loncon.lcnt
                           txb.ln%his.gua = txb.lon.gua
                           txb.ln%his.grp = txb.lon.grp
                           txb.ln%his.loncat = txb.lon.loncat.
                end.

                run Lonsec1_(vLonSec,  vLon, vRdt, vDuedt, vCrc).

                for each txb.sub-dic where txb.sub-dic.sub = "lon" no-lock.
                    find first txb.sub-cod where txb.sub-cod.acc = vLon and txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = txb.sub-dic.d-cod use-index dcod  no-lock no-error .
                    if not avail txb.sub-cod then do:
                        create txb.sub-cod no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                        txb.sub-cod.acc = vLon.
                        txb.sub-cod.sub = "lon".
                        txb.sub-cod.d-cod = txb.sub-dic.d-cod .
                        txb.sub-cod.ccode = "msc" .
                        /*txb.sub-cod.rdt = g-today.*/
                    end.
                end.

/*lnovdcd */
    find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lnovdcd" and txb.sub-cod.acc = vLon no-error. /**/
    if avail txb.sub-cod  then
    do:
        if txb.lon.grp = 10 then /*Краткосрочные кредиты юр.лиц*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '25'. else txb.sub-cod.ccode = '33'.
            end.
        else
        if txb.lon.grp = 50 then /*Долгосрочные кредиты юр.лиц*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '26'. else txb.sub-cod.ccode = '34'.
            end.
        else
            if lookup(string(txb.lon.grp),'11,14,15,16') > 0 then /*11 Факторинг ЮЛ 14 Краткоср. ОК МСБ ЮЛ 15 Краткоср. ИК МСБ ЮЛ 16 Краткоср. МСБ ЮЛ упрощ.*/
                do:
                    if txb.lon.crc = 1 then txb.sub-cod.ccode = '27'. else txb.sub-cod.ccode = '35'.
                end.
        else
        if lookup(string(txb.lon.grp),'54,55,56') > 0 then /*54Долгоср. ОК МСБ ЮЛ 55 Долгоср. ИК МСБ ЮЛ  56 Долгоср. МСБ ЮЛ упрощ. */
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '28'. else txb.sub-cod.ccode = '36'.
            end.
        else
        if lookup(string(txb.lon.grp),'20,81') > 0 then /*20 Краткосрочные кредиты физ.лиц  81 Краткоср. кредиты сотрудников*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '29'. else txb.sub-cod.ccode = '37'.
            end.
        else
        if lookup(string(txb.lon.grp),'60,82') > 0 then /*60 Долгосрочные кредиты физ.лиц  82 Долгоср. кредиты сотрудников*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '30'. else txb.sub-cod.ccode = '38'.
            end.
        else
        if lookup(string(txb.lon.grp),'21,24,25,26') > 0 then /* 21 Факторинг ИП 24 Краткоср. ОК МСБ ИП 25 Краткоср. ИК МСБ ИП 26 Краткоср. МСБ ИП упрощ.*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '31'. else txb.sub-cod.ccode = '39'.
            end.
        else
        if lookup(string(txb.lon.grp),'64,65,66') > 0 then /*64 Долгоср. ОК МСБ ИП  65 Долгоср. ИК МСБ ИП  66 Долгоср. МСБ ИП упрощ.*/
            do:
                if txb.lon.crc = 1 then txb.sub-cod.ccode = '32'. else txb.sub-cod.ccode = '40'.
            end.
        else
        if txb.lon.grp = 70 then /*70 Овердрафты,предоставл.юр.лицам*/
            do:
                run day-360(txb.lon.rdt, txb.lon.duedt - 1,360,output londays,output dn2).
                if lon.crc = 1 then do:
                    if londays <= 360 then txb.sub-cod.ccode = '27'. else txb.sub-cod.ccode = '28'.
            end.
            else
            do:
                if londays <= 360 then txb.sub-cod.ccode = '35'. else txb.sub-cod.ccode = '36'.
            end.
        end.
        else
        if txb.lon.grp = 80 then /*80 Овердрафты,предостав.физ.лицам*/
            do:
                run day-360(txb.lon.rdt,txb.lon.duedt - 1,360,output londays,output dn2).
                if txb.lon.crc = 1 then do:
                    if londays <= 360 then txb.sub-cod.ccode = '31'. else txb.sub-cod.ccode = '32'.
            end.
            else
            do:
                if londays <= 360 then txb.sub-cod.ccode = '39'. else txb.sub-cod.ccode = '40'.
            end.
    end.

/*Lnshifr */
    find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lnshifr" and txb.sub-cod.acc = vLon no-error. /**/
    if avail txb.sub-cod  then
    do:
        if txb.lon.grp = 10 then do:
            if txb.lon.crc = 1 then sub-cod.ccode = '01'. else txb.sub-cod.ccode = '09'.
        end.
        else
        if txb.lon.grp = 50 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '02'. else txb.sub-cod.ccode = '10'.
        end.
        else
        if lookup(string(txb.lon.grp),'11,14,15,16') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '03'. else txb.sub-cod.ccode = '11'.
        end.
        else
        if lookup(string(txb.lon.grp),'54,55,56') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '04'. else txb.sub-cod.ccode = '12'.
        end.
        else
        if lookup(string(txb.lon.grp),'20,81') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '05'. else txb.sub-cod.ccode = '13'.
        end.
        else
        if lookup(string(txb.lon.grp),'60,82') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '06'. else txb.sub-cod.ccode = '14'.
        end.
        else
        if lookup(string(txb.lon.grp),'21,24,25,26') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '07'. else txb.sub-cod.ccode = '15'.
        end.
        else
        if lookup(string(txb.lon.grp),'64,65,66') > 0 then do:
            if txb.lon.crc = 1 then txb.sub-cod.ccode = '08'. else txb.sub-cod.ccode = '16'.
        end.
        else
        if txb.lon.grp = 70 then do:
            run day-360(txb.lon.rdt,txb.lon.duedt - 1,360,output londays,output dn2).
            if lon.crc = 1 then do:
                if londays <= 360 then txb.sub-cod.ccode = '03'. else txb.sub-cod.ccode = '04'.
            end.
            else do:
                if londays <= 360 then txb.sub-cod.ccode = '11'. else txb.sub-cod.ccode = '12'.
            end.
        end.
        else
        if txb.lon.grp = 80 then
            do:
                run day-360(txb.lon.rdt,txb.lon.duedt - 1,360,output londays,output dn2).
                if txb.lon.crc = 1 then
                    do:
                        if londays <= 360 then txb.sub-cod.ccode = '07'. else txb.sub-cod.ccode = '08'.
                    end.
                    else
                    do:
                        if londays <= 360 then txb.sub-cod.ccode = '15'. else txb.sub-cod.ccode = '16'.
                    end.
            end.
    end.

/*lnsrok */
    find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lnsrok" and txb.sub-cod.acc = vLon no-error. /**/
    if avail txb.sub-cod  then
    do:
        lonsrok = ABS (lon.duedt - lon.rdt).
        if DAY (lon.duedt) = DAY (lon.rdt) and MONTH (lon.duedt) = MONTH (lon.rdt) then
            lonsrok = 365 * ABS (YEAR (lon.duedt) - YEAR (lon.rdt)).
        if lonsrok <= 30 then
            sub-cod.ccode = "01".
        else
        if lonsrok <= 90 then
            sub-cod.ccode = "02".
        else
        if lonsrok <= 180 then
            sub-cod.ccode = "03".
        else
        if lonsrok <= 365 then
            sub-cod.ccode = "04".
        else
        if lonsrok <= 1095 then
            sub-cod.ccode = "05".
        else
        if lonsrok <= 1825 then
            sub-cod.ccode = "06".
        else
        if lonsrok <= 3650 then
            sub-cod.ccode = "07".
        else
            sub-cod.ccode = "08".
    end.

/*Lndtkk*/
    if string(vLndtkk) <> "" then
        do:
            find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lndtkk" and txb.sub-cod.acc = vLon no-error. /**/
            if avail txb.sub-cod  then
                do:
                    sub-cod.rcode = string(vLndtkk).
                end.
        end.

/*Lnprod*/
    if vLnprod <> "" then
        do:
            find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lnprod" and txb.sub-cod.acc = vLon no-error. /**/
            if avail txb.sub-cod  then
                do:
                    sub-cod.ccode = vLnprod.
                end.
        end.


/*lonkb*/
    find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lonkb" and txb.sub-cod.acc = vLon no-error. /**/
    if avail txb.sub-cod  then
        do:
            sub-cod.ccode = "01".
        end.

end.


                /*find txb.ofc where txb.ofc.ofc = vStaffId no-lock no-error.*/
        vErrorsProgress = "".

        end.
        end.
        else

                vLon = "".

procedure WriteError:
DEF VAR i AS INTEGER NO-UNDO.
IF ERROR-STATUS:ERROR THEN
    DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        vErrorsProgress = vErrorsProgress + string(ERROR-STATUS:GET-MESSAGE(i)) + ",".
    END.
end procedure.

procedure Lonsec1_:
DEF input parameter pLonSec as char.
DEF input parameter pLon as char.
DEF input parameter pRdt as date.
DEF input parameter pDuedt as date.
DEF input parameter pCrc as integer.

DEF VAR memptrDoc AS MEMPTR.
DEF VAR hdoc AS HANDLE.
DEF VAR hRoot1 AS HANDLE.
DEF VAR hRoot2 AS HANDLE.
DEF VAR hRoot3 AS HANDLE.
DEF VAR hRoot4 AS HANDLE.
DEF VAR xmlText AS CHAR.
DEF VAR indx AS INT.
DEF VAR indx2 AS INT.
DEF VAR iNumFields AS INT.
CREATE X-DOCUMENT hdoc.
CREATE X-NODEREF hRoot1.
CREATE X-NODEREF hRoot2.
CREATE X-NODEREF hRoot3.
CREATE X-NODEREF hRoot4.
SET-SIZE(memptrDoc) = 2097152.
xmlText = pLonSec.
PUT-STRING(memptrDoc, 1) = trim(xmlText).
hdoc:LOAD("memptr", memptrDoc, FALSE).
hdoc:GET-DOCUMENT-ELEMENT(hRoot1).
DEF VAR st as CHAR.
DEF VAR iLn as INTEGER.
REPEAT indx = 1 TO hRoot1:NUM-CHILDREN:
    hRoot1:GET-CHILD(hRoot2, indx).
    create txb.lonsec1 no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
           txb.lonsec1.lon = pLon.
           txb.lonsec1.fdt = pRdt.
           txb.lonsec1.tdt = pDuedt.
           txb.lonsec1.crc = pCrc.
           txb.lonsec1.lonsec = vLonSecType.
    REPEAT indx2 = 1 TO hRoot2:NUM-CHILDREN:
        hRoot2:GET-CHILD(hRoot3, indx2).
        hRoot3:GET-CHILD(hRoot4, 1).
        st = trim(hRoot3:NAME).
        if (st = "ln") then
            do:
                iLn = integer(trim(hRoot4:NODE-VALUE)).
                txb.lonsec1.ln  = iLn.
            end.
        else
        if (st = "prm") then
            txb.lonsec1.prm = trim(hRoot4:NODE-VALUE).
        else
        if (st = "secamt") then
            txb.lonsec1.secamt = DECIMAL(trim(hRoot4:NODE-VALUE)).
        else
        if (st = "vieta") then
            txb.lonsec1.vieta = trim(hRoot4:NODE-VALUE).
        else
        if (st = "pielikums") then
            txb.lonsec1.pielikums[1] = trim(hRoot4:NODE-VALUE).
        else
        if (st = "cif2") then
            run Cifs (trim(hRoot4:NODE-VALUE), pLon, iLn).
    END.

END.


end procedure.

procedure Cifs:
DEF input parameter pCifsList as char.
DEF input parameter pLon as char.
DEF input parameter pLn as integer.
DEF VAR st as char.
DEF VAR iCount as integer.
/*
st = "id00852,id00853,id00854".
*/
REPEAT iCount = 1 TO NUM-ENTRIES(pCifsList):
    create txb.lonsec1zal no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
    txb.lonsec1zal.lon = pLon.
    txb.lonsec1zal.ln = pLn.
    txb.lonsec1zal.cif = ENTRY(iCount, pCifsList).
END.
end procedure.