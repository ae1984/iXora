/* rpppn.p
 * MODULE
          Налоговая отчетность
 * DESCRIPTION
          Реестр платежных поручений по налогам
 * BASES
          BANK COMM 
 * RUN
  
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
          8.8.7.6
 * AUTHOR
          04.03.09 id00363
 * CHANGES
*/


def var i as int.

def var dt1     as date.
def var dt2     as date.
def var r-rnn   as char.
def var r-kbk   as char.
def var r-knp   as char.

form dt1 label ' Укажите период с' format '99/99/9999'
    dt2 label ' по' format '99/99/9999' skip(1)
    r-rnn label ' РНН Отправителя...'  format '999999999999' skip(1)
    r-kbk label ' КБК...............' format 'x(20)' skip(1)
    r-knp label ' КНП...............' format 'x(20)'
with side-label row 5 width 48 centered frame dat.


update dt1 dt2 r-rnn r-kbk r-knp with frame dat.


define stream rep.

output stream rep to myreport.html.




find first cmp no-lock no-error.


put stream rep unformatted

    "<html>" skip
    "<head>" skip
          "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
          "<title>Отчет</title>" skip
             "<style type= text/css>" skip
             "TABLE \{ border-collapse: collapse; \}" skip
             "</style>" skip
    "</head>" skip
    "<body>" skip



    "<table width= 40% border= 1 cellspacing= 0 cellpadding= 0   bgcolor= #C0C0C0>" skip

    "<tr>" skip
    "<td>Период</td>" skip
    "<td>" dt1 "-" dt2 "</td>" skip
    "</tr>" skip


    "<tr>" skip
    "<td>Наименование отправителя</td>" skip
    "<td>" cmp.name "</td>" skip
    "</tr>" skip


    "<tr>" skip
    "<td>РНН Отправителя</td>" skip
    "<td>" r-rnn "</td>" skip
    "</tr>" skip



    "</table><br><br>"skip



    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0  >" skip
    "<tr align= center>" skip
    "<td colspan=11>Дата формирования реестра " + string(today, "99/99/99") + "</td>" skip
    "</tr>" skip
    "<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0 align= center>" skip
    "<td>N<br>п/п</td>" skip
    "<td>Наименование<br>бенефициара</td>" skip
    "<td>РНН бенефициара</td>" skip
    "<td>БИК Банка бенефициара</td>" skip
    "<td>ИИК бенефициара</td>" skip
    "<td>КБК</td>" skip
    "<td>КНП</td>" skip
    "<td>Сумма</td>" skip
    "<td>Назначение</td>" skip
    "<td>Дата оплаты/платежного поручения</td>" skip
    "<td>Номер платежного документа</td>" skip
    "</tr>" skip.



i = 0.

r-rnn = '*' + r-rnn + '*'.
r-kbk = '*' + r-kbk + '*'.
r-knp = '*' + r-knp + '*'.

for each remtrz where ( remtrz.drgl = 285110 OR remtrz.drgl = 185100 ) 
AND remtrz.rdt >= dt1 AND remtrz.rdt <= dt2 AND remtrz.ord matches  r-rnn
AND remtrz.ba matches r-kbk no-lock :

find first sub-cod where  sub-cod.d-cod = 'eknp' AND sub-cod.acc = remtrz.rem AND entry(3,sub-cod.rcode,",") matches r-knp   no-lock no-error.
if avail sub-cod then do :

find first taxnk where taxnk.rnn = entry(3,remtrz.bn[3],"/") no-lock no-error.
if avail taxnk then do :




i = i + 1.
put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
        "<td  align= center>" string(i) "</td>" skip
        "<td>" remtrz.bn[1] "</td>" skip.
	if num-entries(remtrz.bn[3],'/') = 3 then put stream rep unformatted "<td>" entry(3,remtrz.bn[3],'/') "</td>" skip.
	else put stream rep unformatted "<td>" remtrz.bn[3] "</td>" skip.
put stream rep unformatted
        "<td>" remtrz.bb "</td>" skip
        "<td  align= center>" entry(1,remtrz.ba,"/") "</td>" skip
        "<td  align= center>" entry(2,remtrz.ba,"/") "</td>" skip
        "<td  align= center>" entry(3,sub-cod.rcode,",")  "</td>" skip
        "<td  align= center>" remtrz.payment "</td>" skip
        "<td>" remtrz.detpay "</td>" skip
        "<td  align= center>" remtrz.rdt format '99.99.9999' "</td>" skip
        "<td  align= center>" substring ( remtrz.sqn , 19, 8)  "</td>" skip
        "</tr>" skip.


end.

end.

end.

put stream rep unformatted "</table></body></html>".

output stream rep close.
unix silent cptwin myreport.html explorer.
