/* dcls32.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
*/

/* dcls32.i - из dcls32.p
   Расчет комиссии за ведение счета за текущий месяц - в таблицу, указанную в параметре {&head}

   23.12.2002 nadejda - расчеты выделены в dcls32.i, чтобы можно было делать предварительные расчеты во временной таблице (п.8.1.8.6)

   15.01.2004 valery - тз 672 от 07.01.04  теперь с счетов сотрудников банка "ЕМР" принадлежащих группам 241,242,243 не снимается комиссия с минимального остатка
   11.10.2004 saltanat - в Атырау внесла снятие комиссии для ЧП.
   08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
   28.02.2005 u00121 - добавлено поле gl для поиска по jl, а то индекс acc не подцеплялся
   05.07.2005 saltanat - Выборка льгот по счетам.
   26/08/2005 madiyar - комиссия не берется по тек. счетам для погашения кредитов БД
   02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
   06/04/2010 madiyar - комиссия по тек. счетам для погашения кредитов БД не берется независимо от того погашен кредит или нет
   20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
   25/11/2013 Luiza   - ТЗ 2181 поиск по таблице comon
*/

{curs_conv.i}

def buffer b     for aaa.
def buffer blgr  for lgr.
def var v-gl     like gl.gl.
def var v-des    as char.
      def var v-chgb   as char initial "104".  /* за ведение счета ЮЛ в тенге c оборотами -785тг      */
      def var v-chgb3  as char initial "154".  /* за ведение счета ЮЛ в тенге без оборотов - 50       */
      def var v-chgb2  as char initial "192".  /* за ведение счета ЮЛ в валюте c оборотами -0 тг */
      def var v-chgb4  as char initial "153".  /* за ведение счета ЮЛ в валюте -при отсутствии денег на счете */
      def var v-chgp   as char initial "105".  /* за ведение счета ФЛ в валюте -10$                   */
      def var v-chgp2  as char initial "195".  /* за ведение счета ФЛ в тенге  -5$                    */
      def var v-chgx   as char initial "008".  /* за ведение счета ЧП в тенге с оборотами -250тг      */
      def var v-chgx2  as char initial "010".  /* за ведение счета ЧП в валюте без оборотов -50 тг    */


def var v-period as char.
def var s-feemon like jl.dam.
def var s-amt    like jl.dam.
def var vbal     like jl.dam.
def var vavl     like jl.dam.
def var vhbal    like jl.dam.
def var vfbal    like jl.dam.
def var vcrline  like jl.dam.
def var vcrlused like jl.dam.
def var vooo     like aaa.aaa.
def var v-param  as char.
def var vdel     as char initial "^".
def var v-templ  as char.
def var rcode    as int.
def var rdes     as char.
def var s-jh     like jh.jh.
def var v-cnt    as int.
def var v-cntp   as int.
def var v-cntn   as int.
def var v-sump   like jl.dam.
def var v-sumn   like jl.dam.
def var v-pay    as log.
def buffer bcrc  for crc.
def var v-bool   as log.

def var v-chval  as char.

def var paym  like rem.payment.
def var kod12 like rem.crc2.
def var tcif  like cif.cif .


def var kod11     like rem.crc1.
def var tproc     like tarif2.proc .
def var tmin1     as dec decimals 10 .
def var tmax1     as dec decimals 10 .
def var tost      as dec decimals 10 .
def var v-sum     as dec.
def var konts     like tarif2.kont.
def var pakal     as char.
def var v-err     as log.
def var v-headoff as log init false.
def var v-jl      as log init false.
def var v-beg     as date.

def buffer bf for sub-cod.
def var v-ourbnk  as char init ''.
def var v-chp     as logi init false.
def var bilance   as dec.

find sysc where  sysc.sysc matches "ourbnk" no-lock no-error.
v-headoff = (avail sysc) and (sysc.chval = "TXB00").
if avail sysc then
		v-ourbnk  = sysc.chval.

/*1-ый блок  ЮЛ*************/

