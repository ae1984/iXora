/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
       27/02/2009 alex
 * BASES
        BANK COMM
 * CHANGES
        04/03/2009 madiyar - подправил ширину фрейма, иначе прога не добавлялась в библиотеку
        05/03/2009 madiyar - оказывается, был еще один широкий фрейм, поправил
        10.06.2009 galina - убрала оба фрейма,
                            убрала формирование ответного сообщения
        11.06.2009 galina - не выводим на экран список файлов
        11.06.2009 galina - принимаем файлы с видом операции 09 или 07
        22.06.2009 galina - сохраняем последовательность В (разбавка по сотрудникам) в inc100.reschar[1]
        26.06.2009 galine - исправила копирование файлов в архив
                            не сохраняем поле в 21 последовательности, если оно встречается 1 раз
        30/07/2010 galina - берем 20 знаков из поля 59 (счет получателя)
        02/06/2011 evseev - переход на ИИН/БИН
        11/10/2011 evseev - правка из-за изменение формата 102
*/

{global.i}

def var v-str as char no-undo.
def var file_list as char no-undo.

def var i as integer no-undo.

def var v-files0 as char no-undo.
def var v-files as char no-undo.
def stream rstr.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.


def var v-jss like inc100.jss.
def var v-iik like inc100.iik.

def new shared var v-txb as char.
def var v-strb as char no-undo.
def var v-dtz      like inc100.dtz format "99/99/9999" no-undo.
def var v-crc      like inc100.crc no-undo.
def var v-sum      like inc100.sum no-undo.
def var v-name     like inc100.name no-undo.
def var v-irsseco  like inc100.irsseco no-undo.
def var v-mfo      like inc100.mfo no-undo.
def var v-vo       like inc100.vo format "99" no-undo.
def var v-knp      like inc100.knp no-undo.
def var v-kbk      like inc100.kbk no-undo.
def var v-prn      like inc100.prn no-undo.
def var v-mnu      like inc100.mnu no-undo.
def var v-ref      like inc100.ref no-undo.
def var v-num      like inc100.num no-undo.
def var v-dt       like inc100.dt no-undo.
def var v-filename like inc100.filename no-undo.
def var v-bnf      like inc100.bnf no-undo.
def var v-dpname   like inc100.dpname no-undo.
def var v-rg       as char no-undo.
def var v-wps       as char no-undo.
def var v-txt       like t-s400.str no-undo.
def var v-tsnum     as int no-undo.
def var v-a32       as char no-undo.
def var v-clbin       like inc100.bin.
def var v-nkbin     like inc100.nkbin no-undo.

/*def var v-sumans    as dec no-undo.
def var v-kol       as int no-undo.
def var v-kref      as char no-undo.
def var v-text      as char no-undo.
def var v-file      as char no-undo.*/
def var v-bankbik   as char no-undo.
def var v-bicben   as char no-undo.
def var p as integer no-undo.

def stream r-in.
def stream mt400.

def var v-mt100in as char no-undo.
def var v-mt100out as char no-undo.
def var v-exist1 as char no-undo.
def var v-ststime as char no-undo.
def var v-tempstr as char.
def var v-position as integer no-undo.

{chbin.i}

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

if (time ge 64800) or (g-today <> today) then v-ststime = "wait". else v-ststime = "accept".

input through value( "find /tmp/inc100in/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/inc100in/").
    unix silent value("chmod 777 /tmp/inc100in/").
end.
else unix silent value ("rm -f /tmp/inc100in/*.*").


v-files0 = ''.


input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -lis ":70:/OPV/" ' + replace(v-term,'/','\\\\') + 'Out\\\\*.102').

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:

        v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
        if v-files0 <> "" then v-files0 = v-files0 + "|".
        v-files0 = v-files0 + v-str.
    end.
end.

v-files = ''.
do i = 1 to num-entries(v-files0,"|"):
    find first inc100 where inc100.rdt = g-today and inc100.filename = entry(i, v-files0, "|") no-lock no-error.
    if not avail inc100 then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i,v-files0,"|").
    end.
end.


if v-files = '' then return.

v-mt100in = "/data/import/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-mt100in + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100in).
    unix silent value("chmod 777 " + v-mt100in).
end.

/*v-mt100out = "/data/export/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-mt100out + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100out).
    unix silent value("chmod 777 " + v-mt100out).
end.*/

