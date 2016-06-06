/* r-garantn.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по неакцептованным гарантиям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        13/04/2010 madiyar - скопировал из r-garant.p с изменениями
 * BASES
        BANK
 * CHANGES
*/

{mainhead.i}

def stream m-out.
def var ecdivis as char no-undo.

def temp-table wrk no-undo
    field aaa       like  aaa.aaa
    field ecdivis   as    char
    field regdt     like  aaa.regdt
    field expdt     like  aaa.expdt
    field vid       as    character  format 'x(10)'
    field cif       like  cif.cif
    field name      like  cif.sname
    field crc       like  crc.crc
    field code      like  crc.code
    field ost       like  jl.dam     init 0
    field ostkzt    like  jl.dam     init 0
    field jh        as    integer.

hide message no-pause.
message '   Формируется отчет...   '.

for each cif,
    each aaa where aaa.cif = cif.cif and
                   ((aaa.gl >= 222300 and aaa.gl <= 222399) or
                    (aaa.gl >= 220800 and aaa.gl <= 220899) or
                    (aaa.gl >= 224000 and aaa.gl <= 224099) or
                    aaa.gl = 213110 or aaa.gl = 213120) no-lock:
    find sub-cod where sub-cod.sub = 'cln' and  sub-cod.acc = aaa.cif  and  sub-cod.d-cod = 'ecdivis' no-lock no-error.
    if avail sub-cod then ecdivis = sub-cod.ccod. else ecdivis = 'N/A'.

    for each jl where jl.acc = aaa.aaa and jl.lev = 7 and jl.subled = 'cif' no-lock:
        if jl.dc = 'd' and jl.sts = 5 then do:
            create wrk.
            wrk.cif = cif.cif.
            wrk.name = trim(trim(cif.prefix) + " " + trim(cif.sname)).
            wrk.aaa = aaa.aaa.
            find first crc where crc.crc = aaa.crc no-lock no-error.
            wrk.crc = crc.crc.
            wrk.code = crc.code.
            wrk.regdt = aaa.regdt.
            wrk.expdt = aaa.expdt.
            wrk.ecdivis = ecdivis.
            wrk.jh = jl.jh.

            find trxlevgl where trxlevgl.gl = aaa.gl
                          and trxlevgl.subled eq 'cif'
                          and trxlevgl.level eq 7
                          no-lock no-error.
            if avail trxlevgl then do:
                if trxlevgl.glr = 605530 then wrk.vid = 'депозит'.
                else if trxlevgl.glr = 605540 then wrk.vid = 'др.залог'.
                else wrk.vid = 'н/обесп.'.
                wrk.ost = jl.dam.
                find first crc where crc.crc = wrk.crc no-lock no-error.
                wrk.ostkzt = wrk.ost * crc.rate[1].
            end.
        end.
    end.

end.

output stream m-out to rpt.htm.
put stream m-out unformatted
    "<html><head><title>Неакцептованные гарантии</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted
    "<b>Неакцептованные гарантии<br>" + string(g-today,"99/99/9999") + " " + string(time,"hh:mm:ss") + "</b><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код кл</td>" skip
    "<td>Клиент</td>" skip
    "<td>Счет</td>" skip
    "<td>Транзакция</td>" skip
    "<td>Валюта</td>" skip
    "<td>Сумма<br>гарантии</td>" skip
    "<td>Эквивалент<br>в тенге</td>" skip
    "<td>Дата<br>выдачи</td>" skip
    "<td>Срок<br>погашения</td>" skip
    "<td>Вид<br>гарантии</td>" skip
    "<td>Признак<br>отрасли</td>" skip
    "</tr>" skip.

for each wrk where wrk.ost <> 0 break by wrk.vid by wrk.cif by wrk.expdt.

    accum wrk.ostkzt (total by wrk.vid).
    if first-of(wrk.cif) then
        put stream m-out unformatted
            "<tr>" skip
            "<td>" wrk.cif "</td>" skip
            "<td>" wrk.name "</td>" skip
            "<td>" wrk.aaa "</td>" skip
            "<td>" wrk.jh "</td>" skip
            "<td>" wrk.code "</td>" skip
            "<td>" replace(trim(string(wrk.ost,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.ostkzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" string(wrk.regdt,"99/99/9999") "</td>" skip
            "<td>" string(wrk.expdt,"99/99/9999") "</td>" skip
            "<td>" wrk.vid "</td>" skip
            "<td>" wrk.ecdivis "</td>" skip.
    else
       put stream m-out unformatted
            "<tr>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td>" wrk.aaa "</td>" skip
            "<td>" wrk.jh "</td>" skip
            "<td>" wrk.code "</td>" skip
            "<td>" replace(trim(string(wrk.ost,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.ostkzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" string(wrk.regdt,"99/99/9999") "</td>" skip
            "<td>" string(wrk.expdt,"99/99/9999") "</td>" skip
            "<td>" wrk.vid "</td>" skip
            "<td>" wrk.ecdivis "</td>" skip.

    if last-of(wrk.vid) then do:
        put stream m-out unformatted
            "<tr style=""font:bold"">" skip
            "<td colspan=""2"">Итого по виду гарантии: " + wrk.vid + "</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td>" replace(trim(string(accum total by wrk.vid wrk.ostkzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip.
    end.
end.

put stream m-out unformatted
            "<tr style=""font:bold"">" skip
            "<td colspan=""2"">Итого:</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td>" replace(trim(string(accum total wrk.ostkzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip.

for each wrk where wrk.ost <> 0 break by wrk.code:
    accum wrk.ost (total by wrk.code).
    accum wrk.ostkzt (total by wrk.code).
    if last-of(wrk.code) then
        put stream m-out unformatted
            "<tr style=""font:bold"">" skip
            "<td colspan=""2"">Итого по валюте:</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td>" wrk.code "</td>" skip
            "<td>" replace(trim(string(accum total by wrk.code wrk.ost,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(accum total by wrk.code wrk.ostkzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td></td>" skip.
end.
output stream m-out close.

hide message no-pause.

unix silent cptwin rpt.htm excel.
pause 0.

