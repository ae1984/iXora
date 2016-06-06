/* lnprisk.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Расчет долга клиента для проведения претензионно-исковой работы
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
        18/05/2010 madiyar
 * BASES
        BANK
 * CHANGES
*/

{mainhead.i}

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
find first cif where cif.cif = lon.cif no-lock no-error.

if not avail lon or not avail cif then do:
    message "Не найден ссудный счет или клиентская карточка!" view-as alert-box error.
    return.
end.

def var v-jdt as date no-undo.
v-jdt = g-today.

update v-jdt format "99/99/9999" label "Укажите дату" with centered row 13 overlay frame frdt.
hide frame frdt.

def var v-crccode as char no-undo.
def var v-mod as deci no-undo.
def var v-mprc as deci no-undo.
def var v-day as integer no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-srok as deci no-undo.
def var v-prem as deci no-undo.
def var v-opnamt as deci no-undo.
def var v-bal as deci no-undo.
def var v-dt as date no-undo.

def var i as integer no-undo.
def var prc_i as integer no-undo.
def var od_i as integer no-undo.
def var itog_i as integer no-undo.
def var itogo as logi no-undo.
def var max_i as integer no-undo.

def var prc_sum as deci no-undo.
def var opnamt_sum as deci no-undo.
def var nach_prc_sum as deci no-undo.
def var od_sum as deci no-undo.
def var pen_sum as deci no-undo.
def var com_sum as deci no-undo.
def var all_sum as deci no-undo.
def var postfix as char no-undo.

def temp-table wrkinf no-undo
  field id as integer
  field kname as char
  field kvalue as char
  index idx is primary id.

def temp-table wrk no-undo
  field id as integer
  field tt as char
  field dt as date
  field amt as deci
  field vyd as deci
  field odleft as deci
  field days as integer
  field prcaccr as deci
  index idx is primary tt dt
  index idx2 tt id.

find first crc where crc.crc = lon.crc no-lock no-error.
if avail crc then v-crccode = crc.code.
else v-crccode = "--not found--".

v-day = 0.
v-mod = 0.
v-mprc = 0.
find last lnsch where lnsch.lnn = lon.lon and lnsch.stdat < lon.duedt no-lock no-error.
if avail lnsch then do:
    v-mod = lnsch.stval.
    v-day = day(lnsch.stdat).
end.
find last lnsci where lnsci.lni = lon.lon and lnsci.idat < lon.duedt no-lock no-error.
if avail lnsci then do:
    v-mprc = lnsci.iv-sc.
    if v-day = 0 then v-day = day(lnsci.idat).
end.

run day-360(lon.rdt,lon.duedt - 1,lon.basedy,output dn1,output dn2).
v-srok = round(dn1 / 30,0).

v-prem = lon.prem.
if v-prem = 0 then v-prem = lon.prem1.
if v-prem = 0 then do:
    find last ln%his where ln%his.lon = lon.lon and ln%his.intrate > 0 no-lock no-error.
    if avail ln%his then v-prem = ln%his.intrate.
end.

com_sum = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' no-lock:
    com_sum = com_sum + bxcif.amount.
end.

run lonbalcrc('lon',lon.lon,g-today,"5,16",yes,1,output pen_sum).

prc_sum = 0.
for each lnsci where lnsci.lni = lon.lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
    create wrk.
    assign wrk.tt = "prc"
           wrk.dt = lnsci.idat
           wrk.amt = lnsci.paid-iv.
    prc_sum = prc_sum + lnsci.paid-iv.
end.

v-opnamt = 0.
opnamt_sum = 0.
for each lnscg where lnscg.lng = lon.lon and lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0 no-lock by lnscg.stdat descending:
    v-opnamt = v-opnamt + lnscg.paid.
    create wrk.
    assign wrk.tt = "od"
           wrk.dt = lnscg.stdat
           wrk.vyd = lnscg.paid
           wrk.odleft = v-opnamt.
    opnamt_sum = opnamt_sum + lnscg.paid.
