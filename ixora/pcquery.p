/* pcquery.p
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
        01.04.2013 Lyubov
 * CHANGES

*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def var v-select  as inte no-undo.

def var v-ofc as char.
def var v-mid as char.

find first sysc where sysc.sysc = 'pcacpt' no-lock no-error.
if not avail sysc then do:
    message 'Не найден список менеджеров ОО. Обратитесь в ДИТ' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-ofc = sysc.chval.
find first sysc where sysc.sysc = 'pcmidl' no-lock no-error.
if not avail sysc then do:
    message 'Не найден список сотрудников МИДЛ-ОФИСА. Обратитесь в ДИТ.' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-mid = sysc.chval.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = s-credtype and pkanketa.aaa = v-aaa no-lock no-error.
if avail pkanketa and pkanketa.summa > 0 then do:
    run sel2 ("Выберите :", " 1. ГЦВП | 2. КБ | 3. Кредитная история БВУ | 4. Выход ", output v-select).
    case v-select:
        when 1 then do:
            if can-do (v-ofc,g-ofc) then run pcgcvp.
            else message " Нет доступа к меню 'ГЦВП'! " view-as alert-box.
        end.
        when 2 then do:
            run cs_reguest1cbreport.
        end.
        when 3 then do:
            if can-do (v-mid,g-ofc) then run cs_cb.
            else message " Нет доступа к меню 'Кредитная история БВУ'! " view-as alert-box.
        end.
        when 4 then return.
    end.
end.
else message ' Не установлен кредитный лимит! ' view-as alert-box.