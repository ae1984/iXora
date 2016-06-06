/* p905.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Проверка на наличие МТ905 в \\\Secure FTP\iXora\data\bmkb\ps\NB\IN\
 * RUN
        6-1 процесс отрабатывает каждые 5 мин
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25.08.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        20.09.2011 aigul - убрала замену очереди на филиалах
        28.02.2012 aigul - убрала себя из рассылки
*/

def var v-dir as char.
def var v-host as char.
def var v-text as char.
def var v-str as char.
def var v-file as char.
def var s as char.
def var i as int.
def var j as int.
def buffer b-mt905 for mt905.
def var v-sts as logical initial no.
def var v-rmz as char.
def var v-rmz1 as char.
def var v-20 as char.
def var v-sum as char.
def var v-error as char.
def var v-msg as char.
def var v-msg1 as char.
def var v-bank as char.
def var v-que as char.
def var v-log as logical initial no.
def var oldpid like que.pid .
def var oldpri like que.pri .
def var nparpri as cha .
def var nparpid as cha .
def var v-ref1 as char.
def var v-ref2 as char.
def var v-ref3 as char.
def var v-ref4 as char.
def var v-ref5 as char.
def var v-ref as char.

def temp-table rmz
    FIELD num as int
    field bank as char
    field remtrz as char.
find sysc where sysc.sysc = "lbHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
    message v-text .
    run lgps.
    return .
end.
v-host = sysc.chval .
/*v-host = "Administrator@`askhost`".*/
v-dir = "/data/bmkb/ps/NB/IN/".

/*число файлов*/
/*input through value("find /home/" + g-ofc + "/" + "*.905 -type f | wc -l") no-echo.
repeat:
    import unformatted s.
    i = int(s).
end.*/

input through value("ls " + v-dir + "*.905") no-echo.
repeat:
    import unformatted s.
    find first mt905 where mt905.file = s no-lock no-error.
    if avail mt905 then next.
    create mt905.
    find last b-mt905 no-lock no-error.
    if avail b-mt905 then mt905.num = b-mt905.num + 1.
    else mt905.num = 1.
    mt905.file = s.
    mt905.dt = today.
    mt905.tim = time.
    mt905.sts = "new".
end.
input close.

for each mt905 where mt905.dt = today and mt905.sts = "new" exclusive-lock:
    input through value ("grep -r ':72:' " + mt905.file) no-echo.
        import unformatted v-str.
        mt905.rem = substr(v-str,5,10000).
    input close.
end.
i = 0.
for each mt905 where mt905.dt = today and mt905.sts = "new" exclusive-lock.
    input through value ("grep -r ':21:' " + mt905.file) no-echo.
        import unformatted v-str.
        v-20 = substr(v-str,5,16).
    input close.
    v-log = no.
    for each remtrz where remtrz.remtrz = v-20 no-lock:
        find first crc where crc.crc = remtrz.fcrc no-lock no-error.
        if avail crc then v-sum = string(remtrz.amt) + " " + crc.code.
        v-rmz1 = substr(remtrz.sqn,7,10).
        v-rmz = remtrz.remtrz.
        v-log = yes.
        v-error = mt905.rem.
        if v-msg = "" then v-msg = v-rmz + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
        else v-msg = v-msg + "\n\n " + v-rmz + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
        if v-msg1 = "" then v-msg1 = v-rmz1 + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
        else v-msg1 = v-msg1 + "\n\n " + v-rmz1 + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина: Ошибка - " + v-error.
        find first que where que.remtrz = v-rmz and que.pid = "stw" exclusive-lock no-error.
        if avail que then do:
            oldpri = que.pri.
            oldpid = que.pid.
            nparpri = substr(que.npar,1,17).
            nparpid = substr(que.npar,18).
            que.pid = "31".
            que.df = today .
            que.tf = time .
            nparpri = " Last PRI = " + string(oldpri,"zzzz9") .
            nparpid = " Last PID = " + string(oldpid) .
            que.npar = nparpri + nparpid .
        end.
        v-bank = remtrz.sbank.
        i = i + 1.
        create rmz.
        rmz.num = i.
        rmz.bank = v-bank.
        rmz.remtrz = v-rmz1.
    end.
    if v-log = no then do:
        for each remtrz where remtrz.package = v-20 no-lock:
            find first crc where crc.crc = remtrz.fcrc no-lock no-error.
            if avail crc then v-sum = string(remtrz.amt) + " " + crc.code.
            v-rmz1 = substr(remtrz.sqn,7,10).
            v-rmz = remtrz.remtrz.
            v-error = mt905.rem.
            if v-msg = "" then v-msg = v-rmz + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
            else v-msg = v-msg + "\n\n " + v-rmz + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
            if v-msg1 = "" then v-msg1 = v-rmz1 + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина Ошибка " + v-error.
            else v-msg1 = v-msg1 + "\n\n " + v-rmz1 + " на сумму " + v-sum + " перемещен на очередь 31" + ". Причина: Ошибка - " + v-error.
            find first que where que.remtrz = v-rmz and que.pid = "stw" exclusive-lock no-error.
            if avail que then do:
                oldpri = que.pri.
                oldpid = que.pid.
                nparpri = substr(que.npar,1,17).
                nparpid = substr(que.npar,18).
                que.pid = "31".
                que.df = today .
                que.tf = time .
                nparpri = " Last PRI = " + string(oldpri,"zzzz9") .
                nparpid = " Last PID = " + string(oldpid) .
                que.npar = nparpri + nparpid .
            end.
            v-bank = remtrz.sbank.
            i = i + 1.
            create rmz.
            rmz.num = i.
            rmz.bank = v-bank.
            rmz.remtrz = v-rmz1.
        end.
    end.
end.
/*меняем очередь рмз на 31 на филиалах*/
/*for each rmz no-lock:*/
    /*{r-branch.i &proc = "p905txb(rmz.remtrz, output v-ref) "}
    v-ref1 = v-ref1 + v-ref.
    {r-branch.i &proc = "p905txb(rmz.remtrz) "}*/
    /*if connected ("txb") then disconnect "txb".
    for each txb where txb.consolid and txb.bank = rmz.bank no-lock:
        if connected ("txb") then  disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
        run p905txb1(rmz.remtrz, v-ref4, output v-ref, output v-ref5).
        v-ref1 = v-ref1 + v-ref.
        v-ref4 = v-ref5.
        disconnect "txb".
    end.
end.
for each rmz no-lock:
    {r-branch.i &proc = "p905txb(rmz.remtrz) "}
end.*/
if v-msg <> "" /*and v-msg1 <> ""*/ then do:
    v-ref2 = "id00179@metrocombank.kz; id00276@metrocombank.kz;".
    /*v-ref3 = v-ref2 + " " + v-ref1.*/
    run mail(v-ref2,"METROCOMBANK <abpk@metrocombank.kz>", 'Ошибка МТ905', v-msg, "", "","").
    /*run mail2 (v-ref3,"METROCOMBANK <abpk@metrocombank.kz>", 'Ошибка МТ905',v-msg1, "", "","").*/
    for each mt905 where mt905.dt = today and mt905.sts = "new" exclusive-lock.
    mt905.sts = "old".
    end.
end.

