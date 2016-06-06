/* 16.p
 * MODULE
        Отчеты для статистики
 * DESCRIPTION
        Отчет 16ПБ - основная
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        16run.p
 * MENU
        8-2-14-9
 * AUTHOR
        11/03/04 sasco
 * CHANGES
        14.02.2012 aigul - исправила вывод ГК 185800
*/

{16.i "new"}
{gl-utils.i}


update v-date1 label "DATE FROM" SKIP v-date2 label "DATE TO" with frame getdats.
hide frame getdats.

{r-brfilial.i &proc="16run"}


output to wrk.csv.
for each wrk:
    find tot where tot.crc = wrk.crc and
                   tot.dc = wrk.dc and
                   tot.dgl = wrk.dgl and
                   tot.cgl = wrk.cgl and
                   tot.fu = wrk.fu and
                   tot.res = wrk.res no-error.
    if not avail tot then do:
       create tot.
       tot.crc = wrk.crc.
       tot.dc = wrk.dc.
       tot.dgl = wrk.dgl.
       tot.cgl = wrk.cgl.
       tot.fu = wrk.fu.
       tot.res = wrk.res.
       tot.sum = 0.0.
       tot.numtrx = 0.
    end.

    tot.sum = tot.sum + wrk.sum.
    tot.numtrx = tot.numtrx + 1.

    put unformatted wrk.crc ";" wrk.dc ";" wrk.dgl ";" wrk.cgl ";" wrk.fu ";" wrk.res ";" XLS-NUMBER (wrk.sum) ";"
                    wrk.cif ";" wrk.jh ";" wrk.party ";"
                    wrk.drem[1] + wrk.drem[2] + wrk.drem[3] + wrk.drem[4] + wrk.drem[5] ";"
                    wrk.crem[1] + wrk.crem[2] + wrk.crem[3] + wrk.crem[4] + wrk.crem[5] SKIP.

end.
output close.


output to tot.csv.
    for each tot.
        put unformatted tot.crc ";" tot.dc ";" tot.dgl ";" tot.cgl ";" tot.fu ";" tot.res ";" XLS-NUMBER (tot.sum) ";" tot.numtrx SKIP.
    end.
output close.


unix silent value ("cptwin wrk.csv excel.exe").
unix silent value ("cptwin tot.csv excel.exe").

