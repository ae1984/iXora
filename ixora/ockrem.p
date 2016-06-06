/* ockrem.p
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

/** ockrem.p **/


{mainhead.i}

define new shared variable s-jh  like jh.jh.


define variable f-ock like ock.ock label "°EKA Nr.".
define variable f-gl  like gl.gl   label "G/GR#   ".
define variable f-crc like crc.crc label "VAL®TA  ".
define variable f-amt like jl.dam  label "SUMMA   ".
define variable t-sub like ock.ock label "SUBKONTS".
define variable t-gl  like gl.gl   label "G/GR#   ".
define variable t-crc like crc.crc label "VAL®TA  ".
define variable t-amt like jl.dam. 
define variable f-dc  as character.
define variable t-dc  as character.
define variable ccode like crc.code.
define variable ask   as logical format "J–/Nё".
define variable ocka  as logical.
  
define variable rcode  as integer.
define variable rdes   as character.
define variable vdel   as character initial "^".
define variable vparam as character.
define variable foot   like jl.rem.

define frame frest
    f-gl space(14) t-gl skip
    f-ock space(10) t-sub skip
    f-crc crc.code no-label space(14) t-crc ccode no-label skip(1)
    f-dc no-label f-amt no-label t-dc no-label t-amt no-label skip
    with centered side-labels.

update f-ock with frame frest.

find ock where ock.ock eq f-ock no-lock no-error.
    if not available ock then do:
        message "°eks nav atrasts.".
        undo, retry.
    end.
    if ock.csts ne "R" then do:
        message "Apstr–d–t nedrЁkst.".
        undo, retry.
    end.

f-crc = ock.crc.

find gl where gl.gl eq ock.gl no-lock no-error.

f-gl = ock.gl.
f-amt = ock.camt.
f-dc = "DEBETS ".
t-dc = "KRED§TS".

find crc where crc.crc eq ock.crc no-lock.
display f-amt ock.crc @ f-crc crc.code f-gl f-dc t-dc
    with frame frest.


update t-gl with frame frest.
find gl where gl.gl eq t-gl no-lock no-error.
    if gl.subled ne "" then do:
        update t-sub with frame frest.
         
         /* P…RBAUDE */               

    end.
t-crc = f-crc.
t-amt = f-amt.
display t-crc t-amt crc.code @ ccode with frame frest.

message "Veidot transakciju?" update ask.
    if not ask then undo, retry.

    foot[1] = "°eka pie‡emЅana".

    vparam = 
        string (f-amt) + vdel + string(f-gl) + vdel + "ock" + vdel + 
        string(1) + vdel + f-ock + vdel + string(t-gl) + vdel + 
        gl.subled + vdel + string(1) + vdel + t-sub + vdel + foot[1].

    
    output to oo.
    put vparam format "x(200)".
    output close.


    s-jh = 0.
    run trxgen 
        ("ock0030", vdel, vparam, output rcode, output rdes, input-output s-jh).
        
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        else message s-jh.
        pause 333.

    run x-jlvou.

    if t-gl eq 101000 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.  
    end.
    else do:
        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.  
    end.

find ock where ock.ock eq f-ock exclusive-lock.


ock.jh1 = s-jh.
    ock.csts = "C".

release ock.

