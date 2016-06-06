/* obmdel.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Удаление реестра платежей по обменным операциям по кассиру за дату
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.2.7.5
 * AUTHOR
        09.08.06 marinav
 * CHANGES
        14/08/06 marinav  - добавила удаление подотчета grp = 11
*/

{yes-no.i}
{comm-txb.i}

def shared var g-ofc as char.
def shared var g-today as date.

def var d-ofc like g-ofc NO-UNDO.
def var d-date as date NO-UNDO.
def var seltxb as int NO-UNDO.
def var cnt as int NO-UNDO.
def var ssum as deci NO-UNDO.

seltxb = comm-cod().
d-date = g-today.

update skip d-ofc  label "Введите логин кассира" SKIP
       d-date label "Введите дату платежей" 
       with side-labels centered frame getofc
       title "УДАЛЕНИЕ ПЛАТЕЖЕЙ ИЗ РЕЕСТРА ПО ОБМЕННЫМ ОПЕРАЦИЙ". 

hide frame getofc.


for each commonpl where commonpl.txb = seltxb and
                          commonpl.date = d-date and 
                          commonpl.uid = d-ofc and
                          (commonpl.grp = 0 or commonpl.grp = 11) and 
                          commonpl.deluid = ?
                          no-lock .
    ssum = ssum + commonpl.sum .
    cnt = cnt + 1.
end.

if cnt = 0 then do:
   message "Платежей нет~nНе могу удалить пустой реестр" view-as alert-box title "".
   hide all. pause 0.
   return.
end.

if yes-no ("", "Удалить реестр : " + string(cnt) + " платежей на сумму " + string(ssum) + " ?")
   then do:

          run savelog ("stadlog", "-").
          run savelog ("stadlog", "УДАЛЕНИЕ ПЛАТЕЖЕЙ СТАНЦИИ ДИАГНОСТИКИ И КОММУНАЛЬНЫХ ПЛАТЕЖЕЙ").
          run savelog ("stadlog", "     Кассир: " + d-ofc).
          run savelog ("stadlog", "       Дата: " + STRING(d-date)).

          cnt = 0.

          do transaction:

             for each commonpl where commonpl.txb = seltxb and
                                     commonpl.date = d-date and
                                     commonpl.uid = d-ofc and
                                     (commonpl.grp = 0 or commonpl.grp = 11) and
                                     commonpl.deluid = ?  :

                 assign commonpl.deluid = g-ofc
                        commonpl.deldate = g-today
                        commonpl.deltime = time
                        commonpl.delwhy = "Удаление ошибочно загруженного реестра"
                        NO-ERROR.
                 cnt = cnt + 1.
              
             end.

          end.

          run savelog ("stadlog", "      Всего: " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей").
          run savelog ("stadlog", "-").

          message "Реестр удален~nВсего - " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей" view-as alert-box title "".

end.