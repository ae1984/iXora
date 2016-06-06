/*  tavt2_add.p
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
 * BASES
        BANK COMM        
 * AUTHOR
        02.11.2004 saltanat
 * CHANGES
        28.04.05 saltanat - упростила прцедуру tarifhis_update.
                            при удалении тарифа предусмотрела удаление льгот по тарифу.
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
                              добалена возможность просмотра полной истории
        18.08.2009 id00205 Добавил синхронизацию счета г-к по филиалам                              
*/

{global.i}
{yes-no.i}

def shared var v-stat as char.
def var i as char format 'x(6)' init ''. 
def buffer b-tarif2 for tarif2 .
define buffer tarif2_buf for tarif2.  
def buffer ftarif2 for tarif2.

def var v-nr   like tarif2.nr.
def var v-nr1  like tarif2.nr.
def var v-nr2  like tarif2.nr.

find first tarif2 where tarif2.stat = v-stat no-lock no-error.
if avail tarif2 then do:

{apbra.i 

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tarif2add"
&framename = "tarif2"
&where     = "tarif2.stat = v-stat and (if i <> '' then string(tarif2.kont) begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " "

&prechoose = "message ' F4-выход, P-печать, TAB-исключения, H-история, F-поиск, A-Акцепт'."

&predisplay = " "

&display   = " tarif2.num
               tarif2.kod
               tarif2.kont
               tarif2.pakalp
               tarif2.crc 
               tarif2.ost
               tarif2.proc
               tarif2.min1
               tarif2.max1 "

&highlight = " tarif2.num tarif2.kod tarif2.kont tarif2.pakalp "

&predelete = " "

&postkey   = "
      else if keyfunction(lastkey) = 'P' then do:
        output to tar2.img .
        for each b-tarif2:
          display b-tarif2.str5  label 'Код' format 'x(3)'
                  b-tarif2.kont  column-label ' Счет'
                  b-tarif2.pakalp format 'x(30)' column-label 'Услуга'
                  b-tarif2.crc column-label 'Вал'
                  b-tarif2.ost  column-label 'Сумма'
                  b-tarif2.proc column-label ' %   '
                  b-tarif2.min1   format 'zz9.99'  column-label ' Мин'
                  b-tarif2.max1  format 'zz9.99' column-label 'Макс' 
             with overlay column 1 row 7 11 down frame uuu.
         end.
         hide frame uuu.
         output close.
         output to terminal.
         unix prit tar2.img.
       end. 

       else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave:
         hide all.
         run tavt3_add. 
       end .
       else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
            /*displ tarif2.who label 'Внес.' 
                  tarif2.whn label 'Дата вн.' 
            with overlay centered row 10 title 'История' frame df.
             hide frame df.*/
            run proc_his. 
       end. 

       else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
        run proc_find.
        hide frame fri.
        clin = 0. blin = 0.
        next upper.
       end. 

       else if keyfunction(lastkey) = 'A' then do on endkey undo, leave:
       assign v-nr = tarif2.nr v-nr1 = tarif2.nr1 v-nr2 = tarif2.nr2.
      do transaction:
       find last tarif2 where tarif2.nr = v-nr and tarif2.nr1 = v-nr1 and tarif2.nr2 = v-nr2  
                          and tarif2.stat = 'r' exclusive-lock no-error.
        if avail tarif2 then delete tarif2.
      end. /*transaction:*/
       release tarif2. 
        run proc_akcept.
         
        hide frame fri.
        find first tarif2 where tarif2.stat = v-stat no-lock no-error.
        if not avail tarif2 then do: if yes-no('',' Больше нет данных для акцепта. Перейти на начало? ') then do:
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

&end = "hide frame tarif2."
}
hide message.
end.
else do:
if yes-no('',' Нет данных. Продолжить просмотр след. раздела? ') then do:
   run tavt3_add.
end.
end.

procedure proc_his.
    displ tarif2.who    column-label 'Внес.'      format 'x(10)'
          tarif2.whn    column-label 'Дата вн.'
          tarif2.akswho column-label 'Акцепт.'    format 'x(10)'
          tarif2.akswhn column-label 'Дата акц.' 
    with overlay centered row 10 title 'История' frame ff. 
hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

output to vcdata.csv .
displ 'История' skip(1).
  put unformatted 'Nr'          ';'
                  'Nr'          ';'
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