do i = 1 to num-entries(v-files, "|"):
    v-str = ''.

    input through value('scp -q Administrator@db01:' + replace(v-term,'/','\\\\\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/inc100in/' + entry(i, v-files, "|") + ' ;echo $?').

    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "inkps", "INKM_ps: Ошибка копирования файлов mt100 из терминала!").
        return.
    end.
end.
unix silent value('cp /tmp/inc100in/*.102 ' + v-mt100in).

v-str = "".


do i = 1 to num-entries(v-files, "|"):
    do transaction:
        v-filename = entry(i, v-files, "|").

        unix silent value('echo "" >> /tmp/inc100in/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
        unix silent value("/pragma/bin9/dos-un /tmp/inc100in/" + v-filename + " /tmp/inc100in/r" + v-filename).
        unix silent value("rm -f /tmp/inc100in/" + v-filename).
        unix silent value("mv /tmp/inc100in/r" + v-filename + " /tmp/inc100in/" + v-filename).

        empty temp-table t-s400.

        v-tsnum = 0.
        v-str = "".

        input stream r-in from value("/tmp/inc100in/" + v-filename).

        repeat:
            import stream r-in unformatted v-txt.
            if v-txt ne "" then do:
                create t-s400.
                assign t-s400.num = v-tsnum
                    t-s400.str = v-txt.
            end.
            v-tsnum = v-tsnum + 1.
        end.

        input stream r-in close.

        find first t-s400 where t-s400.str begins "/VO/" no-lock no-error.
        if not avail t-s400 then next.
        else v-vo = entry(3, t-s400.str, "/").
        if v-vo eq "07" or v-vo eq "09" then v-mnu = v-ststime.
        else next.

        find first t-s400 where t-s400.str begins ":20:" no-lock no-error.
        if avail t-s400 then v-ref = entry(3, t-s400.str, ":").

        find first t-s400 where t-s400.str begins ":32A:" no-lock no-error.
        if avail t-s400 then v-a32 = entry(3, t-s400.str, ":").

        v-dtz = date(substr(v-a32, 5, 2) + substr(v-a32, 3, 2) + substr(v-a32, 1, 2)).
        v-crc = substr(v-a32, 7, 3).
        v-a32 = replace(v-a32, ",", ".").
        v-sum = dec(substr(v-a32, 10)).

        find first t-s400 where t-s400.str begins "/NAME/" no-lock no-error.
        if avail t-s400 then v-name = entry(3, t-s400.str, "/").

        if v-bin then do:
           v-jss = ''.
           find first t-s400 where t-s400.str begins "/IDN/" no-lock no-error.
           if avail t-s400 then do:
               v-clbin = entry(3, t-s400.str, "/").
               v-tempstr = t-s400.str.
           end.
        end.
        else do:
           v-clbin = ''.
           find first t-s400 where t-s400.str begins "/RNN/" no-lock no-error.
           if avail t-s400 then v-jss = entry(3, t-s400.str, "/").
        end.

        if v-bin then do:
           v-dpname = ''.
           find first t-s400 where t-s400.str <> v-tempstr and t-s400.str begins "/IDN/" no-lock no-error.
           if avail t-s400 then v-nkbin = entry(3, t-s400.str, "/").
        end.
        else do:
           v-nkbin = ''.
           find last t-s400 where t-s400.str begins "/RNN/" no-lock no-error.
           if avail t-s400 then v-dpname = entry(3, t-s400.str, "/").
        end.

        find last t-s400 where t-s400.str begins "/NAME/" no-lock no-error.
        if avail t-s400 then v-bnf = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/IRS/" no-lock no-error.
        if avail t-s400 then v-irsseco = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/SECO/" no-lock no-error.
        if avail t-s400 then v-irsseco = v-irsseco + entry(3, t-s400.str, "/").

        /*find first t-s400 where t-s400.str begins ":52B:" no-lock no-error.
        if avail t-s400 then v-mfo = entry(3, t-s400.str, ":").
        find first txb where txb.mfo eq v-mfo no-lock no-error.
        if avail txb then v-txb = txb.bank.
        else run savelog( "inkps", "ink100in: error filename=" + v-filename + " - не найдена запись txb по БИК филиала!").*/


        find first t-s400 where t-s400.str begins ":50:/D/" no-lock no-error.
        if avail t-s400 then do:
            if length(entry(3, t-s400.str, "/")) > 20 then v-iik = substring(entry(3, t-s400.str, "/"), 1, 20).
            else v-iik = entry(3, t-s400.str, "/").
            v-txb = 'TXB' + substr(v-iik,19,2).
        end.

        find first t-s400 where t-s400.str begins ":59:" no-lock no-error.
        if avail t-s400 then do:
            if length(entry(3, t-s400.str, ":")) > 20 then v-wps = substring(entry(3, t-s400.str, ":"), 1, 20).
            else v-wps = entry(3, t-s400.str, ":").
        end.

        find first t-s400 where t-s400.str begins ":57B:" no-lock no-error.
        if avail t-s400 then v-bicben = entry(3, t-s400.str, ":").


        find first t-s400 where t-s400.str begins ":70:" no-lock no-error.
        if avail t-s400 then v-num = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/DATE/" no-lock no-error.
        if avail t-s400 then v-dt = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/VO/" no-lock no-error.
        if avail t-s400 then v-vo = entry(3, t-s400.str, "/").
        if v-vo eq "07" or v-vo eq "09" then v-mnu = v-ststime.
        else v-mnu = "err".

        find first t-s400 where t-s400.str begins "/KNP/" no-lock no-error.
        if avail t-s400 then v-knp = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/PERIOD/" no-lock no-error.
        if avail t-s400 then v-kbk = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/PRT/" no-lock no-error.
        if avail t-s400 then v-prn = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/ASSIGN/" no-lock no-error.
        if avail t-s400 then v-rg = entry(2, t-s400.str, ".").

        p = 0.
        for each t-s400 where t-s400.str begins "/PERIOD/" no-lock:
          p = p + 1.
        end.

        v-strb = ''.
        if v-bin then do:
            find first t-s400 where t-s400.str begins "/ASSIGN/" no-lock no-error.
            if avail t-s400 then v-position = t-s400.num.

            for each t-s400 where t-s400.str begins ":21:" or t-s400.str begins ":32B:" or t-s400.str begins ":70:/OPV/" or t-s400.str begins "/FM" or
                                  t-s400.str begins "/NM" or t-s400.str begins "/FT" or t-s400.str begins "/DT" or t-s400.str begins "/RNN" or
                                  t-s400.str begins "/IDN"  or (t-s400.str begins "/PERIOD/" and p > 1 ) no-lock:
              if t-s400.num < v-position then next.
              if v-strb <> '' then v-strb = v-strb + '^'.
              v-strb = v-strb + t-s400.str.
            end.
        end. else do:
            for each t-s400 where t-s400.str begins ":21:" or t-s400.str begins ":32B:" or t-s400.str begins ":70:/OPV/" or t-s400.str begins "//FM" or t-s400.str begins "//NM" or t-s400.str begins "//FT" or t-s400.str begins "//DT" or t-s400.str begins "//RNN" or t-s400.str begins "//IDN"  or (t-s400.str begins "/PERIOD/" and p > 1 ) no-lock:
              if v-strb <> '' then v-strb = v-strb + '^'.
              v-strb = v-strb + t-s400.str.
            end.
        end.
    end. /* transaction */

    do transaction:

        find first inc100 where inc100.ref eq v-ref no-lock no-error.
        if not avail inc100 then do:

            create inc100.
            assign inc100.ref = v-ref
                inc100.jss = v-jss
                inc100.name = v-name
                inc100.irsseco = v-irsseco
                inc100.mfo = v-mfo
                inc100.iik = v-iik
                inc100.num = v-num
                inc100.dt = v-dt
                inc100.vo = v-vo
                inc100.knp = v-knp
                inc100.kbk = v-kbk
                inc100.prn = v-prn
                inc100.filename = v-filename
                inc100.dtz = v-dtz
                inc100.crc = v-crc
                inc100.sum = v-sum
                inc100.mnu = v-mnu
                inc100.rdt = g-today
                inc100.rtm = time
                inc100.bank = v-txb
                inc100.dpname = v-dpname
                inc100.bnf = v-bnf
                inc100.rgref = v-rg
                inc100.reschar[2] = v-wps
                inc100.reschar[3] = v-bicben
                inc100.reschar[1] = v-strb
                inc100.bin = v-clbin
                inc100.nkbin = v-nkbin.

        end.
        else do:
            next.
        end.
    end.

end.

unix silent value ("rm -f /tmp/inc100in/*.*").
