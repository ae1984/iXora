/* h-pcr.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Help - поиск счета ПК для устан.КЛ
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
        16.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def var v-sel   as char              no-undo.
def var v-pcard like pcstaff0.pcard  no-undo.
def var v-name  like pcstaff0.sname  no-undo.
def var v-bin   like pcstaff0.iin    no-undo.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

message "Выберите счет: A)карточка  N)ФИО  B)ИИН" update v-sel.

if can-do('A,а,А,ф,Ф',v-sel) then do:
    {itemlist.i
       &file    = "pcstaff0"
       &start   = "message ' Введите номер карточки '  update v-pcard."
       &where   = "pcstaff0.pcard = v-pcard and pcstaff0.bank = s-ourbank"
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pcstaff0.cif label ' CIF-код' pcstaff0.aaa label ' № счета' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО' pcstaff0.iin label 'ИИН' (substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13)) label '№ карты' format 'x(16)' "
       &chkey   = "cif"
       &chtype  = "string"
       &index   = "iin"
       &funadd  = "if frame-value = "" "" then do:
		           {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
      &set      = "A"}
end.
else if can-do('N,n,н,Н,т,Т',v-sel) then do:
    {itemlist.i
       &file    = "pcstaff0"
       &start   = "message ' Введите наименование клиента '  update v-name. "
       &where   = " pcstaff0.sname begins v-name and pcstaff0.bank = s-ourbank"
       &frame   = "row 5 centered scroll 1 25 down width 87 overlay "
       &flddisp = "'' pcstaff0.cif label ' CIF-код' pcstaff0.aaa label '№ счета' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО' pcstaff0.iin label 'ИИН' (substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13)) label '№ карты' format 'x(16)' "
       &chkey   = "cif"
       &chtype  = "string"
       &index   = "iin"
       &funadd  = "if frame-value = "" "" then do:
        		   {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
       &set     = "N"}
end.
else if can-do('B,b,И,и',v-sel) then do:
{itemlist.i
       &file    = "pcstaff0"
       &start   = "message ' Введите ИИН ' update v-bin. "
       &where   = "pcstaff0.iin = v-bin and pcstaff0.bank = s-ourbank"
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pcstaff0.cif label ' CIF-код' pcstaff0.aaa label '№ счета' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО' pcstaff0.iin label 'ИИН' (substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13)) label '№ карты' format 'x(16)' "
       &chkey   = "cif"
       &chtype  = "string"
       &index   = "iin"
       &funadd  = "if frame-value = "" "" then do:
		          {imesg.i 9205}.
		          pause 1.
		          next.
		          end."
       &set     = "B"}
end.
