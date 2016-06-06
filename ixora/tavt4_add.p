/*  tavt4_add.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        tar2_aex.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1-2-6-3 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
                              добалена возможность просмотра полной истории
*/
{global.i}
{yes-no.i}

def shared var v-stat as char.
def var i as char format 'x(6)' init ''. 
def buffer b-tarifex2 for tarifex2.
def buffer ftarifex2 for tarifex2.
def var v-cif like tarifex2.cif.
def var v-aaa like tarifex2.aaa.
def var v-str5 like tarifex2.str5.

find first tarifex2 where tarifex2.stat = v-stat no-lock no-error.

if avail tarifex2 then do:
{apbra.i 

&start     = " "
&head      = "tarifex2"
&headkey   = "tarifex2"
&index     = "id-aaasts"

&formname  = "tarifex2add"
&framename = "tarifex2"
&where     = "(if i <> '' then tarifex2.aaa begins i else true) and tarifex2.stat = v-stat "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " " 

&prechoose = "message ' F4-выход, P-печать, H-история, F-поиск, A-Акцепт'."

&predisplay = " find first tarif2 where tarif2.str5 = tarifex2.str5 no-lock no-error. "
&display   = " tarifex2.str5 
               tarif2.punkt 
               tarifex2.aaa
               tarifex2.cif
               tarifex2.kont
               tarifex2.pakalp
               tarifex2.crc column-label 'Вал'
               tarifex2.ost
               tarifex2.proc
               tarifex2.min1
               tarifex2.max1
               tarifex2.nsost 
               substr(tarifex2.who, 1, 1) @ v-am "

&highlight = " tarifex2.cif tarifex2.kont tarifex2.pakalp "

&postkey   = " else if keyfunction(lastkey) = 'P' then do:
                 output to tar2ex2.img .
                 for each b-tarifex2 :
                   display 
                       b-tarifex2.aaa label 'Счет кл.'
                       b-tarifex2.cif label 'Клиент'
                       b-tarifex2.kont column-label 'Счет '
                       b-tarifex2.pakalp format 'x(26)'
                        column-label 'Услуга'
                       b-tarifex2.crc column-label 'Вал'
                       b-tarifex2.ost  column-label 'Сумма'
                       b-tarifex2.proc column-label '  %  '
                       b-tarifex2.min1   format 'zz9.99' column-label ' Мин '
                       b-tarifex2.max1  format 'zz9.99' column-label ' Макс'
                       b-tarifex2.nsost label 'Несниж.ост.'
                        with overlay column 1 row 7 11 down frame uuu.
                 end.
               hide frame uuu.
               output close.
               output to terminal.
               unix prit tar2ex2.img.
             end. 
             else if keyfunction(lastkey) = 'NEW-LINE' then do :
               run tavt4_add.
             end .

             else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
             /*displ tarifex2.who column-label 'Внес'
                   tarifex2.whn column-label 'Дата вн.'
             with overlay centered row 10 title 'История' frame df.
             hide frame df. */
               run proc_his.
             end. 

            else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                 run proc_find.
                 hide frame fri.
 	         clin = 0. blin = 0.
	         next upper.
            end. 

            else if keyfunction(lastkey) = 'A' then do on endkey undo, leave:
                 assign v-str5 = tarifex2.str5 v-cif = tarifex2.cif v-aaa = tarifex2.aaa.
                 find last tarifex2 where tarifex2.str5 = v-str5 and tarifex2.cif = v-cif   
                          and tarifex2.aaa = v-aaa   
                          and tarifex2.stat = 'r' exclusive-lock no-error.
                 if avail tarifex2 then delete tarifex2.
                 release tarifex2. 
                 run proc_akcept.
                 hide frame fri.
                 find first tarifex2 where tarifex2.stat = v-stat no-lock no-error.
                 if not avail tarifex2 then do: if yes-no('',' Больше нет данных для акцепта. Перейти на начало? ') then do:
                                                  hide message.
                                                  hide all.
                                                  run tar_avt.
                                               end.
                                               else hide message.
                 end.
 	         clin = 0. blin = 0.
	         next upper.
            end. 

 "

&end = "hide frame tarifex2."
}
hide message.
end.
else do:
if yes-no('',' Нет данных. Переитти на начало? ') then do:
   run tar_avt.
