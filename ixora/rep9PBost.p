/* rep9PBost.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет о состоянии финансовых требований к нерезидентам и обязательств перед ними
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
        28/12/2012 Luiza
 * BASES
        BANK
 * CHANGES
*/


def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.
def shared var v-select1 as int no-undo.

/* таблицы для расшифровки  */
/* обороты */
define shared temp-table t-salde no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field dt as decimal
    field dttng as decimal
    field dtus as decimal
    field ct as decimal
    field cttng as decimal
    field ctus as decimal
    field rdt as date
    field rate as decimal
    field rateus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field jh as int
    field dc as char
    field ln as int
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb jh
    INDEX indwrk wrk num.

/* остатки */
define shared temp-table t-ost no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field b as decimal
    field btng as decimal
    field bus as decimal
    field e as decimal
    field etng as decimal
    field eus as decimal
    field rateb as decimal
    field ratebus as decimal
    field ratee as decimal
    field rateeus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb
    INDEX indwrk wrk num.

/* доходы-расходы */
define shared temp-table t-income no-undo
    field num as char
    field num1 as char
    field num2 as char
    field oper as char
    field oper1 as char
    field oper2  as char
    field gl as int
    field dt7 as int
    field ct7 as int
    field jh as int
    field rdt as date
    field name as char
    field dtacc as char
    field ctacc as char
    field sum1 as decimal   /* остаток на начало */
    field sumus1 as decimal
    field rateus1 as decimal
    field sumdt as decimal   /* обороты дебет */
    field sumusdt as decimal
    field rateus as decimal
    field sumct as decimal   /* обороты кредит */
    field sumusct as decimal
    field sum2 as decimal    /* остаток на конец */
    field sumus2 as decimal
    field rateus2 as decimal
    field rem as char
    field country as char
    field cng as char
    field txb as char
    field txbname as char
    field wrk as char
    field crc as int
    index ind is primary oper.


/* основные таблицы */
define shared temp-table wgl no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field num as char
    field wrk as char
    field df as char
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.

define shared temp-table wrk1 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

define shared temp-table wrk2 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field crc as int
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

define shared temp-table wrk3 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field crc as int
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk4 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk5 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk6 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk7 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk8 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

define shared temp-table wrk9 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".


define shared temp-table wrk10 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk15 no-undo /*Раздел I. Требования к  нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk16 no-undo /*Раздел II. Обязательства  банка перед нерезидентами*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk17 no-undo /* Поступления от нерезидентов*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk18 no-undo /*Платежи нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk11 no-undo /*Раздел I. Требования к  нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk12 no-undo /* Раздел II. Обязательства  банка перед нерезидентами  */
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk13 no-undo /* Поступления от нерезидентов*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

    define shared temp-table wrk14 no-undo /* Платежи нерезидентам */
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

def var lst as char no-undo.
def var v-grp as char no-undo.
def var i as int no-undo.

define shared temp-table sootv no-undo
    field sng as char
    field ru as char
    field kz as char
    index idx  kz.

function sngru returns char(sub as char, cod as char,lst as char).
    for each sootv where sootv.kz = cod.
        if lst = "" then if sub = "sng" then lst = sootv.sng. else lst = sootv.ru.
        else do:
            if sub = "sng" then  if LOOKUP( sootv.sng, lst ) = 0 then lst = lst + "," + sootv.sng.
            if sub = "ru" then   if LOOKUP( sootv.ru, lst ) = 0 then lst = lst + "," + sootv.ru.
        end.
    end.
    return lst.
end.


