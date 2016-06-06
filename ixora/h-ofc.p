/* h-ofc.p
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
        29/06/04 sasco возможность поиска по наименованию
*/

/* h-ofc.p
*/
{global.i}
def var vkey as cha form "x(16)".
def var vpoint like ppoint.point label "PUNKTS".
def var vdep like ppoint.depart label "DEPARTAMENTS".
define variable vch as integer initial 1.

/* bell. */
/* sasco {mesg.i 0951} update vkey. */

message "Поиск по 1)логину; 2)ФИО " update vch.
case vch:
   when 1 then message "Введите логин " update vkey.
   when 2 then message "Введите часть ФИО " update vkey.
   otherwise undo, return.
end case.   

/* if keyfunction(lastkey) = "go" then do: */
if vch = 2 then do:
  vkey = "*" + vkey + "*".
  {itemlist.i &where = "ofc.name matches vkey "
	 &file = "ofc"
	 &frame = "row 5 centered scroll 1 12 down overlay "
	 &predisp = " vpoint = ofc.regno / 1000 - 0.5.
		      vdep = ofc.regno - vpoint * 1000. "
	 &flddisp = "ofc.ofc ofc.name vpoint vdep ofc.tit "
	 &chkey = "ofc"
	 &chtype = "string"
	 &index  = "ofc"
	 &funadd = "if frame-value = "" "" then do:
		      {imesg.i 9205}.
		      pause 1.
		      next.
		    end."
	 &set = "a"}
end.
else 
if vch = 1 then do:
  {itemlist.i
	 &where = "ofc.ofc ge vkey"
	 &file = "ofc"
	 &frame = "row 5 centered scroll 1 12 down overlay "
	 &predisp = " vpoint = ofc.regno / 1000 - 0.5.
		      vdep = ofc.regno - vpoint * 1000. "
	 &flddisp = "ofc.ofc ofc.name vpoint vdep ofc.tit"
	 &chkey = "ofc"
	 &chtype = "string"
	 &index  = "ofc"      /*       &file */
	 &funadd = "if frame-value = "" "" then do:
		      {imesg.i 9205}.
		      pause 1.
		      next.
		    end."
	 &set = "b"}
 end.
