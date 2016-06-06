/* ipacpt2.p
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
        BANK COMM IB
 * AUTHOR
        08.09.2004 tsoy
 * CHANGES
*/

define shared variable g-ofc as char.
define shared variable ib-brnch as char.

define variable i as int.
define variable s as char.
define variable blval as char. /* To show in the frame */

define button bt-stbl label  "Блокировать" .
define button bt-rmbl label  "Разблокировать" .

define button bt-exit label "Выход".

define frame ibblock
    usr.id format ">>>>>>9" label "IО клиент " view-as text   skip
    blval  format "x(13)"   label "Статус    " view-as text   skip (1)
    bt-exit  bt-rmbl bt-stbl skip
    with side-labels row 7 centered.


on "choose" of bt-stbl do:
        
        create ib.hist.
        assign
            usr.perm[3] = 2
            ib.hist.type1 = 2
            ib.hist.type2 = 11
            ib.hist.procname = "IB_Platon_Menu"
            ib.hist.ip_addr = "platon"
            ib.hist.ip_name = g-ofc
            ib.hist.idusraff = usr.id
            blval = "блокирован" .
        release ib.hist.
        display usr.id blval with frame ibblock.
end.

on "choose" of bt-rmbl do:
        create ib.hist.
        assign
            usr.perm[3] = 0
            ib.hist.type1 = 2
            ib.hist.type2 = 12
            ib.hist.procname = "IB_Platon_Menu"
            ib.hist.ip_addr = "platon"
            ib.hist.ip_name = g-ofc
            ib.hist.idusraff = usr.id
            blval = "не блокирован" /* label */
        .
        release ib.hist.
        display usr.id blval with frame ibblock.
end.

do transaction:

repeat :
        i = 0.
        update i label "Код клиента Интернет Офиса:"
            format ">>>>>>9" with side-labels row 1 no-error.
        find usr where usr.id = i no-lock no-error.
        if not available usr then do:
                message "Нет клиента с таким номером.".
        end. else if usr.bnkplc <> ib-brnch then do:
                message "Пользователь не в Вашем филиале.".
        end. else if usr.perm[6] = 1 then do:
                message "Договор закрыт.".
        end. else leave.
        pause 10.
        return.
end.
if error-status:error then return. 
if usr.perm[3] = 0 then blval = "не блокирован". else blval = "блокирован" .

display usr.id blval with frame ibblock.
find current usr exclusive-lock.
enable all with frame ibblock.
wait-for "choose" of bt-exit.

end. /* transaction */