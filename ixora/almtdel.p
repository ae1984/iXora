/* almtdel.p
 * MODULE
        Алма ТВ. Очистка реестра суммы по АлмаТВ
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
       5.2.7.4 
 * AUTHOR
        14.04.2006. u00600
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

find first almatv where almatv.txb    = seltxb and
                        almatv.uid    = d-ofc and
                        almatv.dtfk   = d-date and 
                        almatv.deluid = ?
                        no-lock no-error.

if not avail almatv then do:
   message "Незачисленных платежей нет~nНе могу удалить пустой реестр" view-as alert-box title "".
   hide all. pause 0.
   return.
end.

for each almatv where almatv.txb    = seltxb and
                      almatv.uid    = d-ofc and
                      almatv.dtfk   = d-date and 
                      almatv.deluid = ? no-lock:
       cnt = cnt + 1.
       ACCUMULATE almatv.summfk (total).
end.

    MESSAGE "Удалить реестр в количестве " cnt " платежей на сумму " accum total almatv.summfk " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи АлмаТВ" UPDATE choice3 as logical.

    if choice3 = false then return.

run savelog ("pflog", "-").
run savelog ("pflog", "УДАЛЕНИЕ ПЛАТЕЖЕЙ АЛМА ТВ").
run savelog ("pflog", "     Кассир: " + d-ofc).
run savelog ("pflog", "       Дата: " + STRING(d-date)).
cnt = 0.

do transaction:

   for each almatv where almatv.txb = seltxb and
                         almatv.uid = d-ofc and
                         almatv.dtfk = d-date and
                         almatv.deluid = ? :
       assign almatv.deluid  = g-ofc
              almatv.deldate = g-today
              almatv.deltime = time
              almatv.delwhy  = "Удаление ошибочно загруженного реестра"
              NO-ERROR.
       cnt = cnt + 1.
   end.

end.

run savelog ("pflog", "      Всего: " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей").
run savelog ("pflog", "-").

message "Реестр удален~nВсего - " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей" view-as alert-box title "".
