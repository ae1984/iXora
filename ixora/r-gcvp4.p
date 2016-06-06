/* r-gcvp4.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Акты сверок Период указывается с ... по ... включительно!!!
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        25.08.08  marinav
 * CHANGES
        15/03/12 id00810 - добавила v-bnkname для печати
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{mainhead.i}
{nbankBik.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.

def new shared temp-table wrk
             field bank as char
             field type as inte
             field sum1 as deci
             field sum2 as deci
             field sum3 as deci
             field sum4 as deci
             field sum5 as deci.

def var v-s1 as deci .
def var v-s2 as deci .
def var v-s3 as deci .
def var v-s4 as deci .
def var v-s5 as deci .


update
  v-dtb label " Начальная дата " format "99/99/9999" skip
  v-dte label "  Конечная дата " format "99/99/9999"
  with centered row 5 side-label frame f-dt.

create wrk. wrk.type = 1.
create wrk. wrk.type = 2.

def var v-sel as char.

run sel2 (" Акты сверок :", " 1. Выплаты по пенсиям и пособиям | 2. Выплата компенсаций по Семипалатискому полигону | 3. Выплата удержаний из пенсий и пособий | 4. Выход ", output v-sel).

   {r-brfilial.i &proc = "r-gcvp4p (txb.bank, v-sel)" }


   define stream m-out.
   output stream m-out to rpt.html.
   put stream m-out "<html><head><title></title>" skip
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


  if v-sel = "1" then do:

      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенным выплатам пенсий и пособий из Республиканского бюджета и  </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по социальным выплатам из средств Государственного фонда социального страхования между </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> " + v-nbankru + " и Государственным центром по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Выплата пенсий и пособий из средств Республиканского бюджета</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Социальная выплата из средств ГФСС</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.
  end.


  if v-sel = "2" then do:
      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенной выплате единовременной государственной денежной компенсации гражданам, </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> пострадавшим вследствии яд. испытаний на Семипалатинском испытательном полигоне. </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> " + v-nbankru + " и РГКП Государственный центр по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Выплата единовременной денежной компенсации ПЕНСИОНЕРАМ, ПОЛУЧАТЕЛЯМ ГСП </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Выплата единовременной денежной компенсации РАБОТАЮЩИМ (НЕРАБОТАЮЩИМ) ГРАЖДАНАМ</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

  end.

  if v-sel = "3" then do:
      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенным выплатам удержаний из пенсий и пособий из Республиканского бюджета и из средств ГФСС, </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> между " + v-nbankru + " и РГКП Государственный центр по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Перечисление удержаний из пенсий и пособий из средств Республиканского бюджета </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Перечисление удержаний из социальных выплат из средств ГФСС </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.
  end.

  if v-sel = "4" then do:
     leave.
  end.


  put stream m-out unformatted
     "<tr align=""right""><b><td align=""left"">ИТОГО</td>"
     "<td>" v-s1 "</td><td>" v-s2 "</td><td>" v-s3 "</td><td>" v-s4 "</td><td>" v-s5 "</td><td></td><td></td></tr>" skip.


  put stream m-out unformatted "</table>" skip.

  output stream m-out close.
  unix silent cptwin rpt.html excel.
  pause 0.


