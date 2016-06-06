/* lb100g.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Программа формирования файла сообщения по ГРОССУ при выгрузке
 * RUN
        
 * CALLER
        lbtog.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-5-10
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        21.02.2003 nadejda   если нет деталей платежа - перейти просто на следующую строку 
        17.03.2003 nadejda   изменен поиск РНН нашего банка - надо брать из cmp!
        08.04.2003 nadejda   для всех команд "unix rm" добавлен параметр -f
        19.09.2003 nadejda   добавлена проверка на размер файла сообщения для МТ102
        20.04.2004 nadejda   добавлена отдельная выгрузка налоговых платежей с arp-счетов lb100tax.p
                             предварительная разбивка платежей по типам во временные таблицы
        23.06.2004 nadejda - c 01.07.2004 МТ102 разрешены только для налоговых и пенсионных, проверяем дату отсечки
        28.06.2004 nadejda - исправлена ошибка в проверке даты разрешенных МТ102
                             запрет на МТ102 только для ГРОССА !  
        22.10.2004 tsoy      убрал проверку на размер файла
        18.01.2005 sasco     убрал поле SEND
        18.01.2005 sasco     вернул поле SEND
        23.11.2005 suсhkov   Детали платежа 412 символов
        13.12.2005 suсhkov   исправлены ошибки
        03.10.2006 u00121    если первая строка swift-файла не начинается с "\{", то значит файл кривой, или вообще пустой, как это было 02.10.2006 с RMZ112665B
			     в таком случае выдается сообщение пользователю в виде alert-box, а не так как раньше просто в лог.
			     Если пользователь обратился с таким сообщением, администратору АБПК нужно: проверить каталог из sysc`а PSJIN на наличие файла 
			     с именем указанного RMZ, возможно он просто пустой либо кривой. Продолжать выгрузку можно дальше, если убрать платеж на 31 очередь.
			     После чего нужно проверить каталог или распаковать архив из sysc`а lb100g.p psjarc на предмет наличия файла <RMZxxxxxxxx>.<PPxxxxxxxxxx>
			     Он должен содержать правильный SWIFT, если и там проблемы, то нужно разбираться.		     
       26.06.2009 galina - добавила формирование файла сообщения по ОПВ и СО ИР			     
*/

{trim.i}

def input parameter iddat as date.

/* sasco *************************************************/
FUNCTION ToNumber returns char (inchar as char).
	DEF VAR tt as int.
	DEF VAR oc as char.
	oc = inchar.
	do tt = 0 to 255:
		if tt < 48 or tt > 57 then
			oc = GReplace (oc, CHR(tt), "").
	end.
	do WHILE LENGTH (oc) > 9:
		oc = SUBSTR (oc, 2).
	end.
        if oc = "" then oc = "бн".
	RETURN oc.
END FUNCTION.
/* sasco *************************************************/

def var l-102 as log init false .
def var t1-amt as cha .
def var oc102 as cha init "c". 
def var ref102 as cha . 
def var mt102sum as decimal .
def var num102 as int init 0 .
def var v-ks as char .  /* v-ba */
def var v-ks1 as char .  /* v-ba */
def shared var g-today as date . 
def shared var g-ofc as cha .     
def new shared var v-text as cha . 
def buffer u-remtrz for remtrz . 
def var l-atm as log initial false . 
def var rrr as log extent 255 initial true .                         
def var vvv as cha.
def var v-tax as log initial true . 
def var r-bic as cha. 
def var asim as int .
def var v-iii as cha extent 6 .
def var v-bb as cha . 
def var v-date as date.
def buffer t-bankl for bankl.
def shared var vvsum as deci . 
def shared var nnsum as int . 
def var v-i as decimal . 
def var i as int. 
def var vsim as cha .
def shared var vnum as int .
def var t-summ like remtrz.amt .
def var v-tmp as  cha . 
def var eii as int . 
def var v_num as int . 
def var t-n as int .
def var v-unidir as cha .
def var v-lbmfo as cha .
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def var ii as int . 
def var r-sqn like remtrz.remtrz . 
def var v-ob as cha .
def var v-on as cha .
def var v-bn as cha .
def var v-dt as cha .
def var v-ri as cha .
def var v-racc as cha . 
def var t-bn as cha .
def var t-on as cha .
def var t-amt as cha .
def var ourbic as cha .
def var lbbic as cha .
def var amttot like remtrz.payment .
def var cnt as int .
def var a-amttot like remtrz.payment .
def var a-cnt as int .
def var i1 as int .
def var n as int .
def var regs as cha .
def var filenum as int .
def var filenumstr as char.
def var daynum as cha .
def var ourbank as cha .
def stream main .
def stream second .
def stream atma . 
def var v-tnum as char.
def var v-clecod as cha. 
def stream prot . 
def var v-field as cha extent 50.
def var s-error as cha.
def var v-knp as char.
def var v-new102 as logical.
def var v-last102 as logical.
define variable vdetpay as character .

