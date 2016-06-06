/* printjl-prcd3.p
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        06.03.2012 damir - changing copy's jl-prcd3.p
        02/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}

{chbin.i}
{convgl.i "bank"}

def input parameter KOd  as char.
def input parameter KBe  as char.
def input parameter KNP  as char.
def input parameter KOd1 as char.
def input parameter KBe1 as char.
def input parameter KNP1 as char.
def input parameter KOd2 as char.
def input parameter KBe2 as char.
def input parameter KNP2 as char.
def input parameter s-jh as inte.

def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  ".
def var sxin  like xin.
def var sxout like xout.
def var intot  like xin.
def var outtot like xout.

define shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define shared temp-table remfile
   field rem as character.

define variable rnn      as character format "x(20)".
define variable vv-cif   like cif.cif.
define variable vv-type  like cif.type.
define variable refn     as character.
define variable dtreg    as date format "99/99/9999".
define variable drek     as character extent 16 format "x(90)".
define variable drek1    as character extent 8 format "x(90)".
define variable v_doc    as character format "x(10)".


def shared temp-table ljl like jl.
def shared var g-officer  like ofc.ofc.

find jh where jh.jh eq s-jh no-lock no-error.
dtreg = jh.jdt.

xin  = 0.
xout = 0.
vv-type = "".

define variable conve as logical.

conve = false.
for each ljl of jh no-lock:
    if isConvGL(ljl.gl) then do:
       conve = true.
       leave.
    end.
end.

if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find joudoc where joudoc.docnum eq v_doc no-lock no-error.
   refn  = joudoc.num.
   dtreg = joudoc.whn.
   find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
      vv-type = cif.type.
   end.
   else do:
      vv-cif = "".
   end.

   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :    " + joudoc.info.
   drek[3] = "Получил : " + joudoc.info.
   if joudoc.passp eq ? then drek[4] = "Паспорт : ".
   else do:
        if string(joudoc.passpdt) = ? then
           drek[4] = "Паспорт : " + joudoc.passp.
        else
           drek[4] = "Паспорт : " + joudoc.passp + "  " + string(joudoc.passpdt).
   end.

   if v-bin then drek[5] = "ИИН     : " + joudoc.perkod.
   else drek[5] = "РНН     : " + joudoc.perkod.

   if vv-type = 'P' then do:
   drek[6] = "Подтверждаю: данная операция не связана с предпринимательской деятельностью, ".
   drek1[1] = "осуществлением мною валютных операций, требующих получения лицензии, " .
   drek1[2] = "регистрационного свидетельства, свидетельства об уведомлении, оформления " .
   drek1[3] = "паспорта сделки. " .
   drek1[4] = "Я согласен с предоставлением информации о данном платеже в " .
   drek1[5] = "правоохранительные органы и  Национальный Банк по их требованию. ".
   end.
   else drek[6] = "".
   drek[7] = "Подпись : ".

   /**************************************************************************/
   if conve = true then do:
      drek[1] = "Кассир:".
      drek[5] = "".
      drek[7] = "".
      if joudoc.info = "" then assign drek[2] = "" drek[3] = "" drek[4] = "".
   end.


end.

if jh.sub eq "rmz" then do:
   v_doc = jh.ref.

   find remtrz where remtrz.remtrz eq v_doc no-lock no-error.
   dtreg = remtrz.rdt.
   refn = substring (remtrz.sqn, 19).
   find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".

   drek[1] =
       "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :     " + remtrz.ord.

   if v-bin then drek[5] = "ИИН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
   else drek[5] = "РНН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
   drek[4] = "Паспорт : " .
   drek[7] = " Подпись :".
   drek[6] = "".

end.


/* sasco - для пополнений пластиковых карточек */
if jh.party = "BWX" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то карточники растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Клиент:     " .
   drek[7] = "".
end.

if jh.party = "CAS" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то кассиры растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Внес:     " .
   drek[4] = "Паспорт : " .
   drek[7] = "".
end.

if jh.party = "MXP" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :".
   find first remfile. find next remfile. find next remfile.
   drek[2] = "Внес :    " + remfile.rem.
   drek[3] = "Получил : " + remfile.rem.
   find next remfile.
   drek[4] = "Паспорт : " + remfile.rem.
   find first translat where translat.jh = jh.jh no-lock no-error.
   if avail translat then do:
      if v-bin then drek[5] = "ИИН :  " + translat.rnn.
      else drek[5] = "РНН :  " + translat.rnn.
   end.
   find first r-translat where r-translat.jh = jh.jh no-lock no-error.
   if avail r-translat then do:
      if v-bin then drek[5] = "ИИН :  " + r-translat.acc.
      else drek[5] = "РНН :  " + r-translat.acc.
   end.

