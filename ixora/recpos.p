/* recpos.p
 * MODULE
        Отчет по клиентам банка
 * DESCRIPTION
        Отчет по переоценке внебалансовой валютной позиции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
        11.5.13
 * BASES
        BANK
 * AUTHOR
        26.02.2004 tsoy
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       25/04/2012 evseev  - rebranding. Название банка из sysc.
 */

{html_stuff.i}
{mainhead.i}
{nbankBik.i}

def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".

def var v-req  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.
def var v-liab as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.
def var v-cur_sum as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'init 0.

def var v-today-rate as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.
def var v-prev-rate  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.

def var v-cur_tot  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.

define stream m-out.
output stream m-out to rptcur.html.

form
  v-dtb  format "99/99/9999" label " Начальная дата периода "
    help " Введите дату начала периода"
    validate (v-dtb <= g-today - 1, " Дата не может быть больше " + string (g-today - 1)) skip

  v-dte  format "99/99/9999" label " Конечная дата периода  "
    help " Введите дату конца периода"
    validate (v-dte <= g-today - 1, " Дата не может быть больше " + string (g-today - 1)) skip

  with overlay width 78 centered row 6 side-label title " Параметры отчета "  frame f-period.

def temp-table posit
    field posit_date        like glday.gdt
    field posit_cur         like crc.code
    field posit_req         as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'
    field posit_liab        as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'
    field posit_bal         as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'
    field posit_prev_rate   as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'
    field posit_today_rate  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'
    field posit_rate_dif    as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'.

def var i as date.

def temp-table t-currency
    field crc as integer
    field code like crc.code
    index main is primary crc.

def temp-table t-glreq
    field gl like glday.gl
    index main is primary gl.

def temp-table t-glliab
    field gl like glday.gl
    index main is primary gl.

def var v-cur as char  init "2,3,4".

def var v-glreq as char  init  "640511,640521".
def var v-glliab as char  init "690511,690521".

def var j as integer initial 0.

do j = 1 to num-entries(v-cur) :
    find first crc where crc.crc = integer (entry (j, v-cur)) no-lock no-error.
    if  avail crc then do:
       create t-currency.
       assign  t-currency.crc  = integer (entry(j, v-cur ))
               t-currency.code = crc.code.
    end.
end.

do j = 1 to num-entries(v-glreq) :
    create t-glreq.
    t-glreq.gl = integer(entry(j, v-glreq)).
end.

do j = 1 to num-entries(v-glliab) :
    create t-glliab.
    t-glliab.gl = integer(entry(j, v-glliab)).
end.

  v-dte = g-today - 1.
  update v-dtb v-dte with frame f-period.

/* BEGIN */
do i = v-dtb to v-dte :
       for each t-currency no-lock.

          find last crchis where crchis.regdt <= i
                                 and crchis.crc = t-currency.crc no-lock no-error.
          if avail crchis then
                     v-today-rate =  round(crchis.rate[1],2).

          find last crchis where crchis.regdt <= i - 1
                                 and crchis.crc = t-currency.crc no-lock no-error.
          if avail crchis then
                     v-prev-rate =  round(crchis.rate[1],2).

          for each t-glreq no-lock.
              find last glday where glday.gdt <= i
                                    and glday.crc = t-currency.crc
                                    and glday.gl  = t-glreq.gl no-lock no-error.
                         if avail glday then
                         v-req =  v-req + round(glday.bal,2).
          end.

          for each t-glliab no-lock.
              find last glday where glday.gdt <= i
                                     and glday.crc = t-currency.crc
                                     and glday.gl  = t-glliab.gl no-lock no-error.
              if avail glday then
                         v-liab =  v-liab + round(glday.bal,2).
          end.

             create posit.
             assign
                 posit_date        = i
                 posit_cur         = t-currency.code
                 posit_req         = v-req
                 posit_liab        = v-liab
                 posit_bal         = round((v-req - v-liab),2)
                 posit_prev_rate   = v-prev-rate
                 posit_today_rate  = v-today-rate
                 posit_rate_dif    = round(((v-req - v-liab) * (v-today-rate - v-prev-rate)),2).

          v-req = 0.
          v-liab = 0.
       end.

end. /* do */

put stream m-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3>Отчет по переоценке внебалансовой валютной позиции<br>" skip
                 v-dtb " по " v-dte "</h3>" skip.
for each posit break by posit_cur by posit_date:

accumulate posit.posit_rate_dif (TOTAL by posit.posit_cur).

if first-of(posit.posit_cur) then do:

       put stream m-out unformatted  "<br><b>Валюта : " posit_cur "</b>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.
       put stream m-out unformatted "<tr style=""font:bold"">"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Требования <br>на конец дня</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Обязательства <br>на конец дня</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Позиция <br>на конец дня</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Курс <br> предыдущего дня </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Курс текущий </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Курсовая <br>разница</td>"
                         "</tr>" skip.
end.
put stream m-out  unformatted "<tr style=""font:bold"">"
                   "<td>" posit_date       "</td>"
                   "<td>" replace(trim(string(posit_req, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")        "</td>"  skip
                   "<td>" replace(trim(string(posit_liab, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")       "</td>"  skip
                   "<td>" replace(trim(string(posit_bal, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")        "</td>"  skip
                   "<td>" replace(trim(string(posit_prev_rate, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"  skip
                   "<td>" replace(trim(string(posit_today_rate, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") " </td>" skip
                   "<td>" replace(trim(string(posit_rate_dif, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                   "</tr>" skip.

if last-of(posit.posit_cur) then do:
   v-cur_sum = ACCUM total by (posit.posit_cur) posit.posit_rate_dif.
   put stream m-out unformatted
   "<tr><td colspan = ""6"" align= right><b>Итого</b></td><td><b>"  replace(trim(string(v-cur_sum, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</b></td>" skip
   "</table>".
   v-cur_tot = v-cur_tot + v-cur_sum.
end.
end.

put stream m-out unformatted "<br><b>"
                  "<pre>                                                   Итого курсовая разница:" replace(trim(string(v-cur_tot, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</pre>" skip.

output stream m-out close.
unix silent cptwin rptcur.html excel.



