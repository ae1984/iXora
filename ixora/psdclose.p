/* psdclose.p
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

 {global.i }
 {lgps.i } 
 {ps-prmt.i}      
 def buffer b-bal for nbal .
 def var delta like nbal.plus .
 find first dproc no-lock no-error .
 if avail dproc then
 do:
  Message " Сначала остановите процессы платежной системы !  " .
  bell . bell .
  pause .
  return .
 end.

find sysc where sysc.sysc = "ps-cls" no-lock no-error .
if not avail sysc or string(sysc.daval) = ? then do:
 message " Нет записи PS-CLS в sysc файле !". bell. bell. pause .   
 return .
end.
find last cls .    
if ( cls.cls eq sysc.daval) then do:
   display " Закрытие дня за  : " + string(sysc.daval) + " уже было выполнено     ... " format "x(78)"
   with centered row 10  frame warn .
   bell. bell. pause.
   hide frame warn.
   return.
end.

display " Идет закрытие дня     ... Ж д и т е ... " skip(0) with centered row 10 frame dw.
pause 0 .

do transaction :
 display " Обработка дней валютирования    ... " skip(0) with frame dw .
 pause 0 .

for each que where que.pid = "V1" and que.con = "W" use-index fprc exclusive-lock .
  find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
  if que.pid = "v1" and remtrz.valdt1 <= g-today then do:
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.rcod = "0".
    v-text = que.pid + " состояние обработано программой закрытия дня " + que.remtrz .
    run lgps.
    release que.
   end .
end.

for each que where que.pid = "V2" 
  and que.con = "W" use-index fprc exclusive-lock .
  find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
  if que.pid = "v2" and remtrz.valdt2 <= g-today then do:
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.rcod = "0".
    v-text = que.pid + " состояние обработано программой закрытия дня " + que.remtrz .
    run lgps.
    release que.
   end .
end.

/* KOVAL */
for each que where que.pid = "ST2" and que.con = "W" use-index fprc exclusive-lock .
  find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
  if que.pid = "ST2" and remtrz.valdt2 <= g-today then do:
    que.dp = today.
    que.tp = time.
    que.rcod = "0".
    que.con = "F".
    v-text = que.pid + " состояние обработано программой закрытия дня " + que.remtrz .
    run lgps.
    release que.
   end .
end.
/* KOVAL */

/*SNIP payment chekoing*/
run rtn_ps .

display " Архивация ... " skip(0) with frame dw .  pause 0 .
for each  que where  que.pid = "F"  
  and que.con = "W" use-index fprc exclusive-lock .
  do:
   que.dp = today.
   que.tp = time.
   que.pid = "ARC".
   que.rcod = "0" .
   release que.
  end .
end . 
          
display " Коррекция баланса корр. счетов  ... " skip(0) with frame dw .
pause 0 .
 delta = g-today - cls.cls .

 for each nbal exclusive-lock use-index remday .
  nbal.plus = nbal.plus - delta .
 end .
 for each nbal exclusive-lock .
  if nbal.plus < 0 then
   do:
    find first b-bal where b-bal.dfb = nbal.dfb and b-bal.plus = 0
     exclusive-lock no-error .
     if not avail b-bal then do:
       create b-bal .
       b-bal.dfb = nbal.dfb .
       b-bal.plus = 0 .
     end.
     b-bal.inwbal = b-bal.inwbal + nbal.inwbal .
     b-bal.outbal = b-bal.outbal + nbal.outbal .
     delete nbal .
   end.
 end.

 find sysc where sysc.sysc = "M-DIR" exclusive-lock no-error .
 display " Удаление  " + sysc.chval + " ..." 
 format "x(60)" skip(0) with frame dw .  pause 0 .
 unix silent /bin/rm -f value ( sysc.chval + "/*") .
 pause 0 .

 display " Проверка  STS.." skip(0) with frame dw .  pause 0 .
 def var ttt as int . 
 for each sts . 
   delete sts . 
 end. 

find first que use-index fprc no-lock no-error . 
if  avail que  then do: 
ttt = time .
repeat : 
 if que.pid = "ARC" then
  do:
    find last  que where que.pid = "ARC"  use-index fprc no-lock .
    find next que  use-index fprc no-lock no-error.
    if not avail que then leave .
  end .

 find first sts where que.pid eq sts.pid exclusive-lock no-error.
 if not avail sts then do:
  create sts.
  sts.pid = que.pid .
  sts.nw = 0 .  
  sts.nf = 0.
  sts.nwt = 0 .
  sts.nft = 0 . 
 end.
if que.con = "W" then
    sts.nw = sts.nw + 1.
   else
if que.con = "F" then
   sts.nf = sts.nf + 1.

sts.nwt = sts.nwt + ttt - que.tf  +  (today - que.df) * 86400 .

 find next que  use-index fprc no-lock no-error .
 if not avail que then leave .
end.
end.
for each sts exclusive-lock . 
sts.dupd = today .
sts.upd = ttt. 
end. 
   
 find sysc where sysc.sysc = "ps-cls" exclusive-lock no-error .
 sysc.daval = cls.cls .
end.

v-text = " Процедура закрытия дня выполнена " + g-ofc . 
run lgps. 

display " Завершено ... "  with frame dw .
pause . return .
