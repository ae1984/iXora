/* s-harchs.f
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
        25/03/2009 galina - добавила поле Поручитель
        23.04.2009 galina - убираем поле поручитель
        
*/

/*---------------------------------------------------------------------------
  #3.MeklёЅana kredЁta aprakst–
---------------------------------------------------------------------------*/
define  shared variable s-lon    like lon.lon.
define  shared variable s-longrp like longrp.longrp.
define  shared variable grp-name as character.
define  shared variable crc-code as character.
define  shared variable cat-des  as character.
define  shared variable v-cif    like cif.cif.
define  shared variable v-lcnt   like loncon.lcnt.
define  shared variable v-vards  like cif.name.
define shared variable s-stat0 as integer.
define shared variable s-stat1 as integer.
define shared variable s-dts1  as date.
define shared variable s-frez0 as decimal.
define shared variable s-frez1 as decimal.
define shared variable s-dtf1  as date.
define shared variable s-kuzk0 as decimal.
define shared variable s-kuzk1 as decimal.
define shared variable s-dtu1  as date.
define shared variable s-sk    as decimal.
define shared variable s-dk    as integer.
define shared variable s-pk    as integer.
define shared variable s-dtk   as date.
define shared variable s-sp    as decimal.
define shared variable s-dp    as integer.
define shared variable s-pp    as integer.
define shared variable s-dtp   as date.
define shared variable s-sec   as decimal.
define shared variable s-prc   as decimal.
define shared variable s-akc   as logical.
define shared variable s-dt    as date.
define shared variable s-atln  as decimal.
define shared variable s-atll  as decimal.
/*galina 25/03/2009
def var v-guarantor as char format "x(50)".*/

define variable dam1-cam1 as decimal.
define variable v-dt      as date.
define variable v-dt1     as date.
define variable r         as character.
define variable r1        as character.
define variable i         as integer.
define variable j         as integer.
define variable k         as integer.

define shared frame lon.

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

form v-vards format "x(60)" with no-label no-hide no-box 
     overlay row 3 column 25 frame cif.

form loncon.lon help
     "F4-выход; вверх/вниз-поиск; F1,Enter-выбор; F3-смена списка"
     with 10 down no-label title "Кредит"
     row 3 scroll 1 frame ln.
