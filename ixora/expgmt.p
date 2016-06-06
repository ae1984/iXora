/* expgmt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT730
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
        31/01/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        11/02/2011 evseev - добавил для exlc
        21/02/2011 id00810 - поменяла формат сообщения для EXPG на МТ768 и реквизит Sender на InsTo730
        23/02/2011 id00810 - MT710 для exlc
        23/05/2011 id00810 - для EXSBLC
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        14/09/2011 id00810 - изменились значения реквизита AdvBy
        17/01/2011 id00810 - уточнение реквизита (поле 21) для exlc/exsblc
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
        22.10.2012 Lyubov - ТЗ 1350, добавила пола для Advise Guarantee
*/
{global.i}
def shared var s-lc     like LC.LC.
def shared var s-lcprod as char.

def var s-value1 as char no-undo.
def var v-file0  as char no-undo init 'MT730'.
def var v-result as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var field21  as char no-undo.
def var v-format as char no-undo.
def var v-swt    as char no-undo.
def stream out.
def temp-table wrk no-undo
  field id        as int
  field nom-f     as char
  field name-f    as char
  field datacode1 as char
  field datacode2 as char
  index idx is primary id.

{cr-swthead.i}
message s-lcprod view-as alert-box.
if lookup(s-lcprod,'expg,GTEADV') > 0 then assign v-format = '768' field21 = 'TRNum'.
else if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then assign v-format = '730' field21 = 'ReceRef'.

s-value1 = replace(s-lc,"/", "_").
v-swt = get-path('swtpath').

output stream out to value(v-file0).

if s-lcprod = 'GTEADV' then find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
else find first lch where lch.lc = s-lc and lch.kritcode = 'InsTo730' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted cr-swthead (v-format,trim(lch.value1)).
put stream out unformatted '\{4:' skip.

put stream out unformatted ':20:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'BankRef' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

put stream out unformatted ':21:'.
find first lch where lch.lc = s-lc and lch.kritcode = field21 no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

find first lch where lch.lc = s-lc and lch.kritcode = 'AccIdent' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ':25:'.
    put stream out unformatted caps(lch.value1) skip.
end.

put stream out unformatted ':30:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted datestr(lch.value1) skip.

find first lch where lch.lc = s-lc and lch.kritcode = 'AmtChaC' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then
find first crc where crc.crc = int(lch.value1) no-lock no-error.
find first lch where lch.lc = s-lc and lch.kritcode = 'AmtChaA' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ':32a:'.
    put stream out unformatted crc.code + lch.value1 skip.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'AccBnk' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ':57a:'.
    put stream out unformatted lch.value1 skip.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'DetCharg' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ":71B:".
    k = length(lch.value1).
    i = 1.
    repeat:
        put stream out unformatted caps(trim(substr(lch.value1,i,35))) SKIP.
        k = k - 35.
        if k <= 0 then leave.
        i = i + 35.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'StoRI730' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ":72:".
    k = length(lch.value1).
    i = 1.
    repeat:

        put stream out unformatted caps(trim(substr(lch.value1,i,35))) SKIP.
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
     message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance" skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
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

unix silent rm -f value (v-file0).
unix silent rm -f value (s-value1).

/* MT710 для EXLC */
if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
    if not avail lch or lch.value1 ne '700' then leave.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Advby' no-lock no-error.
    if not avail lch or lch.value1 ne '710' then leave.

    for each codfr where codfr.codfr   = 'MT710' no-lock.
            create wrk.
            assign wrk.id        = int(codfr.name[2])
                   wrk.nom-f     = codfr.code
                   wrk.name-f    = codfr.name[1]
                   wrk.datacode1 = codfr.name[3]
                   wrk.datacode2 = codfr.name[4] no-error.
    end.

    v-file0 = 'MT710'.
    output stream out to value(v-file0).

    find first lch where lch.lc = s-lc and lch.kritcode = 'InsTo710' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then put stream out unformatted cr-swthead ('710',trim(lch.value1)).
    put stream out unformatted '\{4:' skip.
    for each wrk no-lock:
        if wrk.datacode1 eq '' then next.
        find first lch where lch.lc = s-lc and lch.kritcode = wrk.datacode1 no-lock no-error.
        if avail lch and lch.value1 <> '' then do:
            put stream out unformatted wrk.nom-f ':'.
            if lch.kritcode ne 'lcCrc' then do:
                find first lckrit where lckrit.datacode = lch.kritcode no-lock no-error.
                if avail lckrit and lckrit.datatype = 'd' then put stream out unformatted datestr(lch.value1).
                else do:
                    if lch.kritcode = 'stoRI710' then do:
                        k = length(lch.value1).
                        i = 1.
                        repeat:
                            put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                            k = k - 35.
                            if k <= 0 then leave.
                            i = i + 35.
                        end.
                    end.
                    else do i = 1 to num-entries(lch.value1,chr(1)):
                            put stream out unformatted entry(i,lch.value1,chr(1)) skip.
                    end.
                end.
            end.
            else do:
              find first crc where crc.crc = int(lch.value1) no-lock no-error.
              if avail crc then put stream out unformatted crc.code.
            end.
            if  wrk.datacode2 ne '' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = wrk.datacode2 no-lock no-error.
                if avail lch and lch.value1 <> '' then do:
                    if lch.kritcode = 'by' then put stream out unformatted skip.
                    put stream out unformatted lch.value1.
                end.
            end.
            put stream out unformatted skip.
        end.
    end.
    put stream out unformatted "-}" skip.
    output stream out close.

    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " Administrator@192.168.222.226:/swift/in/;echo $?").
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
    message skip "Произошла ошибка при копировании файла " s-value1 " в архив /data/export/mt700." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
end.
