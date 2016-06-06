/* sklad.p
 * MODULE
        Склад
 * DESCRIPTION
        Учету товаров и материалов на складе        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.8
 * BASES
     BANK SKLAD

 * AUTHOR
        03/12/2001 sasco
 * CHANGES
        21/09/2003 sasco - обработка списка списания с Г/К и АРП счетами 
                           генерируются две проводки в зависимости от списка
                           + обработка шаблона VNB0055
        26/05/2004 valery - операционный ордер будет печататься без вопроса
        12/10/04 sasco - добавил вывод subamt, subcost в форме текущего склада и остатков на дату
                       - Раскомментировал удаление проводок (техзадание # 1162)
        07.09.05 nataly замена skladb -> item, sklada -> grp
        09.09.05 nataly добавлена возможность списания сог-но акта 
        12/09/05 nataly добавлена группировка по товару при сверке остатков со СКЛАДОМ
        15.09.05 nataly изменен счет aRP
        31/10/05 nataly убрала архивыне товары
*/


/*{global.i}*/

{sklads2.f}
{yes-no.i}

define shared var g-ofc    like ofc.ofc.
define shared var g-today  as date.
define shared var g-lang   like lang.lang.

define temp-table sktemp
       field gl as int init 0
       field arp like arp.arp initial ''
       field jh as int init ?.

def new shared temp-table  wskitem
     field sid as integer
     field pid as integer
     field des as char 
     field sid2 as integer
     field pid2 as integer
     field des2 as char 
     field ost as decimal
     field ost2 as decimal.

def stream rpt.
def new shared var v-date as date.

def var d-arp as char init "000940601".
def var c-arp as char  init "000904906".

ON HELP OF v-sid   IN FRAME getsid  run help-sksid.
ON HELP OF v-pid   IN FRAME getpid  do: run help-skpid. 
                                        v-pid:screen-value = return-value.
                                        v-pid = int (return-value).
                                    end.

ON HELP OF wsk.sid IN FRAME income  run help-sksid.
ON HELP OF wsk.pid IN FRAME income  do: run help-skpid.
                                        wsk.pid:screen-value = return-value.
                                        wsk.pid = int (return-value).
                                    end.

ON HELP OF v-sid IN FRAME getsid2 run help-sksid.

ON HELP OF v-sid IN FRAME getlist run help-sksid.
ON HELP OF v-pid IN FRAME getlist do: run help-skpid.
                                      v-pid:screen-value = return-value.
                                      v-pid = int (return-value).
                                 end.
                    
ON HELP OF wsk.darp IN FRAME income run help-skarp.
ON HELP OF wsk.carp IN FRAME income run help-skarp.

ON HELP OF item.code IN FRAME skladb do: run help-code2.
                                      item.code:screen-value = return-value.
                                      item.code = string (return-value).
                                     end.

ON endkey OF FRAME income hide frame income.

/*DEFINE SUB-MENU subadd
      MENU-ITEM skadd  LABEL "Приход".
  */

DEFINE SUB-MENU subremp     /*Приход*/
      MENU-ITEM skremap LABEL "Формирование списка для зачисления"
      MENU-ITEM skrems  LABEL "Сверка остатков со СКЛАДОМ"
      MENU-ITEM skremp  LABEL "Проводка"
      RULE
      MENU-ITEM skremnp LABEL "Очистить список".

DEFINE SUB-MENU subrem
      MENU-ITEM skrema LABEL "Формирование списка для списания"
      MENU-ITEM skrem  LABEL "Проводка" .
/*      RULE
      MENU-ITEM skremn LABEL "Очистить список"*/ 


DEFINE SUB-MENU subquit
      MENU-ITEM skquit LABEL "Выход".

DEFINE SUB-MENU subopt
      MENU-ITEM skoptar LABEL "Просмотр групп товаров"
      MENU-ITEM skoptaw LABEL "Редактирование групп"
      RULE
      MENU-ITEM skoptbr LABEL "Отдельные товары и материалы"
      MENU-ITEM skoptbw LABEL "Редактирование товаров".
      RULE
      MENU-ITEM sktrxdl LABEL "Удаление проводок". 


DEFINE SUB-MENU subhis
      MENU-ITEM skcurr LABEL "Текущее состояние на складе"
      MENU-ITEM skost  LABEL "Остаток на дату"
      MENU-ITEM skost2  LABEL "Сверка остатков на дату"
      RULE
      MENU-ITEM skhall LABEL "История всех проводок"
      MENU-ITEM skhpri LABEL "История проводок /приходы/"
      MENU-ITEM skhspi LABEL "История проводок /списания/"
      RULE
      MENU-ITEM sktaba LABEL "Печать текущего состояния на складе"
      MENU-ITEM sktabo LABEL "Печать остатков на дату"
      MENU-ITEM sktabi LABEL "Печать всех проводок"
      MENU-ITEM sktabb LABEL "Печать истории приходов"
      MENU-ITEM sktabc LABEL "Печать истории списаний".
      
      
DEFINE MENU mbar MENUBAR
   /*   SUB-MENU subadd  LABEL "ПриходСтарый"*/
      SUB-MENU subremp  LABEL "Приход"
      SUB-MENU subrem  LABEL "Списание"
      SUB-MENU subopt  LABEL "Настройки"
      SUB-MENU subhis  LABEL "Информация"
      SUB-MENU subquit LABEL "Выход".

/*      MENU-ITEM upupup LABEL "Ввод g-today" 
ON CHOOSE OF MENU-ITEM upupup
do:
    update g-today with row 5 centered frame gggt.
    hide frame gggt.
end.
*/


ON CHOOSE OF MENU-ITEM sktrxdl  /* TRX STORNO */    
    do:
        run sklstor.
        hide all.
    end.


ON "VALUE-CHANGED" of browse bc 
    do:
       if not avail wcur then do:
          displ 0 @ subamt 0.00 @ subcost with frame fc.
          pause 0.
       end.
       else do:
          subamt = 0.
          subcost = 0.
          for each bwcur where bwcur.sid = wcur.sid and bwcur.pid = wcur.pid:
              subamt = subamt + bwcur.amt.
              subcost = subcost + (bwcur.amt * bwcur.cost).
          end.
          displ subamt subcost with frame fc.
          pause 0.
       end.
    end.

ON "VALUE-CHANGED" of browse bc2
    do:
       if not avail wcur2 then do:
          displ 0 @ subamt 0.00 @ subcost with frame fc2.
          pause 0.
       end.
       else do:
          subamt = 0.
          subcost = 0.
          for each bwcur2 where bwcur2.sid = wcur2.sid and bwcur2.pid = wcur2.pid:
              subamt = subamt + bwcur2.amt.
              subcost = subcost + (bwcur2.amt * bwcur2.cost).
          end.
          displ subamt subcost with frame fc2.
          pause 0.
       end.
    end.

/*ON CHOOSE OF MENU-ITEM skadd   /* приход по-старому */    
    do:
        run n-sklad.
        hide frame income.
    end.
  */
/*ПРИХОД*/
ON CHOOSE OF MENU-ITEM skremap /* формирование списка  - ПРИХОД*/
    do:
        run r-skladap.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM skremnp /* очистить список  - ПРИХОД*/
    do:
        run r-skladnp.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM skremp /* транзакция - ПРИХОД */
    do:
        run r-skladp. 
        hide frame outgo.
     end.

ON CHOOSE OF MENU-ITEM skrems /* Сверка остатков  - ПРИХОД */
    do:
        run r-sklads. 
        hide frame outgo.
     end.
        
 /*СПИСАНИЕ*/
ON CHOOSE OF MENU-ITEM skrema /* редакция списка - СПИСАНИЕ */
    do:
        run r-sklada.
        hide all.
    end.    

/*
 ON CHOOSE OF MENU-ITEM skremn /* очистить список - СПИСАНИЕ */
    do:
        run r-skladn.
        hide all.
    end.    
  */
ON CHOOSE OF MENU-ITEM skrem /* транзакция - СПИСАНИЕ */
    do:
        run r-sklad. 
        hide frame outgo.
     end.

/*НАСТРОЙКИ*/    
ON CHOOSE OF MENU-ITEM skoptar   /* просмотр групп */
     do :
       run o-skladaR. 
       hide all.
     end.
 
ON CHOOSE OF MENU-ITEM skoptaw  /* редакция групп */
     do :        
       run o-skladaW .
       hide all.
     end.

ON CHOOSE OF MENU-ITEM skoptbr  /* просмотр товаров */
     do :
       run o-skladbR.
       hide all.
     end.

ON CHOOSE OF MENU-ITEM skoptbw /* редакция товаров */
     do :
       run o-skladbW.
       hide all.
     end.

ON CHOOSE OF MENU-ITEM skost /* остаток на дату */
   do:
      run o-dateost. 
      hide all.
   end.

ON CHOOSE OF MENU-ITEM skost2 /* остаток на дату */
   do:
      run o-sverost. 
      hide all.
   end.


ON CHOOSE OF MENU-ITEM sktaba /* печать тек. склада */
   do:
      run o-tabhista. 
      hide all.
   end.

ON CHOOSE OF MENU-ITEM sktabb /* печать истории приходов */
   do:
      run o-tabhistb.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM sktabo /* печать остатков на дату */
   do:
      run o-prtost.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM sktabc /* печать истории расходов */ 
   do:
      run o-tabhistc.
      hide all.
   end.
      
ON CHOOSE OF MENU-ITEM sktabi /* печать всех проводок */
   do:
      run o-tabhitrx.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM skcurr /* текущий склад */
   do:
      run o-scurrent.
      hide all.
   end.


ON CHOOSE OF MENU-ITEM skhall        /*---   история приходов + расходов ---- */
   do:
      run o-histall.
      hide all.
   end.

   
ON CHOOSE OF MENU-ITEM skhpri        /*---   история приходов   -----*/
   do:
      run o-histpr.
      hide all.
   end.


ON CHOOSE OF MENU-ITEM skhspi        /*-----   история списаний     -----*/
   do:
      run o-histsp.
      hide all.
   end.

