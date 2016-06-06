/* calcfork3.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        01/10/2012 id01143
 * BASES
        BANK COMM
 * CHANGES
        06/02/2012 Sayat(id01143) - ТЗ 1697 осуществлен переход на ИИН/БИН
 */

def var v-sum       as deci.
def var v-rate      as deci no-undo extent 20.
def buffer b-loan   for loansk3.
def buffer b-loan11 for loansk3.
def buffer b-deps   for depsk3.
def var zalsum      as deci.
def var zalvid      as char.
def var loansum     as deci.
def var nloansum1   as deci initial 0.
def var nloansum2   as deci initial 0.
def var nfil1       as char initial "".
def var nfil2       as char initial "".
def var nlon1       as char initial "".
def var nlon2       as char initial "".
def var nloansum3   as deci initial 0.
def var nfil3       as char initial "".
def var nlon3       as char initial "".
def var v-loansum   as deci initial 0.
def var v-ltype     as char.
def var i as int initial 0.


def temp-table t-loan /*временная таблица для сбора данных по кредитам*/
    field tnum      as int
    field client    as char
    field clrnn     as char
    field clbin     as char
    field amt       as deci
    field zalamt    as deci
    field zalvid    as char
    field ltype     as char
    field ltype1    as char
    field ramt      as deci.

for each bank.crc where bank.crc.crc > 0 /*and bank.crc.crc <= 4*/ no-lock:
    v-rate[bank.crc.crc] =  bank.crc.rate[1].
end.

function clspecrel returns logical (input fil1 as char, input lon1 as char).
    def buffer b-loan1  for loansk3.
    def buffer b-clink1 for clinksk3.
    def var ncol    as int initial 0.
    def var clsr    as logical initial false.
    find first b-loan1 where b-loan1.fil = fil1 and b-loan1.lon = lon1 no-lock no-error.
    if not avail b-loan1 then return false.
    for each b-clink1 where b-clink1.clbin1 = b-loan1.clbin and b-clink1.clname1 = b-loan1.client no-lock:
        find first prisv where (prisv.rnn = b-clink1.clbin2 and b-clink1.clbin2 <> "") or (prisv.name = b-clink1.clname2 and b-clink1.clbin2 = "" ) or (prisv.name = b-clink1.clname2 and prisv.rnn = "") no-lock no-error.
        if avail prisv then ncol = ncol + 1.
    end.
    for each b-clink1 where b-clink1.clbin2 = b-loan1.clbin or b-clink1.clname2 = b-loan1.client no-lock:
        find first prisv where (prisv.rnn = b-clink1.clbin1 and b-clink1.clbin1 <> "" and b-clink1.clbin1 <> "012345678910") or (prisv.name = b-clink1.clname1 and (b-clink1.clbin1 = "" or b-clink1.clbin1 = "012345678910")) or (prisv.name = b-clink1.clname1 and prisv.rnn = "") no-lock no-error.
        if avail prisv then ncol = ncol + 1.
    end.
    if ncol > 0 then clsr = true.
    else do:
        find first prisv where (prisv.rnn = b-loan1.clbin and b-loan1.clbin <> "" and b-loan1.clbin <> "012345678910") or ((b-loan1.clbin = "" or b-loan1.clbin = "012345678910") and prisv.name = b-loan1.client) or (prisv.rnn = "" and prisv.name = b-loan1.client) no-lock no-error.
        if avail prisv then clsr = true.
    end.
    return clsr.
end function.

