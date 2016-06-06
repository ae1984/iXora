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
 * CHANGES
*/

/* 1 */
def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.



def var infoperkod as char.
def var oper as char.


define stream rep.

output stream rep to myreport.html append.





for each txb.joudoc where ((txb.joudoc.dracctype = '1' AND txb.joudoc.cracctype = '4') OR
(txb.joudoc.dracctype = '4' AND txb.joudoc.cracctype = '1')) AND txb.joudoc.whn  >= dt1 AND txb.joudoc.whn <= dt2 no-lock break by txb.joudoc.info:

	/*find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
	if avail txb.arp and (txb.arp.gl = 287032) then do:*/

	/* КНП */
	/*find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
	find first txb.gl where txb.gl.gl = txb.arp.gl no-lock no-error.*/
	find first txb.trxcods where txb.trxcods.trxh = txb.joudoc.jh and  txb.trxcods.codfr = "spnpl" no-lock no-error.

        if avail txb.trxcods then do: 

		if txb.trxcods.code <> '423' OR txb.trxcods.code <> '421' then do:




	find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.

	find first txb.cmp no-lock no-error.

	find txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.

        find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur and txb.crchis.regdt <= txb.joudoc.whn no-lock no-error.

	if txb.joudoc.dracctype = '1' then do:
		find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
		if avail txb.arp and (txb.arp.gl = 287032) then do:
			oper = "Отправленный".
		
			put stream rep unformatted
		        "<tr style=' font-size:x-small'>" skip
			"<td>" txb.joudoc.whn format '99.99.9999' "</td>" skip
			"<td><nobr>"  entry(1,cmp.addr[1],',') "</td>" skip
		        "<td><nobr>" oper ", (" txb.joudoc.jh ")</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td>" txb.crc.code "</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt * txb.crchis.rate[1] / 1000, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td><font size='-3'>" txb.joudoc.remark "</td>" skip
		        "</tr>" skip.

		end.
	end.

	if txb.joudoc.dracctype = '4' then do:
		/*find first txb.arp where txb.arp.arp = txb.joudoc.cracc no-lock no-error.
		if avail txb.arp and (txb.arp.gl = 287032) then do:*/
			oper = "Полученный".

			put stream rep unformatted
		        "<tr style=' font-size:x-small'>" skip
			"<td>" txb.joudoc.whn format '99.99.9999' "</td>" skip
			"<td><nobr>"  entry(1,cmp.addr[1],',') "</td>" skip
		        "<td><nobr>" oper ", (" txb.joudoc.jh ")</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td>" txb.crc.code "</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt * txb.crchis.rate[1] / 1000, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td><font size='-3'>" txb.joudoc.remark "</td>" skip
		        "</tr>" skip.

		/*end.*/
	end.

		end.
	end.

	/*end.*/

end.


for each txb.remtrz where (txb.remtrz.outcode = 1 OR txb.remtrz.outcode = 6) AND txb.remtrz.rdt  >= dt1 AND txb.remtrz.rdt <= dt2 no-lock :

	if txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '6' then do:
		oper = "Перевод в ин.вал. без откр. счета".

		find first txb.cmp no-lock no-error.

		find txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.

	        find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and txb.crchis.regdt <= txb.remtrz.rdt no-lock no-error.

		put stream rep unformatted
	        "<tr style=' font-size:x-small'>" skip
		"<td>" txb.remtrz.rdt format '99.99.9999' " </td>" skip
		"<td><nobr>" entry(1,cmp.addr[1],',') "</td>" skip
	        "<td>Отправленный</td>" skip
        	"<td>" replace(trim(string(txb.remtrz.amt, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
	        "<td>" txb.crc.code "</td>" skip
	        "<td>" replace(trim(string(txb.remtrz.amt * txb.crchis.rate[1] / 1000, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
	        "<td><font size='-3'>" txb.remtrz.detpay "</td>" skip
	        "</tr>" skip.

	end.

	if txb.remtrz.ptype = '4' then do:
		oper = "Перевод в ин.вал. c откр. счета".
	end.


end.



/*for each txb.remtrz where (txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '4') and  txb.remtrz.ord matches infoperkod no-lock :*/
/*for each txb.remtrz where (txb.remtrz.ptype = '1' OR txb.remtrz.ptype = '6') and  txb.remtrz.ord matches infoperkod no-lock :*/

/*for each txb.remtrz where (txb.remtrz.outcode = 1 OR txb.remtrz.outcode = 6) and  txb.remtrz.ord matches infoperkod no-lock :

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
        "</tr>" skip.


end.

*/

output stream rep close.