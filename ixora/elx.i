


    function comm-payment returns decimal ( sum as decimal, code as char, first_code as char,  output comchar as char).
        define var v-proc as deci.
        if sum = 0 then return 0.00.
        find first tarif2 where num = first_code and kod = code and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then return 0.00.
        comchar = tarif2.pakalp.
        if tarif2.ost <> 0 then return tarif2.ost.
        v-proc =  (sum * tarif2.proc * 0.01).
        if tarif2.min = 0 and tarif2.max = 0 then return v-proc.
        if tarif2.min > 0 and tarif2.max > 0 then do:
           if v-proc <= tarif2.min then return tarif2.min.
           if v-proc > tarif2.min and v-proc < tarif2.max then return v-proc.
           if v-proc >= tarif2.max then return tarif2.max.
        end.
        if tarif2.min = 0 and tarif2.max > 0 then do:
           if v-proc >= tarif2.max then tarif2.max.
           else return v-proc.
        end.
        if tarif2.min > 0 and tarif2.max = 0 then do:
           if v-proc <= tarif2.min then return tarif2.min.
              else return v-proc.
        end.
    end.



function is-process-uid logical (input p-uid as char).

  find first uid-jh where uid-jh.uid = p-uid and uid-jh.jh > 0  no-lock no-error. 
  if avail uid-jh then 
      return true.
  else 
      return false.

end function.

procedure insert-uid.
 def input parameter  p-uid as char .
 def input parameter  p-jh as integer.
 def input parameter  p-xdoc as integer .
 def input parameter  p-type as char.
 def input parameter  p-sender-id as char .
 def input parameter  p-amt as deci.
 def input parameter  p-comm as deci.


   create uid-jh.
     assign 
        uid-jh.dt           = today
        uid-jh.uid          = p-uid
        uid-jh.jh           = p-jh
        uid-jh.xdoc-id      = p-xdoc
        uid-jh.xdoc-type    = p-type
        uid-jh.terminal-id  = p-sender-id
        uid-jh.amt          = p-amt
        uid-jh.comm         = p-comm.

  release uid-jh.

end procedure.
