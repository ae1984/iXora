/* r-gl1858.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Проверка счета 1858
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-gl1858f.p
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        10/04/2012 id00810
 * CHANGES
        18/05/2012 id00810 - отчет формируется за период
*/

{mainhead.i}

def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field dt       as date
  field crc      as int
  field crc_code as char
  field jh       as int
  field amtv     as deci
  field amtt     as deci
  field amt      as deci
  field razn     as deci
  field amtdr    as deci
  field razn1    as deci
  field rate     as deci
  field rate_op  as deci
  field ofc      as char
  index idx is primary bank crc jh.
def var v-branch as logi no-undo.
def stream m-out.

  update
     v-dt1 label "Начало периода "
           help " Дата начала отчетного периода " skip
     v-dt2 label " Конец периода "
           help " Дата окончания отчетного периода " skip
     with row 8 centered  side-label frame opt1 title " Параметры отчета ".
     hide frame  opt1.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
if txb.is_branch then v-branch = true.

if v-branch = true then do:
     if connected ("txb") then disconnect "txb".
     find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
     connect value(" -db " + replace(txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
     run r-gl1858f(txb.name).
     if connected ("txb") then disconnect "txb".
end.
else do:
     {r-brfilial.i &proc = "r-gl1858f (txb.info)"}
end.

output stream m-out to r-gl1858.htm.
put stream m-out unformatted "<html><head><title></title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find first cmp no-lock no-error.
put stream m-out unformatted "<br><br>" cmp.name "<br>" skip.

if v-select > 1 then do:
    find first txb where txb.txb = (v-select - 2) no-lock no-error.
    put stream m-out unformatted txb.info "<br>" skip.
end.
put stream m-out unformatted "<br>" "Проверка расхождений по счету ГК 185800".
find first gl where gl.gl = 185800 no-lock no-error.
if avail gl then put stream m-out unformatted " " + gl.des.
put stream m-out unformatted "<br>" skip
                             "за период с " v-dt1 " по " v-dt2 "<br>" skip.

for each wrk no-lock break by wrk.crc by wrk.bank :
    if first-of(wrk.crc) then do:
        put stream m-out unformatted "<br>Валюта: " + wrk.crc_code + "<br>" skip.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Вал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма операции в валюте</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Эквивалент в тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма операции в тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Доход/расход операции</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Доход/расход по расчету</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Расхождение</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ID</td>"
                  "</tr>" skip.
    end.

    put stream m-out unformatted
              "<tr>"
              "<td>" wrk.bankn "</td>"
              "<td>" wrk.dt "</td>"
              "<td>" wrk.jh "</td>"
              "<td>" wrk.crc_code "</td>"
              "<td>" replace(trim(string(wrk.amtv, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.amtt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.amt,  ">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.amtdr,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.razn, "->>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.razn1,"->>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" wrk.ofc "</td>"
              "</tr>" skip.

    if last-of(wrk.crc) then do:
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
    end.
end.
output stream m-out close.
unix silent cptwin r-gl1858.htm excel.