function loanagsum returns decimal (input fil2 as char, input lon2 as char).
    def buffer b-loan2  for loansk3.
    def buffer b-clink2 for clinksk3.
    def buffer b-loan3  for loansk3.
    def buffer b-deps1  for depsk3.
    def var loansum     as deci initial 0.
    def var zalsum      as deci initial 0.
    def var sum         as deci.
    loansum = 0.
    zalsum = 0.
    find first b-loan2 where b-loan2.fil = fil2 and b-loan2.lon = lon2 no-lock no-error.
    if not avail b-loan2 then return 0.
    for each b-loan3 where b-loan3.clbin = b-loan2.clbin and b-loan3.client = b-loan2.client /*and b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt > 0*/ no-lock:
        loansum = loansum + (b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt) * v-rate[b-loan3.loncrc].
        zalsum = zalsum + b-loan3.zaldep.
    end.
    /*
    for each b-deps1 where b-deps1.clbin = b-loan2.clbin and b-deps1.client = b-loan2.client and (b-deps1.depgl = 224015 or b-deps1.depgl = 224025) no-lock:
        zalsum = zalsum + b-deps1.amt * v-rate[b-deps1.depcrc].
    end.
    */
    for each b-clink2 where b-clink2.clbin1 = b-loan2.clbin and b-clink2.clname1 = b-loan2.client no-lock:
        for each b-loan3 where ((b-loan3.clbin = b-clink2.clbin2 and b-clink2.clbin2 <> "") or (b-clink2.clbin2 = "" and b-loan3.client = b-clink2.clname2)) /*and b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt > 0*/ no-lock:
            loansum = loansum + (b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt) * v-rate[b-loan3.loncrc].
            zalsum = zalsum + b-loan3.zaldep.
        end.
        /*
        for each b-deps1 where ((b-deps1.clbin = b-clink2.clbin2 and b-clink2.clbin2 <> "") or (b-clink2.clbin2 = "" and b-deps1.client = b-clink2.clname2)) and (b-deps1.depgl = 224015 or b-deps1.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps1.amt * v-rate[b-deps1.depcrc].
        end.
        */
    end.
    for each b-clink2 where b-clink2.clbin2 = b-loan2.clbin and b-clink2.clname2 = b-loan2.client no-lock:
        for each b-loan3 where ((b-loan3.clbin = b-clink2.clbin1 and b-clink2.clbin1 <> "" and b-clink2.clbin1 <> "012345678910") or ((b-clink2.clbin1 = "" or b-clink2.clbin1 = "012345678910") and b-loan3.client = b-clink2.clname1)) /*and b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt > 0*/ no-lock:
            loansum = loansum + (b-loan3.amt + b-loan3.prsramt - b-loan3.prvzamt) * v-rate[b-loan3.loncrc].
            zalsum = zalsum + b-loan3.zaldep.
        end.
        /*
        for each b-deps1 where ((b-deps1.clbin = b-clink2.clbin1 and b-clink2.clbin1 <> "") or (b-clink2.clbin1 = "" and b-deps1.client = b-clink2.clname1)) and (b-deps1.depgl = 224015 or b-deps1.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps1.amt * v-rate[b-deps1.depcrc].
        end.
        */
    end.
    sum = loansum - zalsum.
    return sum.
end function.


def frame f-date v-sum format "->>>>>>>>>>>>>>9.99<<<<<<<<"label "Сумма собственного капитала (тыс.тенге)"
with side-labels centered row 7 title "Параметры отчета".

update  v-sum with frame f-date.
v-sum = v-sum * 1000.

nloansum1 = 0.
nloansum2 = 0.
for each loansk3 where loansk3.amt + loansk3.prsramt - loansk3.prvzamt > 0 no-lock:
    v-loansum = loanagsum(loansk3.fil,loansk3.lon).
    if clspecrel(loansk3.fil,loansk3.lon) then do:
        if v-loansum > nloansum2 then do:
            nloansum2 = v-loansum.
            nfil2 = loansk3.fil.
            nlon2 = loansk3.lon.
        end.
    end.
    else do:
        if v-loansum > nloansum1 then do:
            nloansum1 = v-loansum.
            nfil1 = loansk3.fil.
            nlon1 = loansk3.lon.
        end.
    end.
end.

nloansum3 = 0.
for each loansk3 where loansk3.zalamt + loansk3.zalgar + loansk3.zaldep = 0 and loansk3.amt + loansk3.prsramt - loansk3.prvzamt > 0 and loansk3.zalog1 = "" no-lock:
    loansum = 0.
    for each b-loan where b-loan.clbin = loansk3.clbin and b-loan.client = loansk3.client and b-loan.zalamt +  b-loan.zalgar + b-loan.zaldep = 0 and  b-loan.zalog1 = "" no-lock:
        loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
    end.
    if loansum > nloansum3 then do:
            nloansum3 = loansum.
            nfil3 = loansk3.fil.
            nlon3 = loansk3.lon.
    end.
end.


