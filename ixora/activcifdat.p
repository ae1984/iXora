/* activcifdat.p
 * MODULE
        Название модуля - Активные клиенты и счета.
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
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        22.07.2011 damir - дата(верхняя) учитывается не включительно
*/

def input parameter p-bank  as char.
def input parameter p-dep   as char.
def input parameter p-date  as date.
def input parameter p-dat1  as date.
def input parameter p-dat2  as date.
def input parameter p-year  as inte.
def input parameter p-type  as char.


def var v-bank     as char.
def var v-bankname as char.
def var v-deptmp   as int no-undo.
def var v-name     as char.
def var v-dep      as int no-undo.
def var v-sumcif  as deci no-undo.
def var v-sumgl   as deci no-undo.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

def temp-table one /*Клиенты, по признакам сегментации*/
    field cif     like txb.cif.cif
    field regdt   as date
    field priznak as inte.

def temp-table two /*Собираем счета, по которым были осуществлены 3 и более транзакции*/
    field aaa   like txb.aaa.aaa
    field regdt as date
    field jh    as inte
    field val   as inte.

def temp-table three  /*Обороты по кредиту, кроме ссудныхх операций и конвертации валют, в разбивке валют*/
    field aaa  like txb.aaa.aaa
    field regdt as date
    field amt  as deci decimals 2
    field val as inte.

def temp-table four /*Остатки – сумма остатков по всем счетам в разбивке валют*/
    field aaa   like txb.aaa.aaa
    field regdt as date
    field amt   as deci decimals 2
    field crc   as inte.

def temp-table five /*Количество активных клиентов – клиенты, у которых есть активные счета*/
    field cif   like txb.cif.cif
    field regdt as date
    field jh    as inte.

def temp-table six /*Количество новых клиентов – количество новых CIF кодов*/
    field cif   like txb.cif.cif
    field regdt as date.

def temp-table seven /*Количество клиентов с ссудными счетами – количество клиентов с ссудными счетами*/
    field cif   like txb.cif.cif
    field regdt as date.

def temp-table eight /*Количество клиентов, подключенных к сервису Internet Banking*/
    field cif   like txb.cif.cif
    field regdt as date.

def var dam1-cam1   as deci.
def var v-lonprnlev as char init "1".
for each txb.cif where txb.cif.del = no and txb.cif.type = trim(p-type) and txb.cif.regdt >= p-dat1 and txb.cif.regdt < p-dat2 no-lock:
    find first txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> 'C' no-lock no-error.  /*Общее количество клиентов-разбивка по признаку сегментации*/
    if avail txb.aaa then do:
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnsegm' and
        txb.sub-cod.ccode <> 'msc' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then do:
                create one.
                assign
                one.cif     = txb.cif.cif
                one.regdt   = txb.cif.regdt
                one.priznak = int(txb.codfr.code).
            end.
        end.
    end.
    hide message no-pause.
    message "Сбор данных(1) - " LN[i] "  БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.

/*Количество активных счетов - 3 и более операции*/
def buffer b-jl for txb.jl.
def buffer b-cif for txb.cif.
for each txb.aaa where txb.aaa.regdt >= p-dat1 and txb.aaa.regdt < p-dat2 and txb.aaa.sta <> 'C' no-lock:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then do:
        if txb.cif.type <> trim(p-type) then next.
    end.
    i1:
    for each txb.jl where txb.jl.sub = 'cif' and txb.jl.acc = txb.aaa.aaa and txb.jl.jdt >= p-dat1 and txb.jl.jdt < p-dat2 no-lock break by txb.jl.jh:
        if txb.jl.dc = "D" then do:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.cam = txb.jl.dam and b-jl.dc = "C" no-lock no-error.
            if avail b-jl then do:
                if lookup(substr(string(b-jl.gl),1,1), "4") > 0 then next i1.
                create two.
                assign
                two.aaa   = txb.aaa.aaa
                two.regdt = txb.aaa.regdt
                two.jh    = txb.jl.jh
                two.val   = txb.aaa.crc.
            end.
        end.
        if txb.jl.dc = "C" then do:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.dc = "D" no-lock no-error.
            if avail b-jl then do:
                create two.
                assign
                two.aaa   = txb.aaa.aaa
                two.regdt = txb.aaa.regdt
                two.jh    = txb.jl.jh
                two.val   = txb.aaa.crc.
            end.
        end.
        hide message no-pause.
        message "Сбор данных(2) - " LN[i] "  БАЗА № - " p-bank.
        if i = 8 then i = 1.
        else i = i + 1.
    end.
