/* r-clmax.p
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

def new shared var v-dat as date.
v-dat = today.
update v-dat label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .

unix silent value ("echo > rpt.img").

run comm-con.
run r-clmax1 (input v-dat).
run menu-prt( 'rpt.img' ).
