/* tar2_b.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора - просмотр тарифов
 * RUN

 * CALLER
        tar_br.p
 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-6-1
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        20.08.2004 saltanat - внесла просмотр краткой истории.
                              сделала поиск.
        27.04.2005 saltanat - Изменила substring(tarif2.num,1,len) = stnum на tarif2.num = stnum в &where
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
        01.08.2013 damir - перекомпиляция в связи с изменением tarif2.f.
*/

{global.i}

def shared var stnum like tarif2.num.
def shared var paka like tarif.pakalp.
def shared var len as int.
def buffer b-tarif2 for tarif2 .
def var i as char format 'x(6)' init ''.
def buffer ftarif2 for tarif2.

{apbra.i

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tarif2"
&framename = "tarif2"
&where     = "tarif2.num = stnum and tarif2.stat = 'r' and (if i <> '' then string(tarif2.kont) begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = "  "

&prechoose = "message 'F4-выход, P-печать, H-история, F-поиск, X-доп.свед. '."

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



&postkey   = "
               else if keyfunction(lastkey) = 'P' then do:
               output to tar2.img .
               for each b-tarif2 where substring (b-tarif2.num,1,len) = stnum:
               display b-tarif2.str5  label 'Код ' format 'x(3)'
                       b-tarif2.kont  column-label 'Счет '
                       b-tarif2.pakalp format 'x(28)'   column-label 'Услуга'
                       b-tarif2.crc column-label 'Вал'
                       b-tarif2.ost column-label 'Сумма'
                       b-tarif2.proc   column-label '  %  '
                       b-tarif2.min1   format 'zz9.99' column-label ' Мин'
                       b-tarif2.max1  format 'zz9.99'  column-label ' Макс'
                        with overlay
                       title paka column 1 row 7 11 down
                       frame uuu.


                end.
                hide frame uuu.
               output close.
               output to terminal.
               unix prit tar2.img.
               end.
               else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
                    displ tarif2.who label 'Внес.'
                          tarif2.whn label 'Дата вн.'
                          tarif2.akswho label 'Акцепт.'
                          tarif2.akswhn label 'Дата акц.'
                    with overlay centered row 10 title 'История' frame df.
                    hide frame df.
               end.

               else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                run proc_find.
                hide frame fri.
                clin = 0. blin = 0.
                next upper.
               end.

		       else if keyfunction(lastkey) = 'X' then do on endkey undo, leave:
		        run proc_dopsv.
		       end.
              "

&end = "hide frame tarif2."
}
hide message.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- X --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_dopsv.
 displ tarif2.punkt format "x(30)" label "Пункт тарифа" skip
       tarif2.name format "x(60)" label "Наименование"
 with overlay frame frm title "Дополнительные сведения" centered row 5.
 hide frame frm.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите счет:'.
if i <> '' then do:
   find first ftarif2 where string(ftarif2.kont) begins i and substring(ftarif2.num,1,len) = stnum and ftarif2.stat = 'r' no-lock no-error.
   if not avail ftarif2 then do:
     i = ''.
     message ('Такого номера счета здесь нет ! ').
   end.
end. /* if */
end procedure.

