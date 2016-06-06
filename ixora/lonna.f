/* lonna.f
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
        31/05/2006 madiyar - увеличил размерность в формате вывода сумм
        11.12.2008 galina - увеличила размер фрейма lon и подвинула его вправо; подвинула вправо cif
        15/12/2008 galina - явно указала ширину фрема cif
        25/03/2009 galina - добавила поле Поручитель
        23.04.2009 galina - убираем поле поручитель
*/

define variable dam1-cam1 as decimal no-undo.
/*galina 25/03/2009
def var v-guarantor as char format "x(50)".*/
form
    v-cif label "Клиент......"  loncon.lon at 46  label "Кредит......"  skip
    v-lcnt label "Договор....." s-dt at 46 label "Состояние на"  skip
    s-longrp label "Группа......" v-uno at 46  label "Тип........."   skip
    lon.crc label "Валюта......"  crc-code no-label  format "x(3)"  loncon.objekts at 46 label "Объект......" skip
    ln%his.rdt label "С..........." ln%his.duedt at 46 label "По.........."  skip
    ln%his.opnamt label "Сумма......."  format ">,>>>,>>>,>>9.99" 
    dam1-cam1 at 46  label  "Остаток....." format ">,>>>,>>>,>>9.99" skip
    ln%his.intrate label "% ставка...." lon.lcr at 46  label "Отрасль....."  skip
    /*v-guarantor label "Поручитель" skip(2)*/
    "                          Ценность   Дата" skip
    s-stat0 label "Статус......"  format "zzzzzzzzzzzzz9"
            s-dts1 no-label    format "99/99/9999" skip
    s-frez0 label "Финанс.рез. "  format "->>>,>>>,>>>,>>9.99"
               s-dtf1 no-label  format "99/99/9999" skip
    s-kuzk0 label "Накопления.."  format ">>>,>>>,>>>,>>9.99"
            s-dtu1 no-label  format "99/99/9999" skip(2)
    "                     П р о с р о ч к а     Продление" skip
    s-sk label "Кредит......"  format ">>>,>>>,>>>,>>9.99"
                   s-dk no-label  format "zzzzz9" 
                   s-dtk no-label 
                   s-pk no-label format "zzz9" skip
    s-sp label "Проценты...."  format "->>>,>>>,>>>,>>9.99"
                   s-dp no-label format "zzzzz9" 
                   s-dtp no-label 
                   s-pp no-label format "zzz9" skip
    s-sec label "..Обеспечен."  format ">>>,>>>,>>>,>>9.99"
    s-prc no-label format ">>,>>9.99"
    s-akc label "%    Акц." 
    with side-label no-hide column 25 no-box width 110 row 4 /*title "Описание кредита"*/
    frame lon.

form v-vards format "x(60)" with width 65 no-label no-hide no-box 
     overlay row 3 column 25 frame cif.


define variable m1 as character init "Дата регистр.".
define variable m2 as character init "Срок".
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
/*----------------------------------------------------------------------------
  #3.KredЁta aprakst–
-----------------------------------------------------------------------------*/
