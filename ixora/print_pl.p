/* print_pl.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        печать платежного поручения
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-1-1
 * AUTHOR
        12.04.2011 ruslan
* BASES
        BANK COMM
 * CHANGES
*/

define var o_err  as log init false. /* Customer's Account  */
define input parameter i-jh like jl.jh.
define input parameter i-aaa like aaa.aaa.
def new shared var s-cif like cif.cif.

def var in_cif like cif.cif                   no-undo.
def var in_acc like aaa.aaa                   no-undo.
def var in_jh   as char init ""               no-undo.
def var in_ln   as char init ""               no-undo.
def var crccode like crc.code                 no-undo.
def var p_mem   as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
def var p_memf  as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
def var p_pld   as char init "" format "x"    no-undo.  /*   Дебетовое платежное поручениеPut plat.por. deb. */
def var p_uvd   as char init "" format "x"    no-undo.  /*   Кредитовое уведомление Put plat.por. deb.       */
def var v-ok    as log                        no-undo.
def var in_command as char init "prit"        no-undo.
def var in_destination as char init "dok.img" no-undo.
def var partkom as char                       no-undo.
def var vans    as log init true              no-undo.
def var m-rtn   as log                        no-undo.
def new shared var flg1 as log.
def var s-rem   as char                       no-undo.
def var v-cifname as char format "x(40)"      no-undo.

 find first jl where jl.acc EQ i-aaa and jl.jh = i-jh no-lock no-error.
 if avail jl then do:
  in_acc = jl.acc.
  in_jh  = string(jl.jh).
  in_ln =  string(jl.ln).
   end.

  vans=true.
  message "Печатать документ?" view-as alert-box question buttons Yes-No
          title " ---  Печать  --- " update vans. /* as log init true. */
  if vans
  then do:
       Run PrintD in This-Procedure.
  end.

Procedure PrintD:

  hide message no-pause.
  p_mem="".
  p_memf="".
  p_pld="1".

  Repeat on endkey undo,return:
        update " Команда печати :"  in_command with frame c1 row 16 no-label centered overlay.
   leave.
  End.

unix silent rm -f value("dok.img").

display " формирование документа по операции " in_jh with frame c3 no-label . pause 0.
run vipdokln(in_jh,in_ln,in_acc,p_mem,p_memf,p_pld,p_uvd,output o_err).
    if opsys <> "UNIX"
   then return "0".
   if in_command <> ?
   then do:
        partkom = in_command + " " + in_destination.
   end.
   else do:
        find first ofc where ofc.ofc = userid("bank") no-lock no-error.
        if available ofc and ofc.expr[3] <> ""
        then do:
             partkom = ofc.expr[3] + " " + in_destination.
        end.
        else return "0".
   end.
   if flg1 then unix silent value(partkom).
   hide all no-pause.
   view frame mainhead.
   view frame cif.
   pause 0.
End Procedure.