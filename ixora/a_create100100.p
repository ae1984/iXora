/* a_create100100.p
 * MODULE
        Название модуля
 * DESCRIPTION
        создание нового jou документа для счета 100100
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

 * BASES
        BANK COMM
 * CHANGES
                14/05/2012  Luiza
                23/07/2012 Luiza отменила message, который использовался для тестирования
                15/01/2012 Luiza добавила вызов chgsts
                27/02/2013 Luiza - ТЗ № 1699

*/

define input parameter vv-doc as character.

def buffer b-joudoc for joudoc.
def buffer b-joudop for joudop.
find first b-joudoc where b-joudoc.docnum = vv-doc no-lock no-error.
if not available b-joudoc then do:
    message "joudoc документ "  + vv-doc + " не найден!" view-as alert-box.
    return.
end.
find first b-joudop where b-joudop.docnum = vv-doc no-lock no-error.
if not available b-joudop then do:
    message "joudop документ "  + vv-doc + " не найден!" view-as alert-box.
    return.
end.

def var v-joudoc100100 as char.
def var vv-type as char.

function chgtype returns char (str2 as char).
    define var outstr2 as char.
    def var rus2 as char extent 20 init
    ["EK1","EK2","MC2","RF1","RF2","RF3","NIC","BOM","NT3","NT4","NT5","RT1","RT2","RT3","RT4","EK4","EK5","EK6","EK7","EK9"].
    def var eng2 as char  extent 20 init
    ["CS1","CS2","CM2","FR1","FR2","FR3","INC","OBM","TN3","TN4","TN5","TR1","TR2","TR3","TR4","CS4","CS5","CS6","CS7","CS9"].

    def var j2 as integer.
    def var ns2 as log init false.
    str2 = caps(str2).

     repeat j2 = 1 to 20:
       if str2 = rus2[j2] then
       do:
          outstr2 = eng2[j2].
          ns2 = true.
       end.
        if ns2 then return outstr2.
        ns2 = false.
    end.
    return str2.
end.


find nmbr where nmbr.code eq "JOU" no-lock no-error.
v-joudoc100100 = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
find first nmbr no-lock no-error.

create joudoc.
joudoc.docnum = v-joudoc100100.
joudoc.who = b-joudoc.who.
joudoc.whn = b-joudoc.whn.
joudoc.tim = time.
joudoc.dramt = b-joudoc.dramt.
if b-joudoc.dracctype = "4" then do:
    find first arp where arp.arp = b-joudoc.dracc  no-lock no-error.
    if available arp and arp.gl = 100500 then do:
        joudoc.dracctype = "1".
        joudoc.dracc = "".
    end.
    else do:
        joudoc.dracctype = b-joudoc.dracctype.
        joudoc.dracc = b-joudoc.dracc.
    end.
end.
else do:
    joudoc.dracctype = b-joudoc.dracctype.
    joudoc.dracc = b-joudoc.dracc.
end.

joudoc.drcur = b-joudoc.drcur.
joudoc.cramt = b-joudoc.cramt.
if b-joudoc.cracctype = "4" then do:
    find first arp where arp.arp = b-joudoc.cracc  no-lock no-error.
    if available arp and arp.gl = 100500 then do:
        joudoc.cracctype = "1".
        joudoc.cracc = "".
    end.
    else do:
        joudoc.cracctype = b-joudoc.cracctype.
        joudoc.cracc = b-joudoc.cracc.
    end.
end.
else do:
    joudoc.cracctype = b-joudoc.cracctype.
    joudoc.cracc = b-joudoc.cracc.
end.
joudoc.crcur = b-joudoc.crcur.
joudoc.comvo = b-joudoc.comvo.
joudoc.comamt = b-joudoc.comamt.
joudoc.comcur = b-joudoc.comcur.

if b-joudoc.comacctype = "4" then do:
    find first arp where arp.arp = b-joudoc.comacc  no-lock no-error.
    if available arp and arp.gl = 100500 then do:
        joudoc.comacctype = "1".
        joudoc.comacc = "".
    end.
    else do:
        joudoc.comacctype = b-joudoc.comacctype.
        joudoc.comacc = b-joudoc.comacc.
    end.