loansum = 0.
zalsum = 0.
zalvid = "".
find first loansk3 where loansk3.fil = nfil1 and loansk3.lon = nlon1 no-lock no-error.
if avail loansk3 then do:
    for each b-loan where b-loan.clbin = loansk3.clbin and b-loan.client = loansk3.client /*and b-loan.amt + b-loan.prsramt - b-loan.prvzamt > 0*/ no-lock:
        loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
        zalsum = zalsum + b-loan.zaldep.
        if lookup(b-loan.zalog,zalvid) = 0 then do:
            if zalvid <> '' then zalvid = zalvid + ','.
            zalvid = zalvid + b-loan.zalog.
        end.
    end.
    /*
    for each b-deps where b-deps.clbin = loansk3.clbin and b-deps.client = loansk3.client and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
        zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
    end.
    */
    if (loansum - zalsum) > 0 then do:
        create  t-loan.
            t-loan.tnum = 1.
            t-loan.client = loansk3.client.
            t-loan.clrnn = loansk3.clrnn.
            t-loan.clbin = loansk3.clbin.
            t-loan.amt = loansum.
            t-loan.zalamt = zalsum.
            t-loan.zalvid = zalvid.
            t-loan.ltype = "".
            t-loan.ltype1 = "".
            t-loan.ramt = loansum - zalsum.
    end.
    for each clinksk3 where clinksk3.clbin1 = loansk3.clbin and clinksk3.clname1 = loansk3.client no-lock:
        loansum = 0.
        zalsum = 0.
        zalvid = "".
        v-ltype = clinksk3.linktype + " " + clinksk3.pay.
        for each b-loan11 where ((b-loan11.clbin = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and b-loan11.client = clinksk3.clname2)) /*and b-loan11.amt  + b-loan11.prsramt - b-loan11.prvzamt > 0*/ no-lock break by b-loan11.clbin by b-loan11.client:
            if first-of(b-loan11.clbin) then do:
                loansum = 0.
                zalsum = 0.
                zalvid = "".
            end.
            loansum = loansum + (b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt) * v-rate[b-loan11.loncrc].
            zalsum = zalsum + b-loan11.zaldep.
            if lookup(b-loan11.zalog,zalvid) = 0 then do:
                if zalvid <> '' then zalvid = zalvid + ','.
                zalvid = zalvid + b-loan11.zalog.
            end.
            if last-of(b-loan11.clbin) then do:
                if (loansum - zalsum) > 0 then do:
                    create  t-loan.
                            t-loan.tnum = 1.
                            t-loan.client = b-loan11.client.
                            t-loan.clrnn = b-loan11.clrnn.
                            t-loan.clbin = b-loan11.clbin.
                            t-loan.amt = loansum.
                            t-loan.zalamt = zalsum.
                            t-loan.zalvid = zalvid.
                            t-loan.ltype = v-ltype.
                            t-loan.ltype1 = "".
                            t-loan.ramt = loansum - zalsum.
                end.
            end.
        end.
        /*
        for each b-deps where ((b-deps.clbin = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and b-deps.client = clinksk3.clname2)) and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
        end.
        */
    end.
    for each clinksk3 where clinksk3.clbin2 = loansk3.clbin and clinksk3.clname2 = loansk3.client no-lock:
        loansum = 0.
        zalsum = 0.
        zalvid = "".
        v-ltype = clinksk3.linktype + " " + clinksk3.pay.
        for each b-loan11 where ((b-loan11.clbin = clinksk3.clbin1 and clinksk3.clbin1 <> "" and clinksk3.clbin1 <> "012345678910") or ((clinksk3.clbin1 = "" or clinksk3.clbin1 = "012345678910") and b-loan11.client = clinksk3.clname1)) /*and b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt > 0*/ no-lock break by b-loan11.clbin by b-loan11.client:
            if first-of(b-loan11.clbin) then do:
                loansum = 0.
                zalsum = 0.
                zalvid = "".
            end.
            loansum = loansum + (b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt) * v-rate[b-loan11.loncrc].
            zalsum = zalsum + b-loan11.zaldep.
            if lookup(b-loan11.zalog,zalvid) = 0 then do:
                if zalvid <> '' then zalvid = zalvid + ','.
                zalvid = zalvid + b-loan11.zalog.
            end.
            if last-of(b-loan11.clbin) then do:
                if (loansum - zalsum) > 0 then do:
                    create  t-loan.
                            t-loan.tnum = 1.
                            t-loan.client = b-loan11.client.
                            t-loan.clrnn = b-loan11.clrnn.
                            t-loan.clbin = b-loan11.clbin.
                            t-loan.amt = loansum.
                            t-loan.zalamt = zalsum.
                            t-loan.zalvid = zalvid.
                            t-loan.ltype = v-ltype.
                            t-loan.ltype1 = "".
                            t-loan.ramt = loansum - zalsum.
                end.
            end.
        end.
        /*
        for each b-deps where ((b-deps.clbin = clinksk3.clbin1 and clinksk3.clbin1 <> "") or (clinksk3.clbin1 = "" and b-deps.client = clinksk3.clname1)) and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
        end.
        */
    end.
