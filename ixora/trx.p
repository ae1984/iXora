/* trx.p
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
        27.01.2004 sasco    - убрал today для cashofc
*/


/* last change : 30/11/2001 by sasco - change CASHOFC record 

*/

def input parameter state as int.
def input parameter sum as deci.
def input parameter cur as int.
def input parameter dglaccnt as char.
def input parameter daccnt as char.
def input parameter cglaccnt as char.
def input parameter caccnt as char.
def input parameter rem as char.
def input parameter kod as char.
def input parameter kbe as char.
def input parameter knp as char.

if cglaccnt = '' then do:
    run getgl.p(caccnt).
    cglaccnt = return-value.
end.

if dglaccnt = '' then do:
    run getgl.p(daccnt).
    dglaccnt = return-value.
end.
        
def new shared var s-jh like jh.jh.
def new shared var v-text as char.
def shared var g-ofc like ofc.ofc.
define shared variable g-today as date.

def var retval as char.
def var rcode as int.
def var rdes  as cha.

s-jh = 0.
def var dlm as char init "|".

run trxgen ('ALX0009', dlm,  
    string(state) + dlm +
    string(sum) + dlm +
    string(cur) + dlm +
    dglaccnt + dlm + 
    daccnt + dlm +
    cglaccnt + dlm +
    caccnt + dlm +
    substring(rem,1  ,55) + dlm +
    substring(rem,56 ,55) + dlm +
    substring(rem,111,55) + dlm +
    substring(rem,166,55) + dlm +
    substring(rem,221,55) + dlm +
    substring(kod,1,1) + dlm +
    substring(kbe,1,1) + dlm +
    substring(kod,2,1) + dlm +
    substring(kbe,2,1) + dlm +
    knp
    ,
    "", "", output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        return "".
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


