/* defexl.p
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
        19/04/2005 madiyar - добавил вывод в выписку штрафов и комиссий
        17/06/2005 madiyar - добавил вывод в выписку индексации
        09/01/2006 madiyar - выбор варианта вывода
        06/10/2006 madiyar - выбор ссудника из справочника
*/

{mainhead.i "CLOM9"}

def var s-lon like lon.lon.
def var d_from as date.
def var d_to as date.
def var v-int as dec.
def var v-intbal as dec.
def var sm3 as dec.
def new shared var s-cif like cif.cif.
def var s-hlon like lon.lon.
def var partkom as char format "x(40)".
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if available ofc and ofc.expr[3] <> "" then do:
       partkom = ofc.expr[3] .
    end.
    else partkom = "prit".


d_from = g-today.
d_to = date(month(d_from),1,year(d_from)) - 1.
d_from = date(month(d_to),1,year(d_to)).

def temp-table t-ln no-undo
  field code like lon.lon
  field crc as char
  field opnamt as deci
  field rdt as date
  index main is primary code.

form
        cif.cif  label "Код"
        cif.name label "Имя"
        s-hlon   label "Счет" help " F2 - справочник "
        /*
        partkom  label "Команда печати"
        */
with side-label 1 column frame cif.

on help of s-hlon in frame cif do:
  for each t-ln: delete t-ln. end.
  for each lon where lon.cif = cif.cif no-lock.
    create t-ln.
    t-ln.code = lon.lon.
    find crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then t-ln.crc = crc.code.
    t-ln.opnamt = lon.opnamt.
    t-ln.rdt = lon.rdt.
  end.
  find first t-ln no-error.
  if not avail t-ln then do:
    message skip " Ссудных счетов нет! " skip(1) view-as alert-box information.
    undo.
  end.
  {itemlist.i 
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'Сс.счет' format 'x(9)'
                    t-ln.crc label 'Вал' format 'x(3)'
                    t-ln.opnamt label 'Сумма' format '>>>,>>>,>>>,>>9.99'
                    t-ln.rdt label 'ДатаВыдачи' format '99/99/9999'
                   "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) = 'end-error' then return."
  }
  s-hlon = t-ln.code.
  displ s-hlon with frame cif.
end.

   /*
   displ partkom with frame cif.
   */
   prompt-for cif.cif with frame cif.

   find cif using cif.cif no-lock no-error.
   if avail cif then do: display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ cif.name with frame cif. pause 0. end.
   else undo.

   s-cif =  cif.cif.



  update s-hlon validate
  (can-find(lon where ( lon.lon = s-hlon and lon.cif = s-cif)) ,
    "Счет не найден !!!")  with side-label frame cif.
  s-lon = s-hlon.
  /*
  update partkom with frame cif.
  */

  update d_from label "C" d_to label "по" with frame b row 10 side-label.

{header-t.i "new shared" }
{deals.i "new shared"}
{stlibl.i}
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
 



find lon where lon.lon eq s-lon no-lock no-error.
find cif where cif.cif eq lon.cif no-lock .
run setv("h-custname", trim(trim(cif.prefix) + ' ' + trim(cif.name)) ,?,?).
run setv("h-cif", lon.cif ,?,?).

create acc_list.
acc_list.aaa  = s-lon .
acc_list.d_from = d_from.
acc_list.d_to = d_to.
acc_list.crc = lon.crc.
acc_list.stmsts = "INF".
           /*
           acc_list.lgr  as char format "X(3)"
           acc_list.hbal as decimal format "-z,zzz,zzz,zzz,zz9.99"
           acc_list.craccnt as char format "X(10)"
           acc_list.stmsts  AS CHARACTER
           acc_list.seq     AS DECIMAL
            */
run atl-dat(lon.lon,d_to,output dbt).
run add_deall(?, lon.lon, d_to, - dbt, lon.crc, ?, "cb", ?).

run atl-dat(lon.lon,d_from - 1,output dbt).
run add_deall(?, lon.lon, d_from, - dbt, lon.crc, ?, "ob", ?).

