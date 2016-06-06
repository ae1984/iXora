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

def var s-ourbank as char no-undo.

define stream rep.

output stream rep to myreport.html append.





for each txb.joudoc where txb.joudoc.dracctype = '2' AND txb.joudoc.cracctype = '2' AND txb.joudoc.whn  >= dt1 AND txb.joudoc.whn <= dt2 no-lock break by txb.joudoc.info:

/*
dracctype = '2' - отправленный
cracctype = '2' - получ.
*/

	find first txb.cmp no-lock no-error.

	find txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.

        find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur and txb.crchis.regdt <= txb.joudoc.whn no-lock no-error.	

			put stream rep unformatted
		        "<tr style=' font-size:x-small'>" skip
			"<td>" txb.joudoc.whn format '99.99.9999' "</td>" skip
			"<td><nobr>"  entry(1,cmp.addr[1],',') "</td>" skip
		        "<td><font color=#FFFFFF>a</font>" txb.joudoc.cracc "</td>" skip
		        "<td><nobr>Счет - Счет, (" txb.joudoc.jh ")</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td>" txb.crc.code "</td>" skip
		        "<td>" replace(trim(string(txb.joudoc.cramt * txb.crchis.rate[1] / 1000, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
		        "<td><font size='-3'>" txb.joudoc.remark "</td>" skip
		        "</tr>" skip.

end.


for each txb.remtrz where txb.remtrz.outcode = 3 AND txb.remtrz.rdt  >= dt1 AND txb.remtrz.rdt <= dt2 no-lock :


find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
s-ourbank = trim(txb.sysc.chval).



if txb.remtrz.sbank = s-ourbank OR txb.remtrz.rbank = s-ourbank then do:

	if txb.remtrz.sbank = s-ourbank then oper = "отправленный". else if txb.remtrz.rbank = s-ourbank then oper = "полученный". 

	if txb.remtrz.ptype = '4' then do:

		find first txb.cmp no-lock no-error.

		find txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.

	        find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and txb.crchis.regdt <= txb.remtrz.rdt no-lock no-error.

		/*find first txb.aaa where txb.aaa.aaa = txb.remtrz.cracc no-lock no-error.*/

		/*oper = "Счет - Счет".*/

		put stream rep unformatted
	        "<tr style=' font-size:x-small'>" skip
		"<td>" txb.remtrz.rdt format '99.99.9999' " </td>" skip
		"<td><nobr>" entry(1,cmp.addr[1],',') "</td>" skip
	        "<td><font color=#FFFFFF>a</font>" txb.remtrz.cracc "</td>" skip
	        "<td>" oper "</td>" skip
        	"<td>" replace(trim(string(txb.remtrz.amt, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
	        "<td>" txb.crc.code "</td>" skip
	        "<td>" replace(trim(string(txb.remtrz.amt * txb.crchis.rate[1] / 1000, '>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
	        "<td><font size='-3'>" txb.remtrz.detpay "</td>" skip
	        "</tr>" skip.

	end.


end.

end.


output stream rep close.