end.

if jh.party = "" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :" .
   drek[2] = "Внес :    " .
   drek[3] = "Получил : " .
   drek[4] = "Паспорт : " .

end.

drek[8]  = "КОД : " + KOd .
drek[9]  = "КБе : " + KBe .
drek[10] = "КНП : " + KNP .

drek[11] = "КОД : " + KOd1 .
drek[12] = "КБе : " + KBe1 .
drek[13] = "КНП : " + KNP1 .

drek[14] = "КОД : " + KOd2 .
drek[15] = "КБе : " + KBe2 .
drek[16] = "КНП : " + KNP2 .

output to vou.img page-size 0.

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


/*----------------------27.08.01-----------------------------------*/
def var        decAmountT like xin.
def buffer drate for crc.
/*-----------------------------------------------------------------*/

define variable obmenGL2 as integer.
define variable v-opkkas as char.
def var v-iscash as logical.
def var j as inte init 0.
def var k as inte init 0.

def var v-sub as logical initial no.
def var v-com as char.
def var v-kod as char.
def var v-remtrz as char.
find sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find point where point.point = v-point no-lock no-error.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.


sxin = 0.
sxout = 0.

find first ljl of jh where ljl.gl = sysc.inval no-lock no-error.
v-iscash = avail ljl.
if ljl.ln = 1 then v-remtrz =  substr(ljl.rem[1],1,10).

/*find jh where jh.jh eq s-jh no-lock no-error.
if jh.sub eq "jou" then v_doc = jh.ref.*/

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval) or (ljl.gl = 100110)
                                        or (ljl.gl = obmenGL2 and not v-iscash     /* если есть Касса в пути - то печатать по ней ордер, только если нет Кассы */
                                            and ((ljl.trx begins "opk")
                                              or (substring(ljl.rem[1],1,5) = "Обмен")
                                              or (can-find (sub-cod where sub-cod.sub = "arp"
                                                                      and sub-cod.acc = ljl.acc
                                                                      and sub-cod.d-cod = "arptype"
                                                                      and sub-cod.ccode = "obmen1002" no-lock))))
    no-lock
    break by ljl.crc by ljl.dc:
    if ljl.dc eq "D" then do:
        j = j + 1.  /*Дамир, подсчет кол-ва приходных ордеров*/
        put skip(3) space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
        run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz).
        put unformatted string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
          "Dok.Nr." + trim(refn) + "   /" + ofc.name +
          "         " + trim(v-datastr) skip.

        put
