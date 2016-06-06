/* budlist.p
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
 * BASES
	BANK COMM

 * AUTHOR
        14/07/2012 Luiza
 * CHANGES
*/


def var v-check as int.
repeat:
    run sel2 ("Выбор данных :", " 1. По департаменту | 2. По контролирующему подразделению | 3. Выход ", output v-check).
    if keyfunction (lastkey) = "end-error" then return.
    if (v-check < 1) or (v-check > 2) then return.
    if v-check = 1 then run budlist2.
    else run budlist3.
end.