on "value-changed" of browse bt
do:
   st_amt = 0.
   st_sum = 0.0.
   st_amt1 = 0.
   st_sum1 = 0.0.
   if avail skladt then do:
      for each st_buf where st_buf.pid = skladt.pid and st_buf.sid = skladt.sid no-lock.
          st_amt = st_amt + st_buf.amt.
          st_sum = st_sum + (st_buf.amt * st_buf.cost).
      end.
     for each skladt.
          st_amt1 = st_amt1 + skladt.amt.
          st_sum1 = st_sum1 + (skladt.amt * skladt.cost).
     end. 
   end.
   displ st_amt st_sum  st_amt1 st_sum1 with frame st.
end.

on "value-changed" of browse bp
do:
   st_amt = 0.
   st_sum = 0.0.
   st_amt1 = 0.
   st_sum1 = 0.0.
   if avail skladp then do:
      for each st_bufp where st_bufp.pid = skladp.pid and st_bufp.sid = skladp.sid no-lock.
          st_amt = st_amt + st_bufp.amt.
          st_sum = st_sum + (st_bufp.amt * st_bufp.cost).
      end.
     for each skladp.
          st_amt1 = st_amt1 + skladp.amt.
          st_sum1 = st_sum1 + (skladp.amt * skladp.cost).
     end. 
   end.
   displ st_amt st_sum st_amt1 st_sum1 with frame st.
end.
   
/* -------------------------- добавление группы ---------------- */ 
/*on "insert" of browse ba 
do:
   def var l like grp.grp.
   find last grp no-error.
   if avail grp then l = grp.grp. else l = 0.
   do transaction:
     create grp.
     grp.grp = l + 1.
     display grp.grp with frame sklada no-labels.
     update grp.des
             with frame sklada no-labels title 
     "Введите наименование для создаваемой группы".
   end.  
   hide frame sklada. 
   close query qa. 
   open query qa for each grp no-lock.
   browse ba:refresh().
end. */

/* --------------------------- добавление товара в группу ------------- */
on "insert" of browse bb
do:
   def var l like item.item.
   find last sklad.item where item.grp = v-sid no-error.
   if avail item then l = item.grp. else l = 0.
   do transaction:
     create item.
     item.item = l + 1.
     item.grp = v-sid.
     display item.item item.code with frame skladb no-labels.
     update item.des with frame skladb no-labels
     title "Введите описание товара или материала".
   end.
   hide frame skladb.
   close query qb.
      displ v-des LABEL "ГРУППА" format "x(20)" with row 2 centered
                              no-box side-labels frame dess.
   open query qb for each item where item.grp = v-sid no-lock.
   browse bb:refresh(). 
end. 

/* --------------------  добавление товара для прихода ---------- */
on "return" of browse bp
do:
     run n-sklad.
   hide all.
   close query qp.
   open query qp for each skladp by skladp.sid by skladp.pid by skladp.dpr.
   if can-find (first skladp) then browse bp:refresh().
   apply "value-changed" to browse bp.
end.

/* --------------------  добавление товара для списания ---------- */
on "return" of browse bt
do:
   update v-sid with frame getlist.
   update v-pid with frame getlist.

   for each wcho: delete wcho. end.

   for each skladc where skladc.sid = v-sid and
                         skladc.pid = v-pid
                         no-lock:
       /* создать с текущим складом */
       create wcho.
       wcho.amt = skladc.amt.
       wcho.cost = skladc.cost.
       wcho.dpr = skladc.dpr.
       find first item where item.grp = skladc.sid and
                               item.item = skladc.pid
                               no-lock no-error.
       if avail item then wcho.des = item.des.



       /* отнять значения списываемых товаров из списка */
       for each skladt where skladt.cost = wcho.cost and
                             skladt.dpr = wcho.dpr and
                             skladt.sid = skladc.sid and
                             skladt.pid = skladc.pid no-lock:

           wcho.amt = wcho.amt - skladt.amt.
       end.                      
   end.

   pause 0.
   run help-curskl.
   pause 0.

   create skladt.
   skladt.sid = v-sid.
   skladt.pid = v-pid.
   skladt.cost = v-cost.
   skladt.dpr = v-dpr.
   skladt.ost = 0.
   run get-p-des (v-sid, v-pid, output skladt.des).

   displ skladt.cost skladt.dpr with frame getlist.
   
   find wcho where wcho.cost = v-cost and wcho.dpr = v-dpr.
   repeat while true:
      update skladt.amt with frame getlist.
      v-amt = skladt.amt.
      if skladt.amt le 0 or skladt.amt > wcho.amt then
         do:
            message "Количество должно быть от 1 до" wcho.amt.
            pause 50.
        end.
        else leave.
   end.
   skladt.ost = skladt.ost + skladt.amt.
   
   update skladt.gl skladt.arp with frame getlist.
   hide all.
   close query qt.

   open query qt for each skladt by skladt.sid by skladt.pid by skladt.dpr.
   browse bt:refresh().
   apply "value-changed" to browse bt.
end.

/* --------------------------------  детали проводки ------------ */
on "return" of browse bc2
do:
        displ wcur2.who wcur2.whn wcur2.dpr wcur2.type wcur2.amtrest
              wcur2.costrest wcur2.gl
        with row 10 centered frame fbc2.
        hide frame fbc2.
end.

/* --------------------------------  удаление группы  */
/*on "clear" of browse ba
do:
    yesno = yes-no("Удалить группу ", "Вы уверены?").
    if yesno then
    do:
        v-sid = grp.grp.

        find first skladb where item.grp = v-sid no-lock no-error.
        if avail skladb then do:
              message 'Удаление невозможно, тк по данной группе имеется товар!'.
              pause 3.
              return.
         end.
       find first grp where grp.grp = v-sid exclusive-lock no-error.

        delete grp.
        release grp.

        close query qa.
        open query qa for each grp no-lock.
        if can-find(first grp no-lock) then
       browse ba:refresh().
        apply "value-changed" to browse ba.
    end.
end. */
/*------------------------------------  редактирование группы */
on "return" of browse ba
do:
     v-sid = grp.grp.
     find first grp where grp.grp = v-sid exclusive-lock no-error.
     update grp.des 
            with frame sklada no-labels title 
     "Введите наименование и счет ГК для создаваемой группы".
   
   hide frame sklada. 
   close query qa. 
   open query qa for each grp no-lock.
   browse ba:refresh().

end.
/* --------------------------------  удаление товара  */
on "clear" of browse bb
do:
    yesno = yes-no("Удалить товар ", "Вы уверены?").
    if yesno then
    do:
        v-pid = item.item.
        v-sid = item.grp.
        if can-find (first skladh where skladh.sid = v-sid and skladh.pid = v-pid  no-lock) 
        then do:   message  "По этому товару уже были движения!~nПеренести в архив?" view-as 
                   ALERT-BOX QUESTION BUTTONS YES-NO UPDATE yes-no2 AS LOGICAL.
                   if yes-no2 then do: 
                         find current item. item.des  = item.des + ' yes' .  
                        {sklad.i}
                   end.
        end.
        else do:
          delete item.
          release item.
         {sklad.i}
        end.
    end.
end.  
/*------------------------------------  редактирование товара */
on "return" of browse bb
do:
        v-pid = item.item.
        v-sid = item.grp.
     find first item where item.item = v-pid and item.grp = v-sid exclusive-lock no-error.

     display item.item  with frame skladb no-labels.
     update item.des item.code
            with frame skladb no-labels title "Введите описание товара или материала".
   
   hide frame skladb. 
   close query qb. 
   open query qb for each item where item.grp = v-sid  no-lock.
   browse bb:refresh().

end.

/* --------------------------------  удаление товара из списка для списания */
on "clear" of bp in FRAME ftp DO:
   def var method-return as logi. 
    def var i as int. 
    yesno = yes-no("Удаление из списка ", "Вы уверены?").
    if yesno then
    do:

        do i = bp:num-selected-rows to 1 by -1 :
             method-return = bp:fetch-selected-row(i).
             get current qp no-lock. 
             find current skladp.
        end.

        v-cost = skladp.cost.
        v-sid = skladp.sid.
        v-pid = skladp.pid.
        v-dpr = skladp.dpr.
        v-amt = skladp.amt.
        find first skladp where skladp.sid = v-sid and skladp.pid = v-pid
                          and skladp.cost = v-cost and skladp.dpr = v-dpr
                          and skladp.amt = v-amt
                          exclusive-lock.
        delete skladp.
        release skladp.

           /*  возврат суммы с список 
           find first wcho where wcho.cost = v-cost and wcho.dpr = v-dpr.
           wcho.amt = wcho.amt + v-amt.
            */

        close query qp.
        open query qp for each skladp by skladp.sid by skladp.pid by 
                    skladp.dpr.
        if can-find(first skladp no-lock) then
        browse bp:refresh().
        apply "value-changed" to browse bp.
    end.
end.

/* --------------------------------  удаление товара из списка для списания */
on "clear" of browse bt
do:
    yesno = yes-no("Удаление из списка", "Вы уверены?").
    if yesno then
    do:
        v-cost = skladt.cost.
        v-sid = skladt.sid.
        v-pid = skladt.pid.
        v-dpr = skladt.dpr.
        v-amt = skladt.amt.
        find first skladt where skladt.sid = v-sid and skladt.pid = v-pid
                          and skladt.cost = v-cost and skladt.dpr = v-dpr
                          and skladt.amt = v-amt
                          exclusive-lock.
        delete skladt.
        release skladt.

           /*  возврат суммы с список 
           find first wcho where wcho.cost = v-cost and wcho.dpr = v-dpr.
           wcho.amt = wcho.amt + v-amt.
            */

        close query qt.
        open query qt for each skladt by skladt.sid by skladt.pid by 
                    skladt.dpr.
        if can-find(first skladt no-lock) then
        browse bt:refresh().
        apply "value-changed" to browse bt.
    end.
end.