run atl-prcl(lon.lon, d_to, output v-int, output v-intbal, output sm3).
run add_deall(?, lon.lon, d_to, - v-int, lon.crc, ?, "ab", ?).

for each jl where
    (jl.acc eq s-lon
    and jl.jdt ge d_from
    and jl.jdt le d_to ) no-lock:
    if jl.sub ne "lon" then next.
    find gl where gl.gl eq jl.gl no-lock no-error.
    if not avail gl then next.
    if gl.subled eq "LON" and lookup(string(jl.lev),"1,2,7,8,9,10,16,20,22,25,27,28,29") > 0 then do:
        /*
        if jl.lev eq 1 or jl.lev eq 7 or jl.lev eq 8 then v-code = "LON".
        else
        if jl.lev eq 2 or jl.lev eq 9 or jl.lev eq 10 then v-code = "INT".
        else
        v-code = "OTHER".
        */
    run add_deall( recid(jl), jl.acc, jl.jdt, ?, jl.crc,
    string(jl.jh), "lt", ?).

                 accumulate jl.dam ( total ) jl.cam ( total ).
                 end.
end. /* --- for each jl --- */


def var v-dam like jl.dam.
def var v-cam like jl.cam.
def var v-damo like jl.dam.
def var v-camo like jl.cam.
for each deals break by deals.account :
if deals.servcode eq "lt" then
if deals.dc eq "d" then v-dam = v-dam + deals.amount.
else v-cam = v-cam + deals.amount.
if deals.servcode eq "lt" and deals.trxcode eq "LON" then
if deals.dc eq "d" then v-damo = v-damo + deals.amount.
else v-camo = v-camo + deals.amount.
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
v-amt = 0.
for each acc_list no-lock.

    find first deals where deals.account = acc_list.aaa and deals.servcode = "ob" and
                           deals.d_date = acc_list.d_from no-error.
    if available deals then v-amt = deals.amount.

    find first deals where deals.account = acc_list.aaa and deals.servcode = "lcto" and
                           deals.d_date = acc_list.d_to no-error.
    if available deals then v-amt = v-amt + deals.amount.

    find first deals where deals.account = acc_list.aaa and deals.servcode = "ldto" and
                           deals.d_date = acc_list.d_to no-error.
    if available deals then v-amt = v-amt - deals.amount.

    find first deals where deals.account = acc_list.aaa and deals.servcode = "cb" and
                           deals.d_date = acc_list.d_to no-error.
    if v-amt ne deals.amount then message "Error balance " + acc_list.aaa view-as alert-box.

end.
run dewidel("rpt.img").
/*
def var v-ans as log.
v-ans = no.
message "Выводить на экран ?" view-as alert-box question button yes-no
update v-ans .
if v-ans then partkom = "joe".
unix silent value(partkom) rpt.img.
*/

run menu-prt ("rpt.img").

pause 0.
return.

 

procedure add_deall:


DEFINE INPUT PARAMETER in_recid    AS recid.
DEFINE INPUT PARAMETER in_account  AS CHARACTER.

DEFINE INPUT PARAMETER in_d_date   AS DATE.
DEFINE INPUT PARAMETER in_amount   AS DECIMAL.
DEFINE INPUT PARAMETER in_crc      AS INTEGER.

DEFINE INPUT PARAMETER in_trxtrn   AS CHARACTER.

DEFINE INPUT PARAMETER in_servcode AS CHARACTER.

DEFINE INPUT PARAMETER in_in_value AS INTEGER.

define variable o_dealtrn       as character initial ?.
define variable o_custtrn       as character initial ?.
define variable o_ordins        as character initial ?.
define variable o_ordcust       as character initial ?.
define variable o_ordacc        as character initial ?.
define variable o_benfsr        as character initial ?.
define variable o_benacc        as character initial ?.
define variable o_benbank       as character initial ?.
define variable o_dealsdet      as character initial ?.
define variable o_trxcode       as character initial ?.
define variable o_bankinfo      as character initial ?.

define buffer b-jl for jl.
define buffer b-aal for aal.
define buffer b-aax for aax.
define buffer b-jh  for jh.
def var v-damname as char.
def var v-camname as char.
def var v-cust as char initial ?.


do transaction:

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
