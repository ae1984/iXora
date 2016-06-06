/* kdklass.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Классификация кредита на момент выдачи
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 Класифик
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
        07.12.03 marinav автоматич рейтинг по обеспечениям
        05.03.04 marinav - после кредитного комитета пересчитать клас-цию по одобр условиям
        30/04/2004 madiar - Просмотр досье филиалов в ГБ
        18/05/2004 madiar - Убрал возможность редактирования кода класс-ции досье филиала в ГБ.
                            Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных.
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
        20/08/2004 madiar - В связи с изменением числа пар-ров в функциях run value(kdklass.proc) - внес изменения в вызов
        24/08/2004 madiar - Исправил ошибку в вызове run value(kdklass.proc)
        25/08/2004 madiar - Исправил ошибку
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
/*
s-kdcif = 't26075'.
s-kdlon = 'KD4'.
*/
  
def var v-cod as char.
define var v-rat as deci init 0.

if s-kdlon = '' then return.


find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

/*if kdlon.sts > "02" then do:
  message skip " Менять сумму нельзя !" skip(1)
    view-as alert-box buttons ok .
  return.
end.
*/

/* {kdlonvew.i}*/

def var hanket as handle.
run kdlib persistent set hanket.
pause 0.

define variable s_rowid as rowid.
def var v-title as char init " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВ ".
def var v-fl as inte.

/*def shared var hanket as handle.*/

