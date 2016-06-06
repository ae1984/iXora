/* i799mt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT799
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
        08/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        05.03.2012 Lyubov  - добавила другие форматы сообщений
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
        18.10.2012 Lyubov -  ТЗ 1350, для авизования гарантии в 3й банк в МТ799 берутся другие поля
*/

{global.i}
def shared var s-lc    like LC.LC.
def shared var s-lccor like lcswt.lccor.
def shared var s-mt as inte.

def var s-value1 as char no-undo.
def var v-file0  as char no-undo.
def var v-result as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var v-swt    as char no-undo.
def var v-fcor   as logi no-undo.
def stream out.

def var v-str as char.
v-str = 'O' + string(s-mt) + '-'.

v-file0 = 'MT' + string(s-mt).
{cr-swthead.i}
v-swt = get-path('swtpath').

find first lc where lc.lc = s-lc no-lock no-error.
if avail lc and lc.lc begins 'GTEADV' and lc.lctype = 'E' then v-fcor = true.

    if not v-fcor then do:
        find first lch where lch.lc = s-lc and  LCh.value4 = v-str + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then s-value1 = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').
    end.
    else do:
        find first lch where lch.lc = s-lc and lch.kritcode = "BankRef" and lch.value1 <> '' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then s-value1 = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').
    end.

    output stream out to value(v-file0).

    find first lch where lch.lc = s-lc and (v-fcor or (not v-fcor and LCh.value4 = v-str + string(s-lccor,'999999'))) and lch.kritcode = 'AdvBank' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
        if s-mt = 799 then put stream out unformatted  cr-swthead ('799',trim(lch.value1)).
        if s-mt = 999 then put stream out unformatted  cr-swthead ('999',trim(lch.value1)).
        if s-mt = 499 then put stream out unformatted  cr-swthead ('499',trim(lch.value1)).
    end.
    put stream out unformatted '\{4:' skip.
    put stream out unformatted ':20:'.
    if not v-fcor then do:
        find first lch where lch.lc = s-lc and  LCh.value4 = v-str + string(s-lccor,'999999') and lch.kritcode = "TRNum" no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.
    end.
    else do:
        find first lch where lch.lc = s-lc and lch.kritcode = "BankRef" no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.
    end.

    put stream out unformatted ':21:'.
    if not v-fcor then do:
        find first lch where lch.lc = s-lc and  LCh.value4 = v-str + string(s-lccor,'999999') and lch.kritcode = "RREF" no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.
    end.
    else do:
        find first lch where lch.lc = s-lc and lch.kritcode = "TRNum" no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then put stream out unformatted caps(lch.value1) skip.
    end.

    put stream out unformatted ':79:'.
    find first lch where lch.lc = s-lc and (v-fcor or (not v-fcor and LCh.value4 = v-str + string(s-lccor,'999999'))) and lch.kritcode = 'Narrat' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then do:
       k = length(lch.value1).
       i = 1.
       repeat:
         put stream out unformatted caps(trim(substr(lch.value1,i,50))) SKIP.
         k = k - 50.
         if k <= 0 then leave.
         i = i + 50.
       end.
     end.

    put stream out unformatted "-}".
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