end.

v-bal = v-opnamt.
od_sum = 0.
for each lnsch where lnsch.lnn = lon.lon and lnsch.fpn = 0 and lnsch.flp > 0 no-lock:
    v-bal = v-bal - lnsch.paid.
    create wrk.
    assign wrk.tt = "od"
           wrk.dt = lnsch.stdat
           wrk.amt = lnsch.paid
           wrk.odleft = v-bal.
    od_sum = od_sum + lnsch.paid.
end.

prc_i = 0.
for each wrk where wrk.tt = "prc" use-index idx:
    prc_i = prc_i + 1.
    wrk.id = prc_i.
end.

od_i = 0.
for each wrk where wrk.tt = "od" use-index idx:
    od_i = od_i + 1.
    wrk.id = od_i.
end.

od_i = od_i + 1.
create wrk.
assign wrk.tt = "od"
       wrk.id = od_i
       wrk.dt = v-jdt
       wrk.odleft = v-bal.

if prc_i > od_i then max_i = prc_i. else max_i = od_i.
itog_i = max_i + 1.

find first wrk where wrk.tt = "od" use-index idx no-lock no-error.
v-dt = wrk.dt.

nach_prc_sum = 0.
for each wrk where wrk.tt = "od" use-index idx:
    if wrk.dt > v-dt then do:
        run day-360(v-dt,wrk.dt - 1,lon.basedy,output dn1,output dn2).
        wrk.days = dn1.
        wrk.prcaccr = round(wrk.days * v-opnamt * v-prem / 100 / lon.basedy,2).
        nach_prc_sum = nach_prc_sum + wrk.prcaccr.
        v-dt = wrk.dt.
    end.
end.