/* --------------------------------   Удаление проводки (откат таблиц) ------ */
on "clear" of browse bc2
do:
if wcur2.whn <> g-today then
message "Вы не можете удалить не сегодняшнюю проводку!!!"
view-as alert-box.
else do:
  yesno = yes-no("Отмена проводки", "Вы уверены?").
  if yesno then
  do:
    yesno = yes-no("Отмена проводки", "Вы действительно уверены?").
    if yesno then
    do:
        if wcur2.type = "P" then
           do:  /* был приход */
                   /* исправить skladc */
                find last skladc where skladc.sid = wcur2.sid and
                                       skladc.pid = wcur2.pid and
                                       skladc.dpr = wcur2.dpr and
                                       skladc.cost = wcur2.cost
                                       no-error.
                if avail skladc then
                do:
                    skladc.amt = skladc.amt - wcur2.amt.
                    if skladc.amt = 0 then delete skladc.
                end.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в skladc!"
                     view-as alert-box.

                   /* исправить skladh */
                find last skladh where skladh.sid = wcur2.sid and
                                       skladh.pid = wcur2.pid and
                                       skladh.dpr = wcur2.dpr and
                                       skladh.whn = wcur2.whn and
                                       skladh.cost = wcur2.cost
                                       no-error.
                if avail skladh then skladh.type = "A". /* СТОРНО ПРИХОДА*/
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в skladh!"
                     view-as alert-box.

                   /* исправить sklado type = "O" */
                find first sklado where sklado.sid = wcur2.sid and
                                       sklado.pid = wcur2.pid and
                                       sklado.cost = wcur2.cost and
                                       sklado.whn = wcur2.whn and
                                       sklado.type = "O"
                                       use-index www
                                       no-error.
                if avail sklado then sklado.amt = sklado.amt - wcur2.amt.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в sklado!"
                     view-as alert-box.

                   /* исправить sklado type = "T" */
                find first sklado where sklado.sid = wcur2.sid and
                                       sklado.pid = wcur2.pid and
                                       sklado.whn = wcur2.whn and
                                       sklado.type = "T"
                                       use-index www
                                       no-error.
                if avail sklado then
                   do:
                      sklado.amt = sklado.amt - wcur2.amt.
                      sklado.cost = sklado.cost - (wcur2.amt * wcur2.cost).
                   end.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в sklado!"
                     view-as alert-box.
           end. /* СТОРНА ПРИХОДА уффффф....*/

        else if wcur2.type = "S" then

           do: /* было списание */
                   /* исправить skladc */
                find last skladc where skladc.sid = wcur2.sid and
                                       skladc.pid = wcur2.pid and
                                       skladc.dpr = wcur2.dpr and
                                       skladc.cost = wcur2.cost
                                       no-error.
                if avail skladc then skladc.amt = skladc.amt + wcur2.amt.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в skladc!"
                     view-as alert-box.

                   /* исправить skladh */
                find last skladh where skladh.sid = wcur2.sid and
                                       skladh.pid = wcur2.pid and
                                       skladh.dpr = wcur2.dpr and
                                       skladh.whn = wcur2.whn and
                                       skladh.cost = wcur2.cost
                                       no-error.
                if avail skladh then skladh.type = "B". /* СТОРНО РАСХОДА */
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в skladh!"
                     view-as alert-box.

                   /* исправить sklado type = "O" */
                find first sklado where sklado.sid = wcur2.sid and
                                       sklado.pid = wcur2.pid and
                                       sklado.cost = wcur2.cost and
                                       sklado.whn = wcur2.whn and
                                       sklado.type = "O"
                                       use-index www
                                       no-error.
                if avail sklado then sklado.amt = sklado.amt + wcur2.amt.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в sklado!"
                     view-as alert-box.

                   /* исправить sklado type = "T" */
                find first sklado where sklado.sid = wcur2.sid and
                                       sklado.pid = wcur2.pid and
                                       sklado.whn = wcur2.whn and
                                       sklado.type = "T"
                                       use-index www
                                       no-error.
                if avail sklado then
                   do:
                      sklado.amt = sklado.amt + wcur2.amt.
                      sklado.cost = sklado.cost + (wcur2.amt * wcur2.cost).
                   end.
                else /* не нашли skladc */
                     message "Внимание! Не найдена запись в sklado!"
                     view-as alert-box.
           end.

        delete wcur2.
        close query qc2.
        open query qc2 for each wcur2 by wcur2.sid by wcur2.pid by wcur2.dpr.
        enable all with frame fc2.
        if can-find(first wcur2 no-lock) then
        browse bc2:refresh().
    end.
  end.
end.
end.

close query qa.
close query qb.

ASSIGN CURRENT-WINDOW:MENUBAR = MENU mbar:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM skquit.               /* выход */
    
if avail grp then release grp. 
if avail item then release item.
if avail skladh then release skladh.
if avail skladc then release skladc.

for each wsk: delete wsk. end.

/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/



/*-------------------------    приход     -------------*/
procedure n-sklad.
   create wsk.
   wsk.who = g-ofc.
   wsk.whn = g-today.
   displ wsk.who wsk.whn with frame income.
   disable wsk.who wsk.whn /* byes2*/ with frame income.
   wsk.type = "P".
   wsk.tdes = "Приход на склад".
   displ wsk.tdes with frame income.
   update wsk.sid with frame income.
   v-sid = wsk.sid.
   find first grp where grp.grp = wsk.sid no-lock.
   wsk.sdes = grp.des.
   displ wsk.sdes with frame income.
   update wsk.pid with frame income.
   find first item where item.grp = wsk.sid and 
                     item.item = wsk.pid no-lock.
   wsk.pdes = item.des.
   displ wsk.pdes with frame income.
   update wsk.amt with frame income.
   update cost with frame income.

   grd1 = cost / wsk.amt.
   wsk.cost = grd1.
    wsk.rem[1] = "приход".
   display wsk.rem with frame income.
   update wsk.rem with frame income.
    
         create skladp.
         assign 
                skladp.sid = wsk.sid
                skladp.pid = wsk.pid
                skladp.amt = wsk.amt
                skladp.cost = wsk.cost 
                skladp.dpr = wsk.whn
                skladp.des = wsk.rem[1]
                skladp.ost = 0.
         run get-p-des (skladp.sid, skladp.pid, output skladp.des).
   wsk.darp =  d-arp.    /*  начальное значение для gl = 160200 */
   update wsk.darp with frame income.
   find arp where arp.arp = wsk.darp no-lock no-error.
   if avail arp then wsk.ddes = trim(arp.des). else wsk.ddes = "".
   displ wsk.ddes with frame income.
   wsk.carp =  c-arp.    /*  начальное значение для gl = 160200 */
   update wsk.carp with frame income.
   find arp where arp.arp = wsk.carp no-lock no-error.
   if avail arp then wsk.cdes = trim(arp.des). else wsk.cdes = "".
                skladp.arp = wsk.carp.

end procedure.


procedure prichod.

def var pri as integer.
def var pra as integer.
def var prc as decimal.
def var sum as decimal init 0.
def var v-text1 as char format 'x(55)'.
def var v-text2 as char format 'x(55)'.
 
 /*определяем сумму для проводки - ИТОГО по всем товарам*/
   for each skladp .
     sum =  sum + skladp.amt * skladp.cost.
   end.

   /*делаем проводку*/
if sum > 0 then do:                                
  update v-text1 label 'Введите назначение платежа' skip
         v-text2 label 'Задайте дебитора' with frame s1.
   hide frame s1.


   find first skladp. c-arp = skladp.arp.
  displ "Создание проводки..." with centered row 10 frame fff.
   v-param = string(sum) + v-del + 
             d-arp + v-del + 
             c-arp + v-del + v-text1 + v-del + v-text2 . 
   v-doc = "VNB0010".
   s-jh = 0.
        
         RUN trxgen (v-doc, v-del, v-param, "", "", output rcode, output rdes,
                    input-output s-jh).
         IF rcode <> 0 then
                    do:
                        message rcode rdes.
                        pause 50.
                        return.
                    end.
         def var colorders as integer init 1.
         def var i as integer.
         
         UPDATE colorders label "Введите количество ордеров"
         with centered row 10 frame fcolord.
         HIDE FRAME fcolord.
         
         DISPL "Печать операционного ордера..." with centered row 10 frame fff.
         DO i = 1 to colorders:
            RUN vou_bank(1). /*параметр "1" означает что операционный ордер печатается без вопросов*/
            pause 0.
         END.
        
   hide frame sss. pause 0.
   hide frame fff. pause 0.
end.
             /*Изменяем таблицы с остатками*/
    if s-jh = 0 then do: 
           message 'Проводка не сформировалась!'. 
           pause 3.
           return.
    end. 
     for each skladp :

         CREATE skladh.
         assign skladh.sid = skladp.sid
                skladh.pid = skladp.pid
                skladh.amt = skladp.amt
                skladh.cost = skladp.cost
                skladh.type = "P"
