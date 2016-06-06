/* ink100in.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        27/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        02/12/2008 alex - убрал перикодировку DOS
        25/12/2008 alex - добавил проверку валюты счета (поле :59:)
        04.04.2009 galina - исправила определение валюта счета
        10.06.2009 galina - проставляем статус ошибки для ОПВ и СО платежей, т.к. они загружуются в 102in
        22/10/2009 galina - добавила запись времени и даты прихода файла
        02/06/2011 evseev - переход на ИИН/БИН
*/

def var v-files0    as char no-undo.
def var v-files     as char no-undo.
def var i           as integer no-undo.
def var v-str       as char no-undo.
def var v-dtz       like inc100.dtz format "99/99/9999" no-undo.
def var v-crc       like inc100.crc no-undo.
def var v-sum       like inc100.sum no-undo.
def var v-name      like inc100.name no-undo.
def var v-irsseco   like inc100.irsseco no-undo.
def var v-mfo       like inc100.mfo no-undo.
def var v-vo        like inc100.vo format "99" no-undo.
def var v-knp       like inc100.knp no-undo.
def var v-kbk       like inc100.kbk no-undo.
def var v-prn       like inc100.prn no-undo.
def var v-ans       as int format "9999999999999" no-undo.
def var v-mnu       like inc100.mnu no-undo.
def var v-ref       like inc100.ref no-undo.
def var v-num       like inc100.num no-undo.
def var v-dt        like inc100.dt no-undo.
def var v-filename  like inc100.filename no-undo.
def var v-bnf       like inc100.bnf no-undo.
def var v-dpname    like inc100.dpname no-undo.
def var v-rg        as char no-undo.
def var v-bank      as char no-undo.
def var v-jss       like inc100.jss.
def var v-iik       like inc100.iik.
def var v-clbin       like inc100.bin.
def var v-nkbin       like inc100.nkbin.
def var v-iikcrc    as char no-undo.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

def var v-txt       like t-s400.str no-undo.
def var v-tsnum     as int no-undo.
def var v-a32       as char no-undo.

def var v-mt100in   as char no-undo.
def var v-exist1    as char no-undo.
def var v-ststime   as char.
def var v-fcreinfo as char.

def stream r-in.

{global.i}
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
/*input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis "\{2:.\{14\}KNALOG" c:\\\\Capital\\\\Terminal\\\\Out\\\\*.100').*/
input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis "\{2:.\{14\}KNALOG" ' + replace(v-term,'/','\\\\') + 'Out\\\\*.100').
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
    find first inc100 where inc100.rdt = g-today and inc100.filename = entry(i,v-files0,"|") no-lock no-error.
    if not avail inc100 then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i,v-files0,"|").
    end.
end.

/*
displ v-files format "x(100)".
pause.
*/

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

do i = 1 to num-entries(v-files, "|"):
    v-str = ''.
    /*input through value('scp -pq Administrator@db01:C:\\\\CAPITAL\\\\terminal\\\\OUT\\\\' + entry(i, v-files, "|") + ' /tmp/inc100in/' + entry(i, v-files, "|") + ' ;echo $?').*/
    input through value('scp -pq Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/inc100in/' + entry(i, v-files, "|") + ' ;echo $?').
    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "inkps", "ink100in: Ошибка копирования файлов mt100 из терминала!").
        return.
    end.
end.
unix silent value('cp /tmp/inc100in/*.100 ' + v-mt100in).

