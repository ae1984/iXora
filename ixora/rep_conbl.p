/* rep_conbl.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Консолидированный баланс в тенге
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
        30/09/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        16.01.2013 damir - Внедрено Т.З. № 1610.
*/

{mainhead.i}
{rep_conbl_shared.i "new"}

define temp-table wrk no-undo /*final table for report*/
    field txb as char
    field totlev as integer
    field gl as integer
    field des as char.

/*************************************************************************************************************/
function GetNormSumm returns char (input summ as deci ):
    def var ss1 as deci.
    def var ret as char.
    if summ >= 0 then do:
        ss1 = summ.
        ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
    end.
    else do:
        ss1 = - summ.
        ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
    end.
    return trim(replace(ret,".",",")).
end function.
/*************************************************************************************************************/

def var bal1 as deci.
def var bal2 as deci.

dt1 = g-today - 8.
dt2 = g-today - 1.
update
    dt1 label ' Период с ' format '99/99/9999'
    dt2 label ' по ' format '99/99/9999' skip
with side-labels row 13 centered frame dat.

hide frame dat no-pause.

display "   Ждите...  "  with row 5 frame ww centered .

{r-branch.i &proc = "rep_conbl1"}

/*************************************************************************************************************/
for each temp break by temp.gl:
    if first-of(temp.gl) then do:
        create wrk.
        wrk.totlev = temp.totlev.
        wrk.gl = temp.gl.
        wrk.des = temp.des.
    end.
end.

hide all no-pause.
message " Отчеты по филиалам... " .

def stream rep_br.
/* Отчеты по всем филиалам */
for each comm.txb  where comm.txb.consolid no-lock:
    hide all no-pause.
    message " Отчет " comm.txb.info .

    output stream rep_br to value("rpt_" + comm.txb.bank + ".htm").
    put stream rep_br "<html><head><title>Сравнительный баланс в тенге " + comm.txb.info + "</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.
    put stream rep_br unformatted "<tr><td colspan=""6""> " + string(today) + " " + string(time,"HH:MM:SS") + " Исп. " + g-ofc + "</td>" skip.
    put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
    put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
    put stream rep_br unformatted "<tr><td colspan=""6"" style=""font:bold"">СРАВНИТЕЛЬНЫЙ БАЛАНС (ТЕНГЕ) " + comm.txb.info.
    put stream rep_br unformatted "  ЗА ПЕРИОД С " + string(dt1) + " ПО " + string(dt2) + "</td></tr>" skip.
    put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
    put stream rep_br unformatted "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>" + string(dt1) + "</td><td>" + string(dt2) + "</td>".
    put stream rep_br unformatted "<td>Разница</td></tr>" skip.


    for each wrk no-lock break by substr(trim(string(wrk.gl)),1,1) by substr(trim(string(wrk.gl)),1,2) by substr(trim(string(wrk.gl)),1,3):
        if first-of(substr(trim(string(wrk.gl)),1,1)) then do:
            if substr(trim(string(wrk.gl)),1,1) eq "1" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">АКТИВЫ</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "2" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ПАССИВЫ</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "3" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">КАПИТАЛ</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "4" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ДОХОДЫ</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "5" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">РАСХОДЫ</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "6" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС )</td></tr>" skip.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "7" then do:
                put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС )</td></tr>" skip.
            end.
        end. /*if first-of*/

        bal1 = 0. bal2 = 0.

        find first temp where temp.txb = comm.txb.bank and temp.gl = wrk.gl and temp.totlev = wrk.totlev and temp.des = wrk.des and temp.dt = dt1 no-lock no-error.
        if avail temp then bal1 = temp.baltot.

        find first temp where temp.txb = comm.txb.bank and temp.gl = wrk.gl and temp.totlev = wrk.totlev and temp.des = wrk.des and temp.dt = dt2 no-lock no-error.
        if avail temp then bal2 = temp.baltot.

        put stream rep_br unformatted "<tr><td>" + string(wrk.totlev) + "</td>" skip.
        put stream rep_br unformatted "<td>" + string(wrk.gl) + "</td>" skip.
        put stream rep_br unformatted "<td>" + wrk.des + "</td>" skip.
        put stream rep_br unformatted "<td>" + GetNormSumm(bal1) + "</td>" skip.
        put stream rep_br unformatted "<td>" + GetNormSumm(bal2) + "</td>" skip.
        put stream rep_br unformatted "<td>" + GetNormSumm(bal2 - bal1) + "</td></tr>" skip.
    end. /*for each wrk*/
    put stream rep_br unformatted "</table></body></html>" skip.
    output stream rep_br close.
end.

/* Консолидированный отчет */
hide all no-pause.
message " Консолидированный... " .

output stream rep_br to value("rep_br.htm").
put stream rep_br "<html><head><title>Сравнительный консолидированный баланс в тенге </title>" skip
"<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
"<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.
put stream rep_br unformatted "<tr><td colspan=""6""> " + string(today) + " " + string(time,"HH:MM:SS") + " Исп. " + g-ofc + "</td>" skip.
put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
put stream rep_br unformatted "<tr><td colspan=""6"" style=""font:bold"">СРАВНИТЕЛЬНЫЙ КОНСОЛИДИРОВАННЫЙ БАЛАНС (ТЕНГЕ) ".
put stream rep_br unformatted "  ЗА ПЕРИОД С " + string(dt1) + " ПО " + string(dt2) + "</td></tr>" skip.
put stream rep_br unformatted "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" skip.
put stream rep_br unformatted "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>" + string(dt1) + "</td><td>" + string(dt2) + "</td>".
put stream rep_br unformatted "<td>Разница</td></tr>" skip.


