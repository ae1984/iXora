/* defexll.p
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

{mainhead.i "CLOM10"}

def var d_from as date.
def var d_to as date.
def var v-int as dec.
def var v-intbal as dec.
def var sm3 as dec.
def var v-ob as dec.
def var v-cb as dec.
def new shared var s-cif like cif.cif.
def var s-hlcnt as char format "x(12)".

d_from = g-today.
d_to = date(month(d_from),1,year(d_from)) - 1.
d_from = date(month(d_to),1,year(d_to)).
form 
        cif.cif  label "Код"
        cif.name label "Имя"
        s-hlcnt   label "Кредитная линия"
with side-label 1 column  frame cif.

   prompt-for cif.cif with frame cif.

   find cif using cif.cif no-lock.

   display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ cif.name with frame cif. pause 0.


   s-cif =  cif.cif.



  update s-hlcnt validate 
  (can-find(first loncon where ( loncon.lcnt begins s-hlcnt and loncon.cif = s-cif)) ,
    "Счет не найден !!!")  with side-label frame cif.
  update d_from label "C" d_to label "по" with frame b row 10 side-label.

{header-t.i "new shared" }
{deals.i "new shared"}
{stlibll.i}
{lonlev.i}



def new shared var s-newstmtdt as date.
find sysc where sysc.sysc eq "LONSTN" no-lock no-error.
if available sysc then  s-newstmtdt = sysc.daval.
else s-newstmtdt = g-today + 1.


/*
def var v-code as char.
*/
def var dbt as dec.
def buffer b-deals for deals.



 rows         = 56.
 cols         = 120.
 row_in_page  = 1.
 new_page     = yes.
 new_acc      = yes.
 balance_mode = no.
 page_num     = 0.
 total_page   = 1.
 frmt         = '"x(120)"'.
 margin       = 0.


 formfeed     = yes.

 v-codfr      = "stmt".
 lang-code    = 0.

 branch       = "".
 
find cif where cif.cif eq s-cif no-lock .
run setv("h-custname", trim(trim(cif.prefix) + ' ' + trim(cif.name)) ,?,?).
run setv("h-cif", cif.cif ,?,?).


for each lon where lon.cif eq s-cif no-lock, 
each loncon where loncon.lon eq lon.lon and loncon.lcnt begins s-hlcnt
break by lon.lon:

run atl-dat(lon.lon,d_from - 1,output v-ob).
run atl-dat(lon.lon,d_to,output v-cb).
run atl-prcl(lon.lon, d_to, output v-int, output v-intbal, output sm3).


if first(lon.lon) then do:
create acc_list.
acc_list.aaa  = s-hlcnt .
acc_list.d_from = d_from.
acc_list.d_to = d_to. 
acc_list.crc = lon.crc.
acc_list.stmsts = "INF".
run add_deall(?, acc_list.aaa, d_to, - v-cb, acc_list.crc, ?, "cb", ?).
run add_deall(?, acc_list.aaa, d_from, - v-ob, acc_list.crc, ?, "ob", ?). 
run add_deall(?, acc_list.aaa, d_to, - v-int, acc_list.crc, ?, "ab", ?).
end.
else do:
   find first deals where deals.account = acc_list.aaa and 
   deals.servcode = "ob" and deals.d_date = acc_list.d_from no-error. 
   deals.amount = deals.amount - v-ob.

   find first deals where deals.account = acc_list.aaa and 
   deals.servcode = "cb" and deals.d_date = acc_list.d_to no-error. 
   deals.amount = deals.amount - v-cb.

   find first deals where deals.account = acc_list.aaa and 
   deals.servcode = "ab" and deals.d_date = acc_list.d_to no-error. 
   deals.amount = deals.amount - v-int.

end.

for each jl where 
    (jl.acc eq lon.lon
    and jl.jdt ge d_from 
    and jl.jdt le d_to ) no-lock:
    if jl.sub ne "lon" then next.
    find gl where gl.gl eq jl.gl no-lock no-error.
    if gl.subled eq "LON" and  
    not (jl.lev ne 1 and jl.lev ne 7 and jl.lev ne 8 and
    jl.lev ne 2 and jl.lev ne 9 and jl.lev ne 10) then do:
        /*
        if jl.lev eq 1 or jl.lev eq 7 or jl.lev eq 8 then v-code = "LON".
        else
        if jl.lev eq 2 or jl.lev eq 9 or jl.lev eq 10 then v-code = "INT".
        else
        v-code = "OTHER".
        */
    run add_deall( recid(jl), acc_list.aaa, jl.jdt, ?, jl.crc, 
    string(jl.jh), "lt", ?). 

                 end.
