/*  tar3_arh.p
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
        28.03.05 saltanat - Создала архив по клиентам с закрытыми счетами.
        08.11.06 Natalya D. - добавила сортировку в q1 и поиск
*/

define frame tar_spr
   tarifex.cif    column-label "Клиент" skip
   tarifex.kont   column-label "Счет"   skip
   tarifex.pakalp column-label "Услуга" skip
   tarifex.crc    column-label "Вал"    skip
   tarifex.ost    column-label "Сумма"  skip
   tarifex.proc   column-label "%"      skip
   tarifex.min1   column-label "Мин"    skip
   tarifex.max1   column-label "Макс"
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR tarifex.
def var i as char format 'x(6)' init ''. 
def buffer ftarifex for tarifex.
def var v-rwd AS ROWID.

define buffer buf for tarifex.

def browse b1
     query q1 
     displ 
	   tarifex.cif    column-label "Клиент" format 'x(6)'
	   tarifex.kont   column-label "Счет" 
	   tarifex.str5   column-label "Код" format 'x(3)'  
	   tarifex.pakalp column-label "Услуга" format 'x(12)'
	   tarifex.crc    column-label "Вал"    format 'z9'
	   tarifex.ost    column-label "Сумма"      
	   tarifex.proc   column-label "%"      
	   tarifex.min1   column-label "Мин"    
	   tarifex.max1   column-label "Макс"
     with 12 down title "Справочник комиссий по клиентам" overlay.


DEFINE BUTTON baks LABEL "Возврат".   
DEFINE BUTTON bspr LABEL "Ком по усл".        
DEFINE BUTTON bscl LABEL "Ком по сч.ГК.".        
DEFINE BUTTON bacl LABEL "Кл с закр.сч".
DEFINE BUTTON bcls LABEL "Ком по сч".
define button bfnd label "Поиск".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 help "F1 - История, F4 - Выход"   
     skip
     baks
     bspr
     bscl
     bacl
     bcls
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
   find current tarifex exclusive-lock no-error.
   if avail tarifex then do:
      tarifex.akswho = ''.
      tarifex.akswhn = ?.
      tarifex.awtim  = 0.
      tarifex.delwho = ''.
      tarifex.delwhn = ?.
      tarifex.dwtim  = 0.
      tarifex.who    = g-ofc.
      tarifex.whn    = g-today.
      tarifex.wtim   = time.
      tarifex.stat   = 'n'.
      run tarifexhis_update.
      open query q1 for each tarifex where tarifex.stat = 'a'. 
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

ON CHOOSE OF bacl IN FRAME fr1
do:
   run tar4_arh.
end.

ON CHOOSE OF bcls IN FRAME fr1
do:
   run tar5_arh.
end.

ON CHOOSE OF bfnd IN FRAME fr1
do:
   
update i no-label
  with frame fri with overlay centered row 10 title 'Введите номер клиента:'.
  if i <> '' then do:
     
     find first tarifex where tarifex.cif begins i and tarifex.stat = 'a' no-lock no-error.
     if not avail tarifex then do:
       i = ''.
       message ('Такого клиента здесь нет ! ').
     end.
     else do:
     v-rwd = rowid(tarifex).   
         reposition q1 to rowid v-rwd no-error.
         browse b1:refresh().
         /*b1:SET-REPOSITIONED-ROW (10, "CONDITIONAL").    */
     end.
  end. /* if */
end.

open query q1 for each tarifex where tarifex.stat = 'a' by tarifex.cif by tarifex.str5. 

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only .

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.


/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
assign tarifexhis.cif    = tarifex.cif
       tarifexhis.kont   = tarifex.kont
       tarifexhis.pakalp = tarifex.pakalp
       tarifexhis.ost    = tarifex.ost
       tarifexhis.proc   = tarifex.proc
       tarifexhis.max1   = tarifex.max1
       tarifexhis.min1   = tarifex.min1
       tarifexhis.str5   = tarifex.str5
       tarifexhis.crc    = tarifex.crc
       tarifexhis.who    = tarifex.who
       tarifexhis.whn    = tarifex.whn 
       tarifexhis.wtim   = tarifex.wtim
       tarifexhis.akswho = tarifex.akswho
       tarifexhis.akswhn = tarifex.akswhn
       tarifexhis.awtim  = tarifex.awtim
       tarifexhis.delwho = tarifex.delwho
       tarifexhis.delwhn = tarifex.delwhn
       tarifexhis.dwtim  = tarifex.dwtim
       tarifexhis.stat   = tarifex.stat.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
find current tarifex no-lock no-error.
if not avail tarifex then do: message 'Нет текущей записи !' view-as alert-box buttons ok. return. end.

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

for each tarifexhis where tarifexhis.cif = tarifex.cif and tarifexhis.kont = tarifex.kont and tarifexhis.str5 = tarifex.str5 no-lock by tarifexhis.whn by tarifexhis.wtim:
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
end procedure.
