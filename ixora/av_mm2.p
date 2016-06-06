/* av_mm2.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет о средних остатках за месяц по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.21
 * AUTHOR
        06.12.2012 dmitriy
 * BASES
        COMM TXB
 * CHANGES
*/

def shared var s-dat1 as date no-undo format '99/99/9999'.
def shared var s-dat2 as date no-undo format '99/99/9999'.
def shared var v-rep1 as logi.
def shared var v-rep2 as logi.

def shared var v-total as int extent 7 init
[199995, 299990, 399990, 499900, 599990, 699990, 799990].

define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.

def shared temp-table wrk
    field br  as int
    field dt  as date
    field gl  as int
    field gl4 as char
    field bal as deci
    field crc as int
    field skv as int
    field tot as logi
    field totlev as int
    field totgl as int
    field des as char
    index gl4 gl4.

def var dt as date.
def var mm as int.
def var yy as int.
def var ndays as int.
def var i  as int.
def var j  as int.
def var day-sum as deci.
def var br-code as int.
def var v-gl4 as char.
def var v-inc as logi.
def buffer b-gl for txb.gl.
def var v-skv as int.

find first txb.cmp no-lock no-error.
if avail txb.cmp then br-code = txb.cmp.code.

message "Сбор данных : " + txb.cmp.name.


mm = month(s-dat1).
yy = year(s-dat1).

ndays = (s-dat2 - s-dat1) + 1.

dt = s-dat1.

do i = 1 to ndays:
    for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl < 800000 no-lock break by txb.gl.gl:
        if txb.gl.gl <> 599980 then do:
        v-gl4 = substr(string(txb.gl.gl), 1, 4).
        for each txb.crc no-lock:
            find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt <= dt and txb.glday.crc = txb.crc.crc no-lock no-error.
            if avail txb.glday then do:
                find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= dt no-lock no-error.
                if avail txb.crchis then day-sum = txb.glday.bal * txb.crchis.rate[1].

                if txb.crc.crc = 1 then v-skv = 1.
                else if txb.crc.crc <> 1 and txb.crc.crc <> 4 and txb.crc.crc <> 5 then v-skv = 3.
                else v-skv = 2.


                create wrk.
                wrk.br = br-code.
                wrk.dt = dt.
                wrk.gl = txb.gl.gl.
                wrk.des = txb.gl.des.
                wrk.gl4 = v-gl4.
                wrk.crc = txb.glday.crc.
                wrk.skv = v-skv.
                wrk.bal = day-sum.
                wrk.tot = txb.gl.totact.
                wrk.totlev = txb.gl.totlev.
                wrk.totgl = txb.gl.totgl.

                day-sum = 0.
            end.
        end.
        end.
    end.
    dt = dt + 1.
end.

dt = s-dat1.
do j = 1 to ndays:
    do i = 1 to 7:
        for each txb.crc no-lock:
            find last txb.glday where txb.glday.gl = v-total[i] and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= dt no-lock no-error.
            if avail txb.glday then do:
                find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= dt no-lock no-error.
                if avail txb.crchis then day-sum = txb.glday.bal * txb.crchis.rate[1].

                create wrk.
                wrk.br = br-code.
                wrk.dt = dt.
                wrk.gl = txb.glday.gl.
                wrk.des = txb.gl.des.
                wrk.crc = txb.glday.crc.
                wrk.skv = v-skv.
                wrk.bal = day-sum.
            end.
        end.
    end.
    if v-rep2 = yes then run av_mm2_pril(dt).
    dt = dt + 1.
end.

message "". pause 0.
