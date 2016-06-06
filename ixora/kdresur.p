/* kdresur.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Резюме юридического департамента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-5 РезюмеЮ
 * AUTHOR
        15.01.04 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        17/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdcif = '' then return.

find kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


def var v-cod as char.
def var v-descr as char format "x(30)".
define var v-info as char.

define frame fr skip(1)
       kdaffil.info[1]  label "Резюме  " VIEW-AS EDITOR SIZE 50 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "РЕЗЮМЕ ЮРИДИЧЕСКОГО ДЕПАРТАМЕНТА " .

define variable s_rowid as rowid.

  find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '23' and (kdaffil.bank = s-ourbank or s-ourbank = "TXB00")no-lock no-error.
  if not avail kdaffil then do:
     if s-ourbank = kdcif.bank then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '23'.  
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
        find current kdaffil no-lock no-error.
     end.
     else do:
        message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
        return.
     end.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.

  displ kdaffil.info[1] kdaffil.who kdaffil.whn with frame fr.
  if s-ourbank = kdcif.bank then do:
    find current kdaffil exclusive-lock no-error.
    update kdaffil.info[1] with frame fr.
    kdaffil.who = g-ofc. kdaffil.whn = g-today.
    find current kdaffil no-lock no-error.
  end.

hide message.


            

