/*  tar5_arh.p
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
        9-1-2-6-4 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
        08.11.06 Natalya D. - добавила сортировку в q1 и поиск
*/

define frame tar_spr
   tarifex2.aaa    column-label "Сч кл." skip
   tarifex2.cif    column-label "Кл" skip
   tarifex2.kont   column-label "Сч ГК"   skip
   tarifex2.pakalp column-label "Усл" skip
/*   tarifex2.crc    column-label "Вал"    skip*/
   tarifex2.ost    column-label "Сум"  skip
   tarifex2.proc   column-label "%"      skip
   tarifex2.min1   column-label "Мин"    skip
   tarifex2.max1   column-label "Макс"   skip
/*   tarifex2.nsost  column-label "Несн.ост."*/
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR tarifex2.
def var i as char format 'x(6)' init ''. 

define buffer buf for tarifex2.

def browse b1
     query q1 
     displ 
       tarifex2.aaa    column-label "Сч кл." format 'x(9)'
	   tarifex2.cif    column-label "Кл" format 'x(6)'
	   tarifex2.kont   column-label "Счет" 
	   tarifex2.str5   column-label "Код" format 'x(3)'  
	   tarifex2.pakalp column-label "Усл" format 'x(7)'
	/*   tarifex2.crc    column-label "Вал"    format 'z9'*/
	   tarifex2.ost    column-label "Сум"      
	   tarifex2.proc   column-label "%"      
	   tarifex2.min1   column-label "Мин"    
	   tarifex2.max1   column-label "Макс"
	/*   tarifex2.nsost  column-label "Несн.ост."*/
     with 12 down title "Справочник комиссий по клиентам" overlay.


DEFINE BUTTON baks LABEL "Возв".   
DEFINE BUTTON bspr LABEL "Ком по Усл".        
DEFINE BUTTON bscl LABEL "Ком по сч.ГК".        
DEFINE BUTTON bcl  LABEL "Ком по кл".
DEFINE BUTTON bacl LABEL "Зак.сч".
DEFINE BUTTON bfnd LABEL "Поиск".
DEFINE BUTTON bext LABEL "Вых".

def frame fr1
     b1 help "F1 - История, F4 - Выход"   
     skip
     baks
     bspr
     bscl
     bcl
     bacl
     bfnd
     bext with centered overlay row 1 top-only.  

on "go" of browse b1 run proc_his.

on 'end-error' of browse b1 hide all.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF baks IN FRAME fr1
do:
if yes-no('',' Вы действительно хотите вернуть запись? ') then do:
   find current tarifex2 exclusive-lock no-error.
   if avail tarifex2 then do:
      tarifex2.akswho = ''.
      tarifex2.akswhn = ?.
      tarifex2.awtim  = 0.
      tarifex2.delwho = ''.
      tarifex2.delwhn = ?.
      tarifex2.dwtim  = 0.
      tarifex2.who    = g-ofc.
      tarifex2.whn    = g-today.
      tarifex2.wtim   = time.
      tarifex2.stat   = 'n'.
      run tarifex2his_update.
      open query q1 for each tarifex2 where tarifex2.stat = 'a'. 
   end.
   else message (' Записи нет ! ').
end.
end.

ON CHOOSE OF bspr IN FRAME fr1
do:
   run tar_arh.
end.

ON CHOOSE OF bscl IN FRAME fr1
do:
   run tar2_arh.
end.

ON CHOOSE OF bcl IN FRAME fr1
do:
   run tar3_arh.
end.

ON CHOOSE OF bacl IN FRAME fr1
do:
   run tar4_arh.
end.

ON CHOOSE OF bfnd IN FRAME fr1
do:  
update i no-label
  with frame fri with overlay centered row 10 title 'Введите номер клиента:'.
  if i <> '' then do:     
     find first tarifex2 where tarifex2.cif begins i and tarifex2.stat = 'a' no-lock no-error.
     if not avail tarifex2 then do:
       i = ''.
       message ('Такого клиента здесь нет ! ').
     end.
     else do:   
         reposition q1 to rowid rowid(tarifex2) no-error.
         browse b1:refresh().         
     end.
  end. /* if */
end.


open query q1 for each tarifex2 where tarifex2.stat = 'a' by tarifex2.cif by tarifex2.str5. 


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifex2his_update.
	create tarifex2his.
	buffer-copy tarifex2 to tarifex2his.
end procedure.


/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
find current tarifex2 no-lock no-error.
if not avail tarifex2 then do: message 'Нет текущей записи !' view-as alert-box buttons ok. return. end.

output to vcdata.csv .
displ 'История' skip(1).
  put unformatted
              'Счет кл'     ';'  
              'Клиент'      ';'
	          'Счет ГК'        ';' 
	          'Услуга'      ';'
	          'Вал'         ';'
	          'Сумма'       ';'
	          '%'           ';'
	          'Мин'         ';'
	          'Макс'        ';'
	          'Несниж. ост.' ';'
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

for each tarifex2his where tarifex2his.cif = tarifex2.cif and tarifex2his.kont = tarifex2.kont and tarifex2his.str5 = tarifex2.str5 no-lock by tarifex2his.whn by tarifex2his.wtim:
  put unformatted 
              tarifex2his.aaa                               ';'
              tarifex2his.cif							    ';'
	          tarifex2his.kont							    ';' 
	          tarifex2his.pakalp							';'
	          tarifex2his.crc							    ';'
	          tarifex2his.ost							    ';'
	          tarifex2his.proc							    ';'
	          tarifex2his.min1 							    ';'
	          tarifex2his.max1   							';'
	          tarifex2his.nsost                             ';'
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
end procedure.
