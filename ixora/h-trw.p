/* h-trw.p
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

/* h-trw.p
* Модуль: 
            Клиенты и их счета
Назначение: 
            Выбор категории клиента
Вызывается: 
            по F2 через applhelp
            1.2 кнопка "Катег"
Пункты меню: 
            1.2
Автор: 
            sasco
Дата создания:
            31.07.2003
Протокол изменений:
*/

def shared var g-lang as char.

{itemlist.i   &start = " "
              &file = "codfr"
              &where = " codfr.codfr = 'cifkat' "
              &frame = "row 3 centered scroll 1 15 down overlay
                        title ' Категории клиентов ' "
              &flddisp = " codfr.code format 'x(2)' label 'ID' 
                           codfr.name[1] format 'x(15)' label 'Категория' 
                         "
              &chkey = "code"
              &chtype = "string"
              &index  = "cdco_idx"
              &funadd = "if frame-value = "" "" and (available codfr and codfr.name[1] = '') then
                             do:
                                {imesg.i 9205}.
                                pause 1.
                                next.
                             end."
}


