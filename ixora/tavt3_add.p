/*  tavt3_add.p
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
        02.11.2004 saltanat
 * CHANGES
        28.04.05 saltanat - упростила прцедуру tarifexhis_update.
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
                              добалена возможность просмотра полной истории
*/
{global.i}
{yes-no.i}

def shared var v-stat as char.
def var i as char format 'x(6)' init ''. 
def buffer b-tarifex for tarifex.
def buffer ftarifex for tarifex.
def var v-str5 like tarifex.str5.
def var v-cif like tarifex.cif.

find first tarifex where tarifex.stat = v-stat no-lock no-error.

if avail tarifex then do:
{apbra.i 

&start     = " "
&head      = "tarifex"
&headkey   = "tarifex"
&index     = "main"

&formname  = "tarifexadd"
&framename = "tarifex"
&where     = "tarifex.stat = v-stat and (if i <> '' then tarifex.cif begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " " 

&prechoose = "message 'F4-выход,P-печать,H-история,F-поиск,A-Акцепт,TAB-сч.искл.'."

&predisplay = "  find first tarif2 where tarif2.str5 = tarifex.str5 no-lock no-error. "
&display   = " 
               tarifex.str5 
               tarif2.punkt 
               tarifex.cif
               tarifex.kont
               tarifex.pakalp
               tarifex.crc column-label 'Вал'
               tarifex.ost
               tarifex.proc
               tarifex.min1
               tarifex.max1 
               substr(tarifex.who, 1, 1) @ v-am "

&highlight = " tarifex.cif tarifex.kont tarifex.pakalp "

&postkey   = " 
            else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave:
              hide all.
              run tavt4_add. 
            end .

            else if keyfunction(lastkey) = 'P' then do:
                 output to tar2ex.img .
                 for each b-tarifex :
                   display b-tarifex.cif label 'Клиент'
                       b-tarifex.kont column-label 'Счет '
                       b-tarifex.pakalp format 'x(26)'
                        column-label 'Услуга'
                       b-tarifex.crc column-label 'Вал'
                       b-tarifex.ost  column-label 'Сумма'
                       b-tarifex.proc column-label '  %  '
                       b-tarifex.min1   format 'zz9.99' column-label ' Мин '
                       b-tarifex.max1  format 'zz9.99' column-label ' Макс'
                        with overlay column 1 row 7 11 down frame uuu.
                 end.
               hide frame uuu.
               output close.
               output to terminal.
               unix prit tar2ex.img.
             end. 
             else if keyfunction(lastkey) = 'NEW-LINE' then do :
               run tavt3_add.
             end .

             else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
             /*displ tarifex.who column-label 'Внес'
                   tarifex.whn column-label 'Дата вн.'
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
                 assign v-str5 = tarifex.str5 v-cif = tarifex.cif.
                 find last tarifex where tarifex.str5 = v-str5 and tarifex.cif = v-cif   
                          and tarifex.stat = 'r' exclusive-lock no-error.
                 if avail tarifex then delete tarifex.
                 release tarifex. 
                 run proc_akcept.
                 hide frame fri.
                 find first tarifex where tarifex.stat = v-stat no-lock no-error.
                 if not avail tarifex then do: if yes-no('',' Больше нет данных для акцепта. Перейти на начало? ') then do:
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

&end = "hide frame tarifex."
}
hide message.
end.
else do:
if yes-no('',' Нет данных. Продолжить просмотр след. раздела? ') then do:
   run tavt4_add.
end.
end.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер клиента:'.
if i <> '' then do:
   find first ftarifex where ftarifex.cif begins i and tarifex.stat = v-stat no-lock no-error.
   if not avail ftarifex then do:
     i = ''.
     message ('Такого клиента здесь нет ! ').
   end.
end. /* if */
end procedure.

procedure proc_his.
    displ tarifex.who    column-label 'Внес.'         
          tarifex.whn    column-label 'Дата вн.'
          tarifex.akswho column-label 'Акцепт.'       
          tarifex.akswhn column-label 'Дата акц.' 
    with overlay centered row 10 title 'История' frame ff.

hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

output to vcdata.csv .
displ 'История' skip(1).
  put unformatted 'Клиент'      ';'
	          'Счет'        ';' 
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

for each tarifexhis where tarifexhis.cif = tarifex.cif and tarifexhis.kont = tarifex.kont and tarifexhis.str5 = tarifexh.str5 no-lock by tarifexhis.whn by tarifexhis.wtim:
  put unformatted tarifexhis.cif							    ';'
	          tarifexhis.kont							    ';' 
	          tarifexhis.pakalp							    ';'
	          tarifexhis.crc							    ';'
	          tarifexhis.ost							    ';'
	          tarifexhis.proc							    ';'
	          tarifexhis.min1 							    ';'
	          tarifexhis.max1   							    ';'
	          tarifexhis.who  							    ';'
	          if tarifexhis.whn = ? then '' else string(tarifexhis.whn) 		    ';'
                  if tarifexhis.wtim = 0 then '' else string(tarifexhis.wtim, 'hh:mm:ss')   ';'
	          tarifexhis.akswho 							    ';'
	          if tarifexhis.akswhn = ? then '' else string(tarifexhis.akswhn) 	    ';'
                  if tarifexhis.awtim = 0 then '' else string(tarifexhis.awtim, 'hh:mm:ss') ';'
	          tarifexhis.delwho 							    ';'
	          if tarifexhis.delwhn <> ? then string(tarifexhis.delwhn) else '' 	    ';'
                  if tarifexhis.dwtim = 0 then '' else string(tarifexhis.dwtim, 'hh:mm:ss') ';'
                  tarifexhis.stat							    skip.
end.
output close.
unix silent cptwin vcdata.csv excel.
end. /* yes-no*/

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- Akcept --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_akcept.
if yes-no('',' Вы действительно хотите акцептовать запись? ') then do:
   /*find current tarifex exclusive-lock no-error.*/
   find last tarifex where tarifex.stat = v-stat and tarifex.str5 = v-str5 and tarifex.cif = v-cif 
                      exclusive-lock no-error.   
   if avail tarifex then do:
      tarifex.akswho = g-ofc.
      tarifex.akswhn = g-today.
      tarifex.awtim  = time.
      if v-stat = 'd' then tarifex.stat = 'a'. 
      else tarifex.stat = 'r'.
      run tarifexhis_update.
      find current tarifex no-lock no-error.
   end.
   else message (' Акцептуемой записи нет ! ').
end.
end procedure.


/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
	create tarifexhis.
	buffer-copy tarifex to tarifexhis.
end procedure.


