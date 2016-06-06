/* sel_screen.p
 * MODULE
        Экран клиента
 * DESCRIPTION
        Сборка строки для заполнения шаблонов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.5
 * AUTHOR
        10/07/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        26/07/2012 dmitriy - исправил поиск даты следующего погашения по кредиту (не всегда записан в хронологическом порядке)
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

{global.i}

def input parameter t-mask as char.
def input parameter t-cif  as char.
def input parameter t-acc  as char.

def output parameter v-res as char.

def temp-table wrk  /* для графика погашения по кредиту */
    field dt as date
    index idx is primary dt.

def var scr-newaaa    as char init "newaaa1,aaadepo2".
def var scr-newdepo   as char init "newdepo1,newdepo2".
def var scr-aaamove   as char init "extract1,extract2".
def var scr-statedepo as char init "statedepo1,statedepo2,statedepo3".
def var scr-pyaacc    as char init "payacc1,paytrans2".
def var scr-paytrans  as char init "transfer,paytrans2".
def var scr-qtrans    as char init "qtransfer1,qtransfer2".

def var v-mask as char.
/*def var v-res  as char.*/

def var list1 as char initial
    "246,151,152,153,154,155,156,157,158,171,172,173,174,175,160,161,249,204,202,208,222,247,248,176,177,130,131,132".

def var list2 as char initial
    "484,485,486,487,488,489,478,479,480,481,482,483,518,519,520,A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,B09,B10,B11,B15,B16,B17,B18,B19,B20".

def var vbal as deci init 0.
def var vavl as deci init 0.
def var vhbal as deci init 0.
def var vfbal as deci init 0.
def var vcrline as deci init 0.
def var vcrlused as deci init 0.
def var vooo as char.

def var TCIFNAME as char.
def var TINN as char.
def var TADDR as char.
def var TTEL as char.
def var TBOSS as char.
def var TBUKH as char.
def var TFRENDCIF as char.
def var TDOVDT as char.
def var TAAA as char.
def var TCRC as char.
def var TSUMM as char.
def var TDEPONAME as char.
def var TDEPOSUMM as char.
def var TDATE as char.
def var TDATE1 as char.
def var TDATE2 as char.
def var TDATE3 as char.
def var TRATE1 as char.
def var TRATE2 as char.
def var TRATE3 as char.
def var TDEPORATE as char.
def var TPROLONG as char.
def var TRATEHIST as char.
def var TPAYBON as char.
def var TCALCBON as char.
def var TCREDRATE as char.
def var TREST as char.
def var TPEN as char.
def var TPAYDATE as char.
def var TDOCNO as char.
def var TPRIOR as char.
def var TKOD as char.
def var TRECAAA as char.
def var TRACNAME as char.
def var TRECINN as char.
def var TKBE as char.
def var TRBANK as char.
def var TRBANKBIK as char.
def var TKORBANK as char.
def var TKROAAA as char.
def var TREM as char.
def var TKNP as char.
def var TKBK as char.
def var TAAA1 as char.
def var TAAA2 as char.
def var TAAA3 as char.
def var TCRC1 as char.
def var TCRC2 as char.
def var TCRC3 as char.
def var TSUMM1 as char.
def var TSUMM2 as char.
def var TSUMM3 as char.
def var TTYPE as char.
def var TCOMSUMM as char.
def var TCOMCRC as char.
def var TDEB as char.
def var TCRED as char.
def var TRECNAME as char.
def var TKORAAA as char.
def var TRATE as char.
def var TVALDATE as char.
def var TLSTPAY as char.
def var TSUMMIN as char.
def var TSUMMOUT as char.
def var TCONAGENT as char.
def var TRECCOUNTRY as char.
def var TRATETYPE as char.
def var TUSD1 as char.
def var TUSD2 as char.
def var TEUR1 as char.
def var TEUR2 as char.
def var TRUB1 as char.
def var TRUB2 as char.

def var v-bal as deci init 0.
def var v-ec as char.
def var str_hist as char.
def var v-od as deci.
def var v-dt as date.
def var v-dt1 as date.
def var v-dt2 as date.
def var v-list as char.
def var v-list2 as char.
def var v-sel as int.
def var v-ok as int.
def var i as integer.
def var v-shtraf as deci.
def var v-ks as char.
def var v-ks1 as char.
def var dt1 as date.
def var dt2 as date.

define frame fmask3
    v-dt  format "99/99/9999" label "Введите дату"
with side-labels centered row 15.

define frame fmask7
    TDOCNO format "x(10)" label "Введите номер документа"
with side-labels centered row 15.

define frame fmask8
    v-dt1 format "99/99/9999" label "С"
    v-dt2 format "99/99/9999" label "По"
with side-labels centered row 15.

define frame fmask9
    TDOCNO format "x(10)" label "Введите номер документа"
with side-labels centered row 15.

def var MaxPage as int.
def var pages as char label "страница".
def button prev-button label "Предыдущая".
def button next-button label "Следующая".
def button close-button label "Закрыть".

