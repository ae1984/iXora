/* proviz.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет о движении провизий
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.20
 * AUTHOR
        16/05/2011 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        01/07/2011 dmitriy - добавил сводный отчет
        01/12/2011 dmitriy - добавил возможность выбора вида провизий (МСФО или АФН)
        15/03/2012 id00810 - использование v-bankn для печати
        27/03/2012 dmitriy - убрал r-branch2.i
*/

{global.i}

def new shared var dat1 as date.
def new shared var dat2 as date.
def new shared var v-reptype as integer no-undo.
def new shared var v-prov_type as integer no-undo.
v-reptype = 1.
v-prov_type = 1.

def new shared temp-table wrk
   field cif as char
   field gl as char
   field cifname as char
   field branch as char
   field longr as char
   field crc as char
   field begin-bal as decimal
   field res_prc as decimal
   field res1-od as decimal
   field res1-begin as decimal
   field res1-shtr as decimal
   field res1-sum as decimal
   field sozd-od as decimal
   field sozd-begin as decimal
   field sozd-shtr as decimal
   field sozd-sum as decimal
   field storn-od as decimal
   field storn-begin as decimal
   field storn-shtr as decimal
   field storn-sum as decimal
   field res2-od as decimal
   field res2-begin as decimal
   field res2-shtr as decimal
   field res2-sum as decimal
   field chng-rate as decimal
   field end-bal as decimal.