for each wrk1.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk1" and t-ost.num = wrk1.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk1.sum[1] = wrk1.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk1.sum[8] = wrk1.sum[8] + t-ost.eus. /* остаток на конец  */
        end.
        else do:  /* по вознаграждению */
            wrk1.sum[9] = wrk1.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk1.sum[12] = wrk1.sum[12] + t-ost.eus. /* остаток на конец  */
        end.
        t-ost.num1 = sngru("sng",wrk1.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk1.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk1" and t-salde.num = wrk1.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk1.sum[2] = wrk1.sum[2] + t-salde.dtus. /* 'поступило  */
            wrk1.sum[3] = wrk1.sum[3] + t-salde.ctus. /* 'списано  */
            wrk1.sum[4] = wrk1.sum[2] - wrk1.sum[3].
            wrk1.sum[6] = wrk1.sum[8] - wrk1.sum[1] - wrk1.sum[4].

        end.
        else do:  /* по вознаграждению */
            wrk1.sum[10] = wrk1.sum[10] + t-salde.dtus. /* начислено  */
            wrk1.sum[11] = wrk1.sum[11] + t-salde.ctus. /* оплачено  */
        end.
        t-salde.num1 = sngru("sng",wrk1.num,t-salde.num).
        t-salde.num2 = sngru("ru",wrk1.num,t-salde.num2).
    end.  /* for each t-salde  */

end.

for each wrk3.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk3" and t-ost.num = wrk3.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk3.sum[1] = wrk3.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk3.sum[8] = wrk3.sum[8] + t-ost.eus. /* остаток на конец  */
        end.
        else do:  /* по вознаграждению */
            wrk3.sum[9] = wrk3.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk3.sum[12] = wrk3.sum[12] + t-ost.eus. /* остаток на конец  */
        end.
        t-ost.num1 = sngru("sng",wrk3.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk3.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk3" and t-salde.num = wrk3.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk3.sum[2] = wrk3.sum[2] + t-salde.dtus. /* 'поступило  */
            wrk3.sum[3] = wrk3.sum[3] + t-salde.ctus. /* 'списано  */
            wrk3.sum[4] = wrk3.sum[2] - wrk3.sum[3].
            wrk3.sum[6] = wrk3.sum[8] - wrk3.sum[1] - wrk3.sum[4].
        end.
        else do:  /* по вознаграждению */
            wrk3.sum[10] = wrk3.sum[10] + t-salde.dtus. /* начислено  */
            wrk3.sum[11] = wrk3.sum[11] + t-salde.ctus. /* оплачено  */
        end.
        t-salde.num1 = sngru("sng",wrk3.num,t-salde.num1).
        t-salde.num2 = sngru("ru",wrk3.num,t-salde.num2).
    end.  /* for each t-salde  */
end.

for each wrk5.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk5" and t-ost.num = wrk5.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk5.sum[1] = wrk5.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk5.sum[8] = wrk5.sum[8] + t-ost.eus. /* остаток на конец  */
        end.
        else do:  /* по вознаграждению */
            wrk5.sum[9] = wrk5.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk5.sum[12] = wrk5.sum[12] + t-ost.eus. /* остаток на конец  */
        end.
        t-ost.num1 = sngru("sng",wrk5.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk5.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk5" and t-salde.num = wrk5.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk5.sum[2] = wrk5.sum[2] + t-salde.dtus. /* 'поступило  */
            wrk5.sum[3] = wrk5.sum[3] + t-salde.ctus. /* 'списано  */
            wrk5.sum[4] = wrk5.sum[2] - wrk5.sum[3].
            wrk5.sum[6] = wrk5.sum[8] - wrk5.sum[1] - wrk5.sum[4].
        end.
        else do:  /* по вознаграждению */
            wrk5.sum[10] = wrk5.sum[10] + t-salde.dtus. /* начислено  */
            wrk5.sum[11] = wrk5.sum[11] + t-salde.ctus. /* оплачено  */
        end.
        t-salde.num1 = sngru("sng",wrk5.num,t-salde.num1).
        t-salde.num2 = sngru("ru",wrk5.num,t-salde.num2).
    end.  /* for each t-salde  */
end.

define buffer bwrk6 for wrk6.
for each wrk6.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk6" and t-ost.num = wrk6.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk6.sum[1] = wrk6.sum[1] + t-ost.bus.
            wrk6.sum[8] = wrk6.sum[8] + t-ost.eus.
            if wrk6.num = "251" or wrk6.num = "253" or wrk6.num = "255" then do:
                find first bwrk6 where bwrk6.num = "250" no-error.
                bwrk6.sum[1] = bwrk6.sum[1] + t-ost.bus.
                bwrk6.sum[8] = bwrk6.sum[8] + t-ost.eus.
            end.
            if wrk6.num = "261" or wrk6.num = "263" or wrk6.num = "267" then do:
                find first bwrk6 where bwrk6.num = "260" no-error.
                bwrk6.sum[1] = bwrk6.sum[1] + t-ost.bus.
                bwrk6.sum[8] = bwrk6.sum[8] + t-ost.eus.
            end.
            if wrk6.num = "271" or wrk6.num = "273" or wrk6.num = "272" then do:
                find first bwrk6 where bwrk6.num = "270" no-error.
                bwrk6.sum[1] = bwrk6.sum[1] + t-ost.bus.
                bwrk6.sum[8] = bwrk6.sum[8] + t-ost.eus.
            end.
        end.
        else do:  /* по вознаграждению */
            wrk6.sum[9] = wrk6.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk6.sum[12] = wrk6.sum[12] + t-ost.eus. /* остаток на конец  */
            if wrk6.num = "251" or wrk6.num = "253" or wrk6.num = "255" then do:
                find first bwrk6 where bwrk6.num = "250" no-error.
                bwrk6.sum[9] = bwrk6.sum[9] + t-ost.bus. /* остаток на начало  */
                bwrk6.sum[12] = bwrk6.sum[12] + t-ost.eus. /* остаток на конец  */
            end.
            if wrk6.num = "261" or wrk6.num = "263" or wrk6.num = "267" then do:
                find first bwrk6 where bwrk6.num = "260" no-error.
                bwrk6.sum[9] = bwrk6.sum[9] + t-ost.bus. /* остаток на начало  */
                bwrk6.sum[12] = bwrk6.sum[12] + t-ost.eus. /* остаток на конец  */
            end.
            if wrk6.num = "271" or wrk6.num = "273" or wrk6.num = "272" then do:
                find first bwrk6 where bwrk6.num = "270" no-error.
                bwrk6.sum[9] = bwrk6.sum[9] + t-ost.bus. /* остаток на начало  */
                bwrk6.sum[12] = bwrk6.sum[12] + t-ost.eus. /* остаток на конец  */
            end.
        end.
        t-ost.num1 = sngru("sng",wrk6.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk6.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk6" and t-salde.num = wrk6.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk6.sum[2] = wrk6.sum[2] + t-salde.ctus. /* 'поступило  */
            wrk6.sum[3] = wrk6.sum[3] + t-salde.dtus. /* 'списано  */
            wrk6.sum[4] = wrk6.sum[2] - wrk6.sum[3].
            wrk6.sum[6] = wrk6.sum[8] - wrk6.sum[1] - wrk6.sum[4].
            if wrk6.num = "251" or wrk6.num = "253" or wrk6.num = "255" then do:
                find first bwrk6 where bwrk6.num = "250" no-error.
                bwrk6.sum[2] = bwrk6.sum[2] + t-salde.ctus. /* 'поступило  */
                bwrk6.sum[3] = bwrk6.sum[3] + t-salde.dtus. /* 'списано  */
                bwrk6.sum[4] = bwrk6.sum[2] - bwrk6.sum[3].
                bwrk6.sum[6] = bwrk6.sum[8] - bwrk6.sum[1] - bwrk6.sum[4].
            end.
            if wrk6.num = "261" or wrk6.num = "263" or wrk6.num = "267" then do:
                find first bwrk6 where bwrk6.num = "260" no-error.
                bwrk6.sum[2] = bwrk6.sum[2] + t-salde.ctus. /* 'поступило  */
                bwrk6.sum[3] = bwrk6.sum[3] + t-salde.dtus. /* 'списано  */
                bwrk6.sum[4] = bwrk6.sum[2] - bwrk6.sum[3].
                bwrk6.sum[6] = bwrk6.sum[8] - bwrk6.sum[1] - bwrk6.sum[4].
            end.
            if wrk6.num = "271" or wrk6.num = "273" or wrk6.num = "272" then do:
                find first bwrk6 where bwrk6.num = "270" no-error.
                bwrk6.sum[2] = bwrk6.sum[2] + t-salde.ctus. /* 'поступило  */
                bwrk6.sum[3] = bwrk6.sum[3] + t-salde.dtus. /* 'списано  */
                bwrk6.sum[4] = bwrk6.sum[2] - bwrk6.sum[3].
                bwrk6.sum[6] = bwrk6.sum[8] - bwrk6.sum[1] - bwrk6.sum[4].
            end.
        end.
        else do:  /* по вознаграждению */
            wrk6.sum[10] = wrk6.sum[10] + t-salde.dtus. /* начислено  */
            wrk6.sum[11] = wrk6.sum[11] + t-salde.ctus. /* оплачено  */
            if wrk6.num = "251" or wrk6.num = "253" or wrk6.num = "255" then do:
                find first bwrk6 where bwrk6.num = "250" no-error.
                bwrk6.sum[10] = bwrk6.sum[10] + t-salde.dtus. /* начислено  */
                bwrk6.sum[11] = bwrk6.sum[11] + t-salde.ctus. /* оплачено  */
            end.
            if wrk6.num = "261" or wrk6.num = "263" or wrk6.num = "267" then do:
                find first bwrk6 where bwrk6.num = "260" no-error.
                bwrk6.sum[10] = bwrk6.sum[10] + t-salde.dtus. /* начислено  */
                bwrk6.sum[11] = bwrk6.sum[11] + t-salde.ctus. /* оплачено  */
            end.
            if wrk6.num = "271" or wrk6.num = "273" or wrk6.num = "272" then do:
                find first bwrk6 where bwrk6.num = "270" no-error.
                bwrk6.sum[10] = bwrk6.sum[10] + t-salde.dtus. /* начислено  */
                bwrk6.sum[11] = bwrk6.sum[11] + t-salde.ctus. /* оплачено  */
            end.
        end.
        t-salde.num1 = sngru("sng",wrk6.num,t-salde.num1).
        t-salde.num2 = sngru("ru",wrk6.num,t-salde.num2).
    end.  /* for each t-salde  */
end.

for each wrk8.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk8" and t-ost.num = wrk8.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk8.sum[1] = wrk8.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk8.sum[8] = wrk8.sum[8] + t-ost.eus. /* остаток на конец  */
        end.
        else do:  /* по вознаграждению */
            wrk8.sum[9] = wrk8.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk8.sum[12] = wrk8.sum[12] + t-ost.eus. /* остаток на конец  */
        end.
        t-ost.num1 = sngru("sng",wrk8.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk8.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk8" and t-salde.num = wrk8.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk8.sum[2] = wrk8.sum[2] + t-salde.ctus. /* 'поступило  */
            wrk8.sum[3] = wrk8.sum[3] + t-salde.dtus. /* 'списано  */
            wrk8.sum[4] = wrk8.sum[2] - wrk8.sum[3].
            wrk8.sum[6] = wrk8.sum[8] - wrk8.sum[1] - wrk8.sum[4].
        end.
        else do:  /* по вознаграждению */
            wrk8.sum[10] = wrk8.sum[10] + t-salde.dtus. /* начислено  */
            wrk8.sum[11] = wrk8.sum[11] + t-salde.ctus. /* оплачено  */
        end.
        t-salde.num1 = sngru("sng",wrk8.num,t-salde.num1).
        t-salde.num2 = sngru("ru",wrk8.num,t-salde.num2).
    end.  /* for each t-salde  */
end.

for each wrk9.
    /* остатки */
    for each t-ost where t-ost.wrk = "wrk9" and t-ost.num = wrk9.num use-index indwrk no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk9.sum[1] = wrk9.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk9.sum[8] = wrk9.sum[8] + t-ost.eus. /* остаток на конец  */
        end.
        else do:  /* по вознаграждению */
            wrk9.sum[9] = wrk9.sum[9] + t-ost.bus. /* остаток на начало  */
            wrk9.sum[12] = wrk9.sum[12] + t-ost.eus. /* остаток на конец  */
        end.
        t-ost.num1 = sngru("sng",wrk9.num,t-ost.num1).
        t-ost.num2 = sngru("ru",wrk9.num,t-ost.num2).
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.wrk = "wrk9" and t-salde.num = wrk9.num use-index indwrk no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk9.sum[2] = wrk9.sum[2] + t-salde.dtus. /* 'поступило  */
            wrk9.sum[3] = wrk9.sum[3] + t-salde.dtus. /* 'списано  */
            wrk9.sum[4] = wrk9.sum[2] - wrk9.sum[3].
            wrk9.sum[6] = wrk9.sum[8] - wrk9.sum[1] - wrk9.sum[4].
        end.
        else do:  /* по вознаграждению */
            wrk9.sum[10] = wrk9.sum[10] + t-salde.dtus. /* начислено  */
            wrk9.sum[11] = wrk9.sum[11] + t-salde.ctus. /* оплачено  */
        end.
        t-salde.num1 = sngru("sng",wrk9.num,t-salde.num1).
        t-salde.num2 = sngru("ru",wrk9.num,t-salde.num2).
    end.  /* for each t-salde  */
end.
/* комиссии */
for each t-income .
    find first wrk10 where wrk10.num = t-income.oper no-error.
    if available wrk10 then do:
        wrk10.sum = wrk10.sum + t-income.sumusdt + t-income.sumusct.
    end.
end.

def buffer bwrk10 for wrk10.
def buffer bwrk16 for wrk16.
def buffer bwrk12 for wrk12.


/* собираем суммы для Поступления от нерезидентов */
find first bwrk10 where bwrk10.num = "470" no-error.
if available bwrk10 then do:
    for each wrk10 where int(wrk10.num) >= 470  and int(wrk10.num) < 480.
        bwrk10.sum =  bwrk10.sum + wrk10.sum.
    end.
end.
/* собираем суммы  платежей нерезидентам */
find first bwrk10 where bwrk10.num = "480" no-error.
if available bwrk10 then do:
    for each wrk10 where int(wrk10.num) >= 480  and int(wrk10.num) <= 487.
        bwrk10.sum =  bwrk10.sum + wrk10.sum.
    end.
end.
/*----------------------------------------------------------------------------------------------*/
/* для СНГ  */
for each wrk15.
    /* остатки */
    for each t-ost where t-ost.num = wrk15.numo and (t-ost.cng = "cng" or t-ost.cng = "ru")  no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk15.sum[1] = wrk15.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk15.sum[6] = wrk15.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.num = wrk15.numo and (t-salde.cng = "SNG" or t-salde.cng = "RU")  no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk15.sum[2] = wrk15.sum[2] + t-salde.dtus - t-salde.ctus.
            wrk15.sum[4] = wrk15.sum[6] - wrk15.sum[1] - wrk15.sum[2] + wrk15.sum[3].
        end.
    end.  /* for each t-salde  */
    /* стобец 7 */
    for each t-income where t-income.num = wrk15.numo and (t-income.cng = "SNG" or t-income.cng = "RU") no-lock.
        wrk15.sum[7] = wrk15.sum[7] + t-income.sumus2. /* Расходы/ доходы начисленные за период  */
    end.
end.

for each wrk16.
    /* остатки */
    for each t-ost where t-ost.num = wrk16.numo and (t-ost.cng = "SNG" or t-ost.cng = "RU")  no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk16.sum[1] = wrk16.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk16.sum[6] = wrk16.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
        if wrk16.num = "601" or wrk16.num = "603" then do:
            find first bwrk16 where bwrk16.num = "600" no-error.
            bwrk16.sum[1] = bwrk16.sum[1] + t-ost.bus. /* остаток на начало  */
            bwrk16.sum[6] = bwrk16.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
        if wrk16.num = "611" or wrk16.num = "612"  or wrk16.num = "613" then do:
            find first bwrk16 where bwrk16.num = "610" no-error.
            bwrk16.sum[1] = bwrk16.sum[1] + t-ost.bus. /* остаток на начало  */
            bwrk16.sum[6] = bwrk16.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.num = wrk16.numo and (t-salde.cng = "SNG" or t-salde.cng = "RU")  no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk16.sum[2] = wrk16.sum[2] + t-salde.dtus - t-salde.ctus.
            wrk16.sum[4] = wrk16.sum[6] - wrk16.sum[1] - wrk16.sum[2] + wrk16.sum[3].
        end.
        if wrk16.num = "601" or wrk16.num = "603" then do:
            find first bwrk16 where bwrk16.num = "600" no-error.
            bwrk16.sum[2] = bwrk16.sum[2] + t-salde.dtus - t-salde.ctus.
            bwrk16.sum[4] = bwrk16.sum[6] - bwrk16.sum[1] - bwrk16.sum[2] + bwrk16.sum[3].
        end.
        if wrk16.num = "611" or wrk16.num = "612"  or wrk16.num = "613" then do:
            find first bwrk16 where bwrk16.num = "610" no-error.
            bwrk16.sum[2] = bwrk16.sum[2] + t-salde.dtus - t-salde.ctus.
            bwrk16.sum[4] = bwrk16.sum[6] - bwrk16.sum[1] - bwrk16.sum[2] + bwrk16.sum[3].
        end.
    end.  /* for each t-salde  */
    for each t-income where t-income.num = wrk16.numo and (t-income.cng = "SNG" or t-income.cng = "RU") no-lock.
        wrk16.sum[7] = wrk16.sum[7] + t-income.sumus2. /* Расходы/ доходы начисленные за период  */
    end.
end.

for each wrk17.
    for each t-income where t-income.oper = wrk17.numo and (t-income.cng = "SNG" or t-income.cng = "RU").
        wrk17.sum = wrk17.sum + t-income.sumus2.
        if t-income.oper1 = "" then t-income.oper1 = wrk17.num.
        else t-income.oper1 = t-income.oper1 + "," + wrk17.num.
    end.
end.
for each wrk18.
    for each t-income where t-income.oper = wrk18.numo and (t-income.cng = "SNG" or t-income.cng = "RU").
        wrk18.sum = wrk18.sum + t-income.sumus2.
        if t-income.oper1 = "" then t-income.oper1 = wrk18.num.
        else t-income.oper1 = t-income.oper1 + "," + wrk18.num.
    end.
end.
/*-----------------------------------------------------------------------------------------*/
/* для России */
for each wrk11.
    /* остатки */
    for each t-ost where t-ost.num = wrk11.numo and  t-ost.cng = "ru"  no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk11.sum[1] = wrk11.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk11.sum[6] = wrk11.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where  t-salde.num = wrk11.numo and  t-salde.cng = "RU"  no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk11.sum[2] = wrk11.sum[2] + t-salde.dtus - t-salde.ctus.
            wrk11.sum[4] = wrk11.sum[6] - wrk11.sum[1] - wrk11.sum[2] + wrk11.sum[3].
        end.
    end.  /* for each t-salde  */
    /* стобец 7 */
    for each t-income where t-income.num = wrk11.numo and t-income.cng = "RU" no-lock.
        wrk11.sum[7] = wrk11.sum[7] + t-income.sumus2. /* Расходы/ доходы начисленные за период  */
    end.
end.

for each wrk12.
    /* остатки */
    for each t-ost where t-ost.num = wrk12.numo and  t-ost.cng = "RU"  no-lock:
        if t-ost.df = "d" then do: /* по долгу */
            wrk12.sum[1] = wrk12.sum[1] + t-ost.bus. /* остаток на начало  */
            wrk12.sum[6] = wrk12.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
        if wrk12.num = "891" or wrk12.num = "893" then do:
            find first bwrk12 where bwrk12.num = "890" no-error.
            bwrk12.sum[1] = bwrk12.sum[1] + t-ost.bus. /* остаток на начало  */
            bwrk12.sum[6] = bwrk12.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
        if wrk12.num = "901" or wrk12.num = "902"  or wrk12.num = "903" then do:
            find first bwrk12 where bwrk12.num = "900" no-error.
            bwrk12.sum[1] = bwrk12.sum[1] + t-ost.bus. /* остаток на начало  */
            bwrk12.sum[6] = bwrk12.sum[6] + t-ost.eus. /* остаток на конец  */
        end.
    end.  /* for each t-ost  */

    /* обороты */
    for each t-salde where t-salde.num = wrk12.numo and  t-salde.cng = "RU"  no-lock:
        if t-salde.df = "d" then do: /* по долгу */
            wrk12.sum[2] = wrk12.sum[2] + t-salde.dtus - t-salde.ctus.
            wrk12.sum[4] = wrk12.sum[6] - wrk12.sum[1] - wrk12.sum[2] + wrk12.sum[3].
        end.
        if wrk12.num = "891" or wrk12.num = "893" then do:
            find first bwrk12 where bwrk12.num = "890" no-error.
            bwrk12.sum[2] = bwrk12.sum[2] + t-salde.dtus - t-salde.ctus.
            bwrk12.sum[4] = bwrk12.sum[6] - bwrk12.sum[1] - bwrk12.sum[2] + bwrk12.sum[3].
        end.
        if wrk12.num = "901" or wrk12.num = "902"  or wrk12.num = "903" then do:
            find first bwrk12 where bwrk12.num = "900" no-error.
            bwrk12.sum[2] = bwrk12.sum[2] + t-salde.dtus - t-salde.ctus.
            bwrk12.sum[4] = bwrk12.sum[6] - bwrk12.sum[1] - bwrk12.sum[2] + bwrk12.sum[3].
        end.
    end.  /* for each t-salde  */

    /* стобец 7 */
    for each t-income where t-income.num = wrk12.numo and t-income.cng = "RU" no-lock.
        wrk12.sum[7] = wrk12.sum[7] + t-income.sumus2. /* Расходы/ доходы начисленные за период  */
    end.
end.


for each wrk13.
    for each t-income where t-income.oper = wrk13.numo and  t-income.cng = "RU".
        wrk13.sum = wrk13.sum + t-income.sumus2.
        if t-income.oper2 = "" then t-income.oper2 = wrk13.num.
        else t-income.oper2 = t-income.oper2 + "," + wrk13.num.
    end.
end.
for each wrk14.
    for each t-income where t-income.oper = wrk14.numo and  t-income.cng = "RU".
        wrk14.sum = wrk14.sum + t-income.sumus2.
        if t-income.oper2 = "" then t-income.oper2 = wrk14.num.
        else t-income.oper2 = t-income.oper2 + "," + wrk14.num.
    end.
end.
/*-----------------------------------------------------------------------------------------*/
/* проставим шифры для t-income */
for each t-income.
    t-income.num1 = sngru("sng",t-income.num,t-income.num1).
    t-income.num2 = sngru("ru",t-income.num,t-income.num2).
end.

/* в тыс дол США */
if v-select1 = 1 then do:
    for each wrk1.
        i = 1.
        do while i <= 12 :
            if wrk1.sum[i] <> 0 then if wrk1.sum[i] < 1000 then wrk1.sum[i] = 1. else wrk1.sum[i] = round((wrk1.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk3.
        i = 1.
        do while i <= 12 :
            if wrk3.sum[i] <> 0 then if wrk3.sum[i] < 1000 then wrk3.sum[i] = 1. else wrk3.sum[i] = round((wrk3.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk5.
        i = 1.
        do while i <= 12 :
            if wrk5.sum[i] <> 0 then if wrk5.sum[i] < 1000 then wrk5.sum[i] = 1. else wrk5.sum[i] = round((wrk5.sum[i] / 1000),0).

            i = i + 1.

        end.
    end.
    for each wrk6.
        i = 1.
        do while i <= 12 :
            if wrk6.sum[i] <> 0 then if wrk6.sum[i] < 1000 then wrk6.sum[i] = 1. else wrk6.sum[i] = round((wrk6.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk8.
        i = 1.
        do while i <= 12 :
            if wrk8.sum[i] <> 0 then if wrk8.sum[i] < 1000 then wrk8.sum[i] = 1. else wrk8.sum[i] = round((wrk8.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk9.
        i = 1.
        do while i <= 12 :
            if wrk9.sum[i] <> 0 then if wrk9.sum[i] < 1000 then wrk9.sum[i] = 1. else wrk9.sum[i] = round((wrk9.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk10.
        if wrk10.sum <> 0 then if wrk10.sum < 1000 then wrk10.sum = 1. else wrk10.sum = round((wrk10.sum / 1000),0).

    end.
    for each wrk11.
        i = 1.
        do while i <= 7 :
            if wrk11.sum[i] <> 0 then if wrk11.sum[i] < 1000 then wrk11.sum[i] = 1. else wrk11.sum[i] = round((wrk11.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk12.
        i = 1.
        do while i <= 7 :
            if wrk12.sum[i] <> 0 then if wrk12.sum[i] < 1000 then wrk12.sum[i] = 1. else wrk12.sum[i] = round((wrk12.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk13.
        if wrk13.sum <> 0 then if wrk13.sum < 1000 then wrk13.sum = 1. else wrk13.sum = round((wrk13.sum / 1000),0).

    end.
    for each wrk14.
        if wrk14.sum <> 0 then if wrk14.sum < 1000 then wrk14.sum = 1. else wrk14.sum = round((wrk14.sum / 1000),0).

    end.
    for each wrk15.
        i = 1.
        do while i <= 7 :
            if wrk15.sum[i] <> 0 then if wrk15.sum[i] < 1000 then wrk15.sum[i] = 1. else wrk15.sum[i] = round((wrk15.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk16.
        i = 1.
        do while i <= 7 :
            if wrk16.sum[i] <> 0 then if wrk16.sum[i] < 1000 then wrk16.sum[i] = 1. else wrk16.sum[i] = round((wrk16.sum[i] / 1000),0).

            i = i + 1.
        end.
    end.
    for each wrk17.
        if wrk17.sum <> 0 then if wrk17.sum < 1000 then wrk17.sum = 1. else wrk17.sum = round((wrk17.sum / 1000),0).

    end.
    for each wrk18.
        if wrk18.sum <> 0 then if wrk18.sum < 1000 then wrk18.sum = 1. else wrk18.sum = round((wrk18.sum / 1000),0).

    end.
end.