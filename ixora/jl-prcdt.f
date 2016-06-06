/* jl-prct.f
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
 * BASES
        BANK COMM
 * CHANGES
*/

/**    подобие jl-prcd.f **/

/*
                        22/12/2011 Luiza при выводе курса покупки добавила условие проверки была ли конвертация валюты
*/

def shared var v-point like point.point.

def var vi as inte.
def var ss as inte.

def var v-datastr as char format "x(20)".
def var v-datastrkz as char format "x(20)".

/*----------------------06.06.01-----------------------------------*/
def var        decAmount like xin.
def var        strAmount as char format "x(80)".
def var        temp as char.
def var        strTemp as char.
def var        str1 as char format "x(80)".
def var        str2 as char format "x(80)".
/*-------------------------------------------------------------*/
def var v-chk as logical initial no.

/*----------------------27.08.01-----------------------------------*/
def var        decAmountT like xin.
def buffer drate for crc.
/*-----------------------------------------------------------------*/

define variable obmenGL2 as integer.
define variable v-opkkas as char.
def var v-iscash as logical.
def var j as inte init 0.
def var k as inte init 0.

find sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find point where point.point = v-point no-lock no-error.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
def buffer bb-sysc for sysc.
find bb-sysc where bb-sysc.sysc = "CASHGL500" no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.


sxin = 0.
sxout = 0.

find first ljl of jh where ljl.gl = sysc.inval or ljl.gl = bb-sysc.inval no-lock no-error.
v-iscash = avail ljl.

/*find jh where jh.jh eq s-jh no-lock no-error.
if jh.sub eq "jou" then v_doc = jh.ref.*/

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval or ljl.gl = bb-sysc.inval) and ljl.dc = "D" no-lock.

    put skip(3) space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
    run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz).
    put unformatted string (jh.jh) + "/" + v_doc + "/" + "Dok.Nr." + trim(refn) + " /" + ofc.name +
      "  " + trim(v-datastr) skip.

    put
    "==========================================================================="
                                                     skip(1).
    put
    "ВАЛЮТА                                      ПРИХОД                РАСХОД"   skip.
    put unformatted fill ("-", 77) skip.
    find crc of ljl.
    put crc.des ljl.dam 0 skip.
    put unformatted skip(1)
    space(22) "ИТОГО ПРИХОД" ljl.dam format "z,zzz,zzz,zz9.99" skip(2).
    decAmount = ljl.dam.
    put 'Сумма прописью: '.
    temp = string (decAmount).
    if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then
        temp = substring(temp,2,1) + "0".
    end.
    else temp = "00".

    strTemp = string(truncate(decAmount,0)).

    run Sm-vrd(input decAmount, output strAmount).
    run sm-wrdcrc(input strTemp,input temp,input crc.crc,output str1,output str2).
    strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
    if length(strAmount) > 80 then do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put str1 skip str2 skip(0).
    end.
    else  put strAmount skip(0).
    if crc.crc <> 1 then do:

        find first drate where drate.crc = crc.crc no-lock no-error.
        if avail drate then do:
            decAmountT = decAmount * drate.rate[1].
        end.

        temp = string (decAmountT).
        if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
            temp = substring(temp, length(temp) - 1, 2).
            if num-entries(temp,".") = 2 then
            temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".

        strTemp = string(truncate(decAmountT,0)).

        run Sm-vrd(input decAmountT, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmount = "(" + strAmount + " " + str1 + " " + temp + " " + str2 + ")".

        if length(strAmount) > 80 then do:
            str1 = substring(strAmount,1,80).
            str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
            put str1 skip str2 skip(0).
        end.
        else  put strAmount skip(0).
    end.
/*------------------------------------------------------------------------------*/
    define buffer l_crc for crc.
    define buffer m_crc for crc.
    define buffer n_crc for crc.
    find l_crc where l_crc.crc eq joudoc.drcur no-lock.
    find m_crc where m_crc.crc eq joudoc.crcur no-lock.
    find n_crc where n_crc.crc eq 1 no-lock.
    if joudoc.brate <> 1  and conve then put "  " +
        l_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
        " " + n_crc.code + "/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
        l_crc.code format "x(80)" skip.

    if joudoc.srate <> 1  and conve then put "  " +
        m_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
        " " + n_crc.code + "/ " + trim (string (joudoc.sn, "zzzzzzz")) + " " +
        m_crc.code format "x(80)" skip.

    put skip(1) drek[1] format "x(75)" skip(2).

    if length (trim (drek[2])) ne 0 then put drek[2] skip.
    if length (trim (drek[4])) ne 0 then put drek[4] skip(1).
    if length (trim (drek[5])) ne 0 then put drek[5] skip.
    /* ------ 05/06/2002 ------ */
    if length (trim (drek[6]))  ne 0 then put drek[6]  skip.
    if length (trim (drek1[1])) ne 0 then put drek1[1] skip.
    if length (trim (drek1[2])) ne 0 then put drek1[2] skip.
    if length (trim (drek1[3])) ne 0 then put drek1[3] skip.
    if length (trim (drek1[4])) ne 0 then put drek1[4] skip.
    if length (trim (drek1[5])) ne 0 then put drek1[5] skip.
/* ------ 05/06/2002 ------ */
    put skip(1).
    if ljl.dc eq "D" /*and  not ljl.rem[1] begins "Комиссия" */ then do:
        run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
        drek[8]  = "КОД : " + KOd .
        drek[10] = "КНП : " + KNP .
        run GetEKNP(s-jh, ljl.ln + 1, "C", input-output KOd, input-output KBe, input-output KNP).
            /*put KOd skip KBe skip KNP skip.*/
        drek[9]  = "КБе : " + KBe .
        if not ljl.rem[1] begins "Комиссия за:"  then  put drek[8] skip drek[9] skip drek[10] skip.

    end.
    if ljl.dc eq "D" then do:
        put skip(1).
        if length (trim (drek[7])) ne 0 then put drek[7] skip.

        put skip.
        put "============================================================================="  skip(1).

        put  unformatted ljl.rem[1] skip.
      /* if ljl.rem[1] begins "Комиссия" then put  unformatted ljl.rem[1] skip.
        else do:
            for each remfile:
              put unformatted remfile.rem  skip.
            end.
            put skip(1).
        end.*/
    end.
end.

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval or ljl.gl = bb-sysc.inval)  no-lock  break by ljl.crc by ljl.dc:

    if first-of(ljl.dc) then do:
        if ljl.dc eq "C" then do:
            put skip(3) space(20) "РАСХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).

            run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz).
            put unformatted string (jh.jh) + "/" + v_doc + "/" +
              "Dok.Nr." + trim(refn) + " /" + ofc.name + " " + trim(v-datastr) skip.

            put
