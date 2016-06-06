/* dvou.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        18/11/2011 evseev - переход на ИИН/БИН
        06.03.2012 damir - переход на новые форматы, нередактируемые документы.
        07.03.2012 damir - изменил формат курса конвертации.
        13.03.2012 damir - добавил возможность печати на матричный принтер пользователей которые есть в printofc.
        16.05.2012 damir - изменения в формате и в примечании.
        30.05.2012 damir - добавил ConvDocClass, доп.строки и валюту в опер.ордер.
        23.08.2012 evseev - иин/бин
        26.12.2012 damir - Внедрено Т.З. 1624.
*/
{chbin.i}
{keyord.i} /*Переход на новые и старые форматы форм*/
{classes.i}

define input parameter kuda_vivodim as character.

define buffer d_crc for crc.
define buffer c_crc for crc.

define variable bas_crc like crc.crc initial 1.
define variable v_doc   as character format "x(10)".
define variable dtreg   as date format "99/99/9999".
define variable dttime  as integer.
define variable refn    as character.
define variable vcode   as character format "x(3)".

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif
   field wcrc like crc.crc.

define new shared temp-table remfile
   field rem as character.

def new shared var v-point  like point.point.
define shared var s-jh      like jh.jh .

define buffer bjl for jl.

DEF VAR Doc         as CLASS ConvDocClass.
def var ss          as int.
def var vi          as int.
def var vcash       as log.
define var vdb      as cha format "x(9)" label " ".
define var vcr      as cha format "x(9)" label " ".
define var vdes     as cha format "x(32)" label " ". /* chart of account desc */
define var vname    as cha format "x(30)" label " ". /* name of customer */
define var vrem     as cha format "x(55)" extent 7 label " ".
define var vamt     like jl.dam extent 7 label " ".
define var vext     as cha format "x(40)" label " ".
define var vtot     like jl.dam label " ".
define var vcontra  as cha format "x(53)" extent 5 label " ".
define var vpoint   as int.
define var inc      as int.
define var tdes     like gl.des.
define var tty      as cha format "x(20)".
define var vconsol  as log.
define var vcif     as cha format "x(6)" label " ".
define var vofc     like ofc.ofc label  " ".
def var vcrc        like crc.code label " ".
def var xamt        like fun.amt.
def var xdam        like jl.dam.
def var xcam        like jl.cam.
def var xco         as char format "x(2)" label "".
def var vcha2       as cha format "x(50)".
def var vcha3       as cha format "x(50)".
def var vcha1       as cha format "x(65)".
def var v-crcrate1  as decimal format "zzzz.9999".
def var v-tmpstr    as char.
def var v-bankbin as char.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

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

Doc = NEW ConvDocClass(0,Base).

define variable vv-cif like cif.cif.

define new shared temp-table ljl like jl.

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.
find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
   create ljl.
   buffer-copy jl to ljl.
end.

/*find dealing_doc where dealing_doc.jh eq s-jh no-lock no-error.
v_doc = dealing_doc.docno.*/
dtreg   = jh.whn.
dttime  = jh.tim.
vv-cif  = jh.cif.
/*v-crcrate1 = dealing_doc.rate.*/

find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then do:
    if dtreg ge v-bin_rnn_dt then v-bankbin = trim(sysc.chval).
    else v-bankbin = trim(cmp.addr[2]).
end.
else v-bankbin = trim(cmp.addr[2]).

if Doc:FindDocJH(string(jh.jh)) then do:
    assign
    v_doc = Doc:DocNo
    v-crcrate1 = Doc:rate.
end.

output to vou1.img page-size 0.

put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put
"============================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(dttime,"HH:MM") skip
    "Рег.Nr." + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put point.name skip.
put point.addr[1] skip.
put string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
    "Dok.Nr." + trim(refn) +
    "   /" + ofc.name + "/" + ofc.ofc format "x(78)" skip.
put
"============================================================================="
    skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream v-out unformatted
    "<TR><TD align=center><FONT size=3>ОПЕРАЦИОННЫЙ ОРДЕР</FONT></TD></TR>" skip
    "<TR><TD height=""30""></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" cmp.name + "  " + string(dtreg,"99/99/9999") + "  " + string(dttime,"HH:MM") "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>Рег.Nr.  " v-bankbin + "," + cmp.addr[3] "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" point.name "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" point.addr[1] "</FONT></TD></TR>" skip
    "<TR><TD align=left><FONT size=2>" string(jh.jh) + "/" + v_doc + "/" + vv-cif + "/" + "Dok.Nr." + trim(refn) + "   /" +
    ofc.name + "/" + ofc.ofc "</FONT></TD></TR>" skip
    "<TR><TD>=============================================================================</TD></TR>" skip.
