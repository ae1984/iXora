/* v-stat2.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       08.04.2004 tsoy добавил начисление процентов по БК
       04.08.2005 dpuchkov добавил автоматическую оплату инкассовых распоряжений (Запускается раз в день после старта всех процессов)
       15.09.2005 dpuchkov добавил автоматический перевод % с депозитов на пласт карты.
       28.12.2005 dpuchkov добавил формирование RMZ по выплате % с депозитов юр. лиц.
       24.07.2006 Natalya D. добавила автоматическую продажу runautosl
       27.07.2006 Natalya D. добавила: авт.продажа отрабатывает только на Алмате
       29/08/06 u00121 заменил nawk на awk
       02.10.2006 Natalya D. добавила рассылку сообщений для урегулирования диспутных сумм.
       26/03/2009 madiyar - рассылка распоряжений по курсам валют
       25/09/2009 madiyar - увеличил фрейм
       31/01/2011 id00004 - добавил обновление данных на портале
       03/02/2011 id00810 - импорт swift-сообщений по аккредитивам и чистка каталога
       21.04.2011 aigul - убрала автоматическую рассылку в 9 утра по курсам валют
       28.05.2012 evseev - загрузка статреестра
       24/10/2012 madiyar - выключил запуск runprem - нет займов с 3 схемой, и не будет
       23/11/2012 k.gitalov - синзронизация que и sts при старте ПС.
*/

def var v-scan as cha .
def var tt as cha
view-as editor INNER-CHARS 32  INNER-LINES 19  SCROLLBAR-VERTICAL .
def new shared temp-table fltr field pid like que.pid
  column-label "Код"
  field v as cha label "Показать"  .
def var i-fltr as cha extent 2 .
def temp-table scan field  scan as cha extent 2 .
def buffer b-dproc for dproc .
def var yn as log initial false format "да/нет".
def var dd as int .
def var v-nwt as int  .
def var tpause as int .
def var del as log .
def var v-dproc as cha format "x(1)" .
def var leav as log .
def var i as int .
def var rold like dproc.pid .
def var ttt as int .
 {mainhead.i "PSMAN " "NEW GLOBAL" }
 {ps-prmt.i}
def var rsts like que.pid .
def var nnn as cha .
def var vv as cha format "x(3)" .
def var v-pause as int .
def new shared var s-remtrz like que.remtrz.
def var s-remtrzR like que.remtrz.
def var s-quepid like fproc.pid .
def var s-quetyp like ptyp.ptype .
def var tmp as cha.
def new shared frame pid.
def var v-pid like que.pid.

def new shared var v-log as cha .
def var v-copy as integer.
{lgps.i "new" }
m_pid = "PS_".
u_pid = "v-stat".
def var cikl as int.
def new shared var idle as cha .
def var ifi as int.
def var swt as cha .
def var spt as cha .
def var sft as cha .
def new shared var h as int .
def var s-date as date .
def var s-time as int .
def var hp as int .
def var l-leave as log .
s-date = today .
s-time = time .
vv = "-" .
h  = 30 .
hp = 30 .
def var hhlp as int .
hhlp = 37.


find sysc where sysc.sysc = "ps-cls" no-lock no-error .
if not avail sysc or string(sysc.daval) = ? then do:
 message " Не найдена запись PS-CLS в настроечном (sysc) файле !!".
 bell. bell.
 pause .   return .
end.
find last cls .
if not ( cls.cls eq sysc.daval) then do:
 display " Внимание !!! Последний закрытый ПС день : " +
   string(sysc.daval) format "x(46)" skip(0)
  " не соответствует операционному дню !! " with centered
   row 10  frame warn . bell . bell .
   pause .
   hide frame warn .
 end .

tpause = 100.
for each fproc no-lock .
create fltr .
 fltr.pid = fproc.pid .
 fltr.v = "*" .
end.

if search(".psman.flt") = ".psman.flt" then do:
input from \.psman.flt .
for each fproc no-lock .
 import i-fltr .
 find first fltr where fltr.pid = i-fltr[1] no-error .
 if avail fltr then fltr.v = i-fltr[2] .
