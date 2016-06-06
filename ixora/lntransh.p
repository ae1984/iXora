/* lntransh.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Создание карточки транша
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
        03/12/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        31/12/2010 madiyar - тип кредита (lon.prnmos) копируем из КЛ
        06/01/2011 madiyar - убрал проверку суммы на непревышение остатка КЛ
        26/01/2011 madiyar - проверка сроков погашения; копирование статусов фин. состояния и качества обеспечения из карточки КЛ
        04/03/2011 madiyar - копирование признаков с полем rcode
        12/04/2011 madiyar - при копировании критериев классификации (kdlonkl) копируются также поля rating и valdesc
        13/04/2011 madiyar - перекомпиляция
        31/05/2011 madiyar - проверки на группу и срок
        14/07/2011 madiyar - подправил проверку на срок
        10.01.2012 kapar - ТЗ №1122
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def shared var s-lon like lon.lon.
def shared var g-today as date.
def shared var g-ofc as char.

{get-kod.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-type as integer no-undo.
def var v-dtend as date no-undo.
def var v-sum as deci no-undo.
def var v-dog as char no-undo.
def var v-cif as char no-undo.
def var v-cname as char no-undo.
def var v-aaa as char no-undo.
def var v-ja as logi no-undo.
def var v-lontr like lon.lon.
def var v-longrp as integer no-undo.
def var lonsrok as int no-undo.
def var v-ccode as char no-undo.


def var v-msg as char no-undo.
def new shared var s-lgr like lgr.lgr. /* переменная для кредитов не используется, но нужна для отработки acng */

def buffer b-cif for cif.
def buffer b-lon for lon.
def buffer b-loncon for loncon.
def buffer b-sub-cod for sub-cod.
def buffer b-lonsec1 for lonsec1.
def buffer b-kdlonkl for kdlonkl.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

find first loncon where loncon.lon = lon.lon no-lock no-error.
if not avail loncon then do:
    message "Не найдена запись loncon!" view-as alert-box error.
    return.
end.

find first cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then do:
    message "Не найдена карточка клиента!" view-as alert-box error.
    return.
end.

if lon.gua <> "CL" then do:
    message "Не кредитная линия!" view-as alert-box error.
    return.
end.

if (lon.idt15 < g-today) and (lon.idt35 < g-today) then do:
    message "Срок выборки кредитной линии истек!" view-as alert-box error.
    return.
end.

function valSum returns logi (input p-sum as deci, input p-type as integer).
    def var res as logi no-undo.
    def var v-clost as deci no-undo.
    v-clost = 0.
    res = yes.
    if p-sum <= 0 then do:
        v-msg = "Некорректная сумма транша!".
        res = no.
    end.
    /*
    if res then do:
        if p-type = 1 then do:
            run lonbalcrc('lon',lon.lon,g-today,"15",yes,lon.crc,output v-clost).
            v-clost = - v-clost.
        end.
        else
        if p-type = 2 then do:
            run lonbalcrc('lon',lon.lon,g-today,"35",yes,lon.crc,output v-clost).
            v-clost = - v-clost.
        end.
        if v-clost < p-sum then do:
            v-msg = "Сумма транша превышает соответствующий остаток КЛ!".
            res = no.
        end.
    end.
    */
    return res.
end function.

function valType returns logi (input p-type as integer).
    def var res as logi no-undo.
    res = yes.
    if (p-type <> 1) and (p-type <> 2) then res = no.
    else
    if ((p-type = 1) and (lon.idt15 < g-today)) or ((p-type = 2) and (lon.idt35 < g-today)) then res = no.
    return res.
end function.

function valDtEnd returns logi (input p-dt as date, input p-type as integer, input p-grp as integer).
    def var res as logi no-undo.
    def var lonsrok as integer no-undo.
    def var dn2 as deci no-undo.
    res = yes.


    if (p-dt <= g-today) then assign res = no v-msg = "Некорректная дата погашения транша!".
    else
    if (p-dt > lon.duedt) then assign res = no v-msg = "Некорректная дата погашения транша!".
    else

    if ((p-type = 1) and (p-dt > lon.duedt15)) or ((p-type = 2) and (p-dt > lon.duedt35)) then assign res = no v-msg = "Дата погашения транша позже соотв. даты погашения КЛ!".

    run day-360(g-today,p-dt - 1,360,output lonsrok,output dn2).
    find first longrp where longrp.longrp = p-grp no-lock no-error.
   /* краткосрочный */
   if substr(string(longrp.stn), 2, 1) = "1" then if lonsrok > 360 then assign res = no v-msg = "Неверный срок окончания! У вас краткосрочная группа!".
   /* долгосрочный */
   if substr(string(longrp.stn), 2, 1) = "2" then if lonsrok <= 360 then assign res = no v-msg = "Неверный срок окончания! У вас долгосрочная группа!".

    return res.