define frame Form1
    Pages skip
    "----------------------------------" skip
    prev-button next-button close-button
 WITH SIDE-LABELS centered overlay row 15 TITLE "Экран клиента".


v-ok = 0.

case t-mask:
    when "newaaa1" then do: /* текущий счет 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TADDR + "&" + TTEL + "&" + TAAA + "&" + TCRC.
    end.

    when "aaadepo2" then do: /* текущий счет 2/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TBOSS + "&" + TBUKH + "&" + TFRENDCIF + "&" + TDOVDT.
    end.

    when "newdepo1" then do: /* сберегательный счет 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TADDR + "&" + TTEL + "&" + TDEPONAME + "&" + TDEPOSUMM + "&" + TCRC + "&" + TDATE1 + "&" + TDATE2 + "&" + TDEPORATE + "&" + TAAA.
    end.

    when "aaadepo2" then do: /* сберегательный счет 2/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TBOSS + "&" + TBUKH + "&" + TFRENDCIF + "&" + TDOVDT.
    end.

    when "stateaaa" then do: /* остатки по счету */
        run find_info.
        v-res = TCIFNAME + "&" + TDATE + "&" +  TAAA + "&" + TCRC + "&" + TSUMM.
    end.

    when "extract1" then do: /* движение по счету 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TAAA + "&" + TCRC + "&" + TDATE1 + "&" + TDATE2 + "&" + TLSTPAY + "&" + TSUMMIN + "&" + TSUMMOUT.
    end.

    when "extract2" then do: /* движение по счету 2/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TDATE + "&" + TDEB + "&" + TCRED + "&" + TREM + "&" + TCONAGENT.
    end.

    when "statedepo1" then do: /* состояние депозита 1/3 */
        run find_info.
        v-res = TCIFNAME + "&" + TDEPONAME + "&" + TDEPOSUMM + "&" + TCRC + "&" + TDATE1 + "&" + TDATE2 + "&" + TDEPORATE + "&" + TPROLONG + "&" + TPAYBON + "&" + TCALCBON.
    end.

    when "statedepo2" then do: /* состояние депозита 2/3 */
        run find_info.
        v-res = TCIFNAME + "&" + TDATE1 + "&" + TRATE1 + "&" + TDATE2 + "&" + TRATE2 + "&" + TDATE3 + "&" + TRATE3.
    end.

    when "statedepo3" then do: /* состояние депозита 3/3 */
        run find_info.
        v-res = TCIFNAME + "&" + TFRENDCIF + "&" + TDOVDT.
    end.

    when "newcred" then do: /* кредит */
        run find_info.
        v-res = TCIFNAME + "&" + TSUMM + "&" + TDATE1 + "&" + TDATE2 + "&" + TCREDRATE + "&" + TCRC + "&" + TREST + "&" + TPAYDATE.
    end.

    when "payacc1" then do: /* платежи со счета 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TDOCNO + "&" + TPRIOR + "&" + TAAA + "&" + TCRC + "&" + TSUMM + "&" + TKNP + "&" + TKBK + "&" + TVALDATE + "&" + TREM.
    end.

    when "paytrans2" then do: /* платежи со счета 2/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TRECNAME + "&" + TRECINN + "&" + TRBANKBIK + "&" + TRECAAA + "&" + TKBE + "&" + TRBANK + "&" + TKORBANK + "&" + TKORAAA.
    end.

    when "convdoc" then do: /* покупка/продажа ин.валюты */
        run find_info.
        v-res = TCIFNAME + "&" + TSUMM1 + "&" + TSUMM2 + "&" + TRATE + "&" + TTYPE + "&" + TSUMM3.
    end.

    when "transfer" then do: /* банковский перевод без открытия счета 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TSUMM + "&" + TCRC + "&" + TVALDATE + "&" + TKNP + "&" + TCOMSUMM + "&" + TREM.
    end.

    /* банковский перевод без открытия счета 2/2 */
    /*when "transfer" then do:
        run find_info.
        v-res = TCIFNAME + "&" + TRECNAME + "&" + TRECAAA + "&" + TKBE + "&" + TRECINN + "&" + TRBANKBIK + "&" + TRBANK + "&" + TKORBANK + "&" + TKORAAA.
    end.*/

    when "qtransfer1" then do: /* быстрый перевод 1/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TSUMM + "&" + TCRC + "&" + TCOMSUMM + "&" + TKNP + "&" + TREM.
    end.

    when "qtransfer2" then do: /* быстрый перевод 2/2 */
        run find_info.
        v-res = TCIFNAME + "&" + TRECNAME + "&" + TRECAAA + "&" + TRBANK + "&" + TRBANKBIK + "&" + TRECCOUNTRY.
    end.

    when "cifacc"then do: /* Взнос на счет / Снятие со счета */
        run find_info.
        v-res = TCIFNAME + "&" +  TSUMM + "&" + TAAA + "&" + TCOMSUMM + "&" + TREM.
    end.

    when "rates" then do: /* Курсы */
        run find_info.
        v-res = TRATETYPE + "&" + TUSD1 + "&" + TUSD2 + "&" + TRUB1 + "&" + TRUB2 + "&" + TEUR1 + "&" + TEUR2.
    end.
