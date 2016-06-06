/* a_helppc.p
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
        16/07/2013 id00800
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def var v-bank   as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc! " view-as alert-box.
    return.
end.
v-bank = sysc.chval.


def var v-sel   as char             no-undo.
def var v-pcard like pccards.pcard  no-undo.
def var v-name  like pccards.sname  no-undo.
def var v-rnn   like pccards.rnn    no-undo.
def var v-bin   like pccards.iin    no-undo.

message "Выберите счет: A)карточка  N)ФИО  B)ИИН" update v-sel.

if can-do('A,а,А,ф,Ф',v-sel) then do:
    {itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите номер карточки '  update v-pcard.
                   /*find first pccards where pccards.pcard = v-pcard  and pccards.sts = 'ok' no-lock no-error.
                   if not avail pccards then do: message 'Карточка с номером ' v-pcard ' не найдена или не активна!'. pause 10. return. end."*/
       &where   = " pccards.pcard = v-pcard and pccards.bank = v-bank "
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pccards.aaa label ' № счета' pccards.sname label 'ФИО' pccards.rnn label 'РНН' (substr(pccards.pcard,1,6) + '******' +  substr(pccards.pcard,13)) label '№ карты'  format 'x(16)' "
       &chkey   = "aaa"
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
       &where   = " pccards.sname begins v-name and pccards.sts = 'ok' and pccards.bank = v-bank "
       &frame   = "row 5 centered scroll 1 25 down width 87 overlay "
       &flddisp = "'' pccards.aaa label '№ счета' pccards.sname label 'ФИО' pccards.rnn label 'РНН' (substr(pccards.pcard,1,6) + '******' +  substr(pccards.pcard,13)) label '№ карты'  format 'x(16)' "
       &chkey   = "aaa"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
        		   {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
       &set     = "N"}
end.
/*else if can-do('P,p,П,п,з,З',v-sel) then do:
{itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите РНН ' update v-rnn. "
       &where   = " pccards.rnn = v-rnn and pccards.sts = 'ok' and pccards.bank = v-bank "
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pccards.aaa label '№ счета' pccards.sname label 'ФИО' pccards.rnn label 'РНН' (substr(pccards.pcard,1,6) + '******' +  substr(pccards.pcard,13)) label '№ карты'  format 'x(16)' "
       &chkey   = "aaa"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
		           {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
       &set     = "P"}
end.*/
else if can-do('B,b,И,и',v-sel) then do:
{itemlist.i
       &file    = "pccards"
       &start   = "message ' Введите ИИН ' update v-bin. "
       &where   = " pccards.iin = v-bin and pccards.sts = 'ok' and pccards.bank = v-bank "
       &frame   = "row 5 centered scroll 1 25 down width 86 overlay "
       &flddisp = "' ' pccards.aaa label '№ счета' pccards.sname label 'ФИО' pccards.rnn label 'РНН' (substr(pccards.pcard,1,6) + '******' +  substr(pccards.pcard,13)) label '№ карты'  format 'x(16)' "
       &chkey   = "aaa"
       &chtype  = "string"
       &index   = "pc"
       &funadd  = "if frame-value = "" "" then do:
		          {imesg.i 9205}.
		          pause 1.
		          next.
		          end."
       &set     = "B"}
end.
