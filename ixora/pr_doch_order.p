/*  pr_doch_order.p
 * MODULE
        Название модуля
 * DESCRIPTION
    печать ордера для акцептования
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
        01.12.2010 Luiza
 * BASES
        BANK COMM
 * CHANGES
        22.02.2011 Luiza - добавила вывод итого после каждого вида валюты
        31.05.2011 Luiza - расширила формат вывода для prn_code
        18.04.2012 damir - формирование ордера в WORD.
        23.08.2012 evseev - иин/бин
        26.12.2012 damir - Внедрено Т.З. 1624.
*/

{keyord.i} /*Переход на формат ордера в WORD*/
{chbin.i}

def input parameter prn_docid   as char format "x(9)".
def input parameter dtreg       as date format "99/99/9999".
def input parameter dtime       as inte.
def input parameter drwho       as char.


def var numln       as inte no-undo.
def var prn_des     as char format "x(25)" no-undo.
def var prn_gl      as inte format "999999" no-undo.
def var prn_crc     as inte no-undo.
def var prn_kzt     as char no-undo.
def var prn_amt     as deci no-undo.
def var total-dam   as deci no-undo.
def var total-cam   as deci no-undo.
def var p_name      as char no-undo.
def var p_addr      as char no-undo.
def var ofc_name    as char no-undo.
def var prn_code    as char format "x(25)" no-undo.
def var prn_rem1    as char format "x(60)" no-undo.
define shared var g-ofc like ofc.ofc.

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

for each point no-lock.
    p_name = point.name.
    p_addr =  point.addr[1].
end.
for each ofc where ofc.ofc = drwho no-lock.
    ofc_name = ofc.name.
end.

output to value("uni.img") page-size 0.

for each cmp no-lock:
    find sysc where sysc.sysc = "bnkbin" no-lock no-error.
    if v-bin then do:
        if dtreg ge v-bin_rnn_dt then v-bankbin = trim(sysc.chval).
        else v-bankbin = trim(cmp.addr[2]).
    end.
    else v-bankbin = trim(cmp.addr[2]).

    put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР (для контроля)" skip .
    put  "=========================================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(dtime,"HH:MM") skip
    "Рег.Nr." + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
    put p_name format "x(50)" skip.
    put p_addr format "x(50)" skip.
    put "Ном.докум. " + prn_docid + "   /" + ofc_name  format "x(78)" skip.
    put  "==========================================================================================" skip.

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream v-out unformatted
        "<TR><TD align=center><FONT size=3>ОПЕРАЦИОННЫЙ ОРДЕР &nbsp; (для контроля)</FONT></TD></TR>" skip
        "<TR><TD>=============================================================================</TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" trim(cmp.name) + "&nbsp;&nbsp;" + string(dtreg,"99/99/9999") + "&nbsp;&nbsp;" +
        string(dtime,"HH:MM") "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>Рег.Nr." trim(v-bankbin) + ",&nbsp;" + trim(cmp.addr[3]) "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" trim(p_name) "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" trim(p_addr) "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>Ном.докум.&nbsp;&nbsp;&nbsp;" trim(prn_docid) + "&nbsp;&nbsp;&nbsp;&nbsp;/" + trim(ofc_name) "</FONT></TD></TR>" skip
        "<TR><TD>=============================================================================</TD></TR>" skip.
    put stream v-out unformatted
        "</TABLE>" skip.
end.

numln = 0.
total-dam = 0.
total-cam = 0.
find first docl where docl.docid = prn_docid  no-lock.
prn_crc = docl.crc.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

