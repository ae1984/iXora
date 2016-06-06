/* help-sklad.f
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

define frame hsid 
    sklada.sid at 6 no-label
    sklada.des no-label
    with title "Выберите из списка, F4 - отмена"
    side-labels centered row 2 overlay 17 down.

define frame hpid
    skladb.pid at 6 no-label
    skladb.des no-label
    with title "Выберите из списка, F4 - отмена" 
    side-labels centered row 2 overlay 17 down.

define frame hgl
    gl.gl
    gl.des 
    gl.subled
    gl.level format 'z9'
    with title "Выберите из списка, F4 - отмена" 
    row 5 centered scroll 1 12 down overlay.

define frame harp
    arp.arp
    arp.des
    with title "Выберите из списка, F4 - отмена"
    row 5 centered scroll 1 12 down overlay.
