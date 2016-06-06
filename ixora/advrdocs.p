/*advrdocs.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        формирование документов
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
        24/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def shared var s-lc like LC.LC.
def var v-sel as integer.
define new shared   var s-jh like jh.jh .
def stream out.
def var v-infile as char.
def var v-ofile as char.
def var v-str as char.
def var v-amt as char.
def var i as integer.
def var k as integer.
def buffer b-lch for lch.
def var v-logsno as char init "no,n,нет,н,1".

def shared var s-number like lcevent.number.
def shared var s-event like lcevent.event.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

run sel2('Docs',' MT 734 | Payment Order ', output v-sel).
case v-sel:
    when 1 then do:
            output stream out to MT734.txt.
            put stream out unformatted 'MT734: Advice of Refusal' skip
                                        'To Institution '.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'InstTo734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted LCeventh.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted "20:Sender's TRN" skip.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'SendTRN734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted LCeventh.value1 skip.

            put stream out unformatted "21:Presenting Bank's Reference" skip.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'PrBnkRef734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted LCeventh.value1 skip.

            put stream out unformatted "32A:Date and Amount of Utilisation" skip.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'DtUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted datestr(LCeventh.value1) .
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'CurUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then do:
                find first crc where crc.crc = int(LCeventh.value1) no-lock no-error.
                if avail crc then put stream out unformatted crc.code.
            end.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'AmtUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted trim(replace(string(deci(LCeventh.value1),'>>>>>>>>9.99'),'.',',')) skip.

            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'ChCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
                put stream out unformatted '73:Charges Claimed' skip.
                k = length(LCeventh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(LCeventh.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'TotAmtClO734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
               put stream out unformatted '32' + trim(LCeventh.value1) + ':Total Amount Claimed' skip.
               if trim(LCeventh.value1) = 'A' then do:
                  find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'DtTtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
                  if avail LCeventh then put stream out unformatted datestr(LCeventh.value1) .
               end.
               find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'CurTtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
               if avail LCeventh then do:
                  find first crc where crc.crc = int(LCeventh.value1) no-lock no-error.
                  if avail crc then put stream out unformatted crc.code.
               end.
               find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'TtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
               if avail LCeventh then put stream out unformatted trim(replace(string(deci(LCeventh.value1),'>>>>>>>>9.99'),'.',',')) skip.

            end.

            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'AccWBnkA734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
               put stream out unformatted '57a:Account With Bank' skip.
               put stream out unformatted '/' + LCeventh.value1 skip.
               find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'AccWBnkB734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
               if avail LCeventh then put stream out unformatted LCeventh.value1 skip.
            end.


            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'S2RInf734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
                put stream out unformatted '72:Sender to Receiver Information' skip.
                k = length(LCeventh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(LCeventh.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.


           put stream out unformatted '77J:Discrepancies' skip.
           find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'Disc734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
                k = length(LCeventh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(LCeventh.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
/*
           put stream out unformatted '77B:Disposal of Documents' skip.
           find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'DisOfDoc734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh and trim(LCeventh.value1) <> '' then do:
                k = length(LCeventh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(LCeventh.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
*/
            put stream out unformatted '77B:Disposal of Documents' skip.
            find first LCeventh where LCeventh.lc = s-lc and LCeventh.kritcode = 'DisOfDoc734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
            if avail LCeventh then put stream out unformatted '/' + LCeventh.value1 + '/' skip.


            output stream out close.
            unix silent cptwin MT734.txt winword.
            unix silent rm -f MT734.txt.
    end.
    when 2 then do:
        find first lceventres where lceventres.lc = s-lc and lceventres.jh > 0 and lceventres.number = s-number and lceventres.event = s-event no-lock no-error.
        if avail lceventres then do:
            for each lceventres where lceventres.lc = s-lc and lceventres.jh > 0 and lceventres.number = s-number and lceventres.event = s-event no-lock:
                find first jh where jh.jh = lceventres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
end case.