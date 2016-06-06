/* acdcvou.p
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

/* advvou.p
*/

{mainhead.i ELCADVP}

define new shared var s-jh like jh.jh format "zzzzzzzz".
define new shared var s-ln like jl.ln.

def var vcnt as int.
def var vcmp like cmp.name format "x(25)".
def var vtennor as char form "x(30)".
def var vdate as date.
def var cond as char format "x(5)" extent 2.

repeat:

do on error undo,retry:
 update {acdcvou.h} s-jh skip
 with centered no-box no-label frame ops row 5.

 find first rpay where rpay.jh  = s-jh  no-lock no-error no-wait.
  if not available  rpay then do:
  bell.
  {mesg.i 0230}.
  undo,retry.
 end.
end.

find bank where bank.bank eq rpay.bank no-error.
if not available bank then leave.

find ofc where ofc.ofc eq userid('bank') no-error.
find first cmp no-error.

vcmp = cmp.name.
vdate = rpay.regdt.
vtennor = string(rpay.trm) + " DAYS".
if rpay.itype = "A" then do:
		    cond[1] = "(   )".
		    cond[2] = "(XXX)".
		    end.
		      else do:
		      cond[1] = "(XXX)".
		      cond[2] = "(   )".
		     end.

output to stmt.img page-size 59.

{acdcvou.f}

end.
output to close.
unix silent psor -o Courier 10 10 26 stmt.img > post.img.
unix silent lpr -Plp1 post.img.
