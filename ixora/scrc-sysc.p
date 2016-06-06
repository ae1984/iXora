/* scrc-sysc.p
 * MODULE
        Казначейство
 * DESCRIPTION
        Установка опорных курсов
 * RUN
        7-3-6
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14.03.2011 aigul
 * BASES
        BANK TXB
 * CHANGES
        08.08.2011 aigul - добавила запсиь в sysc.sysc= "scrc-order"
        09.08.2011 aigul - recompile
*/
def input parameter p-crc as int.

def var d as char format "x(50)".
/*
def var c as char.
def var p-crc as int initial 2.
c = "2-0, 3-0, 4-0".
if index(c,string(p-crc)) > 0 then do:
    d = substr(c,index(c,string(p-crc)),3).
    c = REPLACE(c, d, substr(d,1,1) + "-1").
end.
displ d c format "x(20)".
*/
find txb.sysc where txb.sysc.sysc = "SCRC" exclusive-lock.
    txb.sysc.daval = today.
    /*txb.sysc.loval = yes.*/
    if index(txb.sysc.chval, string(p-crc)) > 0 then do:
        d = substr(txb.sysc.chval, index(txb.sysc.chval, string(p-crc)), 3).
        txb.sysc.chval  = REPLACE(txb.sysc.chval , d, substr(d,1,1) + "-1").
    end.
find txb.sysc where txb.sysc.sysc = "SCRC" no-lock.
/*find txb.sysc where txb.sysc.sysc = "SCRC-ORDER" exclusive-lock.
    txb.sysc.daval = today.
    txb.sysc.loval = no.
find txb.sysc where txb.sysc.sysc = "SCRC-ORDER" no-lock.*/
find txb.sysc where txb.sysc.sysc = "SCRC-ORDER" exclusive-lock.
    txb.sysc.daval = today.
    txb.sysc.loval = yes.
    /*if index(txb.sysc.chval, string(p-crc)) > 0 then do:
        d = substr(txb.sysc.chval, index(txb.sysc.chval, string(p-crc)), 3).
        txb.sysc.chval  = REPLACE(txb.sysc.chval , d, substr(d,1,1) + "-1").
    end.*/
find txb.sysc where txb.sysc.sysc = "SCRC-ORDER" no-lock.