end function.

function valGrp returns logi (input p-grp as integer).
    def var res as logi no-undo.
    res = yes.

    find first longrp where longrp.longrp = p-grp no-lock no-error.
    if not avail longrp then assign v-msg = "Некорректная группа транша!" res = no.
    else do:
        if substr(string(longrp.stn), 1, 1) = "1" then do: /* собираются выдать кредит для физ. лиц */
            if substr(get-kod("", v-cif), 2, 1) <> "9" then do:
                v-msg = "Группа не соответствует CIF (сектор экономики)!".
                res = no.
            end.
        end.
        if substr(string(longrp.stn), 1, 1) = "2" then do: /* собираются выдать кредит для юр. лиц */
            if substr(get-kod("", v-cif), 2, 1) = "9" then do:
                v-msg = "Группа не соответствует CIF (сектор экономики)!".
                res = no.
            end.
        end.
    end.

    return res.
end function.

v-cif = lon.cif.
v-cname = cif.name.
v-aaa = lon.aaa.
form v-type label "Тип транша (1-возобн., 2-невозобн.)" format "9" validate(valType(v-type),"Некорректный тип транша или истек соотв. срок выборки КЛ!") skip
     v-cif label "Код клиента........................" format "x(10)" validate (can-find(cif where cif.cif = v-cif), "Нет такого клиента!") skip
     v-cname label "Наименование клиента..............." format "x(40)" v-cname skip
     v-aaa label "Счет..............................." format "x(20)" validate (can-find(aaa where aaa.aaa = v-aaa), "Нет такого клиента!") skip
     v-longrp label "Группа транша......................" format ">9" validate(valGrp(v-longrp),v-msg) skip
     v-dtend label "Срок погашения транша.............." format "99/99/9999" validate(valDtEnd(v-dtend,v-type,v-longrp),v-msg) skip
     v-sum label "Сумма транша......................." format ">>>,>>>,>>>,>>9.99" validate(valSum(v-sum,v-type),v-msg) skip
     v-dog label "Номер акцессорного договора........" format "x(40)" validate(trim(v-dog) <> '',"Некорректный номер договора!") skip(1)
     v-ja label "Произвести оформление транша?......" format "да/нет"
with centered row 13 side-labels overlay frame fr.

