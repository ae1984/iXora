/* bkupdabn.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Изменение реквизитов клиента - формирование файла 
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
        12.01.06 marinav 
 * CHANGES
*/


{global.i}
{bknewcrd.i}

def var s_bank as char.
def var v_out as logical init false.
def var s_count as inte init 0.
def var s_summ as deci init 0.
define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.

find first sysc where sysc.sysc = "CRDCMM" no-lock no-error .
if not available sysc or (avail sysc and  num-entries(sysc.chval) < 3) then do:
    message skip(1) "ПОПОЛНЕНИЕ НЕ ПРОШЛО. НЕТ ДАННЫХ В НАСТРОЙКАХ SYSC !"   skip(1) view-as alert-box title "ПОПОЛНЕНИЕ".
    return.
end.

find first bkcard where bkcard.bank = s_bank and bkcard.sta = 2 and bkcard.exec = yes  no-lock no-error.
if not avail bkcard then do: 
   message "НЕТ КАРТОЧЕК ДЛЯ ПОПОЛНЕНИЯ !"   skip(1) view-as alert-box title "ПОПОЛНЕНИЕ КАРТ".
   return.
end.

for each bkcard where bkcard.bank = s_bank and bkcard.sta = 2 and bkcard.exec = yes no-lock.
      s_count = s_count + 1.
      s_summ = s_summ + bkcard.nominal.
end.

      vparam = ' ' + vdel + string (s_summ) + vdel + '1' + vdel +
               string (entry(2, sysc.chval)) + vdel + 
               string (entry(3, sysc.chval)) + vdel +  
               "Пополнение карт , кол " + string(s_count) + 
               vdel + '1' + vdel + '1' + vdel  + '311'.
      s-jh = 0.
      
      run trxgen ("jou0036", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
          if rcode <> 0 then do: message rcode rdes. pause 100.  return.  end. 
      run jou.
      run vou_bank(1).
      /* проставим признак проводки для пл. карточек */
      find jh where jh.jh = s-jh exclusive-lock no-error.
	for each jl of jh exclusive-lock:
		jl.sts = 6.
		jl.teller = g-ofc.
	end.
        jh.party = "BWX".
	jh.sts = 6.
	release jh.
	release jl.

for each bkcard where bkcard.bank = s_bank and bkcard.sta = 2 and bkcard.exec = yes exclusive-lock.

          create mobtemp.
          assign mobtemp.phone = string (s-jh)
                 mobtemp.who = g-ofc
                 mobtemp.ctime = time
                 mobtemp.cdate = g-today
                 mobtemp.valdate = g-today
                 mobtemp.sum = bkcard.nominal   /* сумма */
                 mobtemp.rid = 1  /* валюта */
                 mobtemp.ref = bkcard.contract_number + "//" + bkcard.client  /* карточка */
                 mobtemp.state = 300   /* пополнение - ОСНОВНАЯ СУММА */
                 mobtemp.npl = "Пополнение пластиковой карточки INSTANT".
          bkcard.sta = 3. 
end.
run savelog ("crdquick", SUBSTITUTE ("Создание проводки &1 пополнения карточки INSTANT В количестве &2 на сумму &3 ", s-jh, s_count, s_summ)).