for  each docl where  docl.docid = prn_docid  no-lock.
    if docl.crc <> prn_crc then do:
        put space (39) "ВСЕГО ДЕБЕТ  " total-dam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
        put space (39) "ВСЕГО КРЕДИТ " total-cam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.

        put stream v-out unformatted
            "<TR><FONT size=2>" skip
            "<TD colspan=3></TD>" skip
            "<TD colspan=2 align=left>ВСЕГО ДЕБЕТ</TD>" skip
            "<TD align=left>" string(total-dam,"zzz,zzz,zzz,zzz,zz9.99") "</TD>" skip
            "<TD align=left>" trim(prn_kzt) "</TD>" skip
            "</FONT></TR>" skip
            "<TR><FONT size=2>" skip
            "<TD colspan=3></TD>" skip
            "<TD colspan=2 align=left>ВСЕГО КРЕДИТ</TD>" skip
            "<TD align=left>" string(total-cam,"zzz,zzz,zzz,zzz,zz9.99") "</TD>" skip
            "<TD align=left>" trim(prn_kzt) "</TD>" skip
            "</FONT></TR>" skip.

        total-dam = 0.
        total-cam = 0.
        prn_crc = docl.crc.
    end.
    prn_amt = 0.
    if docl.dc = "D" then do:
        prn_amt = docl.dam.
        total-dam = total-dam + docl.dam.
    end.
    else do:
        prn_amt = docl.cam.
        total-cam = total-cam + docl.cam.
    end.
    prn_gl = docl.gl.
    find gl where gl.gl = prn_gl no-lock.
    if available gl then do:
        prn_des = gl.sname.
    end.
    else do:
        message "Ошибка!!! Не найден счет главной книги".
        hide message.
    end.
    numln = numln + 1.
    find crc where crc.crc = prn_crc no-lock.
    if available crc then prn_kzt = crc.code.
    else do:
        message "Ошибка!!! Не найден код валюты".
        hide message.
    end.
    put string(numln,"99") + " " + string(docl.gl) + " " + prn_des format "x(35)" " " docl.acc format "x(20)" " " prn_kzt " ".
    put prn_amt format "zzz,zzz,zzz,zzz,zz9.99" + " " docl.dc skip.

    put stream v-out unformatted
        "<TR align=left><FONT size=2>" skip
        "<TD>" string(numln,"99") "</TD>" skip
        "<TD>" string(docl.gl)    "</TD>" skip
        "<TD>" prn_des            "</TD>" skip
        "<TD>" docl.acc           "</TD>" skip
        "<TD>" prn_kzt            "</TD>" skip
        "<TD>" string(prn_amt,"zzz,zzz,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" docl.dc            "</TD>" skip
        "</FONT></TR>" skip.

    if numln = 1 then do:
        prn_rem1 =  docl.rem[1].
        prn_code = "КОД:" + substring(docl.cods,1,2) + " КБе:" + substring(docl.cods,4,2) + " КНП:" + substring(docl.cods,7,3).
    end.
end.

if length(prn_code) > 5 then do:
    put  prn_code format "x(50)" skip.

    put stream v-out unformatted
        "<TR align=left><FONT size=2>" skip
        "<TD colspan=7 align=left>" prn_code "</TD>" skip
        "</FONT></TR>" skip.
end.
put space (39) "ВСЕГО ДЕБЕТ  " total-dam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
put space (39) "ВСЕГО КРЕДИТ " total-cam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.

put stream v-out unformatted
    "<TR><FONT size=2>" skip
    "<TD colspan=3></TD>" skip
    "<TD colspan=2 align=left>ВСЕГО ДЕБЕТ</TD>" skip
    "<TD align=left>" string(total-dam,"zzz,zzz,zzz,zzz,zz9.99") "</TD>" skip
    "<TD align=left>" trim(prn_kzt) "</TD>" skip
    "</FONT></TR>" skip
    "<TR><FONT size=2>" skip
    "<TD colspan=3></TD>" skip
    "<TD colspan=2 align=left>ВСЕГО КРЕДИТ</TD>" skip
    "<TD align=left>" string(total-cam,"zzz,zzz,zzz,zzz,zz9.99") "</TD>" skip
    "<TD align=left>" trim(prn_kzt) "</TD>" skip
    "</FONT></TR>" skip.

put stream v-out unformatted
    "</TABLE>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    /*"<TR><TD height=""30""></TD></TR>" skip*/
    "<TR><TD>----------------------------------------------------------------------------------------------------------------------------------</TD></TR>" skip
    "<TR><TD><FONT size=2>Примечан.:  " trim(prn_rem1) "</FONT></TD></TR>" skip
    "<TR><TD>=============================================================================</TD></TR>" skip.
put stream v-out unformatted
    "</TABLE>" skip.

put stream v-out unformatted
    "<P><FONT size=2>Менеджер:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Контролер:</FONT></P>" skip.
put      "------------------------------------------------------------------------------------------" skip.
put "Примечан.: " prn_rem1 format "x(60)"  skip.
put     "==========================================================================================" skip(1).
put "Менеджер:                  Контролер:" skip.
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

if v-noord = no then unix silent prit -t value("uni.img").
else unix silent cptwin value(v-file2) winword.

return.