/*                skladh.whn = skladp.dpr*/
                skladh.who = ""
                skladh.dpr = skladp.dpr
                skladh.rem[1] = skladp.des
                skladh.drarp = d-arp
                skladh.crarp = c-arp
                skladh.gl = 0
                skladh.jh = s-jh.
        
         find first skladc where skladc.sid = wsk.sid and 
                    skladc.pid = wsk.pid and skladc.cost = skladp.cost
                    and skladc.dpr = wsk.whn no-error.
         if avail skladc then           
                /*  изменение значения  */
                skladc.amt = skladc.amt + skladp.amt.
         else do:
                /*  создать запись  */
                 CREATE skladc.
                 skladc.sid = skladp.sid.
                 skladc.pid = skladp.pid.
                 skladc.amt = skladp.amt.
                 skladc.cost = skladp.cost.
                 skladc.dpr = skladp.dpr.
              end.

         /* ------------------------------------- */
         /*    Добавим остаток за текущую дату    */
         /* ( TOTAL суммирование по всей группе ) */
         /* ------------------------------------- */
         FIND FIRST sklado where sklado.sid = skladp.sid and
                                sklado.pid = skladp.pid and
                                sklado.whn = g-today and
                                sklado.type = "T"
                                use-index www
                                no-error.
         if avail sklado then /* если нашли за текущую дату... */
            do: /* ...то прибавить её значение */
                v-amt = sklado.amt.
                v-cost = sklado.cost.
            end.
         else do:
                 /* нет - найти последний остаток по товару и приплюсовать */
                 FIND FIRST sklado where sklado.sid = skladp.sid and
                                        sklado.pid = skladp.pid and
                                        sklado.type = "T"
                                        use-index www
                                        no-error.
                 if avail sklado then /* нашли - запомнить остатки */
                 do:
                    v-amt = sklado.amt.
                    v-cost = sklado.cost.
                 end.
                 else do: v-amt = 0. v-cost = 0.0. end.

                 /* создать с текущей датой */
                 CREATE sklado.
                 sklado.sid = skladp.sid.
                 sklado.pid = skladp.pid.
                 sklado.whn = g-today.
                 sklado.type = "T".
            end.

         sklado.amt = v-amt + skladp.amt.
         sklado.cost = v-cost + (skladp.amt * skladp.cost).

         /* ------------------------------------- */
         /*    Добавим остаток за текущую дату    */
         /*      (суммирование по товару )        */
         /* ------------------------------------- */
         FIND FIRST sklado where sklado.sid = skladp.sid and
                                sklado.pid = skladp.pid and
                                sklado.whn = g-today and
                                sklado.dpr = g-today and
                                sklado.cost = skladp.cost and
                                sklado.type = "O"
                                use-index www
                                no-error.
         if avail sklado then /* если нашли за текущую дату... */
            /* ...то прибавить её значение */
            v-amt = sklado.amt.
         else do:
                 /* создать с текущей датой */
                 CREATE sklado.
                 sklado.sid = skladp.sid.
                 sklado.pid = skladp.pid.
                 sklado.whn = g-today.
                 sklado.dpr = g-today.
                 sklado.type = "O".
                 sklado.cost = skladp.cost.
                 v-amt = 0.
            end.

         sklado.amt = v-amt + skladp.amt.
        /* sum =  sum + skladp.amt * skladp.cost.*/

       end. /* ... for each skladp ... */

end procedure.

/*---------------------------   удаление списка - СПИСАНИЕ ----------------*/
procedure r-skladn.
    yesno = yes-no("Новый список","Внимание! Текущий список будет удален").
    if yesno = true then
    yesno = yes-no("","Вы уверены").
    if yesno = true then
       do:
          for each skladt:
          delete skladt.
          end.
       end.
end procedure.

/*---------------------------   удаление списка - ПРИХОД ----------------*/
procedure r-skladnp.
    yesno = yes-no("Новый список","Внимание! Текущий список будет удален").
    if yesno = true then
    yesno = yes-no("","Вы уверены").
    if yesno = true then
       do:
          for each skladp:
          delete skladp.
          end.
       end.
end procedure.

/*---------------------------   редакция списка - ПРИХОД -------------*/
procedure r-skladap.
    open query qp for each skladp by skladp.sid by skladp.pid by skladp.dpr.
    enable all with frame ftp.
    apply "value-changed" to browse bp.
    wait-for window-close of frame ftp focus browse bp.
    release skladp.
end procedure.

/*---------------------------   редакция списка - СПИСАНИЕ -------------*/
procedure r-sklada.
    run spistrx(no).

/*    open query qt for each skladt by skladt.sid by skladt.pid by skladt.dpr.
    enable all with frame ft.
    apply "value-changed" to browse bt.
    wait-for window-close of frame ft focus browse bt.
    release skladt.*/
end procedure.

/*---------------------------   сверка остатков - ПРИХОД   ----------------*/
procedure r-sklads.
   run sverka.
end procedure.

/*---------------------------   сверка остатков - ОТЧЕТ   ----------------*/
procedure o-sverost.
   run sverost1.
end procedure.

/*---------------------------   ТРАНЗАКЦИЯ - ПРИХОД   ----------------*/
procedure r-skladp.
   run prichod.
end procedure.

/*---------------------------   списание -ТРАНЗАКЦИЯ    ----------------*/
procedure r-sklad.
  run spistrx(yes).
end procedure.

procedure r-skladOLD.
    define variable amtR like sklado.amt.
    define variable costR like sklado.cost.
    define variable r-type as integer. /* 1 = "gl" или 2 = "arp" */
    define variable r-tmpl as character. /* номер шаблона для списания */
    define variable defaultARP like arp.arp. /* для подстановки в пустые линии шаблона */
                                             /* чтобы trxgen не ругался на АРП <-> Г/К */

    def var ii as integer.
    def var cnt as integer.
    def var vpar as char.
    def var jj as integer.
    def var ii2 as integer.
    def var vdel as char init "^".

    def var colorders as integer init 1.
    def var i as integer.
    
    yesno = yes-no("","Вы уверены").
    if yesno = true then do:
       UPDATE colorders label "Введите количество ордеров"
       with centered row 10 frame fcolord.
       HIDE FRAME fcolord.
       pause 0.
    end.

    if yesno = true then
    do r-type = 1 to 2:

          defaultARP = ''.

          if r-type = 2 then do:
             find first skladt where skladt.arp <> '' no-error.
             if available skladt then defaultARP = skladt.arp.

             find arp where arp.arp = defaultARP no-lock no-error.
             if not available arp then defaultARP = ''.
          end.

          for each tb: delete tb. end.
          for each sktemp: delete sktemp. end.

          if r-type = 1 then r-tmpl = "VNB0016". /* gl */
                        else r-tmpl = "VNB0055". /* arp */

          /* цикл - разбивка на 7 частей и проводка */
          ii = 0.
          ii2 = 0.
          vpar = "".
          cnt = 0.

          /* таблица с параметрами для проводки - счета ГК и суммы */
          if r-type = 1 then /* список для "gl" */
            for each skladt where skladt.gl <> 0 no-lock:
               find tb where tb.gl = skladt.gl no-error.
               if not avail tb then 
               do:
                  create tb.
                  tb.gl = skladt.gl.
                  tb.amt = 0.0.
               end.
               tb.amt = tb.amt + (skladt.amt * skladt.cost).
            end.
          else /* список для "arp" */
            for each skladt where skladt.arp <> '' no-lock:
               find tb where tb.arp = skladt.arp no-error.
               if not avail tb then 
               do:
                  create tb.
                  tb.arp = skladt.arp.
                  tb.amt = 0.0.
               end.
               tb.amt = tb.amt + (skladt.amt * skladt.cost).
            end.

          /* сколько всего накопилось */
          cnt = 0.
          for each tb no-lock:
             cnt = cnt + 1.
          end.

          for each tb no-lock:
              ii = ii + 1.
              ii2 = ii2 + 1.

              if r-type = 1 then 
              do: /* gl */
                 if ii = 1 then vpar = string(tb.amt) + vdel + string(tb.gl).
                           else vpar = vpar + vdel + string(tb.amt) + vdel + string(tb.gl).
                 create sktemp.
                 assign sktemp.gl = tb.gl
                        sktemp.arp = ''
                        sktemp.jh = -1.
              end.
              else do: /* arp */
                 if ii = 1 then vpar = string(tb.amt) + vdel + tb.arp.
                           else vpar = vpar + vdel + string(tb.amt) + vdel + tb.arp.
                 find arp where arp.arp = tb.arp no-lock no-error.
                 create sktemp.
                 assign sktemp.gl = arp.gl
                        sktemp.arp = tb.arp
                        sktemp.jh = -1.
              end.


              /* проводка, как только есть 7 линий для шаблона */
              if ii = 7 or ii2 = cnt then 
              do:
                  jj = ii.
                  do while jj le 7:
                     vpar = vpar + vdel + vdel + defaultARP.
                     jj = jj + 1.
                  end.
                  vpar = vpar + vdel.
                  s-jh = 0.
                  hide all.
                  run trxgen(r-tmpl, vdel, vpar, "", "", 
                             output rcode, output rdes,
                             input-output s-jh).
                  if rcode ne 0 then
                             do:
                                 message rcode rdes.
                                 pause.
                                 return.
                             end.
                  hide all.
                  if s-jh = 0 then
                              do:
                                 message "Ошибка! Номер транзакции = 0".
                                 pause.
                                 return.
                              end.
                  message "                                           ".
                  pause 0.
                  
                  find last jl where jl.jh = s-jh no-error.
                  if not avail jl then message "CANNOT FIND JL FOR S-JH!" view-as alert-box.

                  for each sktemp where sktemp.jh = -1:
                      sktemp.jh = s-jh.
                  end.

         DISPL "Печать операционного ордера..." with centered row 10 frame fff. pause 0.
         DO i = 1 to colorders:
            RUN vou_bank(1). pause 0. /*параметр "1" означает что операционный ордер печатается без вопросов*/
         END.

                  vpar = "".
                  ii = 0.
              end.
          end.
    
    /* если все в порядке - */
    for each tb: delete tb. end.

    for each skladt where ((skladt.gl <> 0 and r-type = 1) or (skladt.arp <> '' and r-type = 2)) no-lock:
        /* найдем текущий склад - по группе и по датеПрихода */
        find skladc where skladc.sid = skladt.sid and
                          skladc.pid = skladt.pid and
                          skladc.cost = skladt.cost and
                          skladc.dpr = skladt.dpr
                          no-error.
        if avail skladc then do:
        /* вычесть количество (по этой цене) */
            skladc.amt = skladc.amt - skladt.amt.
            /* если ничего не осталось, то удалить запись */    
            if skladc.amt < 0 then
            message "Предупреждение! Количество на складе не может быть < 0 ("
                    + "sid=" skladc.sid "pid=" skladc.pid "amt=" skladc.amt
                    ")" view-as alert-box.
            else
                if skladc.amt = 0 then delete skladc.
        end.
        else message 
        "Предупреждение! Не найдена запись для skladc (sid=" skladt.sid " pid="
            skladt.pid " cost=" skladt.cost " dpr=" skladt.dpr ")"
            view-as alert-box.
        
    end.

    /* создание истории проводок - списание со склада */
    for each skladt where ((skladt.gl <> 0 and r-type = 1) or (skladt.arp <> '' and r-type = 2)):

       find sktemp where ((sktemp.gl = skladt.gl and r-type = 1) or (sktemp.arp = skladt.arp and r-type = 2)) no-error. 

       CREATE skladh.
       assign skladh.sid = skladt.sid
              skladh.pid = skladt.pid
              skladh.whn = g-today
              skladh.who = g-ofc
              skladh.amt = skladt.amt
              skladh.cost = skladt.cost
              skladh.type = "S"
              skladh.dpr = skladt.dpr
              skladh.drarp = ""
              skladh.crarp = ""
              skladh.gl = sktemp.gl
              skladh.jh = sktemp.jh.


       run get-p-des (skladt.sid, skladt.pid, output v-des).
       skladh.rem = "Списание "+ v-des + " " + string(skladt.amt) + "x" +
           string(skladt.cost).

         /* ------------------------------------- */
         /*    Отнимеме остаток за текущую дату   */
         /*   ( TOTAL вычитание по всей группе )  */
         /* ------------------------------------- */
         FIND FIRST sklado where sklado.sid = skladt.sid and
                                 sklado.pid = skladt.pid and
                                 sklado.whn = g-today and
                                 sklado.type = "T"
                                 use-index www
                                 no-error.
         if avail sklado then /* если нашли за текущую дату... */
            do: /* ...то отнять её значение */
                v-amt = sklado.amt.
                v-cost = sklado.cost.
            end.
         else do:
                 /* нет - найти последний остаток по товару и минусовать */
                 FIND FIRST sklado where sklado.sid = skladt.sid and
                                         sklado.pid = skladt.pid and
                                         sklado.type = "T"
                                         use-index www
                                         no-error.
                 if avail sklado then /* нашли - запомнить остатки */
                 do:
                    v-amt = sklado.amt.
                    v-cost = sklado.cost.
                 end.
                 else do: v-amt = 0. v-cost = 0.0. end.

                 /* создать с текущей датой */
                 CREATE sklado.
                 sklado.sid = skladt.sid.
                 sklado.pid = skladt.pid.
                 sklado.whn = g-today.
                 sklado.type = "T".
            end.

         sklado.amt = v-amt - skladt.amt.
         sklado.cost = v-cost - (skladt.amt * skladt.cost).

         /* ------------------------------------- */
         /*    Отнимем остаток за текущую дату    */
         /*      (вычитание по товару )           */
         /* ------------------------------------- */
         FIND FIRST sklado where sklado.sid  = skladt.sid and
                                 sklado.pid  = skladt.pid and
                                 sklado.whn  = g-today and
                                 sklado.dpr  = skladt.dpr and
                                 sklado.cost = skladt.cost and
                                 sklado.type = "O"
                                 use-index www
                                 no-error.
         if avail sklado then /* если нашли за текущую дату... */
            /* ...то отнять её значение */
            v-amt = sklado.amt.
         else do:
                 /* нет - найти последний остаток по товару и минусовать */
                 FIND FIRST sklado where sklado.sid = skladt.sid and
                                         sklado.pid = skladt.pid and
                                         sklado.dpr = skladt.dpr and
                                         sklado.cost = skladt.cost and
                                         sklado.type = "O"
                                         use-index www
                                         no-error.
                 if avail sklado then /* нашли - запомнить остатки */
                    v-amt = sklado.amt.
                 else
                    v-amt = 0.

                 /* создать с текущей датой */
                 CREATE sklado.
                 sklado.sid = skladt.sid.
                 sklado.pid = skladt.pid.
                 sklado.whn = g-today.
                 sklado.dpr = skladt.dpr.
                 sklado.cost = skladt.cost.
                 sklado.type = "O".
            end.

         sklado.amt = v-amt - skladt.amt.


       /* очистка списка */
       delete skladt.
    end.
    hide all.
    
    end. /* yesno = true */
    
    hide all.               
    
