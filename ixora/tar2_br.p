/* tar2_br.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора - настройка кодов и сумм тарифов
 * RUN
        
 * CALLER
        tar_br.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-6-1
 * CHANGES
        29.09.2003 nadejda  - поставила копирование на филиалы новых тарифов или при изменении счета ГК и названия - только в Головном офисе
                              чтобы это можно было делать корректно, перенесла при вставке нового тарифа ввод валюты и сумм в редактирование тарифа
        20.08.2004 saltanat - отменила какое-либо редактирование, удаление либо внесение данных.
                              внесла просмотр краткой истории.
                              сделала поиск.
        27.04.2005 saltanat - Изменила substring(tarif2.num,1,len) = stnum на tarif2.num = stnum в &where                      
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{global.i}

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
def var i as char format 'x(6)' init ''. 
def buffer ftarif2 for tarif2.

find first cmp no-lock no-error.
v-center = (cmp.code = 0).

{apbra.i 

&start     = " "
&head      = "tarif2"
&headkey   = "tarif2"
&index     = "nr"

&formname  = "tarif2"
&framename = "tarif2"
&where     = "tarif2.num = stnum and tarif2.nr1 = rr4 and tarif2.stat = 'r' and (if i <> '' then string(tarif2.kont) begins i else true) "

&addcon    = "false"
&deletecon = "false"

&precreate = " "

&postadd   = " find last atarif2 where substring(atarif2.num,1,len) = stnum use-index num no-error.
               if available atarif2 then rr5 = integer(atarif2.kod) + 1. else rr5 = 1.
               if rr5 < 10 then tarif2.kod = '0' + string(rr5). else tarif2.kod = string(rr5).
               tarif2.num = stnum .
               tarif2.crc = 0.
               disp tarif2.num tarif2.kod tarif2.crc with frame tarif2.
               update tarif2.kod tarif2.kont tarif2.pakalp
/*                    tarif2.crc tarif2.ost tarif2.proc tarif2.min1 tarif2.max1 29.09.2003 nadejda */ 
                      with frame tarif2.
               tarif2.str5 = trim(tarif2.num) + trim(tarif2.kod).
               tarif2.nr1 = rr4.
               tarif2.nr  = integer(tarif2.num).
               tarif2.nr2 = integer(tarif2.kod).
               tarif2.whn = g-today.
               tarif2.who = g-ofc. 
               /*run deflgot. 29.09.2003 nadejda */ "

&prechoose = "message ' F4-выход, P-печать, TAB-исключения, H-история, F-поиск, X-доп.свед.'."

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

&predelete = " 
  for each tarifex where tarifex.str5 = tarif2.str5
    exclusive-lock .
   delete tarifex .
  end .
    "

&postkey   = "
      else if keyfunction(lastkey) = 'P' then do:
        output to tar2.img .
        for each b-tarif2 where substring (b-tarif2.num,1,len) = stnum:
          display b-tarif2.str5  label 'Код' format 'x(3)'
                  b-tarif2.kont  column-label ' Счет'
                  b-tarif2.pakalp format 'x(30)' column-label 'Услуга'
                  b-tarif2.crc column-label 'Вал'
                  b-tarif2.ost  column-label 'Сумма'
                  b-tarif2.proc column-label ' %   '
                  b-tarif2.min1   format 'zz9.99'  column-label ' Мин'
                  b-tarif2.max1  format 'zz9.99' column-label 'Макс' 
             with overlay title paka column 1 row 7 11 down frame uuu.
         end.
         hide frame uuu.
         output close.
         output to terminal.
         unix prit tar2.img.
       end. 

       else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave:
         code = tarif2.str5. 
         tit = tarif2.pakalp. 
         kon = tarif2.kont. 
         run tar2_ex. 
       end .
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
   find first ftarif2 where string(ftarif2.kont) begins i and substring(ftarif2.num,1,len) = stnum and ftarif2.nr1 = rr4 and ftarif2.stat = 'r' no-lock no-error.
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

