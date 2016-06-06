/* bankrnn.p
 * MODULE
       Платежная система 
 * DESCRIPTION
        Редактирование РНН банков-корреспондентов.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.11.5
 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK
 * CHANGES
*/

def var v-bankrnn as char no-undo.
form
  bankl.name label "Банк" format "x(40)" skip
  v-bankrnn label "РНН" format "x(12)" skip
with side-label row 3 width 80 title "РНН Банка корреспондента"  frame f-bankrnn.  

for each dfb no-lock break by dfb.bank:
if first-of(dfb.bank) then do:
 find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.
 if not avail sub-cod then next. 
  find first bankl where bankl.bank = dfb.bank  no-lock no-error.
  if avail bankl then do:
   assign  v-bankrnn = bankl.attn.
   display bankl.name v-bankrnn with frame f-bankrnn.
   update v-bankrnn with frame f-bankrnn.
   find current bankl exclusive-lock.
   assign  bankl.attn = v-bankrnn.
  end. 
end.

end.