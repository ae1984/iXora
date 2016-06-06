/*  tar2_arh.p
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
        08.11.06 Natalya D. - добавила сортировку в q1
*/

define frame tar_spr
   tarif2.num    column-label "Nr."    skip
   tarif2.kod    column-label "Nr."    skip
   tarif2.kont   column-label "Счет"   skip
   tarif2.pakalp column-label "Услуга" skip
   tarif2.crc    column-label "Вал"    skip
   tarif2.ost    column-label "Сумма"  skip
   tarif2.proc   column-label "%"      skip
   tarif2.min1   column-label "Мин"    skip
   tarif2.max1   column-label "Макс"
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR tarif2.

define buffer buf for tarif2.

def browse b1
     query q1 
     displ 
	   tarif2.num    column-label "Nr."    format 'x(2)'   
	   tarif2.kod    column-label "Nr."    format 'x(2)'
	   tarif2.kont   column-label "Счет"   
	   tarif2.pakalp column-label "Услуга" format 'x(15)'
	   tarif2.crc    column-label "Вал"    format 'z9'
	   tarif2.ost    column-label "Сумма"      
	   tarif2.proc   column-label "%"      
	   tarif2.min1   column-label "Мин"    
	   tarif2.max1   column-label "Макс"
     with 12 down title "Справочник комиссий по счетам" overlay.


DEFINE BUTTON baks LABEL "Возврат".        
DEFINE BUTTON bspr LABEL "Ком по усл".        
DEFINE BUTTON bscl LABEL "Ком по кл".   
DEFINE BUTTON bacl LABEL "Кл с закр.сч". 
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
   find current tarif2 exclusive-lock no-error.
   if avail tarif2 then do:
      tarif2.akswho = ''.
      tarif2.akswhn = ?.
      tarif2.awtim  = 0.
      tarif2.delwho = ''.
      tarif2.delwhn = ?.
      tarif2.dwtim  = 0.
      tarif2.who    = g-ofc.
      tarif2.whn    = g-today.
      tarif2.wtim   = time.
      tarif2.stat   = 'n'.
      run tarif2his_update.
      open query q1 for each tarif2 where tarif2.stat = 'a'. 
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

open query q1 for each tarif2 where tarif2.stat = 'a' by tarif2.num by tarif2.kod. 


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.


/* ---- процедура сохранения истории ---- */
procedure tarif2his_update.
create tarif2his.
assign tarif2his.num    = tarif2.num
       tarif2his.kod    = tarif2.kod
       tarif2his.kont   = tarif2.kont
       tarif2his.pakalp = tarif2.pakalp
       tarif2his.ost    = tarif2.ost
       tarif2his.proc   = tarif2.proc
       tarif2his.max1   = tarif2.max1
       tarif2his.min1   = tarif2.min1
       tarif2his.str5   = tarif2.str5
       tarif2his.nr     = tarif2.nr
       tarif2his.nr1    = tarif2.nr1
       tarif2his.nr2    = tarif2.nr2
       tarif2his.nr3    = tarif2.nr3
       tarif2his.crc    = tarif2.crc
       tarif2his.who    = tarif2.who
       tarif2his.whn    = tarif2.whn
       tarif2his.wtim   = tarif2.wtim
       tarif2his.akswho = tarif2.akswho
       tarif2his.akswhn = tarif2.akswhn
       tarif2his.awtim  = tarif2.awtim
       tarif2his.delwho = tarif2.delwho
       tarif2his.delwhn = tarif2.delwhn
       tarif2his.dwtim  = tarif2.dwtim
       tarif2his.stat   = tarif2.stat.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
find current tarif2 no-lock no-error.
if not avail tarif2 then do: message 'Нет текущей записи !' view-as alert-box buttons ok. return. end.

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
  put unformatted tarif2his.num  							  ';'
	          tarif2his.kod 						          ';'
	          tarif2his.kont 							  ';'
	          tarif2his.pakalp							  ';'
	          tarif2his.crc  							  ';'
	          tarif2his.ost  							  ';'
	          tarif2his.proc 							  ';'
	          tarif2his.min1 							  ';'
	          tarif2his.max1 							  ';'
	          tarif2his.who  							  ';'
	          if tarif2his.whn = ? then '' else string(tarif2his.whn) 		  ';'
                  if tarif2his.wtim = 0 then '' else string(tarif2his.wtim,'hh:mm:ss')    ';'
	          tarif2his.akswho 							  ';'
	          if tarif2his.akswhn = ? then '' else string(tarif2his.akswhn) 	  ';'
                  if tarif2his.awtim = 0 then '' else string(tarif2his.awtim, 'hh:mm:ss') ';'
	          tarif2his.delwho 							  ';'
	          if tarif2his.delwhn = ? then '' else string(tarif2his.delwhn) 	  ';'
                  if tarif2his.dwtim = 0 then '' else string(tarif2his.dwtim, 'hh:mm:ss') ';'
                  tarif2his.stat 							  skip. 
end.
output close.
unix silent cptwin vcdata.csv excel.
end procedure.