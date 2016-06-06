/* tar2_ak.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора - настройка кодов и сумм тарифов
 * RUN

 * CALLER
        tar_ak.p
 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-6-2
 * AUTHOR
        20.08.02 saltanat
 * BASES
        BANK COMM
 * CHANGES
        27.04.2005 saltanat - Изменила substring(tarif2.num,1,len) = stnum на tarif2.num = stnum в &where
        28.04.05 saltanat - упростила прцедуру tarif2his_update.
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
	    30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        06.11.06 Natalya D. - реализовано: до акцепта новых или изменённых тарифов, будет действовать последний акцептованных тариф
        08.11.06 Natalya D. - при редактировании записи, добавила проверку
        13.12.2011 damir - перекомпиляция в связи с изменением tarif2.f.
        01.08.2013 damir - перекомпиляция в связи с изменением tarif2.f.
*/

{global.i}
{yes-no.i}

def shared var stnum like tarif2.num.
def shared var paka like tarif.pakalp.
def shared var len as int.
def buffer atarif2 for tarif2.
def var rr5 as int.
def shared var rr4 as int.
def new shared var code like tarif2.str5 .
def new shared var tit like tarifex.pakalp .
def new shared var kon like tarifex.kont .
def buffer b-tarif2 for tarif2.
def var v-chng as logical.
def var v-center as logical.
def var v-oldname as char.
def var num_ like tarif2.num.
def var kod_ like tarif2.kod.
def var kont_ like tarif2.kont.
def var pakalp_ like tarif2.pakalp.
def var crc_ like tarif2.crc.
def var ost_ like tarif2.ost.
def var proc_ like tarif2.proc.
def var min1_ like tarif2.min1.
def var max1_ like tarif2.max1.
def var i as char format 'x(6)' init ''.
def buffer ftarif2 for tarif2.

def temp-table t-tarif2 like tarif2.

find first tarif2 where lookup(tarif2.stat,'c,d,n') > 0 no-lock no-error.
if avail tarif2 then message "Имеются неакцептованные записи!" view-as alert-box title "ВНИМАНИЕ!".

find first cmp no-lock no-error.
v-center = (cmp.code = 0).

{apbra.i

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tarif2"
&framename = "tarif2"
&where     = "tarif2.num = stnum and tarif2.nr1 = rr4 and tarif2.stat <> 'a' and (if i <> '' then string(tarif2.kont) begins i else true) "

&addcon    = "true"
&deletecon = "false"

&precreate = " "

&postadd   = " find last atarif2 where atarif2.num = stnum use-index num no-error.
               if available atarif2 then rr5 = integer(atarif2.kod) + 1. else rr5 = 1.
               if rr5 < 10 then tarif2.kod = '0' + string(rr5). else tarif2.kod = string(rr5).
               tarif2.num = stnum .
               tarif2.crc = 0.
               disp tarif2.num tarif2.kod tarif2.crc with frame tarif2.
               update tarif2.kod tarif2.kont tarif2.pakalp tarif2.crc tarif2.ost
               /* ******************************************** tarif2.crc tarif2.ost tarif2.proc tarif2.min1 tarif2.max1 29.09.2003 nadejda */
               with frame tarif2.

               tarif2.str5 = trim(tarif2.num) + trim(tarif2.kod).
               tarif2.nr1  = rr4.
               tarif2.nr   = integer(tarif2.num).
               tarif2.nr2  = integer(tarif2.kod).
               tarif2.whn  = g-today.
               tarif2.who  = g-ofc.
               tarif2.wtim = time.
               tarif2.stat = 'n'.
               run tarif2his_update.
               v-chng = (tarif2.kod entered or tarif2.kont entered or tarif2.pakalp entered or tarif2.crc entered or tarif2.ost entered).
               if v-center and v-chng then run copy2fil.
               /* ******************************************** run deflgot. 29.09.2003 nadejda */
               "

&prechoose = "message 'F4-выход,TAB-исключения,INS-добавить,ENTER-изменить,D-удалить,H-история,F-поиск,X-доп.свед.'."

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

&predelete = " "

&postkey   = "
       else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave:
        run proc_tab.
       end .

       else if keyfunction(lastkey) = 'RETURN' then do:
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

       else if keyfunction(lastkey) = 'X' then do on endkey undo, leave:
        run proc_dopsv.
       end.
       "

&end = "hide frame tarif2."
}
hide message.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- X --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_dopsv.
def var v-punkt as char.
def var v-name as char.

