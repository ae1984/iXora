/* compltrx.p
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
        14/03/07 marinav - not avail на arp
*/

{global.i}
def var v_kol as int.
def var v_arp like arp.arp.
def var v_arp1 like arp.arp.
def var i as int.
def var vparam as char.
def var rcode as int.
def var rdes as char.
def new shared var s-jh like jh.jh.
define variable vdel as character initial "^".
def var s-amt like aaa.cr[1].


s-jh = 0.
output to rpt1.img.

find sysc where sysc.sysc = 'COMPL$' no-lock no-error.
if not avail sysc then return.
v_kol = num-entries(chval).
i = 1.
REPEAT ON ENDKEY UNDO, RETRY:
  v_arp = entry(i,chval).
  v_arp1 = entry(i + 1,chval).
  find first arp where arp.arp = v_arp no-lock no-error. 
  if not avail arp then return.
  s-amt = arp.cam[1] - arp.dam[1].
  if s-amt > 0 then do:
  s-jh = 0.
     vparam = string (s-amt) + vdel +
              string (arp.crc) + vdel + v_arp + vdel + 
              "Отражении комиссии за " + string(g-today)
              + vdel + '1' + vdel + v_arp1.
              
     run trxgen("dcl0006", vdel, vparam,
         "arp", "", output rcode, output rdes, input-output s-jh).

     if rcode ne 0 then message rcode rdes.
     put v_arp cam[1] - dam[1] s-jh skip.
  end.

  if i = v_kol - 1 then leave.
  i = i + 2. 
END.

/*s-jh = 0.
find sysc where sysc.sysc = 'COMPLD' no-lock no-error.
if not avail sysc then return.
v_kol = num-entries(chval).
i = 1.
REPEAT ON ENDKEY UNDO, RETRY:
  v_arp = entry(i,chval).
  find first arp where arp.arp = v_arp no-lock no-error. 
  s-amt = arp.cam[1] - arp.dam[1].
  if s-amt > 0 then do:
  s-jh = 0.
     vparam = string (s-amt) + vdel +
              string (arp.crc) + vdel + v_arp + vdel + 
              '460813' + vdel + " Комиссия за " + string(g-today).
            
     run trxgen("vnb0001", vdel, vparam,  
        "arp", "", output rcode, output rdes, input-output s-jh).
             
     if rcode ne 0 then message rcode rdes.
     put v_arp cam[1] - dam[1] s-jh skip.
  end.
 
  if i = v_kol then leave.
  i = i + 1. 
end. 
*/

/*find sysc where sysc.sysc = 'COMPLR' no-lock no-error.
v_kol = num-entries(chval).
i = 1.
REPEAT ON ENDKEY UNDO, RETRY:
  v_arp = entry(i,chval).
  find first arp where arp.arp = v_arp no-lock no-error. 
  s-amt = arp.dam[1] - arp.cam[1].
  if s-amt > 0 then do:
  s-jh = 0.
     vparam = string (s-amt) + vdel +
              string (arp.crc) + vdel + '560813' + vdel + 
              v_arp + vdel + " Комиссия за " + string(g-today).
            
     run trxgen("vnb0002", vdel, vparam,  
        "arp", "", output rcode, output rdes, input-output s-jh).
             
     if rcode ne 0 then message rcode rdes.
     put v_arp dam[1] - cam[1] s-jh skip.
  end.
 
  if i = v_kol then leave.
  i = i + 1. 
end. 
*/
output close.
