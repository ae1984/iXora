/* pfpaydel.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Удаление реестра платежей по кассиру за дату
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        05.01.2006. u00118
 * CHANGES
*/

{yes-no.i}
{comm-txb.i}

def shared var g-ofc as char.
def shared var g-today as date.

def var d-ofc like g-ofc NO-UNDO.
def var d-date as date NO-UNDO.
def var seltxb as int NO-UNDO.
def var cnt as int NO-UNDO.

seltxb = comm-cod().
d-date = g-today.

update d-ofc  label "Введите логин кассира" SKIP
       d-date label "Введите дату платежей" 
       with side-labels centered frame getofc
       title "УДАЛЕНИЕ ПЛАТЕЖЕЙ ИЗ РЕЕСТРА". 

hide frame getofc.

find first p_f_payment where p_f_payment.txb = seltxb and
                             p_f_payment.uid = d-ofc and
                             p_f_payment.date = d-date and 
                             p_f_payment.deluid = ? and
                             p_f_payment.stgl = 0  and
                             p_f_payment.stcif = 0
                             no-lock no-error.

if not avail p_f_payment then do:
   message "Незачисленных платежей нет~nНе могу удалить пустой реестр" view-as alert-box title "".
   hide all. pause 0.
   return.
end.

   for each p_f_payment where p_f_payment.txb = seltxb and
                           p_f_payment.uid = d-ofc and
                           p_f_payment.date = d-date and
                           p_f_payment.deluid = ?  and
                           p_f_payment.stgl = 0  and
                           p_f_payment.stcif = 0 no-lock:
       cnt = cnt + 1.
       ACCUMULATE p_f_payment.amt (total).
   end.

    MESSAGE "Удалить реестр в количестве " cnt " платежей на сумму " accum total p_f_payment.amt " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Пенсионные и др. платежи" UPDATE choice3 as logical.

    if choice3 = false then return.


run savelog ("pflog", "-").
run savelog ("pflog", "УДАЛЕНИЕ ПЕНСИОННЫХ ПЛАТЕЖЕЙ ").
run savelog ("pflog", "     Кассир: " + d-ofc).
run savelog ("pflog", "       Дата: " + STRING(d-date)).
cnt = 0.

do transaction:

   for each p_f_payment where p_f_payment.txb = seltxb and
                           p_f_payment.uid = d-ofc and
                           p_f_payment.date = d-date and
                           p_f_payment.deluid = ?  and
                           p_f_payment.stgl = 0  and
                           p_f_payment.stcif = 0:
       assign p_f_payment.deluid = g-ofc
              p_f_payment.deldate = g-today
              p_f_payment.deltime = time
              p_f_payment.delwhy = "Удаление ошибочно загруженного реестра"
              NO-ERROR.
       cnt = cnt + 1.
   end.

end.

run savelog ("pflog", "      Всего: " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей").
run savelog ("pflog", "-").

message "Реестр удален~nВсего - " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей" view-as alert-box title "".

