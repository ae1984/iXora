/* tar2_ex2.p
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
        9-1-2-6-1 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
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
def var aaa_  like tarifex2.aaa.
def var nsost_ like tarifex2.nsost.

{apbra.i 
&start     = " "
&head      = "tarifex2"
&headkey   = "tarifex2"
&index     = "id-str5cifsta"

&formname  = "tarifex2"
&framename = "tarifex2"
&where     = "tarifex2.str5 = code and tarifex2.cif = cif_ and tarifex2.stat = 'r' and (if i <> '' then tarifex2.aaa begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " "

&prechoose = "message 'F4-выход,P-печать,H-история,F-поиск'."

&predisplay = " "

&predelete = " "  

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
	        else if keyfunction(lastkey) = 'P' then do:
                 output to tar2ex2.img .
                 for each b-tarifex2 where b-tarifex2.str5 = code :
                   display 
                       b-tarifex2.cif label 'Клиент'
                       b-tarifex2.aaa label 'Сч.Кл.'
                       b-tarifex2.kont column-label 'Счет Гл.Кн. '
                       b-tarifex2.pakalp format 'x(26)' column-label 'Услуга'
                       b-tarifex2.crc column-label 'Вал'
                       b-tarifex2.ost  column-label 'Сумма'
                       b-tarifex2.proc column-label '  %  '
                       b-tarifex2.min1   format 'zz9.99' column-label ' Мин '
                       b-tarifex2.max1  format 'zz9.99' column-label ' Макс'
                        with overlay title tit column 1 row 7 11 down frame uuu.
                 end.
               hide frame uuu.
               output close.
               output to terminal.
               unix prit tar2ex2.img.
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

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер счета клиента:'.
if i <> '' then do:
   find first ftarifex2 where ftarifex2.aaa begins i and tarifex.stat = 'r' no-lock no-error.
   if not avail ftarifex2 then do:
     i = ''.
     message ('Такого клиента здесь нет ! ').
   end.
end. /* if */
end procedure.


 