def temp-table wrk2
   field reptype as int
   field branch as char
   field res1-od as decimal
   field res1-begin as decimal
   field res1-shtr as decimal
   field res1-sum as decimal
   field sozd-od as decimal
   field sozd-begin as decimal
   field sozd-shtr as decimal
   field sozd-sum as decimal
   field storn-od as decimal
   field storn-begin as decimal
   field storn-shtr as decimal
   field storn-sum as decimal
   field profit-od as decimal
   field profit-begin as decimal
   field profit-shtr as decimal
   field profit-sum as decimal
   field res2-od as decimal
   field res2-begin as decimal
   field res2-shtr as decimal
   field res2-sum as decimal
   field chng-rate as decimal.

   def var v-res1-od as decimal extent 3.
   def var v-res1-begin as decimal extent 3.
   def var v-res1-shtr as decimal extent 3.
   def var v-res1-sum as decimal extent 3.
   def var v-sozd-od as decimal extent 3.
   def var v-sozd-begin as decimal extent 3.
   def var v-sozd-shtr as decimal extent 3.
   def var v-sozd-sum as decimal extent 3.
   def var v-storn-od as decimal extent 3.
   def var v-storn-begin as decimal extent 3.
   def var v-storn-shtr as decimal extent 3.
   def var v-storn-sum as decimal extent 3.
   def var v-profit-od as decimal extent 3.
   def var v-profit-begin as decimal extent 3.
   def var v-profit-shtr as decimal extent 3.
   def var v-profit-sum as decimal extent 3.
   def var v-res2-od as decimal extent 3.
   def var v-res2-begin as decimal extent 3.
   def var v-res2-shtr as decimal extent 3.
   def var v-res2-sum as decimal extent 3.
   def var v-chng-rate as decimal extent 3.


   def var v-repname as char no-undo extent 5.
   v-repname[1] = "МСБ ЮЛ".
   v-repname[2] = "МСБ ФЛ".
   v-repname[3] = "Физ.лиц.".
   v-repname[4] = "Все".
   v-repname[5] = "Сводный отчет".

   def var summm as decimal extent 5.
   def var profit as decimal extent 4.
   def var v-branch as char.
   def var v-bankn   as char no-undo.

   update dat1 format "99/99/9999" label "Введите дату С "
          dat2 format "99/99/9999" label  "По" with centered frame www row 1 col 5.

   update v-prov_type label ' Вид провизий ' format "9" validate (v-prov_type > 0 and v-prov_type < 3, " Вид провизий - МСФО или АФН ")
   help "1-Провизии по МСФО,  2-Провизии по АФН"
   with side-label row 5 centered frame prov_type.

   if v-prov_type = 1 then do:
       update v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5 ")
       help "1-МСБ ЮЛ, 2-МСБ ФЛ, 3-Физ.лиц, 4-Все, 5-Сводный отчет"
           with side-label row 5 centered frame dat.
   end.
   if v-prov_type = 2 then do:
       update v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 5, " Тип отчета - 1, 2, 3 или 4 ")
       help "1-МСБ ЮЛ, 2-МСБ ФЛ, 3-Физ.лиц, 4-Все"
           with side-label row 5 centered frame dat1.
   end.

   find first sysc where sysc.sysc = "bankname" no-lock no-error.
   if avail sysc then v-bankn = sysc.chval.

  /* ОТЧЕТЫ 1,2,3,4 для МСФО */
  if v-reptype <> 5 and v-prov_type = 1 then do:

      {r-brfilial.i &proc = "proviz-2"}

      define stream m-out.
      output stream m-out to proviz.html.

      put stream m-out "<html><head><title></title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"">"
                     skip.

       put stream m-out  unformatted "<tr align=""center""><td>Отчет о движении провизий ("  v-repname[v-reptype] ")" "<br>"
                         v-bankname "<br>"
                       "с " dat1 format "99.99.9999" " по " dat2 format "99.99.9999"

                       "</td></tr><br><br>"
                     skip(2).
      put stream m-out "<br><br><tr></tr>".


      put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse" ">" skip
                      "<tr style=""font:bold" "" ">"
                      "<td rowspan=""2"" align=""center"">Код клиента</td>"
                      "<td rowspan=""2"" align=""center"">Счет<br>главной книги</td>"
                      "<td rowspan=""2"" align=""center"">ФИО или<br>наименование<br>компании</td>"
                      "<td rowspan=""2"" align=""center"">Наименование<br>филиала</td>"
                      "<td rowspan=""2"" align=""center"">Группа<br>кредита</td>"
                      "<td rowspan=""2"" align=""center"">Вид<br>валюты</td>"
                      "<td rowspan=""2"" align=""center"">Остаток ОД<br>на начало периода</td>"
                      "<td rowspan=""2"" align=""center"">Размер<br>резерва<br>в (%)</td>"
                      "<td colspan=""4"" align=""center"">Резерв на начало периода</td>"
                      "<td colspan=""4"" align=""center"">Досоздано провизий за месяц</td>"
                      "<td colspan=""4"" align=""center"">Сторнировано провизий за месяц</td>"
                      "<td colspan=""4"" align=""center"">Резерв на конец периода</td>"
                      "<td rowspan=""2"" align=""center"">Курсовые изменения</td>"
                      "<td rowspan=""2"" align=""center"">Остаток ОД<br>на конец<br>периода</td>"
                      "</tr>"

                      "<td  align=""center"">Резерв на ОД<br>(6 ур.)</td>"
                      "<td  align=""center"">Резерв на<br>нач.возн.<br>(36 ур.)</td>"
                      "<td  align=""center"">Резерв по<br>штрафам<br>(37 ур.)</td>"
                      "<td  align=""center"">Общая<br>сумма<br>резерва</td>"

                      "<td  align=""center"">Резерв на ОД<br>(6 ур.)</td>"
                      "<td  align=""center"">Резерв на<br>нач.возн.<br>(36 ур.)</td>"
                      "<td  align=""center"">Резерв по<br>штрафам<br>(37 ур.)</td>"
                      "<td  align=""center"">Общая<br>сумма<br>резерва</td>"

                      "<td  align=""center"">Резерв на ОД<br>(6 ур.)</td>"
                      "<td  align=""center"">Резерв на<br>нач.возн.<br>(36 ур.)</td>"
                      "<td  align=""center"">Резерв по<br>штрафам<br>(37 ур.)</td>"
                      "<td  align=""center"">Общая<br>сумма<br>резерва</td>"

                      "<td  align=""center"">Резерв на ОД<br>(6 ур.)</td>"
                      "<td  align=""center"">Резерв на<br>нач.возн.<br>(36 ур.)</td>"
                      "<td  align=""center"">Резерв по<br>штрафам<br>(37 ур.)</td>"
                      "<td  align=""center"">Общая<br>сумма<br>резерва</td>"
                      "</tr>".


      for each wrk no-lock:
      if (wrk.begin-bal = 0 and wrk.res1-od = 0 and wrk.res1-begin = 0 and wrk.res1-shtr = 0
                            and wrk.res2-od = 0 and wrk.res2-begin = 0 and wrk.res2-shtr = 0
                            and end-bal = 0) then next.
         put stream m-out unformatted
         "<tr>"
              "<td  align=""right"">" wrk.cif "</td>"
              "<td  align=""right"">" wrk.gl "</td>"
              "<td  align=""right"">" wrk.cifname "</td>"
              "<td  align=""right"">" wrk.branch "</td>"
              "<td  align=""right"">" wrk.longr "</td>"
              "<td  align=""right"">" wrk.crc "</td>"
              "<td  align=""right"">" replace(string(wrk.begin-bal),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res_prc),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res1-od),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res1-begin),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res1-shtr),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res1-sum),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.sozd-od),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.sozd-begin),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.sozd-shtr),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.sozd-sum),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.storn-od),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.storn-begin),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.storn-shtr),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.storn-sum),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res2-od),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res2-begin),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res2-shtr),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.res2-sum),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.chng-rate),".",",") "</td>"
              "<td  align=""right"">" replace(string(wrk.end-bal),".",",") "</td>"
         "</tr>".
      end. /* for each wrk */

     put stream m-out "</table>" skip.


     put stream m-out "</body></html>" skip.


     output stream m-out close.
     unix silent cptwin proviz.html excel.exe.
     unix silent rm proviz.html.
  end. /* if v-reptype <> 5 */



  /* СВОДНЫЙ ОТЧЕТ */
  if v-reptype = 5 and v-prov_type = 1 then do:

      define stream m-out.
      output stream m-out to proviz2.html.

      put stream m-out "<html><head><title></title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"">"
                     skip.

      put stream m-out  unformatted "<tr align=""center""><td>Сводный отчет по провизиям за период с " dat1 " по " dat2 "<br>"

                     "</td></tr><br><br>"
                     skip(2).
      put stream m-out "<br><br><tr></tr>".


      put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse" ">" skip
                      "<tr style=""font:bold" "" ">"
                      "<td rowspan=""2"" align=""center"">Наименование</td>"
                      "<td colspan=""4"" align=""center"">Провизии на " dat1 "</td>"
                      "<td colspan=""4"" align=""center"">Досоздано провизий</td>"
                      "<td colspan=""4"" align=""center"">Сторнировано провизий</td>"
                      "<td colspan=""4"" align=""center"">Чистый рост/снижение провизий</td>"
                      "<td align=""center"">Курсовая разница</td>"
                      "<td colspan=""4"" align=""center"">Провизии на " dat2 + 1 "</td>"
                      "</tr>"

                      "<td bgcolor=""#ffff80"" align=""center"">На ОД</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">На %</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">По штрафам</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">Итого</td>"

                      "<td bgcolor=""#ffff80"" align=""center"">На ОД</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">На %</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">По штрафам</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">Итого</td>"

                      "<td bgcolor=""#ffff80"" align=""center"">На ОД</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">На %</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">По штрафам</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">Итого</td>"

                      "<td bgcolor=""#ffff80"" align=""center"">На ОД</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">На %</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">По штрафам</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">Итого</td>"

                      "<td bgcolor=""#ffff80""></td>"

                      "<td bgcolor=""#ffff80"" align=""center"">На ОД</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">На %</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">По штрафам</td>"
                      "<td bgcolor=""#ffff80"" align=""center"">Итого</td>"
                      "</tr>".

      v-reptype = 1.

     for each comm.txb where comm.txb.consolid no-lock:
         if connected ("txb") then disconnect "txb".
         connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
         run proviz-2.
     end.
     if connected ("txb") then disconnect "txb".


      for each wrk break by wrk.branch desc by wrk.cif.

          accumulate wrk.res1-od (TOTAL by wrk.branch).
          accumulate wrk.res1-begin (TOTAL by wrk.branch).
          accumulate wrk.res1-shtr (TOTAL by wrk.branch).
          accumulate wrk.res1-sum (TOTAL by wrk.branch).

          accumulate wrk.sozd-od (TOTAL by wrk.branch).
          accumulate wrk.sozd-begin (TOTAL by wrk.branch).
          accumulate wrk.sozd-shtr (TOTAL by wrk.branch).
          accumulate wrk.sozd-sum (TOTAL by wrk.branch).

          accumulate wrk.storn-od (TOTAL by wrk.branch).
          accumulate wrk.storn-begin (TOTAL by wrk.branch).
          accumulate wrk.storn-shtr (TOTAL by wrk.branch).
          accumulate wrk.storn-sum (TOTAL by wrk.branch).

          accumulate wrk.res2-od (TOTAL by wrk.branch).
          accumulate wrk.res2-begin (TOTAL by wrk.branch).
          accumulate wrk.res2-shtr (TOTAL by wrk.branch).
          accumulate wrk.res2-sum (TOTAL by wrk.branch).

          if last-of(wrk.branch) then do:

              summm[1] = accum total by wrk.branch wrk.res1-sum.
              summm[2] = accum total by wrk.branch wrk.sozd-sum.
              summm[3] = accum total by wrk.branch wrk.storn-sum.
              summm[4] = accum total by wrk.branch wrk.res2-sum.
              summm[5] = summm[1] + (summm[2] + summm[3]) - summm[4].

              profit[1] = (accum total by wrk.branch wrk.res2-od) - (accum total by wrk.branch wrk.res1-od).
              profit[2] = (accum total by wrk.branch wrk.res2-begin) - (accum total by wrk.branch wrk.res1-begin).
              profit[3] = (accum total by wrk.branch wrk.res2-shtr) - (accum total by wrk.branch wrk.res1-shtr).
              profit[4] = (accum total by wrk.branch wrk.res2-sum) - (accum total by wrk.branch wrk.res1-sum).

              run branch-name.

              create wrk2.
              wrk2.reptype = v-reptype.
              wrk2.branch = v-branch.
              wrk2.res1-od = accum total by wrk.branch wrk.res1-od.
              wrk2.res1-begin = accum total by wrk.branch wrk.res1-begin.
              wrk2.res1-shtr = accum total by wrk.branch wrk.res1-shtr.
              wrk2.res1-sum = accum total by wrk.branch wrk.res1-sum.
              wrk2.sozd-od = accum total by wrk.branch wrk.sozd-od.
              wrk2.sozd-begin = accum total by wrk.branch wrk.sozd-begin.
              wrk2.sozd-shtr = accum total by wrk.branch wrk.sozd-shtr.
              wrk2.sozd-sum = accum total by wrk.branch wrk.sozd-sum.
              wrk2.storn-od = accum total by wrk.branch wrk.storn-od.
              wrk2.storn-begin = accum total by wrk.branch wrk.storn-begin.
              wrk2.storn-shtr  = accum total by wrk.branch wrk.storn-shtr.
              wrk2.storn-sum = accum total by wrk.branch wrk.storn-sum.
              wrk2.profit-od = profit[1].
              wrk2.profit-begin = profit[2].
              wrk2.profit-shtr = profit[3].
              wrk2.profit-sum = profit[4].
              wrk2.res2-od = accum total by wrk.branch wrk.res2-od.
              wrk2.res2-begin = accum total by wrk.branch wrk.res2-begin.
              wrk2.res2-shtr = accum total by wrk.branch wrk.res2-shtr.
              wrk2.res2-sum = accum total by wrk.branch wrk.res2-sum.
              wrk2.chng-rate = summm[5].

          end.
      end.


      for each wrk no-lock:
         delete wrk.
      end.
      summm[1] = 0. summm[2] = 0. summm[3] = 0. summm[4] = 0. summm[5] = 0.
      profit[1] = 0. profit[2] = 0. profit[3] = 0. profit[4] = 0.


      v-reptype = 2.

     for each comm.txb where comm.txb.consolid no-lock:
         if connected ("txb") then disconnect "txb".
         connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
         run proviz-2.
     end.
     if connected ("txb") then disconnect "txb".


      for each wrk break by wrk.branch desc by wrk.cif.

          accumulate wrk.res1-od (TOTAL by wrk.branch).
          accumulate wrk.res1-begin (TOTAL by wrk.branch).
          accumulate wrk.res1-shtr (TOTAL by wrk.branch).
          accumulate wrk.res1-sum (TOTAL by wrk.branch).

          accumulate wrk.sozd-od (TOTAL by wrk.branch).
          accumulate wrk.sozd-begin (TOTAL by wrk.branch).
          accumulate wrk.sozd-shtr (TOTAL by wrk.branch).
          accumulate wrk.sozd-sum (TOTAL by wrk.branch).

          accumulate wrk.storn-od (TOTAL by wrk.branch).
          accumulate wrk.storn-begin (TOTAL by wrk.branch).
          accumulate wrk.storn-shtr (TOTAL by wrk.branch).
          accumulate wrk.storn-sum (TOTAL by wrk.branch).

          accumulate wrk.res2-od (TOTAL by wrk.branch).
          accumulate wrk.res2-begin (TOTAL by wrk.branch).
          accumulate wrk.res2-shtr (TOTAL by wrk.branch).
          accumulate wrk.res2-sum (TOTAL by wrk.branch).

          if last-of(wrk.branch) then do:

              summm[1] = accum total by wrk.branch wrk.res1-sum.
              summm[2] = accum total by wrk.branch wrk.sozd-sum.
              summm[3] = accum total by wrk.branch wrk.storn-sum.
              summm[4] = accum total by wrk.branch wrk.res2-sum.
              summm[5] = summm[1] + (summm[2] + summm[3]) - summm[4].

              profit[1] = (accum total by wrk.branch wrk.res2-od) - (accum total by wrk.branch wrk.res1-od).
              profit[2] = (accum total by wrk.branch wrk.res2-begin) - (accum total by wrk.branch wrk.res1-begin).
              profit[3] = (accum total by wrk.branch wrk.res2-shtr) - (accum total by wrk.branch wrk.res1-shtr).
              profit[4] = (accum total by wrk.branch wrk.res2-sum) - (accum total by wrk.branch wrk.res1-sum).

              run branch-name.

              create wrk2.
              wrk2.reptype = v-reptype.
              wrk2.branch = v-branch.
              wrk2.res1-od = accum total by wrk.branch wrk.res1-od.
              wrk2.res1-begin = accum total by wrk.branch wrk.res1-begin.
              wrk2.res1-shtr = accum total by wrk.branch wrk.res1-shtr.
              wrk2.res1-sum = accum total by wrk.branch wrk.res1-sum.
              wrk2.sozd-od = accum total by wrk.branch wrk.sozd-od.
              wrk2.sozd-begin = accum total by wrk.branch wrk.sozd-begin.
              wrk2.sozd-shtr = accum total by wrk.branch wrk.sozd-shtr.
              wrk2.sozd-sum = accum total by wrk.branch wrk.sozd-sum.
              wrk2.storn-od = accum total by wrk.branch wrk.storn-od.
              wrk2.storn-begin = accum total by wrk.branch wrk.storn-begin.
              wrk2.storn-shtr  = accum total by wrk.branch wrk.storn-shtr.
              wrk2.storn-sum = accum total by wrk.branch wrk.storn-sum.
              wrk2.profit-od = profit[1].
              wrk2.profit-begin = profit[2].
              wrk2.profit-shtr = profit[3].
              wrk2.profit-sum = profit[4].
              wrk2.res2-od = accum total by wrk.branch wrk.res2-od.
              wrk2.res2-begin = accum total by wrk.branch wrk.res2-begin.
              wrk2.res2-shtr = accum total by wrk.branch wrk.res2-shtr.
              wrk2.res2-sum = accum total by wrk.branch wrk.res2-sum.
              wrk2.chng-rate = summm[5].

          end.
      end.


      for each wrk no-lock:
         delete wrk.
      end.
      summm[1] = 0. summm[2] = 0. summm[3] = 0. summm[4] = 0. summm[5] = 0.
      profit[1] = 0. profit[2] = 0. profit[3] = 0. profit[4] = 0.


      v-reptype = 3.

     for each comm.txb where comm.txb.consolid no-lock:
         if connected ("txb") then disconnect "txb".
         connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
         run proviz-2.
     end.
     if connected ("txb") then disconnect "txb".


      for each wrk break by wrk.branch desc by wrk.cif.

          accumulate wrk.res1-od (TOTAL by wrk.branch).
          accumulate wrk.res1-begin (TOTAL by wrk.branch).
          accumulate wrk.res1-shtr (TOTAL by wrk.branch).
          accumulate wrk.res1-sum (TOTAL by wrk.branch).

          accumulate wrk.sozd-od (TOTAL by wrk.branch).
          accumulate wrk.sozd-begin (TOTAL by wrk.branch).
          accumulate wrk.sozd-shtr (TOTAL by wrk.branch).
          accumulate wrk.sozd-sum (TOTAL by wrk.branch).

          accumulate wrk.storn-od (TOTAL by wrk.branch).
          accumulate wrk.storn-begin (TOTAL by wrk.branch).
          accumulate wrk.storn-shtr (TOTAL by wrk.branch).
          accumulate wrk.storn-sum (TOTAL by wrk.branch).

          accumulate wrk.res2-od (TOTAL by wrk.branch).
          accumulate wrk.res2-begin (TOTAL by wrk.branch).
          accumulate wrk.res2-shtr (TOTAL by wrk.branch).
          accumulate wrk.res2-sum (TOTAL by wrk.branch).

          if last-of(wrk.branch) then do:

              summm[1] = accum total by wrk.branch wrk.res1-sum.
              summm[2] = accum total by wrk.branch wrk.sozd-sum.
              summm[3] = accum total by wrk.branch wrk.storn-sum.
              summm[4] = accum total by wrk.branch wrk.res2-sum.
              summm[5] = summm[1] + (summm[2] + summm[3]) - summm[4].

              profit[1] = (accum total by wrk.branch wrk.res2-od) - (accum total by wrk.branch wrk.res1-od).
              profit[2] = (accum total by wrk.branch wrk.res2-begin) - (accum total by wrk.branch wrk.res1-begin).
              profit[3] = (accum total by wrk.branch wrk.res2-shtr) - (accum total by wrk.branch wrk.res1-shtr).
              profit[4] = (accum total by wrk.branch wrk.res2-sum) - (accum total by wrk.branch wrk.res1-sum).

              run branch-name.

              create wrk2.
              wrk2.reptype = v-reptype.
              wrk2.branch = v-branch.
              wrk2.res1-od = accum total by wrk.branch wrk.res1-od.
              wrk2.res1-begin = accum total by wrk.branch wrk.res1-begin.
              wrk2.res1-shtr = accum total by wrk.branch wrk.res1-shtr.
              wrk2.res1-sum = accum total by wrk.branch wrk.res1-sum.
              wrk2.sozd-od = accum total by wrk.branch wrk.sozd-od.
              wrk2.sozd-begin = accum total by wrk.branch wrk.sozd-begin.
              wrk2.sozd-shtr = accum total by wrk.branch wrk.sozd-shtr.
              wrk2.sozd-sum = accum total by wrk.branch wrk.sozd-sum.
              wrk2.storn-od = accum total by wrk.branch wrk.storn-od.
              wrk2.storn-begin = accum total by wrk.branch wrk.storn-begin.
              wrk2.storn-shtr  = accum total by wrk.branch wrk.storn-shtr.
              wrk2.storn-sum = accum total by wrk.branch wrk.storn-sum.
              wrk2.profit-od = profit[1].
              wrk2.profit-begin = profit[2].
              wrk2.profit-shtr = profit[3].
              wrk2.profit-sum = profit[4].
              wrk2.res2-od = accum total by wrk.branch wrk.res2-od.
              wrk2.res2-begin = accum total by wrk.branch wrk.res2-begin.
              wrk2.res2-shtr = accum total by wrk.branch wrk.res2-shtr.
              wrk2.res2-sum = accum total by wrk.branch wrk.res2-sum.
              wrk2.chng-rate = summm[5].

          end.
      end.


    for each wrk2 no-lock:
        if wrk2.reptype = 1 then do:
            v-res1-od[1] = v-res1-od[1] + wrk2.res1-od.
            v-res1-begin[1] = v-res1-begin[1] + wrk2.res1-begin.
            v-res1-shtr[1] = v-res1-shtr[1] + wrk2.res1-shtr.
            v-res1-sum[1] = v-res1-sum[1] + wrk2.res1-sum.

            v-sozd-od[1] = v-sozd-od[1] + wrk2.sozd-od.
            v-sozd-begin[1] = v-sozd-begin[1] + wrk2.sozd-begin.
            v-sozd-shtr[1] = v-sozd-shtr[1] + wrk2.sozd-shtr.
            v-sozd-sum[1] = v-sozd-sum[1] + wrk2.sozd-sum.

            v-storn-od[1] = v-storn-od[1] + wrk2.storn-od.
            v-storn-begin[1] = v-storn-begin[1] + wrk2.storn-begin.
            v-storn-shtr[1] = v-storn-shtr[1] + wrk2.storn-shtr.
            v-storn-sum[1] = v-storn-sum[1] + wrk2.storn-sum.

            v-profit-od[1] = v-profit-od[1] + wrk2.profit-od.
            v-profit-begin[1] = v-profit-begin[1] + wrk2.profit-begin.
            v-profit-shtr[1] = v-profit-shtr[1] + wrk2.profit-shtr.
            v-profit-sum[1] = v-profit-sum[1] + wrk2.profit-sum.

            v-chng-rate[1] = v-chng-rate[1] + wrk2.chng-rate.

            v-res2-od[1] = v-res2-od[1] + wrk2.res2-od.
            v-res2-begin[1] = v-res2-begin[1] + wrk2.res2-begin.
            v-res2-shtr[1] = v-res2-shtr[1] + wrk2.res2-shtr.
            v-res2-sum[1] = v-res2-sum[1] + wrk2.res2-sum.
        end.
        if wrk2.reptype = 2 then do:
            v-res1-od[2] = v-res1-od[2] + wrk2.res1-od.
            v-res1-begin[2] = v-res1-begin[2] + wrk2.res1-begin.
            v-res1-shtr[2] = v-res1-shtr[2] + wrk2.res1-shtr.
            v-res1-sum[2] = v-res1-sum[2] + wrk2.res1-sum.

            v-sozd-od[2] = v-sozd-od[2] + wrk2.sozd-od.
            v-sozd-begin[2] = v-sozd-begin[2] + wrk2.sozd-begin.
            v-sozd-shtr[2] = v-sozd-shtr[2] + wrk2.sozd-shtr.
            v-sozd-sum[2] = v-sozd-sum[2] + wrk2.sozd-sum.

            v-storn-od[2] = v-storn-od[2] + wrk2.storn-od.
            v-storn-begin[2] = v-storn-begin[2] + wrk2.storn-begin.
            v-storn-shtr[2] = v-storn-shtr[2] + wrk2.storn-shtr.
            v-storn-sum[2] = v-storn-sum[2] + wrk2.storn-sum.

            v-profit-od[2] = v-profit-od[2] + wrk2.profit-od.
            v-profit-begin[2] = v-profit-begin[2] + wrk2.profit-begin.
            v-profit-shtr[2] = v-profit-shtr[2] + wrk2.profit-shtr.
            v-profit-sum[2] = v-profit-sum[2] + wrk2.profit-sum.

            v-chng-rate[2] = v-chng-rate[2] + wrk2.chng-rate.

            v-res2-od[2] = v-res2-od[2] + wrk2.res2-od.
            v-res2-begin[2] = v-res2-begin[2] + wrk2.res2-begin.
            v-res2-shtr[2] = v-res2-shtr[2] + wrk2.res2-shtr.
            v-res2-sum[2] = v-res2-sum[2] + wrk2.res2-sum.
        end.
        if wrk2.reptype = 3 then do:
            v-res1-od[3] = v-res1-od[3] + wrk2.res1-od.
            v-res1-begin[3] = v-res1-begin[3] + wrk2.res1-begin.
            v-res1-shtr[3] = v-res1-shtr[3] + wrk2.res1-shtr.
            v-res1-sum[3] = v-res1-sum[3] + wrk2.res1-sum.

            v-sozd-od[3] = v-sozd-od[3] + wrk2.sozd-od.
            v-sozd-begin[3] = v-sozd-begin[3] + wrk2.sozd-begin.
            v-sozd-shtr[3] = v-sozd-shtr[3] + wrk2.sozd-shtr.
            v-sozd-sum[3] = v-sozd-sum[3] + wrk2.sozd-sum.

            v-storn-od[3] = v-storn-od[3] + wrk2.storn-od.
            v-storn-begin[3] = v-storn-begin[3] + wrk2.storn-begin.
            v-storn-shtr[3] = v-storn-shtr[3] + wrk2.storn-shtr.
            v-storn-sum[3] = v-storn-sum[3] + wrk2.storn-sum.

            v-profit-od[3] = v-profit-od[3] + wrk2.profit-od.
            v-profit-begin[3] = v-profit-begin[3] + wrk2.profit-begin.
            v-profit-shtr[3] = v-profit-shtr[3] + wrk2.profit-shtr.
            v-profit-sum[3] = v-profit-sum[3] + wrk2.profit-sum.

            v-chng-rate[3] = v-chng-rate[3] + wrk2.chng-rate.

            v-res2-od[3] = v-res2-od[3] + wrk2.res2-od.
            v-res2-begin[3] = v-res2-begin[3] + wrk2.res2-begin.
            v-res2-shtr[3] = v-res2-shtr[3] + wrk2.res2-shtr.
            v-res2-sum[3] = v-res2-sum[3] + wrk2.res2-sum.
        end.

    end.


    put stream m-out unformatted
    "<tr>"
        "<td  align=""center"">Всего провизий по займам,<br>предоставленным клиентам,<br>в том числе:</td>"

        "<td>" replace(string(v-res1-od[1] + v-res1-od[2] + v-res1-od[3]),".",",") "</td>"
        "<td>" replace(string(v-res1-begin[1] + v-res1-begin[2] + v-res1-begin[3]),".",",") "</td>"
        "<td>" replace(string(v-res1-shtr[1] + v-res1-shtr[2] + v-res1-shtr[3]),".",",") "</td>"
        "<td>" replace(string(v-res1-sum[1] + v-res1-sum[2] + v-res1-sum[3]),".",",") "</td>"

        "<td>" replace(string(v-sozd-od[1] + v-sozd-od[2] + v-sozd-od[3]),".",",") "</td>"
        "<td>" replace(string(v-sozd-begin[1] + v-sozd-begin[2] + v-sozd-begin[3]),".",",") "</td>"
        "<td>" replace(string(v-sozd-shtr[1] + v-sozd-shtr[2] + v-sozd-shtr[3]),".",",") "</td>"
        "<td>" replace(string(v-sozd-sum[1] + v-sozd-sum[2] + v-sozd-sum[3]),".",",") "</td>"

        "<td>" replace(string(v-storn-od[1] + v-storn-od[2] + v-storn-od[3]),".",",") "</td>"
        "<td>" replace(string(v-storn-begin[1] + v-storn-begin[2] + v-storn-begin[3]),".",",") "</td>"
        "<td>" replace(string(v-storn-shtr[1] + v-storn-shtr[2] + v-storn-shtr[3]),".",",") "</td>"
        "<td>" replace(string(v-storn-sum[1] + v-storn-sum[2] + v-storn-sum[3]),".",",") "</td>"

        "<td>" replace(string(v-profit-od[1] + v-profit-od[2] + v-profit-od[3]),".",",") "</td>"
        "<td>" replace(string(v-profit-begin[1] + v-profit-begin[2] + v-profit-begin[3]),".",",") "</td>"
        "<td>" replace(string(v-profit-shtr[1] + v-profit-shtr[2] + v-profit-shtr[3]),".",",") "</td>"
        "<td>" replace(string(v-profit-sum[1] + v-profit-sum[2] + v-profit-sum[3]),".",",") "</td>"

        "<td>" replace(string(v-chng-rate[1] + v-chng-rate[2] + v-chng-rate[3]),".",",") "</td>"

        "<td>" replace(string(v-res2-od[1] + v-res2-od[2] + v-res2-od[3]),".",",") "</td>"
        "<td>" replace(string(v-res2-begin[1] + v-res2-begin[2] + v-res2-begin[3]),".",",") "</td>"
        "<td>" replace(string(v-res2-shtr[1] + v-res2-shtr[2] + v-res2-shtr[3]),".",",") "</td>"
        "<td>" replace(string(v-res2-sum[1] + v-res2-sum[2] + v-res2-sum[3]),".",",") "</td>"
    "</tr>"

    "<tr>"
        "<td bgcolor=""#C0C0C0"" align=""right"">Всего МСБ ЮЛ</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-od[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-begin[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-shtr[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-sum[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-od[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-begin[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-shtr[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-sum[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-od[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-begin[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-shtr[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-sum[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-od[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-begin[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-shtr[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-sum[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-chng-rate[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-od[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-begin[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-shtr[1]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-sum[1]),".",",") "</td>"
    "</tr>".

    for each wrk2 where wrk2.reptype = 1 no-lock:
        put stream m-out unformatted
        "<tr>"
            "<td  align=""right"">" replace(string(wrk2.branch),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res1-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.sozd-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.storn-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.profit-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.chng-rate),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res2-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-sum),".",",") "</td>"
        "</tr>".
    end.

    put stream m-out unformatted
    "<tr>"
    "<td  bgcolor=""#C0C0C0"" align=""right"">Всего МСБ ИП</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-od[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-begin[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-shtr[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-sum[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-od[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-begin[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-shtr[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-sum[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-od[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-begin[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-shtr[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-sum[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-od[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-begin[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-shtr[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-sum[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-chng-rate[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-od[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-begin[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-shtr[2]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-sum[2]),".",",") "</td>"
    "</tr>".


    for each wrk2 where wrk2.reptype = 2 no-lock:
        put stream m-out unformatted
        "<tr>"
            "<td  align=""right"">" replace(string(wrk2.branch),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res1-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.sozd-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.storn-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.profit-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.chng-rate),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res2-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-sum),".",",") "</td>"
        "</tr>".
    end.

    put stream m-out unformatted
    "<tr>"
    "<td  bgcolor=""#C0C0C0"" align=""right"">Всего физические лица</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-od[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-begin[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-shtr[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res1-sum[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-od[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-begin[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-shtr[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-sozd-sum[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-od[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-begin[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-shtr[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-storn-sum[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-od[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-begin[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-shtr[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-profit-sum[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-chng-rate[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-od[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-begin[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-shtr[3]),".",",") "</td>"
        "<td bgcolor=""#C0C0C0"" align=""right"">" replace(string(v-res2-sum[3]),".",",") "</td>"
    "</tr>".


    for each wrk2 where wrk2.reptype = 3 no-lock:
        put stream m-out unformatted
        "<tr>"
            "<td  align=""right"">" replace(string(wrk2.branch),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res1-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res1-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.sozd-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.sozd-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.storn-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.storn-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.profit-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.profit-sum),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.chng-rate),".",",") "</td>"

            "<td  align=""right"">" replace(string(wrk2.res2-od),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-begin),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-shtr),".",",") "</td>"
            "<td  align=""right"">" replace(string(wrk2.res2-sum),".",",") "</td>"
        "</tr>".
    end.


     put stream m-out "</table>" skip.

     put stream m-out "</body></html>" skip.


     output stream m-out close.
     unix silent cptwin proviz2.html excel.exe.
     unix silent rm proviz2.html.
  end. /* if v-reptype = 5 */


  /* ОТЧЕТЫ 1,2,3,4 для АФН */
  if v-reptype <> 5 and v-prov_type = 2 then do:

     for each comm.txb where comm.txb.consolid no-lock:
         if connected ("txb") then disconnect "txb".
         connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
         run proviz-2.
     end.
     if connected ("txb") then disconnect "txb".


      define stream m-out.
      output stream m-out to proviz.html.

      put stream m-out "<html><head><title></title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"">"
                     skip.

       put stream m-out  unformatted "<tr align=""center""><td>Отчет о движении провизий ("  v-repname[v-reptype] ")" "<br>"
                         v-bankname "<br>"
                       "с " dat1 format "99.99.9999" " по " dat2 format "99.99.9999"

                       "</td></tr><br><br>"
                     skip(2).
      put stream m-out "<br><br><tr></tr>".


      put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse" ">" skip
                      "<tr style=""font:bold" "" ">"
                      "<td align=""center"">Код клиента</td>"
                      "<td align=""center"">ФИО или<br>наименование<br>компании</td>"
                      "<td align=""center"">Наименование<br>филиала</td>"
                      "<td align=""center"">Группа<br>кредита</td>"
                      "<td align=""center"">Вид<br>валюты</td>"
                      "<td align=""center"">Остаток ОД<br>на начало периода</td>"
                      "<td align=""center"">Размер<br>резерва<br>в (%)</td>"
                      "<td align=""center"">Резерв на начало периода<br>(41 ур.) </td>"
                      "<td align=""center"">Досоздано провизий<br>за месяц<br>(41 ур.)</td>"
                      "<td align=""center"">Сторнировано провизий<br>за месяц<br>(41 ур.)</td>"
                      "<td align=""center"">Резерв на конец периода<br>(41 ур.)</td>"
                      "<td align=""center"">Курсовые изменения</td>"
                      "<td align=""center"">Остаток ОД<br>на конец<br>периода</td>"
                      "</tr>"

                      "</tr>".

              for each wrk no-lock:
              if wrk.begin-bal = 0 and wrk.end-bal = 0 and wrk.res1-sum = 0 and wrk.res2-sum = 0 then next.
                 run branch-name.
                 put stream m-out unformatted
                 "<tr>"
                      "<td  align=""right"">" wrk.cif "</td>"

                      "<td  align=""right"">" wrk.cifname "</td>"
                      "<td  align=""right"">" v-branch "</td>"
                      "<td  align=""right"">" wrk.longr "</td>"
                      "<td  align=""right"">" wrk.crc "</td>"
                      "<td  align=""right"">" replace(string(wrk.begin-bal),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.res_prc),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.res1-sum),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.sozd-sum),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.storn-sum),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.res2-sum),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.chng-rate),".",",") "</td>"
                      "<td  align=""right"">" replace(string(wrk.end-bal),".",",") "</td>"
                 "</tr>".
              end. /* for each wrk */

             put stream m-out "</table>" skip.


             put stream m-out "</body></html>" skip.


             output stream m-out close.
             unix silent cptwin proviz.html excel.exe.
             unix silent rm proviz.html.

  end. /* ОТЧЕТЫ 1,2,3,4 для АФН */

