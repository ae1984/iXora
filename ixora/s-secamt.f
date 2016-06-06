/* s-secamt.f
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

define shared variable s-lon    as character.
define shared variable g-today  as date.

define shared variable m-ln as integer init 1.
define variable galv as character extent 10.
define variable gal1 as character.
define variable gal2 as character.
define variable gal3 as character.
define variable gal4 as character.
define variable adr  as character extent 10.
define variable pal  as character extent 2.
define variable i    as integer.
define variable dd   as integer.
define variable mm   as integer.
define variable gg   as integer.
define variable regdt as date.
form
    gal1              label "Обеспечение" format "x(60)"
                             help "Наименование; F1,F4-далее"
    gal2              label "Обеспечение" format "x(60)"
                             help "Продолжение; F1,F4-далее"
    gal3              label "Обеспечение" format "x(60)"
                             help "Продолжение; F1,F4-далее"
    gal4              label "Обеспечение" format "x(60)"
                             help "Продолжение; F1,F4-далее"
    adr[1]            label "Адрес........" format "x(60)"
                             help "Место нахождения; F1,F4-далее"
    lonsec1.novert    label "Оценка..." help "F1,F4-далее" skip
    lonsec1.uno       label "Основание...." help "F2-код;F1,F4-далее"
    lonsec1.proc      label "% ценности....." help "F1,F4-далее"
    lonsec1.secamt    label "Сумма ценности" skip
    lonsec1.apdr      label "Сумма страховки" help "F1,F4-выход"
    galv[2]           label "Обеспечитель  " format "x(60)"
                             help "Наименование; F1,F4-выход"
    galv[3]           label "Адрес........." format "x(60)"
                             help "F1,F4-выход"
    galv[4]           label "Должность....." format "x(30)"
                             help "Должность руководителя; F1,F4-выход"
    galv[5]           label "Имя..........." format "x(30)"
                             help "Имя фамилия руководителя; F1,F4-выход"
    galv[6]           label "Nr паспорта..." format "x(20)"
                             help "Номер серия паспорта; F1,F4-выход"
    galv[7]           label "Перс.код......" format "x(20)" help "F1,F4-выход"
    galv[8]           label "Выдан........." format "x(60)"
                             help "Дата выдачи паспорта; F1,F4-выход"
    galv[9]           label "Прописка......" format "x(60)"
                             help "Прописка по адресу; F1,F4-выход"
    galv[10]          label "Телефон......." format "x(20)" help "F1,F4-выход"
                             skip
    adr[2]            label "Регистр.Nr...." format "x(20)"
    regdt             label "Регистр.дата.." format "99/99/9999"
    with row 2 column 1 2 columns overlay side-label  title
         "Ввод описания обеспечения" frame colla.


/*-----------------------------------------------------------------------------
  #3.
     1.izmai‡a - forma papildin–ta ar klienta re¦istr–cijas apliecЁbas numuru"
       un datumu
     2.izmai‡a - nodroЅin–jumam vair–k vietas
-----------------------------------------------------------------------------*/