end.

/*Обороты по кредиту, кроме ссудныхх операций и конвертации валют, в разбивке валют*/
def buffer bjl for txb.jl.
for each txb.aaa where txb.aaa.regdt >= p-dat1 and txb.aaa.regdt < p-dat2 and txb.aaa.sta <> 'C' no-lock:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then do:
        if txb.cif.type <> trim(p-type) then next.
    end.
    i2:
    for each txb.jl where txb.jl.sub = 'cif' and txb.jl.lev = 1 and txb.jl.dc = 'C' and txb.jl.acc = txb.aaa.aaa and
    txb.jl.jdt >= p-dat1 and txb.jl.jdt < p-dat2 no-lock break by txb.jl.jh:
        if txb.jl.trx begins 'lon' then next i2.  /*Исключаем ссудные операции*/
        find first bjl where bjl.jh = txb.jl.jh and bjl.gl = 287044 no-lock no-error.
        if avail bjl then next i2. /*Исключаем конвертации валют*/
        create three.
        assign
        three.aaa   = txb.aaa.aaa
        three.regdt = txb.aaa.regdt
        three.amt   = txb.jl.cam
        three.val   = txb.aaa.crc.
        hide message no-pause.
        message "Сбор данных(3) - " LN[i] "  БАЗА № - " p-bank.
        if i = 8 then i = 1.
        else i = i + 1.
    end.
end.

/*Остатки – сумма остатков по всем счетам в разбивке валют*/
def var v-ost as deci decimals 2.
for each txb.aaa where txb.aaa.regdt >= p-dat1 and txb.aaa.regdt < p-dat2 and txb.aaa.sta <> 'C' no-lock:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then do:
         if txb.cif.type <> trim(p-type) then next.
    end.
    v-ost = txb.aaa.cbal - txb.aaa.hbal. /*Доступный остаток*/
    if v-ost > 0 then do:
        create four.
        assign
        four.aaa   = txb.aaa.aaa
        four.regdt = txb.aaa.regdt
        four.amt   = v-ost
        four.crc   = txb.aaa.crc.
    end.
    hide message no-pause.
    message "Сбор данных(4) - " LN[i] "  БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.

for each txb.cif where txb.cif.del = no and txb.cif.type = trim(p-type) and txb.cif.regdt >= p-dat1 and txb.cif.regdt < p-dat2 no-lock:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> 'C' no-lock:
        for each txb.jl where txb.jl.sub = 'cif' and txb.jl.acc = txb.aaa.aaa no-lock break by txb.jl.jh:
            create five. /*Количество активных клиентов – клиенты, у которых есть активные счета,min 3 операции*/
            assign
            five.cif   = txb.cif.cif
            five.regdt = txb.cif.regdt
            five.jh    = txb.jl.jh.
        end.
        hide message no-pause.
        message "Сбор данных(5) - " LN[i] "  БАЗА № - " p-bank.
        if i = 8 then i = 1.
        else i = i + 1.
    end.
end.

for each txb.cif where txb.cif.del = no and txb.cif.type = trim(p-type) and txb.cif.regdt >= p-dat1 and txb.cif.regdt < p-dat2 no-lock:
    create six. /*Количество новых клиентов – количество новых CIF кодов*/
    assign
    six.cif   = txb.cif.cif
    six.regdt = txb.cif.regdt.
    hide message no-pause.
    message "Сбор данных(6) - " LN[i] "  БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.