put stream v-out unformatted
    "</TABLE>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

xdam = 0. xcam = 0.
for each ljl of jh use-index jhln no-lock break by ljl.crc by ljl.ln :
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

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
    displ
        ljl.ln ljl.gl gl.sname ljl.acc format "x(16)" crc.code xamt xco
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

DO:

put "--------------------------------------"
    "----------------------------------------" skip(0).

/*********** KURSS **************/

for each ljl of jh where ljl.ln = 1 use-index jhln no-lock break by ljl.crc by ljl.ln :
    if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi = 1 to 5 :
        if vi = 1 then do:
            ss = 1.
            repeat:
                if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
                    create remfile.
                    remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                end.
                else leave.
                ss = ss + 60.
            end.
            /* arp ili cif */
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
                    find arp where arp.arp eq wf.wacc no-lock.
                    find sub-cod where sub-cod.d-cod eq "arprnn" and sub-cod.acc eq wf.wacc and sub = 'arp' no-lock no-error.
                    if available sub-cod then do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
                    end.
                    else do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des.
                    end.
                end.
            end. /*for each wf*/
        end.
        else if (trim(ljl.rem[vi]) ne "" ) then do:
            create remfile.
            remfile.rem = "     " + trim(ljl.rem[vi]).
        end.
    end.  /* do */
    else do:
        /* arp ili cif */
        gonext:
        for each wf:
            find crc where crc.crc = wf.wcrc no-lock no-error.
            if wf.wsub eq "cif" then do:
                find cif where cif.cif eq wf.wcif no-lock.
                create remfile.
                if v-bin then do:
                    if dtreg ge v-bin_rnn_dt then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin + " " + crc.code.
                    else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + crc.code.
                end.
                else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + crc.code.
            end.
            else if wf.wsub eq "arp" then do:
                if trim(wf.wacc) = "KZ56470142870A010816" then next gonext.
                find arp where arp.arp eq wf.wacc no-lock.
                find sub-cod where sub-cod.d-cod eq "arprnn" and sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                if available sub-cod then do:
                    create remfile.
                    remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode + " " + crc.code .
                end.
                else do:
                    create remfile.
                    remfile.rem = "     " + wf.wacc + " " + arp.des + " " + crc.code.
                end.
            end.
        end.
    end.
end. /* for each */

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR><TD>----------------------------------------------------------------------------------------------------------------------------------</TD></TR>" skip.
for each remfile:
    put unformatted remfile.rem skip.

    if (remfile.rem matches "*Учет собственных средств*") or (remfile.rem matches "*Полученная валюта*") then next.
    put stream v-out unformatted
        "<TR><TD align=left><FONT size=2>" remfile.rem "</FONT></TD></TR>" skip.
end.
put stream v-out unformatted
    "</TABLE>" skip.

END.

if Doc:FindDocJH(string(jh.jh)) then do:
    find crc where crc.crc = Doc:crc no-lock no-error.
    if Doc:DocType >= 1 and Doc:DocType <= 4 then assign v-tmpstr = crc.code.
    if Doc:DocType = 5 or Doc:DocType = 6 then assign v-tmpstr = Doc:CRCC:get-code(Doc:tclientaccno) + "-" +
    Doc:CRCC:get-code(Doc:vclientaccno).
end.

put stream v-out unformatted
    "<P align=left><FONT size=2>Курс " v-tmpstr + ":" + string(v-crcrate1,"zzz,zz9.9999") "</FONT></P>" skip
    "<P align=left><FONT size=2>Менеджер ................ Контролер ................</FONT></P>" skip.

put "Курс конвертации: "  v-crcrate1 skip.
put "======================================"
    "================================================" skip(3).

put
"Менеджер ................ Контролер ................" skip(1).

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).

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

output close.

pause 0.

if v-noord = no then do:
    if kuda_vivodim eq "prit" then do:
        unix silent value (kuda_vivodim + " vou1.img").
    end.
    else do:
        unix value (kuda_vivodim + " vou1.img").
    end.
end.
else do:
    if kuda_vivodim eq "prit" then do:
        find first printofc where trim(printofc.ofc) = trim(g-ofc) and lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
        if avail printofc then unix silent value (kuda_vivodim + " vou1.img").
        else unix silent cptwin value(v-file2) winword.
    end.
    else do:
        find first printofc where trim(printofc.ofc) = trim(g-ofc) and lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
        if avail printofc then unix value (kuda_vivodim + " vou1.img").
        else unix silent cptwin value(v-file2) winword.
    end.
end.

for each ljl :
    delete ljl.
end.
for each wf :
    delete wf.
end.
for each remfile :
    delete remfile.
end.

if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.