end.
loansum = 0.
zalsum = 0.
zalvid = "".
find first loansk3 where loansk3.fil = nfil2 and loansk3.lon = nlon2 no-lock no-error.
if avail loansk3 then do:
    for each b-loan where b-loan.clbin = loansk3.clbin and b-loan.client = loansk3.client /*and b-loan.amt + b-loan.prsramt - b-loan.prvzamt > 0*/ no-lock:
        loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
        zalsum = zalsum + b-loan.zaldep.
        if lookup(b-loan.zalog,zalvid) = 0 then do:
            if zalvid <> '' then zalvid = zalvid + ','.
            zalvid = zalvid + b-loan.zalog.
        end.
    end.
    /*
    for each b-deps where b-deps.clbin = loansk3.clbin and b-deps.client = loansk3.client and ( b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
        zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
    end.
    */
    find first prisv where (prisv.rnn = loansk3.clbin and loansk3.clbin <> "" and loansk3.clbin <> "012345678910") or ((loansk3.clbin = "" or loansk3.clbin = "012345678910") and prisv.name = loansk3.client) or (prisv.rnn = "" and prisv.name = loansk3.client) no-lock no-error.
    if (loansum - zalsum) > 0 then do:
        create  t-loan.
            t-loan.tnum = 2.
            t-loan.client = loansk3.client.
            t-loan.clrnn = loansk3.clrnn.
            t-loan.clbin = loansk3.clbin.
            t-loan.amt = loansum.
            t-loan.zalamt = zalsum.
            t-loan.zalvid = zalvid.
            t-loan.ltype = "".
            if avail prisv then t-loan.ltype1 = prisv.specrel.
            else t-loan.ltype1 = "".
            t-loan.ramt = loansum - zalsum.
    end.
    for each clinksk3 where clinksk3.clbin1 = loansk3.clbin and clinksk3.clname1 = loansk3.client no-lock:
        loansum = 0.
        zalsum = 0.
        zalvid = "".
        v-ltype = clinksk3.linktype + " " + clinksk3.pay.
        for each b-loan11 where ((b-loan11.clbin = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and b-loan11.client = clinksk3.clname2)) /*and b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt > 0*/ no-lock break by b-loan11.clbin by b-loan11.client:
            if first-of(b-loan11.clbin) then do:
                loansum = 0.
                zalsum = 0.
                zalvid = "".
            end.
            loansum = loansum + (b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt) * v-rate[b-loan11.loncrc].
            zalsum = zalsum + b-loan11.zaldep.
            if lookup(b-loan11.zalog,zalvid) = 0 then do:
                if zalvid <> '' then zalvid = zalvid + ','.
                zalvid = zalvid + b-loan11.zalog.
            end.
            if last-of(b-loan11.clbin) then do:
                find first prisv where (prisv.rnn = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and prisv.name = clinksk3.clname2) or (prisv.rnn = "" and prisv.name = clinksk3.clname2) no-lock no-error.
                if (loansum - zalsum) > 0 then do:
                    create  t-loan.
                            t-loan.tnum = 2.
                            t-loan.client = b-loan11.client.
                            t-loan.clrnn = b-loan11.clrnn.
                            t-loan.clbin = b-loan11.clbin.
                            t-loan.amt = loansum.
                            t-loan.zalamt = zalsum.
                            t-loan.zalvid = zalvid.
                            t-loan.ltype = v-ltype.
                            if avail prisv then t-loan.ltype1 = prisv.specrel.
                            else t-loan.ltype1 = "".
                            t-loan.ramt = loansum - zalsum.
                end.
            end.
        end.
        /*
        for each b-deps where ((b-deps.clbin = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and b-deps.client = clinksk3.clname2)) and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
        end.
        */
    end.
    for each clinksk3 where clinksk3.clbin2 = loansk3.clbin and clinksk3.clname2 = loansk3.client no-lock:
        loansum = 0.
        zalsum = 0.
        zalvid = "".
        v-ltype = clinksk3.linktype + " " + clinksk3.pay.
        for each b-loan11 where ((b-loan11.clbin = clinksk3.clbin1 and clinksk3.clbin1 <> "") or (clinksk3.clbin1 = "" and b-loan11.client = clinksk3.clname1)) /*and b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt > 0*/ no-lock break by b-loan11.clbin by b-loan11.client:
            if first-of(b-loan11.clbin) then do:
                loansum = 0.
                zalsum = 0.
                zalvid = "".
            end.
            loansum = loansum + (b-loan11.amt + b-loan11.prsramt - b-loan11.prvzamt) * v-rate[b-loan11.loncrc].
            zalsum = zalsum + b-loan11.zaldep.
            if lookup(b-loan11.zalog,zalvid) = 0 then do:
                if zalvid <> '' then zalvid = zalvid + ','.
                zalvid = zalvid + b-loan11.zalog.
            end.
            if last-of(b-loan11.clbin) then do:
                find first prisv where (prisv.rnn = clinksk3.clbin2 and clinksk3.clbin2 <> "") or (clinksk3.clbin2 = "" and prisv.name = clinksk3.clname2) or (prisv.rnn = "" and prisv.name = clinksk3.clname2) no-lock no-error.
                if (loansum - zalsum) > 0 then do:
                    create  t-loan.
                            t-loan.tnum = 2.
                            t-loan.client = b-loan11.client.
                            t-loan.clrnn = b-loan11.clrnn.
                            t-loan.clbin = b-loan11.clbin.
                            t-loan.amt = loansum.
                            t-loan.zalamt = zalsum.
                            t-loan.zalvid = zalvid.
                            t-loan.ltype = v-ltype.
                            if avail prisv then t-loan.ltype1 = prisv.specrel.
                            else t-loan.ltype1 = "".
                            t-loan.ramt = loansum - zalsum.
                end.
            end.
        end.
        /*
        for each b-deps where ((b-deps.clbin = clinksk3.clbin1 and clinksk3.clbin1 <> "") or (clinksk3.clbin1 = "" and b-deps.client = clinksk3.clname1)) and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
        end.
        */
    end.
