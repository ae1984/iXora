/* rmzsend1.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование платежей в КЦМР
 * RUN
        Эта программа компилится на лету при вызове!

        SYNOPSES:
         1 - m_pid
         2 - clrdoc/clrdog
         3 - SCLEAR00/SGROSS00
         4 - cover
         5 - ""/g
 * CALLER
        rmzsend.p
 * SCRIPT

 * INHERIT

 * MENU
        5-3-5-10
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        18.11.2002 KOVAL    - Объединил процедуры формирования платежей в одну для очередей LB,LBG,V2
        sasco    - parameter IS_PENS for V2 que:
        is_pens = "a" - for all
        = "p" - only pension payments
        = "n" - all except pension payments
        18.09.2003 nadejda  - макс.количество платежей mt102_max заведено как настройка в sysc, может быть изменено в 5-3-5-11
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        01.12.2004 u00121 Сумма с которой заканчивается "клиринг"  и после которой начинается "ГРОСС"  теперь берется из sysc = "netgro"
        02.12.2004 u00121 Подробно расписал каждый блок программы (как понял конечно же),
        + теперь номер выгружаемой пачки формируется так: номер последней выгруженой + 1
        23/12/2004 u00121 выделил платежи ДРР в отдельный пункт (LB-ДРР) СЗ ї 1279 от 22/12/2004
        28/12/2004 u00121 перекомпиляция
        29/03/2005 kanat - добавил отправку платежей с очереди DROUX на DROUF после инициации отправки с обычных очередей
        ответственными сотрудниками отдела контроля.
        05/04/2005 sasco - добавил индексы
        19/04/2005 kanat - добавил обработку очереди DRLBG
        17/06/2005 kanat - закомментировал обработку очередей DRLB, DRPR, DRLBG (строки с 276 по 300)
        13/10/2005 ten - добавил cрочные платежи
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        19/08/2013 galina  - добавла обработку СМЭП
        20/08/2013 galina - строго определила sysc и pksysc

*/




{mainhead.i}
{lgps.i "new"}

def input parameter i_m_pid as char.
def input parameter i_system as char format "x(8)".
def input parameter i_cover as integer.
def input parameter is_pens as char. /* 'a' = all, 'p' = pension, 'n' = not pension */

def var k1 as  int.
def var k2  as int.
def var nbank as inte.
def var vsum as deci format "zzz,zzz,zzz,zzz.99".
def var sum1 as deci format "zzz,zzz,zzz,zz9.99" label "Минимальная" init 0.0.
def var sum2 as deci format "zzz,zzz,zzz,zz9.99" label "Максимальная" init 0.0.
define buffer chktbl for remtrz.
def var nk as inte.
def new shared var ddat as date.
def var iddat as date.
def new shared var s-datt as date.
def var vvans as logi format "да/нет" initial false.
def new shared var s-num like clrdoc.pr.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var vnum like clrdoc.pr init 1.
def var v_num like clrdoc.pr  init  1.
def new shared var vvsum as deci.
def var otv as log init false.
def new shared var nnsum as inte.
def var msgg1 as char initial
"Enter-выбор;1-печ.сопр.док-ов;2-печ.плат.пор;3-свод по контр;4-клиринг;9-монитор пачки;F4-выход".
def var lbnstr as cha .
def var veids as  log .
def var bbcod as char.
def var depart as char.
def var ind as int.
def new shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(9)"
    field bbic like bankl.bic
    field quo as inte format "zzzzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".

def buffer b-que for que.
def var v-rnnnk as char.
def var v-rnn as char.
def var v-nnn as integer.
def temp-table tmp-rmz
    field remtrz as char
    field bank   as char
    field rnnnk  as char
    field kbk    as char
    index itmprmz is primary remtrz.

/* timur ********************************/
def var mt102_cnt as int init 0.
def new shared var mt102_max as int init 150.
/* timur ********************************/
def new shared var mtsize as integer init 63. /* максимальный размер файла сообщения в килобайтах */

/*galina*/
def var v-smepamt like remtrz.payment.

v-smepamt = 0.
find first pksysc where pksysc.sysc = 'SmepAmt' and pksysc.credtype = '0' no-lock no-error.
if not avail pksysc or pksysc.deval = 0 then do:
    message "Не найдена запись SmepAmt в sysc!" view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.
v-smepamt = pksysc.deval.
/********/


/* для использования BIN */
{chbin.i}

/*Ностро-счет в Центр.Банке**************************************/
find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then do:
	message  "Отсутствует запись LBNSTR в таблице SYSC!".
	pause .
	return.
end.
lbnstr = trim(sysc.chval) .