for each txb.cif where txb.cif.del = no and txb.cif.type = trim(p-type) and txb.cif.regdt >= p-dat1 and txb.cif.regdt < p-dat2 no-lock:
    dam1-cam1 = 0.
    for each txb.lon where txb.lon.cif = txb.cif.cif no-lock:
        for each txb.trxbal where txb.trxbal.subled = 'LON' and txb.trxbal.acc = txb.lon.lon no-lock:
            if lookup(string(txb.trxbal.level),v-lonprnlev) > 0 then dam1-cam1 = dam1-cam1 + (txb.trxbal.dam - txb.trxbal.cam).
        end.
    end.
    if dam1-cam1 > 0 then do:
        create seven.
        assign
        seven.cif   = txb.cif.cif
        seven.regdt = txb.cif.regdt.
    end.
    hide message no-pause.
    message "Сбор данных(7) - " LN[i] "  БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.

/*******************************************************/
for each eight exclusive-lock:
    delete eight.
end.
for each webra where webra.jdt >= p-dat1 and webra.jdt <= p-dat2 and webra.txb = p-bank no-lock: /*Количество клиентов, подключенных к сервису Internet Banking*/
    create eight.
    assign
    eight.cif   = webra.cif
    eight.regdt = webra.jdt.
    hide message no-pause.
    message "Сбор данных(8) - " LN[i] "  БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.
/*******************************************************/

/*Обработка данных*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table onetable
field month   as char
field priznak as inte.
def buffer b-one for one.
for each one no-lock break by one.priznak:
    if first-of(one.priznak) then do:
        for each b-one where b-one.priznak = one.priznak no-lock:
            create onetable.
            if month(b-one.regdt) = 1  then onetable.month = "Январь".
            if month(b-one.regdt) = 2  then onetable.month = "Февраль".
            if month(b-one.regdt) = 3  then onetable.month = "Март".
            if month(b-one.regdt) = 4  then onetable.month = "Апрель".
            if month(b-one.regdt) = 5  then onetable.month = "Май".
            if month(b-one.regdt) = 6  then onetable.month = "Июнь".
            if month(b-one.regdt) = 7  then onetable.month = "Июль".
            if month(b-one.regdt) = 8  then onetable.month = "Август".
            if month(b-one.regdt) = 9  then onetable.month = "Сентябрь".
            if month(b-one.regdt) = 10 then onetable.month = "Октябрь".
            if month(b-one.regdt) = 11 then onetable.month = "Ноябрь".
            if month(b-one.regdt) = 12 then onetable.month = "Декабрь".
            onetable.priznak = b-one.priznak.
        end.
    end.
end.
def temp-table onetable1
field month as char
field mic   as inte
field sma   as inte
field med   as inte
field cor   as inte
field itog  as inte.
def buffer b-onetable for onetable.
def var i1 as inte init 0.
def var i2 as inte init 0.
def var i3 as inte init 0.
def var i4 as inte init 0.
for each onetable no-lock break by onetable.month:
    if first-of(onetable.month) then do:
        assign
        i1 = 0 i2 = 0 i3 = 0 i4 = 4.
        create onetable1.
        onetable1.month = onetable.month.
        for each b-onetable where b-onetable.month = onetable.month no-lock:
            if b-onetable.priznak = 1 then i1 = i1 + 1.
            if b-onetable.priznak = 2 then i2 = i2 + 1.
            if b-onetable.priznak = 3 then i3 = i3 + 1.
            if b-onetable.priznak = 4 then i4 = i4 + 1.
        end.
        assign
        onetable1.cor  = i1
        onetable1.med  = i2
        onetable1.sma  = i3
        onetable1.mic  = i4
        onetable1.itog = i1 + i2 + i3 + i4.
    end.
end.
/*--------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table twotable
    field aaa   like txb.aaa.aaa
    field regdt as date
    field val   as inte.

def buffer b-two for two.
def var j as inte init 0.
for each two no-lock break by two.aaa:
    if first-of(two.aaa) then do:
        j = 0.
        for each b-two where b-two.aaa = two.aaa no-lock:
            j = j + 1.
        end.
        if j >= 3 then do: /*3 и более операции*/
            create twotable.
            assign
            twotable.aaa   = two.aaa
            twotable.regdt = two.regdt
            twotable.val   = two.val.
        end.
    end.
end.
def temp-table twotable1
    field month as char
    field val   as inte.

