/* rpvoz.p
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
        03.03.2011
 * BASES
        BANK TXB
 * CHANGES
        11.03.2011 убрал счет из наименования клиента
        29.02.2012 Lyubov - включила счета ГК 521910,522300,522910
*/

def input parameter dt1 as date.
def input parameter dt2 as date.
def var summa as deci no-undo.
def var summa1 as deci no-undo.
def var summa2 as deci no-undo.

def shared temp-table t-data
    field bank as char
    field voz_sum as deci
    field nname as char
    field rrn as char
    field bin as char
    field geo as char
    field t-branch as char
    field priznak as char init "НЕТ"
    index idx is primary bank nname.

function konv2kzt returns decimal (p-sum as decimal, p-crc as integer, p-date as date).
    def var vp-sum as decimal.
    if p-crc = 1 then vp-sum = p-sum.
    else do:
        find last txb.crchis where txb.crchis.crc = p-crc and txb.ncrchis.rdt <= p-date no-lock no-error.
        if avail txb.crchis then vp-sum = p-sum * txb.crchis.rate[1].
    end.
    return vp-sum.
end.



def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-city as char no-undo.
if s-ourbank = "txb00" then v-city = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-city = entry(1, txb.cmp.addr[1],",").
end.

for each txb.aaa /*where txb.aaa.aaa = "KZ73470392207A232616"*/ no-lock:
        summa = 0.
        find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled = 'cif' and txb.trxlevgl.level = 11 no-lock no-error.
        if not avail txb.trxlevgl then next.
        if txb.trxlevgl.glr <> 521750 and txb.trxlevgl.glr <> 521710 and txb.trxlevgl.glr <> 521550 and txb.trxlevgl.glr <> 521510 and txb.trxlevgl.glr <> 521910 and txb.trxlevgl.glr <> 522300 and txb.trxlevgl.glr <> 522910 then next.

        if day(dt1) = 1 and month(dt1) = 1 then summa1 = 0.
        else run lonbalcrc_txb('cif',txb.aaa.aaa,dt1,"11",no,1,output summa1).
        run lonbalcrc_txb('cif',txb.aaa.aaa,dt2,"11",yes,1,output summa2).

        summa = summa2 - summa1.

        if summa <> 0 then do:
            create t-data.
            t-data.bank = s-ourbank.
            t-data.t-branch = v-city.
            t-data.voz_sum = summa.
            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            if avail txb.cif then
            assign t-data.nname = txb.cif.prefix + " " + txb.cif.name
                   t-data.rrn = txb.cif.jss
                   t-data.bin = txb.cif.bin
                   t-data.geo = txb.cif.geo.
             find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.ccode = "01" no-lock no-error.
             if avail txb.sub-cod then t-data.priznak = "ДА".
        end.
end.