def shared var mtsize as integer. /* максимальный размер файла сообщения в килобайтах */
def shared var mt102_max as integer.
def var v-seek as integer init 0.
def var v-seeklast as logical init no.


def var v-str as char.
def var v-sum as decimal init 0.
def var v-kol as integer init 0.


/* функция myCustomer */
{mycustomer.i}

{chbin.i}

v-text = "Контроль! Запуск lb100g " + g-ofc.
run lgps.

find first clrdog where clrdog.rdt = g-today and clrdog.pr = vnum no-lock no-error.
if not  available clrdog then 
do:
	Message "There isn't GROSS # " + string(vnum) + " in clrdog file " view-as alert-box.
	pause . 
	return .
end.

/* определение переменных из sysc */
{lb100s.i "'g'"}

/* 23.06.2004 nadejda - c 01.07.2004 МТ102 разрешены только для налоговых и пенсионных */
/* только для ГРОССА - письмо КЦМР от 28 июня 2004 */
def var v-check102 as logical init false.
def var v-date102 as date.
find sysc where sysc.sysc = "no102" no-lock no-error.
if avail sysc then 
do:
	v-check102 = true.
	v-date102 = sysc.daval.
end.

/* раскидывание платежей по временным таблицам по назначению */
{lb100d.i "clrdog"}

{lb102ink.i "clrdog"}

unix silent value("/bin/rm -f " + v-unidir + "p*.eks " + v-unidir + "*.err " + v-unidir +  "m*.eks  &> /dev/null ") .

