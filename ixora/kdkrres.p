/* kdkrres.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Ввод занных в досье - решение кред комитета и внесение одобренных параметров кредита
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6 Решение 
 * AUTHOR
        17.03.2004 marinav
 * CHANGES
        30/04/2004 madiyar - Просмотр досье филиалов в ГБ.
                             сохранение условий, одобренных к/к филиала в kdaffil, код 50
                             Решение к/к - отдельные справочники для ГБ и филиалов
        18/05/2004 madiyar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
                             Заключение к/к возможно только при наличии юридического заключения.
        20/05/2004 madiyar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
        15/06/2004 madiyar - В Атырау нет юридического департамента - для этого филиала убрал проверку на наличие юр. заключения
        05/09/06   marinav - добавление индексов
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/


{global.i}
{kd.i}
{kdkrkom.f}

/*s-kdlon = 'KD11'.
*/
def var v-cod as char.
def var kdaffilcod as char.

if s-kdlon = '' then return.

find kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.sts = "09" then do:
  message skip " Кредит уже выдан ! Изменение досье невозможно !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

def var pass as logi init false.

case kdlon.resume:
  when "01" then if s-ourbank = kdlon.bank then pass = true.
  when "02" then if s-ourbank <> kdlon.bank then pass = true.
end case.

if not pass then return.

/* для выноса на к/к необходимо наличие юридического заключения */
pass = false.
find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '23' no-lock no-error.
if avail kdaffil then if kdaffil.whn <> ? then pass = true.
if not pass /*and s-ourbank <> "TXB03"*/ then do:
  message skip " Нет юридического заключения! " skip(1) view-as alert-box buttons ok.
  return.
end.


form kdlon.repay VIEW-AS EDITOR SIZE 40 by 3 
 with frame y  overlay  row 14  centered top-only no-label.

 {kdkrvew.i}

on help of kdlon.resume in frame kdkrkom do: 
  if s-ourbank = kdlon.bank then run uni_book ("kdresum", "*", output v-cod).
  else run uni_book ("kdresgo", "*", output v-cod).  
  kdlon.resume = entry(1, v-cod).
  find bookcod where (bookcod.bookcod = "kdresum" or bookcod.bookcod = "kdresgo" or bookcod.bookcod = "kdmres" or bookcod.bookcod = "kdmresgo") and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name. 
   displ kdlon.resume v-resdescr with frame kdkrkom.
end.

on help of kdlon.type_ln in frame kdkrkom do: 
  v-cod = kdlon.type_ln.
  run uni_book ("kdfintyp", "*", output v-cod).  
  kdlon.type_ln = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-insdescr1 = bookcod.name. 
    displ kdlon.type_ln v-insdescr1 with frame kdkrkom.
end.

on help of kdlon.goal in frame kdkrkom do:
   run h-codfr ("lntgt", output v-cod).
   kdlon.goal = v-cod.
   displ kdlon.goal with frame kdkrkom.
end.

run uni_book ('kdkrkom', '*', output v-cod).
if keyfunction(lastkey) eq "end-error" then return.

if s-ourbank = kdlon.bank then kdaffilcod = '32'.
else kdaffilcod = '42'.

v-krkom = entry(1, v-cod).
find first kdaffil where /*kdaffil.bank = s-ourbank and*/  
                   kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod no-lock no-error.
if avail kdaffil then do:
  find current kdaffil exclusive-lock no-error.
  kdaffil.name = v-krkom.
  find current kdaffil no-lock no-error.
end.
find first bookcod where bookcod.bookcod = 'kdkrkom' and bookcod.code = v-krkom no-lock no-error.
if avail bookcod then v-krkom = bookcod.name.
displ v-krkom with frame kdkrkom.

find current kdlon exclusive-lock no-error.
update kdlon.resume with frame kdkrkom.
displ kdlon.resume v-resdescr with frame kdkrkom.

kdlon.sts = kdlon.resume.
find current kdlon no-lock no-error.

if kdlon.resume = '02' or kdlon.resume = '03' or kdlon.resume = '11' or kdlon.resume = '13' then do:
  find current kdlon exclusive-lock no-error.
  assign kdlon.whosecr = g-ofc kdlon.whnsecr = g-today.
  pause 0.
  update kdlon.datkk with frame kdkrkom.
  find current kdlon no-lock no-error.
  displ kdlon.datkk with frame kdkrkom.
  hide message.