end.
input close.
end.

form
 " " sts.pid  column-label "Код" format 'x(5)'
 sts.nw column-label "Ожидает" format "zzzzz9" dd format "zz9"
 label "Дни" swt label " Время ожидания " format "x(15)"
 with row 3 column 3 overlay no-hide hp down frame sts1.

display "  Ж д и т е " with centered overlay frame bbb . pause 0.
for each dproc where dproc.u_pid = 0 no-lock.
 do transaction  .
  find first b-dproc where recid(b-dproc) = recid(dproc) exclusive-lock.
  v-text = "Удалено: " + dproc.pid + " " + string(dproc.u_pid)  .
  run lgps .
  delete b-dproc .
 end.
 release b-dproc .
end .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " Не найдена запись OURBNK в sysc файле !!".
 pause .
end.

m_hst = trim(sysc.chval).

find first dproc no-lock no-error .
if avail dproc then do:
input through value("ps_ls_pid " + trim(m_hst)) .

 repeat:
  create scan.
  import scan.
  v-scan = v-scan + scan[1] + " " + scan[2] + " ! ".
 end.
 input close.

for each dproc no-lock  .
del = true .
find first scan where scan[2] begins
    trim(m_hst) + "_" +  trim(dproc.pid) + "_" + string(dproc.copy,"99")
    and scan[1] = string(dproc.u_pid) no-error .
    if avail scan
    then do :
     del = false .
     delete scan .
    end.
 if del then  do transaction :
  find first b-dproc where recid(b-dproc) = recid(dproc) exclusive-lock .
   v-text = "Удалено: b-dproc " + dproc.pid + " " + string(dproc.u_pid)  .
   run lgps .
   delete b-dproc  .
   for each scan .
    v-text  = scan[1] + " " + scan[2] .
    run lgps.
   end.
    v-text = "V-SCAN = " + v-scan .
    run lgps.
 end.   release b-dproc.
end .
for each scan . delete scan . end .
end.

hide frame bbb.

form " " dproc.pid column-label "Процeсс" format 'x(5)'
 dproc.copy label "Nr" dproc.tout label "Пауза"  dproc.u_pid
 column-label "Unix_Id"
 idle
 label "Простой" v-dproc  no-label with column 40 h down title m_hst overlay
frame pid. /*
view frame pid.
*/
pause 0.

rold = "" .
rsts = "" .

cikl = 0.
repeat :

/*
display
  "F1- PSMAN помощь,F2- помощь по системе"
    with row hhlp col 20 width 100 no-box frame mm.
 pause 0 .
*/

/*
 display
 "H - log , J - quest , P/T - search by pid/type , F8/F9 - proc.start/stop."
    with row 20 column 5 no-box frame mm1.
 display
 "HOME - all proc. stop , END - exit , ^t - MONITOR STEP , F2 - help ."
    with rofw 21 column 5 no-box frame mm2.
   */

repeat:
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message "  Не найдена запись OURBNK в настроечном (sysc) файле !!" .
 pause .
end.

m_hst = trim(sysc.chval).

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message  " Не найдена запись PS-LOG в настроечном (sysc) файле !!" .
 pause .
end.

v-log = trim(sysc.chval).
display "Время старта:" s-date string(s-time,"hh:mm:ss")
 with no-box no-label overlay row 1 frame stime.
pause 0 .
 display "Текущее время:" today string(time,"hh:mm:ss")
  with no-box no-label no-hide row 1 column 40 overlay frame ttt .
  pause 0.
  g-fname = "PSMAN ".
  g-mdes = " Менеджер платежной системы".

 display
  g-fname g-mdes g-ofc  g-today
  with color message frame mainhead.
 ttt = time .
 ifi = 0 .
 display "  Ждите..."  format "x(20)"  with row hhlp column 60 no-box overlay
   frame www  . pause 0 .
 cikl = cikl + 1.

find first sts where sts.nw + sts.nf > 0
  and can-find(first fltr where fltr.pid = sts.pid and fltr.v = "*")
 no-lock no-error .