end procedure.

/* ---------------------------   добавление группы   -----*/
procedure o-skladaW.
   open query qa for each grp no-lock.
   enable all with frame fa.
   wait-for window-close of frame fa focus browse ba.
end procedure .


on 'end-error' of browse ba hide frame fa.

on 'end-error' of browse bb hide frame fb.


/*----------------------------   список всех групп   -----*/
procedure o-skladaR.
    if can-find(first grp) then do:
       open query qa1 for each grp no-lock.
       enable all with frame fa1.
       wait-for window-close of frame fa1 focus browse ba1.
    end.   
    else do:
       displ "Не найдены описания групп!!!" with centered row 5 frame ddd.
       pause 30.
       hide frame ddd.
    end.
end procedure .


/* --------------------------   добавление товаров в группу   -----*/
procedure o-skladbW.
repeat:
   update v-sid with frame getsid2.
   hide frame getsid2.
   
   find first grp where grp.grp = v-sid no-lock no-error.
   if avail grp then
   do: 
      v-des = grp.des.
      displ v-des LABEL "ГРУППА" format "x(20)" with row 2 centered
                        no-box side-labels frame dess.
      open query qb for each item where item.grp = v-sid and item.arc = no no-lock.
      enable all with frame fb. 
      wait-for window-close of frame fb focus browse bb.
   end.
   else do:
      displ "Группы товаров и материалов с таким номером не существует!!!" skip
            "         Попробуйте ввести номер еще раз"
            with centered row 7 frame ddd.
      pause 30.
      hide frame ddd.
      retry.
   end.
   hide frame dess.
end.
   
end procedure .


/* --------------------------   список всех товаров в группе  -----*/
procedure o-skladbR.
repeat:
   update v-sid at 5 with row 2 frame getsid.
   hide frame getsid.

   if v-sid > 0 then
   do:
      if can-find (first item where item.grp = v-sid no-lock) then
      do:
        for each wcur3: delete wcur3. end.
        define var v-des2 like v-des.
        run get-s-des(v-sid, output v-des2).
        for each item where item.grp = v-sid and arc = no no-lock:
            create wcur3.
            run get-p-des(item.grp, item.item, output v-des).
            wcur3.sdes = v-des2.
            wcur3.pdes = v-des.
            wcur3.pid = item.item.
        end.
        open query qb1 for each wcur3 by wcur3.sdes by wcur3.pid.
        enable all with frame fb1.
        wait-for window-close of frame fb1 focus browse bb1.
        leave.
      end. 
      else do: 
          displ "Не найдены списки товаров для заданной группы!!!" skip
                "        Попробуйте ввести номер еще раз"
             with centered row 5 frame ddd.                           
          pause 30.      
          hide frame ddd.
          retry.
      end.
    end.
    else do:  /* вывести все группы */
         for each wcur3: delete wcur3. end.
         for each item where arc = no no-lock:
            create wcur3.
            run get-s-des(item.grp, output v-des).
            wcur3.sdes = v-des.
            run get-p-des(item.grp, item.item, output v-des).
            wcur3.pdes = v-des.
            wcur3.pid = item.item.
            wcur3.sid = item.grp.
         end.
         open query qb1 for each wcur3 by wcur3.sid by wcur3.pid.
         enable all with frame fb1.
         wait-for window-close of frame fb1 focus browse bb1.
         leave.
    end.
   end.
   hide frame dess.
end procedure .

/* ------------------------------------------- печать тек. склада  -----*/
procedure o-tabhista.

   def var total as decimal.
   def var atot  as integer.
   total = 0.0.
   atot = 0.
   release wcur.

   for each wcur: delete wcur. end.

    update v-sid label "Введите номер группы (0 - для всех)" 
           with frame getsid with row 7.
    if v-sid > 0 then
    update v-pid label "Введите номер товара (0 - все товары в группе)"
           with frame getpid with row 10 .

    hide frame getsid.
    hide frame getpid.
    
    if v-sid > 0 then /* v-sid ne 0  -->  выбор группы */
    do:
       if v-pid > 0 then /*  выбор товара  */
           for each skladc where skladc.sid = v-sid
                           and skladc.pid = v-pid
                           by skladc.pid by skladc.dpr:
               create wcur.
               run get-p-des (skladc.sid, v-pid, output wcur.pdes).
               wcur.amt = skladc.amt.
               wcur.cost = skladc.cost.
               wcur.sid = skladc.sid.
               wcur.dpr = skladc.dpr.
           end.
        else   /*  все товары */
           for each skladc where skladc.sid = v-sid 
                                 by skladc.pid by skladc.dpr:
           create wcur.
           run get-p-des (v-sid, skladc.pid, output wcur.pdes).
           wcur.amt = skladc.amt.
           wcur.cost = skladc.cost.
           wcur.sid = skladc.sid.
           wcur.dpr = skladc.dpr.
       end.
    end.
    else  /* v-sid = 0   -->  для всех групп */
           for each skladc by skladc.sid by skladc.pid by skladc.dpr:
               create wcur.
               run get-p-des (skladc.sid, skladc.pid, output wcur.pdes).
               wcur.amt = skladc.amt.
               wcur.cost = skladc.cost.
               wcur.sid = skladc.sid.
               wcur.dpr = skladc.dpr.
           end.
if can-find(first wcur no-lock)
then do:
   def var lenta as logical.
   find first ofc where ofc.ofc = userid('bank').
   if ofc.mday[1] = 1 then /* лента */ lenta = true.
                      else /* страница */ lenta = false.
   if lenta then output to rpt.img page-size 0.
            else output to rpt.img page-size 66.
   put skip(1).
   put "                  Текущее состояние на складе" skip (1).
   put 
"==========================================================================="
   skip.
   put 
"Наименование                              | Кол-во|         Цена|   ДатаПр|" 
   skip.
   put
"---------------------------------------------------------------------------"
   skip.

   for each wcur break by wcur.pdes: /*by wcur.sid by wcur.pdes by wcur.dpr*/
       if lenta = false
       then if line-counter + 2 > page-size then page.
       put wcur.pdes format "x(42)" "|"
           wcur.amt "|" wcur.cost "| " wcur.dpr "|" skip.
       total = total + (wcur.amt * wcur.cost).
       atot = atot + wcur.amt.
       if last-of (wcur.pdes) then
       put
