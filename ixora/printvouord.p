/* printvouord.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Формирование и печать операционного ордера.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - x-jls.
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
        06.03.2012 damir....
        04.04.2012 damir - изменения вывода joudoc.info в форме ордера.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        18.04.2012 damir - небольшие изменения по формату вывода в WORD.
        26.04.2012 damir - подтягивает время создания проводки, а не текущее время.
        30.05.2012 damir - добавил ConvDocClass, доп.строки в опер.ордер.
        04.06.2012 damir - вывод курса конвертации.
        23.08.2012 evseev - иин/бин
        02/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
        26.12.2012 damir - Внедрено Т.З. 1624.
        07.06.2013 yerganat- tz1673,но в Примечание вытягиваю  по 70 символов.
*/

/*{global.i}*/
{chbin.i}
{classes.i}
{convgl.i "bank"}

def input parameter oper_Ok as int.

DEF VAR Doc         as CLASS ConvDocClass.
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
def var bas_crc     like crc.crc initial 1.
def var v_doc       as char format "x(10)".
def var dtreg       as date format "99/99/9999".
def var refn        as char.
def var vcode       as char format "x(3)".
def var vcash       as log.
def var vdb         as cha format "x(9)" label " ".
def var vcr         as cha format "x(9)" label " ".
def var vdes        as cha format "x(32)" label " ". /* chart of account desc */
def var vname       as cha format "x(30)" label " ". /* name of customer */
def var vrem        as cha format "x(55)" extent 7 label " ".
def var vamt        like jl.dam extent 7 label " ".
def var vext        as cha format "x(40)" label " ".
def var vtot        like jl.dam label " ".
def var vcontra     as cha format "x(53)" extent 5 label " ".
def var vpoint      as int.
def var inc         as int.
def var tdes        like gl.des.
def var tty         as cha format "x(20)".
def var vconsol     as log.
def var vcif        as cha format "x(6)" label " ".
def var vofc        like ofc.ofc label  " ".
def var vcrc        like crc.code label " ".
def var xamt        like jl.dam.
def var xdam        like jl.dam.
def var xcam        like jl.cam.
def var xco         as char format "x(2)" label "".
def var vcha2       as cha format "x(50)".
def var vcha3       as cha format "x(50)".
def var vcha1       as cha format "x(65)".
def var l-prn       as logical init "no" format "да/нет".
def var ss          as int.
def var vi          as int.
def var vv-cif      like cif.cif.
def var s_payment   as character.
def var obmenGL2    as integer.
def var v-cashgl    as integer.
def var v-remtrz    as char.
def var v-kod       as char.
def var v-prtorder  as logi init "no" format "да/нет".
def var v-lotmp     as logi format "да/нет" init no.
def var v-docno     as char.
def var v-crcrate1  as decimal format "zzzz.9999".
def var v-tmpstr    as char init "".
def var v-tmp       as char init "".

def buffer d_crc for crc.
def buffer c_crc for crc.
def buffer bjl   for jl.

def shared var s-jh like jh.jh .
def new shared var g-officer like ofc.ofc.
def new shared var v-point like point.point.

define new shared temp-table ljl like jl.

def buffer b-ljl for ljl.

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif
   field wcrc like crc.crc.

define new shared temp-table remfile
   field rem as character.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.
def var v-bankbin as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.




{x-jlvou.f}

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.
find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenGL2 = sysc.inval.
else obmenGL2 = 100200.
find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.
find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
    if jl.ln = 1 then v-remtrz = substr(jl.rem[1],1,10).
    create ljl.
    buffer-copy jl to ljl.
    dtreg = jl.jdt.
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

Doc = NEW ConvDocClass(0,Base).

output to vou.img page-size 0.

find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then do:
    if dtreg ge v-bin_rnn_dt then v-bankbin = trim(sysc.chval).
    else v-bankbin = trim(cmp.addr[2]).
end.
else v-bankbin = trim(cmp.addr[2]).

put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put
"============================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(time,"HH:MM") skip
    "Рег.Nr." + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put point.name skip.
put point.addr[1] skip.
put string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
    "Dok.Nr." + trim(refn) +
    "   /" + ofc.name  format "x(78)" skip.
put
"============================================================================="
    skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    "<TR><TD align=center><FONT size=3>ОПЕРАЦИОННЫЙ ОРДЕР</FONT></TD></TR>" skip
    "<TR><TD height=""30""></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" cmp.name + "  " + string(dtreg,"99/99/9999") + "  " + string(jh.tim,"HH:MM") "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>Рег.Nr.  " v-bankbin + "," + cmp.addr[3] "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" point.name "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" point.addr[1] "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" string(jh.jh) "/" + v_doc + "/" + vv-cif + "/" + "Dok.Nr." + trim(refn) + "   /" +
    ofc.name "</FONT></TD></TR>" skip
    "<TR><TD>=============================================================================</TD></TR>" skip.
