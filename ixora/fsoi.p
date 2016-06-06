/* fsoi.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Основные источники привлечения денег
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
	8-2-16
 * AUTHOR
        16.04.2004 valery
 * BASES
	TXB
 * CHANGES
	04.08.2006 u00121 - объединил код в единый for each, добавил индекс в t-cif (idx0-t-cif), проставил no-undo. Whole-index в этой программе будет только при поиске по aaa, т.к. там действительно полный перебор.
*/

def input parameter p-bank as char.
def var v-in as char label "Собираю данные"  no-undo.
def var i as int no-undo.


def shared var v-dt as date no-undo.

def shared temp-table t-cif no-undo
	field cif like txb.cif.cif
	field prefix like txb.cif.prefix
	field name like txb.cif.name
	field rnn like txb.cif.jss
	field code as char format "x(3)"
	field DDA as decimal format "zzz,zzz,zzz,zz9.99-"
	field CDATDA as decimal format "zzz,zzz,zzz,zz9.99-"
	field sum as decimal format "zzz,zzz,zzz,zz9.99-"
	index sum is primary sum DESCENDING
	index idx0-t-cif cif.

for each txb.aaa where ((txb.aaa.gl>=220300 and txb.aaa.gl<220800) or
                        (txb.aaa.gl>=201300 and txb.aaa.gl<201400) or
                        (txb.aaa.gl>=221500 and txb.aaa.gl<221600) or
                        (txb.aaa.gl>=221700 and txb.aaa.gl<221800)) no-lock. /*собираем клиентов с счетами DDA, CDA, TDA*/
	find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr and (txb.lgr.led = "DDA" or txb.lgr.led = "CDA" or txb.lgr.led = "TDA") /*use-index lgrled*/ no-lock no-error.
	if avail txb.lgr then
	do:
		find last txb.cif where txb.cif.cif = txb.aaa.cif use-index cif no-lock no-error.
		/*if avail txb.cif and txb.cif.type = "B" then*//*только юр лиц*/
		do:
			find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error. /*находим код отрасли*/
			if avail txb.sub-cod then
			do:
 				find last t-cif where t-cif.cif = txb.cif.cif no-lock no-error.
				if not avail t-cif then
				do:
					create t-cif.
					assign
						t-cif.cif = txb.cif.cif
						t-cif.prefix = txb.cif.prefix
						t-cif.name = txb.cif.name
						t-cif.rnn = txb.cif.jss
						t-cif.code = txb.sub-cod.ccode.
				end.
				/*else
				do:*/
				        find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-dt  no-lock no-error. /*ищем остатки*/
				        if avail txb.aab then
				        do:
				        	if txb.lgr.led = 'DDA' then
						        t-cif.DDA = t-cif.DDA + txb.aab.bal.
						else
						        t-cif.CDATDA = t-cif.CDATDA + txb.aab.bal.

						t-cif.sum = t-cif.DDA + t-cif.CDATDA.
				        end.
				/*end.*/

				/*А это так, просто чтобы скучно не было когда ждешь отчет*/
				if i<>8 then do: /*что то вроде progresbar*/
					v-in = v-in + "*".
					i = i + 1.
				end.
				else do:
					v-in = "".
					i = 0.
				end.
				displ txb.aaa.aaa no-label v-in with overlay centered side-labels row 18 1 down title p-bank. pause 0.

			end.
		end.
	end.
end.

