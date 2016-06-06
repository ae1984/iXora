/* timerep.p
 * MODULE
        Отчет по сформированым платежам по графику времени
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        из меню
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.12.13
 * AUTHOR
        05/05/06 suchkov
 * CHANGES
*/

define variable tname as character no-undo .
define variable vdt  as date initial today no-undo .
define variable crlf as character no-undo .

define temp-table t-rmz no-undo 
	field rmz like remtrz.remtrz
	field sbank like remtrz.sbank
	field cover like remtrz.cover
	field tim like jh.tim
	field who as character .
	
crlf = chr(10) + chr(13).

update vdt label "Введите дату отчета" with centered side-labels.

for each remtrz where remtrz.rdt = vdt and (remtrz.ptype = "2" or remtrz.ptype = "6") no-lock .
if remtrz.valdt1 <> remtrz.valdt2 or remtrz.jh1 = ? or remtrz.fcrc <> 1  then next .

find first jh where jh.jh = remtrz.jh1 no-lock no-error .
if not available jh then do:
	message "Внимание! Проводка " remtrz.jh1 " не найдена!" view-as alert-box.
	next.
end.

if remtrz.cover = 1 then do:
        if jh.tim < 45900 then next .
	if (remtrz.source = "IBH" or remtrz.source = "SCN") and jh.tim < 50400 then next.
	find first ofc where ofc.ofc = jh.who no-lock no-error .
	create t-rmz.
	assign t-rmz.rmz = remtrz.remtrz
	       t-rmz.sbank = remtrz.sbank
	       t-rmz.cover = remtrz.cover
	       t-rmz.tim = jh.tim
	       t-rmz.who = ofc.ofc .
	if remtrz.source = "PNJ" then t-rmz.who = remtrz.rwho .
end.
if remtrz.cover = 2 then do:
	if jh.tim < 57600 then next .
	find first ofc where ofc.ofc = jh.who no-lock no-error .
	if not available ofc then do:
		message "Внимание! Офицер " jh.who " не найден!" view-as alert-box.
		next.
	end.
	if (remtrz.source = "IBH" or
	    remtrz.source = "A"   or
		ofc.titcd = "106" or 
		ofc.titcd = "518" or 
		ofc.titcd begins "A") and jh.tim < 59400 then next .

	if ofc.titcd = "102" and jh.tim < 58500 then next.

	if ofc.titcd = "101" then do:
               find first sub-cod where
               sub-cod.d-cod = 'eknp' and
               sub-cod.ccode = 'eknp' and
               sub-cod.sub   = 'rmz'  and
               sub-cod.acc   = remtrz.remtrz
               no-lock no-error.
               if available sub-cod then do:
                     if substring(sub-cod.rcode,1,2) = "13" and substring(sub-cod.rcode,4,2) = "14" or 
                        substring(sub-cod.rcode,1,2) = "14" and substring(sub-cod.rcode,4,2) = "13" then if jh.tim < 59400 then next .
		     else if jh.tim < 62100 then next .
               end.
               else do:
                     message "Ошибка! Не найден EKNP для " remtrz.remtrz view-as alert-box.
		     next.
               end.
	end.
	create t-rmz.
	assign t-rmz.rmz = remtrz.remtrz
	       t-rmz.sbank = remtrz.sbank
	       t-rmz.cover = remtrz.cover
	       t-rmz.tim = jh.tim
	       t-rmz.who = ofc.ofc .
	if remtrz.source = "PNJ" then t-rmz.who = remtrz.rwho .
end.
	
end.

output to rpt.html .

put "<html><head><title>TEXAKABANK</title>" crlf
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf.

put "<table border=""0"" cellpadding=""0"" cellspacing=""0""
    style=""border-collapse: collapse"">"
    crlf. 

put "<tr align=""center""><td><h3>ДАТА " vdt "</h3></td></tr><br><br>"
    crlf crlf.
put "<br><br><tr></tr>".

put "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
    style=""border-collapse: collapse"">" crlf
    "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"">Подразделение  </td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">REMTRZ         </td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Время          </td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Тип            </td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Логин менеджера</td>"
    "</tr>".

for each t-rmz.
	find first ofc where ofc.ofc = t-rmz.who no-lock no-error .
	if not available ofc then do:
		message "Внимание! Офицер " t-rmz.who " не найден!" view-as alert-box.
		next.
	end.
	find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock no-error.
	tname = codfr.name[1] .
	if t-rmz.sbank begins "TXB" and t-rmz.sbank <> "TXB00" then do:
		find bankl where bankl.bank = t-rmz.sbank no-lock no-error .
		if available bankl then tname = bankl.addr[1] .
	end.
        put unformatted "<tr>"
            "<td> " tname "</td>"
            "<td> " t-rmz.rmz "</td>"
            "<td> " string(t-rmz.tim,"HH:MM:SS") "</td>" .
	if t-rmz.cover = 1 then put "<td>Клиринг</td>" .
			   else put "<td> Гросс </td>" .
        put "<td> " t-rmz.who "</td>" 
	    "</tr>" crlf.
end.

output close.

unix silent cptwin rpt.html excel.
