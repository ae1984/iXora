/*  tar_arh.p
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
        02.09.2004 saltanat
 * CHANGES
        28.03.05 saltanat - Создала архив по клиентам с закрытыми счетами.
*/

define frame tar_spr
   tarif.num    column-label "Nr." skip
   tarif.nr     column-label "Nr." skip
   tarif.pakalp column-label "Услуга" format 'x(45)'
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR tarif.

define buffer buf for tarif.

def browse b1
     query q1 
     displ 
     tarif.num    column-label "Nr." 
	 tarif.nr     column-label "Nr."    
	 tarif.pakalp column-label "Услуга" format 'x(45)'
     with 12 down title "Справочник комиссий за услуги" overlay.


DEFINE BUTTON baks LABEL "Возврат".        
DEFINE BUTTON bspr LABEL "Ком по сч.ГК.".        
DEFINE BUTTON bscl LABEL "Ком по кл.".        
DEFINE BUTTON bacl LABEL "Кл. с закр.сч".
DEFINE BUTTON bcls LABEL "Ком по сч".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 help "F1 - История, F4 - Выход"   
     skip
     baks
     bspr
     bscl
     bacl
     bcls
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
   find current tarif exclusive-lock no-error.
   if avail tarif then do:
   tarif.akswho = ''.
   tarif.akswhn = ?.
   tarif.awtim  = 0.
   tarif.delwho = ''.
   tarif.delwhn = ?.
   tarif.dwtim  = 0.
   tarif.who    = g-ofc.
   tarif.whn    = g-today.
   tarif.wtim   = time.
   tarif.stat   = 'n'.
   run tarifhis_update.
   open query q1 for each tarif where tarif.stat = 'a'. 
   end.
   else message (' Записи нет ! ').
end.
end.

ON CHOOSE OF bspr IN FRAME fr1
do:
   run tar2_arh.
end.

ON CHOOSE OF bscl IN FRAME fr1
do:
   run tar3_arh.
end.

ON CHOOSE OF bacl IN FRAME fr1
do:
   run tar4_arh.
end.

ON CHOOSE OF bcls IN FRAME fr1
do:
   run tar5_arh.
end.

open query q1 for each tarif where tarif.stat = 'a'. 


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

/* ---- процедура сохранения истории ---- */
procedure tarifhis_update.
create tarifhis.
assign tarifhis.num    = tarif.num
       tarifhis.pakalp = tarif.pakalp
       tarifhis.nr     = tarif.nr
       tarifhis.nr1    = tarif.nr1
       tarifhis.crc    = tarif.crc
       tarifhis.who    = tarif.who
       tarifhis.whn    = tarif.whn 
       tarifhis.wtim   = tarif.wtim
       tarifhis.akswho = tarif.akswho
       tarifhis.akswhn = tarif.akswhn
       tarifhis.awtim  = tarif.awtim
       tarifhis.delwho = tarif.delwho
       tarifhis.delwhn = tarif.delwhn
       tarifhis.dwtim  = tarif.dwtim
       tarifhis.stat   = tarif.stat.
end procedure.

/* H I S T O R Y */
procedure proc_his.
find current tarif no-lock no-error.
if not avail tarif then do: message 'Нет текущей записи !' view-as alert-box buttons ok. return. end.

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
end procedure.