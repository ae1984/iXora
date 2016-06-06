/* sv_mt.p
 * MODULE
        Услуги системы Интернет банк
 * DESCRIPTION
        Набор СВИФТ сообщения МТ100/103
 * RUN
        sv_mt.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-2-11 
 * AUTHOR
        24/08/2004 saltanat 
 * CHANGES
*/
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.

def var ibhost as cha .

{lgps.i "new"}
m_pid = "3M" .
u_pid = "sv_mt" .
v-option = "rmzer3M".

def var v-rmz8i like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz.

form skip v-rmz8i with frame rmzor  side-label row 3  centered .


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



repeat :
{mainhead.i ERR_3M_}

  update v-rmz8i label "Платеж"
    validate (can-find (remtrz where remtrz.remtrz = v-rmz8i),
     "Платеж не найден !" ) with frame rmzor .
      s-remtrz = v-rmz8i.
      find first remtrz where remtrz.remtrz = s-remtrz no-lock.
  run s-remtrz.
  hide all.
  s-remtrz = "".
end.

