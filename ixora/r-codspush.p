/* r-cods.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        6-14-3
 * AUTHOR
        29/04/05 nataly
 * CHANGES
        12/05/05 nataly при выводе отчета задается дата С... По...
        26.05.05 nataly был добавлен выбор полной и сокращенной формы отчета 
        27.05.05 nataly были добавлены итоги разного уровня вложенности
        29/09/05 nataly было детализировано начисление %% по счетам - таблица t-cods3
        26/01/06 nataly добавила поле rem чтобы отсечь проводки bankadm по конвертации
        03/07/06 u00121 добавил индексы во временные таблицы и сделал их no-undo
*/

{global.i}
{push.i }  /*new*/
def stream vcrpt.
def var v-bank as char.

def var v-dam as decimal	no-undo.
def var v-cam as decimal	no-undo.
def var v-des as char	no-undo.
def var totcam as decimal	no-undo.
def var totdam as decimal	no-undo.
def var dt as date	no-undo.

def new shared var v-date as date. /*начало*/
def new shared var v-date2 as date . /*конец*/
v-date2 = vd1 - 1.


v-date = date(month(v-date2),1,year(v-date2)).
/*v-date = v-date2 - 2.*/

def new shared temp-table t-cods no-undo
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
	field jh   like bank.jl.jh
	field rem  as  char
	field who  like bank.jl.who 
        index jdt is primary   jdt 
        index idx2-t-cods who jdt dam gl.

def new shared temp-table t-cods3 no-undo 
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field who  like bank.jl.who 
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
        index idx1-t-cods3 is primary   jdt 
        index idx2-t-cods3 who jdt dam gl
        index idx3-t-cods3 code dep.

def temp-table t-cods2 no-undo
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
        index code is primary   code .
/*
do transaction:
     update v-date label 'ЗАДАЙТЕ ПЕРИОД С' 
            validate(v-date <= today,   "Дата не может быть больше текущей даты..... ")
            help "Введите начальную дату."
            v-date2 label 'ПО'
     validate(v-date2 <= today,   "Дата не может быть больше текущей даты..... ")
              help "Введите конечную дату."
              with row 8 centered  side-label frame opt. 
  if v-date2 < v-date then 
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.
 hide frame opt.
*/
/*def button  btn1  label "Сокращенная форма отчета".
def button  btn2  label "Расширенная форма отчета ".
def button  btn3  label "Выход".*/
def  var prz as integer	no-undo.
/*def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Сокращенная форма отчета" then prz = 1.
    else
    if self:label = "Расширенная форма отчета  " then prz=2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.
  */ 
prz = 2.

{r-branch.i &proc = "codsdatpush" }
/*
def stream rpt.
output stream rpt to 'rpt.img'.

do dt = v-date to v-date2.
for each t-cods  where t-cods.who = 'bankadm'  and not(t-cods.rem  begins 'CONVERSION ') and t-cods.jdt = dt and t-cods.dam <> 0 break by t-cods.gl.
  accum t-cods.dam (total by t-cods.gl).
  if last-of(t-cods.gl) then put stream rpt skip t-cods.gl '  ' dt ' '   accum total by t-cods.gl t-cods.dam  format 'zzzz,zzz,zzz,zz9.99'.
                                                                                        
end. 
end.

put stream rpt skip '-------------' skip.

do dt = v-date to v-date2.
for each t-cods3  where t-cods3.who = 'bankadm'  and t-cods3.jdt = dt and t-cods3.dam <> 0 break by t-cods3.gl.
/*  put stream rpt skip t-cods3.acc ' ' t-cods3.gl ' ' t-cods3.dam ' ' t-cods3.jdt.*/
  accum t-cods3.dam (total by t-cods3.gl).
  if last-of(t-cods3.gl) then put stream rpt skip t-cods3.gl ' ' dt ' '   accum total by t-cods3.gl t-cods3.dam  format 'zzzz,zzz,zzz,zz9.99'.
                                                                                        
end. 
end.
output stream rpt close.
  */

do dt = v-date to v-date2.
	for each t-cods  where t-cods.who = 'bankadm'  and t-cods.jdt = dt and t-cods.dam <> 0 and string(t-cods.gl) begins '5' break by t-cods.gl.
		if t-cods.rem  begins 'CONVERSION ' then next.
		find  first t-cods3 where t-cods3.gl = t-cods.gl and t-cods3.jdt = t-cods.jdt no-lock no-error.
		if avail t-cods3 then  delete t-cods.                                                                                  
	end. 
