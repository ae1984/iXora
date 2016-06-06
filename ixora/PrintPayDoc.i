/* PrintPayDoc.i
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
        BANK
 * CHANGES
        27.09.2013 damir - Внедрено Т.З. № 1693.
*/
def var v-template as char init "/data/export/paydoc.htm".
def var v-str as char.
def var str1 as char format "x(80)".
def var str2 as char format "x(80)".
def var temp as char.
def var strTemp as char.
def var strAmount as char.
def var v-rem as char.

def buffer b-sysc for sysc.
def buffer b-sub-cod for sub-cod.

if v-joudoc eq "" then undo, retry.
find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
if not avail joudoc then undo, retry.

find jh where jh.jh = joudoc.jh no-lock no-error.
find aaa where aaa.aaa = joudoc.dracc no-lock no-error.
if avail aaa then find cif where cif.cif = aaa.cif no-lock no-error.
find cmp no-lock no-error.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
find b-sysc where b-sysc.sysc = "clecod" no-lock no-error.
find crc where crc.crc = joudoc.comcur no-lock no-error.

temp = string(joudoc.comamt).
if num-entries(temp,".") = 2 then do:
    temp = substring(temp, length(temp) - 1, 2).
    if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
end.
else temp = "00".
strTemp = string(truncate(joudoc.comamt,0)).
run Sm-vrd(input joudoc.comamt, output strAmount).
run sm-wrdcrc(input strTemp,input temp,input joudoc.comcur,output str1,output str2).
strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

v-rem = joudoc.remark[1] + joudoc.remark[2].

if avail cif then do:
    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnchf" and sub-cod.ccode = "chief" no-lock no-error.
    find b-sub-cod where b-sub-cod.sub = "cln" and b-sub-cod.acc = cif.cif and b-sub-cod.d-cod = "clnbk" and b-sub-cod.ccode = "mainbk" no-lock no-error.
end.
if avail jh then find ofc where ofc.ofc = jh.who no-lock no-error.

output to value("PayDoc.htm").
input from value(v-template).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*numplat*" then do:
            v-str = replace(v-str,"numplat",trim(joudoc.docnum)).
            next.
        end.
        if v-str matches "*dtzapolnen*" then do:
            v-str = replace(v-str,"dtzapolnen",if avail jh then string(jh.whn,"99/99/9999") else "").
            next.
        end.
        if v-str matches "*otpravitdeneg*" then do:
            v-str = replace(v-str,"otpravitdeneg",trim(joudoc.info)).
            next.
        end.
        if v-str matches "*iinotpravitel*" then do:
            v-str = replace(v-str,"iinotpravitel",if avail cif then trim(cif.bin) else "").
            next.
        end.
        if v-str matches "*iikotpravitel*" then do:
            v-str = replace(v-str,"iikotpravitel",trim(joudoc.dracc)).
            next.
        end.
        if v-str matches "*kodotp*" then do:
            v-str = replace(v-str,"kodotp",trim(joudoc.rescha[2])).
            next.
        end.
        if v-str matches "*sumcifropravit*" then do:
            v-str = replace(v-str,"sumcifropravit",string(joudoc.comamt,"->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9.99")).
            next.
        end.
        if v-str matches "*bankpoluchatel*" then do:
            v-str = replace(v-str,"bankpoluchatel","АО «ForteBank»").
            next.
        end.
        if v-str matches "*bikbankpoluchat*" then do:
            v-str = replace(v-str,"bikbankpoluchat",if avail b-sysc then trim(b-sysc.chval) else "").
            next.
        end.
        if v-str matches "*beneficiar*" then do:
            v-str = replace(v-str,"beneficiar","АО «ForteBank»").
            next.
        end.
        if v-str matches "*iinbenef*" then do:
            v-str = replace(v-str,"iinbenef",if avail sysc then trim(sysc.chval) else "").
            next.
        end.
        if v-str matches "*bikbenef*" then do:
            v-str = replace(v-str,"bikbenef",if avail b-sysc then trim(b-sysc.chval) else "").
            next.
        end.
        if v-str matches "*kbeben*" then do:
            v-str = replace(v-str,"kbeben",trim(v_kbe)).
            next.
        end.
        if v-str matches "*sumpropbenefone*" then do:
            v-str = replace(v-str,"sumpropbenefone",trim(strAmount)).
            next.
        end.
        if v-str matches "*knp*" then do:
            v-str = replace(v-str,"knp",trim(v_knp)).
            next.
        end.
        if v-str matches "*dtvalutirov*" then do:
            v-str = replace(v-str,"dtvalutirov",if avail jh then string(jh.whn,"99/99/9999") else "").
            next.
        end.
        if v-str matches "*naznplatezhaone*" then do:
            v-str = replace(v-str,"naznplatezhaone",substr(v-rem,1,78)).
            next.
        end.
        if v-str matches "*naznplatezhatwo*" then do:
            if length(substr(v-rem,79,98)) > 0 then v-str = replace(v-str,"naznplatezhatwo",substr(v-rem,79,98)).
            else v-str = replace(v-str,"naznplatezhatwo"," ").
            next.
        end.
        if v-str matches "*gendirektor*" then do:
            v-str = replace(v-str,"gendirektor",if avail sub-cod then trim(sub-cod.rcode) else "").
            next.
        end.
        if v-str matches "*glbuhgalter*" then do:
            v-str = replace(v-str,"glbuhgalter",if avail b-sub-cod then trim(b-sub-cod.rcode) else "").
            next.
        end.
        if v-str matches "*fioispolnitelya*" then do:
            v-str = replace(v-str,"fioispolnitelya",if avail ofc then trim(ofc.name) else "").
            next.
        end.
        if v-str matches "*dtispolneniya*" then do:
            v-str = replace(v-str,"dtispolneniya",if avail jh then string(jh.whn,"99/99/9999") else "").
            next.
        end.
        if v-str matches "*vidval*" then do:
            v-str = replace(v-str,"vidval",trim(crc.code)).
            next.
        end.
        leave.
    end.
    put unformatted v-str skip.
end.
input close.
output close.

unix silent cptwin value("PayDoc.htm") winword.