for each wrk no-lock break by substr(trim(string(wrk.gl)),1,1) by substr(trim(string(wrk.gl)),1,2) by substr(trim(string(wrk.gl)),1,3):
    if first-of(substr(trim(string(wrk.gl)),1,1)) then do:
        if substr(trim(string(wrk.gl)),1,1) eq "1" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">АКТИВЫ</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "2" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ПАССИВЫ</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "3" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">КАПИТАЛ</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "4" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ДОХОДЫ</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "5" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">РАСХОДЫ</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "6" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС )</td></tr>" skip.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "7" then do:
            put stream rep_br unformatted "<tr bgcolor=""#CCCCCC""><td colspan=""6"" style=""font:bold"">ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС )</td></tr>" skip.
        end.
    end. /*if first-of*/

    bal1 = 0. bal2 = 0.
    for each temp where temp.gl = wrk.gl and temp.totlev = wrk.totlev and temp.des = wrk.des and temp.dt = dt1 no-lock:
        bal1 = bal1 + temp.baltot.
    end.
    for each temp where temp.gl = wrk.gl and temp.totlev = wrk.totlev and temp.des = wrk.des and temp.dt = dt2 no-lock:
        bal2 = bal2 + temp.baltot.
    end.

    put stream rep_br unformatted "<tr><td>" + string(wrk.totlev) + "</td>" skip.
    put stream rep_br unformatted "<td>" + string(wrk.gl) + "</td>" skip.
    put stream rep_br unformatted "<td>" + wrk.des + "</td>" skip.
    put stream rep_br unformatted "<td>" + GetNormSumm(bal1) + "</td>" skip.
    put stream rep_br unformatted "<td>" + GetNormSumm(bal2) + "</td>" skip.
    put stream rep_br unformatted "<td>" + GetNormSumm(bal2 - bal1) + "</td></tr>" skip.
end. /*for each wrk*/

put stream rep_br unformatted "</table></body></html>" skip.
output stream rep_br close.

/*****************************************************************************************************************/
hide all no-pause.
message " Удаление временных файлов... "  .

output to run.cmd.
put unformatted "del c:\\tmp\\rep_br.htm~n".
put unformatted "del c:\\tmp\\rpt.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB01.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB02.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB03.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB04.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB05.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB06.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB07.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB08.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB09.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB10.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB11.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB12.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB13.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB14.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB15.htm~n".
put unformatted "del c:\\tmp\\rpt_TXB16.htm~n".
output close.
input through value ( "scp -q run.cmd Administrator@`askhost`:c:/tmp/run.cmd" ) .

hide all no-pause.
message " Копирование отчетов... ".
pause 1.

input through value ( "scp -q rpt_TXB00.htm Administrator@`askhost`:c:/tmp/rpt.htm" ) .
input through value ( "scp -q rpt_TXB01.htm Administrator@`askhost`:c:/tmp/rpt_TXB01.htm" ) .
input through value ( "scp -q rpt_TXB02.htm Administrator@`askhost`:c:/tmp/rpt_TXB02.htm" ) .
input through value ( "scp -q rpt_TXB03.htm Administrator@`askhost`:c:/tmp/rpt_TXB03.htm" ) .
input through value ( "scp -q rpt_TXB04.htm Administrator@`askhost`:c:/tmp/rpt_TXB04.htm" ) .
input through value ( "scp -q rpt_TXB05.htm Administrator@`askhost`:c:/tmp/rpt_TXB05.htm" ) .
input through value ( "scp -q rpt_TXB06.htm Administrator@`askhost`:c:/tmp/rpt_TXB06.htm" ) .
input through value ( "scp -q rpt_TXB07.htm Administrator@`askhost`:c:/tmp/rpt_TXB07.htm" ) .
input through value ( "scp -q rpt_TXB08.htm Administrator@`askhost`:c:/tmp/rpt_TXB08.htm" ) .
input through value ( "scp -q rpt_TXB09.htm Administrator@`askhost`:c:/tmp/rpt_TXB09.htm" ) .
input through value ( "scp -q rpt_TXB10.htm Administrator@`askhost`:c:/tmp/rpt_TXB10.htm" ) .
input through value ( "scp -q rpt_TXB11.htm Administrator@`askhost`:c:/tmp/rpt_TXB11.htm" ) .
input through value ( "scp -q rpt_TXB12.htm Administrator@`askhost`:c:/tmp/rpt_TXB12.htm" ) .
input through value ( "scp -q rpt_TXB13.htm Administrator@`askhost`:c:/tmp/rpt_TXB13.htm" ) .
input through value ( "scp -q rpt_TXB14.htm Administrator@`askhost`:c:/tmp/rpt_TXB14.htm" ) .
input through value ( "scp -q rpt_TXB15.htm Administrator@`askhost`:c:/tmp/rpt_TXB15.htm" ) .
input through value ( "scp -q rpt_TXB16.htm Administrator@`askhost`:c:/tmp/rpt_TXB16.htm" ) .
input through value ( "scp -q rep_br.htm Administrator@`askhost`:c:/tmp/rep_br.htm" ) .

input through value ( "scp -q /data/reports/uprav/consolid.xlsm Administrator@`askhost`:c:/tmp/consolid.xlsm" ) .

output to run.cmd.
put unformatted "start excel c:\\tmp\\consolid.xlsm".
output close.

input through value ( "scp -q run.cmd Administrator@`askhost`:c:/tmp/run.cmd" ) .

hide frame ww no-pause.
/**************************************************************************************************/

