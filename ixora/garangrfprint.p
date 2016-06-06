/* garangrfprint.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Вывод на экран и печать клиетского графика и графика амортизации по гарантии
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
        02/09/2013 galina
 * BASES
        BANK
 * CHANGES
*/

{global.i}
def input parameter p-garan as char.

def  temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    index idx is primary stdat.

def button b-print label "Вывод графика клиента".
def button b-print2 label "Вывод графика амортизации".
def button b-exit label "Выход".
define stream m-out.
def var v-sumtot as deci.
def var v-dt as date.
def var v-dt1 as date.
def var v-sum as deci.
def var i as int.

DEFINE QUERY q-wrk FOR wrk.
DEFINE BROWSE b-wrk QUERY q-wrk
       DISPLAY
       wrk.nn label "N" format "99"
       wrk.stdat label "Дата" format "99/99/9999"
       wrk.od label "Сумма" format ">>>>>>>>>>>9.99"
       WITH  15 DOWN width 70 title 'График по гарантии ' + p-garan.
DEFINE FRAME f-wrk
b-wrk skip b-print b-print2 b-exit
WITH overlay SIDE-LABELS row 10 COLUMN 20 width 72.


function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.


on choose of b-exit in frame f-wrk do:
  apply "window-close" to frame f-wrk.
  hide frame f-wrk  no-pause.
end.
on "end-error" of frame f-wrk do:
  apply "window-close" to frame f-wrk.
  hide frame f-wrk  no-pause.
end.
on choose of b-print in frame f-wrk do:

    output stream m-out to garngraf.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>График платежей по комиссии<br>Гарантия " + garan.garnum + " от " + string(garan.dtfrom,'99/99/9999') + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ платежа</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата платежа</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Сумма платежа </td></tr>" skip.

    for each wrk no-lock:

        put stream m-out unformatted  "<tr>"
                                      "<td>" wrk.nn "</td>"
                                      "<td>" string(wrk.stdat,'99/99/9999') "</td>"
                                      "<td>" replace(replace(trim(string(wrk.od,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td></tr>" skip.
    end.
    put stream m-out unformatted "<tr style=""font:bold""><td>ИТОГО</td><td></td><td>" + replace(replace(trim(string(v-sumtot,'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') + "</td></tr>" skip.

    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin garngraf.htm excel.
end.
on choose of b-print2 in frame f-wrk do:
    if v-sumtot > 0 then do:
       find first wrk no-lock.
       if avail wrk then do:
            output stream m-out to garngraf2.htm.
            put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                         "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                         "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

            put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                         "<p><b>График амортизации комиссии<br>Гарантия " + garan.garnum + " от " + string(garan.dtfrom,'99/99/9999') + "</b></p>".
            put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                         "<tr style=""font:bold"">"
                                         "<td bgcolor=""#C0C0C0"" align=""center"">№ платежа</td>"
                                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата платежа</td>"
                                         "<td bgcolor=""#C0C0C0"" align=""center"">Сумма платежа </td></tr>" skip.
            i = 0.
            repeat:
                 i = i + 1.

                 put stream m-out unformatted  "<tr>".
                 put stream m-out unformatted "<td>" i "</td>".

                 if i = 1 then assign v-dt = date(trim(garan.info[2]))
                                       v-sum = round((date(trim(garan.info[2])) - garan.dtfrom) * (v-sumtot / (garan.dtto - garan.dtfrom)),2)
                                       v-dt1 = v-dt.
                 else do:
                    v-dt = get-date(date(trim(garan.info[2])),i - 1).

                    if v-dt >= garan.dtto then v-dt = garan.dtto.
                    v-sum = round((v-dt - v-dt1) * (v-sumtot / (garan.dtto - garan.dtfrom)),2).


                    v-dt1 = v-dt.

                 end.

                 put stream m-out unformatted "<td>" string(v-dt,'99/99/9999') "</td>"
                                              "<td>" replace(replace(trim(string(v-sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td></tr>" skip.
                 if v-dt >= garan.dtto then leave.
            end.

            put stream m-out unformatted "<tr style=""font:bold""><td>ИТОГО</td><td></td><td>" + replace(replace(trim(string(v-sumtot,'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') + "</td></tr>" skip.
            put stream m-out unformatted "</table></body></html>" skip.
            output stream m-out close.
            unix silent cptwin garngraf2.htm excel.

       end.

    end.
end.


find first garancomgraf where garancomgraf.garan = p-garan no-lock no-error.
if not avail garancomgraf then do:
   message "По данной гарантии не найден график!" view-as alert-box.
   return.
end.

empty temp-table wrk.
find first garan where garan.garan = p-garan no-lock no-error.

v-sumtot = 0.
for each garancomgraf where garancomgraf.garan = p-garan no-lock:
     create wrk.
     assign wrk.nn = garancomgraf.num
            wrk.stdat = garancomgraf.dtcom
            wrk.od = garancomgraf.comsum
            v-sumtot = v-sumtot + wrk.od.
end.

find first wrk no-lock no-error.
if avail wrk then do:
    open query q-wrk for each wrk.
    enable all with frame f-wrk.
end.
WAIT-FOR  window-close of frame f-wrk focus browse b-wrk.


