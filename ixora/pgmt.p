/* pgmt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT760
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
        26/01/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
*/

{global.i}
def shared var s-lc like LC.LC.

def var s-value1 as char no-undo.
def var v-file0  as char no-undo init  'MT760'.
def var v-result as char no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-amt    as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var v-swt    as char no-undo.
def stream out.

{cr-swthead.i}

v-swt = get-path('swtpath').

find first lch where lch.lc = s-lc and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then s-value1 = replace(lch.value1,"/", "_").

output stream out to value(v-file0).

find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted cr-swthead ('760',trim(lch.value1)).

put stream out unformatted '\{4:' skip.
put stream out unformatted ':27:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'SeqTot' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

put stream out unformatted ':20:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.

put stream out unformatted ':23:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'FurId' no-lock no-error.
if avail lch then do:
   find first codfr where codfr.codfr = 'pgfurid' and codfr.code = lch.value1 no-lock no-error.
   if avail codfr then put stream out unformatted caps(codfr.name[1]) skip.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
   put stream out unformatted ':30:'.
   put stream out unformatted datestr(lch.value1) skip.
end.

put stream out unformatted ':40C:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'AppRule' no-lock no-error.
if avail lch then put stream out unformatted lch.value1 skip.


put stream out unformatted ':77C:'.
find first lch where lch.lc = s-lc and lch.kritcode = 'DetGar' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then do:
   k = length(lch.value1).
   i = 1.
   repeat:
     put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
     k = k - 65.
     if k <= 0 then leave.
     i = i + 65.
   end.
 end.

 find first lch where lch.lc = s-lc and lch.kritcode = 'StoRInf' no-lock no-error.
 if avail lch and trim(lch.value1) <> '' then do:
    put stream out unformatted ':72:'.
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
message skip "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mt700." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

unix silent rm -f value (s-value1).
unix silent rm -f value (v-file0).