procedure branch-name:
    if wrk.branch matches "*ЮКО*" then v-branch = "Шымкент".
    if wrk.branch matches "*СКО*" then v-branch = "Петропавловск".
    if wrk.branch matches "*Павлодар*" then v-branch = "Павлодар".
    if wrk.branch matches "*Мангистау*" then v-branch = "Актау".
    if wrk.branch matches "*КОСТАНАЙ*" then v-branch = "Костанай".
    if wrk.branch matches "*Караганд*" then v-branch = "Караганда".
    if wrk.branch matches "*ЗКО*" then v-branch = "Уральск".
    if wrk.branch matches "*Жамб*" then v-branch = "Тараз".
    if wrk.branch matches "*ВКО*" then v-branch = "Усть-Каменогорск".
    if wrk.branch matches "*Атырау*" then v-branch = "Атырау".
    if wrk.branch matches "*Актюб*" then v-branch = "Актобе".
    if wrk.branch matches "*Акмол*" then v-branch = "Кокшетау".
    if wrk.branch matches "*Жезказган*" then v-branch = "Жезказган".
    if wrk.branch matches "*Алматы*" then v-branch = "Алматы".
    if wrk.branch matches "*Семей*" then v-branch = "Семей".
    if wrk.branch matches "*Астана*" then v-branch = "Астана".
    if wrk.branch = 'АО ' + v-bankn then v-branch = "ЦО".
end procedure.