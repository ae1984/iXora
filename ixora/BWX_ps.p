/* bwx_ps.p
 * MODULE
     Платежные карты
 * DESCRIPTION
     Формирование файла на пополнение карт
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
      6.1 Платежная система
 * AUTHOR
      10/01/06 marinav  
 * CHANGES
      	13/01/06
      	17/03/06 marinav - два раза в день идет уведамление о прошедших платежах
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
	01/09/06 u00121 - переделал копирование bwx-файла с cp (когда БД были на одном сервере) на scp (базы разнесены на разные сервера)
			- копирование происходит всегда на texaka1, т.к. отправка файлов происходит только с Алматы
        05/09/06 marinav - удалила из рассылки адрес amarina@elexnet.kz
*/

{lgps.i "new"}
{comm-txb.i}

/* таблица для генерации файлов для BWX (пл. карточки) */
def new shared temp-table cpay
           field card as char format "x(18)" /* N карт */
           field sum like jl.dam             /* Сумма к зачисл */
           field crc as char format "x(3)"   /* валюта */
           field trxdes as char              /* описание транзакции */
           field batchdes as char            /* описание батча */
           field messtype as char.           /* тип зачисления */
def var outname as char no-undo.
def var outname1 as char no-undo.
def var bwxdir as char no-undo.
def var rcd as char no-undo.
define variable kztacc as character no-undo.
define variable usdacc as character no-undo.
def var bwxtdir as char no-undo.
def var thisacc as char no-undo.
def var rz like remtrz.remtrz no-undo.
def var s-sumt as deci no-undo.
def var s-numt as inte no-undo.
def var s-sumv as deci no-undo.
def var s-numv as inte no-undo.
def stream t.
def stream st1.

function unix_s returns char (cmd as char).
    def var st as char init ''.
    input stream t through value(cmd).
    import stream t unformatted st.
    input stream t close.
    return st.
end.

for each mobtemp where mobtemp.state = 300 exclusive-lock.
  find first jh where jh.jh = inte(mobtemp.phone) no-lock no-error.
  if avail jh and jh.sts = 6 then do:
   	 mobtemp.state = 302.	
	 create cpay.
	 assign cpay.card = entry(1, mobtemp.ref, '/')
        	cpay.sum = mobtemp.sum
		cpay.crc = (if mobtemp.rid = 1 then "KZT" else (if mobtemp.rid = 2 then "USD" else "XXX")).
         assign cpay.trxdes = "CASH DEPOSIT"
		cpay.batchdes = "CASH DEPOSIT"
		cpay.messtype = "PAYCCD".
  end.
end.

/* формирование файла для BWX */
find first cpay no-lock no-error.
if avail cpay then run crdpaygen (output outname).

/* очистим временную таблицу */
for each cpay.
  delete cpay.
end.
        
for each mobtemp where mobtemp.state = 301 exclusive-lock.
  find first jh where jh.jh = inte(mobtemp.phone) no-lock no-error.
  if avail jh and jh.sts = 6 then do:
   	 mobtemp.state = 303.	
	 create cpay.
	 assign cpay.card = entry(1, mobtemp.ref, '/')
        	cpay.sum = mobtemp.sum
		cpay.crc = (if mobtemp.rid = 1 then "KZT" else (if mobtemp.rid = 2 then "USD" else "XXX")).
 	 assign cpay.trxdes = "CASH SECURE DEPOSIT"
	        cpay.batchdes = "CASH SECURE DEPOSIT"
 	        cpay.messtype = "PAYCARDSEC".
  end.
end.
/* формирование файла для BWX */
find first cpay no-lock no-error.
if avail cpay then run crdpaygen2 (output outname1).

/* очистим временную таблицу */
for each cpay.
  delete cpay.
end.

find first mobtemp where mobtemp.state = 302 or mobtemp.state = 303 no-lock no-error.
if not avail mobtemp then return.

