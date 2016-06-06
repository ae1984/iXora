/* h-pc.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Help - поиск счета ПК
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
        26/06/2012 id00810
 * BASES
 		BANK COMM
 * CHANGES
        16/07/2012 id00810 - переход на использование таблицы pccards
        01.07.2013 Lyubov - ТЗ 1766 отбор по номеру карты
*/

{global.i}

def var v-sel   as char             no-undo.
def var v-pcard like pccards.pcard  no-undo.
def var v-name  like pccards.sname  no-undo.
def var v-bin   like pccards.iin    no-undo.

message "Выберите счет: A)карточка  N)ФИО  B)ИИН" update v-sel.

if can-do('A,а,А,ф,Ф',v-sel) then do:
    {itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите номер карточки '  update v-pcard."
       &where   = " pccards.pcard = v-pcard "
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pccards.aaa label ' № счета' pccards.sname label 'ФИО' pccards.iin label 'ИИН' pccards.pcard label '№ карты'  format 'x(16)' "
       &chkey   = "pcard"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
		           {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
      &set      = "A"}
end.
else if can-do('N,n,н,Н,т,Т',v-sel) then do:
    {itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите наименование клиента '  update v-name. "
       &where   = " pccards.sname begins v-name and pccards.sts = 'ok' "
       &frame   = "row 5 centered scroll 1 25 down width 87 overlay "
       &flddisp = "'' pccards.aaa label '№ счета' pccards.sname label 'ФИО' pccards.iin label 'ИИН' pccards.pcard label '№ карты'  format 'x(16)' "
       &chkey   = "pcard"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
        		   {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
       &set     = "N"}
end.
else if can-do('B,b,И,и',v-sel) then do:
{itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите ИИН ' update v-bin. "
       &where   = " pccards.iin = v-bin and pccards.sts = 'ok' "
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pccards.aaa label '№ счета' pccards.sname label 'ФИО' pccards.iin label 'ИИН' pccards.pcard label '№ карты'  format 'x(16)' "
       &chkey   = "pcard"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
		          {imesg.i 9205}.
		          pause 1.
		          next.
		          end."
       &set     = "B"}
end.