do transaction :
	amttot = 0 .
	daynum = string(g-today - date(12, 31, year(g-today) - 1), "999") .

	output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks").
		v-new102 = false.
		v-last102 = false.

		for each t-docs break by t-docs.bank by t-docs.sbank by t-docs.type:
			find first remtrz where remtrz.remtrz = t-docs.rem no-lock no-error.
			if not avail remtrz then next.

			find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
			if not avail bankl then next.

			if first-of(t-docs.type) then 
			do:
				l-102 = false.
				/* 23.06.2004 nadejda - c 01.07.2004 МТ102 разрешены только для налоговых и пенсионных - только для ГРОССА */
				if v-check102 and remtrz.valdt2 < v-date102 then 
				do:
					find first sub-cod where sub-cod.d-cod = "mt102" and sub-cod.acc =  bankl.cbank and sub-cod.sub = "bnk" no-lock no-error.
					if avail sub-cod and sub-cod.ccode = "102" then 
					do:  
						l-102 = true .
						/* для МТ102 - будем собирать сообщение в отдельный файл */
						unix silent rm -f /tmp/gggtmp.eks.
					end.
				end.
			end.

			v-new102 = (l-102 and (first-of(t-docs.type))).
			v-last102 = (l-102 and last-of(t-docs.type)).

			output stream main to value("/tmp/ggg.eks") .
				if not t-docs.type then 
				do : /*   pension payment   */
					filenum = vnum * 100.
					filenumstr = string(filenum, "99999").

					if search(v-psjin + remtrz.remtrz) <> v-psjin + remtrz.remtrz then 
					do :
						v-text = remtrz.remtrz + " ОШИБКА !!! Нет файла пенсионного платежа в каталоге PSJIN !".
						run lgps.
						message v-text view-as alert-box.
						output stream main close.
						return "1".
					end.

					find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.
			
					input through value("cat " + v-psjin + remtrz.remtrz + " ;echo \n" ).
					repeat:
						import unformatted v-field[1] .
						v-field[1] = trim(v-field[1]).
						if v-field[1] <> "" then 
							leave.
					end.

					if not v-field[1] begins "\{" then 
					do:
						s-error = "".
						do i = 1 to 50 :
							if v-field[i] <> "" then 
								s-error = s-error + v-field[i] + " ".
						end.
						v-text = " Ошибка !!! " + remtrz.remtrz + " не верный формат Swift-файла " + v-psjin + remtrz.remtrz + " " + s-error. /*u00121 03.10.2006*/
						run lgps.
						message v-text view-as alert-box.
						output stream main close.
						return "1".
					end.

					if v-field[1] begins "\{1:" then 
					do:
      /*iban*/
						put stream main unformatted 
							"\{1:F01K0547000" substr(v-field[1],15) skip 
							"\{2:I102SGROSS000000U3003" + "\}" skip.
					end.

					repeat:
						import unformatted v-field[1] .
						v-field[1] = trim(v-field[1]).
	                                        if v-field[1] begins ":20:" then
							put stream main unformatted ":20:" remtrz.remtrz skip.
						else 
							if v-field[1] begins ":32A:" then
								put stream main unformatted ":32A:"  substr(string(year(iddat)),3,2)
                 										     substr(string(month(iddat),"99"),1,2)
                                                                                                     substr(string(day(iddat),"99"),1,2)
                                                                                                     substr(v-field[1],12) skip .
							else 
								if v-field[1] begins ":53C:" then.
								else   /*iban*/
									if v-field[1] begins ":52B:" then
                                                                                   put stream main unformatted  ":52B:" v-clecod skip.
									else 
										if not v-field[1] begins "\{2:" then
											  put stream main unformatted v-field[1] skip.
					end .
					input close.
					cnt = cnt + 1 .
					amttot = amttot + remtrz.payment .                               

					find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock. 
					u-remtrz.t_sqn = remtrz.remtrz.
					u-remtrz.ref =  "p" + daynum + filenumstr + ".eks/102/" + remtrz.remtrz + "/PSJ".
					find current u-remtrz no-lock.

					put stream prot unformatted cnt ":"
						trim(remtrz.remtrz)
						if index(remtrz.sqn,".",19) = 0 then
							caps(substring(remtrz.sqn,19))
						else
							caps(substring(remtrz.sqn,19,index(remtrz.sqn,".",19) - 19)) ":"
							v-ks ":" remtrz.payment " - "
							+ "p" + daynum +
							filenumstr + ".eks (pension) " +  remtrz.sqn 
						skip .
				end.  /*  pension payment processing end  */
				else 
				do : /* not pension payment */
					filenum = 1 + vnum * 100.
					filenumstr = string(filenum, "99999").
					/*  Beginning of main program body */
					find crc where crc.crc = remtrz.tcrc no-lock no-error.
					find first t-bankl where t-bankl.bank = remtrz.sbank no-lock no-error.
					find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.
					v-bb = "" . 

					v-on = myCustomer("/NAME/" + remtrz.ord + " " , remtrz.sacc, "50", remtr.remtrz ) .
					v-bn = myCustomer("/NAME/" + remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] + " ", remtrz.ba, "59", remtrz.remtrz ) .

					find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
					if avail sub-cod and sub-cod.rcod ne '' and sub-cod.rcod matches "*,*,*" then 
							v-knp =  entry(3,sub-cod.rcod,",") . else v-knp = "000".

					v-dt = ":70:/NUM/" + ToNumber (substr(remtrz.sqn,19)) + chr(10) .

					if not l-102 then 
						v-dt = v-dt + "/DATE/" + substr(string(year(remtrz.valdt1)),3,2) +
							string(month(remtrz.valdt1),"99") + string(day(remtrz.valdt1),"99") + 
							chr(10) + "/SEND/07" + chr(10). 
					v-dt = v-dt  + "/VO/01" +  chr(10) + "/KNP/" + v-knp + chr(10) .
					if not l-102 then
						v-dt = v-dt +  "/PSO/01" +  chr(10) +  "/PRT/50" + chr(10).

					if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then  
						v-dt = v-dt + "/BCLASS/" + v-ks1 + chr(10).

					v-dt = v-dt + "/ASSIGN/". 
	
					vdetpay = "" .
					do ii = 1 to 4:
						vdetpay = vdetpay + trim(remtrz.detpay[ii]).
					end.

					if vdetpay <> "" then 
					do:
						if length (vdetpay) > 62 then 
						do:
							if length (vdetpay) > 132 then 
							do:
								if length (vdetpay) > 202 then 
								do:
									if length (vdetpay) > 272 then 
									do:
										if length (vdetpay) > 342 then 
										do:
											if length (vdetpay) > 412 then
												v-dt = v-dt + substring (vdetpay,1,62) 
                                                                                                            + chr(10) + substring (vdetpay,63,70) 
                                                                                                            + chr(10) + substring (vdetpay,133,70) 
                                                                                                            + chr(10) + substring (vdetpay,203,70) 
                                                                                                            + chr(10) + substring (vdetpay,273,70) 
                                                                                                            + chr(10) + substring (vdetpay,343,70) .
											else 
												v-dt = v-dt + substring (vdetpay,1,62) 
                                                                                                            + chr(10) + substring (vdetpay,63,70) 
                                                                                                            + chr(10) + substring (vdetpay,133,70) 
                                                                                                            + chr(10) + substring (vdetpay,203,70) 
                                                                                                            + chr(10) + substring (vdetpay,273,70) 
                                                                                                            + chr(10) + substring (vdetpay,343).
										end.
										else 
											v-dt = v-dt + substring (vdetpay,1,62) 
                                                                                                    + chr(10) + substring (vdetpay,63,70) 
                                                                                                    + chr(10) + substring (vdetpay,133,70) 
                                                                                                    + chr(10) + substring (vdetpay,203,70) 
                                                                                                    + chr(10) + substring (vdetpay,273).
									end.
									else 
										v-dt = v-dt + substring (vdetpay,1,62) 
                                                                                            + chr(10) + substring (vdetpay,63,70) 
                                                                                            + chr(10) + substring (vdetpay,133,70) 
                                                                                            + chr(10) + substring (vdetpay,202).
								end.
								else 
									v-dt = v-dt + substring (vdetpay,1,62) 
                                                                                    + chr(10) + substring (vdetpay,63,70) 
                                                                                    + chr(10) + substring (vdetpay,133).
							end.
							else 
								v-dt = v-dt + substring (vdetpay,1,62) + chr(10) + substring (vdetpay,63).
						end.
						else 
							v-dt = v-dt + vdetpay .
					end.
					v-dt = v-dt + chr(10).

					if v-dt = ":70:" then 
						v-dt = "".
					t-amt = trim(string(remtrz.payment,"zzzzzzzzzzzzzzz9.99-")).
					t-amt = replace (t-amt, ".", ",").
					repeat:
						if substr(v-on,index(v-on,"/RNN/") + 4,1) = " " then 
							v-on = replace(v-on,"/RNN/ ","/RNN/") . 
						else 
							leave . 
					end.                 

					if v-new102 then 
					do:
						mt102sum = 0 .
						num102 = num102 + 1.
						ref102 =  "G"+ substring(string(year(g-today)),3,2) + 
                                                          string(month(g-today),"99") + 
                                                          string(day(g-today),"99") +
                                                          "-" + filenumstr +  "-" + string(num102). 
      /*iban*/
						put stream main unformatted
                                                         "\{1:" +  v-tnum + "\}" skip "\{2:I102" +
                                                         "SGROSS000000U3003"  + "\}" skip "\{4:" skip
                                                         ":20:" ref102  skip.
						put stream main unformatted
                                             /*iban*/
                                                            ":52B:" + trim(v-clecod) + chr(10) +
                                                        if remtrz.rbank ne remtrz.rcbank then
                                                            ":54B:" + trim(remtrz.rcbank)  + chr(10) else ""
                                                            ":57B:" + trim(remtrz.rbank)
                                                            skip  
                                                            ":70:" skip 
                                                            "/DATE/" substring(string(year(g-today)),3,2) month(g-today)
                                                            format "99" day(g-today) format "99"
                                                            skip 
                                                            "/SEND/07" skip  
                                                            "/PSO/01" skip
                                                            "/PRT/05" skip.
					end.

					if not l-102 then 
					do:
      /*iban*/
						put stream main unformatted
                                                    "\{1:" +  v-tnum + "\}" skip "\{2:I100" + 
                                                    "SGROSS000000U3003"  + "\}" skip "\{4:"
                                                    skip    
                                                    ":20:" remtrz.remtrz skip 
                                                    ":32A:" substring(string(year(iddat)),3,2) month(iddat)
                                                    format "99" day(iddat) format "99"
                                                    crc.code format "x(3)"
                                                    t-amt skip .
					end.
					else /*  mt102  */  
					do:
                                               put stream main unformatted
                                               ":21:" remtrz.remtrz skip
	                                       ":32B:" 
                                               crc.code format "x(3)" 
                                               t-amt skip. 
					end.

                                        if v-bin = yes then v-on = replace(v-on,"RNN","IDN"). 
					put stream main unformatted   caps(v-on).

					find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
					if avail sub-cod and sub-cod.rcod ne '' and sub-cod.rcod matches "*,*,*" then 
					do :
						put stream main unformatted "/IRS/" +
							substr(entry(1,sub-cod.rcod,","),1,1) skip.
						put stream main unformatted "/SECO/" +
							substr(entry(1,sub-cod.rcod,","),2,1) skip.
					end.

					if not l-102 then 
					do:
 				             /*iban*/
                                 		put stream main unformatted
								":52B:" + trim(v-clecod) + chr(10) +
								":57B:" + trim(remtrz.rbank)
							skip.
					end.
					
					find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock. 
					u-remtrz.t_sqn = if not l-102 then remtrz.remtrz else ref102 .
					u-remtrz.ref =  "p" + daynum + filenumstr +
							if not l-102 then  ".eks/100/"
							else              ".eks/102/" + string(num102) + "/" .
					find current u-remtrz no-lock.
		
					mt102sum = mt102sum + remtrz.payment .

                                        if v-bin = yes then v-bn = replace(v-bn,"RNN","IDN"). 
					put stream main unformatted caps(v-bn).

					find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
					if avail sub-cod and sub-cod.rcod ne '' and sub-cod.rcod matches "*,*,*" then 
					do :
						put stream main unformatted "/IRS/" +
							substr(entry(2,sub-cod.rcod,","),1,1) skip.
						put stream main unformatted "/SECO/" +
							substr(entry(2,sub-cod.rcod,","),2,1) skip.
					end.

					put stream main unformatted caps(v-dt) . 
					if v-last102 then 
					do:
						t-amt = trim(string(mt102sum, "zzzzzzzzzzzzzzz9.99-")) .
						t-amt = replace (t-amt, ".", ",").
						put stream main unformatted ":32A:"
							substring(string(year(iddat)),3,2) month(iddat) format "99" day(iddat) format "99"
							crc.code format "x(3)" t-amt skip 
							"-}"  skip .
						v-seeklast = yes.
					end.
					if not l-102 then 
					do:
						put stream main unformatted "-}"  skip .
						v-seeklast = yes.
					end.
					cnt = cnt + 1 .
					amttot = amttot + remtrz.payment .
					put stream prot unformatted cnt ":"
						trim(remtrz.remtrz)
						if index(remtrz.sqn,".",19) = 0 then caps(substring(remtrz.sqn, 19))
						else caps(substring(remtrz.sqn,19, index(remtrz.sqn, ".", 19) - 19)) ":"
						v-ks ":" remtrz.payment " - p" + daynum + filenumstr + ".eks"
						if l-102 then " (102_" + string(num102) + ")" else ""
						skip.
				end.  /* not pension    */    
			output stream main close .

			/* если что-нибудь писалось в файл - перепишем в общий файл */
			if filenum > 0 then 
			do: /* для МТ102 - прибавить полученный файл к общему сообщению */
				unix silent value("cat /tmp/ggg.eks >>" + v-unidir + "p" + daynum + filenumstr + ".eks") .
				unix silent /bin/rm -f /tmp/ggg.eks.
			end.
		end.  /*  for each t-docs   */ 