do i = 1 to num-entries(v-files, "|"):
    do transaction:
        v-filename = entry(i, v-files, "|").

        v-fcreinfo = ''.
        FILE-INFO:FILE-NAME = "/tmp/inc100in/" + v-filename.
        v-fcreinfo = string(FILE-INFO:FILE-MOD-DATE, "99/99/9999").
        if v-fcreinfo <> '' then v-fcreinfo = v-fcreinfo + ','.
        v-fcreinfo = v-fcreinfo + string(FILE-INFO:FILE-MOD-TIME, "HH:MM:SS").

        unix silent value('echo "" >> /tmp/inc100in/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
/*
        unix silent value("/pragma/bin9/dos-un /tmp/inc100in/" + v-filename + " /tmp/inc100in/r" + v-filename).
        unix silent value("rm -f /tmp/inc100in/" + v-filename).
        unix silent value("mv /tmp/inc100in/r" + v-filename + " /tmp/inc100in/" + v-filename).
  */
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


/*        find first t-s400 where t-s400.str begins ":57B:" no-lock no-error.
        if avail t-s400 then v-bank = entry(3, t-s400.str, ":").
        find first txb where txb.mfo eq v-bank no-lock no-error.
        if avail txb then v-bank = txb.bank.
        else run savelog( "inkps", "ink100in: error filename=" + v-filename + " - не найдена запись txb по БИК филиала!").*/

        find first t-s400 where t-s400.str begins ":20:" no-lock no-error.
        if avail t-s400 then v-ref = entry(3, t-s400.str, ":").

        find first t-s400 where t-s400.str begins ":32A:" no-lock no-error.
        if avail t-s400 then v-a32 = entry(3, t-s400.str, ":").

        v-dtz = date(substr(v-a32, 5, 2) + substr(v-a32, 3, 2) + substr(v-a32, 1, 2)).
        v-crc = substr(v-a32, 7, 3).
        v-a32 = replace(v-a32, ",", ".").
        v-sum = dec(substr(v-a32, 10)).

        if v-bin then do:
           v-dpname = ''.
           find first t-s400 where t-s400.str begins "/IDN/" no-lock no-error.
           if avail t-s400 then v-nkbin = entry(3, t-s400.str, "/").
        end.
        else do:
           v-nkbin = ''.
           find first t-s400 where t-s400.str begins "/RNN/" no-lock no-error.
           if avail t-s400 then v-dpname = entry(3, t-s400.str, "/").
        end.

        find first t-s400 where t-s400.str begins "/NAME/" no-lock no-error.
        if avail t-s400 then v-bnf = entry(3, t-s400.str, "/").

        if v-bin then do:
           v-jss = ''.
           find last t-s400 where t-s400.str begins "/IDN/" no-lock no-error.
           if avail t-s400 then v-clbin = entry(3, t-s400.str, "/").
        end.
        else do:
           v-clbin = ''.
           find last t-s400 where t-s400.str begins "/RNN/" no-lock no-error.
           if avail t-s400 then v-jss = entry(3, t-s400.str, "/").
        end.

        find last t-s400 where t-s400.str begins "/NAME/" no-lock no-error.
        if avail t-s400 then v-name = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/IRS/" no-lock no-error.
        find next t-s400 where t-s400.str begins "/IRS/" no-lock no-error.
        if avail t-s400 then v-irsseco = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/SECO/" no-lock no-error.
        find next t-s400 where t-s400.str begins "/SECO/" no-lock no-error.
        if avail t-s400 then v-irsseco = v-irsseco + entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins ":57B:" no-lock no-error.
        if avail t-s400 then v-mfo = entry(3, t-s400.str, ":").

        find first t-s400 where t-s400.str begins ":59:" no-lock no-error.
        if avail t-s400 then do:
            v-iik = entry(3, t-s400.str, ":").
            v-iikcrc = "".
            if length(v-iik) > 20 then do:
                v-iikcrc = substring(v-iik, 21).
                v-iik = substring(v-iik, 1, 20).
            end.
            v-bank = 'TXB' + substr(v-iik,19,2).
        end.

        find first t-s400 where t-s400.str begins ":70:" no-lock no-error.
        if avail t-s400 then v-num = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/DATE/" no-lock no-error.
        if avail t-s400 then v-dt = entry(3, t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/VO/" no-lock no-error.
        if avail t-s400 then v-vo = entry(3, t-s400.str, "/").
        if v-vo eq "03" or v-vo eq "04" or v-vo eq "05" /*or v-vo eq "07" or v-vo eq "09"*/ then v-mnu = v-ststime.
                else v-mnu = "err".

        find first t-s400 where t-s400.str begins "/KNP/" no-lock no-error.
        if avail t-s400 then v-knp = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/BCLASS/" no-lock no-error.
        if avail t-s400 then v-kbk = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/PRT/" no-lock no-error.
        if avail t-s400 then v-prn = integer(entry(3, t-s400.str, "/")).

        find first t-s400 where t-s400.str begins "/ASSIGN/" no-lock no-error.
        if avail t-s400 then v-rg = entry(3, t-s400.str, "/").

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
                inc100.stat = 0
                inc100.mnu = v-mnu
                inc100.ans = v-ans
                inc100.rdt = g-today
                inc100.rtm = time
                inc100.bank = v-bank
                inc100.dpname = v-dpname
                inc100.bnf = v-bnf
                inc100.reschar[2] = v-rg
                inc100.rgref = entry(2, v-rg, ".")
                inc100.reschar[5] = v-iikcrc
                inc100.reschar[4] = v-fcreinfo
                inc100.bin = v-clbin
                inc100.nkbin = v-nkbin.
        end.
        else run savelog( "inkps", "ink100in: Запись в inc100 с референсом " + v-ref + " уже есть!").
    end.
end.