"============================================================================="
                                                         skip(1).
        put
    "ВАЛЮТА                                      ПРИХОД                РАСХОД"
                                         skip.
        put unformatted fill ("-", 77) skip.
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
    if ljl.dc eq "D" then put crc.des xin xout skip.
    if j = 1 then sxin = sxin + xin. /*Дамир*/
    if j = 2 then do: /*Дамир*/
        sxin = 0.
        sxin = sxin + xin.
    end.
    if ljl.dc eq "D" then do:
        put unformatted skip(1)
        space(22) "ИТОГО ПРИХОД" sxin format "z,zzz,zzz,zz9.99" skip(2).
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
    end.
    if ljl.dc eq "D" then do:
        if j = 1 and KOd1 + KBe1 + KNP1 <> "" then put drek[11] skip drek[12] skip drek[13] . /*Дамир, если один приходник*/
        if j = 2 and KOd2 + KBe2 + KNP2 <> "" then put drek[14] skip drek[15] skip drek[16] . /*Дамир, если их два, отображение кодов для второго*/
    end.
    if ljl.dc eq "D" then do:
        if (g-fname = "OURMZ" or g-fname = "PODTTR" or g-fname = "RETTR") then do:
            if ljl.ln = 1 or ljl.ln = 2 then do:
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    v-sub = yes.
                    put unformatted  "КОД : " + substr(sub-cod.rcode,1,2) skip.
                    put unformatted "КБе : " + substr(sub-cod.rcode,4,2) skip.
                    put unformatted "КНП : " + substr(sub-cod.rcode,7,3) skip.
                end.
                if v-sub = no then do:
                    find first translat where translat.jh = ljl.jh no-lock no-error.
                    if avail translat then do:
                        find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                        if avail sub-cod then do:
                            put unformatted  "КОД : " + substr(sub-cod.rcode,1,2) skip.
                            put unformatted "КБе : " + substr(sub-cod.rcode,4,2) skip.
                            put unformatted "КНП : " + substr(sub-cod.rcode,7,3) skip.
                        end.
                    end.
                    if not avail translat then do:
                        find first r-translat where r-translat.jh = ljl.jh no-lock no-error.
                        if avail r-translat then do:
                            find first sub-cod where sub-cod.acc = r-translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                            if avail sub-cod then do:
                                put unformatted  "КОД : " + substr(sub-cod.rcode,1,2) skip.
                                put unformatted "КБе : " + substr(sub-cod.rcode,4,2) skip.
                                put unformatted "КНП : " + substr(sub-cod.rcode,7,3) skip.
                            end.
                        end.
                    end.
                end.
            end.
            else do:
                if ljl.acc <> "" then do:
                    find first aaa where aaa.aaa = ljl.acc no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif and cif.geo = "021" then v-kod = "1".
                        if avail cif and cif.geo <> "021" then v-kod = "2".
                        find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                        if avail sub-cod then v-kod = v-kod + substr(sub-cod.ccode,1,2).
                    end.
                end.
                else do:
                    find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                    if avail sub-cod then do:
                        v-sub = yes.
                        v-kod = substr(sub-cod.rcode,1,2).
                    end.
                    if v-sub = no then do:
                        find first translat where translat.jh = ljl.jh no-lock no-error.
                        if avail translat then do:
                            find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                            if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                        end.
                        if not avail translat then do:
                            find first r-translat where r-translat.jh = ljl.jh no-lock no-error.
                            if avail r-translat then do:
                                find first sub-cod where sub-cod.acc = r-translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                                if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                            end.
                        end.
                    end.
                end.
                put unformatted  "КОД : " + v-kod skip.
                put unformatted "КБе : 14" skip.
                put unformatted "КНП : 840" skip.
            end.
        end.
        put skip(1).
        if length (trim (drek[7])) ne 0 then put drek[7] .

        put skip.
        put "============================================================================="  skip(1).
        if ljl.ln = 3 or ljl.ln = 5 then do:
            if ljl.rem[1] matches "*Комиссия*" THEN v-com = "".
            else v-com = "Комиссия ".
            put unformatted "Примечан.:  " + v-com + ljl.rem[1] skip.
            put skip(1).
        end.
        else do:
            for each remfile:
              put unformatted remfile.rem  skip.
            end.
            put skip(1).
        end.
    end.
    if last-of (ljl.crc) then do:
       sxin = 0.   sxout = 0.
    end.
