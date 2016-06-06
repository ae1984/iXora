/* pagenuml.i
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
   put fill ("-",40) format "x(40)" at 35  + margin.
   /*
   run pskip(0).
 if intermbal < 0 then do:
   put "Промежуточный баланс" at 11 + margin  absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 40 + margin.
 end.
 else do:                  
   put "Промежуточный баланс" at 11 + margin intermbal format "z,zzz,zzz,zzz,zz9.99" at 55 + margin.
 end.
 */
end.
 
run pskip(0).

frmt = "x(" + string(cols) + ")".
put fill (".",cols) at 1 + margin  format frmt. 

/* === FormFeed Service Code === */

if formfeed = yes then  put unformatted chr(12). else run pskip(1).

row_in_page = 0.

if new_acc = no then do:
  run pskip(0).

  if acc_list.stmsts = "INF" then put "Справка  N " at 35 + margin. 
  if acc_list.stmsts = "CPY" then put "Дубликат N " at 35 + margin.
  if acc_list.stmsts = "ORG" then put "Выписка N " at 35 + margin.

  put trim(string(acc_list.seq,"zzz9999")) at 50 + margin.
  put string(page_num,"zzz9") + ". стр." format "x(10)" to 70 + margin.
  run pskip(0).
end.
