/* taxdel.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Удаление реестров налоговых платежей
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
        12.03.2003 sasco
 * CHANGES
        01.12.2003 sasco принудительное изменение причины удаления в удаленных платежах 
        03.01.2004 kanat убрал проверку на заисленные платежи
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

/*
find first tax where tax.txb = seltxb and
                     tax.uid = d-ofc and
                     tax.date = d-date and
                     (tax.taxdoc <> ? or 
                      tax.comdoc <> ? or
                      tax.senddoc <> ?)
                      no-lock no-error.

if avail tax then do:
   message "Не могу удалить реестр кассира~nЕсть зачисленные платежи" view-as alert-box title "".
   hide all. pause 0.
   return.
end.
*/

find first tax where tax.txb = seltxb and
                     tax.uid = d-ofc and
                     tax.date = d-date and
                     tax.duid = ?
                     no-lock no-error.

if not avail tax then do:
   message "Платежей нет~nНе могу удалить пустой реестр" view-as alert-box title "".
   hide all. pause 0.
   return.
end.

run savelog ("taxlog", "-").
run savelog ("taxlog", "УДАЛЕНИЕ НАЛОГОВЫХ ПЛАТЕЖЕЙ").
run savelog ("taxlog", "     Кассир: " + d-ofc).
run savelog ("taxlog", "       Дата: " + STRING(d-date)).
cnt = 0.

do transaction:

   for each tax where tax.txb = seltxb and
                      tax.uid = d-ofc and
                      tax.date = d-date and
                      tax.taxdoc = ? /* and
                      tax.duid = ?*/ :
       assign tax.duid = g-ofc
              tax.deldate = g-today
              tax.deltime = time
              tax.delwhy = "Удаление ошибочно загруженного реестра"              
              NO-ERROR.
       cnt = cnt + 1.
   end.

end.

run savelog ("taxlog", "      Всего: " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей").
run savelog ("taxlog", "-").

message "Реестр удален~nВсего - " + TRIM(STRING(cnt, "zzzzzzzzz9")) + " платежей" view-as alert-box title "".
