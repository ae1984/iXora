/* LCmt707.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT707
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        30/11/2010 galina - добавила признак MT707
        09/12/2010 galina - выводи номер аккредитива заглавными буквами
        10/12/2010 galina - поправила копирование в swift
        28/12/2010 Vera   - временно закомментировала удаление s-value1
        29/12/2010 Vera   - перекомпиляция
        30/12/2010 madiyar - исправил копирование файла в Swift Alliance
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

{global.i}
def shared var s-lc like LC.LC.
define shared variable s-lcamend like lcamend.lcamend.
def var s-value1 as char.
def var what as char.
def var scod as char.
def var ValData as char.
def var tmpval as char.
def var v-file0 as char init 'MT707'.
def var v-result as char no-undo.
def var v-logsno as char init "no,n,нет,н,1".
{comm-txb.i}

def stream out.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def var k as integer.
def vaR I AS INTEGER.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'MT707' no-lock no-error.
if avail lcamendh and lookup(lcamendh.value1,v-logsno) > 0 then do:
    message 'You  choice had not been to create this type of message!' view-as alert-box.
    return.
end.
else do:

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NumAmend' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then s-value1 = replace(s-lc,"/", "_") + string(lcamendh.value1,'99').

    output stream out to value(v-file0).

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'InstTo' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted "\{1:F01" + v-clecod + "AXXXXXXXXXXXXX}\{2:I707" + lcamendh.value1 + "XN}\{4:" skip.

    put stream out unformatted ":20:".
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'SendRef' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted caps(lcamendh.value1) skip.

    put stream out unformatted ":21:".
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ReceRef' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted lcamendh.value1 skip.


    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DtAmend' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ":30:" + datestr(lcamendh.value1) skip.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NumAmend' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ":26E:" + string(lcamendh.value1,'99') skip.

    put stream out unformatted ':59:'.
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'BenAmd' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        k = length(lcamendh.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lcamendh.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.

    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NewDtEx' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ":31E:" + datestr(lcamendh.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch then find first crc where crc.crc = int(lch.value1) no-lock no-error.


    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'IncAmt' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ":32B:".
        if avail crc then put stream out unformatted crc.code.
        put stream out unformatted trim(replace(string(deci(lcamendh.value1),'>>>>>>>>9.99'),'.',',')) skip.
    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DecAmt' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ":33B:".
        if avail crc then put stream out unformatted crc.code.
        put stream out unformatted trim(replace(string(deci(lcamendh.value1),'>>>>>>>>9.99'),'.',',')) skip.
    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NewAmt' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ":34B:".
        if avail crc then put stream out unformatted crc.code.
        put stream out unformatted trim(replace(string(deci(lcamendh.value1),'>>>>>>>>9.99'),'.',',')) skip.
    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'PerAmtT' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ":39A:" + lcamendh.value1 skip.

    /*
    find first lcamendh where lcamendh.lc = s-lc and  lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'PlcChar' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ':44A:' + caps(lcamendh.value1) skip.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'PlcFin' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ':44B:' + caps(lcamendh.value1) skip.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'LdtShip' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted ':44C:' + datestr(lcamendh.value1) skip.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ShipPer' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ':44D:'.
        k = length(lcamendh.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lcamendh.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.*/


    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'Narrat' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ':79:'.
        k = length(lcamendh.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lcamendh.value1,i,50))) SKIP.
            k = k - 50.
            if k <= 0 then leave.
            i = i + 50.
        end.
    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'StoRInf' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        put stream out unformatted ':72:'.
        k = length(lcamendh.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lcamendh.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    put stream out unformatted "-}" skip.
    output stream out close.

    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " Administrator@192.168.222.226:C:/swift/in/;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message skip " Произошла ошибка при копировании файла" s-value1 skip(1) v-result view-as alert-box buttons ok title " ОШИБКА ! ".
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mt707;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then  message v-result + " Ошибка копирования в архив" view-as alert-box.


    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).

end.


