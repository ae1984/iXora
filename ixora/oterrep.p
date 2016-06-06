/* oterrep.p
 * MODULE
        Прочие платежи организаций
 * DESCRIPTION
        Отчет по зачисленным на АРП счета или отправленным прочим платежам кассиров 
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
        23/04/2004 kanat
 * CHANGES
        11/10/2004 kanat - поменял переменные вывода лицевых счетов
*/

{global.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
def var v-operation as char.
def var selgrp as integer init 9.
def var v-rep-message as char.

ourbank = comm-txb().
ourcode = comm-cod().

define temp-table otercommpl like commonpl
    field rid as rowid.

def var v-date-1 as date.
def var v-date-2 as date.

v-date-1 = g-today.
v-date-2 = g-today.

update v-date-1 label "Введите период или дату с " v-date-2 label " по " with centered side-label frame fdat.
hide frame fdat.


if v-date-1 > v-date-2 then do:
message "Пользователем задан неверный диапазон дат" view-as alert-box title "Внимание".
return.
end.

   run sel ("Выберите тип отчета", "1. Зачисленные на АРП   |" +
                                   "2. Отправленные платежи |" + 
                                   "3. Выход ").

       case return-value:
          when "1" then v-operation = "1".
          when "2" then v-operation = "2".
          when "3" then v-operation = "3".
       end.

  if v-operation = "1" then do:
for each commonpl where commonpl.txb = ourcode and 
                        commonpl.date >= v-date-1 and 
                        commonpl.date <= v-date-2 and 
                        commonpl.joudoc <> ? and 
                        commonpl.rmzdoc = ? and
                        commonpl.deluid = ? and 
                        commonpl.grp = selgrp no-lock:
    create otercommpl.
    buffer-copy commonpl to otercommpl.
    otercommpl.rid = rowid(commonpl).
end.
v-rep-message = "зачисленных".
  end.



  if v-operation = "2" then do:
for each commonpl where commonpl.txb = ourcode and 
                        commonpl.date >= v-date-1 and 
                        commonpl.date <= v-date-2 and 
                        commonpl.joudoc <> ? and 
                        commonpl.rmzdoc <> ? and
                        commonpl.deluid = ? and 
                        commonpl.grp = selgrp no-lock:
    create otercommpl.
    buffer-copy commonpl to otercommpl.
    otercommpl.rid = rowid(commonpl).
end.
v-rep-message = "отправленных".
  end.

  if v-operation = "3" then
  return. 


output to svodrep.txt. 

find first otercommpl no-lock no-error.
if avail otercommpl then do:

put unformatted "АО TEXAKABANK" skip(1).
put unformatted "Дата: " string(g-today) skip.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then 
put unformatted "Исполнитель: " g-ofc " (" ofc.name ")" skip(3).
else 
return.

        put unformatted "                                      РЕЕСТР " skip.
        put unformatted "                            " v-rep-message " прочих платежей " skip.

if v-date-1 = v-date-2 then
        put unformatted "                                  за " v-date-1 skip(2).

if v-date-1 < v-date-2 then
        put unformatted "                                c " string(v-date-1) " по " string(v-date-2) skip(2).
end.
else do:
put unformatted "                    Извините" skip.
put unformatted "Информации по прочим платежам за указанный период " skip.
put unformatted "         в системе не обнаружено." skip.
end.

        for each otercommpl no-lock.
        put unformatted "Дата внесения квитанции в систему: " otercommpl.date skip.

        if v-operation = "1" then 
        put unformatted "Номер документа зачисления на АРП: " otercommpl.joudoc skip.

        if v-operation = "2" then do:
        put unformatted "Номер документа зачисления на АРП: " otercommpl.joudoc skip.
        put unformatted "Номер документа отправки платежа: " otercommpl.rmzdoc skip.
        end.

        find first ofc where ofc.ofc = otercommpl.uid no-lock no-error.
        if avail ofc then 
        put unformatted "Кассир: " otercommpl.uid " (" ofc.name ")" skip.

        put unformatted "Квитанция: " otercommpl.dnum skip 
                        "ПЛАТЕЛЬЩИК. РНН: [" otercommpl.rnn "]. " otercommpl.fioadr skip 
                        "ПОЛУЧАТЕЛЬ. РНН: [" otercommpl.rnnbn "]. " otercommpl.info[4] skip 
                        "Счет: [" otercommpl.info[2] "]" skip
                        "БИК: [" otercommpl.info[3] "]" skip
                        "Лицевой счет: [" otercommpl.diskont "]" skip
                        "Назначение: [" otercommpl.npl "]" skip
                        "Сумма: [" otercommpl.sum "]" skip
                        "КОД: [" otercommpl.chval[1] "]" skip
                        "КБЕ: [" otercommpl.chval[2] "]" skip
                        "КНП: [" otercommpl.chval[3] "]" skip
                        "КБК: [" otercommpl.kb "]" skip.        
        put unformatted fill("-",20) format "x(20)" skip.
        end.

output close.
        run menu-prt ("svodrep.txt").
