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
        --/--/2011 damir
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter p-bank  as char.
def input parameter p-dep   as char.
def input parameter p-dte   as date.
def input parameter p-dtb   as date.
def input parameter p-type  as char.

def var v-bank     as char.
def var v-bankname as char.
def var v-deptmp   as int no-undo.
def var v-name     as char.
def var v-dep      as int no-undo.
def var v-sumcif   as deci no-undo.
def var v-sumgl    as deci no-undo.
def var LN         as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i          as int init 1.
def var v-crc      as deci.
def var v-bal      as deci.
def var v-balrate  as deci.

def shared temp-table t-acc
    field filial  as char
    field cif     like txb.cif.cif
    field crc     like txb.crc.crc
    field summ    as deci decimals 2
    field rdt     as date
    field duedt   as date
    field monthdt as deci decimals 2
    field stavka% as deci decimals 2
    field nbrksum as deci decimals 2
    field type    as char.

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

for each txb.aaa where txb.aaa.regdt >= p-dte and txb.aaa.regdt <= p-dtb and txb.aaa.sta <> 'c' no-lock:
    find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr and (txb.lgr.led = 'tda' or txb.lgr.led = 'cda') no-lock no-error.
    if not avail txb.lgr then next. /* учитываем только tda -  деп.ф.л., cda - деп.ю.л.*/
    find first txb.cif where txb.cif.cif = txb.aaa.cif and txb.cif.type = trim(p-type) no-lock no-error.
    if avail txb.cif then do:
        find last txb.aab where txb.aab.fdt <= p-dtb and txb.aab.aaa = txb.aaa.aaa no-lock no-error. /*находим по ним остаток*/
        if not avail txb.aab then  /*... и не найден остаток*/
            v-bal = 0. /*txb.aaa.cbal. то остаток берем из самого счета*/
        else  /*если остаток есть, то сохраняем его*/
            v-bal = txb.aab.bal.
        if txb.aaa.crc <> 1 then do: /*если валюта счета не тенге*/
            find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt <= p-dtb no-lock no-error.
            v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9]. /*получаем остаток в тенге*/
        end.
        else do:
            v-balrate = v-bal.  /*иначе если тенге, то остаток в тенге = равен остаток по балансу */
        end.
        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
        create t-acc.
        assign
        t-acc.filial  = v-bankname
        t-acc.cif     = txb.cif.cif
        t-acc.crc     = txb.aaa.crc
        t-acc.summ    = v-bal
        t-acc.rdt     = txb.aaa.regdt.
        t-acc.duedt   = txb.aaa.expdt.
        t-acc.monthdt = int(t-acc.duedt - t-acc.rdt) / 30.
        assign
        t-acc.stavka% = txb.aaa.rate
        t-acc.nbrksum = v-balrate
        t-acc.type    = txb.lgr.des.
    end.
    hide message no-pause.
    message "Сбор данных - " LN[i] " " txb.aaa.aaa "БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.