v-period = substring(string(g-today,"99/99/9999"),7,4) + "/" + substring(string(g-today,"99/99/9999"),4,2).
v-beg = date(month(g-today),1,year(g-today)).

s-jh = 0.
FOR EACH lgr  NO-LOCK BREAK BY lgr:
if (lgr.led = "SAV" OR lgr.led = "DDA") AND  lgr.feemon NE 0.00 then
do:
	v-sump = 0.
	v-sumn = 0.
	v-cnt = 0.
	v-cntn = 0.
	v-cntp = 0.

	FOR EACH aaa WHERE aaa.lgr = lgr.lgr no-lock:
		v-jl = false.
		/*   кроме освобожденных от уплаты "F" счетов, законченных "M",временных "T" и закрытых "C"  */
		if aaa.sta NE "M" AND aaa.sta NE "F" AND aaa.sta NE "C" AND aaa.sta NE "T" AND NOT aaa.sec then
		do:  /* всех счетов кpоме Х клиентов */
			find sub-cod where sub-cod.sub eq "cln" and sub-cod.d-cod eq "clnsts" and sub-cod.acc eq aaa.cif no-lock no-error.
			if not available sub-cod then next.
			if sub-cod.ccode ne "0" then next.
			/* ЧП */
			v-chp = false.
			/*  ???  * * * ??? * * * ??? * * * ??? */
			find first jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and (jdt <= g-today and jdt >= v-beg)  use-index acc no-lock no-error.
			if avail jl then do:
  			   v-jl = true.
			end.
			else
                           v-jl = false.


			if aaa.crc <> 1 then
			do:
				if v-chp then do:
     		                   if v-jl = true then
				      run perev0(aaa.aaa, v-chgb2, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
				   else
 				      run perev0(aaa.aaa, v-chgb4, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).

				end.
				else do:
				     if v-jl = true then
					run perev0(aaa.aaa, v-chgb2, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
                                     else
					run perev0(aaa.aaa, v-chgb4, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
				end.
			end.



			if aaa.crc  eq 1  then
			do:
				if v-chp then do:
                                   if v-jl = true then
  			              run perev0(aaa.aaa, v-chgb, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
  			           else
  			              run perev0(aaa.aaa, v-chgb3, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
				end.
				else
				do:
                                   if v-jl = true then
  			              run perev0(aaa.aaa, v-chgb, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
  			           else
  			              run perev0(aaa.aaa, v-chgb3, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
				end.
			end. /*aaa.crc = 1*/




			if tost gt 0 then
			do:
				find first cif where aaa.cif = cif.cif no-lock.
				CREATE {&head}.
					{&head}.cif = aaa.cif.
					{&head}.aaa = aaa.aaa.
					{&head}.crc = kod11.
					{&head}.tim = time.
				if v-chp then
				do:
					if aaa.crc <> 1 then
						if v-jl then
                                                   {&head}.type = v-chgb2.
						else
                                                   {&head}.type = v-chgb4.

					else
						if v-jl then
							{&head}.type = v-chgb.
                                                else
  					                {&head}.type = v-chgb3.
				end.
				else
				do:
					if aaa.crc <> 1 then
						if v-jl then
                                                   {&head}.type = v-chgb2.
						else
                                                   {&head}.type = v-chgb4.
					else
					do:
						if v-jl then
                                                   {&head}.type = v-chgb.
						else
                                                   {&head}.type = v-chgb3.
					end.
				end.
				{&head}.whn = g-today.
				{&head}.who = substr(cif.fname,1,8).
				{&head}.amount = tost.
				{&head}.period = substring(string(g-today,"99/99/9999"),7,4) + "/" + substring(string(g-today,"99/99/9999"),4,2).
				{&head}.rem = pakal + ". За " + {&head}.period + ". Счет " + aaa.aaa.
                find first comon where comon.aaa = aaa.aaa no-lock no-error.
                if available comon then do: {&head}.aaa = comon.aaac. {&head}.pref = yes. end.
			end.

		end.
	end.
end.
end.
/* ******************************************************* */

/*2-ой блок ФЛ*/

v-period = substring(string(g-today,"99/99/9999"),7,4) + "/" + substring(string(g-today,"99/99/9999"),4,2).

def var v-tlist as char.
def var v-llist as char.
def var i as int.
def var v-d as date.

find sysc where sysc eq "fizact" no-lock no-error.
if available sysc then
	v-tlist = sysc.chval.
else
	v-tlist = "SAV".
find sysc where sysc eq "fizlim" no-lock no-error.
if available sysc then
	v-llist = sysc.chval.
else
	v-llist = "1,1000,2,100,3,100,11,100".

def temp-table wt
	field crc like crc.crc
	field amt like glbal.bal
	index wt is unique crc.

if num-entries(v-llist) mod 2 eq 0 then
do:
	do i = 1 to num-entries(v-llist) by 2 :
		create wt.
			wt.crc = integer(entry(i,v-llist)) no-error.
			if error-status:error then
				delete wt.
			else
			do:
				wt.amt = decimal(entry(i + 1,v-llist)) no-error.
				if error-status:error then
					delete wt.
			end.
	end.
end.




find sysc where sysc.sysc = "LGREMP" no-lock no-error. /*Находим список групп счетов клиентов - сотрудников банка, по которым не снимается комиссия*/
if  avail sysc then
	v-chval = sysc.chval.
else
	v-chval = "".

s-jh = 0.
for each cif no-lock:
	find sub-cod where sub-cod.sub eq "cln" and sub-cod.d-cod eq "clnsts" and sub-cod.acc eq cif.cif no-lock no-error.
	if not available sub-cod then
					next.
	if sub-cod.ccode ne "1" then
					next.

	for each aaa where aaa.cif = cif.cif no-lock:
		if lookup(aaa.lgr,v-chval) > 0 and cif.mname = "EMP" then
		do:
			next. /*Со всех счетов клиентов, которые являются сотрудниками банка не снимается комиссия с минимального остатка*/
		end.

		find lgr where lgr.lgr = aaa.lgr no-lock no-error.
		if lookup(lgr.led,v-tlist) eq 0 then
							next.

		if aaa.lgr = '235' then
					next.
		/*  кроме освобожденных от уплаты "F" счетов, законченных "M",временных "T" и закрытых "C"  */

		if aaa.sta eq "M" or aaa.sta eq "F" or aaa.sta eq "C" or aaa.sta eq "T" or aaa.sec      /* всех счетов кpоме Х клиентов */ then next.

		/* проверка на принадлежность счета к БД */
		if lookup(aaa.lgr,"236,237") > 0  then next.

		v-pay = no.
		find wt where wt.crc eq aaa.crc no-error.
		if not available wt then
					next.
		v-d = date(month(g-today),1,year(g-today)).
		if aaa.regdt lt v-d then
		do:
			find last aab where aab.aaa eq aaa.aaa and aab.fdt le v-d no-lock no-error.
			if not available aab then
				v-pay = yes.
			else
				if aab.bal lt wt.amt then
					v-pay = yes.
		end.
		else
		do:
			if aaa.regdt ne g-today then
			do:
				find aab where aab.aaa eq aaa.aaa and aab.fdt eq aaa.regdt use-index aab no-lock no-error.
				if not available aab then
					v-pay = yes.
				else
					if aab.bal lt wt.amt then
						v-pay = yes.
				v-d = aaa.regdt.
			end.
			else
				v-d = g-today.
		end.
		repeat while v-d lt g-today :
			find first aab where aab.aaa eq aaa.aaa and aab.fdt gt v-d use-index aab no-lock no-error.
			if available aab then
			do :
				if aab.bal lt wt.amt then
					v-pay = yes.
				v-d = aab.fdt.
			end.
			else
				v-d = g-today.

		end.
		if aaa.cr[1] - aaa.dr[1] lt wt.amt then
			v-pay = yes.
		if v-pay then
		do:
			if aaa.crc <> 1 then
				run perev0(aaa.aaa, v-chgp, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
			else
				run perev0(aaa.aaa, v-chgp2, aaa.cif, output kod11, output tproc, output tmin1, output tmax1, output tost, output pakal, output v-err).
			if tost gt 0 then
			do:
				CREATE {&head}.
					{&head}.cif = aaa.cif.
					{&head}.aaa = aaa.aaa.
					{&head}.crc = kod11.
					{&head}.tim = time.
				if aaa.crc <> 1 then
					{&head}.type = v-chgp.
				else
					{&head}.type = v-chgp2.
				{&head}.whn = g-today.
				{&head}.who = cif.fname.
				{&head}.amount  = tost.
				{&head}.period = substring(string(g-today,"99/99/9999"),7,4) + "/" + substring(string(g-today,"99/99/9999"),4,2).
				{&head}.rem = pakal + ". За " + {&head}.period + ". Счет " + aaa.aaa.
                find first comon where comon.aaa = aaa.aaa no-lock no-error.
                if available comon then do: {&head}.aaa = comon.aaac. {&head}.pref = yes. end.
			end.
		end.
	end.
end.
Procedure perev0.
def input parameter s-aaa like aaa.aaa .
def input parameter komis as char format "x(4)".
def input parameter tcif like cif.cif .


def output parameter kod11 like rem.crc1.
def output parameter tproc   like tarif2.proc .
def output parameter tmin1   as dec decimals 10 .
def output parameter tmax1   as dec decimals 10 .
def output parameter tost    as dec decimals 10 .
def output parameter pakal as char.
def output parameter v-err as log.


def var a2 like tarif2.kod.
def var a1 like tarif2.num.
def var rr as dec.
def var sum1 like rem.payment.
def var sum2 like rem.payment.
def var sum3 like rem.payment.
def var v-sumkom as dec.
def var konts like gl.gl.
def var avl_sum as deci.
def var comis as logi.

def buffer bcif for cif.

  v-err = no.
  /*a1 = trim(substring(komis,1,1)).
  a2 = trim(substring(komis,2,2)).
  find first tarif2 where  tarif2.num  = a1
                      and  tarif2.kod  = a2
                      and  tarif2.stat = 'r' no-lock no-error.*/
  find first tarif2 where  tarif2.str5 = trim(komis) and tarif2.stat = 'r' no-lock no-error.

  if available tarif2 then  do :
   if tcif <> "" then
    find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif
                         and tarifex.stat = 'r' no-lock no-error.
   if avail tarifex then do :
     if s-aaa ne '' then
            find first tarifex2 where tarifex2.aaa = s-aaa and tarifex2.cif = tcif and tarifex2.str5 = tarif2.str5 and tarifex2.stat = 'r' no-lock no-error.
            if avail tarifex2 then do:
               find first crc where crc.crc = tarifex2.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex2.pakal.
                konts = tarifex2.kont .

                /* Проверка на неснижаемый остаток */

		       find bcif where bcif.cif = tcif no-lock no-error.
		       comis = yes. /* commission > 0 */
		       avl_sum = avail_bal(s-aaa).
		       if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
        		  if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
		       end.

               tproc = if comis then tarifex2.proc else 0.
	           tmin1 = if comis then tarifex2.min1 else 0.
    	       tmax1 = if comis then tarifex2.max1 else 0.
               tost  = if comis then tarifex2.ost else 0.

            end.
            else do:
            find first crc where crc.crc = tarifex.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex.pakal.
                konts = tarifex.kont .
                tproc = tarifex.proc .
                tmin1 = tarifex.min1 .
                tmax1 = tarifex.max1 .
                tost  = tarifex.ost .
            end.
   end .
   else do :
    find first crc where crc.crc = tarif2.crc no-lock .
    kod11 = crc.crc.
    pakal = tarif2.pakal.
    konts = tarif2.kont .
    tproc = tarif2.proc .
    tmin1 = tarif2.min1 .
    tmax1 = tarif2.max1 .
    tost  = tarif2.ost  .
   end .
  end. /*tarif2*/
  else v-err = yes.
end procedure.

