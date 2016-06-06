/* rnnload.p
 * MODULE
        Загрузка обновлений базы РНН
 * DESCRIPTION
        для загрузки необходимо положить файлы в C:\rnnload\
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        27.04.09 marinav
 * CHANGES
        23.01.10 marinav - изменен формат файлов
        24.06.2010 marinav - вторым полем теперь приходит БИН ИИН , пока никуда его не загружаем - нет поля в таблице rnn
        19.08.10  marinav - запись ИИН БИН
        12.09.2012 evseev - иин/бин
        13.09.2012 evseev - ТЗ-625
        14.09.2012 evseev - ТЗ-1512
        21.02.2013 evseev - tz-1629
        06.06.2013 k.gitalov изменен вызов binload
        04.07.2013 evseev - tz-1544

for each rnn .
  rnn.datdoki = ?.
  rnn.info[1] = ''.
  rnn.info[2] = ''.
  rnn.info[3] = ''.
  rnn.info[4] = ''.
  rnn.info[5] = ''.
end.
for each rnnu.
 rnnu.activity = ''.
 rnnu.datdoki = ?.
 rnnu.info[1] = ''.
 rnnu.info[2] = ''.
 rnnu.info[3] = ''.
end.

*/

{lgps.i}
{global.i}

define variable filelog     as character init "rnnload".

define variable t-file      as character format "x(100)" no-undo.

define variable t-rnn       as character no-undo.
define variable t-bin       as character no-undo.
define variable t-pr        as character no-undo.
define variable t-res       as character no-undo.
define variable t-ip        as character no-undo.
define variable t-name      as character no-undo.
define variable t-dtud      as character no-undo.
define variable t-ud        as character no-undo.
define variable t-adv       as character no-undo.
define variable t-act       as character no-undo.
define variable t-nk        as character no-undo.
define variable t-nkname    as character no-undo.
define variable t-f14       as character no-undo.
define variable v-file      as character init "inis_RegData_".


define variable i           as decimal   format ">>>,>>>,>>>,>>9.99".
define variable v-linecount as integer.
define variable v-timestr   as character.
define variable v-curproc   as integer.
define variable v-tm        as integer.


input through value ("sgnget tmprnn Administrator@`askhost`:c:/rnnload/" + v-file + "; echo $?").

do i = 1 to 5000000.
end.


