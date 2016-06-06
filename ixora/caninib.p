/* caninib.p
 * MODULE
        Отмена проводок внутренних Internet платежей 
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
        5-2-10 
 * AUTHOR
        15.07.2004 tsoy 
 * CHANGES
        19.07.2004 tsoy  замена rmzcan на rmzcan2
*/
{global.i}
{lgps.i "new"}

def var ibhost as char.

def var bcode like crc.code.
def var acode like crc.code.
def buffer tgl for gl.


define new shared frame remtrz.
{rmz.f}

def var  v-rmz8iall like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz.

form skip v-rmz8iall with frame rmzor  side-label row 3  centered .

find sysc where sysc.sysc = "IBHOST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do :
 v-text = " Нет IBHOST записи в sysc файле ! ".
 run lgps .
 return .
end .
ibhost = sysc.chval .

v-text = "Прямой доступ к INTERNET базе данных"  . run lgps . 
 if not connected("ib") then 
  connect value(ibhost) no-error .

if not connected("ib") 
then do:
 v-text = " INTERNET HOST не отвечает ." .  run lgps .           
 message  " INTERNET HOST не отвечает ." .
 return .
end.

def var cmd as char form "x(8)" EXTENT 3
  INIT ["Отм2Пров", "Отм1Пров", "Очередь"].

form cmd with frame slct row 20 no-box no-label overlay centered.


  update v-rmz8iall label "Платеж"
    validate (can-find (remtrz where remtrz.remtrz = v-rmz8iall and remtrz.source  = 'IBH'),
     "Платеж не найден !" ) with frame rmzor .
      find first remtrz where remtrz.remtrz = v-rmz8iall no-lock no-error.
      s-remtrz = remtrz.remtrz.
      m_pid ="ps_" .
repeat:
      disp cmd with frame slct.
      choose field cmd with frame slct.

         if frame-value  = "Отм2Пров"  then do:
            find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if remtrz.jh2 <> ? then do:
                run rmzcan2.
                hide remtrz.
                displ v-rmz8iall with frame rmzor.

            end. else do:
                message "Нельзя отменить 2 пр. т.к. ее нет !" view-as alert-box.
            end.
         end. 

         if frame-value  = "Отм1Пров"  then do:
            find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.

            if remtrz.jh1 = ? then do:
                message "Нельзя отменить 1 пр. т.к. ее нет !" view-as alert-box.
                next.
            end.


            if remtrz.jh2 = ? then do:
               run rmzcan.
                hide remtrz.
                displ v-rmz8iall with frame rmzor.
            end. else do:
                message "Нельзя отменить 1 проводку пока есть 2 -я !" view-as alert-box.
            end.
         end. 

         if frame-value  = "Очередь"  then do:
            find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if remtrz.jh1 = ? or remtrz.jh2 = ? then do:
                run ps-que.
                hide all.
                displ v-rmz8iall with frame rmzor.
            end. else do:
                message "Нельзя изменить очередь пока есть проводки !" view-as alert-box.
            end.

         end. 
end.


