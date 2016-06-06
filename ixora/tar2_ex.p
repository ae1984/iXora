/* tar2_ex.p
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
        31/12/99 pragma
 * CHANGES
        20.08.2004 saltanat - отменила какое-либо редактирование, удаление либо внесение данных.
                              внесла просмотр краткой истории.
                              сделала поиск.
*/

/* tar2_ex.p
   Просмотр и установка льготных тарифов для клиента

   28.04.2003 nadejda - в поле офицера теперь пишется признак 'установлено вручную или по временным льготным тарифам' - "M"
                        для автоматически установленных исключений будет "A" - для льготного вида обслуживания, напр по $2 банкноте
*/

def shared var g-lang as char.
def shared var paka like tarif.pakalp.
def shared var len as int.
def buffer atarifex for tarifex.
def var rr5 as int.
def shared var rr4 as int.
def shared var g-ofc like tarifex.who.
def shared var g-today like tarifex.whn.
def shared var code like tarif2.str5 .
def shared var tit like tarifex.pakalp .
def shared var kon like tarifex.kont .
def buffer b-tarifex for tarifex.
def var i as char format 'x(6)' init ''. 
def buffer ftarifex for tarifex.

def new shared var cif_    like tarifex.cif.
def new shared var kont_   like tarifex.kont.
def new shared var pakalp_ like tarifex.pakalp.
def new shared var ost_    like tarifex.ost.
def new shared var proc_   like tarifex.proc.
def new shared var max1_   like tarifex.max1.
def new shared var min1_   like tarifex.min1.
def new shared var crc_    like tarifex.crc.

{apbra.i

&start     = " "
&head      = "tarifex"
&headkey   = "tarifex"
&index     = "main"

&formname  = "tarifex"
&framename = "tarifex"
&where     = "tarifex.str5 = code and tarifex.stat = 'r' and (if i <> '' then tarifex.cif begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " 
               tarifex.str5 = code .
               tarifex.kont = kon .
               tarifex.pakalp = tit .
               disp tarifex.kont with frame tarifex.
               update tarifex.cif  
                        validate(can-find(cif where cif.cif = tarifex.cif),
                        'Invalid CIF!')
                      tarifex.pakalp
                      tarifex.crc 
                      tarifex.ost tarifex.proc tarifex.min1 tarifex.max1
                      with frame tarifex .
                      tarifex.whn = g-today.
                      tarifex.who = 'M' + g-ofc. " /* признак 'установлено вручную или по временным льготным тарифам' */

&prechoose = "message 'F4-выход,P-печать,H-история,F-поиск,TAB-искл.по сч'."

&predisplay = " "

&display   = " tarifex.cif
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
                 run proc_tab.
               end.
               else if keyfunction(lastkey) = 'P' then do:
                 output to tar2ex.img .
                 for each b-tarifex where b-tarifex.str5 = code :
                   display b-tarifex.cif label 'Клиент'
                       b-tarifex.kont column-label 'Счет '
                       b-tarifex.pakalp format 'x(26)'
                        column-label 'Услуга'
                       b-tarifex.crc column-label 'Вал'
                       b-tarifex.ost  column-label 'Сумма'
                       b-tarifex.proc column-label '  %  '
                       b-tarifex.min1   format 'zz9.99' column-label ' Мин '
                       b-tarifex.max1  format 'zz9.99' column-label ' Макс'
                        with overlay title tit column 1 row 7 11 down frame uuu.
                 end.
               hide frame uuu.
               output close.
               output to terminal.
               unix prit tar2ex.img.
             end. 
             else if keyfunction(lastkey) = 'NEW-LINE' then do :
               run tar2_ex.
             end .

             else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
             displ tarifex.who column-label 'Внес'
                   tarifex.whn column-label 'Дата вн.'
                   tarifex.akswho column-label 'Акцепт'
                   tarifex.akswhn column-label 'Дата акц.'                  
             with overlay centered row 10 title 'История' frame df.
             hide frame df. 
             end. 

            else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                 run proc_find.
                 hide frame fri.
 	         clin = 0. blin = 0.
	         next upper.
            end. 
 "

&end = "hide frame tarifex."
}
hide message.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- TAB --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_tab.
 cif_    = tarifex.cif.
 kont_   = tarifex.kont.
 pakalp_ = tarifex.pakalp.
 crc_    = tarifex.crc.
 ost_    = tarifex.ost.
 proc_   = tarifex.proc.
 min1_   = tarifex.min1.
 max1_   = tarifex.max1.
 run tar2_ex2. 
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер клиента:'.
if i <> '' then do:
   find first ftarifex where ftarifex.cif begins i and tarifex.str5 = code and tarifex.stat = 'r' no-lock no-error.
   if not avail ftarifex then do:
     i = ''.
     message ('Такого клиента здесь нет ! ').
   end.
end. /* if */
end procedure.




