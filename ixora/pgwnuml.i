/* pgwnuml.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/


row_in_page = 0.

if new_acc = no and balance_mode = no then do:
   put fill ("-",40) format "x(40)" to 120 + margin.
   /*
   run pwskip(0).
 if intermbal < 0 then do:
   put "Промежуточный баланс" at 11 + margin absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
 end.
 else do:                  
   put "Промежуточный баланс" at 11 + margin intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
 end.
 */
end.
 run pwskip(0).


frmt = "x(" + string(cols) + ")".
put fill (".",cols) at 1 + margin format frmt. 

/* === FormFeed Service Code === */

if formfeed = yes then  put unformatted chr(12). else run pwskip(1).

/* ============================ NEW PAGE ========================================= */

row_in_page = 0.                  /* --- Resetting --- */

if new_acc = no then do:
  run pwskip(0).

  if acc_list.stmsts = "INF" then put "Справка N "    at 80 + margin. 
  if acc_list.stmsts = "CPY" then put "Дубликат N " at 80 + margin.
  if acc_list.stmsts = "ORG" then put "Выписка N "  at 80 + margin.

  put trim(string(acc_list.seq,"zzz9999")) at 95 + margin.
  put string(page_num,"zzz9") + ". стр." format "x(10)" to 119 + margin.
  run pwskip(0).
end.