def buffer b-twotable for twotable.
for each twotable no-lock:
    create twotable1.
    if month(twotable.regdt) = 1  then twotable1.month = "Январь".
    if month(twotable.regdt) = 2  then twotable1.month = "Февраль".
    if month(twotable.regdt) = 3  then twotable1.month = "Март".
    if month(twotable.regdt) = 4  then twotable1.month = "Апрель".
    if month(twotable.regdt) = 5  then twotable1.month = "Май".
    if month(twotable.regdt) = 6  then twotable1.month = "Июнь".
    if month(twotable.regdt) = 7  then twotable1.month = "Июль".
    if month(twotable.regdt) = 8  then twotable1.month = "Август".
    if month(twotable.regdt) = 9  then twotable1.month = "Сентябрь".
    if month(twotable.regdt) = 10 then twotable1.month = "Октябрь".
    if month(twotable.regdt) = 11 then twotable1.month = "Ноябрь".
    if month(twotable.regdt) = 12 then twotable1.month = "Декабрь".
    assign
    twotable1.val = twotable.val.
end.
def temp-table twotable2
    field month as char
    field val1  as inte
    field val2  as inte
    field val3  as inte
    field val4  as inte
    field val5  as inte
    field itog  as inte.
def buffer b-twotable1 for twotable1.
def var k1 as inte.
def var k2 as inte.
def var k3 as inte.
def var k4 as inte.
def var k5 as inte.
for each twotable1 no-lock break by twotable1.month:
    if first-of(twotable1.month) then do:
        assign k1 = 0 k2 = 0 k3 = 0 k4 = 0 k5 = 0.
        create twotable2.
        twotable2.month = twotable1.month.
        for each b-twotable1 where b-twotable1.month = twotable1.month no-lock:
            if b-twotable1.val = 1 then k1 = k1 + 1.
            if b-twotable1.val = 2 then k2 = k2 + 1.
            if b-twotable1.val = 3 then k3 = k3 + 1.
            if b-twotable1.val = 4 then k4 = k4 + 1.
            if b-twotable1.val = 5 then k5 = k5 + 1.
        end.
        assign
        twotable2.val1 = k1
        twotable2.val2 = k2
        twotable2.val3 = k3
        twotable2.val4 = k4
        twotable2.val5 = k5
        twotable2.itog = k1 + k2 + k3 + k4 + k5.
    end.
end.
/*-----------------------------------------------------------------------------------------------------------------------------------*/
def temp-table threetable
field month as char
field amt   as deci decimals 2
field val   as inte.

for each three no-lock:
    create threetable.
    if month(three.regdt) = 1  then threetable.month = "Январь".
    if month(three.regdt) = 2  then threetable.month = "Февраль".
    if month(three.regdt) = 3  then threetable.month = "Март".
    if month(three.regdt) = 4  then threetable.month = "Апрель".
    if month(three.regdt) = 5  then threetable.month = "Май".
    if month(three.regdt) = 6  then threetable.month = "Июнь".
    if month(three.regdt) = 7  then threetable.month = "Июль".
    if month(three.regdt) = 8  then threetable.month = "Август".
    if month(three.regdt) = 9  then threetable.month = "Сентябрь".
    if month(three.regdt) = 10 then threetable.month = "Октябрь".
    if month(three.regdt) = 11 then threetable.month = "Ноябрь".
    if month(three.regdt) = 12 then threetable.month = "Декабрь".
    assign
    threetable.amt = three.amt
    threetable.val = three.val.
end.

def var v-crc2 as deci.
def var v-crc3 as deci.
def var v-crc4 as deci.
def var v-crc5 as deci.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.regdt <= p-date no-lock no-error.
if avail txb.crchis then v-crc2 = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.regdt <= p-date no-lock no-error.
if avail txb.crchis then v-crc3 = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 4 and txb.crchis.regdt <= p-date no-lock no-error.
if avail txb.crchis then v-crc4 = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 5 and txb.crchis.regdt <= p-date no-lock no-error.
if avail txb.crchis then v-crc5 = txb.crchis.rate[1].

