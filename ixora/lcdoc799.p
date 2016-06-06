/*LCdoc799 .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Корреспонденция - входящий свифт - просмотр
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
        10/01/2011 Vera
 * BASES
        BANK COMM
 * CHANGES
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

{global.i}
def shared var s-lc    like LC.LC.
def shared var s-lccor like LCswt.lccor.
def var v-infile  as char.
def var v-outfile as char.
def var v-result  as char.
def var v-str     as char.
def var i         as integer.
def var k         as integer init 999.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def stream out.

    find first Lcswt where LCswt.lc = s-lc and LCswt.mt = 'O799' and LCswt.lccor = s-lccor no-lock no-error.
    if not avail LCswt then return.
    v-infile = LCswt.fname2.
    v-outfile = "MT799.txt".
    input through  value("cp " + "/data/import/lcmt/" + string(year(LCswt.rdt),"9999") + string(month(LCswt.rdt),"99") + string(day(LCswt.rdt),"99") + "/" + v-infile + " " + v-infile + ";echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message v-result + "Ошибка копирования файла " + v-infile view-as alert-box error.
        return.
    end.
    output stream out to value(v-outfile).
    put stream out unformatted 'MT799: Free Format Message' skip
                               'To Institution  ' + v-clecod + 'AXXX' skip.

    input from value(v-infile).
    repeat:
        import unformatted v-str.
        i = i + 1.
        v-str = trim(v-str).
        if v-str begins ":20:" then
        put stream out unformatted ':20: Transaction Reference Number' skip
                                   space(5) substr(v-str,5) skip.

        if v-str begins ":21:" then
        put stream out unformatted ':21: Related Reference' skip
                                   space(5) substr(v-str,5) skip.
        if v-str begins ":79:" and i < k then do:
            put stream out unformatted ':79: Narrative' skip
                                       space(5) substr(v-str,5) skip.
            k = i.
        end.
        if  not v-str begins '-}' and i > k then
         put stream out unformatted space(5) v-str skip.
    end.
    input close.
    output stream out close.

    unix silent value("cptwin " + v-outfile + " winword").
    unix silent value("rm -r " + v-outfile).
    unix silent value("rm -r " + v-infile).