if avail sts then do:
 for each sts where sts.pid >= rsts and sts.nw + sts.nf > 0
  and can-find(first fltr where fltr.pid = sts.pid and fltr.v = "*") no-lock
  break by   sts.pid .
 /*
  find first fltr where fltr.pid = sts.pid no-error .
  if avail fltr and fltr.v = "" then next .  */
  dd = 0 .
  if sts.nw + sts.nf ne 0 then
  v-nwt = ( time - sts.upd + (today - sts.dupd ) * 86400 ) +
   sts.nwt  / (sts.nw + sts.nf ) .  else v-nwt = 0 .
  repeat :
                                                    /*
   display v-nwt with overlay frame aa.
   pause 0 .
                                                    */
   if v-nwt < 86400 then leave .
   dd = dd + 1 .
   v-nwt = v-nwt - 86400  .
  end.
  swt = "   " + string(v-nwt,"hh:mm:ss").
  display sts.pid sts.nw dd swt /* sts.np  spt sts.nf  */
     with frame sts1.
  down with frame sts1.
  ifi = ifi + 1.
  rsts = "".
  if ifi = hp then do:
   if not last(sts.pid) then do:
    rsts = sts.pid .
    leave .
    end .
   end.
  pause 0.
end.
do i = ifi + 1  to hp :
 clear frame sts1 .
 down with frame sts1.
end.
ifi = i - 1 .
 do i = 1 to ifi :
  up 1 with frame sts1.
 end .
end.
else
 do :
   hide frame sts1.
   message " Очереди пусты..."  . pause 1 . v-pause = 1 .
 end .
pause 0.
find first dproc no-lock no-error .
if avail dproc then do:
ifi = 0.
for each dproc no-lock where dproc.pid ge rold
                       break by dproc.pid by dproc.copy .
 if dproc.l_time ne 0 then
   idle = string(time - dproc.l_time,"hh:mm:ss").
 else idle = "--:--:--".
 v-dproc = substr(dproc.hst,1,1) .
  if dproc.l_time ne 0 then
   idle = string(time - dproc.l_time,"hh:mm:ss").
 else idle = "--:--:--".
 if ((dproc.tout ne 77777 and time - dproc.l_time  > dproc.tout * 3)
    or (dproc.tout eq 77777 and dproc.hst ne "wait" and
     time - dproc.l_time  > 30 )) and
     (g-ofc = "pnp" or g-ofc = "superman") then
     do:
       do i = 1 to 300 :
        bell .
       end.
       display  "Процесс " + dproc.pid + " приостановлен"
       format "x(25)" with column 18
       5 down  row 5 overlay title " Внимание !! " frame susp .
       pause 10.
       hide frame susp .
     end.

 display dproc.pid format 'x(5)' dproc.copy dproc.tout dproc.u_pid idle v-dproc with frame
pid.  ifi = ifi + 1.
 down with frame pid .
 v-pause = 0.
 rold = "" .
 if ifi = h then do:
  if not last(dproc.copy) then do:
   rold = dproc.pid .
   leave .
   /*
    pause 3 .
    ifi = i - 1 .
    do i = 1 to ifi :
     up 1 with frame pid.
    end .
    ifi = 0 .
   */
  end .
 end.
 pause 0 .
 release dproc .
 end.
 do i = ifi + 1  to h :
  clear frame pid .
  down with frame pid.
 end.

ifi = i - 1 .
do i = 1 to ifi :
 up 1 with frame pid.
end .

end .
else hide frame pid .

if vv = "///" then vv = "\\\\\\" .
else
if vv = "\\\\\\" then vv = "---" .
else
if vv = "---" then vv = "///" .
else vv = "---".
hide frame www .
display tpause vv with overlay no-box no-label col 3 row hhlp no-hide frame vvv.
pause 0.

 s-remtrz = "".
 l-leave = false .
 if tpause = 0 then tpause = 1 .