"============================================================================="
                                                         skip(1).
            put
    "ВАЛЮТА                                      ПРИХОД                РАСХОД"
                                         skip.
            put unformatted fill ("-", 77) skip.
        end.
    end.

    find crc of ljl.
    if ljl.dam gt 0 then do:
        xin = ljl.dam.
        xout = 0.
        intot = intot + xin.
    end.
    else do:
        xin = 0.
        xout = ljl.cam.
        outtot = outtot + xout.
    end.
    if ljl.dc eq "C" then put crc.des xin xout skip.
    sxout = sxout + xout.
    if last-of(ljl.dc) then do:
        if ljl.dc eq "C" then do:
            put unformatted skip(1)
            space(43) "ИТОГО РАСХОД" sxout format "z,zzz,zzz,zz9.99" skip(2).

/*-------------------------------06.06.01---------------------------------------*/
            if sxin = 0 then decAmount = sxout. else decAmount = sxin.
            put 'Сумма прописью: '.  /*skip(2).*/
            temp = string (decAmount).
            /* temp = substring(temp,1,length(temp),"character"). */
            if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
                temp = substring(temp, length(temp) - 1, 2).
                if num-entries(temp,".") = 2 then
                temp = substring(temp,2,1) + "0".
            end.
            else temp = "00".

            strTemp = string(truncate(decAmount,0)).

            run Sm-vrd(input decAmount, output strAmount).
            run sm-wrdcrc(input strTemp,input temp,input crc.crc,output str1,output str2).
            strAmount = strAmount + " " + str1 + " " + temp + " " + str2.



            if length(strAmount) > 80
            then do:
                str1 = substring(strAmount,1,80).
                str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
                put str1 skip str2 skip(0).
            end.
            else  put strAmount skip(0).
    /*------------------------------------------------------------------------------*/

    /*----------------------27.08.01------------------------------------------------*/
            if crc.crc <> 1 then do:

                find first drate where drate.crc = crc.crc no-lock no-error.
                if avail drate then do:
                    decAmountT = decAmount * drate.rate[1].
                end.

                temp = string (decAmountT).
                if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
                    temp = substring(temp, length(temp) - 1, 2).
                    if num-entries(temp,".") = 2 then
                    temp = substring(temp,2,1) + "0".
                end.
                else temp = "00".

                strTemp = string(truncate(decAmountT,0)).

                run Sm-vrd(input decAmountT, output strAmount).
                run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
                strAmount = "(" + strAmount + " " + str1 + " " + temp + " " + str2 + ")".

                if length(strAmount) > 80 then do:
                    str1 = substring(strAmount,1,80).
                    str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
                    put str1 skip str2 skip(0).
                end.
                else  put strAmount skip(0).
            end.
/*------------------------------------------------------------------------------*/
            put skip(1) drek[1] format "x(75)" skip(2).
        end.
        if ljl.dc eq "C" and length (trim (drek[3])) ne 0 then put drek[3] skip.
        if ljl.dc eq "C" then do:
            if length (trim (drek[4])) ne 0 then put drek[4] skip(1).
            if length (trim (drek[5])) ne 0 then put drek[5] skip.
        /* ------ 05/06/2002 ------ */
        /* if ljl.dc eq "C" then put drek[6] skip. - надо печатать и на приходном, и на расходном ордерах */

    /* ------ 05/06/2002 ------ */
            put skip(1).
        end.
        if  ljl.dc eq "C" and KOd + KBe + KNP <> "" and not ljl.rem[1] begins "Комиссия за" then do:
            put drek[8] skip drek[9] skip drek[10] .
        end.
        if  ljl.dc eq "C" then do:
            put skip(1).
            if length (trim (drek[7])) ne 0 then put drek[7] .
            put skip.
            put "============================================================================="  skip(1).
            /*for each remfile:
              put unformatted remfile.rem + "комиссия" skip.
            end.
            put skip(1).*/
            v-chk = no.
            if ljl.rem[1] <> "" then do:
                put unformatted "Примечан.: " + ljl.rem[1] skip.
                put skip(1).
            end.
            else do:
                for each remfile:
                  put unformatted remfile.rem  skip.
                end.
                put skip(1).
            end.
        end.
    end.
    if last-of (ljl.crc) then do:
       sxin = 0.   sxout = 0.
    end.
end.
/* by sasco */
put "============================================================================="   skip(1).
find first ofc where ofc.ofc = g-officer no-lock no-error.
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).