end.
end.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i format 'x(9)' no-label
with frame fri with overlay centered row 10 title 'Введите номер счета клиента:'.
if i <> '' then do:
   find first ftarifex2 where ftarifex2.aaa begins i and tarifex2.stat = v-stat no-lock no-error.
   if not avail ftarifex2 then do:
     i = ''.
     message ('Такого счета клиента здесь нет ! ').
   end.
end. /* if */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- Akcept --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_akcept.
if yes-no('',' Вы действительно хотите акцептовать запись? ') then do:
   /*find current tarifex2 exclusive-lock no-error.*/
   find last tarifex2 where tarifex2.stat = v-stat and tarifex2.str5 = v-str5 and tarifex2.cif = v-cif 
                       and tarifex2.aaa = v-aaa
                      exclusive-lock no-error.   
   if avail tarifex2 then do:
      tarifex2.akswho = g-ofc.
      tarifex2.akswhn = g-today.
      tarifex2.awtim  = time.
      if v-stat = 'd' then tarifex2.stat = 'a'. 
      else tarifex2.stat = 'r'.
      run tarifex2his_update.
      find current tarifex2 no-lock no-error.
   end.  
   else message (' Акцептуемой записи нет ! ').
end.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
    displ tarifex2.who    column-label 'Внес.'         
          tarifex2.whn    column-label 'Дата вн.'
          tarifex2.akswho column-label 'Акцепт.'       
          tarifex2.akswhn column-label 'Дата акц.' 
    with overlay centered row 10 title 'История' frame ff.

hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

output to vcdata.csv .
displ 'История' skip(1).
  put unformatted 'Счет'    ';'
              'Клиент'      ';'
	          'Счет Гл.Кн.'        ';' 
	          'Услуга'      ';'
	          'Вал'         ';'
	          'Сумма'       ';'
	          '%'           ';'
	          'Мин'         ';'
	          'Макс'        ';'
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

for each tarifex2his where tarifex2his.aaa = tarifex2.aaa and 
                           tarifex2his.cif = tarifex2.cif and 
                           tarifex2his.str5 = tarifex2.str5 and 
                           tarifex2his.kont = tarifex2.kont  
                           no-lock by tarifex2his.whn by tarifex2his.wtim:
  put unformatted tarifex2his.aaa                           ';'
              tarifex2his.cif							    ';'
	          tarifex2his.kont							    ';' 
	          tarifex2his.pakalp							    ';'
	          tarifex2his.crc							    ';'
	          tarifex2his.ost							    ';'
	          tarifex2his.proc							    ';'
	          tarifex2his.min1 							    ';'
	          tarifex2his.max1   							    ';'
	          tarifex2his.who  							    ';'
	          if tarifex2his.whn = ? then '' else string(tarifex2his.whn) 		    ';'
                  if tarifex2his.wtim = 0 then '' else string(tarifex2his.wtim, 'hh:mm:ss')   ';'
	          tarifex2his.akswho 							    ';'
	          if tarifex2his.akswhn = ? then '' else string(tarifex2his.akswhn) 	    ';'
                  if tarifex2his.awtim = 0 then '' else string(tarifex2his.awtim, 'hh:mm:ss') ';'
	          tarifex2his.delwho 							    ';'
	          if tarifex2his.delwhn <> ? then string(tarifex2his.delwhn) else '' 	    ';'
                  if tarifex2his.dwtim = 0 then '' else string(tarifex2his.dwtim, 'hh:mm:ss') ';'
                  tarifex2his.stat							    skip.
end.
output close.
unix silent cptwin vcdata.csv excel.
end. /* yes-no*/

end procedure.


/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifex2his_update.
	create tarifex2his.
	buffer-copy tarifex2 to tarifex2his.
end procedure.