v-punkt = tarif2.punkt.
v-name = tarif2.name.

 update tarif2.punkt format "x(30)" label "Пункт тарифа" skip
        tarif2.name format "x(60)" label "Наименование"
 with overlay frame frm title "Дополнительные сведения" centered row 5.

if (v-punkt ne tarif2.punkt) or (v-name ne tarif2.name) then do:
      tarif2.whn    = g-today.
      tarif2.who    = g-ofc.
      tarif2.wtim   = time.
      tarif2.akswho = ''.
      tarif2.akswhn = ?.
      tarif2.awtim  = 0.
      tarif2.delwho = ''.
      tarif2.delwhn = ?.
      tarif2.dwtim  = 0.
      tarif2.stat   = 'c'.
 run tarif2his_update.
 hide frame frm.
end.

 hide frame frm.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- TAB --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_tab.
 code = tarif2.str5.
 tit = tarif2.pakalp.
 kon = tarif2.kont.
 run tar2_aex.
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- RETURN --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_return.

if yes-no('',' Вы действительно хотите изменить данные? ') then do:

 kod_    = tarif2.kod.
 kont_   = tarif2.kont.
 pakalp_ = tarif2.pakalp.
 crc_    = tarif2.crc.
 ost_    = tarif2.ost.
 proc_   = tarif2.proc.
 min1_   = tarif2.min1.
 max1_   = tarif2.max1.
/* find current tarif2 exclusive-lock.*/
 find first t-tarif2 no-error.
 if avail t-tarif2 then delete t-tarif2.
 create t-tarif2.
 buffer-copy tarif2 to t-tarif2.
 /*release tarif2.*/
 do transaction on endkey undo, leave:
    v-oldname = tarif2.pakalp.
    update
         tarif2.kod
         tarif2.kont
         tarif2.pakalp
         tarif2.crc
         tarif2.ost
         tarif2.proc
         tarif2.min1
         tarif2.max1
    with frame tarif2 .
    if (kod_ ne tarif2.kod) or (kont_ ne tarif2.kont) or (pakalp_ ne tarif2.pakalp) or (crc_ ne tarif2.crc) or
       (ost_ ne tarif2.ost) or (proc_ ne tarif2.proc) or (min1_ ne tarif2.min1) or (max1_ ne tarif2.max1) then do:
      tarif2.nr     = integer(tarif2.num).
      tarif2.nr2    = integer(tarif2.kod).
      tarif2.str5   = trim(tarif2.num) + trim(tarif2.kod).
      tarif2.nr1    = rr4.
      tarif2.whn    = g-today.
      tarif2.who    = g-ofc.
      tarif2.wtim   = time.
      tarif2.akswho = ''.
      tarif2.akswhn = ?.
      tarif2.awtim  = 0.
      tarif2.delwho = ''.
      tarif2.delwhn = ?.
      tarif2.dwtim  = 0.
      tarif2.stat   = 'c'.
      run tarif2his_update.
    end. /* changed*/
    if tarif2.kont entered or tarif2.crc entered or (tarif2.pakalp entered and v-oldname begins 'N/A') or
       tarif2.ost entered or tarif2.proc entered or tarif2.min1 entered or tarif2.max1 entered then run deflgot.
    v-chng = (tarif2.kod entered or tarif2.kont entered or tarif2.pakalp entered or tarif2.crc entered or tarif2.ost entered).
 end.
 if t-tarif2.stat = 'r' or t-tarif2.stat = 'd' then do:
 for each t-tarif2 where t-tarif2.nr = tarif2.nr and t-tarif2.nr1 = tarif2.nr1 and t-tarif2.nr2 = tarif2.nr2 no-lock.
   create tarif2.
   buffer-copy t-tarif2 to tarif2.
 end.
 end.

 if v-center and v-chng then run copy2fil.
