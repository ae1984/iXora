/* tar2_aex.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        tar2_ak.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1-2-6-2
 * AUTHOR
        20.08.2004 saltanat
 * BASES
        BANK COMM
 * CHANGES
        28.03.05 saltanat - Предусмотрела, чтобы один из видов архивных льгот (sts = 'h') не выходил на экран.
        28.04.05 saltanat - упростила процедуру tarifexhis_update.
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
        08.11.06 Natalya D. - при редактировании записи, добавила проверку
        15.12.2011 damir - перекомпиляция в связи с изменением tarifex.f.
        01.08.2012 damir - перекомпиляция в связи с изменением tarifex.f.
*/

{yes-no.i}

def shared var g-lang as char.
def shared var paka like tarif.pakalp.
def shared var len as int.
def buffer atarifex for tarifex.
def var rr5 as int.
def shared var rr4 as int.
def shared var g-ofc like tarifex.who.
def shared var g-today like tarifex.whn.
def shared var code like tarifex.str5 .
def shared var tit like tarifex.pakalp .
def shared var kon like tarifex.kont .
def buffer b-tarifex for tarifex.
def new shared var cif_    like tarifex.cif.
def new shared var kont_   like tarifex.kont.
def new shared var pakalp_ like tarifex.pakalp.
def new shared var ost_    like tarifex.ost.
def new shared var proc_   like tarifex.proc.
def new shared var max1_   like tarifex.max1.
def new shared var min1_   like tarifex.min1.
def new shared var crc_    like tarifex.crc.
def var i as char format 'x(6)' init ''.
def buffer ftarifex for tarifex.
def var v-nests as char init 'a,h'. /* Статусы которые не должны выходить на экран */

def temp-table t-tarifex like tarifex.

find first tarifex where lookup(tarifex.stat,'c,d,n') > 0 no-lock no-error.
if avail tarifex then message "Имеются неакцептованные записи!" view-as alert-box title "ВНИМАНИЕ!".


{apbra.i
&start     = " "
&head      = "tarifex"
&headkey   = "tarifex"
&index     = "main"

&formname  = "tarifex"
&framename = "tarifex"
&where     = "tarifex.str5 = code and lookup(tarifex.stat,v-nests) = 0 and (if i <> '' then tarifex.cif begins i else true) "

&addcon    = "true"
&deletecon = "false"

&precreate = " "

&postadd   = "
               tarifex.str5 = code .
               tarifex.kont = kon .
               tarifex.pakalp = tit .
               disp tarifex.kont with frame tarifex.
               update tarifex.cif validate(can-find(cif where cif.cif = tarifex.cif), 'Invalid CIF!')
                      tarifex.pakalp
                      tarifex.crc
                      tarifex.ost tarifex.proc tarifex.min1 tarifex.max1
               with frame tarifex .
               tarifex.whn  = g-today.
               tarifex.who  = 'M' + g-ofc.  /* признак 'установлено вручную или по временным льготным тарифам' */
               tarifex.wtim = time.
               tarifex.stat = 'n'.
               run tarifexhis_update. "

&prechoose = "message 'F4-выход,INS-добавить,D-удалить,ENTER-изменить,H-история,F-поиск,TAB-льготы по сч.'."

&predisplay = " "

&predelete = " tarifex.akswho = ''.
               tarifex.akswhn = ?.
               tarifex.awtim  = 0.
               tarifex.delwho = g-ofc.
               tarifex.delwhn = g-today.
               tarifex.dwtim  = time.
               tarifex.stat   = 'd'.
               run tarifexhis_update. "

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
 run tar2_aex2.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- RETURN --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_return.

if yes-no('',' Вы действительно хотите изменить данные? ') then do:
 cif_    = tarifex.cif.
 kont_   = tarifex.kont.
 pakalp_ = tarifex.pakalp.
 crc_    = tarifex.crc.
 ost_    = tarifex.ost.
 proc_   = tarifex.proc.
 min1_   = tarifex.min1.
 max1_   = tarifex.max1.

 find first t-tarifex no-error.
 if avail t-tarifex then delete t-tarifex.
 create t-tarifex.
 buffer-copy tarifex to t-tarifex.

 do transaction on endkey undo, leave:
    update
        tarifex.cif
        tarifex.kont
        tarifex.pakalp
        tarifex.crc
        tarifex.ost
        tarifex.proc
        tarifex.min1
        tarifex.max1
    with frame tarifex .
    tarifex.whn = g-today.
    tarifex.who = 'M' + g-ofc.
    tarifex.wtim = time.
    displ substr(tarifex.who, 1, 1) @ v-am with frame tarifex.
 end.

 if (cif_ ne tarifex.cif) or (kont_ ne tarifex.kont) or (pakalp_ ne tarifex.pakalp) or
    (crc_ ne tarifex.crc) or (ost_ ne tarifex.ost) or (proc_ ne tarifex.proc) or
    (min1_ ne tarifex.min1) or (max1_ ne tarifex.max1) then do:
    tarifex.akswho = ''.
    tarifex.akswhn = ?.
    tarifex.awtim  = 0.
    tarifex.delwho = ''.
    tarifex.delwhn = ?.
    tarifex.dwtim  = 0.
    tarifex.stat   = 'c'.
    run tarifexhis_update.
 end. /* if changed */
 if t-tarifex.stat = 'r' or t-tarifex.stat = 'd' then do:
 for each t-tarifex where t-tarifex.str5 = tarifex.str5 and t-tarifex.cif = tarifex.cif no-lock.
   create tarifex.
   buffer-copy t-tarifex to tarifex.
 end.
 end.
end.  /* yes */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
    displ tarifex.who    column-label 'Внес.'
          tarifex.whn    column-label 'Дата вн.'
          tarifex.akswho column-label 'Акцепт.'
          tarifex.akswhn column-label 'Дата акц.'
    with overlay centered row 10 title 'История' frame ff.

hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

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

for each tarifexhis where tarifexhis.cif = tarifex.cif and tarifexhis.kont = tarifex.kont and tarifexhis.str5 = code no-lock by tarifexhis.whn by tarifexhis.wtim:
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
end. /* yes-no*/

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- DEL --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_del.
if yes-no('',' Вы действительно хотите удалить запись? ') then do:

 find first t-tarifex no-error.
 if avail t-tarifex then delete t-tarifex.
 create t-tarifex.
 buffer-copy tarifex to t-tarifex.

 tarifex.delwho = g-ofc.
 tarifex.delwhn = g-today.
 tarifex.dwtim  = time.
 tarifex.akswho = ''.
 tarifex.akswhn = ?.
 tarifex.awtim  = 0.
 tarifex.stat   = 'd'.
 run tarifexhis_update.

 for each t-tarifex where t-tarifex.str5 = tarifex.str5 and t-tarifex.cif = tarifex.cif no-lock.
   create tarifex.
   buffer-copy t-tarifex to tarifex.
 end.
 release tarifex.

end. /* yes */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер клиента:'.
if i <> '' then do:
   find first ftarifex where ftarifex.cif begins i and ftarifex.stat <> 'a' no-lock no-error.
   if not avail ftarifex then do:
     i = ''.
     message ('Такого клиента здесь нет ! ').
   end.
end. /* if */
end procedure.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
	create tarifexhis.
	buffer-copy tarifex to tarifexhis.
end procedure.