find sysc where sysc.sysc = "CLECOD" no-lock no-error.
if not avail sysc then do:
	v-text = " Записи CLECOD нет в файле sysc " .  run lgps.
	return .
end.
bbcod = substr(trim(sysc.chval),1,6).

/* 18.09.2003 nadejda - макс.количество платежей и макс.размер файла заведены как настройка в sysc,
                        настройки могут быть изменены в 5-3-5-11 */
find sysc where sysc.sysc = "mt102n" no-lock no-error.
if avail sysc then do:
	mt102_max = sysc.inval.
	mtsize = sysc.deval.
end.
mtsize = mtsize * 1024.

m_pid = i_m_pid. /*очередь с которой выгружаем LB, LBG, V2*/
clear frame ans.

ddat = g-today. /*устанавливаем текущую дату прагмы*/
if m_pid="V2" then do:
	iddat = g-today + 1. /*если обрабатываем очердь V2, то берем следующий день*/
        update "Дата выгрузки:" iddat with row 3 no-label centered frame dat. /*если что, можем поменять*/
end.
else
	iddat=ddat. /*если не V2, оставляем текущую дату*/

/********************************************************************************************************************************/
/***Проверим, формировались ли сегодня пачки*************************************************************************************/
find first {1} where {1}.rdt = ddat no-lock no-error.
if available {1} then
do:
/* u00121 02/12/2004 раньше , если в середине номеров пачек удалялась пачка, то она находилась и предлагалась формироваться, т.е. заполнялся пробел...
	repeat:
		find first {1} where {1}.rdt = ddat and {1}.pr = vnum no-lock no-error.
		if available {1} then  vnum = vnum + 1.
		else leave.
	end.
*/
	/*Теперь берем только номер последней пачки выгруженой сегодня u00121 02/12/2004...*/
	find last {1} where {1}.rdt = ddat use-index rdtpr no-lock no-error.
	if available {1} then  vnum = {1}.pr + 1. /*... и получаем номер следующей пачки*/

	v_num = vnum -  1. /*сохраняем номер последней выгруженой пачки*/
	disp "Номер пачки по " + i_system + " ?" format "x(25)" with row 3 column 19 no-label frame ans.
	update vnum format "zz9  " with row 3 column 19 no-label frame ans.

	/****еще раз проверим, была ли выгружена уже пачка с таким номером***************************************************************/
	find first {1} where {1}.rdt = ddat and {1}.pr = vnum no-lock use-index rdtpr no-error.
	if available {1} and vnum = v_num  then
	do: /*если была,*/
		if ddat = g-today then /*и дата пачки совпадает с текущей датой*/
		do: /*спрашиваем*/
			displ caps(g-ofc) label "Вам переформировать ? " with side-label centered frame ans1.
			update vvans with  no-label  centered frame ans1.  /*да/нет*/
			hide frame ans1.
		end.
	end.
	else /*если пачка с полученым номером не была выгружена, или запись в таблице о ней отсутсвует*/
		if vnum < v_num then  /*и этот номер меньше полученого номера последней пачки*/
			vvans = false.  /*то ее не формируем*/
		else
			vvans = true. /*иначе происходит формирование*/
	/********************************************************************************************************************************/
end. /*  if avail {1}   */
else /*если пачки сегодня вообще не формировались*/
	vvans = true. /*то формируем первую пачку*/
/********************************************************************************************************************************/
/********************************************************************************************************************************/


if ddat <> g-today then vvans = false. /*если по каким то причинам дата выгрузки, полученая выше, отличается от текущей даты прагмы,
					то не выгружаемся, честно говоря смысла этой операции я так и не понял, но на всякий случай оставил (u00121)*/
