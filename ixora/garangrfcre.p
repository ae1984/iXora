/* garangrfcre.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Создает график по оплате комиссии для гарантии
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

def input parameter p-garan as char.
def input parameter p-dtform as date.
def input parameter p-dtend as date.
def input parameter p-mdate as date.
def input parameter p-msum as deci.
def output parameter p-sumtot as deci.


def var i as int no-undo.
def var v-dt as date no-undo.
def var v-dt1 as date no-undo.
def var v-sum as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.

def button b-exit label "Выход".
def button b-save label "Сохранить".
/*def button b-print label "Печать".*/
def  temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field days as int
    index idx is primary stdat.

DEFINE QUERY q-wrk FOR wrk.
DEFINE BROWSE b-wrk QUERY q-wrk
       DISPLAY
       wrk.nn label "N" format "99"
       wrk.stdat label "Дата" format "99/99/9999"
       wrk.od label "Сумма" format ">>>>>>>>>>>9.99"
       wrk.days label "Дней" format ">9"
       WITH  15 DOWN title 'График по гарантии ' + p-garan.
DEFINE FRAME f-wrk
b-wrk skip b-save /*b-print*/ b-exit
WITH overlay SIDE-LABELS row 5 COLUMN 20 centered.

on choose of b-exit in frame f-wrk do:
  apply "window-close" to frame f-wrk.
  hide frame f-wrk no-pause.
end.
on "end-error" of frame f-wrk do:
  apply "window-close" to frame f-wrk.
  hide frame f-wrk no-pause.
end.

/***********
define stream m-out.
def var v-sumtot as deci.

on choose of b-print in frame f-wrk do:
    find first garan where garan.garan = p-garan no-lock no-error.
    output stream m-out to garngraf.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>График платежей по комиссии<br>Гарантия " + garan.garnum + " от " + string(garan.dtfrom,'99/99/9999') "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ платежа</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата платежа</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Сумма платежа </td></tr>" skip.

    v-sumtot = 0.
    for each wrk no-lock:
        v-sumtot = v-sumtot + wrk.od.
        put stream m-out unformatted
        "<tr>".

        put stream m-out unformatted "<td>" wrk.nn "</td>".
        put stream m-out unformatted
        "<td>" string(wrk.stdat,'99/99/9999') "</td>"
        "<td>" replace(replace(trim(string(wrk.od,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td></tr>" skip.
    end.
    put stream m-out unformatted "<tr style=""font:bold""><td>ИТОГО</td><td></td><td>" + replace(replace(trim(string(v-sumtot,'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') + "</td></tr>" skip.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin garngraf.htm excel.
end.

**********/

on choose of b-save in frame f-wrk do:
   find first wrk no-lock no-error.
   if avail wrk then do transaction:

       for each wrk no-lock:
         find first garancomgraf where garancomgraf.garan = p-garan and garancomgraf.num = wrk.nn no-lock no-error.
         if avail garancomgraf then do:
             find current garancomgraf exclusive-lock.
             assign garancomgraf.dtcom = wrk.stdat
                    garancomgraf.comsum = wrk.od
                    garancomgraf.uwhn = g-today
                    garancomgraf.uwho = g-ofc.
             find current garancomgraf no-lock.

         end.
         else do:
              create garancomgraf.
              assign garancomgraf.garan = p-garan
                     garancomgraf.num = wrk.nn
                     garancomgraf.dtcom = wrk.stdat
                     garancomgraf.comsum = wrk.od
                     garancomgraf.rwhn = g-today
                     garancomgraf.rwho = g-ofc.
         end.
       end.
       message "График сохранен" view-as alert-box.
   end.
end.

empty temp-table wrk.
p-sumtot = 0.
repeat:
   i = i + 1.
   if i = 1 then do:
       v-dt = p-mdate.
       run day-360(p-dtform,v-dt - 1,360,output dn1,output dn2).
       v-sum = round(dn1 * p-msum / 30,2).
   end.
   else do:
       v-dt = get-date(p-mdate,i - 1).
       if v-dt >= p-dtend then v-dt = p-dtend.
       run day-360(v-dt1,v-dt - 1,360,output dn1,output dn2).
       v-sum = round(dn1 * p-msum / 30,2).
   end.

   create wrk.
   assign wrk.nn = i
          wrk.stdat = v-dt
          wrk.od = v-sum
          wrk.days = dn1.
   p-sumtot = p-sumtot + wrk.od.
   v-dt1 = v-dt.
   if v-dt >= p-dtend then leave.
end.
find first wrk no-lock no-error.
if avail wrk then do:

    open query q-wrk for each wrk.
    enable all with frame f-wrk.
end.

WAIT-FOR window-close of frame f-wrk  focus browse b-wrk.
