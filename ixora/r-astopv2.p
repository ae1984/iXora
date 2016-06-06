/* r-astopv.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - Операции с осн.средствами по видам операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-1-4-4
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.06.06 sasco   - Переделал поиск в hist (по ындэксу opdate)
*/

define shared var g-today  as date.
def shared stream m-out.
def input parameter vmc1 as date  .
def input parameter vmc2 as date  .
def input parameter v-fag like txb.ast.fag .
def input parameter v-gl like txb.ast.gl.
def input parameter v-ast like txb.ast.ast.
def input parameter vib as integer format "9" .
def input parameter v-asttr as char.

def var adam1 as dec format "zzzzzz,zzz,zz9.99-".
def var acam1 as dec format "zzzzzz,zzz,zz9.99-".
def var bdam1 as dec format "zzzzzz,zzz,zz9.99-".
def var bcam1 as dec format "zzzzzz,zzz,zz9.99-".
def var adam3 as dec format "zzzzzz,zzz,zz9.99-".
def var acam3 as dec format "zzzzzz,zzz,zz9.99-".
def var bdam3 as dec format "zzzzzz,zzz,zz9.99-".
def var bcam3 as dec format "zzzzzz,zzz,zz9.99-".
def var v-desoper as char. /*Вид операции*/

find first txb.cmp no-lock no-error.
put  stream m-out unformatted
  "<P style=""font-size:x-small"">" txb.cmp.name "</P>" skip
  "<P align=""left"" style=""font:bold;font-size:small"">Операции с основными средствами за период с  " + string (vmc1) + " по " + string (vmc2)  "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.


put  stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
	"<TD>Дата</TD>" skip
        "<TD>Оп.</TD>" skip
        "<TD>Деп.</TD>" skip
        "<TD>Nr.карточки</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>Шт.</TD>" skip
        "<TD>Nr.опер.</TD>" skip
        "<TD>Исполн.</TD>" skip
        "<TD>Операция</TD>" skip
        "</TR>" skip.


