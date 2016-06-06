/* pksms.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Рассылка СМС-сообщений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-3-12
 * AUTHOR
        09/11/06 Natalya D.
 * CHANGES
        02/02/07 Natalya D. - добавлено "SMS - новости"
        26/08/2009 madiyar - убрал новости
        17/09/2009 madiyar - добавил инфо по пакету
*/

def var v-select as integer no-undo.

repeat:
    v-select = 0.
    run sel2 (" ВЫБОР ", " 1. SMS - Напоминание | 2. SMS - Уведомление | 3. Информация по пакету СМС | 4. ВЫХОД ", output v-select).

    if v-select = 0 then return.

    case v-select:
        when 1 then run pksendsms1.
        when 2 then run pksendsms2.
        when 3 then run pksmsinf.
        when 4 then return.
    end.
end.
