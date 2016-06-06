/* groset.p
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

/* groset.p */

{mainhead.i}

define buffer apagl    for sysc.
define buffer comgl    for sysc.
define buffer ubpay    for nmbr.

{groset.f}

find apagl where apagl.sysc = "APAGL" no-error.
if not available apagl then do:
  create apagl.
  apagl.sysc = "APAGL".
  apagl.des = "ACCOUNT PAYABLE G/L".
end.

find comgl where comgl.sysc = "COMGL" no-error.
if not available comgl then do:
  create comgl.
  comgl.sysc = "COMGL".
  comgl.des = "COMMISSION SERVICE FOR G/L".
end.

find ubpay where ubpay.code = "UBPAY" no-error.
if not available ubpay then do:
  create ubpay.
  ubpay.code = "UBPAY".
  ubpay.des = "UTILITY BILL PAYMENT NUMBER".
end.

disp apagl.inval comgl.inval
     ubpay.code ubpay.des ubpay.fmt
     ubpay.prefix ubpay.sufix  ubpay.nmbr
     with frame setup.

update apagl.inval
       validate(can-find(gl where gl.gl eq inval)
		, {apagl.h} ) with frame setup.
update comgl.inval
       validate(can-find(gl where gl.gl eq inval)
		, {apagl.h} )    with frame setup.

update ubpay.fmt ubpay.prefix
       ubpay.sufix  ubpay.nmbr
       with frame setup.
