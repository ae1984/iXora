/* inv3.p
 * MODULE
	Основные средства
 * DESCRIPTION
	 Ведомость основных средств
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.07.04 suchkov - Отчет переделан, чтобы брался за дату.
        09.09.04 suchkov - переделан еще раз, чтобы если дата - сегодня, инфа бралась из карточки.
        23.11.05 suchkov - Вывод переделан в excel
        27.06.06 sasco   - Переделал поиск в hist (по ындэксу opdate)
        31.07.06 u00121  - отчет выводится в Excel - красиво :)
*/

def var bsum$ as dec format "->>>,>>>,>>9.99" 	no-undo.
def var isum$ as dec format "->>>,>>>,>>9.99" 	no-undo.
def var ic$ as int no-undo.
def var i$ as int format ">>>>>." init 1 	no-undo.
def var i1$ as int format ">>>>>" 		no-undo.
def var gr$ as char format "x(3)" 		no-undo.
def var q$ as int format ">>>>>" 		no-undo.
def var qacc$ as int format ">>>>>" 		no-undo.
def var v-attn as char format "x(3)" 		no-undo.
def var repdt as date initial today 		no-undo.
def var v-file as char init "inv3.htm" 		no-undo.

{global.i}

update 	v-attn label "Код подразделения" 
	repdt  label "Дата расчета"
with row 8 centered side-label frame opt.

hide frame opt.
find last codfr where codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
if not available codfr then 
do:
	message "Неверный код подразделения".
	leave.    
end.

gr$ = v-attn.


output to value(v-file).
	{html-title.i}
	put string(time,"hh:mm:ss") "\n" skip.
    	put unformatted
        "<P align=""left"" style=""font:bold;font-size:x-small""> ВЕДОМОСТЬ ОСНОВНЫХ СРЕДСТВ <br>" repdt " </P>" skip
        "<P align=""left"" style=""font:bold;font-size:x-small"">место расположения: (" gr$ ")" codfr.name[1] " </P>" skip.

      put unformatted "<table><TR><td>" skip.

      put unformatted        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""left"" border=""1"" width=""20%"">" skip.
        put unformatted
        "<TR align=""left"" style=""font:bold"">" skip
        "<TD>Nr.</TD>" skip  
        "<TD>Карточка</TD>" skip
        "<TD>Инв.<br>Nr.</TD>" skip
        "<TD>Наименование</TD>" skip
        "<TD>Дата<br>рег</TD>" skip
        "<TD>Кол.</TD>" skip
        "<TD>Бал.<br>стоимость</TD>" skip
        "<TD>Ост.<br>стоимость</TD>" skip
        "</TR>" skip.


	for each ast where (ast.dam[1] - ast.cam[1]) <> 0 break by ast.gl by ast.fag:
		if first-of(ast.gl) then 
		do:
			find last gl where gl.gl = ast.gl no-lock no-error.
                        put unformatted
                        "<TR style=""font:bold;font-size:x-small;background:ghostwhite"">" skip
                        "<TD>Счет </TD>" skip  
                        "<TD>" ast.gl " " gl.des  "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "</TR>" skip.

		end.
		if first-of(ast.fag) then 
		do:
			find first fagn where fagn.fag = ast.fag no-lock no-error.
                        put unformatted
                        "<TR>" skip
                        "<TD>Группа</TD>" skip  
                        "<TD>" ast.fag " " fagn.naim  "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "</TR>" skip.

			i$ = 1.
			q$ = 0.
		end.
		if repdt <> today then 
			find last hist where hist.pkey = "AST" and hist.skey = ast.ast and hist.op = "MOVEDEP" and hist.date <= repdt no-lock use-index opdate no-error .
			if (available hist and hist.chval[1] = gr$ and repdt <> today) or (repdt = today and ast.attn = gr$) then 
			do:
				accumulate ast.dam[1] - ast.cam[1] (total by ast.gl).
				accumulate (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) (total by ast.gl).
				accumulate ast.ast (count by ast.gl).
				accumulate ast.dam[1] - ast.cam[1] (total by ast.fag).
				accumulate (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) (total by ast.fag).
				accumulate ast.icost (count by ast.fag).
				isum$ = isum$ + (ast.dam[1] - ast.cam[1]).
				bsum$ = bsum$ + (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]).
				ic$ = ic$ + ast.qty.

				put unformatted
                                "<TR>" skip
                                "<TD>" i$ "</TD>" skip  
                                "<TD>`" ast.ast "</TD>" skip
                                "<TD>" ast.addr[2] "</TD>" skip
                                "<TD>" ast.name "</TD>" skip
                                "<TD>" ast.rdt "</TD>" skip
                                "<TD>" ast.qty "</TD>" skip
                                "<TD>" ast.dam[1] - ast.cam[1] "</TD>" skip
                                "<TD>" (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) "</TD>" skip
                                "</TR>" skip.


				i$ = i$ + 1.
				q$ = q$ + ast.qty.
			end.
			if last-of(ast.fag) then 
			do:
                                put unformatted
                                "<TR>" skip
                                "<TD>Всего по гр. </TD>" skip  
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>" q$ "</TD>" skip
                                "<TD>" accum total by ast.fag ast.dam[1] - ast.cam[1] "</TD>" skip
                                "<TD>" accum total by ast.fag (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) "</TD>" skip
                                "</TR>" skip.

					qacc$ = qacc$ + q$.
			end.

			if last-of(ast.gl) then 
			do:
                                put unformatted
                                "<TR>" skip
                                "<TD>Всего по сч. </TD>" skip  
                                "<TD>" ast.gl "</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>" qacc$ "</TD>" skip
                                "<TD>" accum total by ast.gl ast.dam[1] - ast.cam[1]  "</TD>" skip
                                "<TD>" accum total by ast.gl (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) "</TD>" skip
                                "</TR>" skip.

				qacc$ = 0.
			end.
	end.

        put unformatted
                  "<TR>" skip
                  "<TD>ВСЕГО ОС</TD>" skip  
                  "<TD>&nbsp</TD>" skip
                  "<TD>&nbsp</TD>" skip
                  "<TD>&nbsp</TD>" skip
                  "<TD>&nbsp</TD>" skip
                  "<TD>" ic$ "</TD>" skip
                  "<TD>" isum$ "</TD>" skip
                  "<TD>" bsum$ "</TD>" skip
                  "</TR></table>" skip.

        put unformatted "</td></tr><tr><td>" skip.
        put unformatted "</td></tr><tr><td>" skip.	

      put unformatted "<br><table>" skip
                "<TR><TD colspan = 9 >" "Руководитель подразделения" fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>" skip.

output close.

unix silent cptwin value(v-file) excel.