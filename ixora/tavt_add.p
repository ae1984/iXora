/*  tavt_add.p
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
        02.11.2004 saltanat
 * CHANGES
        28.04.05 saltanat - упростила прцедуру tarifexhis_update.
                            при удалении услуги предусмотрела удаление тарифов и льгот по тарифам.
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
                              добалена возможность просмотра полной истории
*/

def shared var v-stat as char.

{global.i}
{yes-no.i}

def var i as char format 'x(3)' init ''. 
def buffer ftarif for tarif.
def var v-nr as int.
def var v-num as char.

find first tarif where tarif.stat = v-stat no-lock no-error.
if avail tarif then do:

{apbra.i 

&start     = " "
&head      = "tarif"
&headkey   = "tarif"
&index     = "nr"

&formname  = "tarif"
&framename = "tarif"
&where     = "tarif.stat = v-stat and (if i <> '' then tarif.num begins i else true) "

&addcon    = "false"
&deletecon = "false"



&precreate = " "

&postadd   = " "
&prechoose = 
 " message ' F4-выход, TAB-выбор, H-история, F-поиск, A-Акцепт'."
&predisplay = " "

&display   = " tarif.num
               tarif.nr
               tarif.pakalp "

&highlight = " tarif.num tarif.nr tarif.pakalp "


&postkey   = "else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave: 
               hide all.
               run tavt2_add. 
             end.
             else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
               /*displ tarif.who label 'Внес.' 
                     tarif.whn label 'Дата вн.' 
               with overlay centered row 8 title 'История' frame df.               
               hide frame df.*/
               run proc_his. 
             end. 
             else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                 run proc_find.
 	         clin = 0. blin = 0.
	         next upper.
                 hide frame fri.
             end. 
             else if keyfunction(lastkey) = 'A' then do on endkey undo, leave:
                 assign v-nr = tarif.nr v-num = tarif.num.
                 find last tarif where tarif.nr = v-nr and tarif.num = v-num  
                          and tarif.stat = 'r' exclusive-lock no-error.
                 if avail tarif then delete tarif.
                 release tarif. 
                 run proc_akcept.
                 find first tarif where tarif.stat = v-stat no-lock no-error.
                 if not avail tarif then  do:
                                          if yes-no('',' Больше нет данных для акцепта. Перейти на начало? ') then do:
                                             hide message.
                                             hide all.
                                             run tar_avt.
                                          end.
                                          else hide message.
                 end.
                                             
 	         clin = 0. blin = 0.
	         next upper.
                 hide frame fri.
             end. 
            "

&end = "hide frame tarif."
}
hide message.

end.
else do:
if yes-no('',' Нет данных. Продолжить просмотр след. раздела? ') then do:
   run tavt2_add.
end.
end.
   
/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер группы:'.
if i <> '' then do:
   find first ftarif where ftarif.num begins i and ftarif.stat = 'r' no-lock no-error.
   if not avail ftarif then do:
     i = ''.
     message ('Такого номера здесь нет ! ').
   end.
end. /* if */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- AKCEPT --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_akcept.

if yes-no('',' Вы действительно хотите акцептовать запись? ') then do:
   /*find current tarif exclusive-lock no-error.*/
   find last tarif where tarif.stat = v-stat and tarif.nr = v-nr and tarif.num = v-num
                      exclusive-lock no-error.
   if avail tarif then do:
   tarif.akswho = g-ofc.
   tarif.akswhn = g-today.
   tarif.awtim  = time.
   if v-stat = 'd' then tarif.stat = 'a'. 
   else tarif.stat = 'r'.
   run tarifhis_update.
   find current tarif no-lock no-error.
   if tarif.stat = 'a' then run tarif2_del.
   end.
   else message (' Акцептуемой записи нет ! ').
end.
release tarif.
end procedure.

/* удаление привязанных к услуге тарифов */
procedure tarif2_del.
	for each tarif2 where tarif2.num = tarif.num and tarif2.nr1 = tarif.nr and tarif2.stat <> 'a' exclusive-lock:
	    tarif2.stat = 'a'.
		tarif2.delwho = g-ofc.
		tarif2.delwhn = g-today.
 		tarif2.dwtim  = time.
	    tarif2.akswho = g-ofc.
 		tarif2.akswhn = g-today.
 		tarif2.awtim  = time.
 		run tarif2his_update.
	    run tarifex_del.
	end.
	release tarif2.
end procedure.

/* удаление привязанных к тарифу льгот */
procedure tarifex_del.
	for each tarifex where tarifex.str5 = tarif2.str5 and tarifex.stat ne 'a' and tarifex.stat ne 'h' exclusive-lock:
	    tarifex.stat = 'a'.
 		tarifex.delwho = g-ofc.
 		tarifex.delwhn = g-today.
 		tarifex.dwtim  = time.
 		tarifex.akswho = g-ofc.
 		tarifex.akswhn = g-today.
 		tarifex.awtim  = time.	    
 		run tarifexhis_update.
	end.
	release tarifex.	
end procedure.

procedure proc_his.

    displ tarif.who    column-label 'Внес.'      
          tarif.whn    column-label 'Дата вн.'
          tarif.akswho column-label 'Акцепт.'    
          tarif.akswhn column-label 'Дата акц.' 
    with overlay centered row 8 title 'История' frame ff.

hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

output to vcdata.csv .
displ 'История' skip(1).
  put unformatted 'Nr'          ';'
	          'Nr'          ';'
	          'Услуга'      ';'
	          'Внес.'       ';'
	          'Дата вн.'    ';'
	          'Время вн.'   ';'
	          'Акцепт.'     ';'
	          'Дата акц.'   ';'
                  'Время акц.'  ';'
	          'Удалил'      ';'
	          'Дата удал.'  ';'
                  'Время удал.' ';' 
                  'Статус'      skip.

for each tarifhis where tarifhis.num = tarif.num and tarifhis.nr = tarif.nr no-lock by tarifhis.whn by tarifhis.wtim:
  put unformatted tarifhis.num    ';'
	          tarifhis.nr     ';'
	          tarifhis.pakalp ';'
	          tarifhis.who    ';'
	          if tarifhis.whn <> ? then string(tarifhis.whn) else '' ';'
                  if tarifhis.wtim = 0 then '' else string(tarifhis.wtim , 'hh:mm:ss') ';'
	          tarifhis.akswho ';'
	          if tarifhis.akswhn <> ? then string(tarifhis.akswhn) else '' ';'
                  if tarifhis.awtim = 0 then '' else string(tarifhis.awtim, 'hh:mm:ss') ';'
	          tarifhis.delwho ';'
	          if tarifhis.delwhn <> ? then string(tarifhis.delwhn) else '' ';'
                  if tarifhis.dwtim = 0 then '' else string(tarifhis.dwtim, 'hh:mm:ss') ';'
                  tarifhis.stat skip.
end.
output close.
unix silent cptwin vcdata.csv excel.
end. /* yes-no*/

end procedure.

/* ---- процедура сохранения истории услуг ---- */
procedure tarifhis_update.
	create tarifhis.
	buffer-copy tarif to tarifhis.
end procedure.

/* ---- процедура сохранения истории тарифов ---- */
procedure tarif2his_update.
	create tarif2his.
	buffer-copy tarif2 to tarif2his.
end procedure.

/* ---- процедура сохранения истории льгот ---- */
procedure tarifexhis_update.
	create tarifexhis.
	buffer-copy tarifex to tarifexhis.
end procedure.
