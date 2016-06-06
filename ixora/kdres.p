/* kdsysc.p Электронное кредитное досье

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
        4-11-3 Решение 
 * AUTHOR
        24.07.03 marinav
 * CHANGES
        01.12.2003 marinav - предлагаемые и одобренные условия
        30/04/2004 madiar - Просмотр и редактирование досье филиалов в ГБ
                            Решение - отдельные справочники для ГБ и филиалов
        18/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных.
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{kdlon.f}
{sysc.i}

def var sumkr_usd as deci. /* сумма кредита в долларах по курсу на день регистрации досье в филиале */

/*s-kdlon = 'KD11'.
*/
def var v-cod as char.

if s-kdlon = '' then return.


find kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

/* if s-ourbank <> kdlon.bank then return. */

if kdlon.sts > "01" and kdlon.bank = s-ourbank then do:
  message skip " Решение по кредиту уже вынесено!~n Изменение досье невозможно !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

if kdlon.bank <> s-ourbank and kdlon.sts <> '25' then return.

form kdlon.repay VIEW-AS EDITOR SIZE 40 by 3 
 with frame y  overlay  row 14  centered top-only no-label.

 {kdlonvew.i}

on help of kdlon.resume in frame kdlon do: 
  if s-ourbank = kdlon.bank then run uni_book ("kdmres", "*", output v-cod).
  else run uni_book ("kdmresgo", "*", output v-cod).
  kdlon.resume = entry(1, v-cod).
  find bookcod where (bookcod.bookcod = "kdresum" or bookcod.bookcod = "kdresgo" or bookcod.bookcod = "kdmres" or bookcod.bookcod = "kdmresgo") and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name. 
   displ kdlon.resume v-resdescr with frame kdlon.
end.

on help of kdlon.type_ln in frame kdlon do: 
  v-cod = kdlon.type_ln.
  run uni_book ("kdfintyp", "*", output v-cod).  
  kdlon.type_ln = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-insdescr1 = bookcod.name. 
    displ kdlon.type_ln v-insdescr1 with frame kdlon.
end.

on help of kdlon.goal in frame kdlon do:
   run h-codfr ("lntgt", output v-cod).
   kdlon.goal = v-cod.
   displ kdlon.goal with frame kdlon.
end.


find current kdlon exclusive-lock no-error.
update kdlon.resume with frame kdlon.
find current kdlon no-lock no-error.

displ kdlon.resume v-resdescr with frame kdlon.

if kdlon.sts <> '25' or (kdlon.sts = '25' and kdlon.resume = '14') then kdlon.sts = kdlon.resume.

/*если выносится на кред ком, то написать основание*/
if kdlon.resume = '01' then do:
  define frame fr skip(1)
         kdaffil.dat      label "Дата      " skip 
         kdaffil.info[1]  label "Резюме    " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
         kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
         with overlay width 80 side-labels column 3 row 3 
         title "Резюме при выносе на Кредитный комитет " .
  find first kdaffil where /*kdaffil.bank = s-ourbank and*/ kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '21' no-lock no-error.
  if not avail kdaffil then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '21'. kdaffil.dat = g-today.  
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
        find current kdaffil no-lock no-error.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
  pause 0.
  find current kdaffil exclusive-lock no-error.
  update kdaffil.dat kdaffil.info[1] with frame fr.
  kdaffil.who = g-ofc. kdaffil.whn = g-today.
  find current kdaffil no-lock no-error.
  hide message.
end.

/*если заключение менеджера КД ГБ, то написать рекомендации*/
if kdlon.sts = '25' then do:
  define frame fr1 skip(1)
         kdaffil.info[1]  label "Рекомендации " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
         kdaffil.whn      label "ПРОВЕДЕНО    " kdaffil.who  no-label skip(1)
         with overlay width 80 side-labels column 3 row 3 
         title "Рекомендации менеджера КД ГБ " .
  find first kdaffil where /*kdaffil.bank = s-ourbank and*/ kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '61' no-lock no-error.
  if not avail kdaffil then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '61'.
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
        find current kdaffil no-lock no-error.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
  pause 0.
  find current kdaffil exclusive-lock no-error.
  update kdaffil.info[1] with frame fr1.
  kdaffil.who = g-ofc. kdaffil.whn = g-today.
  find current kdaffil no-lock no-error.
  hide message.
end.

