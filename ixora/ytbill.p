/* ytbill.p
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


  def buffer b-invsec for invsec.
  def var vscoupon like invsec.coupon label "SALE YIELD".
  def var vrrtn like invsec.coupon label "RATE OF RETURN".

{mainhead.i }

  prompt-for b-invsec.invsec.
  find invsec where invsec.invsec eq input b-invsec.invsec.
  update vscoupon label "SALE YIELD".
  vrrtn = invsec.coupon + (invsec.mdt - g-today) / (g-today - invsec.sdt)
    * (invsec.coupon - vscoupon).
  /*
  display vrrtn.
  */
  invsec.intrec = invsec.par * vrrtn * (g-today - invsec.sdt) / 36000.
  /*
  invsec.aintrec = invsec.aintrec - invsec.intrec.
  display invsec.par invsec.sdt g-today label "T/S DATE"
	  invsec.mdt vscoupon invsec.coupon
	  vrrtn invsec.intrec invsec.aintrec with width 80 frame mk.
 */
