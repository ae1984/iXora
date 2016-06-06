/* astfaged.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Группы основных средств
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.1.6.1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        21/01/04 sasco Исправил update наименования, Г/К, износа.
        09/03/04 sasco Добавил no-error в getprec()
        24/01/2005 marinav Добавилась кнопка для просмотра истории %% ставок по амортизации
        28.01.2005 Перенос срока в карточки 28.01.2005 marinav
*/

{mainhead.i}

define var v-cat as integer. 
define var v-live as logical.

define button btAdd  label 'Добавить'.
define button btDel  label 'Удалить'.
define button btHis  label 'История'.
define button btRpt  label 'Печать'. 
define button btExit label 'Выход'.

FUNCTION getprec returns DECIMAL.

  find first taxcat where taxcat.type = INTEGER(fagn.cont)
                      and taxcat.cat = INTEGER(fagn.ref)
                      and taxcat.active = true 
                          no-lock no-error.
  if avail taxcat then return (taxcat.pc). 
                  else return(?).

END FUNCTION.

define query q_list for fagn FIELDS (fagn.fag fagn.naim fagn.gl fagn.ser fagn.noy fagn.cont fagn.ref).
define browse b_list query q_list
  display 
         fagn.fag  column-label 'Гру!ппа' format '999'
         fagn.naim column-label 'Название'
         fagn.gl   column-label 'Счет!GL'
         fagn.noy  column-label 'Срок!износа'
         fagn.cont column-label 'Кате-!гория'
         fagn.ref  column-label 'Под-!катег.'
         getprec()  column-label 'Процент'
    with title "Список групп" 12 down centered no-row-markers.

define frame f1
       b_list skip btAdd btDel btHis btRpt btExit with no-box centered /*overlay*/.

define frame f_edit
         fagn.fag  column-label 'Гру!ппа' format '999'
         fagn.naim column-label 'Название'
         fagn.gl   column-label 'Счет!GL'
         fagn.noy  column-label 'Срок!износа'
         fagn.cont column-label 'Кате-!гория'
         fagn.ref  column-label 'Под-!катег.'
       with row 4 title "Отредактировать запись" centered.

define query q_type for taxcat FIELDS (taxcat.cat taxcat.name).
define browse b_type query q_type no-lock                       
  display
       taxcat.cat   label 'Номер'
       taxcat.name  label 'Наименование'
       with row 4 no-box 13 down no-row-markers.

define query q_type2 for taxcat FIELDS (taxcat.cat taxcat.name).
define browse b_type2 query q_type2 no-lock                       
  display
       taxcat.cat   label 'Номер'
       taxcat.name  label 'Наименование'
       with no-box 13 down no-row-markers.

define frame f_type
       b_type with row 4 centered title "Выбор категории". 

define frame f_type2
       b_type2 with row 4 centered title "Выбор подкатегории". 

on 'entry' of b_list in frame f1 v-live = true.

on 'return' of b_list in frame f1
do:
   display
         fagn.fag  
         fagn.naim 
         fagn.gl   
         fagn.noy
         fagn.cont 
         fagn.ref  
   with frame f_edit.
   find current fagn exclusive-lock.
   enable fagn.naim with frame f_edit.
/*   disable all.*/
   enable fagn.gl with frame f_edit.
   enable fagn.noy with frame f_edit.

   find current fagn no-lock.
   WAIT-FOR endkey OF frame f_edit or end-error OF frame f_edit focus frame f1.    

   find current fagn exclusive-lock.
   
   fagn.gl = integer (fagn.gl:screen-value).
   fagn.noy = integer (fagn.noy:screen-value).
   fagn.naim = fagn.naim:screen-value.

 /*Перенос срока в карточки 28.01.2005 marinav*/
   
   for each ast where ast.fag = fagn.fag.
     ast.noy = fagn.noy.
   end.

/***/


   find current fagn no-lock.

   view frame f1.
   hide frame f_edit.
end.

on 'return' of fagn.noy in frame f_edit
do:
   open query q_type
   for each taxcat where taxcat.type = 0 and taxcat.active = true.
   enable all with frame f_type.

   WAIT-FOR endkey OF b_type in frame f_type or end-error OF frame f_type focus frame f_edit. 
   if v-live =true then
      do:
         hide frame f_type.
         view frame f_edit.
      end. 
      else apply 'endkey' to frame f_edit.
end.



on 'return' of b_type in frame f_type
do:
/*   find current fagn exclusive-lock.*/
   v-cat = taxcat.cat.
/*   fagn.cont = STRING(taxcat.cat).
   find current fagn no-lock.       */
   open query q_type2 
   for each taxcat where taxcat.type = v-cat and taxcat.active = true.
   enable all with frame f_type2.   
   WAIT-FOR endkey OF b_type2 in frame f_type2 or end-error OF frame f_type2 focus frame f_type.
   if v-live =true then
      do:
         hide frame f_type2.
         view frame f_type.
      end. 
      else apply 'endkey' to b_type in frame f_type.
end.

on 'return' of b_type2 in frame f_type2
do:
   find current fagn exclusive-lock.
   fagn.ref = STRING(taxcat.cat).
   fagn.cont = STRING(v-cat).
   find current fagn no-lock.
   apply 'endkey' to b_type2 in frame f_type2.
   v-live = false.
end.

on choose of btRpt in frame f1
do:
   output to 'rpt.img'.
   for each fagn:
        display 
         fagn.fag  column-label 'Гру!ппа' format '999'
         fagn.naim column-label 'Название'
         fagn.gl   column-label 'Счет!GL'
         fagn.noy  column-label 'Срок!износа'
         fagn.cont column-label 'Кате-!гория'
         fagn.ref  column-label 'Под-!катег.'
         getprec()  column-label 'Процент'.
   end.
   output close.
   run menu-prt('rpt.img').
end.

on choose of btDel in frame f1
do:
   message 'УДАЛИТЬ ЗАПИСЬ???' view-as alert-box buttons yes-no title '' update choice as logical.
   if choice = true then 
      do:
         find first ast where ast.fag = fagn.fag no-lock no-error.
         if not avail ast then 
           do:
              find current fagn exclusive-lock.
              delete fagn.
              b_list:refresh().
           end.
         else message 'Еще есть карточки с такой группой!!!' view-as alert-box.
      end.
end.

on choose of btHis in frame f1
do:
   {itemlist.i &file = "taxcathis"
       &where = "taxcathis.type = inte(fagn.cont) and taxcathis.cat = inte(fagn.ref) "
       &frame = "row 5 centered scroll 1 12 down overlay "
       &flddisp = "taxcathis.type   label 'Катег'
                   taxcathis.cat    label 'Подкат' 
                   taxcathis.dtform label 'Дата'
		   taxcathis.pc     label 'Ставка'
		   taxcathis.rdt    label 'Изменен'
		   taxcathis.who    label 'Кем'"
       &chkey = "type"
       &chtype = "integer"
       &index  = "typecat"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		  end." }

end.

on choose of btAdd in frame f1
do:
   create fagn.
   update "Номер группы :" fagn.fag format 'x(3)' no-label skip
          "Наименование :" fagn.naim no-label.
   fagn.who = g-ofc.
   fagn.whn = g-today.
   close query q_list.
   open query q_list 
        for each fagn share-lock.
end.


open query q_list 
     for each fagn share-lock.

view frame mainhead. pause 0.
enable all with frame f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or CHOOSE of btExit.

readkey pause 0.
apply lastkey.
