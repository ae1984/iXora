/* r-invlst.p
 * MODULE
        Инвентаризационная опись
 * DESCRIPTION
        Формирует инвентаризационную опись основных средств по подразделению.
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        6-1-4-15
 * AUTHOR
        05.12.2003 kim
 * CHANGES
 	31.07.2006 u00121 - отчет выводится в Excel
*/

def var bsum$ as dec format "->>>,>>>,>>9.99" no-undo.
def var isum$ as dec format "->>>,>>>,>>9.99" no-undo.
def var ic$ as int no-undo.
def var i$ as int format ">>>>>." init 1 no-undo.
def var i1$ as int format ">>>>>" no-undo.
def var gr$ as char format "x(3)" no-undo.
def var q$ as int format ">>>>>" no-undo.
def var qacc$ as int format ">>>>>" no-undo.
def var v-attn as char format "x(3)" no-undo.
def var v-file as char init "inv3.htp" no-undo.


{mainhead.i}

update v-attn label "Код подразделения" with row 8 centered side-label frame opt.
hide frame opt.

find last codfr where codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
if not available codfr then do:
	message "Неверный код подразделения".
	leave.    
end.

gr$ = v-attn.

output to value(v-file).
	{html-title.i}
	put string(time,"hh:mm:ss") "\n" skip.

    	put unformatted
        "<P align=""left"" style=""font:bold;font-size:x-small"">ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ " g-today " </P>" skip
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
        "<TD>Сличительные<br>отметки</TD>" skip
        "</TR>" skip.

for each ast where ast.attn = gr$ and (ast.dam[1] - ast.cam[1] <> 0) break by ast.gl by ast.fag:
	accumulate ast.dam[1] - ast.cam[1] (total by ast.gl).
	accumulate (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) (total by ast.gl).
	accumulate ast.ast (count by ast.gl).
	accumulate ast.dam[1] - ast.cam[1] (total by ast.fag).
	accumulate (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) (total by ast.fag).
	accumulate ast.icost (count by ast.fag).
	isum$ = isum$ + (ast.dam[1] - ast.cam[1]).
	bsum$ = bsum$ + (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]).
	ic$ = ic$ + ast.qty.
	if first-of(ast.gl) then 
	do:
		find last gl where gl.gl = ast.gl no-lock no-error.
                put unformatted
                "<TR style=""font:bold;font-size:x-small;background:ghostwhite"">" skip
                "<TD>Счет </TD>" skip  
                "<TD>" ast.gl gl.des  "</TD>" skip
                "<TD>&nbsp</TD>" skip
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
                "<TD>" ast.fag fagn.naim  "</TD>" skip
                "<TD>&nbsp</TD>" skip
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
       "<TD>&nbsp</TD>" skip
       "</TR>" skip.

	i$ = i$ + 1.
	q$ = q$ + ast.qty.
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
                "<TD>&nbsp</TD>" skip
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
                "<TD>&nbsp</TD>" skip
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
                "<TD>&nbsp</TD>" skip
                "</TR></table>" skip.
      put unformatted "</td></tr><tr><td>" skip.
      put unformatted "</td></tr><tr><td>" skip.	

      put unformatted "<br><table>" skip
                "<TR><TD colspan = 9 >" "Материально-ответственное лицо" fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>" skip  
                "<TR><TD colspan = 9 >" "Председатель комиссии         " fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Член комиссии                 " fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Член комиссии                 " fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Член комиссии                 " fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Член комиссии                 " fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Расписка: Инвентаризация имущества проведена в моем присутствии. К членам комиссии претензий не имею.\n" "</TD></TR>"  skip 
                "<TR><TD colspan = 9 >" "Материально-ответственное лицо" fill("_",47) format "x(47)" "/____________________/\n" "</TD></TR></table>"  skip.

      put unformatted "</td></tr>" skip.

output close.
unix silent cptwin value(v-file) excel.