end.

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval) or (ljl.gl = 100110)
                                        or (ljl.gl = obmenGL2 and not v-iscash     /* если есть Касса в пути - то печатать по ней ордер, только если нет Кассы */
                                            and ((ljl.trx begins "opk")
                                              or (substring(ljl.rem[1],1,5) = "Обмен")
                                              or (can-find (sub-cod where sub-cod.sub = "arp"
                                                                      and sub-cod.acc = ljl.acc
                                                                      and sub-cod.d-cod = "arptype"
                                                                      and sub-cod.ccode = "obmen1002" no-lock))))
    no-lock
    break by ljl.crc by ljl.dc:

    if first-of(ljl.dc) then do:
        if ljl.dc eq "C" then do:
            put skip(3) space(20) "РАСХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).

            run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz).
            put unformatted string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
              "Dok.Nr." + trim(refn) + "   /" + ofc.name +
              "         " + trim(v-datastr) skip.

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
        if  ljl.dc eq "C" and KOd + KBe + KNP <> "" then do:
            put drek[8] skip drek[9] skip drek[10] .
        end.
        if  ljl.dc eq "C" then do:
            if g-fname = "OURMZ" or g-fname = "PODTTR" or g-fname = "RETTR" then do:
                if ljl.ln = 1 or ljl.ln = 2 then do:
                    find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                    if avail sub-cod then do:
                        v-sub = yes.
                        put unformatted  "КОД: " + substr(sub-cod.rcode,1,2) skip.
                        put unformatted "КБе: " + substr(sub-cod.rcode,4,2) skip.
                        put unformatted "КНП: " + substr(sub-cod.rcode,7,3) skip.
                    end.
                    if not avail sub-cod then do:
                        find first translat where translat.jh-voz = ljl.jh no-lock no-error.
                        if avail translat then do:
                            find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                            if avail sub-cod then do:
                                v-sub = yes.
                                put unformatted  "КОД: " + substr(sub-cod.rcode,1,2) skip.
                                put unformatted "КБе: " + substr(sub-cod.rcode,4,2) skip.
                                put unformatted "КНП: " + substr(sub-cod.rcode,7,3) skip.
                            end.
                        end.
                    end.
                    if v-sub = no then do:
                        find first translat where translat.jh = ljl.jh no-lock no-error.
                        if avail translat then do:
                            find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                            if avail sub-cod then do:
                                put unformatted  "КОД: " + substr(sub-cod.rcode,1,2) skip.
                                put unformatted "КБе: " + substr(sub-cod.rcode,4,2) skip.
                                put unformatted "КНП: " + substr(sub-cod.rcode,7,3) skip.
                            end.
                        end.
                        if not avail translat then do:
                            find first r-translat where r-translat.jh = ljl.jh no-lock no-error.
                            if avail r-translat then do:
                                find first sub-cod where sub-cod.acc = r-translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                                if avail sub-cod then do:
                                    put unformatted  "КОД: " + substr(sub-cod.rcode,1,2) skip.
                                    put unformatted "КБе: " + substr(sub-cod.rcode,4,2) skip.
                                    put unformatted "КНП: " + substr(sub-cod.rcode,7,3) skip.
                                end.
                            end.
                        end.
                    end.
                end.
                else do:
                    if ljl.acc <> "" then do:
                        find first aaa where aaa.aaa = ljl.acc no-lock no-error.
                        if avail aaa then do:
                            find first cif where cif.cif = aaa.cif no-lock no-error.
                            if avail cif and cif.geo = "021" then v-kod = "1".
                            if avail cif and cif.geo <> "021" then v-kod = "2".
                            find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.ccod = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                            if avail sub-cod then v-kod = v-kod + substr(sub-cod.rcode,1,2).
                        end.
                        if not avail aaa then do:
                            find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                            if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                        end.
                    end.
                    else do:
                        find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                        if avail sub-cod then do:
                            v-sub = yes.
                            v-kod = substr(sub-cod.rcode,1,2).
                        end.
                        if not avail sub-cod then do:
                            find first translat where translat.jh = ljl.jh no-lock no-error.
                            if avail translat then do:
                                find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                                if avail sub-cod then do:
                                    put unformatted  "КОД: " + substr(sub-cod.rcode,1,2) skip.
                                    put unformatted "КБе: " + substr(sub-cod.rcode,4,2) skip.
                                    put unformatted "КНП: " + substr(sub-cod.rcode,7,3) skip.
                                end.
                            end.
                        end.
                        if v-sub = no then do:
                            find first translat where translat.jh = ljl.jh no-lock no-error.
                            if avail translat then do:
                                find first sub-cod where sub-cod.acc = translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                                if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                            end.
                            if not avail translat then do:
                                find first r-translat where r-translat.jh = ljl.jh no-lock no-error.
                                if avail r-translat then do:
                                    find first sub-cod where sub-cod.acc = r-translat.nomer and sub-cod.ccod = "eknp" no-lock no-error.
                                    if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                                end.
                            end.
                        end.
                    end.
                    put unformatted  "КОД: " + v-kod skip.
                    put unformatted "КБе: 14" skip.
                    put unformatted "КНП: 840" skip.
                end.
            end.
            put skip(1).
            if length (trim (drek[7])) ne 0 then put drek[7] .
            put skip.
            put "============================================================================="  skip(1).
            /*for each remfile:
              put unformatted remfile.rem + "комиссия" skip.
            end.
            put skip(1).*/
            if ljl.ln = 3 or ljl.ln = 5 then do:
                if ljl.rem[1] matches "*Комиссия*" THEN v-com = "".
                else v-com = "Комиссия ".
                put unformatted "Примечан.:  " + v-com + ljl.rem[1] skip.
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

if ofc.mday[2] = 1 then put skip(14).
else put skip(1).


output close.

unix silent cptunkoi vou.img winword. /*-t vou.img.*/

/* unix silent joe vou.img. */
pause 0.