def temp-table threetable1
field month as char
field amt1  as deci decimals 2
field amt2  as deci decimals 2
field amt3  as deci decimals 2
field amt4  as deci decimals 2
field amt5  as deci decimals 2
field itog  as deci decimals 2.
def var v-sum1 as deci.
def var v-sum2 as deci.
def var v-sum3 as deci.
def var v-sum4 as deci.
def var v-sum5 as deci.
def buffer b-threetable for threetable.
for each threetable no-lock break by threetable.month:
    if first-of(threetable.month) then do:
        assign v-sum1 = 0 v-sum2 = 0 v-sum3 = 0 v-sum4 = 0 v-sum5 = 0.
        create threetable1.
        threetable1.month = threetable.month.
        for each b-threetable where b-threetable.month = threetable.month no-lock:
            if b-threetable.val = 1 then v-sum1 = v-sum1 + b-threetable.amt.
            if b-threetable.val = 2 then v-sum2 = v-sum2 + b-threetable.amt.
            if b-threetable.val = 3 then v-sum3 = v-sum3 + b-threetable.amt.
            if b-threetable.val = 4 then v-sum4 = v-sum4 + b-threetable.amt.
            if b-threetable.val = 5 then v-sum5 = v-sum5 + b-threetable.amt.
        end.
        assign
        threetable1.amt1 = v-sum1
        threetable1.amt2 = v-sum2
        threetable1.amt3 = v-sum3
        threetable1.amt4 = v-sum4
        threetable1.amt5 = v-sum5.
        threetable1.itog = v-sum1 + v-sum2 * v-crc2 + v-sum3 * v-crc3 + v-sum4 * v-crc4 + v-sum5 * v-crc5.
    end.
end.

/*----------------------------------------------------------------------------------------------------------------------------------*/
def temp-table fourtable
field month as char
field amt   as deci decimals 2
field crc   as inte.
for each four no-lock:
    create fourtable.
    if month(four.regdt) = 1  then fourtable.month = "Январь".
    else
    if month(four.regdt) = 2  then fourtable.month = "Февраль".
    else
    if month(four.regdt) = 3  then fourtable.month = "Март".
    else
    if month(four.regdt) = 4  then fourtable.month = "Апрель".
    if month(four.regdt) = 5  then fourtable.month = "Май".
    else
    if month(four.regdt) = 6  then fourtable.month = "Июнь".
    else
    if month(four.regdt) = 7  then fourtable.month = "Июль".
    else
    if month(four.regdt) = 8  then fourtable.month = "Август".
    else
    if month(four.regdt) = 9  then fourtable.month = "Сентябрь".
    else
    if month(four.regdt) = 10 then fourtable.month = "Октябрь".
    else
    if month(four.regdt) = 11 then fourtable.month = "Ноябрь".
    else
    if month(four.regdt) = 12 then fourtable.month = "Декабрь".
    assign
    fourtable.amt = four.amt
    fourtable.crc = four.crc.
end.
def temp-table fourtable1
    field month as char
    field val1  as deci decimals 2
    field val2  as deci decimals 2
    field val3  as deci decimals 2
    field val4  as deci decimals 2
    field val5  as deci decimals 2
    field itog  as deci decimals 2.
def var v-summ1 as deci.
def var v-summ2 as deci.
def var v-summ3 as deci.
def var v-summ4 as deci.
def var v-summ5 as deci.
def buffer b-fourtable for fourtable.
for each fourtable no-lock break by fourtable.month:
    if first-of(fourtable.month) then do:
        assign v-summ1 = 0 v-summ2 = 0 v-summ3 = 0 v-summ4 = 0 v-summ5 = 0.
        create fourtable1.
        fourtable1.month = fourtable.month.
        for each b-fourtable where b-fourtable.month = fourtable.month no-lock:
            if b-fourtable.crc = 1 then v-summ1 = v-summ1 + fourtable.amt.
            if b-fourtable.crc = 2 then v-summ2 = v-summ2 + fourtable.amt.
            if b-fourtable.crc = 3 then v-summ3 = v-summ3 + fourtable.amt.
            if b-fourtable.crc = 4 then v-summ4 = v-summ4 + fourtable.amt.
            if b-fourtable.crc = 5 then v-summ5 = v-summ5 + fourtable.amt.
        end.
        assign
        fourtable1.val1 = v-summ1
        fourtable1.val2 = v-summ2
        fourtable1.val3 = v-summ3
        fourtable1.val4 = v-summ4
        fourtable1.val5 = v-summ5
        fourtable1.itog = v-summ1 + v-summ2 * v-crc2 + v-summ3 * v-crc3 + v-summ4 * v-crc4 + v-summ5 * v-crc5.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table fivetable
    field cif   as char
    field regdt as date.
