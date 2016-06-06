/* st_rmze.p
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
	26/12/03 valery заменена строка        o_dealsdet = o_dealsdet + ". Комиссия отправителя: " + tmp-amt + tmp-cur.
               o_dealsdet = o_dealsdet + ". Комиссия инобанков: " + tmp-amt + tmp-cur.
*/

/* ==============================================================
=                                                                =
=                Remittance Details Processor                        =
=                                                                =
============================================================== */

/*Последние изменения:
   26/05/03 Попова Н. поменяла   строку o_custtrn = "Nr." + trim(substr(s-remtrz.sqn,19,8))
   на o_custtrn = "Nr." + trim(substr(s-remtrz.sqn,19,10))

*/

define input  parameter rec_id                 as recid.
define output parameter o_dealtrn         as character.
define output parameter o_custtrn         as character .
define output parameter o_ordins        as character.
define output parameter o_ordcust        as character.
define output parameter o_ordacc        as character.
define output parameter o_benfsr        as character.
define output parameter o_benacc        as character.
define output parameter o_benbank        as character.
define output parameter o_dealsdet        as character.
define output parameter o_bankinfo      as character.

define buffer s-jl for jl.
define buffer s-remtrz for remtrz.
define var ja as inte.
define var tmp as char.
define var tmp-amt as char.
define var tmp-cur as char.
define var ind-71F as logi initial true.
define var ind-71G as logi initial true.


find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then return "1".

/* if not s-jl.rem[1] begins "RMZ" then return "1". */

find s-remtrz where s-remtrz.remtrz = substring(s-jl.rem[1],1,10) no-lock no-error.
if not available s-remtrz then return "1".

o_dealtrn = s-remtrz.remtrz.

if s-remtrz.sqn <> ? then o_custtrn = "Nr." + trim(substr(s-remtrz.sqn,19,10)). /* Customers TRN */

/* --- Sender Bank --- */

if s-remtrz.sbank begins "TXB" then do:
find first bankl where bankl.bank = s-remtrz.sbank no-lock no-error.

 if available bankl and bankl.name <> "" then do:
  o_ordins = trim(bankl.name).
 end.
 else do:
   if s-remtrz.ordins[1] <> ? then o_ordins = trim (s-remtrz.ordins[1]).
   if s-remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[2]).
   if s-remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[3]).
   if s-remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[4]).
 end.
end.
else do:
 if s-remtrz.ordins[1] = "NONE" then do:
    find first bankl where bankl.bank = s-remtrz.sbank no-lock no-error.
    if available bankl and bankl.name <> "" then do:
      o_ordins = trim(bankl.name).
    end.
 end.
 else do:
   if s-remtrz.ordins[1] <> ? then o_ordins = trim (s-remtrz.ordins[1]).
   if s-remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[2]).
   if s-remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[3]).
   if s-remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim (s-remtrz.ordins[4]).
 end.
end.
find first bankl where bankl.bank = s-remtrz.sbank no-lock no-error .
if avail bankl then do:
 o_ordins = trim(bankl.bank) + " " + o_ordins .
end.

if s-remtrz.ord <> ? then o_ordcust = trim(s-remtrz.ord).

if s-remtrz.sacc <> ? then o_ordacc = trim(s-remtrz.sacc).

if s-remtrz.bn[1] <> ? then o_benfsr = trim ( s-remtrz.bn[1] ).
if s-remtrz.bn[2] <> ? then o_benfsr = o_benfsr + " " + trim ( s-remtrz.bn[2] ).
if s-remtrz.bn[3] <> ? then o_benfsr = o_benfsr + " " + trim ( s-remtrz.bn[3] ).

/* --- Beneficiary Bank --- */


if s-remtrz.rbank begins "TXB" then do:

 find first bankl where bankl.bank = s-remtrz.rbank no-lock no-error.
  if available bankl and bankl.name <> "" then do:
    o_benbank = trim(bankl.name) .
  end.
  else do:
    o_benbank  = trim(s-remtrz.bb[1]) + " " + trim(s-remtrz.bb[2]) + " " + trim(s-remtrz.bb[3]).
  end.