end. /* --- for each jl --- */
end.

def var v-dam like jl.dam.
def var v-cam like jl.cam.
def var v-damo like jl.dam.
def var v-camo like jl.cam.

for each deals break by deals.account :

if deals.servcode eq "lt" then do:
if deals.dc eq "d" then v-dam = v-dam + deals.amount.
else v-cam = v-cam + deals.amount.
end.

if deals.servcode eq "lt" and deals.trxcode eq "LON" then do:
if deals.dc eq "d" then v-damo = v-damo + deals.amount.
else v-camo = v-camo + deals.amount.
end.
if last-of(deals.account) then do:
run add_deall(?, deals.account, d_to, v-dam, deals.crc, ?, "ldt", ?).
run add_deall(?, deals.account, d_to, v-cam, deals.crc, ?, "lct", ?).
v-dam = 0.
v-cam = 0.

run add_deall(?, deals.account, d_to, v-damo, deals.crc, ?, "ldto", ?).
run add_deall(?, deals.account, d_to, v-camo, deals.crc, ?, "lcto", ?).
v-damo = 0.
v-camo = 0.


end.
end.

def var v-amt as dec.
for each acc_list no-lock .

    find first deals where deals.account = acc_list.aaa and
    deals.servcode = "ob" and
    deals.d_date = acc_list.d_from no-error.
    v-amt = deals.amount.

    find first deals where deals.account = acc_list.aaa and
    deals.servcode = "lcto" and
    deals.d_date = acc_list.d_to no-error.
    if available deals then v-amt = v-amt + deals.amount.

    find first deals where deals.account = acc_list.aaa and
    deals.servcode = "ldto" and
    deals.d_date = acc_list.d_to no-error.
    if available deals then v-amt = v-amt - deals.amount.

    find first deals where deals.account = acc_list.aaa and
    deals.servcode = "cb" and
    deals.d_date = acc_list.d_to no-error.
    if v-amt ne deals.amount then 
    message "Error balance " + acc_list.aaa view-as alert-box.

end.      

run dewidell("rpt.img").
def var partkom as char.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if available ofc and ofc.expr[3] <> "" then do:
       partkom = ofc.expr[3] + " rpt.img".
    end.
    else partkom = "prit rpt.img".
def var v-ans as log.
v-ans = no.
message "Выводить на экран ?" view-as alert-box question button yes-no
update v-ans .
if v-ans then partkom = "joe rpt.img".
unix silent value(partkom) .
pause 0.
return.

 

procedure add_deall:


DEFINE INPUT PARAMETER in_recid    AS recid.
DEFINE INPUT PARAMETER in_account  AS CHARACTER .

DEFINE INPUT PARAMETER in_d_date   AS DATE      .
DEFINE INPUT PARAMETER in_amount   AS DECIMAL   .
DEFINE INPUT PARAMETER in_crc      AS INTEGER   .

DEFINE INPUT PARAMETER in_trxtrn   AS CHARACTER .

DEFINE INPUT PARAMETER in_servcode AS CHARACTER .

DEFINE INPUT PARAMETER in_in_value AS INTEGER .

define variable o_dealtrn        as character initial ?.
define variable o_custtrn        as character initial ?.
define variable o_ordins        as character initial ?.
define variable o_ordcust        as character initial ?.
define variable o_ordacc        as character initial ?.
define variable o_benfsr        as character initial ?.
define variable o_benacc        as character initial ?.
define variable o_benbank        as character initial ?.
define variable o_dealsdet        as character initial ?.
define variable o_trxcode       as character initial ?.
define variable o_bankinfo      as character initial ?.

define buffer b-jl for jl.
define buffer b-aal for aal.
define buffer b-aax for aax.
define buffer b-jh  for jh.
def var v-damname as char.
def var v-camname as char.
def var v-cust as char initial ?.


do transaction :

   create deals.

    deals.account  = in_account.
    deals.crc      = in_crc.
    deals.d_date   = in_d_date.
    deals.amount   = in_amount.
    deals.servcode = in_servcode.
    deals.trxtrn   = in_trxtrn.
    deals.in_value = in_in_value.
 
    /* --- Transaction Details Processing --- */
    
    case deals.servcode:
      
      when "lt" then do:

         find b-jl where recid(b-jl) = in_recid no-lock no-error.
            if not available b-jl then return "1".  
         find first b-jh where b-jh.jh = b-jl.jh no-lock no-error.
            if not available b-jh then return "1".

          {ltl-trx.i "deals"} 
      
      end.
 
      otherwise do:
      end.
    end.
    /* -------------------------------------- */
end.
return "0".
end procedure.