on help of v-longrp in frame fr do:
    {itemlist.i
        &file = "longrp"
        &frame = "row 6 centered scroll 1 20 down overlay "
        &where = " yes "
        &flddisp = " longrp.longrp label 'grpId' longrp.des format 'x(60)' label 'Описание'"
        &chkey = "longrp"
        &index  = "longrp"
        &chtype = "integer"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-longrp = longrp.longrp.
    displ v-longrp with frame fr.
end.

v-type = 1.
v-dtend = g-today.
v-ja = no.
v-longrp = 0.

find first b-cif where b-cif.cif = v-cif no-lock no-error.
if avail b-cif then v-cname = cif.name.

display v-type v-longrp v-dtend v-sum v-dog v-cif v-cname v-aaa v-ja with frame fr.

update v-type with frame fr.
update v-cif with frame fr.
find first b-cif where b-cif.cif = v-cif no-lock no-error.
if avail b-cif then v-cname = b-cif.name.
display v-type v-longrp v-dtend v-sum v-dog v-cif v-cname v-aaa v-ja with frame fr.
update v-aaa with frame fr.
update v-longrp with frame fr.
update v-dtend with frame fr.
update v-sum with frame fr.
update v-dog with frame fr.
update v-ja with frame fr.

if not valGrp(v-longrp) then do:
   message v-msg view-as alert-box error.
   return.
end.
lonsrok = ABS (g-today - v-dtend).
/* определим количество дней для срока кредита - в справочник */
if lonsrok <= 30 then v-ccode = "01".
else
if lonsrok <= 90 then v-ccode = "02".
else
if lonsrok <= 180 then v-ccode = "03".
else
if lonsrok <= 365 then v-ccode = "04".
else
if lonsrok <= 1095 then v-ccode = "05".
else
if lonsrok <= 1825 then v-ccode = "06".
else
if lonsrok <= 3650 then v-ccode = "07".
else
v-ccode = "08".


if v-ja then do:
    find gl of longrp no-lock no-error.

    run acng(input gl.gl, false, output v-lontr).

    do transaction:
        find first b-lon where b-lon.lon = v-lontr exclusive-lock.
        assign b-lon.grp = v-longrp
               b-lon.cif = v-cif
               b-lon.gl = longrp.gl
               b-lon.rdt = g-today
               b-lon.extdt = today
               b-lon.base = "F"
               b-lon.prnmos = lon.prnmos
               b-lon.who = g-ofc
               b-lon.whn = g-today
               b-lon.prem = lon.prem
               b-lon.duedt = v-dtend
               b-lon.loncat = lon.loncat
               b-lon.opnamt = v-sum
               b-lon.crc = lon.crc
               b-lon.gua = "LO"
               b-lon.clnsts = lon.clnsts
               b-lon.basedy = lon.basedy
               b-lon.sts = "A"
               b-lon.penprem = lon.penprem
               b-lon.penprem7 = lon.penprem7
               b-lon.plan = lon.plan
               b-lon.aaa = v-aaa
               b-lon.clmain = lon.lon
               b-lon.trtype = v-type
               b-lon.day = lon.day.

        create b-loncon.
        assign b-loncon.lon = v-lontr
               b-loncon.cif = v-cif
               b-loncon.rez-char[9] = cif.jss
               b-loncon.who = g-ofc
               b-loncon.whn = g-today
               b-loncon.objekts = loncon.objekts
               b-loncon.lcnt = loncon.lcnt + "  " + v-dog
               b-loncon.sods1 = loncon.sods1
               b-loncon.vad-amats = loncon.vad-amats
               b-loncon.vad-vards = loncon.vad-vards
               b-loncon.galv-gram = loncon.galv-gram
               b-loncon.pase-pier = loncon.pase-pier
               b-loncon.rez-char[10] = entry(1,loncon.rez-char[10],'&').

        find first lonstat no-lock no-error.
        if avail lonstat then do:
            create lonhar.
            assign lonhar.lon = v-lontr
                   lonhar.ln = 1
                   lonhar.lonstat = lonstat.lonstat
                   lonhar.fdt = date(1, 1, 1901)
                   lonhar.cif = v-cif
                   lonhar.akc = no
                   lonhar.who = g-ofc
                   lonhar.whn = g-today.
        end.

        find first lonhar where lonhar.lon = v-cif no-lock no-error.
        if not available lonhar then do:
            create lonhar.
            assign lonhar.lon = v-cif
                   lonhar.ln = 2
                   lonhar.fdt = date(1, 1, 1901)
                   lonhar.cif = v-cif
                   lonhar.akc = no
                   lonhar.finrez = 999999999999.99
                   lonhar.who = g-ofc
                   lonhar.whn = g-today.
        end.

        find first ln%his where ln%his.lon = v-lontr no-lock no-error.
        if not avail ln%his then do:
            create ln%his.
            assign ln%his.stdat = g-today
                   ln%his.who = g-ofc
                   ln%his.whn = g-today
                   ln%his.lon = v-lontr
                   ln%his.f0 = 1
                   ln%his.intrate = b-lon.prem
                   ln%his.opnamt = v-sum
                   ln%his.rdt = g-today
                   ln%his.duedt = b-lon.duedt
                   ln%his.cif = b-lon.cif
                   ln%his.lcnt = loncon.lcnt + "  " + v-dog
                   ln%his.gua = b-lon.gua
                   ln%his.grp = b-lon.grp
                   ln%his.loncat = b-lon.loncat.
        end.

        if lon.cif = v-cif then do:
            for each sub-dic where sub-dic.sub = "lon" no-lock.
                find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = sub-dic.d-cod use-index dcod no-lock no-error.
                if avail sub-cod then do:
                    create b-sub-cod.
                    assign b-sub-cod.sub = "lon"
                           b-sub-cod.acc = v-lontr
                           b-sub-cod.d-cod = sub-dic.d-cod
                           b-sub-cod.ccode = sub-cod.ccode
                           b-sub-cod.rcode = sub-cod.rcode.
                end.
            end.
        end.
        else do:
            for each sub-dic where sub-dic.sub = "lon" and d-cod <> "lneko" and  d-cod <> "lnotrdr" and  d-cod <> "lnsegm" no-lock.
                find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = sub-dic.d-cod use-index dcod no-lock no-error.
                if avail sub-cod then do:
                    if sub-dic.d-cod = "lnsrok" Then do:
                        create b-sub-cod.
                        assign b-sub-cod.sub = "lon"
                               b-sub-cod.acc = v-lontr
                               b-sub-cod.d-cod = sub-dic.d-cod
                               b-sub-cod.ccode = v-ccode
                               b-sub-cod.rcode = sub-cod.rcode.
                    end.
                    else do:
                        create b-sub-cod.
                        assign b-sub-cod.sub = "lon"
                               b-sub-cod.acc = v-lontr
                               b-sub-cod.d-cod = sub-dic.d-cod
                               b-sub-cod.ccode = sub-cod.ccode
                               b-sub-cod.rcode = sub-cod.rcode.
                    end.
                end.
            end.
        end.

        run doSubcodEdit.

        for each lonsec1 where lonsec1.lon = lon.lon no-lock:
            create b-lonsec1.
            buffer-copy lonsec1 except lonsec1.lon to b-lonsec1.
            b-lonsec1.lon = v-lontr.
        end.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = lon.lon and kdlonkl.kod = 'finsost1' use-index bclrdt no-lock no-error.
        if avail kdlonkl then do:
            create b-kdlonkl.
            assign b-kdlonkl.bank = s-ourbank
                   b-kdlonkl.kdcif = v-cif
                   b-kdlonkl.kdlon = v-lontr
                   b-kdlonkl.kod = 'finsost1'
                   b-kdlonkl.rdt = g-today
                   b-kdlonkl.who = g-ofc
                   b-kdlonkl.whn = g-today
                   b-kdlonkl.val1 = kdlonkl.val1
                   b-kdlonkl.valdesc = kdlonkl.valdesc
                   b-kdlonkl.rating = kdlonkl.rating.
        end.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = lon.lon and kdlonkl.kod = 'obesp1' use-index bclrdt no-lock no-error.
        if avail kdlonkl then do:
            create b-kdlonkl.
            assign b-kdlonkl.bank = s-ourbank
                   b-kdlonkl.kdcif = v-cif
                   b-kdlonkl.kdlon = v-lontr
                   b-kdlonkl.kod = 'obesp1'
                   b-kdlonkl.rdt = g-today
                   b-kdlonkl.who = g-ofc
                   b-kdlonkl.whn = g-today
                   b-kdlonkl.val1 = kdlonkl.val1
                   b-kdlonkl.valdesc = kdlonkl.valdesc
                   b-kdlonkl.rating = kdlonkl.rating.
        end.


    end. /* transaction */

    message "Карточка транша " + v-lontr + " создана и заполнена" view-as alert-box information.

end.


procedure doSubcodEdit:
    def var londays as integer no-undo.
    def var dn2 as deci no-undo.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnshifr' and sub-cod.acc = v-lontr exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon'
               sub-cod.d-cod = 'lnshifr'
               sub-cod.acc = v-lontr
               sub-cod.rdt = g-today.
    end.
    if b-lon.grp = 10 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '01'. else sub-cod.ccode = '09'.
    end.
    else
    if b-lon.grp = 50 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '02'. else sub-cod.ccode = '10'.
    end.
    else
    if lookup(string(b-lon.grp),'11,14,15') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '03'. else sub-cod.ccode = '11'.
    end.
    else
    if lookup(string(b-lon.grp),'54,55') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '04'. else sub-cod.ccode = '12'.
    end.
    else
    if lookup(string(b-lon.grp),'20,81') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '05'. else sub-cod.ccode = '13'.
    end.
    else
    if lookup(string(b-lon.grp),'60,82') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '06'. else sub-cod.ccode = '14'.
    end.
    else
    if lookup(string(b-lon.grp),'21,24,25') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '07'. else sub-cod.ccode = '15'.
    end.
    else
    if lookup(string(b-lon.grp),'64,65') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '08'. else sub-cod.ccode = '16'.
    end.
    else
    if b-lon.grp = 70 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if b-lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '03'. else sub-cod.ccode = '04'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '11'. else sub-cod.ccode = '12'.
        end.
    end.
    else
    if b-lon.grp = 80 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if b-lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '07'. else sub-cod.ccode = '08'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '15'. else sub-cod.ccode = '16'.
        end.
    end.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnovdcd' and sub-cod.acc = v-lontr exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon'
               sub-cod.d-cod = 'lnovdcd'
               sub-cod.acc = v-lontr
               sub-cod.rdt = g-today.
    end.
    if b-lon.grp = 10 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '25'. else sub-cod.ccode = '33'.
    end.
    else
    if b-lon.grp = 50 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '26'. else sub-cod.ccode = '34'.
    end.
    else
    if lookup(string(b-lon.grp),'11,14,15') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '27'. else sub-cod.ccode = '35'.
    end.
    else
    if lookup(string(b-lon.grp),'54,55') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '28'. else sub-cod.ccode = '36'.
    end.
    else
    if lookup(string(b-lon.grp),'20,81') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '29'. else sub-cod.ccode = '37'.
    end.
    else
    if lookup(string(b-lon.grp),'60,82') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '30'. else sub-cod.ccode = '38'.
    end.
    else
    if lookup(string(b-lon.grp),'21,24,25') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '31'. else sub-cod.ccode = '39'.
    end.
    else
    if lookup(string(b-lon.grp),'64,65') > 0 then do:
        if b-lon.crc = 1 then sub-cod.ccode = '32'. else sub-cod.ccode = '40'.
    end.
    else
    if b-lon.grp = 70 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if b-lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '27'. else sub-cod.ccode = '28'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '35'. else sub-cod.ccode = '36'.
        end.
    end.
    else
    if b-lon.grp = 80 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if b-lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '31'. else sub-cod.ccode = '32'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '39'. else sub-cod.ccode = '40'.
        end.
    end.
end procedure.
