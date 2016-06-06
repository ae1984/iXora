/* q-tnlist.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
           Обновление списка сотрудников из базы "ЗАРПЛАТА"
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
   18.11.2002 nadejda создан
   24.05.2003 nadejda - убраны параметры -H -S из коннекта 
   30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам

*/


{global.i}

def new shared temp-table t-tn
  field tn as char
  field name as char
  field depname as char
  field dep as char
  field fired as logical
  index itn tn.

def var v-path as char.

for each t-tn. delete t-tn. end.

if not connected ("alga") then 
do:
	/*
  find sysc where sysc.sysc = "rkbdir" no-lock no-error.
  if not avail sysc then do:
    message "Не найден системный параметр!". 
    pause.
    return "1".
  end.
  v-path = trim(sysc.chval).
  connect value("-db " + v-path + "alga/alga.db -ld alga").
	*/
  find last bank.cmp no-lock no-error.
  if avail bank.cmp then
  do:
	  find last comm.txb where comm.txb.city = 998 and comm.txb.txb = bank.cmp.code no-lock no-error.
	  if avail comm.txb then
	  do:
	  	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga").	
	  end.
	  else
	  do:
	  	message "Отсутсвуют параметры зарплатной базы"  skip 
	  		"для " bank.cmp.name skip
	  		"Дальнейшая работа не возможна!" view-as alert-box.
	  	return.
	  end.
  end.
  else
  do:
  	message "Отсутствует настройка банковского профайла!" skip 
  		"Дальнейшая работа не возможна!" view-as alert-box.
  	return.
  end.
end.


run ofctns-list.

disconnect "alga".

for each t-tn:
  find ofc-tn where ofc-tn.tn = t-tn.tn no-error.
  if avail ofc-tn then do:
    if ofc-tn.name <> t-tn.name then
      ofc-tn.name = t-tn.name.

    if ofc-tn.fired <> t-tn.fired then
      assign ofc-tn.fired = t-tn.fired 
             ofc-tn.fireddt = g-today.

    if ofc-tn.dep <> t-tn.dep then do:
      ofc-tn.dep = t-tn.dep.
      ofc-tn.depname = t-tn.depname. 
    end.
  end.
  else do:
    create ofc-tn.
    assign 
      ofc-tn.tn = t-tn.tn
      ofc-tn.fired = t-tn.fired
      ofc-tn.name = t-tn.name
      ofc-tn.dep = t-tn.dep
      ofc-tn.regdt = g-today
      ofc-tn.depname = t-tn.depname.
  end.
end.

return "0".



