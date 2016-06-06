/* 8_ps.p
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


{global.i}
{lgps.i }
def var v-sqn as cha .
def var v-field as char.
def var v-amt like remtrz.payment.
def var v-crc like remtrz.tcrc.
def var num as cha.

 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Нет M-DIR записи в sysc файле " .  run lgps.
  return .
 end.

for each  que where que.pid = m_pid and que.con = "W" use-index fprc exclusive-lock .
	que.dw = today.
	que.tw = time.
	find first remtrz where remtrz.remtrz = que.remtrz no-lock .

	/*  Beginning of main program body */

	find first conf  where conf.remtrz = que.remtrz exclusive-lock no-error .

	if  not avail conf then 
	do:
		if remtrz.valdt2 < g-today and time - que.tp > 3600  then 
		do :
			v-text = "Внимание ! Подтверждение не получено втечение " + string(g-today - remtrz.valdt2) + " дней для " + remtrz.remtrz .
			que.con = "F".
			que.rcod = "1".
			run lgps.
		end.
		que.dp = today.
		que.tp = time.
		release que .
		release remtrz.
		next .
	end.

	v-sqn = conf.remtrz .
	v-amt = conf.payment .
	v-crc = conf.crc .
	num   = conf.sqn .

	if remtrz.payment <> v-amt or remtrz.tcrc <> v-crc then 
	do :
		if remtrz.payment <> v-amt then
			v-text = " Ошибка в сумме платежа SQN = " + string(num) + " " + remtrz.remtrz.
		else
			v-text = " Ошибка в валюте платежа SQN = " + string(num) + " " + remtrz.remtrz.
		run lgps.
		que.dp = today.
		que.tp = time.
		que.con = "F".
		que.rcod = "1".
		delete conf.
		release que .
		release remtrz.
		next .
	end.
	v-text = " Получено подтверждение из " + remtrz.rcbank + " сумма " + string(remtrz.payment) + string(remtrz.tcrc) +  " SQN = " + string(num) + " " + remtrz.remtrz + " тип= " + remtrz.ptype .
	/*  End of program body */
	que.dp = today.
	que.tp = time.
	que.con = "F".
	que.rcod = "0".
	delete conf .
	release que .
	release remtrz.
	run lgps.
end.