"---------------------------------------------------------------------------"
skip.
   end.
   if lenta = false then if line-counter + 2 > page-size then page.
   put 
"==========================================================================="
   skip(1).
   put "        ИТОГОВОЕ КОЛИЧЕСТВО: " atot format "zzzzzzzzzzz" skip.
   put "                  СТОИМОСТЬ: " total format 
                          "z,zzz,zzz,zzz,zz9.99".
   output close.
   run menu-prt("rpt.img").
   pause 0.
end.
else message "Таких товаров на складе нет!"  view-as alert-box.

end procedure.

/* ------------------------------------------- печать истории приходов  -----*/
procedure o-tabhistb.
def var tota like skladh.amt.
def var total like skladh.cost.
tota = 0.
total = 0.0.
release wcur2.

   displ "ИСТОРИЯ ПРИХОДОВ" with centered no-box frame iii.
   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.

   hide frame fdat.
   displ "Идет печать..." with frame iii.
            
   if can-find (first skladh where type = "P" and whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
           end.

      def var lenta as logical.
      find first ofc where ofc.ofc = userid('bank').
      if ofc.mday[1] = 1 then /* лента */ lenta = true.
                         else /* страница */ lenta = false.
      if lenta then output to rpt.img page-size 0.
               else output to rpt.img page-size 66.
      put skip(1).
      put "                  История приходов с " dfrom " по " dto skip (1).
      put FILL ("=", 94) format "x(94)" skip.
      put "Дата    |Наименование".
      put "                     | Кол-во|                Цена |"
      "           Стоимость|" skip.
      put FILL ("=", 94) format "x(94)" skip.

      for each wcur2 break by wcur2.sid by wcur2.pid by wcur2.whn:
        if lenta = false
        then if line-counter + 2 > page-size then page.
        put wcur2.whn "|" wcur2.pdes format "x(33)"
                      "|"  wcur2.amt "|" wcur2.cost "|"
                      wcur2.amt * wcur2.cost
                      format "z,zzz,zzz,zzz,zz9.99" "|" skip.
        tota = tota + wcur2.amt.
        total = total + wcur2.amt * wcur2.cost.
        if last-of (wcur2.pid) then put FILL ("-", 94) format "x(94)" skip.
      end.
      put FILL ("=", 94) format "x(94)" skip(1).
   put "        ИТОГОВОЕ КОЛИЧЕСТВО: " tota format "zzzzzzzzzzz" skip.
   put "                  СТОИМОСТЬ: " total format 
                          "z,zzz,zzz,zzz,zz9.99".


      output close.
      run menu-prt("rpt.img").
      pause 0.
   end. /* can-find skladh ..... */
      else message "Не найдены записи о приходах за период!" view-as alert-box.

   hide frame iii.
   pause 0.
end procedure.


/* ------------------------------------------- печать истории списаний  -----*/
procedure o-tabhistc.
def var tota like skladh.amt.
def var total like skladh.cost.
tota = 0.
total = 0.0.
release wcur2.

   displ "ИСТОРИЯ СПИСАНИЙ" with centered no-box frame iii.
   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.

   hide frame fdat.
   displ "Идет печать..." with frame iii.
            
   if can-find (first skladh where type = "S" and whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
           end.

      def var lenta as logical.
      find first ofc where ofc.ofc = userid('bank').
      if ofc.mday[1] = 1 then /* лента */ lenta = true.
                         else /* страница */ lenta = false.
      if lenta then output to rpt.img page-size 0.
               else output to rpt.img page-size 66.
      put skip(1).
      put "                  История списаний с " dfrom " по " dto skip (1).
   put FILL ("=", 102) format "x(102)" skip.
   put
"Дата    |Наименование".
   put "                     | Кол-во|                Цена |"
   "           Стоимость|   Г/К |" skip.
   put FILL ("-", 102) format "x(102)" skip.

      for each wcur2 break by wcur2.sid by wcur2.pid by wcur2.whn:

       if lenta = false
       then if line-counter + 2 > page-size then page.
       put wcur2.whn "|" wcur2.pdes format "x(33)" "|" wcur2.amt "|"
           wcur2.cost "|"  wcur2.amt * wcur2.cost
           format "z,zzz,zzz,zzz,zz9.99" "| " wcur2.gl format "999999" "|" skip.
       tota = tota + wcur2.amt.
       total = total + wcur2.amt * wcur2.cost.
        if last-of (wcur2.pid) then put FILL ("-", 102) format "x(102)" skip.
      end.

      put FILL ("=", 102) format "x(102)" skip(1).
   put "        ИТОГОВОЕ КОЛИЧЕСТВО: " tota format "zzzzzzzzzzz" skip.
   put "                  СТОИМОСТЬ: " total format 
                          "z,zzz,zzz,zzz,zz9.99".

      output close.
      run menu-prt("rpt.img").
      pause 0.
   end. /* can-find skladh ..... */
      else message "Не найдены записи о списаниях за период!" view-as alert-box.

   hide frame iii.
   pause 0.
end procedure.


/* ------------------------------------------- печать истории всех проводок -----*/
procedure o-tabhitrx.
   release wcur2.

   displ "ИСТОРИЯ ВСЕХ ПРОВОДОК" with centered no-box frame iii.
   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.

   hide frame fdat.
   displ "Идет печать..." with frame iii.
            
   if can-find (first skladh where type ne "A" and
                type ne "B" and whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where INDEX("AB", skladh.type) <= 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where INDEX("AB", skladh.type) <= 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where INDEX("AB", skladh.type) <= 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
                  create wcur2.
                  run get-p-des (skladh.sid, skladh.pid, output v-des).
                  assign wcur2.sid = skladh.sid
                         wcur2.pid = skladh.pid
                         wcur2.pdes = v-des
                         wcur2.amt = skladh.amt
                         wcur2.cost = skladh.cost
                         wcur2.who = skladh.who
                         wcur2.whn = skladh.whn
                         wcur2.type = skladh.type
                         wcur2.gl = skladh.gl.
               end.
           end.

      def var lenta as logical.
      find first ofc where ofc.ofc = userid('bank').
      if ofc.mday[1] = 1 then /* лента */ lenta = true.
                         else /* страница */ lenta = false.
      if lenta then output to rpt.img page-size 0.
               else output to rpt.img page-size 66.
      put skip(1).
      put "                  История проводок с " dfrom " по " dto skip (1).
   put FILL ("=", 143) format "x(143)" skip.
   put "Дата    |Наименование ".
   put "            |                Цена|        П Р И Х О Д         |".
   put "        Р А С Х О Д      ".
   put "   |        О С Т А Т О К       |" skip.
   put
"        |               ".
   put   "          |            за штуку| Кол-во|           Стоимость|".
   put " Кол-во|           Стоимость| Кол-во|           Стоимость|" skip.
   put FILL ("-", 143) format "x(143)" skip.


   for each wcur2 break by wcur2.pdes by wcur2.whn:
       if lenta = false
       then if line-counter + 2 > page-size then page.
       if wcur2.type = "P" then
          /* приход --- ДЕБЕТ */
          put wcur2.whn "|" wcur2.pdes format "x(25)" "|" wcur2.cost 
              format "z,zzz,zzz,zzz,zz9.99" "|"
              wcur2.amt "|" wcur2.amt * wcur2.cost 
              format "z,zzz,zzz,zzz,zz9.99" "|"
              "       |                    |". 
         else /* расход --- КРЕДИТ */
          put wcur2.whn "|" wcur2.pdes format "x(25)" "|" wcur2.cost
              format "z,zzz,zzz,zzz,zz9.99" "|"
              "       |                    |"
              wcur2.amt "|" wcur2.amt * wcur2.cost 
              format "z,zzz,zzz,zzz,zz9.99" "|".

        if last-of (wcur2.whn) then
        do:
        FIND LAST sklado where sklado.sid = wcur2.sid and
                               sklado.pid = wcur2.pid and
                               sklado.whn = wcur2.whn and
                               sklado.type = "T"
                               no-lock no-error.
              if avail sklado then put sklado.amt "|" sklado.cost
                       format "z,zzz,zzz,zzz,zz9.99" "|" skip.
              else put "       |                    |" skip.
              if last-of(wcur2.pdes) then put FILL ("-", 143) format "x(143)" skip.
        end.
        else put "       |                    |" skip.
   end.  
   put FILL ("=", 143) format "x(143)" skip.
      output close.
      run menu-prt("rpt.img").
      pause 0.
   end. /* can-find skladh ..... */
      else message "Не найдены записи о проводках за период!" view-as alert-box.

   hide frame iii.
   pause 0.
end procedure.


/* -------------------------------------------   текущий склад   -----*/
procedure o-scurrent.

    update v-sid label "Введите номер группы (0 - для всех)" 
           with frame getsid with row 7.
    if v-sid > 0 then
    update v-pid label "Введите номер товара (0 - все товары в группе)"
           with frame getpid with row 10 .

    define var v-des1 as char format "x(22)".
    define var v-des2 as char format "x(22)".
    totamt = 0.
    totcost = 0.0.

    hide frame getsid.
    hide frame getpid.
    for each wcur: delete wcur. end.
    
    if v-sid > 0 then /* v-sid ne 0  -->  выбор группы */
    do:
       if v-pid > 0 then /*  выбор товара  */
           for each skladc where skladc.sid = v-sid
                           and skladc.pid = v-pid
                           by skladc.pid by skladc.dpr:
               create wcur.
               run get-p-des (skladc.sid, v-pid, output wcur.pdes).
               wcur.amt = skladc.amt.
               wcur.cost = skladc.cost.
               wcur.sid = skladc.sid.
               wcur.pid = skladc.pid. 
               wcur.dpr = skladc.dpr.
               totamt = totamt + skladc.amt.
               totcost = totcost + (skladc.amt * skladc.cost).
           end.
        else   /*  все товары */
           for each skladc where skladc.sid = v-sid 
                                 by skladc.pid by skladc.dpr:
           create wcur.
           run get-p-des (v-sid, skladc.pid, output wcur.pdes).
           wcur.amt = skladc.amt.
           wcur.cost = skladc.cost.
           wcur.sid = skladc.sid.
           wcur.pid = skladc.pid. 
           wcur.dpr = skladc.dpr.
           totamt = totamt + skladc.amt.
           totcost = totcost + (skladc.amt * skladc.cost).
       end.
    end.
    else  /* v-sid = 0   -->  для всех групп */
           for each skladc by skladc.pid by skladc.dpr:
               create wcur.
               run get-p-des (skladc.sid, skladc.pid, output wcur.pdes).
               wcur.amt = skladc.amt.
               wcur.cost = skladc.cost.
               wcur.sid = skladc.sid.
               wcur.pid = skladc.pid. 
               wcur.dpr = skladc.dpr.
               totamt = totamt + skladc.amt.
               totcost = totcost + (skladc.amt * skladc.cost).
           end.

    if can-find (first wcur no-lock) then
    do:
       open query qc for each wcur by wcur.sid by wcur.pdes by wcur.dpr.
       enable all with frame fc.
       displ totamt totcost with frame fc.
       apply "value-changed" to browse bc.
       wait-for window-close of frame fc focus browse bc.
    end.
    else message "Таких товаров на складе нет!"  view-as alert-box.
    
    hide frame choos.
    for each wcur: delete wcur. end.
end procedure.

/* ------------------------------------------- список F2 для писания ------*/
procedure help-curskl.
find first wcho no-error.
if not avail wcho then
do:
    displ "На складе нет товаров, подлежащих списанию"
    with centered row 10 frame fff.
    pause 60.
    hide frame fff.
    return.
end.
{aapbra.i
      &head      = "wcho"
      &index     = "iid no-lock"
      &formname  = "help-sklad"
      &framename = "hcurr"
      &where     = " "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "wcho.des wcho.amt wcho.cost wcho.dpr"
      &highlight = "wcho.des wcho.amt wcho.cost wcho.dpr"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           v-cost = wcho.cost.
                           v-dpr = wcho.dpr.
                           hide frame hcurr.
                           return.  
                    end."
      &end = "hide frame hcurr. return."
}          

end procedure.


/*---------------------------   возвращает описание товаров и групп ------*/
procedure get-s-des.
    define input parameter s like grp.grp.
    define output parameter d like grp.des.
    find first grp where grp.grp = s no-lock no-error.
    if avail grp then d = grp.des.
                    else d = "".
end.

procedure get-p-des.
    define input parameter s like grp.grp.
    define input parameter p like item.item.
    define output parameter d like item.des.
      
    find first item where item.grp = s and item.item = p no-lock no-error.
    if avail item then d = item.des.
end.                      


procedure help-skgl.
{aapbra.i
      &head      = "gl"
      &index     = "gl no-lock"
      &formname  = "help-sklad"
      &framename = "hgl"
      &where     = " "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "gl.gl gl.des gl.subled gl.level format 'z9'"
      &highlight = "gl.gl gl.des gl.subled gl.level format 'z9'"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           frame-value = gl.gl.
                           hide frame hgl.
                           return.  
                    end."
      &end = "hide frame hgl."
}          
end procedure.

procedure help-skpid.
def var choice as int format "9" init 2.
def var str as char format "x(60)" init ''.
message "Поиск по номеру (1) или поиск по части названия (2)" update choice. 
if choice = 2 then message "Часть названия" update str.
{aapbra.i
      &head      = "item"
      &index     = "grp_item"
      &formname  = "help-sklad2"
      &framename = "hpid"
      &where     = " item.grp = v-sid and caps(item.des) matches '*' + caps(trim(str)) + '*' "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "item.item  item.des"
      &highlight = "item.item item.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           /* frame-value = item.item. */
                           hide frame hpid.
                           return string(item.item).  
                    end."
      &end = "hide frame hpid."
}          
end procedure.

procedure help-sksid.
{aapbra.i
      &head      = "grp"
      &index     = "grp no-lock"
      &formname  = "help-sklad2"
      &framename = "hsid"
      &where     = " "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "grp.grp grp.des"
      &highlight = "grp.grp grp.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           frame-value = grp.grp.
                           hide frame hsid.
                           return.  
                    end."
      &end = "hide frame hsid."
}          
end procedure.

procedure help-skarp.
{aapbra.i
      &head      = "arp"
      &index     = "arp no-lock"
      &formname  = "help-sklad2"
      &framename = "harp"
      &where     = " arp.crc = 1 "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "arp.arp arp.des"
      &highlight = "arp.arp arp.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do
                          on endkey undo, leave:
                           frame-value = arp.arp.
                           hide frame harp.
                           return.
                    end."
      &end = "hide frame harp."
}
end procedure.


/* ----------------------------    история Приходов   ------- */
procedure o-histpr.
release wcur2.
displ "ИСТОРИЯ ПРИХОДОВ" with centered no-box frame iii.

   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.
   hide frame fdat.

   totamt = 0.
   totcost = 0.
            
   if can-find (first skladh where type = "P" and whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message 
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where skladh.type = "P" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message 
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
           end.

          open query qc2 for each wcur2 by wcur2.sid by wcur2.pid by wcur2.dpr.
          enable all with frame fc2.
          displ totamt totcost with frame fc2. pause 0.
          apply "value-changed" to browse bc2.
          wait-for window-close of frame fc2 focus browse bc2.
       
    end. /* can-find skladh ..... */
    else
       message "Не найдены записи о приходах за период!" view-as alert-box.

    hide frame iii.
    
end procedure.

/* -----------------------------  ИСТОРИЯ СПИСАНИЙ --------------------- */
procedure o-histsp.
release wcur2.
displ "ИСТОРИЯ СПИСАНИЙ" with centered no-box frame iii.

   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.
   hide frame fdat.

   totamt = 0.
   totcost = 0.
            
   if can-find (first skladh where type = "S" and whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where skladh.type = "S" and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
           end.


       open query qc2 for each wcur2 by wcur2.sid by wcur2.pid by wcur2.dpr.
       enable all with frame fc2.
       displ totamt totcost with frame fc2. pause 0.
       apply "value-changed" to browse bc2.
       wait-for window-close of frame fc2 focus browse bc2.
       
    end. /* can-find skladh ..... */
    else
       message "Не найдены записи о списаниях за период!" view-as alert-box.
       
    hide frame iii.
    
end procedure.

/* -----------------------------  ИСТОРИЯ ПРИХОДОВ + СПИСАНИЙ ------------------ */
procedure o-histall.
release wcur2.
displ "ИСТОРИЯ ВСЕХ ПРОВОДОК" with centered no-box frame iii.
      

   update dfrom with frame fdat.
   update dto with frame fdat.

   update v-sid label "Введите номер группы (0 - для всех)"
          with frame getsid with row 7.
   if v-sid > 0 then
   update v-pid label "Введите номер товара (0 - все товары в группе)"
          with frame getpid with row 10 .

   hide frame getsid.
   hide frame getpid.
   hide frame fdat.

   totamt = 0.
   totcost = 0.
            
   if can-find (first skladh where INDEX ("AB", skladh.type) = 0 and
                whn >= dfrom and whn <= dto)
   then do:
      for each wcur2: delete wcur2. end.

      if v-sid > 0 then
      do: /* выбор товара */
          if v-pid > 0 then /* по товару... */
          do:
               for each skladh where INDEX ("AB", skladh.type) = 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid and
                        skladh.pid = v-pid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
          else do: /* все товары в группе */
               for each skladh where INDEX ("AB", skladh.type) = 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto and
                        skladh.sid = v-sid
                        no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
          end.
      end.
      else do: /* все товары и все группы */
               for each skladh where INDEX ("AB", skladh.type) = 0 and
                        skladh.whn >= dfrom and
                        skladh.whn <= dto no-lock:
               create wcur2.
               wcur2.sid = skladh.sid.
               wcur2.pid = skladh.pid.
               run get-p-des (skladh.sid, skladh.pid, output v-des).
               wcur2.pdes = v-des.
               wcur2.amt = skladh.amt.
               wcur2.cost = skladh.cost.
               wcur2.who = skladh.who.
               wcur2.whn = skladh.whn.
               wcur2.dpr = skladh.dpr.
               wcur2.type = skladh.type.
               wcur2.gl = skladh.gl.
               totamt = totamt + wcur2.amt.
               totcost = totcost + (wcur2.amt * wcur2.cost).
               FIND LAST sklado where sklado.sid = skladh.sid and
                                      sklado.pid = skladh.pid and
                                      sklado.whn = skladh.whn and
                                      sklado.type = "T"
                                      no-lock no-error.
               if not avail sklado then message
                    "Не найден остаток за дату" skladh.whn " sid=" skladh.sid
                    " pid=" skladh.pid view-as alert-box.
               else do:
                        wcur2.amtrest = sklado.amt.
                        wcur2.costrest = sklado.cost.
                    end.
               end.
           end.

       open query qc2 for each wcur2 by wcur2.sid by wcur2.pid by wcur2.whn.
       enable all with frame fc2.
       displ totamt totcost with frame fc2. pause 0.
       apply "value-changed" to browse bc2.
       wait-for window-close of frame fc2 focus browse bc2.
       
    end. /* can-find skladh ..... */
    else
       message "Не найдены записи о проводках за период!" view-as alert-box.
       
    hide frame iii.
    
end procedure.


/* -----------------------------  ОСТАТОК НА ДАТУ   ---------------------------- */
procedure o-dateost.
    def var v-dat as date.
    
    release wcur.
    v-dat = g-today.

    update v-dat label "Введите дату" with row 5 centered frame fddd.
    hide frame fddd.
   
    update v-sid label "Введите номер группы (0 - для всех)" 
           with frame getsid with row 7.
    if v-sid > 0 then
    update v-pid label "Введите номер товара (0 - все товары в группе)"
           with frame getpid with row 10 .

    define var v-des1 as char format "x(22)".
    define var v-des2 as char format "x(22)".
    totamt = 0.
    totcost = 0.0.

    hide frame getsid.
    hide frame getpid.
    for each wcur: delete wcur. end.
    
    if v-sid > 0 then /* v-sid ne 0  -->  выбор группы */
    do:
       if v-pid > 0 then /*  выбор товара  */
        do:
           for each sklado where sklado.sid = v-sid
                           and sklado.pid = v-pid
                           and sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, v-pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
               totamt = totamt + wcur.amt.
               totcost = totcost + (wcur.amt * wcur.cost).
           end.
           for each sklado where sklado.sid = v-sid
                           and sklado.pid = v-pid
                           and sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr and
                            wcur.cost = sklado.cost) then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, v-pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
                    totamt = totamt + wcur.amt.
                    totcost = totcost + (wcur.amt * wcur.cost).
               end.
           end.
        end.
        else   /*  все товары */
        do:
           for each sklado where sklado.sid = v-sid
                           and sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
               totamt = totamt + wcur.amt.
               totcost = totcost + (wcur.amt * wcur.cost).
           end.
           for each sklado where sklado.sid = v-sid
                           and sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr
                            and wcur.pid = sklado.pid
                            and wcur.cost = sklado.cost) 
                            then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
                    totamt = totamt + wcur.amt.
                    totcost = totcost + (wcur.amt * wcur.cost).
               end.
           end. /* for each */
        end. /* else... */
    end. /* for all v-pid */ 
    else  /* v-sid = 0   -->  для всех групп */
        do:
           for each sklado where sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.                    
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
               totamt = totamt + wcur.amt.
               totcost = totcost + (wcur.amt * wcur.cost).
           end.
           for each sklado where
                           sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr
                            and wcur.pid = sklado.pid
                            and wcur.sid = sklado.sid
                            and wcur.cost = sklado.cost) 
                            then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
                    totamt = totamt + wcur.amt.
                    totcost = totcost + (wcur.amt * wcur.cost).
               end.
           end. /* for each */
        end. /* else... */

    for each wcur: 
       if wcur.amt = 0 then delete wcur.
    end.

    if can-find (first wcur no-lock) then
    do:
       open query qc for each wcur by wcur.sid by wcur.pid by wcur.dpr.
       enable all with frame fc.
       apply "value-changed" to browse bc.
       displ totamt totcost with frame fc.
       wait-for window-close of frame fc focus browse bc.
    end.
    else message "Таких товаров на складе нет!"  view-as alert-box.
    
    hide frame choos.
    for each wcur: delete wcur. end.
end procedure.

/*-------------------------------------------   печать остатков на дату ----------*/
procedure o-prtost.
    def var v-dat as date.
    def var total as decimal format "z,zzz,zzz,zzz,zz9.99999".
    def var atot like skladh.amt init 0.
    def var t_amt as int.    
    def var t_cos as decimal.

    release wcur.
    find first wcur no-error.
    if avail wcur then
    do:
       for each wcur: delete wcur. end.
    end.

    v-dat = g-today.

    update v-dat label "Введите дату" with row 5 centered frame fddd.
    hide frame fddd.

    update v-sid label "Введите номер группы (0 - для всех)"
           with frame getsid with row 7.
    if v-sid > 0 then
    update v-pid label "Введите номер товара (0 - все товары в группе)"
           with frame getpid with row 10 .

    define var v-des1 as char format "x(22)".
    define var v-des2 as char format "x(22)".

    hide frame getsid.
    hide frame getpid.

    if v-sid > 0 then /* v-sid ne 0  -->  выбор группы */
    do:
       if v-pid > 0 then /*  выбор товара  */
        do:
           for each sklado where sklado.sid = v-sid
                           and sklado.pid = v-pid
                           and sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, v-pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
           end.
           for each sklado where sklado.sid = v-sid
                           and sklado.pid = v-pid
                           and sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr and
                            wcur.cost = sklado.cost) then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, v-pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
               end.
           end.
        end.
        else   /*  все товары */
        do:
           for each sklado where sklado.sid = v-sid
                           and sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
           end.
           for each sklado where sklado.sid = v-sid
                           and sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr
                            and wcur.pid = sklado.pid
                            and wcur.cost = sklado.cost)
                            then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
               end.
           end. /* for each */
        end. /* else... */
    end. /* for all v-pid */
    else  /* v-sid = 0   -->  для всех групп */
        do:
           for each sklado where sklado.whn = v-dat
                           and sklado.type = "O"
                           no-lock:
               create wcur.
               run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
               wcur.amt = sklado.amt.
               wcur.cost = sklado.cost.
               wcur.sid = sklado.sid.
               wcur.pid = sklado.pid.
               wcur.dpr = sklado.dpr.
           end.
           for each sklado where
                           sklado.whn < v-dat
                           and sklado.type = "O"
                           use-index www
                           no-lock:
               if can-find (wcur where wcur.dpr = sklado.dpr
                            and wcur.pid = sklado.pid
                            and wcur.sid = sklado.sid
                            and wcur.cost = sklado.cost)
                            then next.
               else do:
                    create wcur.
                    run get-p-des (sklado.sid, sklado.pid, output wcur.pdes).
                    wcur.amt = sklado.amt.
                    wcur.cost = sklado.cost.
                    wcur.sid = sklado.sid.
                    wcur.pid = sklado.pid.
                    wcur.dpr = sklado.dpr.
               end.
           end. /* for each */
        end. /* else... */

    for each wcur:
       if wcur.amt = 0 then delete wcur.
    end.


  /*
     а тута сама печать и локализуется!
                                        */

  if can-find (first wcur no-lock) then
  do:
   def var lenta as logical.
   find first ofc where ofc.ofc = userid('bank').
   if ofc.mday[1] = 1 then /* лента */ lenta = true.
                      else /* страница */ lenta = false.
   if lenta then output to rpt.img page-size 0.
            else output to rpt.img page-size 66.
   put skip(1).
   put "                  Остатки на дату:" v-dat skip (1).
   put