def buffer b-five for five.
def var l as inte.
for each five no-lock break by five.cif:
    if first-of(five.cif) then do:
        l = 0.
        for each b-five where b-five.cif = five.cif no-lock:
            l = l + 1.
        end.
        if l >= 3 then do:
            create fivetable.
            assign
            fivetable.cif   = five.cif
            fivetable.regdt = five.regdt.
        end.
    end.
end.
def temp-table fivetable1
    field month as char.
for each fivetable no-lock:
    create fivetable1.
    if month(fivetable.regdt) = 1  then fivetable1.month = "Январь".
    if month(fivetable.regdt) = 2  then fivetable1.month = "Февраль".
    if month(fivetable.regdt) = 3  then fivetable1.month = "Март".
    if month(fivetable.regdt) = 4  then fivetable1.month = "Апрель".
    if month(fivetable.regdt) = 5  then fivetable1.month = "Май".
    if month(fivetable.regdt) = 6  then fivetable1.month = "Июнь".
    if month(fivetable.regdt) = 7  then fivetable1.month = "Июль".
    if month(fivetable.regdt) = 8  then fivetable1.month = "Август".
    if month(fivetable.regdt) = 9  then fivetable1.month = "Сентябрь".
    if month(fivetable.regdt) = 10 then fivetable1.month = "Октябрь".
    if month(fivetable.regdt) = 11 then fivetable1.month = "Ноябрь".
    if month(fivetable.regdt) = 12 then fivetable1.month = "Декабрь".
end.

def temp-table fivetable2
    field month as char
    field kol   as inte.
def buffer b-fivetable1 for fivetable1.
def var g as inte.
for each fivetable1 no-lock break by fivetable1.month:
    if first-of(fivetable1.month) then do:
        g = 0.
        create fivetable2.
        fivetable2.month = fivetable1.month.
        for each b-fivetable1 where b-fivetable1.month = fivetable1.month no-lock:
            g = g + 1.
        end.
        fivetable2.kol = g.
    end.
end.
/*----------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table sixtable
    field month as char.
for each six no-lock:
    create sixtable.
    if month(six.regdt) = 1  then sixtable.month = "Январь".
    if month(six.regdt) = 2  then sixtable.month = "Февраль".
    if month(six.regdt) = 3  then sixtable.month = "Март".
    if month(six.regdt) = 4  then sixtable.month = "Апрель".
    if month(six.regdt) = 5  then sixtable.month = "Май".
    if month(six.regdt) = 6  then sixtable.month = "Июнь".
    if month(six.regdt) = 7  then sixtable.month = "Июль".
    if month(six.regdt) = 8  then sixtable.month = "Август".
    if month(six.regdt) = 9  then sixtable.month = "Сентябрь".
    if month(six.regdt) = 10 then sixtable.month = "Октябрь".
    if month(six.regdt) = 11 then sixtable.month = "Ноябрь".
    if month(six.regdt) = 12 then sixtable.month = "Декабрь".
end.

def temp-table sixtable1
    field month  as char
    field kol    as inte.
def var m as inte.
def buffer b-sixtable for sixtable.
for each sixtable no-lock break by sixtable.month:
    if first-of(sixtable.month) then do:
        m = 0.
        create sixtable1.
        sixtable1.month = sixtable.month.
        for each b-sixtable where b-sixtable.month = sixtable.month no-lock:
            m = m + 1.
        end.
        sixtable1.kol = m.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table seventable
    field month as char.
for each seven no-lock:
    create seventable.
    if month(seven.regdt) = 1  then seventable.month = "Январь".
    if month(seven.regdt) = 2  then seventable.month = "Февраль".
    if month(seven.regdt) = 3  then seventable.month = "Март".
    if month(seven.regdt) = 4  then seventable.month = "Апрель".
    if month(seven.regdt) = 5  then seventable.month = "Май".
    if month(seven.regdt) = 6  then seventable.month = "Июнь".
    if month(seven.regdt) = 7  then seventable.month = "Июль".
    if month(seven.regdt) = 8  then seventable.month = "Август".
    if month(seven.regdt) = 9  then seventable.month = "Сентябрь".
    if month(seven.regdt) = 10 then seventable.month = "Октябрь".
    if month(seven.regdt) = 11 then seventable.month = "Ноябрь".
    if month(seven.regdt) = 12 then seventable.month = "Декабрь".
end.
def temp-table seventable1
    field month as char
    field kol   as inte.
def var n as inte.
def buffer b-seventable for seventable.
for each seventable no-lock break by seventable.month:
    if first-of(seventable.month) then do:
        n = 0.
        create seventable1.
        seventable1.month = seventable.month.
        for each b-seventable where b-seventable.month = seventable.month no-lock:
            n = n + 1.
        end.
        seventable1.kol = n.
    end.
end.
/*-----------------------------------------------------------------------------------------------------------------------------------------*/
def temp-table eighttable
    field month as char.