for each mobtemp no-lock .
   if mobtemp.state = 302 then run savelog ("crdquick", SUBSTITUTE ("Отправка файла &1 пополнения карточки # &2 проводка &3 на сумму &4", outname , entry(1, mobtemp.ref, '/'), mobtemp.phone, mobtemp.sum)).
   if mobtemp.state = 303 then run savelog ("crdquick", SUBSTITUTE ("Отправка файла &1 пополнения карточки # &2 проводка &3 на сумму &4", outname1, entry(1, mobtemp.ref, '/'), mobtemp.phone, mobtemp.sum)).
end.

/* скопируем файл для BWX */
if comm-txb() = "TXB00" then 
do:
	/* isaev если Алматинский платеж карточек то кидаем BWX на NTMAIN */
	bwxdir = "\\\\ntmain\\capital\$\\Users\\Departments\\Bwx\\Salary\\".
	find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxdir' no-lock no-error.
	if avail bookcod then bwxdir = TRIM(bookcod.name).        
	else message "Не найден код BWXDIR в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
	if outname  ne "" then rcd = unix_s("rcp " + outname + " " + bwxdir).
	if rcd <> "" then message "Ошибка копирования BWX файла \n" + outname + "\n" + rcd.
	if outname1 ne "" then rcd = unix_s("rcp " + outname1 + " " + bwxdir).
	if rcd <> "" then message "Ошибка копирования BWX файла \n" + outname1 + "\n" + rcd.
end. 
else 
do:
/* иначе копируем BWX файл во временный каталог и содаем внешний платеж и справочник со сссылкой на BWX файл во временном каталоге */
	find sysc where sysc.sysc = "CRDQCK" no-lock no-error.
	if not available sysc then {error.i "Нет переменной CRDQCK в таблице SYSC!"}
	if num-entries (sysc.chval) < 2 then {error.i "Нет списка всех счетов в CRDQCK в таблице SYSC!"}
	kztacc = entry (1, sysc.chval).
	usdacc = entry (2, sysc.chval).
	find arp where arp.arp = kztacc no-lock no-error.
	if not available arp then {error.i "Нет счета АРП для KZT! проверьте CRDQCK в SYSC!"}
	find arp where arp.arp = usdacc no-lock no-error.
	if not available arp then {error.i "Нет счета АРП для USD! проверьте CRDQCK в SYSC!"}
	bwxtdir = '/home/isaev/bwx/'.
	find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxtdir' no-lock no-error.
	if avail bookcod then bwxtdir = trim(bookcod.name).
	else message "Не найден код BWXTDIR в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
	if outname  ne "" then unix silent value("cp " + outname + " " + bwxtdir).
	if outname  ne "" then unix silent value("scp -qp " + outname + " " + "texaka1:" + bwxtdir). /*01/09/2006 u00121*/
	if outname1 ne "" then unix silent value("cp " + outname1 + " " + bwxtdir).
	if outname1 ne "" then unix silent value("scp -qp " + outname1 + " " + "texaka1:" + bwxtdir). /*01/09/2006 u00121*/ 

	for each mobtemp where mobtemp.state = 302 or mobtemp.state = 303 no-lock .
	
		/* счет получателя в Ц.О. */
		find first bookcod where bookcod = 'cardaccs' and bookcod.code = string(mobtemp.rid) no-lock no-error.
		if not avail bookcod then 
		do:
			message "Не найдены счета для получателя на пополнение карт счетов" view-as alert-box.	return.
		end.
		if mobtemp.rid = 1 then thisacc = kztacc.
		else thisacc = usdacc.
		/* транзитный счет с которого делается перевод. sysc = 'CRDQCK' */
		find first arp where arp.arp = thisacc no-lock.  /* arp*/
		run commpl(
			time,                                                        /*  1 Номер документа */                           
			mobtemp.sum,                                                 /*  2 Сумма платежа */                             
			arp.arp,                                                     /*  3 Счет отправителя т.е. АРП счет */            
			"TXB00",                                                     /*  4 Банк получателя */                           
			bookcod.name,                                                /*  5 Счет получателя */                           
			0,                                                           /*  6 КБК */                                       
			no,                                                          /*  7 Тип бюджета - проверяется если есть КБК */   
			arp.des,                                                     /*  8 Бенефициар */                                
			"600900050984",                                              /*  9 РНН Бенефициара */                           
			"311",                                                       /* 10 KNP */                                       
			"19",                                                        /* 11 Kod */                                       
			"14",                                                        /* 12 Kbe */                                       
			"Пополнение карт. счета " + entry(1, mobtemp.ref, '/') +     /* 13 Назначение платежа */                        
			"~nДержатель: " + entry(3, mobtemp.ref, '/') +                                                              
			"~nРНН: " + entry(2, mobtemp.ref, '/'),                    
			"1P",                                                        /* 14 Код очереди */                               
			1,                                                           /* 15 Кол-во экз. */                               
			5,                                                           /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) */            
			entry(2, mobtemp.ref, '/'),                                  /* 17 РНН отправителя */                                                                              
			entry(3, mobtemp.ref, '/'),                                   /* 18 ФИО отпр. если не найдено в базе RNN */      
                        today
		).                                                               
		rz = return-value.
		find remtrz where remtrz.remtrz = rz exclusive-lock no-error.
		if avail remtrz then remtrz.rsub = 'arp'.
		find current remtrz no-lock no-error.
		if avail remtrz then 
		do:
			find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'RMZ' and sub-cod.d-cod = 'zattach' no-lock no-error.
			if not avail sub-cod then create sub-cod.
			assign sub-cod.acc = rz
			sub-cod.sub = 'RMZ'
			sub-cod.d-cod = 'zattach'
			sub-cod.ccode = 'card'.
  			if mobtemp.state = 302 then sub-cod.rcode = bwxtdir + '/' + outname.
  			if mobtemp.state = 303 then sub-cod.rcode = bwxtdir + '/' + outname1.
		end.
        end.
