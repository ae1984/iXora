/* r-aststa.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - Состояние основных средств
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        8-1-4-2
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08/07/04 sasco Убрал из отчета условие на astatl.atl > 0 (выводим с любой остаточной стоимостью)
        09/07/04 sasco выводим только с ненулевой балансовой стоимостью
	22/04/05 u00121 переделал вывод отчета в Excel
        11/08/06 sasco добавил вывод профит-центра и налогового комитета в последние столбцы отчета
        23.04.10 marinav - консолидация
        03/02/12 dmitriy - добавил столбец "Инв.номер"
        01/03/12 dmitriy - исправил вывод строки "Всего"
*/

{mainhead.i}
def var file as char init "r-aststa.htm" no-undo.
def var v-gl like ast.gl no-undo.
def var v-gl3 like trxlevgl.glr no-undo.
def var v-gl4 like trxlevgl.glr no-undo.
def var v-fag like ast.fag no-undo.
def var vmc1 like ast.ldd  .
def var vib as integer format "9" no-undo.
def var fsak like ast.icost no-undo.
def var fatlv like ast.icost no-undo.
def var fnol like ast.icost no-undo.
def var gsak like ast.icost no-undo.
def var gatlv like ast.icost no-undo.
def var gnol like ast.icost no-undo.
def var gfond like ast.icost no-undo.
def var kfond like ast.icost no-undo.
def var ffond like ast.icost no-undo.
def var ksak like ast.icost no-undo.
def var katlv like ast.icost no-undo.
def var knol like ast.icost no-undo.
def var vibk as integer format "z" init 1 no-undo.


def new shared temp-table wrk no-undo
  field gl       like ast.gl
  field fag      like ast.fag
  field ast      like ast.ast
  field inv-n    like ast.addr[2]
  field qty      like ast.qty
  field rdt      like ast.rdt
  field noy      like ast.noy
  field icost    like astatl.icost
  field nol      like astatl.nol
  field atl      like astatl.atl
  field fatl     like astatl.fatl[4]
  field name     like ast.name
  field fil      as char
  field depname  as char
  field nkname   as char.

form  skip(1)
     " НА ДАТУ    :" vmc1   skip
     " ГРУППА ОС  :" v-fag  format "x(3)" fagn.naim at 35 skip
     " СЧЕТ ОС    :" v-gl   gl.des skip
     with row 8 frame amort centered no-labels title "СОСТОЯНИЕ ОСНОВНЫХ СРЕДСТВ".

vmc1 =  g-today.
update  vmc1 validate(vmc1 ne ? and vmc1<=g-today , "ПРОВЕРЬТЕ ДАТУ ") with frame amort 1 down.

update v-fag validate(can-find (fagn where fagn.fag = v-fag no-lock) or v-fag="", "ПРОВЕРЬТЕ НОМЕР ГРУППЫ  ") with frame amort.
if v-fag ne "" then
do:
	find fagn where fagn.fag = v-fag no-lock no-error.
	if avail fagn then do:
		v-gl = fagn.gl.
		find gl where gl.gl eq v-gl no-lock no-error.
		if avail gl then do:
			display fagn.naim v-gl gl.des with frame amort.	vib=2.
		end.
		else do:
			Message "Счет Г/К " v-gl " не найден!". pause. return.
		end.
	end.
	else do:
		message "Группа ОС " v-fag "не найдена!!!". pause. return.
	end.
end.
else
do:
	update v-gl validate(can-find(gl where gl.gl=v-gl no-lock) or v-gl=0, " ПРОВЕРЬТЕ СЧЕТ  " ) with frame amort.
	if v-gl ne 0 then
	do:
		find gl where gl.gl eq v-gl no-lock no-error.
		if avail gl then do:
			display gl.des with frame amort.
			if gl.subled ne "ast" then do:
				message "СЧЕТ НЕ ОС ". pause 1. undo,retry.
			end.
			vib=3.
		end.
		else do:
			Message "Счет Г/К " v-gl " не найден!". pause.	return.
		end.
	end.
	else vib=4.
end.
pause 0.

{r-brfilial.i &proc = "r-aststa2(vmc1,v-fag,v-gl,vib)"}