/********************************************************************************************************************************/
/********************************************************************************************************************************/
if vvans = true  then  /*нужно ли проводить формирование?*/
do: /*да*/
        /********************************************************************************************************************************/
	/* Установим суммы по умолчанию */
	find first sysc where sysc.sysc = "netgro" no-lock. /*в netgro лежит сумма с которой начинается "ГРОСС" u00121 01/12/2004*/
	if i_system="SCLEAR00" then
		assign sum1=0 sum2= sysc.deval. /*3000000. так было u00121*/
	if i_system="SGROSS00" then
		assign sum1=0 sum2=200000000.01. /*200000000 так было u00121*/
	if i_system="SMEP0000" then
		assign sum1=0 sum2= v-smepamt + 0.01. /*500000.01.galina добавила СМЭП*/


	/* Установим суммы по умолчанию */
	/********************************************************************************************************************************/
	update sum1 sum2 with centered side-labels frame sumf title "Интервал сумм". /*можно "апдейтить" интревалы сумм*/
	hide frame sumf.
	veids = true .
        /*Еще раз проверим наличие пачки с выбранным номером и за выбраную дату*********************************************************/
	find first {1} where {1}.rdt = ddat and {1}.pr = vnum no-lock use-index rdtpr no-error.
	if available {1} then do: /*если была...*/
		if {1}.maks = true then do: /*и была выгружена, то спросим*/
			update i_system view-as text " сегодня уже сформирован. Переформировать ?" otv with centered no-label frame ans3.
			hide frame ans3.
		end.
		else otv = true.
		if otv = false then undo, retry.
	end.
	/********************************************************************************************************************************/
	message " Ж д и т е ...".
	/********************************************************************************************************************************/
	main: do transaction:
			/*******************************************************************************************************/
        	for each {1} where {1}.rdt = ddat and {1}.pr = vnum use-index rdtpr: /*вытаскиваем и удаляем из пачки все платежы*/
				find remtrz where remtrz.remtrz = {1}.rem exclusive-lock. /*ищем платеж в ПС*/
				find que where que.remtrz = {1}.rem exclusive-lock. /*Ищем его очередь*/
				que.pid = m_pid. /*и меняем ее на ту с которой выгружаем*/
				que.con = "W" .
				v-text = remtrz.remtrz + " have returned -> " + m_pid. /*это для лога*/
				run lgps.
				delete {1}. /*удаляем из пачки*/
			end.  /*  for each {1}  */
			/*******************************************************************************************************/
 			k1 = 0.
			k2 = 0.
			/********************************************************************************************************************************/
			/* Выбираем только одну дату для V2*/

			for each que where que.pid = m_pid use-index fprc no-lock:

               for each remtrz where remtrz.remtrz = que.rem no-lock:


			       /* Проверка на РНН в базе НК */
                        if index(remtrz.ord,"/RNN/") > 0 then do:
                               v-rnn = trim(substr(remtrz.ord,index(remtrz.ord,"/RNN/") + 5, 12)).
                               find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.rem and sub-cod.d-cod = 'eknp' no-lock no-error.
                               if avail sub-cod and num-entries(sub-cod.rcode) = 3 then do:
                                  if  lookup(entry(3,sub-cod.rcode),"009,010,012,013,015,017,019,020") > 0 or  entry(3,sub-cod.rcode) > "909" then do:
                                      if v-bin = no then find first rnn where rnn.trn = v-rnn no-lock no-error.
                                                    else find first rnn where rnn.bin = v-rnn no-lock no-error.
                                      if not avail rnn then do:
                                         if v-bin = no then find first rnnu where rnnu.trn = v-rnn no-lock no-error.
                                                       else find first rnnu where rnnu.bin = v-rnn no-lock no-error.
                                         if not avail rnnu then do:
                                            message "~n " + que.rem + "  " +  v-rnn + " РНН (ИИН/БИН) отсутствует в НК МФ  !!! ~n Все равно выгрузить платеж ? ~n (при ответе 'no' платеж пойдет на очередь 31)" view-as alert-box QUESTION BUTTONS YES-NO TITLE ""
                                            UPDATE choice AS LOGICAL.
                                            CASE choice:
                                                 WHEN TRUE THEN /* Yes */
                                                 do:
                                                 end.
                                                 WHEN FALSE THEN /* No */
                                                 do:
                                                     find first b-que where b-que.rem = que.rem exclusive-lock .
                                		     b-que.pid = "31".
				                     b-que.con = "W" .
				                     v-text = remtrz.remtrz + " have returned -> 31 No find RNN in DB NK" . /*это для лога*/
				                     run lgps.
                                                     next.
                                                 end.
                                            end CASE.

                                          end.
                                      end.
                                  end.
                               end.
                        end.
                              /***********************************************/

			       find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz  and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
                   if avail sub-cod then ind = 1.
                   else ind = 2.