display
  "F1- PSMAN помощь,F2- помощь по системе"
    with row hhlp col 20 width 40 no-box frame mm.
         pause 0 .

 readkey pause tpause  .
 /*
 hide frame mm .
 hide frame vvv .
 */
 /*
  display " W A I T ..." with row hhlp no-box frame www  .
 */

 if keyfunction(lastkey) = "right-end" /* or
      keylabel(lastkey) = "f4"  or
      keylabel(lastkey) = "pf4" */ then return.
 pause 0 .
 if keyfunction(lastkey) ne "" then l-leave = true .
 if keylabel(lastkey) = "ctrl-l" then
  do:
   update tpause  label " Пауза (сек) ? "
    with centered row 10 side-label overlay frame tpp .
  end.
 if keyfunction(lastkey) = "clear" then do:
  {ps-prmtk.i}
 update v-pid  label " Код процесса ? " format 'x(5)'
    v-copy label       " Номер копии  ? "
    with row 5 side-label 1 column column 5 title " Запустить "  frame upd.
  v-pid = caps(v-pid).
  find fproc where fproc.pid = v-pid no-lock no-error.
   if not avail fproc then do:
     message "Нет описания процесса в 'fproc' файле ! " .
     pause .
    end.
    else
    do:
    if search("/pragma/bin9/u_pid") ne ? then
    unix silent value("/pragma/bin9/u_pid " + m_hst + " " + v-pid + " " +
      string(v-copy,"99") + " " + v-log ).
      else do:
      message " u_pid script не найден !! . " . pause . end .
    end.

   clear frame upd all.
 end.

 if keylabel(lastkey) = "ctrl-p" then do:
  {ps-prmtk.i}
  
  
 v-copy = 0.
 display " .Старт всех процессов ... " with centered frame www1.  pause 0 .
 for each fproc where fproc.tout ne 1000 :
  pause 2 no-message .
  v-pid = caps(fproc.pid).
  if search("/pragma/bin9/u_pid") ne ? then
  unix silent value("/pragma/bin9/u_pid " + m_hst + " " + v-pid + " " +
   string(v-copy,"99") + " " + v-log ).
   else do:
      message " u_pid script не найден !! . " . pause . end .
 end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
     if not avail sysc or sysc.chval = "" then do:
         display " This isn't record OURBNK in bank.sysc file !!".
         pause.
     end.
 if trim(sysc.chval) = 'TXB00' then do:
     run runautosl.
     run runlcmt.
 end.

 clear frame www1 .


 /*comm должен быть запущен*/
 display " Автоматическая Регистрация инкассовых распоряжений! " with centered frame www2.  pause 0 .
 run inkclose.

 find sysc where sysc.sysc = "ourbnk" no-lock no-error .
 if avail sysc and trim(sysc.chval) = "TXB00" then do:
    display " Автоматическая загрузка Статистического реестра! " with centered frame www2.  pause 0 .
    run loadnkstatreg("","").
 end.

 /**/
 if trim(sysc.chval) = 'TXB00' then do:
    display " Обновление данных по кредитам на портале " with centered frame www2.  pause 0 .
    run crdinfo.
 end.

 end.

 if keyfunction(lastkey) = "new-line" then do transaction :
  {ps-prmtk.i}
  update v-pid  label " Код процесса ? " format 'x(5)'
   v-copy label       " Номер копии  ? "
   with row 5 side-label 1 column column 5 title " Остановить "  frame updb.
  v-pid = caps(v-pid).
  find dproc where dproc.pid = v-pid and dproc.copy = v-copy
   exclusive-lock no-error.
  if avail dproc then do:
   dproc.tout = 1000.
     unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
   clear frame updb all.
  end.
  release dproc .
 end.

 if keylabel(lastkey) = "h" then do:
  input through value
  ("awk -v d=" + string(today) + " '
   (index($0,d) != 0) \{print NR;exit\} ' " +
    v-log + trim(m_hst) + "_logfile.lg." + string(today,"99.99.9999"))  . /*29/08/06 u00121 заменил nawk на awk*/
   nnn = "" .
   repeat:
    import nnn .
   end.
   input close .
  if nnn = "" then nnn = "0" .
  unix value("ps_lessh " + "+" + nnn + " " +
   v-log + trim(m_hst) + "_logfile.lg." + string(today,"99.99.9999")).
  pause 0 .
 end.

 if keylabel(lastkey) = "p" then do:
  run q-quepid.
  if keylabel(lastkey) = "cursor-up" or  keylabel(lastkey) = "cursor-down"
     then next.
 end.

  if keylabel(lastkey) = "f" then do:
     do:
      hide frame mm .
      hide frame vvv .
      display
 "<spase > - выбор , <A> - выбрать все, <Q> - исключить все " skip
 "<F6> -сохранить, <F1> - выход"  with row 20 column 5 no-box centered frame ff.
      pause 0 .
      run fltr.
     end.
     rsts = "" .
     leave .
  end.

 if keyfunction(lastkey) = "go" then do:
 hide frame mm .
  tt =
  " ====== ПС Менеджер помощь ==== " +
  " Старт всех процессов ....  ^P  " +
  " Настройки ПС ............   S  " +
  " Просмотр протокола ПС ...   H  " +
  " Протокол по запросу .....   J  " +
  " Поиск платежей по очереди   P  " +
  " Поиск платежей по ссылке.   R  " +
  " Старт процесса ..........  F8  " +
  " Остановка процесса ......  F9  " +
  " Помощь по банк.системе...  F2  " +
  " Запрос по вход. платежам.  ^U  " +
  " Запрос по исх.  платежам.  ^O  " +
  " Остановка всех процессов. Home " +
  " Фильтр для очередей .....   F  " +
  " Отвергнутые платежи .....   O  " +
  " Пауза для мониторинга ...  ^L  " +
  " Просмотр ВСЕХ очередей ..   X  " +
  " Выход....................  END " .
  update tt no-label   with overlay row 1 centered  no-box
  frame  mm2.
    pause .
    hide frame mm2 .
    view frame mm .
    pause 0 .
 end.

 if keylabel(lastkey) = "r" then do:
  update s-remtrzR no-label
    with overlay centered row 10 title "Платеж" frame rm.
  find first remtrz where remtrz.remtrz = s-remtrzR no-lock no-error .
  if avail remtrz then do:
  s-remtrz = caps(s-remtrzR).
  hide frame rm .
  if s-remtrz ne "" and keylabel(lastkey) ne "pf4" then do:
/*  display s-remtrz .     */
  run rmz_ps.
  release remtrz.
  end.
  end.
 end.

 if keyfunction(lastkey) = "help" then do:
   if search( "pshelp.r") ne ? then
              do:
               hide  all .
               run pshelp.
              end.
              else
     do:
      message " Процедура pshelp не найдена   ".
      pause .
     end.
 end.

 if keyfunction(lastkey) = "x" then do:
   if search( "r-quer.r") ne ? then
              do:
               hide  all .
               run r-quer.
              end.
              else
     do:
      message " Процедура r-quer  не найдена   ".
      pause .
     end.
 end.


 if keylabel(lastkey) = "ctrl-v" then do:
   if search( "midibb.r") ne ? then
              do:
               hide  all .
               run midibb .
              end.
              else
     do:
      message  " Процедура midibb не найдена   ".
      pause .
     end.
 end.
                        /*
 if keylabel(lastkey) = "b" then do:
   if search( "nmenu.r") ne ? then
              do:
               hide  all .
               run nmenu.
              end.
              else
     do:
      message " Процедура nmenu не найдена   ".
      pause .
     end.
 end.
                          */

 if keylabel(lastkey) = "s" then do:
   if search( "psmain.r") ne ? then
              do:
               hide  all .
               run psmain.
              end.
              else
     do:
      message " Процедура psmain не найдена   ".
      pause .
     end.
 end.
               /*
 if keylabel(lastkey) = "m" then do:
   if search( "s-pidupd.r") ne ? then
              do:
               run s-pidupd.
              end.
              else
     do:
      message " Procedure s-pidupd wasn't found ".
      pause .
     end.
 end.

 if keylabel(lastkey) = "r" then do:
   if search( "remtrz.r") ne ? then

              do:
               hide  all .
               run remtrz.
              end.
                               else
     do:
      message " Procedure remtrz wasn't found ".
      pause .
     end.
 end.
          */

 if keylabel(lastkey) = "j" then do:
   if search( "quest.r") ne ? then

              do:
               hide  all .
               run quest.
              end.
                               else
     do:
      message " Процедура quest не найдена   ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "ctrl-t" then do:
  {ps-prmtk.i}
   if search( "M_ps.r") ne ? then

              do:
               message " Монитор ....  " .
               run M_ps.
               message "".
              end.
                               else
     do:
      message " Процедура M_ps не найдена   ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "ctrl-g" then do:
  {ps-prmtk.i}
   if search( "GN_ps.r") ne ? then

              do:
               message " TEST GEN ....  " .
               run GN_ps.
               message "".
              end.
                               else
     do:
      message " Procedure GN_ps wasn't found ".
      pause .
     end.
 end.

 if keylabel(lastkey) = "ctrl-b" then do:
  {ps-prmtk.i}
   if ( search( "H0_ps.r") ne ? ) and
    ( search( "qq10") ne ? )  then

              do:
               message " TEST HOME GEN ....  " .
               run H0_ps.
               message "".
              end.
                               else
     do:
      message " Procedure H0_ps or qq10 weren't found ".
      pause .
     end.
 end.
                     /*
 if keylabel(lastkey) = "ctrl-e" then do:
  {ps-prmtk.i}
   if search( "init.r") ne ? then

              do:
               hide  all .
               run init.
              end.
                               else
     do:
      message " Procedure init wasn't found ".
      pause .
     end.
 end.            */

