/* s-secchs.f
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

define  shared variable s-lon    like lon.lon.
define  shared variable m-ln     like lonsec1.ln extent 25.
define variable i as integer.
define variable m1 as character init "У кредита нет обеспечения".
define variable j as integer.
define variable r1 as character format "x(60)".
define variable r2 as character format "x(60)".
define variable atzime as character init "".

form r1             label 'Предмет залога  '
      help   "F4-выход; вверх/вниз-поиск; Enter-выбор; F1-далее"
     r2             label 'Место нахождения'
     lonsec1.novert label 'Оценка..........'
     lonsec1.proc   label '% ценности......'
     lonsec1.secamt label 'Сумма ценности..'
     lonsec1.apdr   label 'Обеспечение.....'
     atzime         label 'Отметка.........'
     with row 7 side-labels 1 columns overlay title "Выбор залога "
     + s-lon frame ln.