end.
else do:
  if s-remtrz.bb[1] = "NONE" then do:
     find first bankl where bankl.bank = s-remtrz.rbank no-lock no-error.

    if available bankl and bankl.name <> "" then do:
      o_benbank = trim(bankl.name).
    end.
  end.
  else do:
    o_benbank  = trim(s-remtrz.bb[1]) + " " + trim(s-remtrz.bb[2]) + " " + trim(s-remtrz.bb[3]).
  end.
end.
find first bankl where bankl.bank = s-remtrz.rbank no-lock no-error .
if avail bankl then do:
 o_benbank = trim(bankl.bank) + " " + o_benbank .
end.

o_benacc   = trim(s-remtrz.ba).

if (s-remtrz.detpay[1]) matches (s-remtrz.ba + "*") or
   (s-remtrz.detpay[1]) matches (substring(s-remtrz.ba,2) + "*") then do:
    o_dealsdet = trim(substring(s-remtrz.detpay[1], length(o_benacc) + 1)) + " " + trim(s-remtrz.detpay[2]) + " " + trim(s-remtrz.detpay[3]) + " " + trim(s-remtrz.detpay[4]) .
end.
else do:
    o_dealsdet = trim(s-remtrz.detpay[1]) + " " + trim(s-remtrz.detpay[2]) + " " + trim(s-remtrz.detpay[3]) + " " + trim(s-remtrz.detpay[4]) .
    /* o_dealsdet = o_dealsdet + " " + trim(s-remtrz.rcvinfo[1]) + " " + trim(s-remtrz.rcvinfo[2]). */
end.

/*Start ja-030305*/
/*
if s-remtrz.INFO[7] ne "" then do:
  ja = 0.
  repeat:
   ja = ja + 1.
   tmp = entry(ja,s-remtrz.info[7],"^").
   if tmp = "" then leave.
   case true:
    when tmp begins "33B-CUR:" then do:
     tmp-cur = entry(2,tmp,":").
     ja = ja + 1.
     tmp = entry(ja,s-remtrz.info[7],"^").
     tmp-amt = entry(2,tmp,":").
     o_dealsdet = o_dealsdet + " Первоначальная сумма платежа: "
                             + tmp-amt + tmp-cur.
    end.
    when tmp begins "36:" then do:
     tmp-amt = entry(2,tmp,":").
     o_dealsdet = o_dealsdet + ". Курс обмена: " + tmp-amt.
    end.
    when tmp begins "71F-CUR:" then do:
     tmp-cur = entry(2,tmp,":").
     ja = ja + 1.
     tmp = entry(ja,s-remtrz.info[7],"^").
     tmp-amt = entry(2,tmp,":").
     if ind-71F then
       o_dealsdet = o_dealsdet + ". Комиссия инобанков: " + tmp-amt + tmp-cur.
     else
       o_dealsdet = o_dealsdet + "; " + tmp-amt + tmp-cur.
     ind-71F = false.
    end.
    when tmp begins "71G-CUR:" then do:
     tmp-cur = entry(2,tmp,":").
     ja = ja + 1.
     tmp = entry(ja,s-remtrz.info[7],"^").
     tmp-amt = entry(2,tmp,":").
     if ind-71G then
       o_dealsdet = o_dealsdet + ". Комиссия получателя: " + tmp-amt + tmp-cur.
     else
       o_dealsdet = o_dealsdet + "; " + tmp-amt + tmp-cur.
     ind-71G = false.
    end.
   end.
  end.
end.
*/
/*End ja-030305*/
/*
if s-remtrz.fcrc <> s-remtrz.tcrc then do:

  define variable exchange as character.

  o_dealsdet = o_dealsdet + " " + exchange.

end.
*/


return "0".