"==========================================================================="
"====================="
   skip.
   put
"Наименование                              | Кол-во|         Цена|   ДатаПр|".
   put "           Стоимость|" skip.
   put
"---------------------------------------------------------------------------"
"---------------------"
   skip.

   for each wcur break by wcur.sid by wcur.pid by wcur.dpr:
       if lenta = false
       then if line-counter + 2 > page-size then page.
       put wcur.pdes format "x(42)" "|"
           wcur.amt "|" wcur.cost "| " wcur.dpr "|" wcur.amt * wcur.cost
           format "z,zzz,zzz,zzz,zz9.99" "|" skip.

       total = total + (wcur.amt * wcur.cost).
       atot = atot + wcur.amt.

       if first-of (wcur.pid) then assign t_amt = 0 t_cos = 0.0.
       t_amt = t_amt + wcur.amt.
       t_cos = t_cos + (wcur.amt * wcur.cost).

       if last-of (wcur.pid) then 
       do:
          put FILL ("-", 96) format "x(96)" skip.
          put " ИТОГОВОЕ КОЛИЧЕСТВО: " TRIM(STRING(t_amt, "zzzzzzzzzzz")).
          put "  СТОИМОСТЬ: " TRIM(STRING(t_cos, "z,zzz,zzz,zzz,zz9.99")) SKIP.
          put FILL ("-", 96) format "x(96)" skip.
       end.

   end.
   if lenta = false then if line-counter + 2 > page-size then page.
   put