put stream v-out unformatted
    "</TABLE>" skip.

vcash = false.
xdam = 0. xcam = 0.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

for each ljl of jh use-index jhln no-lock break by ljl.crc by ljl.ln:
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

    eknp_bal = eknp_bal + ljl.dam - ljl.cam.
    run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).

    if (ljl.gl = v-cashgl) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or ((ljl.gl = obmenGL2) and
    can-find (sub-cod where sub-cod.sub = "arp" and sub-cod.acc = ljl.acc and sub-cod.d-cod = "arptype" and
    sub-cod.ccode = "obmen1002" no-lock)) then vcash = true.

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
    disp
        ljl.ln ljl.gl gl.sname ljl.acc format "x(21)" crc.code xamt xco
    with down width 132 frame jlprt no-label no-box.

    put stream v-out unformatted
        "<TR align=left><FONT size=2>" skip
        "<TD>" string(ljl.ln) "</TD>" skip
        "<TD>" string(ljl.gl) "</TD>" skip
        "<TD>" string(gl.sname) "</TD>" skip
        "<TD>" ljl.acc "</TD>" skip
        "<TD>" crc.code "</TD>" skip
        "<TD>" string(xamt,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" xco "</TD>" skip
        "</FONT></TR>" skip.

    if eknp_bal = 0 then do:
        if KOd + KBe + KNP <> "" then do:
            put "КОд " KOd " КБе " KBe " КНП " KNP skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=7>КОд " KOd + "    КБе " + KBe + "    КНП " + KNP "</TD>" skip
                "</FONT></TR>" skip.
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

            put stream v-out unformatted
                "<TR align=center><FONT size=2>" skip
                "<TD colspan=6>" v-kod "</TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.
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

            put stream v-out unformatted
                "<TR align=center><FONT size=2>" skip
                "<TD colspan=6>КОД: " + v-kod + " КБе: 14" + " КНП: 840</TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.
        end.
    end.
    if last-of(ljl.crc) then do:
       put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.

       put stream v-out unformatted
            "<TR align=rigth><FONT size=2>" skip
            "<TD colspan=5>" vcha2 "</TD>" skip
            "<TD>" string(xdam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" crc.code "</TD>" skip
            "</FONT></TR>" skip
            "<TR align=rigth><FONT size=2>" skip
            "<TD colspan=5>" vcha3 "</TD>" skip
            "<TD>" string(xcam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" crc.code "</TD>" skip
            "</FONT></TR>" skip.

       xcam = 0. xdam = 0.
       KOd = "". KBe = "". KNP = "".
    end.

    if ljl.subled eq "arp" then do:
        find first wf where wf.wsub eq "arp" and wf.wacc eq ljl.acc no-error.
        if not available wf then do:
            create wf.
            wf.wsub = "arp".
            wf.wacc = ljl.acc.
            wf.wcrc = ljl.crc.
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
            wf.wcrc = ljl.crc.
        end.
    end.
end.

put stream v-out unformatted
    "</TABLE>" skip.

define variable conve as logical.

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

    if bas_crc ne d_crc.crc then do:
        put "  " + d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") + " " + vcode + "/ " +
        trim (string (joudoc.bn, "zzzzzzz")) + " " + d_crc.code format "x(80)" skip.

        put stream v-out unformatted
            "<P align=left><FONT size=2>" d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
            " " + vcode + "/ " + trim(string(joudoc.bn,"zzzzzzz")) + " " + d_crc.code "</FONT></P>" skip.
    end.
    if bas_crc ne c_crc.crc then do:
        put "  " + c_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") + " " + vcode + "/ " +
        trim (string (joudoc.sn, "zzzzzzz")) + " " + c_crc.code format "x(80)" skip.

        put stream v-out unformatted
            "<P align=left><FONT size=2>" d_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
            " " + vcode + "/ " + trim(string(joudoc.sn,"zzzzzzz")) + " " + c_crc.code "</FONT></P>" skip.
    end.
end.


for each ljl of jh where ljl.ln = 1 use-index jhln no-lock break by ljl.crc by ljl.ln:
    if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi = 1 to 5 :
        if vi = 1 then do:
            ss = 1.
            repeat:
                if (trim(substring(ljl.rem[vi],ss,70)) ne "" ) then do:
                    find joudoc where joudoc.docnum eq v_doc no-lock no-error.
                    if avail joudoc then do:
                        if (joudoc.dracctype = "1" and joudoc.cracctype = "5") or (joudoc.dracctype = "2" and joudoc.cracctype = "5") then do:
                            create remfile.
                            remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                        end.
                        else do:
                            create remfile.
                            remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                        end.
                    end.
                    if not avail joudoc then do:
                        create remfile.
                        remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                    end.
                end.
                else leave.
                ss = ss + 70.
            end.

            /* arp ili cif */
            for each wf:
                find crc where crc.crc = wf.wcrc no-lock no-error.
                assign v-tmpstr = "".
                if Doc:FindDocJH(string(jh.jh)) then do:
                    assign v-tmpstr = crc.code.
                end.
                if wf.wsub eq "cif" then do:
                    find cif where cif.cif eq wf.wcif no-lock.
                    create remfile.
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin + " " + v-tmpstr.
                        else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + v-tmpstr.
                    end.
                    else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + v-tmpstr.
                end.
                else if wf.wsub eq "arp" then do:
                    find arp where arp.arp eq wf.wacc no-lock.
                    /*            find sub-cod where sub-cod.d-cod eq "arprnn" and
                    sub-cod.acc eq wf.wacc no-lock no-error.*/
                    find sub-cod where sub-cod.d-cod eq "arprnn" and
                    sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                    if available sub-cod then do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode + " " + v-tmpstr.
                    end.
                    else do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des + " " + v-tmpstr.
                    end.
                end.
            end.
        end.
        else if (trim(ljl.rem[vi]) ne "" ) then do:
            def var v-spaces as char init "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".
            create remfile.
            remfile.rem = v-spaces + trim(ljl.rem[vi]).
        end.
    end.  /* do */
    else do:
        /* arp ili cif */
        gonext:
        for each wf:
            if wf.wsub eq "cif" then do:
                find cif where cif.cif eq wf.wcif no-lock.
                create remfile.
                if v-bin then do:
                    if dtreg ge v-bin_rnn_dt then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
                    else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
                end.
                else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
            end.
            else if wf.wsub eq "arp" then do:
                if trim(wf.wacc) = "KZ56470142870A010816" then next gonext.
                find arp where arp.arp eq wf.wacc no-lock.
                /*           find sub-cod where sub-cod.d-cod eq "arprnn" and
                sub-cod.acc eq wf.wacc no-lock no-error.*/
                find sub-cod where sub-cod.d-cod eq "arprnn" and
                sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                if available sub-cod then do:
                    create remfile.
                    remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
                end.
                else do:
                    create remfile.
                    remfile.rem = "     " + wf.wacc + " " + arp.des.
                end.
            end.
        end.
    end.
end. /* for each */

find first ofc where ofc.ofc = g-ofc no-lock no-error.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR><TD>----------------------------------------------------------------------------------------------------------------------------------</TD></TR>" skip.
for each remfile:
    put unformatted remfile.rem skip.
    put stream v-out unformatted
        "<TR><TD align=left><FONT size=2>" remfile.rem "</FONT></TD></TR>" skip.
end.

put stream v-out unformatted
    "</TABLE>" skip.

/*Если документ создан 2.3.1, 2.3.2, 2.3.3, 2.3.4, 2.3.5 и т.д.*/
if Doc:FindDocJH(string(jh.jh)) then do:
    find crc where crc.crc = Doc:crc no-lock no-error.
    if Doc:DocType >= 1 and Doc:DocType <= 4 then assign v-tmp = crc.code.
    if Doc:DocType = 5 or Doc:DocType = 6 then assign v-tmp = Doc:CRCC:get-code(Doc:tclientaccno) + "-" +
    Doc:CRCC:get-code(Doc:vclientaccno).

    put stream v-out unformatted
    "<P align=left><FONT size=2>Курс " + v-tmp + ":" string(Doc:rate,"zzz,zz9.9999") "</FONT></P>" skip
    "<P align=left><FONT size=2>Менеджер ................ Контролер ................</FONT></P>" skip.
end.

/*Убрал по запросу*/
/*if g-fname = "ACOM" then do:
    for each ljl where ljl.acc <> "" and ljl.dc = "D" no-lock, each aaa where aaa.aaa = ljl.acc no-lock:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            find first b-ljl where b-ljl.ln = ljl.ln + 1 and b-ljl.dc = "C" and (string(b-ljl.gl) begins "4") no-lock no-error.
            if avail b-ljl then assign v-lotmp = yes.
        end.
    end.
    if v-lotmp = no then do:
        if avail joudoc then put stream v-out unformatted
        "<P align=right><FONT size=2>" joudoc.info "__________________</FONT></P>" skip.
    end.
end.
else do:
    if g-fname <> "A_KZ" then do:
        if avail joudoc then put stream v-out unformatted
            "<P align=right><FONT size=2>" joudoc.info "__________________</FONT></P>" skip.
    end.
end.*/

if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(3).

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
if vcash = false then do:
   if ofc.mday[2] = 1 then put skip(14).
   else put skip(1).
end.
g-officer = g-ofc.
output close.

output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

if oper_Ok = 2 then do:
    message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder.
end.
else if oper_Ok = 0 then do:
    v-prtorder = false.
end.
else v-prtorder = true. /*иначе, входной параметр равен 1, и переменную v-prtorder не меняем, т.е. печатаем операционный ордер*/

if v-prtorder then unix silent cptwin value(v-file2) winword.

/*unix silent prit -t vou.img.*/
pause 0.

if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.