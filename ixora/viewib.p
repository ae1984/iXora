/* viewib.p
 * MODULE
        Мониторинг карточных задолжностей
 * DESCRIPTION
        Должники на контроле
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-5-11
 * BASES
        BANK COMM IB
 * AUTHOR
        05.12.2005 
        tsoy
 * CHANGES
*/

{mainhead.i}

def new shared temp-table t-doc like ib.doc
   field  s as char 
   field  t as char. 

define variable v-dt as date format "99/99/99" init today.
define variable v-id as integer format ">>>9".

DEFINE BUTTON bexit    LABEL "Выход".                            

def var r AS ROWID.
def var i as integer.
define variable method-return as logical.


form skip v-id LABEL "ID " space(3) v-dt LABEL "DATE " with frame rmzor side-label row 3  centered.

define query q1 for t-doc.                                                                    

def browse b1
    query q1 no-lock
    display
        t-doc.id           label "ДОК."   format ">>>>>>>>9"
        t-doc.amt          label "СУММА"  format ">>>,>>>,>>9.99"
        t-doc.crccode      label "ВАЛ"    format "x(3)"
        t-doc.remtrz       label "ПАЛТЕЖ" format "x(10)"
        t-doc.s            label "СТАТУС" format "x(16)"            
        t-doc.t            label "ТИП"    format "x(13)"            
    with 9 down   title "СПИСОК ПЛАТЕЖЕЙ" no-labels.

def frame f1
    b1 help "<ENTER> -  Просмотр "
    skip
    bexit
with centered row 3.

def frame f2
  "ERROR    : "
  t-doc.unpromsg[1] no-label format "x(50)"  skip
with row 19 centered width 80 overlay.


update v-id v-dt  with frame rmzor.

for each ib.doc where ib.doc.id_usr = v-id and ib.doc.valdate = v-dt no-lock.
    create t-doc.
    buffer-copy ib.doc to t-doc.

    case t-doc.state:
    	when 0 then                           
    		t-doc.s =  "Создается".
    	when 1 then                           
    		t-doc.s =  "Новый".
    	when 2 then                            
    		t-doc.s =  "Отправлен".
    	when 3 then                            
    		t-doc.s =  "Отправленый".
    	when 4 then                            
    		t-doc.s =  "Акцептован" .
    	when 5 then                            
    		t-doc.s =  "Отверг. автомат." .
    	when 6 then                            
    		t-doc.s =  "Шаблон".
    	when 7 then                            
    		t-doc.s =  "Отвер. операц.".
    	when 8 then                            
    		t-doc.s =  "Исполненый".
    end case.

    if t-doc.type = 1 then do:
         case t-doc.state:
         	when 1 then                           
         		t-doc.t =  "По Казахстану".
         	when 2 then                           
         		t-doc.t =  "Налоговый".
         	when 3 then                           
         		t-doc.t =  "Пенсионный".
         	when 4 then                           
         		t-doc.t =  "Пополнение ЗП".
          end case.
    end.

    if t-doc.type = 2 then t-doc.t = "Международный "   .
    if t-doc.type = 3 then t-doc.t = "Письмо        "   .
    if t-doc.type = 4 then t-doc.t = "Внутрибанк    "   .
    if t-doc.type = 9 then t-doc.t = "Конвертация   "   .

end.


on value-changed of b1 in frame f1 do:
  if num-results("q1") > 0 then
    display t-doc.unpromsg[1] with frame f2.
  else
    display "" with frame f2.
end.

ON return of b1 in FRAME f1 DO:

     do i = b1:num-selected-rows to 1 by -1 transaction:
       
       method-return = b1:fetch-selected-row(i).
       get current q1 no-lock.
       find current t-doc.
       
       displ t-doc except author with 1 col. {wait.i}

     end.

     apply "value-changed" to browse b1.

end.

/* выход */
on choose of bexit in frame f1 do:
   apply "enter-menubar" to frame f1.
end.


open query q1 for each t-doc.

enable all with centered frame f1.
apply "value-changed" to browse b1.
wait-for "enter-menubar" of frame f1.

close query q1.
hide all no-pause.


                                                    	