end.

for each loansk3 where loansk3.amt + loansk3.prsramt - loansk3.prvzamt > 0 no-lock:
    loansum = 0.
    zalsum = 0.
    zalvid = "".
    find first prisv where (prisv.rnn = loansk3.clbin and loansk3.clbin <> "" and loansk3.clbin <> "012345678910") or ((loansk3.clbin = "" or loansk3.clbin = "012345678910") and prisv.name = loansk3.client) or (prisv.rnn = "" and prisv.name = loansk3.client) no-lock no-error.

    if avail prisv then do:
        for each b-loan where b-loan.clbin = loansk3.clbin /*and b-loan.clbin = loansk3.clbin*/ and b-loan.client = loansk3.client /*and b-loan.amt + b-loan.prsramt - b-loan.prvzamt > 0*/ no-lock:
            loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
            zalsum = zalsum + b-loan.zaldep.

            if lookup(b-loan.zalog,zalvid) = 0 then do:
                if zalvid <> '' then zalvid = zalvid + ','.
                zalvid = zalvid + b-loan.zalog.
            end.

        end.
        /*
        for each b-deps where b-deps.clbin = loansk3.clbin and b-deps.client = loansk3.client and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
            zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
        end.
        */
        find first t-loan where t-loan.tnum = 3 and t-loan.client = loansk3.client and t-loan.clbin = loansk3.clbin /*and t-loan.clbin = loansk3.clbin*/ no-lock no-error.
        if not avail t-loan then do:
            if (loansum - zalsum) > 0 then do:
                create  t-loan.
                    t-loan.tnum = 3.
                    t-loan.client = loansk3.client.
                    t-loan.clrnn = loansk3.clrnn.
                    t-loan.clbin = loansk3.clbin.
                    t-loan.amt = loansum.
                    t-loan.zalamt = zalsum.
                    t-loan.zalvid = zalvid.
                    t-loan.ltype = "".
                    t-loan.ltype1 = prisv.specrel.
                    t-loan.ramt = loansum - zalsum.
            end.
        end.
    end.
end.