if keylabel(lastkey) = "ctrl-u" then do:
   {ps-prmtk.i}
   if search( "psarc.r") ne ? then

              do:
               hide  all .
               run psarc.
              end.
                               else
     do:
      message " Процедура psarc не найдена   ".
      pause .
     end.
 end.

if keylabel(lastkey) = "ctrl-o" then do:
   {ps-prmtk.i}
   if search( "psarco.r") ne ? then

              do:
               hide  all .
               run psarco.
              end.
                               else
     do:
      message " Процедура psarco не найдена   ".
      pause .
     end.
 end.

 if keylabel(lastkey) = "o" then do:
   if search( "q-reject.r") ne ? then

              do:
               hide  all .
               run q-reject.
              end.
                               else
     do:
      message " Процедура q-reject не найдена   ".
      pause .
     end.
 end.
              /*
 if keylabel(lastkey) = "n" then do:
   if search( "n.r") ne ? then

              do:
               hide  all .
               run n.
              end.
                               else
     do:
      message
      " Procedure n wasn't found ".
      pause .
     end.
 end.

 if keyfunction(lastkey) = "delete-line" then do:
  update v-pid  format 'x(5)' v-copy
   column-label " What process to delete ? "  with frame updlb.
  v-pid = caps(v-pid).
   clear frame updlb all.
  find dproc where dproc.pid = v-pid and dproc.copy = v-copy
   exclusive-lock no-error.

  if avail dproc then do on error undo , leave :
   if dproc.tout ne 1000 then
   do:
    message " There is working process , stop it before ! " .
    pause .
    undo , leave .
   end.
   else
   do:
    delete dproc .
    clear frame pid all .
   end .
  end.
 end.
                   */

 if keyfunction(lastkey) = "cursor-up"   then run manag.
 if keyfunction(lastkey) = "cursor-down" then run manag.

 if keyfunction(lastkey) = "home" then do transaction :
  {ps-prmtk.i}
  Message "Вы уверены   ? " update yn .
  if yn then do:
  clear frame pid all.
  for each dproc with row 3 frame pid .
   dproc.tout = 1000.
   unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
  end.
  end.
 end.
/*
 clear frame mm all.
 clear frame mm1 all.
 clear frame mm2 all.     */

 if l-leave then   leave .
end.
end.