/*message '2 ' lbnstr = remtrz.cracc remtrz.cover = i_cover  remtrz.jh1 <> ? remtrz.payment >= sum1 remtrz.payment <= sum2 is_pens = 'a'  ind = 2 que.pid = 'LBG'. pause.*/
                                     /* нужные rmz */
			        if     remtrz.cracc = lbnstr  /*то с Ностро-счетом в Центр.Банке*/
					and remtrz.cover = i_cover  /*тока с указаным транспортом*/
					and remtrz.jh1 <> ?  /*то те у кого есть первая проводка*/
					and remtrz.payment >= sum1 /*больше или равен первом пределу выбраных сумм*/
					and remtrz.payment <= sum2  /*меньше второго предела выбраных сумм*/
					and ((is_pens = 'a' and ind = 2 and que.pid = 'LBG') /*все платежи из LBG 23/12/2004 u00121*/
					or (is_pens = 'a'   and remtrz.source <> 'PRR'  and que.pid = 'LB') /*Все платежи из LB кроме ДРР 23/12/2004 u00121*/
					or  (is_pens = 'PRR' and remtrz.source = is_pens and que.pid = 'LB') /*Все платежи ДРР из LB 23/12/2004 u00121*/
					or  (is_pens = 'n' and index(remtrz.rcvinfo[1], "/PSJ/") = 0)
					or  (is_pens = 'p' and index(remtrz.rcvinfo[1], "/PSJ/") <> 0)
                    or  (is_pens = 's' and ind = 1 and que.pid = 'LBG' )
                    or (is_pens = 'n' and que.pid = 'SMP'))  /* все срочные платежи */
					and remtrz.valdt2=iddat then do:


         				find first {1} where {1}.rem eq remtrz.remtrz and {1}.rdt = ddat use-index rem no-lock no-error.

         				if not available {1} then do: /*transaction*/ /*если такая RMZ еще не выгружалась, то выгружаем ее*/
         					k1 = k1 + 1.
         					disp  remtrz.remtrz label "Обработано " k1 label "#" m_pid label "код очереди " with side-label centered no-box frame ans4.
         					pause 0.
         					create {1}.
         						{1}.rem = remtrz.remtrz.
         						{1}.bank = remtrz.rbank.
         						{1}.amt = remtrz.payment.
         						if remtrz.ba begins '/' then {1}.tacc = substring(remtrz.ba,2). else {1}.tacc = remtrz.ba.
         						{1}.facc = remtrz.sacc.
         						{1}.rdt = ddat.
         						{1}.pr = vnum.
         						{1}.maks = false.
         						s-remtrz = remtrz.remtrz.
         					 run KISC_ps(m_pid,vnum,s-remtrz,i_system). /* Отправляем на STW */
         				end.

				end. /* нужные remtrz */


   			   end. /* remtrz */
			end. /* que */
			hide frame ans4.
			/* Выбираем только одну дату для V2*/
			/********************************************************************************************************************************/

/* 29.03.2005 kanat - перенос платежей для корр. отношений */

/*
                for each que where que.pid = "DRLB" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.

                for each que where que.pid = "DRPR" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.

                for each que where que.pid = "DRLBG" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.
*/

/* 29.03.2005 kanat - перенос платежей для корр. отношений */


		end. /* of transaction */
	/********************************************************************************************************************************/
	u_pid =  ''.
	v-text = i_system + " номер  " + string(vnum)  + " сформирован ".
	run lgps.
end.
/********************************************************************************************************************************/
/********************************************************************************************************************************/

/********************************************************************************************************************************/

if i_m_pid = "LB" and is_pens = 'PRR' then do:
for each {1} where {1}.rdt = ddat and {1}.pr = vnum no-lock use-index rdtpr:
    find first remtrz where remtrz.remtrz = {1}.rem no-lock use-index rem no-error.
    if avail remtrz and remtrz.rcvinfo[1] matches "*TAX*" then do:

        v-rnnnk = trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]).
        v-nnn = index (v-rnnnk, "/RNN/").
        if v-nnn = 0 then v-rnnnk = "".
                     else v-rnnnk = substr(trim(substr(v-rnnnk, v-nnn + 5)), 1, 12).

            create tmp-rmz.
            update tmp-rmz.remtrz = remtrz.remtrz
                   tmp-rmz.bank = remtrz.rbank
                   tmp-rmz.rnnnk = v-rnnnk
                   tmp-rmz.kbk = entry(num-entries(trim(remtrz.ba), "/"), trim(remtrz.ba), "/").
    end. /* avail remtrz */
end. /* for each clr... */

/********************************************************************************************************************************/
/* 04/04/2005 kanat - налоговые пачки формируются отдельно */

mt102_cnt = 0.

for each tmp-rmz no-lock by tmp-rmz.bank by tmp-rmz.rnnnk by tmp-rmz.kbk.
    find first {1} where {1}.rem = tmp-rmz.remtrz use-index rem no-error.
    if avail {1} then do:
    	mt102_cnt = mt102_cnt + 1. /*считаем количество платежей в пачке*/
    	if mt102_cnt > mt102_max then  /*если их больше максимально допустимых*/
     				{1}.pr = vnum + 1.
    end.
end.

/* 04/04/2005 kanat - не налоговые пачки формируются отдельно */

