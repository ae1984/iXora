/* vou_bankoperord.p
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
        Пункт меню - 2.1.3
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        16.01.2012 changing copy of vou_bank.p
        23.08.2012 evseev - переход на ИИН/БИН
        01/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{chbin.i} /*Переход на ИИН и БИН*/
{convgl.i "bank"}

def input parameter oper_Ok as int.

def var KOd         as char format "x(2)".
def var KBe         as char format "x(2)".
def var KNP         as char format "x(3)".
def var eknp_bal    as deci.
def var KOd_        as char format "x(2)".
def var KBe_        as char format "x(2)".
def var KNP_        as char format "x(3)".
def var KOd_1       as char format "x(2)".
def var KBe_1       as char format "x(2)".
def var KNP_1       as char format "x(3)".
def var KOd_2       as char format "x(2)".
def var KBe_2       as char format "x(2)".
def var KNP_2       as char format "x(3)".
def var ln1         as inte init 0.
def var ln2         as inte init 0.
def var v-remark1   as char.
def var v-remark2   as char.
def var bas_crc     like crc.crc init 1.
def var v_doc       as char format "x(10)".
def var dtreg       as date format "99/99/9999".
def var refn        as char.
def var vcode       as char format "x(3)".
def var ss          as inte.
def var vi          as inte.
def var vcash       as logi.
def var vdb         as char format "x(9)" label " ".
def var vcr         as char format "x(9)" label " ".
def var vdes        as char format "x(32)" label " ". /* chart of account desc */
def var vname       as char format "x(30)" label " ". /* name of customer */
def var vrem        as char format "x(55)" extent 7 label " ".
def var vamt        like jl.dam extent 7 label " ".
def var vext        as char format "x(40)" label " ".
def var vtot        like jl.dam label " ".
def var vcontra     as char format "x(53)" extent 5 label " ".
def var vpoint      as inte.
def var inc         as inte.
def var tdes        like gl.des.
def var tty         as char format "x(20)".
def var vconsol     as logi.
def var vcif        as char format "x(6)" label " ".
def var vofc        like ofc.ofc label  " ".
def var vcrc        like crc.code label " ".
def var xamt        like jl.dam.
def var xdam        like jl.dam.
def var xcam        like jl.cam.
def var xco         as char format "x(2)" label "".
def var vcha2       as cha format "x(50)".
def var vcha3       as cha format "x(50)".
def var vcha1       as cha format "x(65)".
def var l-prn       as logi init "no" format "да/нет".
def var vv-cif      like cif.cif.
def var s_payment   as char.
def var obmenGL2    as integer.
def var v-cashgl    as integer.
def var v-remtrz    as char.
def var v-kod       as char.
def var conve       as logi.

def buffer d_crc for crc.
def buffer c_crc for crc.
def buffer bjl   for jl.

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define new shared temp-table remfile
   field rem as character.

define new shared temp-table ljl like jl.

def new shared var v-point like point.point.
def new shared var g-officer like ofc.ofc.
def shared var s-jh like jh.jh .

{x-jlvou.f}

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.

find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
   if jl.ln = 1 then v-remtrz =  substr(jl.rem[1],1,10).
   create ljl.
   buffer-copy jl to ljl.
   dtreg = jl.jdt. /* jl.whn. 29.11.2003 nadejda */
end.

if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find first joudoc where joudoc.docnum = v_doc no-lock.
   if avail joudoc then do:
        dtreg = joudoc.whn.
        refn  = joudoc.num.
        v-remark1 = joudoc.remark[1].
        find first tarif2 where tarif2.num + tarif2.kod = joudoc.comcode no-lock no-error.
        if avail tarif2 then v-remark2 = tarif2.pakalp.
        else v-remark2 = "".
   end.
   find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".
end.
if jh.sub eq "rmz" then do:
   v_doc = jh.ref.
   find remtrz where remtrz.remtrz eq v_doc no-lock.
   dtreg = remtrz.rdt.
   refn = substring (remtrz.sqn, 19).
   find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".
end.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

output to vou.img page-size 0.


put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put
"============================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(time,"HH:MM") skip
    "БИН" + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put point.name skip.
put point.addr[1] skip.
put string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
    "Dok.Nr." + trim(refn) +
    "   /" + ofc.name  format "x(78)" skip.
put
"============================================================================="
    skip.

vcash = false.
xdam = 0. xcam = 0.