for each eight no-lock:
    create eighttable.
    if month(eight.regdt) = 1  then eighttable.month = "Январь".
    if month(eight.regdt) = 2  then eighttable.month = "Февраль".
    if month(eight.regdt) = 3  then eighttable.month = "Март".
    if month(eight.regdt) = 4  then eighttable.month = "Апрель".
    if month(eight.regdt) = 5  then eighttable.month = "Май".
    if month(eight.regdt) = 6  then eighttable.month = "Июнь".
    if month(eight.regdt) = 7  then eighttable.month = "Июль".
    if month(eight.regdt) = 8  then eighttable.month = "Август".
    if month(eight.regdt) = 9  then eighttable.month = "Сентябрь".
    if month(eight.regdt) = 10 then eighttable.month = "Октябрь".
    if month(eight.regdt) = 11 then eighttable.month = "Ноябрь".
    if month(eight.regdt) = 12 then eighttable.month = "Декабрь".
end.
def temp-table eighttable1
    field month as char
    field kol   as inte.
def buffer b-eighttable for eighttable.
def var r as inte.
for each eighttable no-lock break by eighttable.month:
    if first-of(eighttable.month) then do:
        r = 0.
        create eighttable1.
        eighttable1.month = eighttable.month.
        for each b-eighttable where b-eighttable.month = eighttable.month no-lock:
            r = r + 1.
        end.
        eighttable1.kol = r.
    end.
end.
/*------------------------------------------------------------------------------------------------------------------------------------------*/

def shared temp-table newtemp1
    field filial  as char
    field month   as char
    field one1    as inte
    field one2    as inte
    field one3    as inte
    field one4    as inte
    field oneitog as inte
    field two1    as inte
    field two2    as inte
    field two3    as inte
    field two4    as inte
    field two5    as inte
    field twoitog as inte
    field three1  as deci
    field three2  as deci
    field three3  as deci
    field three4  as deci
    field three5    as deci
    field threeitog as deci
    field four1     as deci
    field four2     as deci
    field four3     as deci
    field four4     as deci
    field four5     as deci
    field fouritog  as deci
    field five      as inte
    field six       as inte
    field seven     as inte
    field eight     as inte.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-bank = txb.sysc.chval.
else v-bank = "".
if v-bank = "TXB00" then v-bankname = "ЦО".
else if v-bank = "TXB01" then v-bankname = "Актобе".
else if v-bank = "TXB02" then v-bankname = "Кустанай".
else if v-bank = "TXB03" then v-bankname = "Тараз".
else if v-bank = "TXB04" then v-bankname = "Уральск".
else if v-bank = "TXB05" then v-bankname = "Караганда".
else if v-bank = "TXB06" then v-bankname = "Семей".
else if v-bank = "TXB07" then v-bankname = "Кокшетау".
else if v-bank = "TXB08" then v-bankname = "Астана".
else if v-bank = "TXB09" then v-bankname = "Павлодар".
else if v-bank = "TXB10" then v-bankname = "Петропавловск".
else if v-bank = "TXB11" then v-bankname = "Атырау".
else if v-bank = "TXB12" then v-bankname = "Актау".
else if v-bank = "TXB13" then v-bankname = "Жезказган".
else if v-bank = "TXB14" then v-bankname = "Усть-Каменогорск".
else if v-bank = "TXB15" then v-bankname = "Шымкент".
else if v-bank = "TXB16" then v-bankname = "Алматы".

