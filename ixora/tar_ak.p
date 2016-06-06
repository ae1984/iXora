/* tar_ak.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
        tar2_ak.p, tar2_b.p
 * MENU
        9-1-2-6-2
 * AUTHOR
        20.08.04 saltanat
 * CHANGES
        28.04.05 saltanat - упростила прцедуру tarifhis_update.
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
        08.11.06 Natalya D. - при редактировании записи, добавила проверку
        27.10.2011 damir - перекомпиляция.
        13.12.2011 damir - перекомпиляция в связи с изменением tarif.f.
*/

{global.i}
{yes-no.i}

def new shared var stnum like tarif2.num.
def new shared var paka like tarif.pakalp.
def new shared var len as int.
def new shared var rr4 as int.
def var num_ like tarif.num.
def var nr_ like tarif.nr.
def var pakalp_ like tarif.pakalp.
def var i as char format 'x(3)' init ''.
def buffer ftarif for tarif.

def temp-table t-tarif like tarif.

find first tarif where lookup(tarif.stat,'c,d,n') > 0 no-lock no-error.
if avail tarif then message "Имеются неакцептованные записи!" view-as alert-box title "ВНИМАНИЕ!".


{apbra.i

&start     = " "
&head      = "tarif"
&headkey   = "tarif"
&index     = "nr"

&formname  = "tarif"
&framename = "tarif"
&where     = "tarif.stat <> 'a' and (if i <> '' then tarif.num begins i else true) "

&addcon    = "true"
&deletecon = "false"
&predelete = " "

&precreate = " "

&postadd   = " update tarif.num
                      tarif.nr
                      tarif.pakalp
                      with frame tarif.
                      tarif.nr1 = integer(tarif.num).
                      tarif.who = g-ofc.
                      tarif.whn = g-today.
                      tarif.wtim = time.
                      tarif.stat = 'n'.
               run tarifhis_update. "
&prechoose =
 " message 'F4-выход, TAB-выбор, INS-добавить, ENTER-изменить, D-удалить, H-история, F-поиск'."
&predisplay = " "

&display   = " tarif.num
               tarif.nr
               tarif.pakalp label 'Услуга' "

&highlight = " tarif.num tarif.nr tarif.pakalp "


&postkey   = "
             else if keyfunction(lastkey) = 'TAB' then do on endkey undo, leave:
                 run proc_tab.
             end.
             else if keyfunction(lastkey) = 'RETURN' then do on endkey undo, leave:
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

&end = "hide frame tarif. "
}
hide message.


/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- TAB --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_tab.

 paka = tarif.pakalp.
 stnum = tarif.num.
 rr4 = tarif.nr.
 len = length(num).
 if rr4 <> 0 then RUN tar2_ak.
             else run tar2_b.

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- RETURN --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_return.

if yes-no('',' Вы действительно хотите изменить данные? ') then do:
 num_ = tarif.num.
 nr_ = tarif.nr.
 pakalp_ = tarif.pakalp.
 find first t-tarif no-error.
 if avail t-tarif then delete t-tarif.
 create t-tarif.
 buffer-copy tarif to t-tarif.
 update tarif.num  tarif.nr tarif.pakalp with frame tarif.
 if (num_ ne tarif.num) or (nr_ ne tarif.nr) or (pakalp_ ne tarif.pakalp) then do:
    tarif.nr1    = integer(tarif.num).
    tarif.who    = g-ofc.
    tarif.whn    = g-today.
    tarif.wtim   = time.
    tarif.akswho = ''.
    tarif.akswhn = ?.
    tarif.awtim  = 0.
    tarif.delwho = ''.
    tarif.delwhn = ?.
    tarif.dwtim  = 0.
    tarif.stat   = 'c'.
    run tarifhis_update.
   /*release tarif.*/
 if t-tarif.stat = 'r' or t-tarif.stat = 'd' then do:
 for each t-tarif where t-tarif.nr = tarif.nr and t-tarif.num = tarif.num no-lock.
   create tarif.
   buffer-copy t-tarif to tarif.
 end.
 end.
 end.
end.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- DEL --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_del.
if yes-no('',' Вы действительно хотите удалить запись? ') then do:
  /*find current tarif exclusive-lock.*/
  find first t-tarif no-error.
 if avail t-tarif then delete t-tarif.
  create t-tarif.
  buffer-copy tarif to t-tarif.
  tarif.akswho = ''.
  tarif.akswhn = ?.
  tarif.awtim  = 0.
  tarif.delwho = g-ofc.
  tarif.delwhn = g-today.
  tarif.dwtim  = time.
  tarif.stat   = 'd'.
  run tarifhis_update.
  /*release tarif.*/
  for each t-tarif where t-tarif.nr = tarif.nr and t-tarif.num = tarif.num no-lock.
   create tarif.
   buffer-copy t-tarif to tarif.
  end.
end. /* yes */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.

    displ tarif.who    column-label 'Внес.'
          tarif.whn    column-label 'Дата вн.'
          tarif.akswho column-label 'Акцепт.'
          tarif.akswhn column-label 'Дата акц.'
    with overlay centered row 8 title 'История' frame ff.

hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

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
end. /* yes-no*/

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер группы:'.
if i <> '' then do:
   find first ftarif where ftarif.num begins i and ftarif.stat <> 'a' no-lock no-error.
   if not avail ftarif then do:
     i = ''.
     message ('Такого номера здесь нет ! ').
   end.
end. /* if */
end procedure.

/* ---- процедура сохранения истории ---- */
procedure tarifhis_update.
	create tarifhis.
	buffer-copy tarif to tarifhis.
end procedure.