end. /* yes */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- DEL --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_del.
if yes-no('',' Вы действительно хотите удалить запись? ') then do:
/* for each tarifex where tarifex.str5 = tarif2.str5 exclusive-lock:
 if avail tarifex then do:
    tarifex.delwho = g-ofc.
    tarifex.delwhn = g-today.
    tarifex.dwtim  = time.
    tarifex.akswho = ''.
    tarifex.akswhn = ?.
    tarifex.awtim  = 0.
    tarifex.stat   = 'd'.
    run tarifexhis_update.
 end.
 end .  */
 find first t-tarif2 no-error.
 if avail t-tarif2 then delete t-tarif2.
 create t-tarif2.
 buffer-copy tarif2 to t-tarif2.

 tarif2.delwho = g-ofc.
 tarif2.delwhn = g-today.
 tarif2.dwtim  = time.
 tarif2.akswho = ''.
 tarif2.akswhn = ?.
 tarif2.awtim  = 0.
 tarif2.stat   = 'd'.
 run tarif2his_update.

 for each t-tarif2 where t-tarif2.nr = tarif2.nr and t-tarif2.nr1 = tarif2.nr1 and t-tarif2.nr2 = tarif2.nr2 no-lock.
   create tarif2.
   buffer-copy t-tarif2 to tarif2.
 end.
 release tarif2.
end. /* yes */
end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- HISTORY --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_his.
    displ tarif2.who    column-label 'Внес.'      format 'x(10)'
          tarif2.whn    column-label 'Дата вн.'
          tarif2.akswho column-label 'Акцепт.'    format 'x(10)'
          tarif2.akswhn column-label 'Дата акц.'
    with overlay centered row 10 title 'История' frame ff.
hide frame ff.

if yes-no('',' Хотите просмотреть полную историю? ') then do:

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
  put unformatted tarif2his.num                                                           ';'
                  tarif2his.kod                                                           ';'
                  tarif2his.kont                                                          ';'
                  tarif2his.pakalp                                                        ';'
                  tarif2his.crc                                                           ';'
                  tarif2his.ost                                                           ';'
                  tarif2his.proc                                                          ';'
                  tarif2his.min1                                                          ';'
                  tarif2his.max1                                                          ';'
                  tarif2his.who                                                           ';'
                  if tarif2his.whn = ? then '' else string(tarif2his.whn)                 ';'
                  if tarif2his.wtim = 0 then '' else string(tarif2his.wtim,'hh:mm:ss')    ';'
                  tarif2his.akswho                                                        ';'
                  if tarif2his.akswhn = ? then '' else string(tarif2his.akswhn)           ';'
                  if tarif2his.awtim = 0 then '' else string(tarif2his.awtim, 'hh:mm:ss') ';'
                  tarif2his.delwho                                                        ';'
                  if tarif2his.delwhn = ? then '' else string(tarif2his.delwhn)           ';'
                  if tarif2his.dwtim = 0 then '' else string(tarif2his.dwtim, 'hh:mm:ss') ';'
                  tarif2his.stat                                                          skip.
end.
output close.
unix silent cptwin vcdata.csv excel.
end. /* yes-no*/

end procedure.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите счет:'.
if i <> '' then do:
   find first ftarif2 where string(ftarif2.kont) begins i and substring(ftarif2.num,1,len) = stnum and ftarif2.nr1 = rr4 and ftarif2.stat <> 'a' no-lock no-error.
   if not avail ftarif2 then do:
     i = ''.
     message ('Такого номера счета здесь нет ! ').
   end.
end. /* if */
end procedure.

procedure deflgot.
  def var p-ans as logical init yes.
  if not tarif2.pakalp begins "N/A" then do:
    /* поискать клиентов с льготным обслуживанием */
    find first cif where cif.pres <> "" no-lock no-error.
    if avail cif then do:
      message skip " Найдены клиенты по группам льготного обслуживания !"
              skip(1) " Пересчитать данный тариф для групп льготного обслуживания ?"
              skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update p-ans.

      if p-ans then do:
        /* по всем группам запустить пересчет льготы для данного тарифа */
        for each codfr where codfr.codfr = "clnlgot" and codfr.code <> "msc" no-lock:
          run value("clnlgot-" + codfr.code) ("", tarif2.str5, yes).
        end.
      end.
    end.
  end.
end.


/* 29.09.2003 nadejda - переписать важные изменения с головного на филиалы */
procedure copy2fil.
  for each txb where txb.consolid and txb.is_branch no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password).
    run tarif2fil.p (tarif2.num, tarif2.kod, txb.bank).
    disconnect "ast" no-error.
    if error-status:error then do: message " Connected!". pause. end.
    pause 0.
  end.
end procedure.

/* ---- процедура сохранения истории ---- */
procedure tarif2his_update.
	create tarif2his.
	buffer-copy tarif2 to tarif2his.
end procedure.