end.
joudoc.srate = b-joudoc.srate.
joudoc.brate = b-joudoc.brate.
joudoc.comcode = b-joudoc.comcode.
joudoc.bas_amt = b-joudoc.bas_amt.
joudoc.remark[1] = b-joudoc.remark[1].
joudoc.remark[2] = b-joudoc.remark[2].
joudoc.chk = b-joudoc.chk.
joudoc.info = b-joudoc.info .
joudoc.passp = b-joudoc.passp.
joudoc.perkod = b-joudoc.perkod.
joudoc.num = b-joudoc.num.
joudoc.sts = b-joudoc.sts.
joudoc.dsts = b-joudoc.dsts.
joudoc.tsts = b-joudoc.tsts.
joudoc.nalamt = b-joudoc.nalamt.
joudoc.passpdt = b-joudoc.passpdt.
joudoc.rescha[1] = b-joudoc.rescha[1].
joudoc.rescha[2] = b-joudoc.rescha[2].
joudoc.rescha[3] = b-joudoc.rescha[3].
joudoc.rescha[4] = b-joudoc.rescha[4].
joudoc.rescha[5] = b-joudoc.rescha[5].
joudoc.drirs = b-joudoc.drirs.
joudoc.crirs = b-joudoc.crirs.
joudoc.vo = b-joudoc.vo.
joudoc.drclntype = b-joudoc.drclntype.
joudoc.crclntype = b-joudoc.crclntype.
joudoc.comvo = b-joudoc.comvo.
joudoc.payment = b-joudoc.payment.
joudoc.nalcomcode = b-joudoc.nalcomcode.
joudoc.point = b-joudoc.point.
joudoc.depart = b-joudoc.depart.
joudoc.kfmcif = b-joudoc.kfmcif.
joudoc.benname = b-joudoc.benname.
find current joudoc no-lock no-error.

create joudop.
joudop.docnum = v-joudoc100100.
joudop.who = b-joudop.who.
joudop.whn = b-joudop.whn.
joudop.tim = time.
vv-type = substring(b-joudop.type,4,1).
joudop.type = chgtype(substring(b-joudop.type,1,3)).
joudop.type = joudop.type + vv-type.
joudop.cur = b-joudop.cur.
joudop.lname = b-joudop.lname.
joudop.mname = b-joudop.mname.
joudop.fname = b-joudop.fname.
joudop.rez1 = b-joudop.rez1.
joudop.doc1 = b-joudop.doc1.
joudop.docwho = b-joudop.docwho.
joudop.docdt = b-joudop.docdt.
joudop.amt = b-joudop.amt.
joudop.amt1 = b-joudop.amt1.
joudop.amt2 = b-joudop.amt2.
joudop.amt3 = b-joudop.amt3.

joudop.patt = b-joudop.patt.
find current joudop no-lock no-error.

def buffer b-sub-cod for sub-cod.


find first b-sub-cod where b-sub-cod.sub = "jou" and b-sub-cod.acc = vv-doc and b-sub-cod.d-cod = "eknp" exclusive-lock no-error.
if available b-sub-cod then do:
    create sub-cod.
    sub-cod.acc = v-joudoc100100.
    sub-cod.sub = "jou".
    sub-cod.d-cod  = "eknp".
    sub-cod.ccode = "eknp".
    sub-cod.rdt = b-sub-cod.rdt.
    sub-cod.rcode = b-sub-cod.rcode.
end.


find first b-sub-cod where b-sub-cod.sub = 'jou' and b-sub-cod.acc = vv-doc and b-sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
if available b-sub-cod then do:
    create sub-cod.
    sub-cod.sub = 'jou'.
    sub-cod.acc = v-joudoc100100.
    sub-cod.d-cod = 'pdoctng'.
    sub-cod.ccode = b-sub-cod.ccode.
    sub-cod.rdt = b-sub-cod.rdt.
end.
run chgsts("JOU", v-joudoc100100, "new").

message "Документ для счета 100100 сформирован! Номер документа: " +  v-joudoc100100 view-as alert-box.