/*ФОРМИРУЕМ И ВЫВОДИМ ПОЛЬЗОВАТЕЛЮ ОТЧЕТ *************************************************************************************************************************/
output to value(file).
{html-title.i}
find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" v-bankname "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">Состояние основных средств на " vmc1 ". <br> Время создания: " + string(time,"HH:MM:SS") + "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put unformatted
      "<TR align=""center"" style=""font:bold"">" skip
	"<TD>Счет</TD>" skip
        "<TD>Гр.</TD>" skip
        "<TD>Nr.карт.</TD>" skip
        "<TD>Инв.номер</TD>" skip
        "<TD>Кол- <br> во</TD>" skip
        "<TD>Дата <br> регистрации</TD>" skip
        "<TD>Срок <br> износа</TD>" skip
        "<TD>Балансовая стоимость</TD>" skip
        "<TD>Начисл. аморт.</TD>" skip
        "<TD>Остат.стоим.</TD>" skip
        "<TD>Фонд <br> переоценки</TD>" skip
        "<TD>Название</TD>" skip
        "<TD>Профит-центр</TD>" skip
        "<TD>Налоговый комитет</TD>" skip
        "</TR>" skip.



for each wrk where no-lock  break  by wrk.gl by wrk.fag by wrk.ast:


	if first-of(wrk.gl) then
	do:
		find first trxlevgl where trxlevgl.gl = wrk.gl and trxlevgl.lev = 3 no-lock no-error.
		if available trxlevgl then v-gl3 = trxlevgl.glr.
		                      else v-gl3=?.

		find first trxlevgl where trxlevgl.gl = wrk.gl and trxlevgl.lev = 4 no-lock no-error.
		if available trxlevgl then v-gl4 = trxlevgl.glr.
		                      else v-gl4=?.
                put unformatted
                      "<TR>" skip
                	"<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>" wrk.gl "</TD>" skip
                        "<TD>" v-gl3 "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>" v-gl4 "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                      "</TR>" skip.
	end.

        put unformatted
                     "<TR>" skip
               	       "<TD>" wrk.gl "</TD>" skip
                       "<TD>" wrk.fag "</TD>" skip
                       "<TD>" wrk.ast "</TD>" skip
                       "<TD>" wrk.inv-n "</TD>" skip
                       "<TD>" wrk.qty "</TD>" skip
                       "<TD>" wrk.rdt "</TD>" skip
                       "<TD>" wrk.noy "</TD>" skip
                       "<TD>" replace(trim(string(wrk.icost , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(wrk.nol , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(wrk.atl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(wrk.fatl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" wrk.name "</TD>" skip
                       "<TD>" wrk.depname "</TD>" skip
                       "<TD>" wrk.nkname "</TD>" skip
                     "</TR>" skip.

			fsak  = fsak + wrk.icost.
			fatlv = fatlv + wrk.atl.
			fnol  = fnol + wrk.nol.
			ffond = ffond + wrk.fatl.
			gsak  = gsak + wrk.icost.
			gatlv = gatlv + wrk.atl.
			gnol  = gnol + wrk.nol.
			gfond = gfond + wrk.fatl.
			ksak  = ksak + wrk.icost.
			katlv = katlv + wrk.atl.
			knol  = knol + wrk.nol.
			kfond = kfond + wrk.fatl.

	if vib >= 2 and fsak ne 0 and last-of (wrk.fag) then
	do:
		find fagn where fagn.fag = wrk.fag no-lock no-error.
	        if not avail fagn then next.

                        put unformatted
                              "<TR style=""font:bold"">" skip
                        	"<TD>Всего( гр.  " wrk.fag ")</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>" replace(trim(string(fsak , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                                "<TD>" replace(trim(string(fnol , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                                "<TD>" replace(trim(string(fatlv , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                                "<TD>" replace(trim(string(ffond , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                                "<TD>" fagn.naim "</TD>" skip
                                "<TD>&nbsp</TD>" skip
                                "<TD>&nbsp</TD>" skip
                              "</TR>" skip.

			fsak = 0.
			fatlv = 0.
			fnol = 0.
	end.

	if vib >= 3 and gsak ne 0 and last-of (wrk.gl) then
	do:
		find gl where gl.gl = wrk.gl no-lock no-error.
		if not avail gl then next.

                put unformatted
                      "<TR style=""font:bold"">" skip
                	"<TD>Всего(счет  " wrk.gl ")</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>" replace(trim(string(gsak , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(gnol , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(gatlv , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(gfond , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" gl.des "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                      "</TR>" skip.

		gsak = 0.
		gatlv = 0.
		gnol = 0.
	end.

end.


if vib >= 4 and ksak ne 0 then
do:
                put unformatted
                      "<TR style=""font:bold"">" skip
                	"<TD>Всего</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>" replace(trim(string(ksak , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(knol , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(katlv , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>" replace(trim(string(kfond , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                        "<TD>&nbsp</TD>" skip
                      "</TR>" skip.
end.

put unformatted "</table>" skip.


{html-end.i " "}
output close .
hide frame ww .
hide all.
unix silent cptwin value(file) excel.