end.

do dt = v-date to v-date2.
	for each t-cods3  where t-cods3.who = 'bankadm'  and t-cods3.jdt = dt and t-cods3.dam <> 0  and string(t-cods3.gl) begins '5' break by t-cods3.code   by t-cods3.dep.
		accum t-cods3.dam (total by t-cods3.dep).
		if last-of(t-cods3.dep) then 
		do:
			create t-cods.
			buffer-copy  t-cods3 except t-cods3.dam to  t-cods.                                                                                 
			t-cods.dam = accum total by t-cods3.dep t-cods3.dam.
		end.
	end. 
end.



output stream vcrpt to value(vfname).
/*output stream vcrpt to 'cods.html'. */
{html-title.i 
	&stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted 
   "<p><B> Отчет по кодам доходов/расходов  с " + 
        string(v-date) + " по " + string(v-date2) + "</B></p>" skip.

/*расширенная форма*/
if prz = 2 then do:
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Код расходов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Подразделение</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Счет ГК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма по дебету (в тенге)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма по кредиту (в тенге)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доп признак</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата проводки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>N проводки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Исполнитель</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.
 
for each t-cods use-index jdt break  by substr(t-cods.code,1,5) by substr(t-cods.code,6,2).
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    find last cods where cods.code = t-cods.code no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".

   accum t-cods.dam (total by substr(t-cods.code,6,2)).
   accum t-cods.cam (total by substr(t-cods.code,6,2)).
   accum t-cods.dam (total by substr(t-cods.code,1,5)).
   accum t-cods.cam (total by substr(t-cods.code,1,5)).

  put stream vcrpt unformatted
      t-cods.code  "</TD>" skip
      "<TD>"  t-cods.dep  "</TD>" skip
      "<TD>"  t-cods.crc  "</TD>" skip
      "<TD>"  string(t-cods.gl)  "</TD>" skip
      "<TD>"  v-des  "</TD>" skip
      "<TD>"  replace(string(t-cods.dam,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD>"  replace(string(t-cods.cam,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD>"  t-cods.acc  "</TD>" skip
      "<TD>"  t-cods.jdt  "</TD>" skip
      "<TD>"  string(t-cods.jh)  "</TD>" skip
      "<TD>"  t-cods.who  "</TD>" skip.

  put stream vcrpt unformatted
    "</TR>" skip.

     /*итого по последним  2-ум цифрам кода*/
  if last-of(substr(t-cods.code,6,2)) then do:
     v-dam = ACCUMulate total  by  substr(t-cods.code,6,2) t-cods.dam.   
     v-cam = ACCUMulate total  by  substr(t-cods.code,6,2) t-cods.cam.   

    find last cods where cods.code = t-cods.code no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".

   put stream vcrpt unformatted
         "<TR valign=""top"">" skip 
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><B> ПОДИТОГ  </b></TD>" skip
      "<TD><b>"  substr(t-cods.code,1,7)   "</b></TD>" skip
      "<TD><b>"  v-des  "</b></TD>" skip
      "<TD><b>"  replace(string(v-dam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD><b>"  replace(string(v-cam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

     /*итого по первым  5-ти цифрам кода*/
  if last-of(substr(t-cods.code,1,5)) then do:
     v-dam = ACCUMulate total  by  substr(t-cods.code,1,5) t-cods.dam.   
     v-cam = ACCUMulate total  by  substr(t-cods.code,1,5) t-cods.cam.   

    find last cods where cods.code = substr(t-cods.code,1,5) + "00" no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".

   put stream vcrpt unformatted
         "<TR valign=""top"">" skip 
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><B> ИТОГО  </b></TD>" skip
      "<TD><b>"  substr(t-cods.code,1,5) + "00"   "</b></TD>" skip
      "<TD><b>" v-des  "</b></TD>" skip
      "<TD><b>"  replace(string(v-dam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD><b>"  replace(string(v-cam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

end.

put stream vcrpt unformatted
  "</TABLE>" skip.
end.
else do: /*сокращенная форма*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Код расходов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Подразделение</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Счет ГК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма по дебету (в тенге)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма по кредиту (в тенге)</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

for each t-cods use-index jdt break  by substr(t-cods.code,1,5) by substr(t-cods.code,6,2).
   accum t-cods.dam (total by substr(t-cods.code,6,2)).
   accum t-cods.cam (total by substr(t-cods.code,6,2)).
   accum t-cods.dam (total by substr(t-cods.code,1,5)).
   accum t-cods.cam (total by substr(t-cods.code,1,5)).

  if last-of(substr(t-cods.code,1,5)) then do:
     v-dam = ACCUMulate total  by  substr(t-cods.code,1,5) t-cods.dam.   
     v-cam = ACCUMulate total  by  substr(t-cods.code,1,5) t-cods.cam.   
             create t-cods2. 
                t-cods2.code =  substr(t-cods.code,1,5) + "00".  
                t-cods2.dep = "000".          
                t-cods2.gl = 0 . 
      assign 
             t-cods2.dam = v-dam.
             t-cods2.cam = v-cam.
              totdam = totdam + v-dam.
              totcam = totcam + v-cam.
  end.
end .
 
for each t-cods2 use-index code break by substr(t-cods2.code,1,1) by substr(t-cods2.code,1,3) .
   accum t-cods2.dam (total by substr(t-cods2.code,1,1)).
   accum t-cods2.cam (total by substr(t-cods2.code,1,1)).
   accum t-cods2.dam (total by substr(t-cods2.code,1,3)).
   accum t-cods2.cam (total by substr(t-cods2.code,1,3)).

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    find cods where cods.code = t-cods2.code no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".

  /*ИТОГО 1-го уровня вложенности*/
  put stream vcrpt unformatted
      t-cods2.code  "</TD>" skip
      "<TD>"  t-cods2.dep  "</TD>" skip
      "<TD>"  string(t-cods2.gl)  "</TD>" skip
      "<TD>"  v-des  "</TD>" skip
      "<TD>"  replace(string(t-cods2.dam,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD>"  replace(string(t-cods2.cam,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.

 /*ИТОГО 2-го уровня вложенности*/
  if last-of(substr(t-cods2.code,1,3)) then do:
     v-dam = ACCUMulate total  by  substr(t-cods2.code,1,3) t-cods2.dam.   
     v-cam = ACCUMulate total  by  substr(t-cods2.code,1,3) t-cods2.cam.   

    find cods where cods.code = substr(t-cods2.code,1,3) + "0000" no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".
  put stream vcrpt unformatted
     "<TR valign=""top"">" skip 
       "<TD>"  "</TD>" skip
      "<TD><b>ИТОГО </b></TD>" skip
      "<TD><b>" substr(t-cods2.code,1,3) + "0000"   "</b></TD>" skip
      "<TD><B>" v-des "</b></TD>" skip
      "<TD><B>"  replace(string(v-dam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD><b>"  replace(string(v-cam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 /*ИТОГО 3-го уровня вложенности*/
  if last-of(substr(t-cods2.code,1,1)) then do:
     v-dam = ACCUMulate total  by  substr(t-cods2.code,1,1) t-cods2.dam.   
     v-cam = ACCUMulate total  by  substr(t-cods2.code,1,1) t-cods2.cam.   

    find cods where cods.code = substr(t-cods2.code,1,1) + "000000" no-lock no-error.
    if avail cods then v-des = cods.des. else v-des = "".
  put stream vcrpt unformatted
     "<TR valign=""top"">" skip 
       "<TD>"  "</TD>" skip
      "<TD><b>ИТОГО </b></TD>" skip
      "<TD><b>" substr(t-cods2.code,1,1) + "000000"   "</b></TD>" skip
      "<TD><B>" v-des "</b></TD>" skip
      "<TD><B>"  replace(string(v-dam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD><b>"  replace(string(v-cam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  put stream vcrpt unformatted
     "<TR valign=""top"">" skip 
       "<TDcolspan = 6>"  "</TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

end.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
  put stream vcrpt unformatted
        "</TD>" skip
      "<TD><B>  </B></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><b> ИТОГО </b></TD>" skip
      "<TD><B>"  replace(string(totdam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip
      "<TD><B>"  replace(string(totcam,'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.

put stream vcrpt unformatted
  "</TABLE>" skip.
end. 
{html-end.i " stream vcrpt "}

output stream vcrpt close.
vres = yes.

/*  unix silent value("cptwin cods.html excel").*/

pause 0.


