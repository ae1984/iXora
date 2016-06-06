/* expquery.p
 * MODULE
        экспресс кредиты по ПК
 * DESCRIPTION
        отчеты из 1КБ и ГЦВП
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
        11/11/2013 Luiza ТЗ 1831
 * CHANGES
            13/11/2013 Luiza ТЗ 2197 рефинансирование по нескольким кредитам
*/

{global.i}

def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-bank     as char no-undo.
def var v-select  as inte no-undo.

def var v-ofc as char.
def var v-mid as char.

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
if not avail codfr then do:
    message 'Не найден список менеджеров ОО. Обратитесь в ДИТ' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-ofc = codfr.name[1].

find first pkanketa where pkanketa.bank = v-bank  and pkanketa.cif = v-cifcod and pkanketa.credtype = "10" and pkanketa.ln = s-ln no-lock no-error.
if avail pkanketa then do:
    if pkanketa.sts = '111' then do:
        message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
        return.
    end.
    run sel2 ("Выберите :", " 1. ГЦВП | 2. КБ | 3. Выход ", output v-select).
    case v-select:
        when 1 then do:
            if can-do (v-ofc,g-ofc) then run expgcvp.
            else message " Нет доступа к меню 'ГЦВП'! " view-as alert-box.
        end.
        when 2 then do:
            if can-do (v-ofc,g-ofc) then run cs_cb1.
            else message " Нет доступа к меню 'КБ'! " view-as alert-box.
        end.
        when 3 then return.
    end.
end.
else message 'Анкета не найдена!'  view-as alert-box.