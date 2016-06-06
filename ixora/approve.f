/* sklads2.f
 * MODULE
        Склад
 * DESCRIPTION
        Для sklad.p
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
        12/10/04 sasco добавил вывод subamt, subcost в форме текущего склада и остатков на дату
        07.09.05 nataly замена skaldb -> item, sklada -> grp (скопировано с sklads.f)
        23/02/06 nataly увеличила размерность 
        05/04/06 nataly увеличила размерность 
	12/05/06 u00121 добавил индексы во временные таблицы b-orders и b-orders2
*/


define new shared var v-sid like item.grp.
define new shared var v-pid like item.item.
define new shared var v-des as char init "".

define variable subamt as integer no-undo.
define variable subcost as decimal no-undo.

define var can-exit as logical no-undo.
define var v-param as char no-undo.
define var v-del as char init "^" no-undo.
define var v-doc as char no-undo.
define var v-dpr like skladh.dpr no-undo.
define var v-amt like skladh.amt no-undo.
define new shared var s-jh like jh.jh.
define var rcode as integer no-undo.
define var rdes as char no-undo.
define var yesno as logical no-undo.
define var totamt as integer init 0 no-undo.
define var totcost as decimal init 0.0 no-undo.


define temp-table b-orders no-undo 
           field nmpl as integer
           field dep as char
           field who as char
           field whn as date
           field sta as char
	index idx1 nmpl whn
	index idx2 sta nmpl.


define temp-table b-orders2  no-undo
           field nmpl as integer
           field dep as char
           field who as char
           field whn as date
           field sta as char
	index idx1 sta nmpl.



/*define frame fc bc help "Используйте стрелки для передвижения. F4 - Конец"
       skip (1) "По группе:"   totamt  format "zzzzzzzzzzzzzzzzz" view-as text
                "       По товару:" subamt  format "zzzzzzzzzzzzzzzzz" view-as text
       skip     "стоимость:"   totcost format "zz,zzz,zzz,zz9.99" view-as text
                "       стоимость:" subcost format "zz,zzz,zzz,zz9.99" view-as text
 with row 2 no-label title
" Наименование             Количество          Цена     Стоимость   ДатаПр ".

  */
/*------------------------------------------------------------------------*/



define button byes label "ПРОВОДКА".
define button byes2 label "Добавить товар".
define button bretry label "ИЗМЕНИТЬ".
       
define var cost like skladh.cost no-undo.
define var gra1 as integer no-undo.
define var gra2 as integer no-undo.
define var grc1 as decimal no-undo.
define var grc2 as decimal no-undo.
define var grdx as decimal no-undo.
define var grd1 as decimal format ">>>>>>>9.9999" no-undo.
define var grd2 as decimal no-undo.
define var grstr as char no-undo.

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

DEFINE FRAME getsid2 "Введите номер группы" v-sid 
       with no-label row 9 centered.


define temp-table tb
       field gl like gl.gl
       field amt like jl.dam
       field arp like arp.arp.


define temp-table wcur3
       field sdes like item.des column-label "ГРУППА"
       field sid  like item.grp column-label "SID"
       field pid  like item.item column-label "PID"
       field pdes like item.des column-label "ТОВАР"
       index iid sdes pdes.

define query qa for grp.
define query qa1 for grp.
define query qb for item.
define query qb1 for wcur3.
define query qt for skladt.


define buffer st_buf for skladt.
define buffer st_bufp for skladp.
define var st_amt as decimal format "z,zzz,zzz,zz9".
define var st_sum as decimal format "z,zzz,zzz,zz9.99".
define var st_amt1 as decimal format "z,zzz,zzz,zz9".
define var st_sum1 as decimal format "z,zzz,zzz,zz9.99".

define frame getlist
            v-sid      format "zz9"     label "Гр" 
            v-pid      format "zzz9"    label "Товар" 
            skladz.des format "x(25)"   label "Наим-ие"
            skladz.zakaz format "zzzzzz9.99" label "Заказать"
            with row 2 centered side-labels.

/*авторизованные/На обработке*/
define query qp for b-orders.
define browse bp query qp
       display
               b-orders.nmpl  label "Номер" format "zzzz9"
               b-orders.whn  label "Дата создания"  format "99/99/9999"
               b-orders.dep   label "Департамент"  format "x(38)"
               b-orders.sta  label "Статус"        format "x(15)"
       with 9 down /* size 80 by 9 */ no-label title "Авторизованные".

/*На исполнении*/
define query qis for b-orders2.
define browse bis query qis
       display
               b-orders2.nmpl   label "Номер" format "zzzz9"
               b-orders2.whn  label "Дата создания"  format "99/99/9999"
               b-orders2.dep   label "Департамент"  format "x(38)"
               b-orders2.sta  label "Статус"        format "x(15)"
       with 9 down /* size 80 by 9 */ no-label title "На исполнении".

define query qc for skladz.
define browse bc query qc
              displ
                 skladz.sid format "zz9"     label "Гр"
                 skladz.pid format "zzz9"    label "Тов"
                 skladz.des format "x(21)"   label "Наим-ие"
                 skladz.amt format "zzzzz9.99" label "Лимит"
                 skladz.zakaz format "zzzzz9.99" label "Заказано"
                 skladz.rem format "x(20)" label "Причина"
                 with centered no-label row 2 13 down no-box.


define frame ft bc
help " Используйте стрелки для передв,[ENTER]-Изменить заказ,F4-Конец "
       with row 2 centered no-box. 

define frame ftp bp
help "  F2 - акцепт , F4 - конец"
       with row 2 centered no-box. 


define frame ftpis bis
help "  F2 - акцепт , F4 - конец"
       with row 2 centered no-box. 

define var dfrom as date init today.
define var dto as date init today.

form 
             "Период: с" dfrom 
             validate (dfrom <= today, 
                       "Начало периода не может быть больше, чем сегодня!")
             " по" dto
             validate (dfrom <= dto, 
                      "Конец периода не может быть раньше его начала!")
             with no-label centered row 7 frame fdat.