end case.

/*if v-ok = 1 and (t-mask = "newcred") then do:
    run to_screen(t-mask, v-res).
    v-list = "Закрыть экран клиента|".
    run sel2 ("Экран клиента",v-list , output v-sel).
    if v-sel = 1 then run to_screen( "default","").
end.*/



{to_screen.i}

procedure find_info:

    /* открытие текущего счета 1/2 */
    if t-mask = "newaaa1" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

            TADDR = "TADDR=" + replace(cif.addr[1], ",,",",").
            TADDR = replace(TADDR, "(KZ)","").

            TTEL = "TTEL=" + trim(cif.tel).
        end.

        find first aaa where aaa.aaa = t-acc and aaa.sta <> "C" no-lock no-error.
        if avail aaa then do:
            TAAA = "TAAA=" + aaa.aaa.

            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then
            TCRC = "TCRC=" + crc.code.
        end.
        else leave.

        v-ok = 1.
    end.

    /* открытие текущего счета 2/2 */
    if t-mask = "aaadepo2" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' and sub-cod.ccod = 'chief' no-lock no-error.
            if avail sub-cod then
            TBOSS = "TBOSS=" + UrlEncode(sub-cod.rcode).

            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk' and sub-cod.ccod = 'mainbk' no-lock no-error.
            if avail sub-cod then
            TBUKH = "TBUKH=" + UrlEncode(sub-cod.rcode).

            find last uplcif where uplcif.cif = cif.cif and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then do:
                TFRENDCIF = "TFRENDCIF=" + UrlEncode(uplcif.badd[1]).
                TDOVDT = "TDOVDT=" + string(uplcif.finday, "99.99.9999").
            end.
        end.
        v-ok = 1.
    end.

    /* Открытие сберегательного счета 1/2 */
    if t-mask = "newdepo1" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

            TADDR = "TADDR=" + replace(cif.addr[1], ",,",",").
            TADDR = replace(TADDR, "(KZ)","").
            TADDR = UrlEncode(TADDR).

            TTEL = "TTEL=" + trim(cif.tel).
        end.

        find first aaa where aaa.aaa = t-acc and aaa.sta <> "C" no-lock no-error.
        if avail aaa then do:
            TAAA = "TAAA=" + aaa.aaa.

            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then
            TCRC = "TCRC=" + crc.code.
            run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
            TSUMM = "TSUMM=" + string(vbal /*vhbal + vavl*/ , ">>>,>>>,>>>,>>9.99").
        end.
        else leave.

        run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
        TDEPOSUMM = "TDEPOSUMM=" + string(vbal, ">>>,>>>,>>>,>>9.99").
        TDATE1 = "TDATE1=" + string(aaa.lstmdt, "99.99.9999").

        /*find last accr where accr.aaa = t-acc and accr.rate <> decimal(TRATE1) and accr.rate <> decimal(TRATE2) no-lock no-error.
        if avail accr then TDATE2 = "TDATE2=" + string(accr.fdt, "99.99.9999").
        else  TDATE2 = "TDATE2=" + string(aaa.expdt, "99.99.9999").*/


        find first acvolt where acvolt.aaa = aaa.aaa no-lock no-error.
        if avail acvolt then do:
            if date(acvolt.x3) <> aaa.expdt then
            TDATE2 = "TDATE2=" + replace(acvolt.x3, "/", ".").
        end.

        find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr then
        TDEPONAME = "TDEPONAME=" + entry(1, lgr.des, " ").
        TDEPORATE = "TDEPORATE=" + string(aaa.rate) + UrlEncode(" %").
        v-ok = 1.
    end.

    /* Открытие сберегательного счета 2/2 */
    if t-mask = "aaadepo2" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' and sub-cod.ccod = 'chief' no-lock no-error.
            if avail sub-cod then
            TBOSS = "TBOSS=" + UrlEncode(sub-cod.rcode).

            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk' and sub-cod.ccod = 'mainbk' no-lock no-error.
            if avail sub-cod then
            TBUKH = "TBUKH=" + UrlEncode(sub-cod.rcode).

            find last uplcif where uplcif.cif = cif.cif and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then
            TFRENDCIF = "TFRENDCIF=" + UrlEncode(uplcif.badd[1]).

            find last uplcif where uplcif.cif = cif.cif and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then
            TDOVDT = "TDOVDT=" + string(uplcif.finday, "99.99.9999").
        end.
        v-ok = 1.
    end.

    /* Остатки по счету 1/1 */
    if t-mask = "stateaaa" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).
        end.

        find first aaa where aaa.aaa = t-acc and aaa.sta <> "C" no-lock no-error.
        if avail aaa then do:
            TAAA = "TAAA=" + aaa.aaa.

            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then
            TCRC = "TCRC=" + crc.code.
        end.
        else leave.

        update v-dt with frame fmask3.
        TDATE = "TDATE=" + string(v-dt, "99.99.9999").
        run lonbal3('cif', aaa.aaa, v-dt, "1", yes, output v-bal).
        TSUMM = "TSUMM=" + string(v-bal, ">>>,>>>,>>>,>>9.99").
        v-ok = 1.
    end.



    /* Движение по счету 1/2 */

    if t-mask = "extract1" then do:

        TDATE1 = "TDATE1=" + entry(2, t-acc, "|").
        TDATE1 = "TDATE2=" + entry(3, t-acc, "|").

        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).
        end.

        find first aaa where aaa.aaa = entry(1, t-acc, "|") and aaa.sta <> "C" no-lock no-error.
        if avail aaa then do:
            TAAA = "TAAA=" + aaa.aaa.

            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then
            TCRC = "TCRC=" + crc.code.
        end.
        else leave.
    end.



    /* Движение по счету 2/2 */

    if t-mask = "extract2" then do:
        run scr-extract (t-cif,entry(1, t-acc, "|"), date(entry(2, t-acc, "|")), date(entry(3, t-acc, "|"))) .
    end.



    /* состояние депозита 1/3 */

    if t-mask = "statedepo1" then do:

        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then do:
            TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

            find last uplcif where uplcif.cif = cif.cif and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then
            TFRENDCIF = "TFRENDCIF=" + UrlEncode(uplcif.badd[1]).
        end.

        find first aaa where aaa.aaa = t-acc no-lock no-error.

        TDEPOSUMM = "TDEPOSUMM=" + string(aaa.cr[1] - aaa.dr[1], ">>>,>>>,>>9.99").
        TDATE1 = "TDATE1=" + string(aaa.lstmdt, "99.99.9999").
        TDATE2 = "TDATE2=" + string(aaa.expdt, "99.99.9999").

        find first crc where crc.crc = aaa.crc no-lock no-error.
        if avail crc then
        TCRC = "TCRC=" + crc.code.

        find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr then
        TDEPONAME = "TDEPONAME=" + entry(1, lgr.des, " ").
        TDEPORATE = "TDEPORATE=" + string(aaa.rate) + UrlEncode(" %").

        find first acvolt where acvolt.aaa = aaa.aaa no-lock no-error.
        if avail acvolt then do:
            if /*date((acvolt.x1) > date("06/06/10")) and*/ date(acvolt.x3) <> aaa.expdt then
            TPROLONG = "TPROLONG=" + replace(acvolt.x3, "/", ".").
        end.

        TPAYBON = "TPAYBON=" + string(aaa.dr[2], ">>>,>>>,>>>,>>9.99").
        TCALCBON = "TCALCBON=" + string(aaa.cr[2] - aaa.dr[2], ">>>,>>>,>>>,>>9.99").
        v-ok = 1.
    end.

    /* состояние депозита 2/3 */

    if t-mask = "statedepo2" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then
        TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

        find first accr where accr.aaa = t-acc no-lock no-error.
        if avail accr then do:
            TRATE1 = string(accr.rate).
            TDATE1 = string(accr.fdt, "99.99.9999").
        end.

        find first accr where accr.aaa = t-acc and accr.rate <> decimal(TRATE1) no-lock no-error.
        if avail accr then do:
            TRATE2 = string(accr.rate).
            TDATE2 = string(accr.fdt, "99.99.9999").
        end.

        find first accr where accr.aaa = t-acc and accr.rate <> decimal(TRATE1) and accr.rate <> decimal(TRATE2) no-lock no-error.
        if avail accr then do:
            TRATE3 = string(accr.rate).
            TDATE3 = string(accr.fdt, "99.99.9999").
        end.

        TRATE1 = "TRATE1=" + TRATE1.
        TRATE2 = "TRATE2=" + TRATE2.
        TRATE3 = "TRATE3=" + TRATE3.

        TDATE1 = "TDATE1=" + TDATE1.
        TDATE2 = "TDATE2=" + TDATE2.
        TDATE3 = "TDATE3=" + TDATE3.
    end.



    /* состояние депозита 3/3 */

    if t-mask = "statedepo3" then do:
            find last uplcif where uplcif.cif = t-cif and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then do:
                TFRENDCIF = "TFRENDCIF=" + UrlEncode(uplcif.badd[1]).
                TDOVDT = "TDOVDT=" + string(uplcif.finday).
            end.
    end.



    /* кредит 1/1 */

    if t-mask = "newcred" then do:
        find first cif where cif.cif = t-cif no-lock no-error.
        if avail cif then
        TCIFNAME = "TCIFNAME=" + UrlEncode(cif.prefix + " " + cif.name).

        v-list = "".
        v-list2 = "".
        for each lon where lon.cif = t-cif no-lock:
            run lonbalcrc('lon',lon.lon,g-today,"1",no,lon.crc,output v-od).
            if v-od <= 0 then next.

            v-list = v-list + lon.lon + "|".
            v-list2 = v-list2 + lon.aaa + "   (" + lon.lon + ")" + "|".
        end.

        if v-list <> "" then
            run sel2 ('Ссудные счета клиента',v-list2 , output v-sel).
        else do:
            message "У клиента нет ссудных счетов!".
            pause 10.
            return.
        end.

        find first lon where lon.lon = entry(v-sel, v-list, '|') no-lock no-error.
        if avail lon then
            TSUMM = "TSUMM=" + string(lon.opnamt, ">>>,>>>,>>>,>>9.99").

        find first crc where crc.crc = lon.crc no-lock no-error.
        if avail crc then
        TCRC = "TCRC=" + crc.code.

        TDATE1 = "TDATE1=" + string(lon.opndt, "99.99.9999").
        TDATE2 = "TDATE2=" + string(lon.duedt, "99.99.9999").

        TCREDRATE = "TCREDRATE=" + string(lon.prem) + UrlEncode(" %").

        run lonbalcrc('lon',lon.lon,g-today,"1",no,lon.crc,output v-od).

        TREST = "TREST=" + string(v-od, ">>>,>>>,>>>,>>9.99").

        run lonbalcrc('lon',lon.lon,g-today,"5,16",yes,lon.crc,output v-shtraf).
        TPEN = "TPEN=" + string(v-shtraf, ">>>,>>>,>>>,>>9.99").

        for each lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock :
            create wrk.
            wrk.dt = lnsci.idat.
        end.

        find first wrk where wrk.dt >= g-today no-lock no-error.
        if avail wrk then
        TPAYDATE = "TPAYDATE=" + string(wrk.dt, "99.99.9999").
        v-ok = 1.
    end.


    /* Платежи со счета 1/2 и 2/2 */

    if t-mask = "payacc1" or t-mask = "paytrans2" then do:

        find first remtrz where remtrz.remtrz = t-acc no-lock no-error.
        if avail remtrz then TDOCNO = remtrz.remtrz.

        if substr(TDOCNO,1,3) = "rmz" then do:
            find first remtrz where remtrz.remtrz = /*t-acc*/ TDOCNO no-lock no-error.
            if avail remtrz then do:
                TCIFNAME = "TCIFNAME=" + UrlEncode(entry(1, remtrz.ord, "/")).
                if INDEX(remtrz.ord, "/") >= 3 then
                TINN = "TINN=" + entry(3, remtrz.ord, "/").
                if TINN = "TINN=" then TINN = "".
                TDOCNO = "TDOCNO=" + trim( substring( remtrz.sqn,19,8 )).
                TRECAAA = "TRECAAA=" + remtrz.ba.
                TAAA = "TAAA=" + remtrz.sacc.
                TRECNAME = "TRECNAME=" + UrlEncode(entry(1, (remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]), "/")).

                /*if index(remtrz.bn[3], "/RNN/") <= 0 then TRECINN = "TRECINN=" + substring(remtrz.bn[3],1,12).
                else TRECINN = "TRECINN=" + substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).*/

                if index(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3], "/RNN/") >= 0 then
                TRECINN = "TRECINN=" + substring(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],index(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3], "/RNN/") + 5,12).

                if trim(TRECINN) = "TRECINN=" then do:
                    find first aaa where aaa.aaa = remtrz.ba no-lock no-error.
                    if avail aaa then
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif then
                            TRECINN = TRECINN + cif.jss.
                end.


                find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
                if not avail sub-cod then do:
                    TPRIOR = "TPRIOR=Обычный".
                end.
                else do:
                    if sub-cod.ccode = "s" then
                    TPRIOR = "TPRIOR=Срочный".
                    else
                    if sub-cod.ccode = "o" then
                    TPRIOR = "TPRIOR=Обычный".
                end.

                if substr(remtrz.ba,1,1) = '/' then v-ks = trim(substr(remtrz.ba,2)).
                else v-ks = trim(remtrz.ba).

                v-ks1 = v-ks.
                if index(v-ks1,'/') <> 0 then do:
                    v-ks  = substring(v-ks,1,index(v-ks,'/') - 1).
                    v-ks1 = substring(v-ks1,index(v-ks1,'/') + 1).
                end.
                else do:
                   if index(v-ks1,' ') <> 0 then do:
                      v-ks  = substring(v-ks,1,index(v-ks,' ') - 1).
                      v-ks1 = substring(v-ks1,index(v-ks1,' ') + 1).
                   end.
                   else do:
                      if length(v-ks1) > 20 then do:
                         v-ks1 = substr(v-ks,21,20).
                         v-ks  = substr(v-ks, 1,20).
                      end.
                      else v-ks1 = ' '.
                   end.
                end.

                /*if v-ks1 <> "" then*/
                find first budcodes where budcodes.code = int(v-ks1) no-lock no-error.
                if avail budcodes then TKBK = "TKBK=" + v-ks1.
                else TKBK = "TKBK=".
                /*substring(remtrz.ba,index(remtrz.ba, "/") + 1,6).*/
                /*else TKBK = "TKBK=" + entry(2,remtrz.ba,"/").*/

                if substr(remtrz.bb[1], 2,5) = "SWIFT" then
                TRBANK = "TRBANK=" + UrlEncode(substr(remtrz.bb[1], 8 + length(entry(2, remtrz.bb[1], " ")))).
                else
                TRBANK = "TRBANK=" + UrlEncode(remtrz.bb[1]).

                if remtrz.bb[1] matches "*метрокомбанк*" or remtrz.bb[1] matches "*ForteBank*" then do:
                    find sysc where sysc.sysc = "clecod" no-lock no-error.
                    if avail sysc then TRBANKBIK = "TRBANKBIK=" + sysc.chval.
                end.
                else if remtrz.rbank = "VALOUT" then do:
                    TRBANKBIK = "TRBANKBIK=" + entry(2,remtrz.bb[1]," "). /*remtrz.rbank.*/
                end.
                else TRBANKBIK = "TRBANKBIK=" + remtrz.rbank.


                find first swbody where swbody.rmz = remtrz.remtrz  and swbody.swfield = "56" no-lock no-error.
                if avail swbody then
                TKORBANK = "TKORBANK=" + UrlEncode(swbody.content[2]). /* + "   " + swbody.content[3]).*/

                /*
                Для банка получателя
                find first swbody where swbody.rmz = remtrz.remtrz  and swbody.swfield = "57" no-lock no-error.
                if avail swbody then  swbody.content[2] = бик
                                      swbody.content[3] = v_ наименование.*/




                TREM = "TREM=" + UrlEncode(trim(remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4])).

                TSUMM = "TSUMM=" + string(remtrz.amt, ">>>,>>>,>>>,>>9.99").

                find first crc where crc.crc = remtrz.fcrc no-lock no-error.
                if avail crc then
                TCRC = "TCRC=" + crc.code.

                TVALDATE = "TVALDATE=" + string(remtrz.valdt1, "99.99.9999").

                find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    TKOD = "TKOD=" + entry(1,sub-cod.rcode,',').
                    TKBE = "TKBE=" + entry(2,sub-cod.rcode,',').
                    TKNP = "TKNP=" + entry(3,sub-cod.rcode,',').
                end.

                /* TKORBANK = "TKORBANK=" +

                TRECINN = "TRECINN=" + */
            end.
        end.

        if substr(TDOCNO,1,3) = "jou" then do:
            find first joudoc where joudoc.docnum = /*t-acc*/ trim(TDOCNO) no-lock no-error.
            if avail joudoc then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                if avail aaa then
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        TCIFNAME = "TCIFNAME=" + UrlEncode(cif.name).
                        TINN = "TINN=" + cif.jss.
                    end.
                TAAA = "TAAA=" + joudoc.dracc.
                TSUMM = "TSUMM=" + string(joudoc.dramt, ">>>,>>>,>>>,>>9.99").
            end.
            TDOCNO = "TDOCNO=" + TDOCNO.
        end.


        v-ok = 1.
    end.



    /* Покупка/Продажа ин.валюты 1/1 */

    if t-mask = "convdoc" then do:
        update v-dt1 v-dt2 with frame fmask8.

        find first cif where cif.cif = t-cif no-lock no-error.
            if avail cif then do:
            TCIFNAME = "TCIFNAME=" + cif.prefix + " " + cif.name.
            v-list = "".
            for each aaa where aaa.cif = cif.cif no-lock:
                for each dealing_doc where dealing_doc.tclientaccno = aaa.aaa and dealing_doc.whn_mod >= v-dt1 and dealing_doc.whn_mod <= v-dt2 no-lock:
                    v-list = v-list + dealing_doc.DocNo + "|".
                end.
            end.
            if v-list = "" then do:
                message "Покупка/продажа валюты за указанный период не осуществлялась".
                pause 10.
                leave.
            end.

            run sel2 ('Документы по покупке/продаже за период',v-list , output v-sel).

            find first dealing_doc where dealing_doc.DocNo = entry(v-sel, v-list,'|') no-lock no-error.
            if avail dealing_doc then do:

                TAAA1 = "TAAA1=" + dealing_doc.tclientaccno.

                find first aaa where aaa.aaa = dealing_doc.tclientaccno no-lock no-error.
                if avail aaa then
                    find first crc where crc.crc = aaa.crc no-lock no-error.
                if avail crc then
                    TCRC1 = crc.code.

                TAAA2 = "TAAA2=" + dealing_doc.vclientaccno.

                find first aaa where aaa.aaa = dealing_doc.vclientaccno no-lock no-error.
                if avail aaa then
                    find first crc where crc.crc = aaa.crc no-lock no-error.
                if avail crc then
                    TCRC2 = crc.code.

                TAAA3 = "TAAA3=" + dealing_doc.com_accno.

                find first aaa where aaa.aaa = dealing_doc.com_accno no-lock no-error.
                if avail aaa then
                    find first crc where crc.crc = aaa.crc no-lock no-error.
                if avail crc then
                    TCRC3 = crc.code.

                TSUMM1 = "TSUMM1=" + string(dealing_doc.t_amount, ">>>,>>>,>>>,>>9.99") + " " + TCRC1.
                TSUMM2 = "TSUMM2=" + string(dealing_doc.v_amount, ">>>,>>>,>>>,>>9.99") + " " + TCRC2.
                TSUMM3 = "TSUMM3=" + string(dealing_doc.com_conv, ">>>,>>>,>>>,>>9.99") + " " + TCRC3.
                TRATE = "TRATE=" + string(dealing_doc.rate, ">>>,>>>,>>9.99").
                if dealing_doc.doctype = 1 or dealing_doc.doctype = 3 then
                    TTYPE = "TTYPE=" + "День в день".
                if dealing_doc.doctype = 2 or dealing_doc.doctype = 4 then
                    TTYPE = "TTYPE=" + "На след.день".
            end.
        end. /*if avail cif*/
        v-ok = 1.
    end.

    /* Банковский перевод без открытия счета 1/2     ( 2-я стр. paytrans2 -  вызывается из шаблона платежи со счета) */

    if t-mask = "transfer" then do:
        find first remtrz where remtrz.remtrz = t-acc no-lock no-error.
        if avail remtrz then TDOCNO = remtrz.remtrz.

        if substr(TDOCNO,1,3) = "rmz" then do:
            find first remtrz where remtrz.remtrz = /*t-acc*/ TDOCNO no-lock no-error.
            if avail remtrz then do:

                TCIFNAME = "TCIFNAME=" + UrlEncode(entry(1, remtrz.ord, "/")).
                if INDEX(remtrz.ord, "/") >= 3 then
                TINN = "TINN=" + entry(3, remtrz.ord, "/").
                if TINN = "TINN=" then TINN = "".

                TRECNAME = "TRECNAME=" + UrlEncode(remtrz.bn[1] + " " + remtrz.bn[2] +  " " + remtrz.bn[3]).

                find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    TKOD = "TKOD=" + entry(1,sub-cod.rcode,',').
                    TKBE = "TKBE=" + entry(2,sub-cod.rcode,',').
                    TKNP = "TKNP=" + entry(3,sub-cod.rcode,',').
                end.

                find first crc where crc.crc = remtrz.svcrc no-lock no-error.
                if avail crc then do:
                    tcrc = crc.code.

                end.

                TRECAAA = "TRECAAA=" + remtrz.ba.
                TRBANK = "TRBANK=" + remtrz.bb[1].
                TRBANKBIK = "TRBANKBIK=" + remtrz.rbank.
                TSUMM = "TSUMM=" + string(remtrz.amt, ">>>,>>>,>>>,>>9.99").
                TCOMSUMM = "TCOMSUMM=" + string(remtrz.svca, ">>>,>>>,>>>,>>9.99") + "  " + tcrc.
                TREM = "TREM=" + remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4].

                if index(remtrz.bn[3], "/RNN/") <= 0 then TRECINN = "TRECINN=" + substring(remtrz.bn[3],1,12).
                else TRECINN = "TRECINN=" + substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).

                tcrc = "".
                find first crc where crc.crc = remtrz.fcrc no-lock no-error.
                if avail crc then
                TCRC = "TCRC=" + crc.code.
                TVALDATE = "TVALDATE=" + string(remtrz.valdt2, "99.99.9999").
            end.
        end.

        if substr(TDOCNO,1,3) = "jou" then do:
            find first joudoc where joudoc.docnum = TDOCNO no-lock no-error.
            if avail joudoc then do:

                TCIFNAME = "TCIFNAME=" + UrlEncode(joudoc.info).
                TSUMM = "TSUMM=" + string(joudoc.dramt, ">>>,>>>,>>>,>>9.99").

                find first crc where crc.crc = joudoc.drcur no-lock no-error.
                if avail crc then
                TCRC = "TCRC=" + crc.code.

                TREM = "TREM=" + UrlEncode(trim(joudoc.remark[1]) + " " + trim(joudoc.remark[2])).

                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        TCIFNAME = "TCIFNAME=" + cif.prefix + " " + UrlEncode(cif.name).
                        TINN = "TINN=" + cif.jss.

                        find first crc where crc.crc = aaa.crc no-lock no-error.
                        if avail crc then
                        TCRC = "TCRC=" + crc.code.
                    end.
                end.

                find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
                if avail joudop then do:
                    TRECNAME = "TRECNAME=" + entry(1, joudop.patt,'^').
                    TRECINN = "TRECINN=" + entry(2, joudop.patt,'^').
                    TKBE = "TKBE=" + entry(3,joudop.patt,'^').
                    TRECAAA = "TRECAAA=" + entry(4,joudop.patt,'^').
                    TRBANK = "TRBANK=" + entry(5,joudop.patt,'^').
                    TRBANKBIK = "TRBANKBIK=" + entry(6,joudop.patt,'^').
                    TKNP = "TKNP=" + entry(7,joudop.patt,'^').
                end.

            end.

            find first cifmin where cifmin.cifmin = t-cif no-lock no-error.
            if avail cifmin then TKOD = "TKOD=" + cifmin.res.

            /*find first cifmin where cifmin.cifmin = t-cif no-lock no-error.
            if avail cifmin then do:
                TCIFNAME = "TCIFNAME=" + cifmin.fam + " " + cifmin.name + " " + cifmin.mname.
                TINN = "TINN=" + cifmin.rnn.
                TKOD = "TKOD=" + cifmin.res.
            end.*/
        end.
        v-ok = 1.
    end.

    if t-mask = "10" then do:
        /* запускается из программ по быстрым переводам */
    end.



    /* Курсы валют 1/1 */

    if t-mask = "rates" then do:
        run sel2 ("Курсы валют","Наличный|Безналичный" , output v-sel).
        if v-sel = 1 then do:
            TRATETYPE = "TRATETYPE=Курс наличной валюты".
            find first crc where crc.crc = 2 no-lock no-error.
            if avail crc then do:
                TUSD1 = "TUSD1=" + string(crc.rate[2], ">,>>9.99").
                TUSD2 = "TUSD2=" + string(crc.rate[3], ">,>>9.99").
            end.

            find first crc where crc.crc = 3 no-lock no-error.
            if avail crc then do:
                TEUR1 = "TEUR1=" + string(crc.rate[2], ">,>>9.99").
                TEUR2 = "TEUR2=" + string(crc.rate[3], ">,>>9.99").
            end.

            find first crc where crc.crc = 4 no-lock no-error.
            if avail crc then do:
                TRUB1 = "TRUB1=" + string(crc.rate[2], ">,>>9.99").
                TRUB2 = "TRUB2=" + string(crc.rate[3], ">,>>9.99").
            end.
        end.

        if v-sel = 2 then do:
            run sel2 ("Курсы валют","День в день|На следующий день" , output v-sel).

            if v-sel = 1 then do:

                TRATETYPE = "TRATETYPE=Курс безналичной валюты (день в день)".

                find sysc  where sysc.sysc  = 'ERCUSD' no-lock no-error.
                if avail sysc then TUSD1 = "TUSD1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ECUSD' no-lock no-error.
                if avail sysc then TUSD2 = "TUSD2=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ERCEUR' no-lock no-error.
                if avail sysc then TEUR1 = "TEUR1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ECEUR' no-lock no-error.
                if avail sysc then TEUR2 = "TEUR2=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ERCRUR' no-lock no-error.
                if avail sysc then TRUB1 = "TRUB1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ECRUR' no-lock no-error.
                if avail sysc then TRUB2 = "TRUB2=" + string(sysc.deval, ">,>>9.99").
            end.
            if v-sel = 2 then do:

                TRATETYPE = "TRATETYPE=Курс безналичной валюты (на следующий день)".

                find sysc  where sysc.sysc  = 'ORCUSD' no-lock no-error.
                if avail sysc then TUSD1 = "TUSD1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'OCUSD' no-lock no-error.
                if avail sysc then TUSD2 = "TUSD2=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ORCEUR' no-lock no-error.
                if avail sysc then TEUR1 = "TEUR1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'OCEUR' no-lock no-error.
                if avail sysc then TEUR2 = "TEUR2=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'ORCRUR' no-lock no-error.
                if avail sysc then TRUB1 = "TRUB1=" + string(sysc.deval, ">,>>9.99").

                find sysc  where sysc.sysc  = 'OCRUR' no-lock no-error.
                if avail sysc then TRUB2 = "TRUB2=" + string(sysc.deval, ">,>>9.99").
            end.
        end.

    end.

end procedure.



procedure lonbal3.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.
def buffer b-aaa for aaa.

res = 0.

if p-dt > g-today then p-dt = g-today. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then do:

            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + trxbal.dam - trxbal.cam.
	    else res = res + trxbal.cam - trxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
	    for each jl where jl.acc = p-acc
                          and jl.jdt >= p-dt
                          and jl.lev = 1 no-lock:
	    if gl.type eq "A" or gl.type eq "E" then res = res - jl.dam + jl.cam.
            else res = res + jl.dam - jl.cam.
            end.

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last histrxbal where histrxbal.subled = p-sub
                              and histrxbal.acc = p-acc
                              and histrxbal.level = integer(entry(i, p-lvls))
                              and histrxbal.dt <= p-dt no-lock no-error.
        if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                 and histrxbal.dt < p-dt no-lock no-error.
       if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.



end.