for each {1} where {1}.rdt = ddat and {1}.pr = vnum:
    find first tmp-rmz where tmp-rmz.remtrz = {1}.rem no-lock no-error.
    if not avail tmp-rmz then do:
    	mt102_cnt = mt102_cnt + 1. /*считаем количество платежей в пачке*/
    	if mt102_cnt > mt102_max then  /*если их больше максимально допустимых*/
    				{1}.pr = vnum + 1.
    end.
end. /* each clr... */
end. /*  lb-drr*/
else do:
     mt102_cnt = 0.
     for each {1} where {1}.rdt = ddat and {1}.pr = vnum use-index rdtpr:
     	mt102_cnt = mt102_cnt + 1.
     	if mt102_cnt > mt102_max then
     				{1}.pr = vnum + 1.
     end.
end.

find first {1} where {1}.rdt = ddat and {1}.pr = vnum + 1 no-lock use-index rdtpr no-error.
if available {1} then
	message "Часть платежей переведена в пачку " vnum + 1 view-as alert-box.
/* timur ******************************************************/
/********************************************************************************************************************************/


/********************************************************************************************************************************/
/* Формирование ведомости платежей в разрезе банков получателей */
for each {1} where {1}.rdt = ddat and {1}.pr = vnum no-lock use-index rdtpr break by {1}.bank:
	nbank = nbank + 1.
	vsum = vsum + {1}.amt.
	if last-of({1}.bank) then do:
		nk = nk + 1.
		create ree.
			ree.npk = nk.
			ree.bank = {1}.bank.
			ree.quo = nbank.
			ree.kopa = vsum.
			vvsum = vvsum + vsum.
			nnsum = nnsum + nbank.
			nbank = 0.
			vsum = 0.
	end.
end.
/* Формирование ведомости платежей в разрезе банков получателей */
/********************************************************************************************************************************/

/********************************************************************************************************************************/
/* KOVAL Формирование и отправка на различные мыла ведомости платежей в разрезе банков отправителей */

if i_m_pid="V2" then i_m_pid = i_m_pid + string(i_cover,'9').
run clrrmzm(vnum,"mailps",ddat,i_m_pid).

/* KOVAL Формирование и отправка на различные мыла ведомости платежей в разрезе банков отправителей */
/********************************************************************************************************************************/

s-num = vnum.
s-datt = ddat.

hide frame aaa.
hide frame bbb.


/***************************************	*****************************************************************************************/

{jabre.i
&start = "disp vvsum nnsum with frame kopp."
&head = "ree"
&headkey = "npk"
&where = "true"
&formname = "clrdoc"
&frameparm = "new"
&framename = "clrdoc"
&addcon = "false"
&deletecon = "false"
&prechoose = "message msgg1."
&display = "
ree.npk ree.bank ree.quo ree.kopa"
&highlight = "ree.npk ree.bank ree.quo ree.kopa"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              run clrrmz1{2}(ree.bank, ddat, vnum).
              vvsum = vvsum - ree.kopa.
              nnsum = nnsum - ree.quo.
              for each {1} where {1}.rdt = ddat and {1}.pr = vnum and
                {1}.bank = ree.bank no-lock use-index rdtpr:
                nbank = nbank + 1.
                vsum = vsum + {1}.amt.
              end.
                ree.quo = nbank.
                ree.kopa = vsum.

              nbank = 0.
              vsum = 0.
              vvsum = vvsum + ree.kopa.
              nnsum = nnsum + ree.quo.
              disp ree.bank ree.quo ree.npk
              ree.kopa with frame clrdoc.
              disp vvsum nnsum with frame kopp.
            end.
            else if keyfunction(lastkey)='1' then do:
               run clrrmzp1.
            end.
            else if keyfunction(lastkey) = '2' then do:
               run clrrmzp2('*').
            end.
            else if keyfunction(lastkey) = '3' then do:
               message ' Ж д и т е ... '.
               run crmzusr{2}.
               disp ree.bank ree.quo ree.npk ree.kopa with frame clrdoc.
               disp vvsum nnsum with frame kopp.
            end.
            else if keyfunction(lastkey) = '4' then do:
             run lbto{2}(iddat,m_pid).
             view  frame mainhead.
             pause 0.
             view frame dat .
             view frame ans .
             pause 0 .
             view frame clrdoc .
             view frame kopp .
            end.
            else if keyfunction(lastkey) = '9' then do:
                run clrrmzm(vnum,'menu-prt',ddat,i_m_pid).
            end."
&end = "hide frame clrdoc. hide frame ans. hide frame dat. hide frame kopp.
hide message."
}

/********************************************************************************************************************************/
