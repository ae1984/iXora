/* tar2_aex2.p
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
        9-1-2-6-2 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
        08.11.06 Natalya D. - при редактировании записи, добавила проверку
*/

{yes-no.i}

def shared var g-lang as char.
def shared var paka like tarif.pakalp.
def shared var len as int.
def buffer atarifex2 for tarifex2.
def var rr5 as int.
def shared var rr4 as int.
def shared var g-ofc like tarifex2.who.
def shared var g-today like tarifex2.whn.
def shared var code like tarifex2.str5 .
def shared var tit like tarifex2.pakalp .
def shared var kon like tarifex2.kont .
def buffer b-tarifex2 for tarifex2.
def shared var cif_    like tarifex2.cif.
def shared var kont_   like tarifex2.kont.
def shared var pakalp_ like tarifex2.pakalp.
def shared var ost_    like tarifex2.ost.
def shared var proc_   like tarifex2.proc.
def shared var max1_   like tarifex2.max1.
def shared var min1_   like tarifex2.min1.
def shared var crc_    like tarifex2.crc.
def var i as char format 'x(6)' init ''. 
def buffer ftarifex2 for tarifex2.
def var v-nests as char init 'a,h'. 
def var aaa_  like tarifex2.aaa.
def var nsost_ like tarifex2.nsost.

def temp-table t-tarifex2 like tarifex2.

{apbra.i 
&start     = " "
&head      = "tarifex2"
&headkey   = "tarifex2"
&index     = "id-str5cifsta"

&formname  = "tarifex2"
&framename = "tarifex2"
&where     = "tarifex2.str5 = code and tarifex2.cif = cif_ and lookup(tarifex2.stat,v-nests) = 0 and (if i <> '' then tarifex2.aaa begins i else true) "

&addcon    = "true"
&deletecon = "false"

&precreate = " "

&postadd   = " 
               tarifex2.cif  = cif_ . 
               tarifex2.kont = kon .
               tarifex2.pakalp = pakalp_ .
               tarifex2.str5 = code .
               update tarifex2.aaa validate(can-find(aaa where aaa.aaa = tarifex2.aaa and aaa.cif = cif_ and aaa.sta ne 'c'), 'Неверный счет клиента!')
                      tarifex2.crc 
                      tarifex2.ost tarifex2.proc tarifex2.min1 tarifex2.max1
                      tarifex2.nsost
               with frame tarifex2 .
               tarifex2.whn  = g-today.
               tarifex2.who  = 'M' + g-ofc.  
               tarifex2.wtim = time.
               tarifex2.stat = 'n'.    
               run tarifex2his_update. "

&prechoose = "message 'F4-выход,INS-добавить,D-удалить,ENTER-изменить,H-история,F-поиск'."

&predisplay = " "

&predelete = " tarifex2.akswho = ''.
               tarifex2.akswhn = ?.
               tarifex2.awtim  = 0.
               tarifex2.delwho = g-ofc.
               tarifex2.delwhn = g-today.
               tarifex2.dwtim  = time.
               tarifex2.stat   = 'd'.
               run tarifex2his_update. "  

&display   = " tarifex2.aaa
               tarifex2.crc column-label 'Вал'
               tarifex2.ost
               tarifex2.proc
               tarifex2.min1
               tarifex2.max1 
               tarifex2.nsost
               substr(tarifex2.who, 1, 1) @ v-am "

&highlight = " tarifex2.aaa "

&postkey   = "
            else if keyfunction(lastkey) = 'RETURN' then do transaction on endkey undo, leave:
                 run proc_return.
                 next upper.
            end.

            else if keyfunction(lastkey) = 'D' then do on endkey undo, leave:
	         run proc_del.
                 next upper.
    	    end. 

	        else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
	         run proc_his.
	        end. 

            else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                 run proc_find.
                 hide frame fri.
 	         clin = 0. blin = 0.
	         next upper.
            end. 
 "
&end = "hide frame tarifex2."
}
hide message.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- RETURN --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_return.

if yes-no('',' Вы действительно хотите изменить данные? ') then do:
 aaa_    = tarifex2.aaa.
 crc_    = tarifex2.crc.
 ost_    = tarifex2.ost.
 proc_   = tarifex2.proc.
 min1_   = tarifex2.min1.
 max1_   = tarifex2.max1.
 nsost_   = tarifex2.nsost.
 
 find first t-tarifex2 no-error.
 if avail t-tarifex2 then delete t-tarifex2.
 create t-tarifex2.
 buffer-copy tarifex2 to t-tarifex2. 

 do transaction on endkey undo, leave:
    update
        tarifex2.aaa
        tarifex2.crc column-label 'Вал'
        tarifex2.ost
        tarifex2.proc
        tarifex2.min1
        tarifex2.max1 
        tarifex2.nsost    
    with frame tarifex2 .
    tarifex2.whn = g-today.
    tarifex2.who = 'M' + g-ofc.
    tarifex2.wtim = time.
    displ substr(tarifex2.who, 1, 1) @ v-am with frame tarifex2.
 end.

 if (aaa_ ne tarifex2.aaa) or (ost_ ne tarifex2.ost) or (proc_ ne tarifex2.proc) or 
    (min1_ ne tarifex2.min1) or (max1_ ne tarifex2.max1) or (nsost_ ne tarifex2.nsost) then do:
    tarifex2.akswho = ''.
    tarifex2.akswhn = ?.
    tarifex2.awtim  = 0.
    tarifex2.delwho = ''.
    tarifex2.delwhn = ?.
    tarifex2.dwtim  = 0.
    tarifex2.stat   = 'c'.
    run tarifex2his_update.
 end. /* if changed */
 if t-tarifex2.stat = 'r' or t-tarifex2.stat = 'r' then do:
 for each t-tarifex2 where t-tarifex2.aaa = tarifex2.aaa and t-tarifex2.cif = tarifex2.cif 
                       and t-tarifex2.str5 = tarifex2.str5 no-lock. 
   create tarifex2.
   buffer-copy t-tarifex2 to tarifex2.  
 end.
 end.
end.  /* yes */
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
                           tarifex2his.str5 = code and 
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

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- DEL --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_del.
if yes-no('',' Вы действительно хотите удалить запись? ') then do:

 find first t-tarifex2 no-error.
 if avail t-tarifex2 then delete t-tarifex2.
 create t-tarifex2.
 buffer-copy tarifex2 to t-tarifex2. 

 tarifex2.delwho = g-ofc.
 tarifex2.delwhn = g-today.
 tarifex2.dwtim  = time.
 tarifex2.akswho = ''.
 tarifex2.akswhn = ?.
 tarifex2.awtim  = 0.
 tarifex2.stat   = 'd'.
 run tarifex2his_update.

 for each t-tarifex2 where t-tarifex2.aaa = tarifex2.aaa and t-tarifex2.cif = tarifex2.cif 
                       and t-tarifex2.str5 = tarifex2.str5 no-lock. 
   create tarifex2.
   buffer-copy t-tarifex2 to tarifex2.  
 end.
end. /* yes */ 
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер счета клиента:'.
if i <> '' then do:
   find first ftarifex2 where ftarifex2.aaa begins i and lookup(tarifex2.stat,v-nests) = 0 no-lock no-error.
   if not avail ftarifex2 then do:
     i = ''.
     message ('Такого клиента здесь нет ! ').
   end.
end. /* if */
end procedure.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifex2his_update.
	create tarifex2his.
	buffer-copy tarifex2 to tarifex2his.
end procedure.

 