find first kdlonkl where kdlonkl.kdcif = s-kdcif 
                     and kdlonkl.kdlon = s-kdlon and (kdlonkl.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
if not avail kdlonkl then do:
  if s-ourbank = kdlon.bank then do:
    for each kdklass where kdklass.type = 1 use-index kritcod no-lock .
        create kdlonkl.
        assign kdlonkl.bank = s-ourbank
               kdlonkl.kdcif = s-kdcif 
               kdlonkl.kdlon = s-kdlon 
               kdlonkl.kod = kdklass.kod 
               kdlonkl.ln = kdklass.ln
               kdlonkl.who = g-ofc 
               kdlonkl.whn = g-today. 
       find current kdlonkl no-lock no-error.
    end.
  end.
  else do:
    message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
    return.
  end.
end.

/*качество обеспечения*/
define var v-sec3 as deci .  /*стоимость обеспечения по 3 группе - деньги*/
define var v-sec  as deci.  /* стоимость остального обеспечения*/
define buffer b-crc for crc.
define var bilance as deci.
define var kdval like kdlonkl.val1.

if kdlon.resume = '02' or kdlon.resume = '03' then do:
  bilance = kdlon.amount * (kdlon.rate * kdlon.srok / 1200 + 1).

  find kdlonkl where kdlonkl.kdcif = s-kdcif 
               and kdlonkl.kdlon = s-kdlon  and kdlonkl.kod = 'obesp' and (kdlonkl.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdlonkl then do: 
     find first crc where crc.crc = kdlon.crc no-lock no-error.
     v-sec = 0.
     v-sec3 = 0.
     for each kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock.
         find first b-crc where b-crc.crc = kdaffil.crc no-lock no-error.
         if kdaffil.lonsec = 3 then v-sec3 = v-sec3 + kdaffil.amount_bank * b-crc.rate[1] / crc.rate[1].
                               else v-sec = v-sec + kdaffil.amount_bank * b-crc.rate[1] / crc.rate[1].
     end.
     kdval = '05'.
     if v-sec3 > 0 and v-sec = 0 or v-sec3 = bilance then do:
        if v-sec3 >= bilance then kdval = '01'.
        if v-sec3 < bilance and v-sec3 >= 0.9 * bilance then kdval = '02'.
        if v-sec3 < 0.9 * bilance and v-sec3 >= 0.75 * bilance then kdval = '03'.
        if v-sec3 < 0.75 * bilance and v-sec3 >= 0.5 * bilance then kdval = '04'.
        if v-sec3 < 0.5 * bilance then kdval = '05'.
     end.
     if v-sec > 0 and v-sec3 ne bilance then do:
        bilance = (kdlon.amount  - v-sec3) * (kdlon.rate * kdlon.srok / 1200 + 1).
        if v-sec >= bilance then kdval = '03'.
        if v-sec < bilance and v-sec >= 0.5 * bilance then kdval = '04'.
        if v-sec < 0.5 * bilance then kdval = '05'.
     end.
     find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = kdval no-lock no-error.
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.val1 = kdval.
     if avail bookcod then assign kdlonkl.valdesc = bookcod.name 
                                  kdlonkl.rating = deci(trim(bookcod.info[1])).
     find current kdlonkl no-lock no-error.
  end.
end.

else do:
  bilance = kdlon.amountz * (kdlon.ratez * kdlon.srokz / 1200 + 1).

  find kdlonkl where kdlonkl.kdcif = s-kdcif 
               and kdlonkl.kdlon = s-kdlon and kdlonkl.kod = 'obesp' and (kdlonkl.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdlonkl then do:
     find first crc where crc.crc = kdlon.crcz no-lock no-error.
     v-sec = 0.
     v-sec3 = 0.
     for each kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock.
         find first b-crc where b-crc.crc = kdaffil.crc no-lock no-error.
         if kdaffil.lonsec = 3 then v-sec3 = v-sec3 + kdaffil.amount_bank * b-crc.rate[1] / crc.rate[1].
                               else v-sec = v-sec + kdaffil.amount_bank * b-crc.rate[1] / crc.rate[1].
     end.
     kdval = '05'.
     if v-sec3 > 0 and v-sec = 0 or v-sec3 = bilance then do:
        if v-sec3 >= bilance then kdlonkl.val1 = '01'.
        if v-sec3 < bilance and v-sec3 >= 0.9 * bilance then kdval = '02'.
        if v-sec3 < 0.9 * bilance and v-sec3 >= 0.75 * bilance then kdval = '03'.
        if v-sec3 < 0.75 * bilance and v-sec3 >= 0.5 * bilance then kdval = '04'.
        if v-sec3 < 0.5 * bilance then kdval = '05'.
     end.
     if v-sec > 0 and v-sec3 ne bilance then do:
        bilance = (kdlon.amountz  - v-sec3) * (kdlon.ratez * kdlon.srokz / 1200 + 1).
        if v-sec >= bilance then kdval = '03'.
        if v-sec < bilance and v-sec >= 0.5 * bilance then kdval = '04'.
        if v-sec < 0.5 * bilance then kdval = '05'.
     end.
     find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = kdval no-lock no-error.
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.val1 = kdval.
     if avail bookcod then assign kdlonkl.valdesc = bookcod.name 
                                  kdlonkl.rating = deci(trim(bookcod.info[1])).
     find current kdlonkl no-lock no-error.
  end.
end.

def var update_f as char.
if s-ourbank = kdlon.bank then update_f = " kdlonkl.val1 ".
else update_f = "".

{jabrw.i 
&start     = " "
&head      = "kdlonkl"
&headkey   = "kod"
&index     = "cifbank"

&formname  = "kdklass"
&framename = "kdklass"
&frameparm = " "
&where     = " kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon and (kdlonkl.bank = s-ourbank or s-ourbank = 'TXB00') "
&predisplay = " find first kdklass where kdklass.kod = kdlonkl.kod no-lock no-error. "
&addcon    = "false"
&deletecon = "false"
&postcreate = " "

&postupdate   = " 
                  find first kdklass where kdklass.kod = kdlonkl.kod no-lock no-error.
                  run value(kdklass.proc) in hanket (kdklass.kod,'kd-mngr').
                  display kdklass.name kdlonkl.val1 kdlonkl.valdesc kdlonkl.rating with frame kdklass. "
                 
&prechoose = " hide message. message 'F4 - выход, P - печать'."

&postdisplay = " "

&display   = " kdklass.name kdlonkl.val1 kdlonkl.valdesc kdlonkl.rating "
&update    = " kdlonkl.val1 "
&highlight = " kdlonkl.val1 "

&end = " hide message no-pause. "
}



for each kdlonkl where kdlonkl.kdcif = s-kdcif 
                     and kdlonkl.kdlon = s-kdlon and (kdlonkl.bank = s-ourbank or s-ourbank = "TXB00") no-lock.
   v-rat = v-rat + kdlonkl.rating.
end.
find current kdlon exclusive-lock no-error.
if v-rat <= 1 then kdlon.lonstat  = '01'.
if v-rat > 1 and  v-rat <= 2 then  kdlon.lonstat = '02'.
if v-rat > 2 and  v-rat <= 3 then  kdlon.lonstat = '04'.
if v-rat > 3 and  v-rat <= 4 then  kdlon.lonstat = '06'.
if v-rat > 4 then kdlon.lonstat  = '07'.
find current kdlon no-lock no-error.



/*on help of kdlon.lonstat in frame kdlon do: 
  run uni_book ("kdstat", "*", output v-cod).  
  kdlon.lonstat = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
    if avail bookcod then v-statdescr = bookcod.name. 
    displ kdlon.lonstat v-statdescr with frame kdlon.
end.

update kdlon.lonstat
       with frame kdlon.
  */