loansum = 0.
zalsum = 0.
find first loansk3 where loansk3.fil = nfil3 and loansk3.lon = nlon3 no-lock no-error.
if avail loansk3 then do:
    for each b-loan where b-loan.clbin = loansk3.clbin /*and b-loan.clbin = loansk3.clbin*/ and b-loan.client = loansk3.client and b-loan.zalamt +  b-loan.zalgar + b-loan.zaldep = 0 /*and b-loan.amt + b-loan.prsramt - b-loan.prvzamt > 0*/ and b-loan.zalog1 = "" no-lock:
        loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
    end.
    if (loansum - zalsum) > 0 then do:
        create  t-loan.
            t-loan.tnum = 4.
            t-loan.client = loansk3.client.
            t-loan.clrnn = loansk3.clrnn.
            t-loan.clbin = loansk3.clbin.
            t-loan.amt = loansum.
            t-loan.zalamt = zalsum.
            t-loan.ltype = "".
            t-loan.ltype1 = "".
            t-loan.ramt = loansum - zalsum.
    end.
end.


for each loansk3 where loansk3.amt + loansk3.prsramt - loansk3.prvzamt > 0 no-lock:
    loansum = 0.
    zalsum = 0.
    zalvid = "".
    for each b-loan where b-loan.clbin = loansk3.clbin /*and b-loan.clbin = loansk3.clbin*/ and b-loan.client = loansk3.client /*and b-loan.amt + b-loan.prsramt - b-loan.prvzamt > 0*/ no-lock:
        loansum = loansum + (b-loan.amt + b-loan.prsramt - b-loan.prvzamt) * v-rate[b-loan.loncrc].
        zalsum = zalsum + b-loan.zaldep.

        if lookup(b-loan.zalog,zalvid) = 0 then do:
            if zalvid <> '' then zalvid = zalvid + ','.
            zalvid = zalvid + b-loan.zalog.
        end.

    end.
    /*
    for each b-deps where b-deps.clbin = loansk3.clbin and b-deps.client = loansk3.client and (b-deps.depgl = 224015 or b-deps.depgl = 224025) no-lock:
        zalsum = zalsum + b-deps.amt * v-rate[b-deps.depcrc].
    end.
    */
    if (loansum - zalsum) > 0.1 * v-sum then do:
        find first t-loan where t-loan.tnum = 5 and t-loan.client = loansk3.client and t-loan.clbin = loansk3.clbin /*and t-loan.clbin = loansk3.clbin*/ no-lock no-error.
        if not avail t-loan and (loansum - zalsum) > 0 then do:
            create  t-loan.
                    t-loan.tnum = 5.
                    t-loan.client = loansk3.client.
                    t-loan.clrnn = loansk3.clrnn.
                    t-loan.clbin = loansk3.clbin.
                    t-loan.amt = loansum.
                    t-loan.zalamt = zalsum.
                    t-loan.zalvid = zalvid.
                    t-loan.ltype = "".
                    t-loan.ltype1 = "".
                    t-loan.ramt = loansum - zalsum.
        end.
    end.
end.

def stream m-out.
output stream m-out to calcfork3.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find first bank.cmp no-lock no-error.
put stream m-out unformatted "<br><br>" bank.cmp.name "<br>" skip.


