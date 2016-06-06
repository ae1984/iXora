/* detupd.p
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

{global.i}
def shared var s-remtrz like remtrz.remtrz.
def shared frame remtrz.
def var v-date as date.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def var dtt1 as cha format "x(70)". 
def var dtt2 as cha format "x(70)". 
def var sublist as cha .
def var ourbank as cha . 
def var sender like ptyp.sender . 
def var receiver like ptyp.receiver . 
 find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
 sublist = sysc.chval.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Запись OURBNK нет в sysc файле !!".
   pause .
   undo .
   return .
  end.
 ourbank = sysc.chval.


{lgps.i}
{ps-prmt.i}
{rmz.f}


do transaction :
find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .

if remtrz.rbank ne ourbank  and rbank ne "" then do:
   message " БАНКО не равен " + ourbank + "  !! " .  pause .
   bell . bell .
   undo . 
   return .
end.
if remtrz.jh2 ne ?   then do:
  message "  2 проводка уже сущетвует " + ourbank + "  !! " .
    pause .   bell . bell .
    return .
   end.

 if available remtrz then do :
  if remtrz.source = "SW" then do:
      do on error undo , leave  :

        dtt1 = remtrz.detpay[1] + remtrz.detpay[2] .
        dtt2 = remtrz.detpay[3] + remtrz.detpay[4] . 
        update  dtt1 dtt2 with overlay  no-label top-only row 8 1 col centered
        title "  Details of payment " frame adsd.
        remtrz.detpay[1] = substr(dtt1,1,35) .
        remtrz.detpay[2] = substr(dtt1,36,35) .
        remtrz.detpay[3] = substr(dtt2,1,35) .
        remtrz.detpay[4] = substr(dtt2,36,35) .
        remtrz.rcvinfo[1] = dtt1 .
        remtrz.rcvinfo[2] = dtt2 .
      end.
     end. 
  v-text = remtrz.remtrz + " ТИП = " + remtrz.ptype + " " 
  + " детали платежа изменены пользователем " + g-ofc .
  run lgps .
  que.df = today . 
  release remtrz.
end.
end.
