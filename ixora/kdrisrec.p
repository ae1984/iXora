/* kdrisrec.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Выводы риск-менеджера
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-5 Выводы риск-менеджера
 * AUTHOR
        12.03.04 marinav
 * CHANGES
        30/04/2004 madiar - Работа с досье филиалов в ГБ.
        18/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{kdrisk.f}
{sysc.i}

/*s-kdlon = 'KD11'.
*/
def var sumkr_usd as deci. /* сумма кредита в долларах по курсу на день регистрации досье в филиале */
def var mail_list as char init "".
def var ii as int.
def var v-cod as char.

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

form r-repay VIEW-AS EDITOR SIZE 40 by 3 
 with frame y  overlay  row 14  centered top-only no-label.

 {kdrisvew.i}

on help of r-type_ln in frame kdrisk do: 
  v-cod = r-type_ln.
  run uni_book ("kdfintyp", "*", output v-cod).  
  r-type_ln = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-insdescr1 = bookcod.name. 
    displ r-type_ln v-insdescr1 with frame kdrisk.
end.

on help of r-goal in frame kdrisk do:
   run h-codfr ("lntgt", output v-cod).
   r-goal = v-cod.
   displ r-goal with frame kdrisk.
end.

update r-type_ln 
       r-amount
       v-crc
       r-rate 
       r-srok 
       r-goal with frame kdrisk.
update r-repay with frame y scrollable.
hide frame y no-pause. 
displ r-repay with frame kdrisk.
update r-repay% with frame kdrisk.

find first kdaffil where /*kdaffil.bank = s-ourbank and*/  kdaffil.kdcif = s-kdcif 
                                      and kdaffil.kdlon = s-kdlon and kdaffil.code = '31' no-lock no-error.
if avail kdaffil then do:
   find current kdaffil exclusive-lock no-error.
   kdaffil.info[1] = ''.
   kdaffil.info[1] = string(r-type_ln) + ',' + string(r-amount) + ',' + string(v-crc)    
                     + ',' + string(r-rate) + ',' + string(r-srok) + ',' + r-goal 
                     + ',' + r-repay + ',' + r-repay%.
   find current kdaffil no-lock no-error.
end.


  define frame fr skip(1)
         kdaffil.info[2]  label "Рекомендации    " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
         kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
         with overlay width 80 side-labels column 3 row 3 .

  find first kdaffil where /*kdaffil.bank = s-ourbank and*/ kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '31' no-lock no-error.
  if not avail kdaffil then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '31'. kdaffil.dat = g-today.  
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
        find current kdaffil no-lock no-error.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
  pause 0.
  displ kdaffil.info[2] kdaffil.who kdaffil.whn with frame fr.
  find current kdaffil exclusive-lock no-error.
  update kdaffil.info[2] with frame fr.
  kdaffil.who = g-ofc. kdaffil.whn = g-today.
  find current kdaffil no-lock no-error.
  hide message.
  

/* Если риск-менеджер ГБ одобрил и досье филиальское, то изменение статуса и рассылка уведомлений */

if kdlon.sts = '33' then do:
  
  if kdlon.crc <> 2 then do:
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = kdlon.crc no-lock no-error.
    if avail crchis then sumkr_usd = kdlon.amount * crchis.rate[1].
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = 2 no-lock no-error.
    if avail crchis then sumkr_usd = sumkr_usd / crchis.rate[1].
  end.
  else sumkr_usd = kdlon.amount.
  
  find first kdkrdt where kdkrdt.sumst <= sumkr_usd and kdkrdt.sumend > sumkr_usd no-lock no-error.
  if avail kdkrdt then do:
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
  else message skip " Нет соотв. диапазона в таблице временного контроля ~n прохождения заявок филиалов " skip(1) view-as alert-box buttons ok title " Ошибка! ".

end.