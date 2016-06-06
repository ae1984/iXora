/* kdresur.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Резюме юридического департамента ГО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-5 РезЮ ГБ 
 * AUTHOR
        30/04/2004 madiar
 * CHANGES
        17/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
/* {pksysc.f} */
{sysc.i}

def var sumkr_usd as deci. /* сумма кредита в долларах по курсу на день регистрации досье в филиале */
def var mail_list as char init "".
def var ii as int.

if s-kdcif = '' then return.
if s-ourbank <> "TXB00" then return.

find kdcif where kdcif.kdcif = s-kdcif no-lock no-error.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon no-lock no-error.
if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.bank = s-ourbank then return.

if kdlon.sts <> '30' then return.

def var v-cod as char.
def var v-descr as char format "x(30)".
define var v-info as char.

define frame fr skip(1)
       kdaffil.info[1]  label "Резюме  " VIEW-AS EDITOR SIZE 50 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "РЕЗЮМЕ ЮРИДИЧЕСКОГО ДЕПАРТАМЕНТА ГБ" .

define variable s_rowid as rowid.

  find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '60'  no-lock no-error.
  if not avail kdaffil then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '60'.  
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
        find current kdaffil no-lock no-error.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.

  displ kdaffil.info[1] kdaffil.who kdaffil.whn with frame fr.
  find current kdaffil exclusive-lock no-error.
  update kdaffil.info[1] with frame fr.
  kdaffil.who = g-ofc. kdaffil.whn = g-today.
  find current kdaffil no-lock no-error.
  
  /* Изменение статуса */
  
  message "Изменить статус досье?" view-as alert-box question buttons yes-no title "Изменение статуса" update choice as logical.
  
  if choice then do:
    if kdlon.crc <> 2 then do:
      find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = kdlon.crc no-lock no-error.
      if avail crchis then sumkr_usd = kdlon.amount * crchis.rate[1].
      find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = 2 no-lock no-error.
      if avail crchis then sumkr_usd = sumkr_usd / crchis.rate[1].
    end.
    else sumkr_usd = kdlon.amount.
    
    find first kdkrdt where kdkrdt.sumst <= sumkr_usd and kdkrdt.sumend > sumkr_usd no-lock no-error.
    if avail kdkrdt then do:
      if kdkrdt.daysrm <> 0 then do:
           find current kdlon exclusive-lock no-error.
           kdlon.sts = "33".  /* идет на рассм к риск-менеджеру, добавить рассылку е-майлов --email-- */
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
    else message skip " Нет соотв. диапазона в таблице временного контроля ~n прохождения заявок филиалов " skip(1) view-as alert-box buttons ok title " Ошибка! ".
  end. /* if choice */

hide message.


            