For each txb.astjln where txb.astjln.ajdt ge vmc1 and  txb.astjln.ajdt le vmc2 and
			(if v-asttr<>"" then txb.astjln.atrx begins v-asttr else true) and
			(if vib=1 then txb.astjln.aast = v-ast else (if vib=2  then txb.astjln.afag = v-fag else (if vib=3 then txb.astjln.agl = v-gl else true)))
			use-index astdt no-lock
			break by substring(txb.astjln.atrx,1,1) by txb.astjln.agl by txb.astjln.atrx by txb.astjln.ajh by txb.astjln.aast:

	if txb.astjln.agl=0 then next.
	accumulate txb.astjln.d[1] (total by txb.astjln.agl ) .
	accumulate txb.astjln.c[1] (total by txb.astjln.agl ).
	accumulate txb.astjln.d[3] (total by txb.astjln.agl ) .
	accumulate txb.astjln.c[3] (total by txb.astjln.agl ).

	adam1=adam1 + txb.astjln.d[1].
	acam1=acam1 + txb.astjln.c[1].
	bdam1=bdam1 + txb.astjln.d[1].
	bcam1=bcam1 + txb.astjln.c[1].
	adam3=adam3 + txb.astjln.d[3].
	acam3=acam3 + txb.astjln.c[3].
	bdam3=bdam3 + txb.astjln.d[3].
	bcam3=bcam3 + txb.astjln.c[3].

	if first-of(substring(txb.astjln.atrx,1,1)) then
	do:

		v-desoper = substring(txb.astjln.atrx,1,1) + ".  ".

		find txb.asttr where txb.asttr.asttr=substring(txb.astjln.atrx,1,1) no-lock no-error.
		if avail txb.asttr then v-desoper = v-desoper +	txb.asttr.atdes.

                put  stream m-out unformatted
                      "<TR style=""font:bold"">" skip
                	"<TD>" v-desoper "</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "</TR>" skip.
        end.

	If first-of(txb.astjln.agl) then
	do:
		find txb.gl where txb.gl.gl=txb.astjln.agl no-lock no-error.
		if not avail txb.gl  then
		do:
			message "Счет " txb.astjln.agl " (проводка " txb.astjln.ajh ") не найден!".
			pause.
			return.
		end.
                put stream m-out  unformatted
                      "<TR >" skip
                	"<TD>" txb.astjln.agl gl.des "</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "</TR>" skip.
	end.

	if substring(v-asttr,1,1)="9" or vib = 1 or (substring(txb.astjln.atrx,1,1) ne "9" and vib ne 1) then
	do:
		/* sasco */
		find last txb.hist where txb.hist.pkey = "AST" and txb.hist.skey = txb.astjln.aast and txb.hist.date <= txb.astjln.ajdt no-lock use-index opdate no-error.
		if not avail txb.hist then
		do:
			if vmc1 < g-today then find first txb.hist where txb.hist.pkey = "AST" and txb.hist.skey = txb.astjln.aast and
			                                  txb.hist.date >= txb.astjln.ajdt no-lock use-index opdate no-error.
		end.
		if not avail txb.hist then
		do:
			find first txb.ast where txb.ast.ast = txb.astjln.aast no-lock no-error.
		end.
                put  stream m-out unformatted
                      "<TR >" skip
                	"<TD>" txb.astjln.ajdt "</TD>" skip
                        "<TD>" txb.astjln.atrx "</TD>" skip
                        "<TD>" if avail txb.hist then (if txb.hist.date <= txb.astjln.ajdt then txb.hist.chval[1] else txb.hist.chval[2]) else txb.ast.attn "</TD>" skip
                        "<TD>" txb.astjln.aast "</TD>" skip
                        "<TD>" txb.astjln.d[1] "</TD>" skip
                        "<TD>" txb.astjln.c[1] "</TD>" skip
                        "<TD>" txb.astjln.aqty "</TD>" skip
                        "<TD>" txb.astjln.ajh "</TD>" skip
                        "<TD>" txb.astjln.awho "</TD>" skip
                        "<TD>" txb.astjln.arem[1] "</TD>" skip
                        "</TR>" skip.

		if txb.astjln.d[3] ne 0 or txb.astjln.c[3] ne 0 then
		do:
                        put  stream m-out unformatted
                              "<TR>" skip
                        	"<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>" txb.astjln.d[3] "</TD>" skip
                                "<TD>" txb.astjln.c[3] "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
				"<TD>" txb.astjln.arem[2] "</TD>" skip
				"</TR>" skip.
		end.

        /*
		if txb.astjln.stdt ne ? then
                        put  stream m-out unformatted
                              "<TR >" skip
                        	"<TD>" txb.astjln.agl txb.gl.des "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>сторнир. " txb.astjln.stdt " " txb.astjln.stjh "</TD>" skip
                                "<TD></TD>" skip
			      "</TR>" skip.
                  */

	end.
	if last-of(txb.astjln.atrx) then
                put  stream m-out unformatted
                      "<TR ></TR>" skip.

	if last-of(txb.astjln.agl) then
	do:
		find txb.asttr where txb.asttr.asttr=substring(txb.astjln.atrx,1,1) no-lock no-error.
		if avail txb.asttr then
                        put  stream m-out unformatted
                              "<TR >" skip
                        	"<TD>" txb.asttr.atdes "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.


                        put  stream m-out unformatted
                              "<TR style=""font:bold"">" skip
                        	"<TD>" txb.astjln.agl "</TD>" skip
                                "<TD>Обороты   :</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>" adam1 "</TD>" skip
                                "<TD>" acam1 "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.

		if adam3 ne 0 or acam3 ne 0 then
                        put  stream m-out unformatted
                              "<TR >" skip
                        	"<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>" adam3 "</TD>" skip
                                "<TD>" acam3 "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.

                  put  stream m-out unformatted   "<TR ></TR>" skip.

		adam1=0. acam1=0. adam3=0. acam3=0.
	end.

	if last-of(substring(txb.astjln.atrx,1,1)) then
	do:
		find txb.asttr where txb.asttr.asttr=substring(txb.astjln.atrx,1,1) no-lock no-error.
		if avail txb.asttr then
                        put  stream m-out unformatted
                              "<TR >" skip
                        	"<TD>" txb.asttr.atdes "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.

                        put  stream m-out unformatted
                              "<TR style=""font:bold"">" skip
                        	"<TD>Обороты всего   :</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>" bdam1 "</TD>" skip
                                "<TD>" bcam1 "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.

		if bdam3 ne 0 or bcam3 ne 0 then
                        put  stream m-out unformatted
                              "<TR >" skip
                        	"<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD>" bdam3 "</TD>" skip
                                "<TD>" bcam3 "</TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "<TD></TD>" skip
                                "</TR>" skip.

		bdam1=0. bcam1=0. bdam3=0. bcam3=0.
	end.
end.

if v-asttr="" then
do:
                put  stream m-out unformatted
                      "<TR >" skip
                	"<TD>ОБОРОТЫ ВСЕГО:</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD>" txb.astjln.d[1] "</TD>" skip
                        "<TD>" txb.astjln.c[1] "</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "</TR>" skip.
                put  stream m-out unformatted
                      "<TR >" skip
                	"<TD>ОБОРОТЫ ВСЕГО:</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD>" txb.astjln.d[3] "</TD>" skip
                        "<TD>" txb.astjln.c[3] "</TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "</TR>" skip.

end.
put  stream m-out unformatted "</table>" skip.

