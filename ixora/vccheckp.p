/* vccheckp.p       
 * MODULE
        Контроль на платежа
 * DESCRIPTION
              Возвращет 0 если платеж первый за этот день и не > 10 000 
                               1 если Сумма перевода больше 10 000 $ 
                               2 если был уже платеж в текущем дне
    
        
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
        11/03/04 tsoy
 * CHANGES
*/
{global.i}

define input  parameter p-rnn    as char.
define input  parameter p-remtrz like remtrz.remtrz.
define input  parameter p-fcrc   like remtrz.fcrc.
define output parameter p-ans    as integer.

def var v_amtusd as deci.
def var v-bank as char.


find first remtrz where remtrz.remtrz = p-remtrz no-lock no-error.

/* проверяем сумму*/
if remtrz.fcrc = 2 then
    v_amtusd = remtrz.amt.
else do:
        find first crc where crc.crc = p-fcrc no-lock no-error.
           if avail crc then
              v_amtusd = remtrz.amt * crc.rate[1].

        find first crc where crc.crc = 2 no-lock no-error.
           if avail crc then
              v_amtusd = v_amtusd / crc.rate[1].

end.

{comm-txb.i}
v-bank = comm-txb().

if v_amtusd > 10000 then do:
   p-ans =  1.
   return.
end.
else do: /* проверяем наличие платежа */
    for each remtrz where remtrz.rdt =  g-today       no-lock.

                   if remtrz.remtrz  = p-remtrz then next.
                   if remtrz.fcrc    = 1 then next.
                   if remtrz.sbank  <> v-bank then next.

                   if index(remtrz.ord,"/RNN/") ne 0 then do:
                        if p-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12) then do:
                           p-ans = 2.
                           return remtrz.remtrz + " " + remtrz.rwho.
                        end.
                  end.
    end. 
    for each remtrz where remtrz.rdt < g-today and remtrz.valdt2 =  g-today  no-lock.

                   if  remtrz.remtrz  = p-remtrz then next.
                   if remtrz.fcrc    = 1 then next.
                   if  remtrz.sbank  <> v-bank then next.

                   if index(remtrz.ord,"/RNN/") ne 0 then do:
                        if p-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12) then do:
                           p-ans = 2.
                           return remtrz.remtrz + " " + remtrz.rwho.
                        end.
                  end.
    end. 

end.     /* else do: */

p-ans =  0.

                                                      