def var mtname as char extent 12 init ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь',
'Ноябрь','Декабрь'].
def var q as inte init 1.
do q = 1 to month(p-date):
    create newtemp1.
    assign
    newtemp1.filial  = v-bankname.
    newtemp1.month   = mtname[q].
    find first onetable1 where trim(onetable1.month) = trim(mtname[q]) no-lock no-error.
    if avail onetable1 then do:
        assign
        newtemp1.one1    = onetable1.mic
        newtemp1.one2    = onetable1.sma
        newtemp1.one3    = onetable1.med
        newtemp1.one4    = onetable1.cor
        newtemp1.oneitog = onetable1.itog.
    end.
    else do:
        assign
        newtemp1.one1    = 0
        newtemp1.one2    = 0
        newtemp1.one3    = 0
        newtemp1.one4    = 0
        newtemp1.oneitog = 0.
    end.
    find first twotable2 where trim(twotable2.month) = trim(mtname[q]) no-lock no-error.
    if avail twotable2 then do:
        assign
        newtemp1.two1 = twotable2.val1
        newtemp1.two2 = twotable2.val2
        newtemp1.two3 = twotable2.val3
        newtemp1.two4 = twotable2.val4
        newtemp1.two5 = twotable2.val5
        newtemp1.twoitog = twotable2.itog.
    end.
    else do:
        assign
        newtemp1.two1 = 0
        newtemp1.two2 = 0
        newtemp1.two3 = 0
        newtemp1.two4 = 0
        newtemp1.two5 = 0
        newtemp1.twoitog = 0.
    end.
    find first threetable1 where trim(threetable1.month) = trim(mtname[q]) no-lock no-error.
    if avail threetable1 then do:
        assign
        newtemp1.three1 = threetable1.amt1
        newtemp1.three2 = threetable1.amt2
        newtemp1.three3 = threetable1.amt3
        newtemp1.three4 = threetable1.amt4
        newtemp1.three5 = threetable1.amt5
        newtemp1.threeitog = threetable1.itog.
    end.
    else do:
        assign
        newtemp1.three1 = 0
        newtemp1.three2 = 0
        newtemp1.three3 = 0
        newtemp1.three4 = 0
        newtemp1.three5 = 0
        newtemp1.threeitog = 0.
    end.
    find first fourtable1 where trim(fourtable1.month) = trim(mtname[q]) no-lock no-error.
    if avail fourtable1 then do:
        assign
        newtemp1.four1 = fourtable1.val1
        newtemp1.four2 = fourtable1.val2
        newtemp1.four3 = fourtable1.val3
        newtemp1.four4 = fourtable1.val4
        newtemp1.four5 = fourtable1.val5
        newtemp1.fouritog = fourtable1.itog.
    end.
    else do:
        assign
        newtemp1.four1 = 0
        newtemp1.four2 = 0
        newtemp1.four3 = 0
        newtemp1.four4 = 0
        newtemp1.four5 = 0
        newtemp1.fouritog = 0.
    end.
    find first fivetable2  where trim(fivetable2.month) = trim(mtname[q]) no-lock no-error.
    if avail fivetable2 then newtemp1.five = fivetable2.kol.
    else newtemp1.five = 0.
    find first sixtable1   where trim(sixtable1.month) = trim(mtname[q]) no-lock no-error.
    if avail sixtable1 then newtemp1.six = sixtable1.kol.
    else newtemp1.six = 0.
    find first seventable1 where trim(seventable1.month) = trim(mtname[q]) no-lock no-error.
    if avail seventable1 then newtemp1.seven = seventable1.kol.
    else newtemp1.seven = 0.
    find first eighttable1 where trim(eighttable1.month) = trim(mtname[q]) no-lock no-error.
    if avail eighttable1 then newtemp1.eight = eighttable1.kol.
    else newtemp1.eight = 0.
end.




