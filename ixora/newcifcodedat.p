/* newcifcodedat.p
 * MODULE
        Название модуля - Новые CIF коды с открытыми счетами.
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
def var v-sumcif  as deci no-undo.
def var v-sumgl   as deci no-undo.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

def shared temp-table newtemp
    field filial as char
    field summ   as deci decimals 2.

def temp-table cifaaa
    field cif    like txb.cif.cif
    field aaa    like txb.aaa.aaa.

v-dep = integer(trim(p-dep)).
def buffer b-cif  for txb.cif.

for each txb.cif where txb.cif.type = trim(p-type) and txb.cif.regdt >= p-dte and txb.cif.regdt <= p-dtb no-lock:
    find first txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock no-error.
    if avail txb.aaa then do:
        create cifaaa.
        assign
        cifaaa.cif    = txb.cif.cif
        cifaaa.aaa    = txb.aaa.aaa.
    end.
    hide message no-pause.
    message "Сбор данных - " LN[i] " " txb.cif.cif "БАЗА № - " p-bank.
    if i = 8 then i = 1.
    else i = i + 1.
end.

def buffer b-cifaaa for cifaaa.
def var k as inte init 0.
for each cifaaa no-lock break by cifaaa.cif:
    if first-of(cifaaa.cif) then do:
        k = k + 1.
    end.
end.
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
do:
    create newtemp.
    assign
    newtemp.filial = v-bankname
    newtemp.summ = k.
end.








