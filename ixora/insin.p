/* insin.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Загрузка РПРО
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        09/12/2009 galina - перекомпиляция
        31/12/2009 galina - в РПРО по ОПВ и СО нет причины
                            очищаю переменную со счетами v-iik

        12/01/2010 galina - убарала отладочное сообщение
        12/05/2011 evseev - добавил поле bank1 в insin хранящее перечень всех филиалов на основании iik
        19/05/2011 evseev - отправка сообщения, если зарегистрировано РПРО со счетами для разных филиалов
        01/06/2011 evseev - очистка v-bank1
        08/06/2011 evseev - переход на ИИН/БИН
        28/07/2011 evseev - исправил строку 283
*/

def var v-files0    as char no-undo.
def var v-files     as char no-undo.
def var i           as integer no-undo.
def var j           as integer no-undo.
def var v-str       as char no-undo.
def var v-name      like insin.clname no-undo.
def var v-numr as char no-undo.
def var v-dtr as date no-undo.
def var v-nkrnn like insin.nkrnn.
def var v-nkbin like insin.nkbin.
def var v-nkname as char no-undo.
def var v-mfo       like insin.mfo no-undo.
def var v-type      as char no-undo.
def var v-mnu       like insin.mnu no-undo.
def var v-ref       like insin.ref no-undo.
def var v-num       as char no-undo.
def var v-dt        like insin.dt no-undo.
def var v-filename  like insin.filename no-undo.
def var v-bank      as char no-undo.
def var v-jss       like insin.clrnn.
def var v-clbin       like insin.clbin.
def var v-iik       like insin.iik.
def var v-form      as char init "C,CP,SD".
def var v-reas as char no-undo.
def var v-fcreinfo as char no-undo.
def var v-bank1      as char no-undo.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

def var v-txt       like t-s400.str no-undo.
def var v-tsnum     as int no-undo.
def var v-a32       as char no-undo.

def var v-mt100in   as char no-undo.
def var v-exist1    as char no-undo.
/*def var v-ststime   as char.*/


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

if (time ge 64800) or (g-today <> today) then v-mnu = "wait". else v-mnu = "accept".

input through value( "find /tmp/insin/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/insin/").
    unix silent value("chmod 777 /tmp/insin/").
end.
else unix silent value ("rm -f /tmp/insin/*.*").


v-files0 = ''.

do i = 1 to num-entries(v-form):
    /* реальный сервер*/
    input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis ":77E:FORMS/A' + trim(entry(i, v-form)) + '/" ' + replace(v-term,'/','\\\\') + 'Out\\\\*.998').
    /*тестовый сервер
    input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis ":77E:FORMS/A' + trim(entry(i, v-form)) + '/" C:\\\\STAT\\\\NK\\\\IN\\\\*.998').*/

    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        if v-str <> '' then do:
            v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
            if v-files0 <> "" then v-files0 = v-files0 + "|".
            v-files0 = v-files0 + v-str.
        end.
    end.
end.

v-files = ''.
do i = 1 to num-entries(v-files0,"|"):
    find first insin where insin.rdt = g-today and insin.filename = entry(i,v-files0,"|") no-lock no-error.
    if not avail insin then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i,v-files0,"|").
    end.
end.
/*message v-files view-as alert-box.*/

if v-files = '' then return.

v-mt100in = "/data/import/insarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
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
    /* реальный сервер*/
    input through value('scp -q Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/insin/' + entry(i, v-files, "|") + ' ;echo $?').
    /*тестовый сервер
    input through value('scp -pq Administrator@db01:C:\\\\STAT\\\\NK\\\\IN\\\\' + entry(i, v-files, "|") + ' /tmp/insin/' + entry(i, v-files, "|") + ' ;echo $?').*/

    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "insps", "insin: Ошибка копирования файлов mt998 из терминала!").
        return.
    end.
end.
unix silent value('cp /tmp/insin/*.998 ' + v-mt100in).