"==========================================================================="
"====================="
   skip(1).

   put "        ИТОГОВОЕ КОЛИЧЕСТВО: " atot format "zzzzzzzzzzz" skip.
   put "                  СТОИМОСТЬ: " total format 
                          "z,zzz,zzz,zzz,zz9.99".

   output close.
   run menu-prt("rpt.img").
   pause 0.

   end. /* if */
   else message "Таких товаров на складе нет!"  view-as alert-box.

    hide frame choos.
    for each wcur: delete wcur. end.
end procedure.

procedure sverka.
def var sumcol as integer.

for each wskitem. delete wskitem. end. 
/*for each skladb. 
 create wskitem. 
    wskitem.sid = item.grp.
    wskitem.pid = item.item.
    wskitem.des = item.des.
 end.*/
       update v-date label 'Введите дату, на которую сверяются остатки' with frame str row 2 centered.
       hide frame str.
 for each skladp.
  sumcol = 0.

 find wskitem where wskitem.sid = skladp.sid and wskitem.pid = skladp.pid no-lock no-error.
 if not avail wskitem then do: 
     create wskitem.  
     wskitem.sid = skladp.sid.  
     wskitem.pid = skladp.pid. 
   for  each skladc where skladc.sid = skladp.sid and skladc.pid = skladp.pid no-lock .
       sumcol = sumcol + skladc.amt.
   end.
      wskitem.ost = wskitem.ost + sumcol.
   end.

  find item where item.grp = skladp.sid and item.item = skladp.pid no-lock no-error.
      wskitem.des = item.des.
     wskitem.ost = wskitem.ost + skladp.amt.
 end. 
 run sverka2.

 output stream rpt to sver.img.
  put stream rpt unformatted  '             СВЕРКА ОСТАТКОВ ПО СОСТОЯНИЮ НА    ' string(v-date) skip.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
  put stream rpt unformatted '|Группа|Товар(ID)|    Наименование Товара       | Остаток  после  | Остаток после  | Расхождение |' skip.
  put stream rpt unformatted '|      |         |                              | прихода (PRAGMA)| прихода (Склад)|             |' skip.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.

 for each wskitem. 
  put stream rpt unformatted '|'wskitem.sid format 'zz9' space(3) '|' wskitem.pid format 'zzz9' space(5) '|' 
                            wskitem.des format 'x(30)' '|' wskitem.ost format 'zzzzzz9'  space(10) '|'
                            wskitem.ost2 format 'zzzzzz9'  space(9) '|' wskitem.ost - wskitem.ost2 format 'zzzzz9-'  space(6) '|'   skip.
end.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
 
output stream rpt close .
 run menu-prt('sver.img').
end procedure.