define variable v-exist1  as character no-undo.
define variable v-binload as character.
v-binload = "/data/import/binload/" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
input through value( "find " + v-binload + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then
do:
    unix silent value ("mkdir " + v-binload).
    unix silent value("chmod 777 " + v-binload).
end.


{comm-dir.i}
run comm-dir ("tmprnn/", "*", no).




for each comm-dir:
    i = 0.
    v-linecount = 0.
    input through value( "wc " + trim("tmprnn/" + comm-dir.fname) ).
    repeat:
        import unformatted v-exist1.
    end.
    v-exist1 = trim(entry(1,trim(v-exist1)," ")) no-error.
    v-linecount = integer(v-exist1) no-error.
    if error-status:error then v-linecount = 0.

    message "Загрузка файла " comm-dir.fname " записей " v-linecount view-as alert-box.

    input from value("tmprnn/" + trim(comm-dir.fname) ).
    REPEAT on error undo, leave:
        do transaction:
            if i = 0 then v-tm = time.
            import unformatted t-file no-error.
            IF ERROR-STATUS:ERROR then
            do:
                message "Ошибка импорта RNN" view-as alert-box.
                return.
            END.
            t-rnn = entry(1,t-file,"|").
            t-bin = entry(2,t-file,"|").
            t-pr  = entry(3,t-file,"|").
            t-res = entry(4,t-file,"|").
            t-ip  = entry(10,t-file,"|").
            if t-ip = "1" then t-ip = "0".
            else if t-ip = "32" then t-ip = "1".
            if t-pr = '0' then  t-name = trim(entry(7,t-file,"|")).
            else  t-name = trim(entry(6,t-file,"|")).
            t-dtud = entry(8,t-file,"|").
            t-ud  = entry(9,t-file,"|").
            t-adv = entry(10,t-file,"|").
            if t-adv = "1" then t-adv = "0".
            else if t-adv = "32" then t-adv = "0".
                else if t-adv = "128" then t-adv = "1".
                    else if t-adv = "64" then t-adv = "2".
                        else if t-adv = "256" then t-adv = "4".
            t-act = entry(11,t-file,"|").
            t-nk  = entry(12,t-file,"|").
            t-nkname  = entry(13,t-file,"|").
            t-f14 = "".
            t-f14  = entry(14,t-file,"|") no-error.

            i = i + 1.


            if  i modulo 100 = 0 and v-linecount <> 0 then
            do:
                v-curproc = i / (v-linecount / 100).
                if v-curproc > 0 then
                do:
                    v-timestr = " оставшееся время: " +  string( integer(((time - v-tm) / v-curproc ) * (100 - v-curproc)) ,"HH:MM:SS").
                end.
            end.

            hide message no-pause.
            message "Идет загрузка: " trim(comm-dir.fname) i " из " string(v-linecount) + v-timestr.


            if not(trim(t-f14) = "3" or trim(t-dtud) <> "") then
            do:
                if t-pr = '0' then
                do:  /*физ*/
                    find first rnnu where rnnu.trn = t-rnn  exclusive-lock no-error.
                    if available rnnu then delete rnnu.

                    find first rnn where rnn.trn = t-rnn no-error .
                    if not available rnn then
                    do:
                        create rnn.
                        rnn.trn = t-rnn.
                    end.

                    rnn.lname = "".
                    rnn.fname = "".
                    rnn.mname = "".
                    if num-entries(t-name," ") >= 1 then rnn.lname = entry(1,t-name," ") .
                    if num-entries(t-name," ") >= 2 then rnn.fname = entry(2,t-name," ") .
                    if num-entries(t-name," ") >= 3 then rnn.mname = entry(3,t-name," ") .
                    assign
                        rnn.info[1] = t-res
                        rnn.info[2] = t-ip
                        rnn.info[3] = t-ud
                        rnn.info[4] = t-adv
                        rnn.info[5] = t-act
                        rnn.raj1    = t-nk
                        rnn.raj2    = t-nkname
                        rnn.bin     = t-bin.
                    if trim(t-dtud) ne '' then rnn.datdoki = date(substr(t-dtud,9,2) + '.' + substr(t-dtud,6,2) + '.' + substr(t-dtud,1,4)) no-error.
                    find current rnn no-lock.
                end.
                else
                do:
                    find first rnn where rnn.trn = t-rnn  exclusive-lock no-error.
                    if available rnn then delete rnn.

                    find first rnnu where rnnu.trn = t-rnn no-error .
                    if not available rnnu then
                    do:
                        create rnnu.
                        rnnu.trn = t-rnn.
                    end.

                    assign
                        rnnu.busname  = t-name
                        rnnu.info[1]  = t-res
                        rnnu.info[2]  = t-ip
                        rnnu.info[3]  = t-ud
                        rnnu.activity = t-act
                        rnnu.raj1     = t-nk
                        rnnu.raj2     = t-nkname
                        rnnu.bin      = t-bin.
                    if trim(t-dtud) ne '' then rnnu.datdoki = date(substr(t-dtud,9,2) + '.' + substr(t-dtud,6,2) + '.' + substr(t-dtud,1,4)) no-error.
                    find current rnnu no-lock.
                end.
            end.
            else
            do:
                run savelog(filelog, "Удален из базы - " + trim(comm-dir.fname) + " , запись рнн = " + t-rnn).
                find first rnnu where rnnu.trn = t-rnn  exclusive-lock no-error.
                if available rnnu then delete rnnu.
                find first rnn where rnn.trn = t-rnn  exclusive-lock no-error.
                if available rnn then delete rnn.
            end.

            run binload2(i,comm-dir.fname,t-file).

        end. /*Transaction*/
    END.
    input close.

    unix silent value('cp tmprnn/' + trim(comm-dir.fname) + ' ' + v-binload).

    do transaction:
        create histloadfile.
        assign
            histloadfile.module = "bin"
            histloadfile.regdt  = today
            histloadfile.tm     = time
            histloadfile.ofc    = g-ofc
            histloadfile.fname  = comm-dir.fname.
    end.
    run savelog(filelog, "Загружен - " + trim(comm-dir.fname) + " , записей - " + string(i,">>>>>>>>9")).
end.

hide message no-pause.
message "Загрузка обновлений завершена! ~n Прошедшее время: " + string(time - v-tm,"HH:MM:SS") view-as alert-box.

run bin_error.

