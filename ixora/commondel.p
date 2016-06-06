/* commondel.p
 * MODULE
        Коммунальные платежи
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
        3.2.10.14.1
 * AUTHOR
        12.03.2003 sasco
 * CHANGES
        18.03.2003 sasco теперь удаляется реестр не только ст. диагностики, но весь commonpl
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
find first commonpl where commonpl.txb = seltxb and
                          commonpl.uid = d-ofc and
                          commonpl.date = d-date and
                          (commonpl.joudoc <> ? or 
                           commonpl.comdoc <> ? or
                           commonpl.rmzdoc <> ?)
                           no-lock no-error.

if avail commonpl then do:
   message "Не могу удалить реестр кассира~nЕсть зачисленные платежи" view-as alert-box title "".
   hide all. pause 0.
   return.
end.
*/

find first commonpl where commonpl.txb = seltxb and
                          commonpl.uid = d-ofc and
                          commonpl.date = d-date and 
                          commonpl.deluid = ?
                          no-lock no-error.

if not avail commonpl then do:
   message "Платежей нет~nНе могу удалить пустой реестр" view-as alert-box title "".
   hide all. pause 0.
   return.
end.

run savelog ("stadlog", "-").
run savelog ("stadlog", "УДАЛЕНИЕ ПЛАТЕЖЕЙ СТАНЦИИ ДИАГНОСТИКИ И КОММУНАЛЬНЫХ ПЛАТЕЖЕЙ").
run savelog ("stadlog", "     Кассир: " + d-ofc).
run savelog ("stadlog", "       Дата: " + STRING(d-date)).
cnt = 0.

do transaction:

   for each commonpl where commonpl.txb = seltxb and
                           commonpl.uid = d-ofc and
                           commonpl.date = d-date and
                           commonpl.joudoc = ? /* and
                           commonpl.deluid = ? */ :
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

