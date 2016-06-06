/* deparp_pmp.i
 * MODULE
        Название Программного Модуля
        Платежная система
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Программа находит транзитный счет для пенсионных ьи социальных отчислений по департаменту
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
        19/01/2005 kanat
 * CHANGES
	22.06.2005 u00121 Если не найдет счет для департамента , выведет сообщение с кодом некорректно заведенного департамента
	07.09.2006 u00121 конкретизировал сообщение
*/

function deparp_pmp returns char (dep as int).
    find first pmpaccnt where pmpaccnt.point = 1 and pmpaccnt.depart = dep no-lock no-error.
    if avail pmpaccnt then
	    return pmpaccnt.accnt.
    else
    do:
	Message "Не найден транзитный счет для пенсионных и социальных отчислений по департаменту " + string(dep) view-as alert-box title "deparp_pmp.i".
	return "".
    end.
end.
