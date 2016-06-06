/* signdocum.p
 * MODULE
        Название модуля - Операции.
 * DESCRIPTION
        Описание - Сохранение документов для отображения подписей.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        11.04.2012 damir.
*/

{global.i}

def input parameter v-sub as char.
def input parameter v-acc as char.

do transaction:
    create doccontord.
    assign
    doccontord.sub   = trim(v-sub)
    doccontord.doc   = trim(v-acc)
    doccontord.fname = g-fname
    doccontord.who   = g-ofc
    doccontord.whn   = g-today
    doccontord.tim   = time.
end.

return.