/* в случае отказа менеджера КД - сохранить дату отказа, в противном случае - изменение условий кредита */
find current kdlon exclusive-lock no-error.
if kdlon.resume = '12' or kdlon.resume = '14' then kdlon.resdat[2] = g-today.
else do:
  update kdlon.type_ln kdlon.amount kdlon.crc kdlon.rate 
         kdlon.srok kdlon.goal  with frame kdlon.
  update kdlon.repay with frame y scrollable.
  hide frame y no-pause. 
  update kdlon.repay% with frame kdlon.
end.
find current kdlon no-lock no-error.



if lookup(kdlon.resume, "01,02,03") > 0 then do:
   /*если выносится на КК, то пересчитать классификацию по предлагаемым условиям*/
   /*качество обеспечения*/
   define var v-sec3 as deci .  /*стоимость обеспечения по 3 группе - деньги*/
   define var v-sec  as deci.  /* стоимость остального обеспечения*/
   define buffer b-crc for crc.
   define var bilance as deci.
   define var v-rat as deci init 0.
   define var kdval like kdlonkl.val1.
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
   for each kdlonkl where /*kdlonkl.bank = s-ourbank and*/ kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon no-lock.
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
   

/* Если менеджер КД ГБ одобрил, то изменение статуса и рассылка уведомлений */

def var ii as int.
def var mail_list as char.

if kdlon.sts = '25' and kdlon.resume <> '14' then do:
  
  if kdlon.crc <> 2 then do:
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = kdlon.crc no-lock no-error.
    if avail crchis then sumkr_usd = kdlon.amount * crchis.rate[1].
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = 2 no-lock no-error.
    if avail crchis then sumkr_usd = sumkr_usd / crchis.rate[1].
  end.
  else sumkr_usd = kdlon.amount.
  
  find first kdkrdt where kdkrdt.sumst <= sumkr_usd and kdkrdt.sumend > sumkr_usd no-lock no-error.
  if avail kdkrdt then do:
    if kdkrdt.daysud <> 0 then do:
         find current kdlon exclusive-lock no-error.
         kdlon.sts = "30".  /* идет на рассм в Юр. деп-т ГБ, добавить рассылку е-майлов --email-- */
         find current kdlon no-lock no-error.
         
         mail_list = get-sysc-cha ("kdmud").
         if mail_list <> "" then do:
           do ii = 1 to num-entries(mail_list):
             run mail(entry(ii,mail_list) + "@elexnet.kz", userid("bank") + "@elexnet.kz",
                      "Кредитное досье от " + userid("bank") + " (" + string(time,"HH:MM:SS") + " " + 
                      string(day(today),'99.') + string(month(today),'99.') + string(year(today),'9999') + ")",
                      "Клиент - " + s-kdcif + "   Кредитное досье - " + s-kdlon, "", "", "").
           end.
         end.
         
    end.
    else do:
         if kdkrdt.daysrm <> 0 then do:
              find current kdlon exclusive-lock no-error.
              kdlon.sts = "33".  /* идет на рассм к риск-менеджеру ГБ, добавить рассылку е-майлов --email-- */
              find current kdlon no-lock no-error.
              
              mail_list = get-sysc-cha ("kdmrm").
              if mail_list <> "" then do:
                do ii = 1 to num-entries(mail_list):
                  run mail(entry(ii,mail_list) + "@elexnet.kz", userid("bank") + "@elexnet.kz",
                         "Кредитное досье от " + userid("bank") + " (" + string(time,"HH:MM:SS") + " " + 
                         string(day(today),'99.') + string(month(today),'99.') + string(year(today),'9999') + ")",
                         "Клиент - " + s-kdcif + "   Кредитное досье - " + s-kdlon, "", "", "").
                end.
              end.
         
         end.
         else do:
              find current kdlon exclusive-lock no-error.
              kdlon.sts = "36".  /* идет на к/к ГБ, добавить рассылку е-майлов --email-- */
              find current kdlon no-lock no-error.
              
              mail_list = get-sysc-cha ("kdmkk").
              if mail_list <> "" then do:
                do ii = 1 to num-entries(mail_list):
                  run mail(entry(ii,mail_list) + "@elexnet.kz", userid("bank") + "@elexnet.kz",
                         "Кредитное досье от " + userid("bank") + " (" + string(time,"HH:MM:SS") + " " + 
                         string(day(today),'99.') + string(month(today),'99.') + string(year(today),'9999') + ")",
                         "Клиент - " + s-kdcif + "   Кредитное досье - " + s-kdlon, "", "", "").
                end.
              end.
              
         end.
    end.
  end.
  else message skip " Нет соотв. диапазона в таблице временного контроля ~n прохождения заявок филиалов " skip(1) view-as alert-box buttons ok title " Ошибка! ".

end.