/* billstl.p
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

/*
  h-bill.p
*/
def new shared var vbill like bill.bill.
def var answer as log.
def var ans as log.
def var vdes as char format "x(3)" label "REMK".

{mainhead.i ELCSET}

update {billstl.f}

if answer eq false then return.


{itemlist.i
	      &file = "bill"
	      &frame = "row 3 centered scroll 1 6 down overlay
			 title "" SELECT BILL NUMBER """
	      &where = "bill.grp ge 2
			and  bill.intdue le g-today
			and  bill.dam[1] gt bill.cam[1]"
	      &flddisp = "bill.bill
			  bill.intdue bill.duedt
			  bill.gl
			  bill.itype label ""I"" skip
			  bill.interest + bill.dam[5]
			  format ""z,zzz,zzz,zzz,zz9.99-""
			  label ""INTEREST""
			  bill.dam[1] - bill.cam[1]
			  format ""z,zzz,zzz,zzz,zz9.99-""
			  label ""BALANCE"" vdes"
	      &chkey = "bill"
	      &chtype = "string"
	      &index  = "bill"
	      &predisp = " if bill.duedt ne bill.intdue then vdes = ""EXT"".
			      else vdes = """"."
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end.
		   else if frame-value ne "" "" and input vdes eq "" ""  then
			 do:
			    vbill = frame-value.
			 {imesg.i 0928} update ans.
			 if not ans then undo,retry.
			    run autostlb.
			    scroll from-current up with frame xf.
			    next.
			 end.
		    else if frame-value ne "" "" and input vdes ne "" ""  then
			 do:
			    vbill = frame-value.
			 {imesg.i 0928} update ans.
			 if not ans then undo,retry.
			    run s-billext.
			    scroll from-current up with frame xf.
			    next.
			 end.
			 "

			     }
