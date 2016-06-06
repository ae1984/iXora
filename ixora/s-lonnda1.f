/* s-lonnda1.f
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*----------------------------------
  #3.NodroЅin–juma p–rvёrtёЅana
---------------------------------*/
define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable s-dt     as date.

define new shared variable m-ln as integer init 1.
define new shared variable grp as integer init 1.

define variable s1    like lon.opnamt.
define variable s2    as decimal format "zz9.99".
define variable s3    as decimal format "zz9.99".
define variable s4    like lon.opnamt.
define variable v-dt  as date.
define variable kurss as decimal decimals 6.
define variable v-atl as decimal.
define variable ja-ne as logical.

define temp-table w-sec
       field    lonsec   like lonsec1.lonsec
       field    ln       like lonsec1.ln
       field    des      as character
       field    secamt0  as decimal
       field    secamt   as decimal
       field    secamt1  as decimal
       field    pietiek  as logical
       field    pietiek1 as logical
       field    kurss    as decimal decimals 6
       field    chdt     as date
       field    who      as character
       field    whn      as date.

form
    w-sec.lonsec                           label "Код"
    w-sec.des      format "x(25)"          label "Название"
    w-sec.secamt0  format ">>,>>>,>>9.99"  label "Нач.сумма  ном"
    w-sec.secamt   format ">>,>>>,>>9.99"  label "Факт.сумма ном"
    w-sec.pietiek                          label "Обесп."
    with 6 down row 7 column 15 overlay scroll 1
    title "Изменение обеспечения " + s-lon frame sec1.

form
    s4         label "Нач.сумма  ном"
    s1         label "Факт.сумма ном"
    s2         label "Факт. %"
    w-sec.who  label "Исполн."
    w-sec.whn  label "Дата"
    with row 17 column 10 overlay title "Остаток по кредиту (ном.)" +
    string(v-atl,"zzz,zzz,zzz,zz9.99")
    + " " + s-lon frame br.