i = 0.

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Сумма кредита (" + v-crccode + ")</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(lon.opnamt,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Дата выдачи по кред. договору</td>"
       wrkinf.kvalue = "<td>" + string(lon.rdt,"99/99/9999") + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Факт. дата выдачи</td>"
       wrkinf.kvalue = "<td>" + string(lon.rdt,"99/99/9999") + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Срок</td>"
       wrkinf.kvalue = "<td>" + string(v-srok) + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">% ставка</td>"
       wrkinf.kvalue = "<td>" + replace(trim(string(v-prem,">>9.99")),'.',',') + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Срок возврата</td>"
       wrkinf.kvalue = "<td>" + string(lon.duedt,"99/99/9999") + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""left"" valign=""center"">Обеспечение</td>"
       wrkinf.kvalue = "<td align=""center"">нет</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td></td>"
       wrkinf.kvalue = "<td></td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td colspan=2 style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""center"" valign=""center"">Долг по кредиту на " + string(g-today,"99/99/9999") + "</td>"
       wrkinf.kvalue = "".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""left"" valign=""center"">Долг по выплате %%</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(nach_prc_sum - prc_sum,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""left"" valign=""center"">Остаток основного долга</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(opnamt_sum - od_sum,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""left"" valign=""center"">Штрафы</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(pen_sum,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""left"" valign=""center"">Комиссии</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(com_sum,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".


postfix = ''.
if lon.crc = 1 then assign all_sum = (nach_prc_sum - prc_sum) + (opnamt_sum - od_sum) + pen_sum + com_sum postfix = "(с пеней)".
else assign all_sum = (nach_prc_sum - prc_sum) + (opnamt_sum - od_sum) + com_sum postfix = "(без пени)".

i = i + 1.
create wrkinf.
assign wrkinf.id = i
       wrkinf.kname = "<td style=""font:bold;font-size:xx-small"" bgcolor=""#FFFF99"" align=""left"" valign=""center"">ВСЕГО " + postfix + ":</td>"
       wrkinf.kvalue = "<td>" + replace(replace(trim(string(all_sum,">>>,>>>,>>9.99")),',',' '),'.',',') + "</td>".

if max_i < i then max_i = i.

def stream rep.
output stream rep to rep.htm.


put stream rep unformatted
    "<html><head><title>Расчет долга - " + trim(cif.name) + "</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted trim(cif.name) "<br>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""center"" valign=""center"">" skip
    "<td colspan=2 rowspan=3>Информация о выдаче кредита</td>" skip
    "<td colspan=4>Сроки погашения по кредитному договору</td>" skip
    "<td colspan=2 rowspan=2>Фактическое погашение процентов</td>" skip
    "<td colspan=6>Расчет начисления процентов</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""center"">" skip
    "<td colspan=2>Проценты</td>" skip
    "<td colspan=2>Основной долг</td>" skip
    "<td rowspan=2>Дата</td>" skip
    "<td rowspan=2>Выдача<br>кредита</td>" skip
    "<td rowspan=2>Погашение<br>ОД</td>" skip
    "<td rowspan=2>Остаток<br>ОД</td>" skip
    "<td rowspan=2>Начисленные<br>проценты</td>" skip
    "<td rowspan=2>Кол-во<br>дней</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#CCFFCC"" align=""center"" valign=""center"">" skip
    "<td>дата</td>" skip
    "<td>сумма</td>" skip
    "<td>дата</td>" skip
    "<td>сумма</td>" skip
    "<td>дата</td>" skip
    "<td>сумма</td>" skip
    "</tr>" skip.

itogo = no.

do i = 1 to max_i:

    put stream rep unformatted "<tr>" skip.

    find first wrkinf where wrkinf.id = i no-lock no-error.
    if avail wrkinf then do:
        put stream rep unformatted
            wrkinf.kname skip
            wrkinf.kvalue skip.
    end.
    else put stream rep unformatted "<td></td> <td></td>" skip.

    if i = 1 then do:
        put stream rep unformatted
            "<td>ежемесячно " + string(v-day,"99") + " числа</td>" skip
            "<td>" replace(replace(trim(string(v-mprc,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
            "<td>ежемесячно " + string(v-day,"99") + " числа</td>" skip
            "<td>" replace(replace(trim(string(v-mod,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip.
    end.
    else put stream rep unformatted "<td></td> <td></td> <td></td> <td></td>" skip.

    if i < itog_i then do:
        find first wrk where wrk.tt = "prc" and wrk.id = i no-lock no-error.
        if avail wrk then do:
            put stream rep unformatted
                "<td>" string(wrk.dt,"99/99/9999") "</td>"
                "<td>" replace(replace(trim(string(wrk.amt,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip.
        end.
        else put stream rep unformatted "<td></td> <td></td>" skip.

        find first wrk where wrk.tt = "od" and wrk.id = i no-lock no-error.
        if avail wrk then do:
            put stream rep unformatted
                "<td>" string(wrk.dt,"99/99/9999") "</td>"
                "<td>" replace(replace(trim(string(wrk.vyd,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td>" replace(replace(trim(string(wrk.amt,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td>" replace(replace(trim(string(wrk.odleft,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td>" replace(replace(trim(string(wrk.prcaccr,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td>" wrk.days "</td>" skip.
        end.
        else put stream rep unformatted "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip.
    end.
    else
    if i = itog_i then do:
        put stream rep unformatted
                "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
                "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(prc_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
                "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(opnamt_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(od_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
                "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(nach_prc_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
                "<td style=""font:bold"" bgcolor=""#FFFF99""></td>".
        itogo = yes.
    end.
    else do:
        put stream rep unformatted "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip.
    end.

    put stream rep unformatted
        "</tr>" skip.
end.

if not(itogo)  then do:
    put stream rep unformatted
        "<tr>" skip
        "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
        "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
        "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(prc_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
        "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
        "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(opnamt_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
        "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(od_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
        "<td style=""font:bold"" bgcolor=""#FFFF99""></td>"
        "<td style=""font:bold"" bgcolor=""#FFFF99"">" replace(replace(trim(string(nach_prc_sum,">>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
        "<td style=""font:bold"" bgcolor=""#FFFF99""></td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.

pause 0.