end. /*do transaction*/

	output stream prot close.

/* 20.04.2004 nadejda - обработка налоговых платежей с ARP-счетов */
find first t-rmztax no-error.
if avail t-rmztax then 
do:
	run lb100tax (iddat, "g", cnt, output v-sum, output v-kol).
	amttot = amttot + v-sum.
	cnt = cnt + v-kol.
end.
/*****************************/

/*  galina - обработка оплаты ИР по ОПВ и СО */
find first t-pnjink no-error.
if avail t-pnjink then 
do:
    
	run lb102ink (iddat, "g", cnt, output v-sum, output v-kol).

	amttot = amttot + v-sum.
	cnt = cnt + v-kol.
end.
/*****************************/
v-text = "EKS Electronic messages as-of " + string(g-today) + " was formed by " + g-ofc .
run lgps .   

output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks") append.
	put stream prot unformatted 
		"Total docs:" cnt skip
		"Total amount:" amttot skip .
output stream prot close .

v-text = "EKS Electronic reestr as-of " + string(g-today) + " have formed by "
	+ g-ofc + " Total docs: " + string(cnt) + " Total amount: " + string(amttot).
run lgps .

if vvsum  = amttot and cnt = nnsum then  
	Message  " Ok ... " view-as alert-box.  
else 
	Message " Сумма или кол-во док не равно clrdog ! " . 

pause. 

pause 0 .                                          


