/* pkprtgraf.p
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Расчет временной таблицы данных графика и вызов печати графика
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
        31/12/99 pragma
 * CHANGES
        07.03.2003 nadejda - вырезан кусок из pklongrf.p
        17.03.2003 nadejda - формирование выходного файла выделено в отдельные проги для разных видов кредитов
        11/03/2007 madiyar - не формировались графики, исправил
        10/09/2009 madiyar - добавил поле com в шаренную таблицу
        26/10/2009 galina - добавила определение шаренных переменных
        23/08/10 aigul - изменила  wrk.com = yes на  wrk.com = lnsch.commis.
*/

{global.i}
{pk.i}
{pk-sysc.i}

def var i as integer no-undo.

if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
    message skip " Ссудный счет N" pkanketa.lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

def new shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field com    as logi init no
    index idx is primary stdat.

s-lon = pkanketa.lon.

for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock:
    create wrk.
    wrk.stdat = lnsch.stdat.
    wrk.od = lnsch.stval.
    wrk.com = lnsch.commis. /*aigul*/

end.

for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock:
    find first wrk where wrk.stdat = lnsci.idat no-lock no-error.
    if not avail wrk then do:
        create wrk.
        wrk.stdat = lnsci.idat.
    end.
    wrk.proc = lnsci.iv-sc.
end.

i = 1.
for each wrk:
    wrk.nn = i.
    i = i + 1.
end.

run pkdogsgn.

/* печать графика для разных видов кредитов */
run value("pkprtgrf-" + s-credtype).

