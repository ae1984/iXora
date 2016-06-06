/* LCmt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT700
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
        09/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
    10/09/2010 galina - убрала лишние пробелы в конце строк
    20/09/2010 galina - поправила вывод поля 39A
    23/09/2010 galina - поменяла формат ввода поля 39:A (Percent Credit Amount Tolerance)
    07/10/2010 galina - поправила формат вывода поля 78
    25/11/2010 galina - добавила новый критерий AdvThOpt
    26/11/2010 galina - поправила копирование в swift
    30/11/2010 galina - добавила признак MT700
    09/12/2010 galina - выводи номер аккредитива заглавными буквами
    10/12/2010 galina - поправила копирование в swift
    28/12/2010 Vera   - временно закомментировала удаление s-value1
    29/12/2010 Vera   - перекомпиляция
    30/12/2010 madiyar - исправил копирование файла в Swift Alliance
    04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
    13/09/2011 id00810 - обработка ошибки копирования в SWIFT
    10/02/2012 id00810 - определение каталога swift через функцию get-path
    20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
    24/04/2012 evseev - изменения в .i
    09/09/2013 galina - ТЗ 1881 добавила вывод полей PLAD и PDAD
*/

{global.i}
def shared var s-lc like LC.LC.

def var s-value1 as char no-undo.
def var v-file0  as char no-undo init 'MT700'.
def var v-result as char no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-sel    as int  no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var v-swt    as char no-undo.
def buffer b-lch for lch.
def stream out.

{cr-swthead.i}

find first lch where lch.lc = s-lc  and lch.kritcode = 'MT700' no-lock no-error.
if avail lch and lookup(lch.value1,v-logsno) > 0 then do:
    message 'Your choice had not been to create MT700!' view-as alert-box.
    return.
end.
v-swt = get-path('swtpath').
    find first lch where lch.lc = s-lc and lch.kritcode = "CreditN" and lch.value1 <> '' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then s-value1 = replace(lch.value1,"/", "_").

    output stream out to value(v-file0).

    find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted cr-swthead ('700',trim(lch.value1)).

    put stream out unformatted '\{4:' skip.
    put stream out unformatted ':27:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'SeqTot' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

    put stream out unformatted ':40A:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'FormCred' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first lckrit where lckrit.datacode = 'FormCred' no-lock no-error.
        if avail lckrit then do:
            find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
            if avail codfr then  put stream out unformatted codfr.name[1] skip.
        end.
    end.

    put stream out unformatted ':20:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'CreditN' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted ':31C:'
                                                  datestr(lch.value1) skip.

    put stream out unformatted ':40E:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'AppRule' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        k = length(lch.value1).
        repeat:
            i = 1.
            put stream out unformatted trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
        end.
    end.

    put stream out unformatted ':31D:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted datestr(lch.value1).

    find first lch where lch.lc = s-lc and lch.kritcode = 'PlcExp' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then  put stream out unformatted lch.value1 skip.

    put stream out unformatted ':50:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    put stream out unformatted ':59:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    put stream out unformatted ':32B:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first crc where crc.crc = int(lch.value1) no-lock no-error.
        if avail crc then put stream out unformatted crc.code.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PerAmt' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted ':39A:' + lch.value1 skip.

    put stream out unformatted ":41A:".
    find first lch where lch.lc = s-lc and lch.kritcode = 'AvlWith' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then  put stream out unformatted caps(lch.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first lckrit where lckrit.datacode = 'By' no-lock no-error.
        if avail lckrit then do:
            find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
            if avail codfr then put stream out unformatted 'BY ' + caps(codfr.name[1]) skip.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DrfAt' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':42C:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Drawee' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted ':42A:' caps(lch.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DefPayD' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':42P:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ParShip' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first lckrit where lckrit.datacode = 'ParShip' no-lock no-error.
        if avail lckrit and trim(lch.value1) <> '' then do:
            find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
            if avail codfr then do:
                put stream out unformatted ':43P:'. /*codfr.name[1] skip.*/
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted  trim(caps(substr(codfr.name[1],i,35))) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'TrnShip' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first lckrit where lckrit.datacode = 'TrnShip' no-lock no-error.
        if avail lckrit and trim(lch.value1) <> '' then do:
            find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
            if avail codfr then do:
                put stream out unformatted ':43T:'. /*codfr.name[1] skip.*/
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted  trim(caps(substr(codfr.name[1],i,35))) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.
        end.
     end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PlcCharg' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':44A:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PLAD' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':44E:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PDAD' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':44F:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PclFD' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then  do:
        put stream out unformatted ':44B:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'LDtShip' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted ':44C:' datestr(lch.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DesGood' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':45A:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DocReq' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':46A:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'AddCond' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':47A:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Charges' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':71B:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'PerPres' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':48:'. /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
            k = k - 35.
            if k <= 0 then leave.
            i = i + 35.
        end.
    end.

    put stream out unformatted ':49:'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'Confir' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        find first lckrit where lckrit.datacode = lch.kritcode no-lock no-error.
        if avail lckrit then do:
            find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
            if avail codfr then put stream out unformatted caps(codfr.name[1]) skip.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ReimBnk' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted ':53A:' caps(lch.value1) skip.

    find first lch where lch.lc = s-lc and lch.kritcode = 'InstoBnk' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ':78:'. /*lch.value1.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,65))) SKIP.
            k = k - 65.
            if k <= 0 then leave.
            i = i + 65.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'AdvThrou' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ":57".
        find first b-LCh where b-LCh.LC = s-lc and b-LCh.kritcode = 'AdvThOpt' no-lock no-error.
        if avail b-lch and trim(b-lch.value1) <> '' then put stream out unformatted caps(trim(b-lch.value1)).
        if trim(b-lch.value1) = 'D' then do:
            put stream out unformatted ':'.
            k = length(lch.value1).
            i = 1.
            repeat:
                put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                k = k - 35.
                if k <= 0 then leave.
                i = i + 35.
            end.
         end.
         else put stream out unformatted ':' lch.value1 skip.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'StoRInf' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        put stream out unformatted ":72:". /*lch.value1 skip.*/
        k = length(lch.value1).
        i = 1.
        repeat:
            put stream out unformatted  trim(caps(substr(lch.value1,i,35))) SKIP.
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
    input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " " + v-swt + ";echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
        unix silent rm -f value (s-value1).
        unix silent rm -f value (v-file0).
        return error.
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mt700;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then
    message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mt700." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
