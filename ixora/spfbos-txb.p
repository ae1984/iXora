/* spfbos-txb.p
 * MODULE
          Справка по переводам
 * DESCRIPTION

 * BASES
          BANK COMM TXB
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
          31.03.09 id00363
          28.05.10 id00363 поменял поиск по remtrz по retrz.outcode, было по remtrz.ptype
          06/09/11 dmitriy - добавил столбцы Номер транзакции и Наименование филиала
 * CHANGES
*/

/* 1 */

def shared var j-info   as char.
def shared var j-perkod   as char.

def var infoperkod as char.
def var oper as char.


define stream rep.

output stream rep to myreport.html append.




infoperkod = '*' + j-info + '*' + j-perkod + '*'.





for each txb.joudoc where ((txb.joudoc.dracctype = '1' AND txb.joudoc.cracctype = '4') OR
(txb.joudoc.dracctype = '4' AND txb.joudoc.cracctype = '1')) AND txb.joudoc.info matches j-info AND txb.joudoc.perkod matches j-perkod no-lock break by txb.joudoc.info:


	if txb.joudoc.dracctype = '1' then do:
		find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
		find first txb.gl where txb.gl.gl = txb.arp.gl.
		oper = "Отправленный".
	end.

	if txb.joudoc.dracctype = '4' then do:
		find first txb.arp where txb.arp.arp = txb.joudoc.dracc no-lock no-error.
		find first txb.gl where txb.gl.gl = txb.arp.gl.
		oper = "Полученный".
	end.


	if first-of(txb.joudoc.info) then do:
		find first txb.cmp.

		put stream rep unformatted
			"<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0>" skip
				"<td colspan=8>" txb.cmp.name "</td>" skip
			"</tr>" skip.
	end.

	put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
	"<td>" txb.arp.des "</td>" skip
	"<td>"  oper "</td>" skip
        "<td  align= center>" txb.joudoc.info "</td>" skip
        "<td>" txb.joudoc.perkod "</td>" skip
        "<td>" txb.joudoc.cramt "</td>" skip
        "<td  align= center>" txb.joudoc.whn format '99.99.9999' "</td>" skip
        "<td>" txb.joudoc.jh "</td>" skip
        "<td>" txb.cmp.name "</td>" skip
        "</tr>" skip.


end.



/*for each txb.remtrz where (txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '4') and  txb.remtrz.ord matches infoperkod no-lock :*/
/*for each txb.remtrz where (txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '6') and  txb.remtrz.ord matches infoperkod no-lock :*/
for each txb.remtrz where (txb.remtrz.outcode = 1 OR txb.remtrz.outcode = 6) and  txb.remtrz.ord matches infoperkod no-lock :

	if txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '6' then do:
		oper = "Перевод в ин.вал. без откр. счета".
	end.

	if txb.remtrz.ptype = '4' then do:
		oper = "Перевод в ин.вал. c откр. счета".
	end.


	put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
	"<td>" oper "</td>" skip
	"<td>Отправленный</td>" skip
        "<td  align= center colspan=2>" txb.remtrz.ord "</td>" skip
        "<td>" txb.remtrz.amt "</td>" skip
        "<td  align= center>" txb.remtrz.rdt format '99.99.9999' "</td>" skip
        "<td>" txb.remtrz.jh1 "</td>" skip
        "<td>" txb.cmp.name "</td>" skip
        "</tr>" skip.


end.



output stream rep close.