for each ljl of jh use-index jhln no-lock
break by ljl.crc by ljl.ln:
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

    eknp_bal = eknp_bal + ljl.dam - ljl.cam.
    run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).

    if (ljl.gl = v-cashgl) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or
    ((ljl.gl = obmenGL2) and can-find (sub-cod where sub-cod.sub = "arp"
     and sub-cod.acc = ljl.acc
     and sub-cod.d-cod = "arptype"
     and sub-cod.ccode = "obmen1002" no-lock))
    then vcash = true.

    if ljl.dam ne 0 then do:
        xamt = ljl.dam.
        xdam = xdam + ljl.dam.
        xco  = "DR".
    end.
    else do:
        xamt = ljl.cam.
        xcam = xcam + ljl.cam.
        xco = "CR".
    end.
    disp ljl.ln ljl.gl gl.sname ljl.acc format "x(21)" crc.code xamt xco with down width 132 frame jlprt no-label no-box.

    if eknp_bal = 0 then do:
        if KOd + KBe + KNP <> "" then do:
            put "КОд " KOd " КВе " KBe " КНП " KNP skip.
        end.
        KOd = "". KBe = "". KNP = "".
    end.

    if g-fname = "OUTRMZ" then do:
        if ljl.ln = 1 then do:
            find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                v-kod = "".
                v-kod = "КОД: " + substr(sub-cod.rcode,1,2) + " КБе: " + substr(sub-cod.rcode,4,2) + " КНП: " + substr(sub-cod.rcode,7,3).
            end.
        end.
        if ljl.ln = 2 then do:
            put unformatted v-kod skip.
        end.
        if ljl.ln = 3 then do:
            if ljl.acc <> "" then do:
                find first aaa where aaa.aaa = ljl.acc no-lock no-error.
                if avail aaa then do:
                    v-kod = "".
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif and cif.geo = "021" then v-kod = "1".
                    if avail cif and cif.geo <> "021" then v-kod = "2".
                    find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                    if avail sub-cod then v-kod = v-kod + sub-cod.ccode.
                end.
            end.
            else do:
                v-kod = "".
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
            end.
        end.
        if ljl.ln = 4 then do:
            put unformatted  "КОД: " + v-kod + " КБе: 14" + " КНП: 840" skip.
        end.
    end.

    if last-of(ljl.crc) then do:
        put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.
        xcam = 0. xdam = 0.
        KOd = "". KBe = "". KNP = "".
    end.

    if ljl.subled eq "arp" then do:
        find first wf where wf.wsub eq "arp" and wf.wacc eq ljl.acc no-error.
        if not available wf then do:
            create wf.
            wf.wsub = "arp".
            wf.wacc = ljl.acc.
        end.
    end.
    else if ljl.subled eq "cif" then do:
        find first wf where wf.wsub eq "cif" and wf.wacc eq ljl.acc no-error.
        if not available wf then do:
            find aaa where aaa.aaa eq ljl.acc no-lock.
            create wf.
            wf.wsub = "cif".
            wf.wacc = ljl.acc.
            wf.wcif = aaa.cif.
        end.
    end.
end.
DO:
put "--------------------------------------"
    "----------------------------------------" skip(0).

/*********** KURSS **************/
conve = false.
for each ljl of jh no-lock:
    if isConvGL(ljl.gl) then do:
       conve = true.
       leave.
    end.
end.

if conve and jh.sub eq "jou" then do:
    find joudoc where joudoc.docnum eq v_doc no-lock.
    find d_crc where d_crc.crc eq joudoc.drcur no-lock.
    find c_crc where c_crc.crc eq joudoc.crcur no-lock.

    if bas_crc ne d_crc.crc then put "  " +
    d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
    " " + vcode + "/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
    d_crc.code format "x(80)" skip.

    if bas_crc ne c_crc.crc then put "  " +
    c_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
    " " + vcode + "/ " + trim (string (joudoc.sn, "zzzzzzz")) + " " +
    c_crc.code format "x(80)" skip.
end.


for each ljl of jh where ljl.ln = 1 use-index jhln no-lock break by ljl.crc by ljl.ln:
    if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi = 1 to 5 :
        if vi = 1 then do:
            ss = 1.
            repeat:
                if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
                    find joudoc where joudoc.docnum eq v_doc no-lock no-error.
                    if avail joudoc then do:
                        if (joudoc.dracctype = "1" and joudoc.cracctype = "5") or (joudoc.dracctype = "2" and joudoc.cracctype = "5") then do:
                            create remfile.
                            remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                        end.
                        else do:
                            create remfile.
                            remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                        end.
                    end.
                    if not avail joudoc then do:
                        create remfile.
                        remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                    end.
                end.
                else leave.
                    ss = ss + 60.
                end.
                /* arp ili cif */
                for each wf:
                    if wf.wsub eq "cif" then do:
                    find cif where cif.cif eq wf.wcif no-lock.
                    create remfile.
                    if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
                    else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
                end.
                else if wf.wsub eq "arp" then do:
                    find arp where arp.arp eq wf.wacc no-lock.
                    /*            find sub-cod where sub-cod.d-cod eq "arprnn" and
                    sub-cod.acc eq wf.wacc no-lock no-error.*/
                    find sub-cod where sub-cod.d-cod eq "arprnn" and
                    sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                    if available sub-cod then do:
                        create remfile.
                        remfile.rem =
                        "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
                    end.
                    else do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des.
                    end.
                end.
            end.
        end.
        else if (trim(ljl.rem[vi]) ne "" ) then do:
            create remfile.
            remfile.rem = "     " + trim(ljl.rem[vi]).
        end.
    end.  /* do */
    else do:
        /* arp ili cif */
        for each wf:
            if wf.wsub eq "cif" then do:
                find cif where cif.cif eq wf.wcif no-lock.
                create remfile.
                if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
                else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
            end.
            else if wf.wsub eq "arp" then do:
                find arp where arp.arp eq wf.wacc no-lock.
                /*           find sub-cod where sub-cod.d-cod eq "arprnn" and
                sub-cod.acc eq wf.wacc no-lock no-error.*/
                find sub-cod where sub-cod.d-cod eq "arprnn" and
                sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                if available sub-cod then do:
                    create remfile.
                    remfile.rem =
                    "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
                end.
                else do:
                    create remfile.
                    remfile.rem = "     " + wf.wacc + " " + arp.des.
                end.
            end.
        end.
    end.
end. /* for each */

for each remfile:
   put unformatted remfile.rem skip.
end.

END.

if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(3).

if vcash = false then do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if ofc.mday[2] = 1 then put skip(14).
    else put skip(1).
end.
g-officer = g-ofc.

output close.

def var v-prtorder as logical init "no" format "да/нет".
if oper_Ok = 2 then message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder.
if v-prtorder then do:
    unix silent prit -t vou.img.
    pause 0.
end.

pause 0.
for each ljl :
    delete ljl.
end.
for each wf :
    delete wf.
end.
for each remfile :
    delete remfile.
end.