/* посчитать и запомнить порядковый номер вопроса*/
  if kdlon.datkk ne ? then do:
     find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = kdaffilcod
                          and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
     if avail kdaffil and kdaffil.dat = kdlon.datkk then v-num = kdaffil.uno.

     if avail kdaffil and kdaffil.dat ne kdlon.datkk then do:
        define buffer b-kdaffil for kdaffil.
        find first b-kdaffil where b-kdaffil.bank = s-ourbank and b-kdaffil.dat = kdlon.datkk no-lock no-error. 
        if avail b-kdaffil then do:
           for each b-kdaffil where b-kdaffil.bank = s-ourbank and b-kdaffil.dat = kdlon.datkk no-lock.
             accum b-kdaffil.uno (max).
           end.
           v-num = accum max b-kdaffil.uno.
        end.
        else  v-num = 0.
        v-num = v-num + 1.
        find current kdaffil exclusive-lock no-error.
        kdaffil.dat = kdlon.dat.
        kdaffil.uno = v-num.
        find current kdaffil no-lock no-error.
     end.
     displ v-num with frame kdkrkom.
     update v-num with frame kdkrkom.
     find current kdaffil exclusive-lock no-error.
     kdaffil.uno = v-num.
     find current kdaffil no-lock no-error.
  end.
end.


if kdlon.resume begins '1' or kdlon.resume = '01' then return.

find current kdlon exclusive-lock no-error.
update kdlon.type_ln kdlon.amount kdlon.crc kdlon.rate 
       kdlon.srok kdlon.goal  with frame kdkrkom.
update kdlon.repay with frame y scrollable.
hide frame y no-pause. 
update kdlon.repay% kdlon.rescha[1] with frame kdkrkom.
find current kdlon no-lock no-error.

/* сохранить условия, одобренные к/к филиала в kdaffil, код 50 */

if s-ourbank = kdlon.bank and kdlon.resume = '02' then do:

    find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '50' no-lock no-error.
    if not avail kdaffil then do:
       create kdaffil.
       kdaffil.code = '50'. kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon.
       find current kdaffil no-lock no-error.
    end.
    find current kdaffil exclusive-lock no-error.
    kdaffil.bank = s-ourbank. kdaffil.dat = g-today. kdaffil.who = g-ofc. kdaffil.whn = g-today.
    kdaffil.info[1] = ''.
    kdaffil.info[1] = string(kdlon.type_ln) + ',' + string(kdlon.amount) + ',' + string(kdlon.crc)    
                     + ',' + string(kdlon.rate) + ',' + string(kdlon.srok) + ',' + kdlon.goal 
                     + ',' + kdlon.repay + ',' + kdlon.repay% + ',' + kdlon.rescha[1].
    find current kdaffil no-lock no-error.

end.

def var kdval like kdlonkl.val1.

if lookup(kdlon.resume, "01,02,03") > 0 then do:
   /*если выносится на КК, то пересчитать классификацию по предлагаемым условиям*/
   /*качество обеспечения*/
   define var v-sec3 as deci .  /*стоимость обеспечения по 3 группе - деньги*/
   define var v-sec  as deci.  /* стоимость остального обеспечения*/
   define buffer b-crc for crc.
   define var bilance as deci.
   define var v-rat as deci init 0.
   bilance = kdlon.amount * (kdlon.rate * kdlon.srok / 1200 + 1).

   find kdlonkl where /*kdlonkl.bank = s-ourbank and*/ kdlonkl.kdcif = s-kdcif 
               and kdlonkl.kdlon = s-kdlon and kdlonkl.kod = 'obesp' no-lock no-error.
   if avail kdlonkl then do: 
        find first crc where crc.crc = kdlon.crc no-lock no-error.
        v-sec = 0.
        v-sec3 = 0.
        for each kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock.
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
   for each kdlonkl where /*kdlonkl.bank = s-ourbank and*/ kdlonkl.kdcif = s-kdcif 
                        and kdlonkl.kdlon = s-kdlon no-lock.
      v-rat = v-rat + kdlonkl.rating.
   end.
   find current kdlon exclusive-lock no-error.
   if v-rat <= 1 then kdlon.lonstat  = '01'.
   if v-rat > 1 and  v-rat <= 2 then  kdlon.lonstat = '02'.
   if v-rat > 2 and  v-rat <= 3 then  kdlon.lonstat = '04'.
   if v-rat > 3 and  v-rat <= 4 then  kdlon.lonstat = '06'.
   if v-rat > 4 then kdlon.lonstat  = '07'.
   find current kdlon no-lock no-error.

end.   
   