end.

if outname  ne "" then unix silent value ("rm  " + outname).
if outname1  ne "" then unix silent value ("rm  " + outname1).


  for each mobtemp where mobtemp.state = 302 or mobtemp.state = 303 exclusive-lock.
    if mobtemp.state = 302 then assign mobtemp.info = outname + ',' + string(today) + ',' + string(time)  mobtemp.state = 304.
    if mobtemp.state = 303 then assign mobtemp.info = outname1 + ',' + string(today) + ',' + string(time) mobtemp.state = 305.
  end.
  release mobtemp.


if (time >= 43200 and time <= 45000) or (time >= 61200 and time <= 63000) then do:

  output stream st1 to bwx.txt.
  put stream st1 unformatted 'Return-Path: u00118@elexnet.kz' skip
                             'From: cards@elexnet.kz'  skip
                             'To: inna@elexnet.kz,dina@elexnet.kz'  skip
                             'Subject: Уведомление о пополнении карт счетов' skip
                             'Content-Type: text/html; charset="koi8-r"' skip(1).
  for each mobtemp where mobtemp.state = 304 or mobtemp.state = 305 exclusive-lock.
     put stream st1 unformatted entry(2,mobtemp.info,',') ' ' string(inte(entry(3,mobtemp.info,',')), "HH:MM:SS") ' ' SUBSTITUTE ("Отправка файла &1 пополнения карточки # &2 проводка &3 на сумму &4 <br>", trim(entry(1,mobtemp.info,',')) , entry(1, mobtemp.ref, '/'), mobtemp.phone, mobtemp.sum) skip.
     if mobtemp.rid = 1 then assign s-sumt = s-sumt + mobtemp.sum s-numt = s-numt + 1.
     if mobtemp.rid = 2 then assign s-sumv = s-sumv + mobtemp.sum s-numv = s-numv + 1.
     delete mobtemp.
  end.
  put stream st1 unformatted 'Всего в тенге - ' s-numt ' на сумму ' s-sumt '<br>' skip. 
  put stream st1 unformatted 'Всего в долларах - ' s-numv ' на сумму ' s-sumv '<br>' skip. 
  output stream st1 close.
  unix silent value('cat bwx.txt | /usr/lib/sendmail -t').
  input through value ("rm bwx.txt" ). 
  release mobtemp.

end.






