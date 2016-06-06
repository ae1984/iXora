/* storno-txb.p
 * MODULE
          Внутрибанковские операции
 * DESCRIPTION
          Отчет по сторно-документам
 * BASES
          BANK COMM 
 * RUN
  
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
          8.8.5.21
 * AUTHOR
          31.03.09 id00363
 * CHANGES
*/



def var v-dep like bank.ofchis.depart no-undo.

def new shared var dt1	as date no-undo.
def new shared var dt2	as date no-undo.



def new shared temp-table st no-undo
    
    field depar like bank.ppoint.name
    field num like bank.jh.jh
    field dam like bank.jl.gl
    field cam like bank.jl.gl
    field damcam like bank.jl.dam
    field party like bank.jh.party
    field crc like bank.crc.code
    field who1 like bank.ofc.name
    field who2 like bank.ofc.name
    field jdt like bank.jh.jdt
    field tim like bank.jh.tim.

/*empty temp-table st.*/


form dt1 label ' Укажите период с' format '99/99/9999'
/*update	dt1 label ' Укажите период с' format '99/99/9999'*/
	dt2 label ' по' format '99/99/9999' skip(1)
with side-label row 3 width 48 centered frame dat.
/*	skip with side-label row 5 centered frame dat .*/

update dt1 dt2  with frame dat.

{r-brfilial.i &proc = "storno-txb2"}




define stream rep.

output stream rep to storno.html.




put stream rep unformatted

    "<html>" skip
    "<head>" skip
          "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
          "<title>Отчет</title>" skip
             "<style type= text/css>" skip
             "TABLE \{ border-collapse: collapse; \}" skip
			 "@media print \{ .rotator \{filter:progid:DXImageTransform.Microsoft.BasicImage(Rotation=1)\} \}"

             "</style>" skip
    "</head>" skip
    "<body>" skip
	

        "<center><p>Отчет по сторно-документам</p></center>" skip
        "<center><p>за период с " dt1 " по " dt2 "</p></center>" skip
	


    "<table width= 90% border= 1 cellspacing= 0 cellpadding= 0  class='rotator'>" skip
    "<tr align= center>" skip
    "<td colspan=11>Дата формирования отчета " + string(today, "99/99/99") + "</td>" skip
    "</tr>" skip
    "<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0 align= center>" skip
    "<td>Департамент</td>" skip
    "<td>N транз</td>" 	skip
    "<td>Счет Деб</td>" skip
    "<td>Счет Кр</td>" skip
    "<td>Сумма</td>" skip
    "<td>Содержание</td>" skip
    "<td>Валюта</td>" skip
    "<td>Стонировал</td>" skip
    "<td>Менеджер исходной<br>проводки</td>" skip
    "<td>Дата</td>" skip
    "<td>Время</td>" skip
    "</tr>" skip.




for each st no-lock :

/*
find first crc where crc.crc = jh.crc no-lock no-error.
find first ofc where ofc.ofc = jh.who no-lock no-error.

find first sub-cod where  sub-cod.d-cod = 'eknp' AND sub-cod.acc = remtrz.rem AND entry(3,sub-cod.rcode,",") matches r-knp   no-lock no-error.
if avail sub-cod then do :

find first taxnk where taxnk.rnn = entry(3,remtrz.bn[3],"/") no-lock no-error.
if avail taxnk then do :
*/




put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
        "<td  align= center>" st.depar "</td>" skip
        "<td>" st.num "</td>" skip
	"<td>" st.dam "</td>" skip
	"<td>" st.cam "</td>" skip
        "<td>" st.damcam "</td>" skip
        "<td>" st.party "</td>" skip
        "<td>" st.crc  "</td>" skip
        "<td>" st.who1 "</td>" skip
        "<td>" st.who2 "</td>" skip
        "<td>" st.jdt format '99.99.9999' "</td>" skip
        "<td>" STRING(st.tim, "hh:mm:ss") "</td>" skip
        "</tr>" skip.

end.

put stream rep unformatted "</table></body></html>".

output stream rep close.
unix silent cptwin storno.html excel.