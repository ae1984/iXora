/* tltrxadm.p
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

/* tltrxz.p
   Sushinin Vladimir

*/

def var i as int.
for each tltrxg exclusive-lock :
    delete tltrxg.
end.

m1: repeat :
repeat :
    find first tltrxw  no-lock no-error.
    if available tltrxw then leave.
    display "Нет запросов ... ,   F4 - Выход " with frame a
    row 12 no-label centered.
    pause 120.
end.

hide frame a.
if keyfunction(lastkey) = "End-Error" then leave m1.
do transaction:

	for each tltrxw exclusive-lock :
	find tltrxg where tltrxg.ofc = tltrxw.ofc no-lock no-error.
	if not available tltrxg then do:
	    create tltrxg.
	    tltrxg.ofc = tltrxw.ofc.
	    delete tltrxw.
	end.
	else
	    delete tltrxw.
	end.
end.

i = 0.
for each tltrxg no-lock:
    display tltrxg.ofc tltrxg.sts0.
    pause 0.
    i = i + 1.
end.
    display i with frame ia no-label  row 1 column 60.
    pause 0.

	run tltrxnew.


end.