for each t-loan no-lock break by t-loan.tnum.
accumulate ramt (TOTAL by t-loan.tnum).
    if first-of (t-loan.tnum) then do:
        i = 0.

        if t-loan.tnum = 1 or t-loan.tnum = 5 then do:
            /*if t-loan.tnum = 1 then put stream m-out unformatted "<br><br>" "Расшифровка максимальной совокупной задолженности одного заемщика или группы взаимосвязанных заемщиков, не связанных с банком особыми отношениями по любому виду обязательств перед банком согласно главе 3 Инструкции 358 " "<br>" skip.
            else put stream m-out unformatted "<br><br>" "Расшифровка совокупной суммы рисков банка на одного заемщика, размер каждого из которых превышает 10 процентов от собственного капитала банка" "<br>" skip.*/
            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
            put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ИИН/БИН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак взаимосвязанности заемщиков</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма требований</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Обеспечение в соответствии с пп.5) п.34 Инструкции 358</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Размер риска, тыс.тенге</td>"
                  "</tr>" skip "<tr>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Балансовый счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">вид обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "</tr>" skip.
        end.

        if t-loan.tnum = 2 then do:
            /*put stream m-out unformatted "<br><br>" "Расшифровка максимальной совокупной задолженности одного заемщика или группы взаимосвязанных заемщиков, связанных с банком особыми отношениями по любому виду обязательств перед банком согласно главе 3 Инструкции 358 " "<br>" skip.*/
            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
            put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ИИН/БИН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак связанности с банком особыми отношениями</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак взаимосвязанности заемщиков</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма требований</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Обеспечение в соответствии с пп.5) п.34 Инструкции 358</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Размер риска, тыс.тенге</td>"
                  "</tr>" skip "<tr>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Балансовый счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">вид обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "</tr>" skip.
        end.

        if t-loan.tnum = 3 then do:
            /*put stream m-out unformatted "<br><br>" "Расшифровка  суммы рисков  по всем заемщикам, связанным с банком особыми отношениями  " "<br>" skip.*/
            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
            put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ИИН/БИН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак связанности с банком особыми отношениями</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма требований</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Обеспечение в соответствии с пп.5) п.34 Инструкции 358</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Размер риска, тыс.тенге</td>"
                  "</tr>" skip "<tr>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Балансовый счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">вид обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "</tr>" skip.
        end.

        if t-loan.tnum = 4 then do:
            /*put stream m-out unformatted "<br><br>" "Расшифровка максимальной суммы бланкового займа, необеспеченных условных обязательств перед заемщиком либо за заемщика в пользу третьих лиц, по которым у банка могут возникнуть требования к заемщику в течение текущего и двух последующих месяцев, а также обязательств нерезидентов Республики Казахстан, зарегистрированных или являющихся гражданами оффшорных зон, за исключением требований к резидентам Республики Казахстан с рейтингом агентства Standard & Poors или рейтингом аналогичного уровня одного из других рейтинговых агентств не более чем на один пункт ниже суверенного рейтинга Республики Казахстан и нерезидентов, имеющих рейтинг не ниже «А» агентства Standard & Poors или рейтинг аналогичного уровня одного из других рейтинговых агентств, за исключением нерезидентов с рейтингом не ниже «А» агентства Standard & Poors или рейтингом аналогичного уровня одного из других рейтинговых агентств, в отношении одного заемщика или группы взаимосвязанных заемщиков" "<br>" skip.*/
            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
            put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ИИН/БИН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак взаимосвязанности заемщиков</td>"
                  "<td colspan = 2 bgcolor=""#C0C0C0""  align=""center"" valign=""top"">Сумма требований</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Размер риска, тыс.тенге</td>"
                  "</tr>" skip "<tr>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Балансовый счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top""></td>"
                  "</tr>" skip.
        end.

    end.

    i = i + 1.
    if t-loan.tnum = 1 or t-loan.tnum = 5 then do:
        put stream m-out unformatted
                            "<tr>"                          skip
                            "<td>"  string (i)    "</td>"   skip
                            "<td>"  string(t-loan.client)     "</td>"   skip
                            "<td>"  "'" string(t-loan.clrnn)    "</td>"   skip
                            "<td>"  "'" string(t-loan.clbin)    "</td>"   skip
                            "<td>"  string(t-loan.ltype)    "</td>"   skip
                            "<td>"  ""  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.amt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  string(t-loan.zalvid)  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.zalamt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.ramt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "</tr>" skip.
        if last-of (t-loan.tnum) then do:

            put stream m-out unformatted
                         "<tr>"                          skip
                         "<td> ИТОГО </td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(round((accum total by (t-loan.tnum) ramt) / 1000,2) ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "</tr>" skip.
            put stream m-out unformatted "<br><br>" string(t-loan.tnum) "<br>" skip.
            if t-loan.tnum = 1 then put stream m-out unformatted "<br><br>" "Расшифровка максимальной совокупной задолженности одного заемщика или группы взаимосвязанных заемщиков, не связанных с банком особыми отношениями по любому виду обязательств перед банком согласно главе 3 Инструкции 358 " "<br>" skip.
            else put stream m-out unformatted "<br><br>" "Расшифровка совокупной суммы рисков банка на одного заемщика, размер каждого из которых превышает 10 процентов от собственного капитала банка" "<br>" skip.

        end.
    end.
    if t-loan.tnum = 2 then do:
        put stream m-out unformatted
                            "<tr>"                          skip
                            "<td>"  string (i)    "</td>"   skip
                            "<td>"  string(t-loan.client)     "</td>"   skip
                            "<td>"  "'" string(t-loan.clrnn)    "</td>"   skip
                            "<td>"  "'" string(t-loan.clbin)    "</td>"   skip
                            "<td>"  string(t-loan.ltype1)    "</td>"   skip
                            "<td>"  string(t-loan.ltype)    "</td>"   skip
                            "<td>"  ""  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.amt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  string(t-loan.zalvid)  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.zalamt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.ramt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "</tr>" skip.
        if last-of (t-loan.tnum) then do:
            put stream m-out unformatted
                         "<tr>"                          skip
                         "<td> ИТОГО </td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(round((accum total by (t-loan.tnum) ramt) / 1000,2) ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "</tr>" skip.
            put stream m-out unformatted "<br><br>" string(t-loan.tnum) "<br>" skip.
            put stream m-out unformatted "<br><br>" "Расшифровка максимальной совокупной задолженности одного заемщика или группы взаимосвязанных заемщиков, связанных с банком особыми отношениями по любому виду обязательств перед банком согласно главе 3 Инструкции 358 " "<br>" skip.
        end.
    end.
    if t-loan.tnum = 3 then do:
        put stream m-out unformatted
                            "<tr>"                          skip
                            "<td>"  string (i)    "</td>"   skip
                            "<td>"  string(t-loan.client)     "</td>"   skip
                            "<td>"  "'" string(t-loan.clrnn)    "</td>"   skip
                            "<td>"  "'" string(t-loan.clbin)    "</td>"   skip
                            "<td>"  string(t-loan.ltype1)    "</td>"   skip
                            "<td>"  ""  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.amt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  string(t-loan.zalvid)  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.zalamt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.ramt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "</tr>" skip.
        if last-of (t-loan.tnum) then do:
            put stream m-out unformatted
                         "<tr>"                          skip
                         "<td> ИТОГО </td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(round((accum total by (t-loan.tnum) ramt) / 1000,2) ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "</tr>" skip.
            put stream m-out unformatted "<br><br>" string(t-loan.tnum) "<br>" skip.
            put stream m-out unformatted "<br><br>" "Расшифровка  суммы рисков  по всем заемщикам, связанным с банком особыми отношениями  " "<br>" skip.
        end.
    end.
    if t-loan.tnum = 4 then do:
        put stream m-out unformatted
                            "<tr>"                          skip
                            "<td>"  string (i)    "</td>"   skip
                            "<td>"  string(t-loan.client)     "</td>"   skip
                            "<td>"  "'" string(t-loan.clrnn)    "</td>"   skip
                            "<td>"  "'" string(t-loan.clbin)    "</td>"   skip
                            "<td>"  string(t-loan.ltype)    "</td>"   skip
                            "<td>"  string(t-loan.zalvid)  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.amt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(round(t-loan.ramt / 1000,2)),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "</tr>" skip.
        if last-of (t-loan.tnum) then do:
            put stream m-out unformatted
                         "<tr>"                          skip
                         "<td> ИТОГО </td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(round((accum total by (t-loan.tnum) ramt) / 1000,2),  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "</tr>" skip.
            put stream m-out unformatted "<br><br>" string(t-loan.tnum) "<br>" skip.
            put stream m-out unformatted "<br><br>" "Расшифровка максимальной суммы бланкового займа, необеспеченных условных обязательств перед заемщиком либо за заемщика в пользу третьих лиц, по которым у банка могут возникнуть требования к заемщику в течение текущего и двух последующих месяцев, а также обязательств нерезидентов Республики Казахстан, зарегистрированных или являющихся гражданами оффшорных зон, за исключением требований к резидентам Республики Казахстан с рейтингом агентства Standard & Poors или рейтингом аналогичного уровня одного из других рейтинговых агентств не более чем на один пункт ниже суверенного рейтинга Республики Казахстан и нерезидентов, имеющих рейтинг не ниже «А» агентства Standard & Poors или рейтинг аналогичного уровня одного из других рейтинговых агентств, за исключением нерезидентов с рейтингом не ниже «А» агентства Standard & Poors или рейтингом аналогичного уровня одного из других рейтинговых агентств, в отношении одного заемщика или группы взаимосвязанных заемщиков" "<br>" skip.
        end.
    end.

end.

output stream m-out close.
/*unix silent value("cptwin calcfork3.htm excel").*/
unix silent cptwin value("calcfork3.htm") excel.
