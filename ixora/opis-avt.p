/* 
 * MODULE
	opis-avt.p
 * DESCRIPTION
        Опись документов для авторизации платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        10/06/2004 valery
 * CHANGES
	24/06/2004 valery в отчет добавлены подпись
*/

def temp-table t-avt
	field nn as int /*номер по порядку*/
	field tr like jh.jh /*номер транзакции*/
	field jdt like jh.jdt /*дата транзакции*/
	field doc as char /*номер документа*/
	field frm as char /*наименование поставщикам*/
	field rem as char format "x(76)" /*Назначение платежа*/
	field amt like jl.cam 
	field who like jl.who. /*сумма*/
	
def var f-name as char init "opis-avt.htm".
def var v-dep as char.
def var i as int init 0.
def var vprofit like codfr.code label "Код деп.".  
def var vpname like codfr.code label "Название деп." format "x(40)".  
def var v-yn as logical init false.

{global.i}


displ vprofit vpname with frame ofc col 10 row 5 2 col width 66. /*фрейм для ввода деп-та*/

on help of vprofit in frame ofc do:
          run uni_help1('sproftcn', '...'). /*здесь выводится список профит -центров (департ-ов)*/
end.

update vprofit validate((can-find(codfr where codfr.codfr = 'sproftcn' and code = vprofit) and vprofit matches '...'),'Неверный Профит-центр - повторите!') with frame ofc. 

  find codfr where codfr.codfr = "sproftcn" and codfr.code = vprofit no-lock no-error.
  if avail codfr then vpname = codfr.name[1].
                 else vpname = "".
  displ vpname with frame ofc. /*выводим название департамента определенное по введенному коду*/

v-dep = vprofit.




/*вытаскиваем внутренние документы с не отштампованными проводками*/
for each jh where jdt = g-today and sts <> 6 no-lock by jh.
	for each jl where jl.jh = jh.jh no-lock.
         	find first gl where gl.gl = jl.gl and gl.sub = "CIF"  no-lock no-error.  /*клиентский ли платеж*/
 		if avail gl then
		do:
	        	find first ofc where ofc.ofc = jl.who and  ofc.titcd = v-dep no-lock no-error. /*принадлежит ли создатель проводки выбранному департаменту*/
        		if avail ofc then 
		        	if substr(jh.ref,1,3) = "jou"  then  /*если это jou - документ*/
            			do:
            				find first joudoc where docnum = jh.ref no-lock no-error. /*ищем jou - документ*/ 
	        			if avail joudoc then 
							i = i + 1.
							create t-avt.
							t-avt.nn = i.
							t-avt.tr = jh.jh.
							t-avt.jdt = jh.jdt.
							t-avt.doc = jh.ref.
							find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
 							if avail aaa then 
							do: 
								find first cif where cif.cif = aaa.cif no-lock no-error.
 								if avail cif then do:
                                                        	    t-avt.frm = cif.pref + " " +  cif.name.	
								end.
							end.
							t-avt.rem = joudoc.rem[1] + joudoc.rem[2].
							t-avt.amt = joudoc.cramt.
							t-avt.who = jh.who.
							v-yn = true.
				end.
            	end.
	end.
end.




/*вытаскиваем внешние неотконтролированные платеже*/
for each que where que.pid = "P" and que.con <> "F" no-lock. /*внешний неотконтролированные платеж ищется так*/
	find remtrz where remtrz.remtrz = que.remtrz no-lock no-error. /*ищем RMZ*/ 
       		if avail remtrz then
	        	find first ofc where ofc.ofc = remtrz.rwho and  ofc.titcd = v-dep no-lock no-error. /*проверяем причастность создателя к выбранному департаменту*/
	        		if avail ofc then
					do:
						i = i + 1.
						create t-avt.
						t-avt.nn = i.
						t-avt.tr = remtrz.jh1.
						t-avt.jdt = remtrz.rdt.
						t-avt.doc = remtrz.remtrz.
                                                t-avt.frm = remtrz.ben[1] + remtrz.ben[2].
						t-avt.rem = remtrz.det[1] + remtrz.det[2] + remtrz.det[3].
						t-avt.amt = remtrz.amt.
						t-avt.who = remtrz.rwho.
						v-yn = true.
					end.
end.

hide frame ofc.

if not v-yn then do:
            displ "Нет документов, подлежащих авторизации!" with frame mes row 10 centered. pause 10.  return.
end.


  output  to value(f-name).
  {html-title.i &stream = " " &title = " " &size-add = "x-"}
  find first cmp no-lock no-error.
  put unformatted
	  "<TABLE><TR><TD>" g-today " " string(time,"HH:MM:SS") "</TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD>" cmp.name "</TD></TR></TABLE>" skip 
	  "<P align=""center"" style=""font:bold;font-size:small"">Опись документов для авторизации платежей </P>" skip
	  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

  put unformatted
      "<TR>" skip
	"<TD>N<br>п/п</TD>" skip
        "<TD>Номер<br>транзакции</TD>" skip
        "<TD>Дата<br>транзакции</TD>" skip
        "<TD>Номер<br>документа</TD>" skip
        "<TD>Наименование<br>поставщика</TD>" skip
        "<TD>Назначение<br>платежа</TD>" skip
        "<TD>Сумма</TD>" skip
        "<TD>Примечание</TD>" skip
	"</TR>" skip.


for each t-avt no-lock by nn by frm .
  put unformatted
      "<TR>" skip
	"<TD>" t-avt.nn "</TD>" skip
        "<TD>" t-avt.tr "</TD>" skip
        "<TD>" t-avt.jdt "</TD>" skip
        "<TD>" t-avt.doc "</TD>" skip
        "<TD>" t-avt.frm "</TD>" skip
        "<TD>" t-avt.rem "</TD>" skip
        "<TD>" replace(string(t-avt.amt, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
        "<TD>" t-avt.who "</TD>" skip
     "</TR>" skip.
end.

   put unformatted /*24/06/04 valery*/
	  "<TABLE><TR><TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD></TR>" skip 
		  "<TR><TD></TD> <TD>Передал__________</TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD>Передал__________</TD> <TD></TD></TR>" skip
		  "<TR><TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD></TR>" skip 
	  	  "<TR><TD></TD> <TD>Получил__________</TD> <TD></TD> <TD></TD> <TD></TD> <TD></TD> <TD>Получил__________</TD> <TD></TD></TR></TABLE>" skip .

{html-end.i " "}
output close.
/****Выводим на экран*********************************/
unix silent cptwin value(f-name) excel.

pause 0.
