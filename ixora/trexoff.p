/* trxexoff.p
 * MODULE
        Зачисление обменных операций Offline PragmaTX
 * DESCRIPTION
        Вызов процедуры trxgen с шаблоном для покупки валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        exc2arp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        29/01/04 kanat
 * CHANGES
        02/06/2004 kanat Добавил проставление символа касс плана - run sim-obm (ЛУЧШЕ ПОЗДНО ЧЕМ НИКОГДА)
        02/09/2004 kanat Убрал проставление символов касс плана - они ставятся только на 100100 (они все равно не проставлялись).
        03/03/2004 kanat Добавил входной параметр по дате проведения операции и АРП счета ищутся исходя из истории "передвижения" кассира
        24/03/2004 kanat Изменил в проверке на профит центры вместо regdt на v-ofc-date.
*/

def input parameter rem_1 as char.
def input parameter sum_1 as decimal.
def input parameter cur_1 as integer.
def input parameter rem_2 as char.
def input parameter cur_2 as integer.
def input parameter v-ofc as char.
def input parameter v-ofc-date as date.
       
def new shared var s-jh like jh.jh.
def new shared var v-text as char.
def shared var g-ofc like ofc.ofc.

def var retval as char.
def var rdes  as char.
def var rcode as integer.

def var v-darp as char.
def var v-carp as char.

s-jh = 0.
def var dlm as char init "|".

v-darp = "".
v-carp = "".

find last ofchis where ofchis.ofc = v-ofc and ofchis.regdt <= v-ofc-date no-lock no-error.
if avail ofchis then do:
find last ofcprofit where ofcprofit.ofc = ofchis.ofc and ofcprofit.regdt <= v-ofc-date no-lock no-error.
if not avail ofcprofit then do:
message "Кассир отсутствует в истории изменения профит - центров" view-as alert-box title "Внимание".
return.
end.
end.
else do:
message "Кассир отсутствует в истории" view-as alert-box title "Внимание".
return.
end.


for each arp where arp.gl = 100300 no-lock:
  if (arp.crc <> cur_1) and (arp.crc <> cur_2) then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> "obmen1003" then next.
   
  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> ofcprofit.profit then next.

  if arp.crc = cur_1 then v-darp = arp.arp.
  if arp.crc = cur_2 then v-carp = arp.arp.

  if v-darp <> "" and v-carp <> "" then leave.
end.
   
if v-darp = "" or v-carp = "" then do:
  message skip " Не настроены счета ARP для загружаемого кассира в указанной валюте!?" 
    skip(1) view-as alert-box title "Ошибка".
  return.
end.


run trxgen-obm ('JOU0013', dlm,     
                rem_1 + dlm + 
                string(sum_1) + dlm + 
    		string(cur_1) + dlm +
    		v-darp + dlm + 
    		rem_2 + dlm + 
    		string(cur_2) + dlm +
    		v-carp + dlm, 
    		"", "", output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        return "".
    end.        


        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
            end.



    
    define var v-cash as logical.
    define var cashgl like jl.gl.
    
    find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
    if avail sysc then
    do:
       cashgl = sysc.inval.

       for each jl where jl.jh = s-jh no-lock:
          if jl.sts = 6 and jl.gl = cashgl then
          do:
              find first cashofc where cashofc.whn eq today and
                                       cashofc.sts eq 2 and
                                       cashofc.ofc eq g-ofc and
                                       cashofc.crc eq jl.crc
                                       exclusive-lock no-error.
              if avail cashofc then 
              do:
                  cashofc.amt = cashofc.amt + jl.dam - jl.cam.
              end.
              else do:
                   create cashofc.
                   cashofc.whn = today.
                   cashofc.ofc = g-ofc.
                   cashofc.crc = jl.crc.
                   cashofc.sts = 2.
                   cashofc.amt = jl.dam - jl.cam.
                   cashofc.who = g-ofc.
              end.

              release cashofc.
          end. 
      end. 
      
    end.

return string (s-jh).



