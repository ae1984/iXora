/* trexcom.p
 * MODULE
        Зачисление обменных операций Offline PragmaTX
 * DESCRIPTION
        Вызов процедуры trxgen с шаблоном для снятии комиссий с неплатежной валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        xcm2arp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        05/12/04 kanat
 * CHANGES
        27.01.2004 sasco    - убрал today для cashofc
*/


def input parameter sum_1 as decimal.
def input parameter rez_1 as integer.
       
def new shared var s-jh like jh.jh.
def new shared var v-text as char.
def shared var g-ofc like ofc.ofc.
define shared variable g-today as date.

def var retval as char.
def var rdes  as char.
def var rcode as integer.

s-jh = 0.
def var dlm as char init "|".

run trxgen    ('UNI0131', dlm,     
                string(sum_1) + dlm + 
                string(rez_1), 
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

    
/* ---- 30/11/2001  by sasco   ----->>>>> */
    define var v-cash as logical.
    define var cashgl like jl.gl.
    
    find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
    if avail sysc then
    do:
       cashgl = sysc.inval.

       for each jl where jl.jh = s-jh no-lock:
          if jl.sts = 6 and jl.gl = cashgl then
          do:
              find first cashofc where cashofc.whn eq g-today and
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
                   cashofc.whn = g-today.
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
/* <<<<<------- 30/11/2001 -------------- */



return string(s-jh).

