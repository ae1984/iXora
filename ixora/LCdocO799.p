/*LCdocO799.p
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
        09/09/2009 evseev - взял за основу LCdocs
 * BASES
        BANK COMM
 * CHANGES
        05.03.2012 Lyubov  - добавила другие форматы сообщений
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
define shared variable s-lccor like lcswt.lccor.
def shared var s-mt as inte.

def var str as char.
str = 'O' + string(s-mt) + '-'.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

if s-mt = 799 then
run sel2('Docs',' MT 799 | Payment Order ', output v-sel).
if s-mt = 999 then
run sel2('Docs',' MT 999 | Payment Order ', output v-sel).
if s-mt = 499 then
run sel2('Docs',' MT 499 | Payment Order ', output v-sel).

case v-sel:
    when 1 then do:
            if s-mt = 799 then do:
                output stream out to MT799.txt.
                put stream out unformatted 'MT799: Free Format Message' skip
                                           'To Institution '.
            end.
            if s-mt = 999 then do:
                output stream out to MT999.txt.
                put stream out unformatted 'MT999: Free Format Message' skip
                                           'To Institution '.
            end.
            if s-mt = 499 then do:
                output stream out to MT499.txt.
                put stream out unformatted 'MT499: Free Format Message' skip
                                           'To Institution '.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' and LCh.value4 = str + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted '20:Transaction Reference Number' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' and LCh.value4 = str + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted '21:Related Reference' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'RREF' and LCh.value4 = str + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.


            put stream out unformatted '79:Narrative' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Narrat' and LCh.value4 = str + string(s-lccor,'999999') no-lock no-error.
            if avail lch then do:
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,50)) SKIP.
                    k = k - 50.
                    if k <= 0 then leave.
                    i = i + 50.
                end.
            end.

            if s-mt = 799 then do:
                output stream out close.
                unix silent cptwin MT799.txt winword.
                unix silent rm -f MT799.txt.
            end.
            if s-mt = 999 then do:
                output stream out close.
                unix silent cptwin MT999.txt winword.
                unix silent rm -f MT999.txt.
            end.
            if s-mt = 499 then do:
                output stream out close.
                unix silent cptwin MT499.txt winword.
                unix silent rm -f MT499.txt.
            end.

    end.
    when 2 then do:
        find first lcres where lcres.lc = s-lc + '_' + string(s-lccor) and lcres.jh > 0 no-lock no-error.
        if avail lcres then do:
            for each lcres where lcres.lc = s-lc + '_' + string(s-lccor) and lcres.jh > 0 no-lock:
                find first jh where jh.jh = lcres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
end case.