for each tarif2his where tarif2his.num = tarif2.num and tarif2his.kod = tarif2.kod and tarif2his.kont = tarif2.kont no-lock by tarif2his.whn by tarif2his.wtim:
  put unformatted tarif2his.num                                                           ';'
                  tarif2his.kod                                                           ';'
                  tarif2his.kont                                                          ';'
                  tarif2his.pakalp                                                        ';'
                  tarif2his.crc                                                           ';'
                  tarif2his.ost                                                           ';'
                  tarif2his.proc                                                          ';'
                  tarif2his.min1                                                          ';'
                  tarif2his.max1                                                          ';'
                  tarif2his.who                                                           ';'
                  if tarif2his.whn = ? then '' else string(tarif2his.whn)                 ';'
                  if tarif2his.wtim = 0 then '' else string(tarif2his.wtim,'hh:mm:ss')    ';'
                  tarif2his.akswho                                                        ';'
                  if tarif2his.akswhn = ? then '' else string(tarif2his.akswhn)           ';'
                  if tarif2his.awtim = 0 then '' else string(tarif2his.awtim, 'hh:mm:ss') ';'
                  tarif2his.delwho                                                        ';'
                  if tarif2his.delwhn = ? then '' else string(tarif2his.delwhn)           ';'
                  if tarif2his.dwtim = 0 then '' else string(tarif2his.dwtim, 'hh:mm:ss') ';'
                  tarif2his.stat                                                          skip. 
end.
output close.
unix silent cptwin vcdata.csv excel.
end. /* yes-no*/

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите счет:'.
if i <> '' then do:
   find first ftarif2 where string(ftarif2.kont) begins i and ftarif2.stat = v-stat no-lock no-error.
   if not avail ftarif2 then do:
     i = ''.
     message ('Такого номера счета здесь нет ! ').
   end.
end. /* if */
end procedure.

procedure proc_akcept.
  
 if yes-no('',' Вы действительно хотите акцептовать запись? ') then do:
  do transaction:
   find last tarif2 where tarif2.stat = v-stat and tarif2.nr = v-nr and tarif2.nr1 = v-nr1 and tarif2.nr2 = v-nr2 exclusive-lock no-error.
   if avail tarif2 then do:
      tarif2.akswho = g-ofc.
      tarif2.akswhn = g-today.
      tarif2.awtim  = time.
      
      if v-stat = 'd' then do:
         /* из за наличия кучи уникальных индексов в таблице эти извращения */
         find last tarif2_buf where tarif2_buf.stat = 'a' and ((tarif2_buf.nr = v-nr and tarif2_buf.nr1 = v-nr1 and tarif2_buf.nr2 = v-nr2) or (tarif2_buf.num = tarif2.num and tarif2_buf.kod = tarif2.kod) or (tarif2_buf.str5 = tarif2.str5)) exclusive-lock no-error.
         if avail tarif2_buf then delete tarif2_buf.
         tarif2.stat = 'a'.
      end.      
      else tarif2.stat = 'r'.
      
      run tarif2his_update.
      find current tarif2 no-lock no-error.
      if tarif2.stat = 'a' then run tarifex_del.
   end.
   else message (' Акцептуемой записи нет ! ').
  end. /*transaction*/ 
 
  /*********************************************************************************************************************/
  /* Синхронизация счета г-к. по филиалам */
   find sysc where sysc.sysc = 'OURBNK' no-lock no-error.
   if avail sysc then 
   do:
     if sysc.chval = "TXB00" then 
     do: /* Программа запускается только в ЦО*/
       if v-stat = 'c' or v-stat = 'n' then do:
       /* только новые или изменяемые тарифы */
         {r-branch.i &proc="tavt_all ( tarif2.num , tarif2.kod , tarif2.kont , tarif2.pakalp, tarif2.ost, tarif2.proc , tarif2.max1 , tarif2.min1 , v-nr , v-nr1 , v-nr2 , g-ofc , g-today , tarif2.crc  )"} 
       /* message "1-" + string(v-nr) + "  2-" + string(v-nr1) + "  3-" + string(v-nr2) view-as alert-box.*/
       end.
       else do: message "Программа синхронизации не работает для тарифов со статусом - " + v-stat view-as alert-box. end.
     end.
   end.
   else do: message "Нет переменной OURBNK" view-as alert-box. end.
  /*********************************************************************************************************************/
 end.
 
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


/* ---- процедура сохранения истории ---- */
procedure tarif2his_update.
	create tarif2his.
	buffer-copy tarif2 to tarif2his.
end procedure.

/* ---- процедура сохранения истории льгот ---- */
procedure tarifexhis_update.
	create tarifexhis.
	buffer-copy tarifex to tarifexhis.
end procedure.