do i = 1 to num-entries(v-files, "|"):
    v-iik = ''.
    do transaction:
        v-filename = entry(i, v-files, "|").
        v-fcreinfo = ''.
        FILE-INFO:FILE-NAME = "/tmp/insin/" + v-filename.
        v-fcreinfo = string(FILE-INFO:FILE-MOD-DATE, "99/99/9999").
        if v-fcreinfo <> '' then v-fcreinfo = v-fcreinfo + ','.
        v-fcreinfo = v-fcreinfo + string(FILE-INFO:FILE-MOD-TIME, "HH:MM:SS").


        unix silent value('echo "" >> /tmp/insin/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
        empty temp-table t-s400.

        v-tsnum = 0.
        v-str = "".

        input stream r-in from value("/tmp/insin/" + v-filename).

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


        find first t-s400 where t-s400.str begins ":20:" no-lock no-error.
        if avail t-s400 then v-ref = entry(3, t-s400.str, ":").

        find first t-s400 where t-s400.str begins ":77E:" no-lock no-error.
        if avail t-s400 then do:
          v-type = entry(2,t-s400.str, "/").
          v-dtr = date(substr(entry(3,t-s400.str, "/"),5,2) + substr(entry(3,t-s400.str, "/"),3,2) + substr(entry(3,t-s400.str, "/"),1,2)).
          v-numr = entry(4,t-s400.str, "/").
        end.
        find first t-s400 where t-s400.str begins "/BANK/" no-lock no-error.
        if avail t-s400 then v-mfo = entry(3,t-s400.str, "/").

        /*find first txb where txb.mfo eq v-mfo and txb.consolid no-lock no-error.
        if avail txb then v-bank = txb.bank.*/

        if v-bin then do:
            v-nkrnn = ''.
            find first t-s400 where t-s400.str begins "/TOIDN/" no-lock no-error.
            if avail t-s400 then v-nkbin = entry(3,t-s400.str, "/").
        end. else do:
            v-nkbin = ''.
            find first t-s400 where t-s400.str begins "/TORNN/" no-lock no-error.
            if avail t-s400 then v-nkrnn = entry(3,t-s400.str, "/").
        end.

        find first t-s400 where t-s400.str begins "/TONAME/" no-lock no-error.
        if avail t-s400 then v-nkname = entry(3,t-s400.str, "/").

        find first t-s400 where t-s400.str begins "/DTR/" no-lock no-error.
        if avail t-s400 then do:
          v-num = entry(3,t-s400.str, "/").
          v-dt = date(substr(entry(4,t-s400.str, "/"),5,2) + substr(entry(4,t-s400.str, "/"),3,2) + substr(entry(4,t-s400.str, "/"),1,2)).
          if v-type = 'AC' then v-reas = entry(5,t-s400.str, "/").
        end.

        find first t-s400 where t-s400.str begins "/PLAT/" no-lock no-error.
        if avail t-s400 then do:
          if v-bin then do:
             v-jss = ''.
             v-clbin =  entry(3,t-s400.str, "/").
          end. else do:
             v-clbin = ''.
             v-jss =  entry(3,t-s400.str, "/").
          end.
          v-name = entry(4,t-s400.str, "/").

        end.

        for each t-s400 where t-s400.str begins "/A/" no-lock:
          if v-iik <> '' then v-iik = v-iik + ','.
          v-iik = v-iik + entry(3,t-s400.str, "/").
        end.
        if num-entries(v-iik) > 0 then do:
           v-bank = 'TXB' + substr(entry(1,v-iik),19,2).
           v-bank1 = ''.
           do j = 1 to num-entries(v-iik):
             if lookup('TXB' + substr(entry(j,v-iik),19,2),v-bank1) <= 0 then do:
               if v-bank1 <> '' then v-bank1 = v-bank1 + ','.
               find first comm.txb where comm.txb.bank = 'TXB' + substr(entry(j,v-iik),19,2) no-lock no-error.
               if (avail comm.txb) then v-bank1 = v-bank1 + 'TXB' + substr(entry(j,v-iik),19,2).
             end.
           end.
        end.

    end. /* transaction */

    do transaction:
        find first insin where insin.ref eq v-ref no-lock no-error.
        if not avail insin then do:
            create insin.
            assign insin.ref = v-ref
                insin.clrnn = v-jss
                insin.clbin = v-clbin
                insin.clname = v-name
                insin.mfo = v-mfo
                insin.iik = v-iik
                insin.num = v-num
                insin.dt = v-dt
                insin.numr = v-numr
                insin.dtr = v-dtr
                insin.type = v-type
                insin.filename = v-filename
                insin.stat = 0
                insin.mnu = v-mnu
                insin.rdt = g-today
                insin.rtm = time
                insin.bank = v-bank
                insin.bank1 = v-bank1
                insin.nkrnn = v-nkrnn
                insin.nkbin = v-nkbin
                insin.nkname = v-nkname
                insin.reas = v-reas
                insin.reschar[1] = v-fcreinfo.

           if num-entries(v-bank1) > 1 then do:
               run mail('id00787@metrocombank.kz', "METROCOMBANK <abpk@metrocombank.kz>", "Прием РПРО со счетами для разных филиалов " + v-bank1, "Прием РПРО со счетами для разных филиалов " + v-bank1, "1", "", "").
           end.
        end.
        else run savelog( "insps", "insin: Запись в insin с референсом " + v-ref + " уже есть!").
    end.
end.