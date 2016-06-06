/* limits.p
 * MODULE
        Ввод лимитов        
 * DESCRIPTION
        Ввод лимитов        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.4.2
 * BASES
     BANK SKLAD
 * AUTHOR
        28/11/2005 nataly
 * CHANGES
        12.12.2005 nataly добавлен признак месяца и года  по лимитам
        14/02/2006 nataly копирование лимитов и остатков прошлого месяца
        17/02/2006 nataly добавлено удаление и копирование лимитов из месяца в месяц
*/




define temp-table wcho
       field des like item.des label "DES" column-label "НАИМЕНОВАНИЕ"
       field amt as decimal column-label "КОЛИЧЕСТВО"
       field cost like skladc.cost label "KZT" column-label "ЦЕНА"
       field dpr like skladc.dpr label "ДАТАПР" column-label "ДАТАПР"
       index iid dpr.
  
def stream rpt.
def new shared var v-date as date.
def shared var g-ofc as char.
def shared var g-today as date.
define shared var g-lang   as cha.

def var v-gl  like gl.gl init "575200".
def var v-arp as char.
def var v-crc like crc.crc.
def var v-rem as char.
def var v-sid as integer.
def var v-pid as integer.
def temp-table b-limits like limits.

def var v-monold as integer.
def var v-godold as integer.
def var v-monnew as integer.
def var v-godnew as integer.

{limits.f}
{yes-no.i}


def var v-sum as decimal.
ON HELP OF v-deps  IN FRAME income3 do:  run help-dep("000").
                                        v-deps:screen-value = return-value.
                                        v-deps = return-value.
                                    end.

ON HELP OF v-dep  IN FRAME ff2 do:  run help-dep("000").
                                        v-dep:screen-value = return-value.
                                        v-dep = return-value.
                                    end.

ON HELP OF blimits.sid  IN FRAME income2 do: 
                                        run help-sksid.
                                    end.
ON HELP OF blimits.pid  IN FRAME income2  do: 
                                        run help-skpid. 
                                        blimits.pid:screen-value = return-value.
                                        blimits.pid = int (return-value).
                                    end.
  
ON endkey OF FRAME income hide frame income.
ON endkey OF FRAME ff hide frame ff.

DEFINE SUB-MENU subremp     /*Приход*/
      MENU-ITEM skremap LABEL "Формирование списка"
      RULE
      MENU-ITEM skremnp LABEL "Очистить список".

DEFINE SUB-MENU subopt
      MENU-ITEM skopt LABEL "Копирование лимитов".
      MENU-ITEM skopt2 LABEL "Удаление лимитов".

DEFINE SUB-MENU subquit
      MENU-ITEM skquit LABEL "Выход".


DEFINE MENU mbar MENUBAR
      SUB-MENU subremp  LABEL "Ввод данных"
      SUB-MENU subopt  LABEL "Дополнительно"
      SUB-MENU subquit LABEL "Выход".


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


ON CHOOSE OF MENU-ITEM skopt /* копирование лимитов*/
    do:
        run cpy-limit.
        hide all.
    end.    


ON CHOOSE OF MENU-ITEM skopt2 /* удаление лимитов*/
    do:
        run del-limit.
        hide all.
    end.    

on "value-changed" of browse bp
do:
   st_amt = 0.
   st_sum = 0.0.
end.

/* --------------------  отчет по лимитам ---------- */
on "help" of browse bp
do:
 output stream rpt to 'rpt.img'.

    put stream rpt skip "СПИСОК ЛИМИТОВ В РАЗРЕЗЕ ДЕПАРТАМЕНТОВ" skip 
                        "Дата формирования отчета: "   today skip
                        "Исполнитель :             "    g-ofc.

  for each limits where limits.mon = v-mon and limits.god = v-god break by limits.god by limits.mon by limits.dep . 
   if first-of(limits.mon) then  do:
      put stream rpt skip(1) skip "Месяц: " limits.mon  " Год: " limits.god  skip.
  end.
   if first-of(limits.dep) then  do:
     find codfr where codfr.codfr = 'sdep' and codfr.code = limits.dep no-lock no-error.
      if avail codfr then 
           put stream rpt skip(1) skip codfr.name[1] format 'x(40)'  skip.
           put stream rpt fill("-",40) format("x(40)").
    end.
    put stream rpt skip limits.des format 'x(35)' limits.amt  skip.
  end. 
 output stream rpt close.
 run menu-prt('rpt.img').
end. 
/* --------------------  добавление лимита ---------- */
on "insert" of browse bp
do:
     run n-sklad.
   hide all.

   totamt = 0.

    for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god.
               totamt = totamt + limits.amt.
    end.
    displ totamt  with frame ftp no-label.
 
   close query qp.
   open query qp for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god by limits.sid by limits.pid .
   if can-find (first limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god) then browse bp:refresh().
   apply "value-changed" to browse bp.
end.

/* --------------------  редактирование лимита  ---------- */
on "return" of browse bp
do:
   totamt = 0.
   find current limits no-error.
   if avail limits then do:

     find sklad.item where item.grp = limits.sid and item.item = limits.pid no-lock no-error.
      if avail item then limits.des = item.des. else limits.des = "N/A".

    displ limits.sid limits.pid limits.des limits.amt limits.ost  with frame income.

    limits.dep =  v-dep.
    update  limits.amt  label "Лимит"
            limits.ost  label "Остаток" with frame income .
    end.
    else do: 
       message 'Список пуст!'. 
       pause 3. 
     end. 
   hide frame income.

    for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god.
               totamt = totamt + limits.amt.
    end.
    displ totamt  with frame ftp no-label.

   close query qp.
   open query qp for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god by limits.sid by limits.pid .
   if can-find (first limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god) then browse bp:refresh().
   apply "value-changed" to browse bp.
end.
/* --------------------------------  удаление лимита из списка */
on "clear" of browse bp
do:
    yesno = yes-no("Удаление из списка", "Вы уверены?").
    if yesno then
    do:
        v-sid = limits.sid.
        v-pid = limits.pid.
        v-dep = limits.dep.
        find first limits where limits.sid = v-sid and limits.pid = v-pid  and  limits.dep = v-dep  exclusive-lock.
        delete limits.
        release limits.


   totamt = 0.
        for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god.
               totamt = totamt + limits.amt.
        end.
        displ totamt  with frame ftp no-label.
        close query qp.
        open query qp for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god by limits.sid by limits.pid .

        if can-find(first limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god no-lock) then
        browse bp:refresh().
        apply "value-changed" to browse bp.
    end.
end.

ASSIGN CURRENT-WINDOW:MENUBAR = MENU mbar:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM skquit.               /* выход */
    

/*-------------------------    приход     -------------*/
procedure n-sklad.

 do transaction on error undo,retry:
 for each blimits. delete blimits. end.
   create blimits.

   displ blimits.sid blimits.pid blimits.des blimits.amt with frame income2.

   update blimits.sid with frame income2 .
   if blimits.sid > 0 then
   update blimits.pid with frame income2  .

     find sklad.item where item.grp = blimits.sid and item.item = blimits.pid no-lock no-error.
      if avail item then blimits.des = item.des. else blimits.des = "N/A".
   displ blimits.des with frame income2.

   blimits.dep =  v-dep.
   update  blimits.amt with frame income2.
   blimits.mon = v-mon.
   blimits.god = v-god.
   blimits.ost = blimits.amt.

    create limits.
    buffer-copy blimits to limits.

    hide frame income2.
 end.   
end procedure.


/*---------------------------   удаление списка - ПРИХОД ----------------*/
procedure r-skladnp.
    yesno = yes-no("Новый список","Внимание! Текущий список будет удален").
    if yesno = true then
    yesno = yes-no("","Вы уверены").
    if yesno = true then
       do:
          for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god:
          delete limits.
          end.
       end.
end procedure.

/*---------------------------   редакция списка - ПРИХОД -------------*/
procedure r-skladap.

/*     find sklad.item where item.grp = limits.sid and item.item = limits.pid no-lock no-error.
      if avail item then limits.des = item.des. else limits.des = "N/A".*/
     update v-deps  with frame income3.
      find codfr where codfr = 'sdep' and codfr.code = v-deps no-lock no-error.
    if avail codfr then  do: 
      v-desc = codfr.name[1]. 
      displ v-desc with frame income3. 
   end.
    else message v-desc = "Не определен".
    v-dep = v-deps.

     v-mon = month(g-today).
     v-god = year(g-today).
     update v-mon  v-god with frame income3.
    totamt = 0.
    open query qp for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god by limits.sid by limits.pid .
    enable all with frame ftp.

    for each limits where limits.dep = v-dep and limits.mon = v-mon and limits.god = v-god.
               totamt = totamt + limits.amt.
    end.
    displ totamt  with frame ftp no-label.
    apply "value-changed" to browse bp.
    wait-for window-close of frame ftp focus browse bp.
    release skladp.

end procedure.

/*---------------------------   сверка остатков - ПРИХОД   ----------------*/
procedure r-sklads.
   run sverka.
end procedure.

/*---------------------------   ТРАНЗАКЦИЯ - ПРИХОД   ----------------*/
procedure r-skladp.
   run prichod.
end procedure.

procedure help-skpid.
def var choice as int format "9" init 2.
def var str as char format "x(60)" init ''.
message "Поиск по номеру (1) или поиск по части названия (2)" update choice. 
if choice = 2 then message "Часть названия" update str.
{aapbra.i 
      &head      = "item"
      &index     = "grp_item"
      &formname  = "help-limit"
      &framename = "hpid"
      &where     = " item.grp = blimits.sid and caps(item.des) matches '*' + caps(trim(str)) + '*' "
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
      &formname  = "help-limit"
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

/*---------------------ПЕРЕНОС ЛИМИТОВ-------------------------*/
procedure cpy-limit.

for each b-limits. delete b-limits. end.

find last limits where limits.mon < month(g-today) and limits.god <= year(g-today). if avail limits then 
 do:
   v-monold = limits.mon.
   v-godold = limits.god.
 if v-monold < 12 then   v-monnew = v-monold + 1. else v-monnew = 1.
 if v-monold < 12 then   v-godnew = v-godold .  else v-godnew = v-godold + 1.
 end.

displ  v-monnew  v-godnew v-monold v-godold with frame ff.

update v-monnew 
       v-godnew 
       v-monold 
       v-godold   
       with frame ff no-labels title "ВВОД ДАННЫХ" row 4  .

 find first limits where limits.mon = v-monnew and limits.god = v-godnew no-lock no-error.
 if avail limit then 
  do:
   message 'Найдены записи с месяцем ' v-monnew  ' ' v-godnew 'г. Копирование данных невозможно!'.
   leave.
  end.

if v-monnew - v-monold > 1 then 
do:
  message 'Разница между старым и новым месяцем > 1 ! Копирование данных невозможно!'.
   leave.
end.

for each limits where limits.mon = v-monold and limits.god = v-godold. 

do transaction:
 create b-limits.
 buffer-copy limits to b-limits.
  b-limits.mon = v-monnew.
  b-limits.god = v-godnew.

end.
end.
  
 for each b-limits.
  create limits.
  buffer-copy b-limits to  limits.
 
/*  message b-limits.sid b-limits.pid b-limits.dep b-limits.amt b-limits.ost. */
 /*если есть остаток с предыдущего месяца, его переносим, если нет - остаток = лимиту*/
  if b-limits.ost > 0 then limits.ost = limits.amt + b-limits.ost.
  else limits.ost = limits.amt.
 end. 
 message 'Данные за ' v-monnew '/' v-godnew ' успешно внесены в базу!' view-as alert-box. 

end. 


/*---------------------УДАЛЕНИЕ ЛИМИТОВ-------------------------*/
procedure del-limit.



update v-mon 
       v-god 
       v-dep 
       with frame ff2 no-labels title "ВВОД ДАННЫХ" row 4  .

 if v-dep <> '000' then do:
 find first limits where limits.mon = v-mon and limits.god = v-god and limits.dep = v-dep no-lock no-error.
 if not avail limits then 
  do:
   message 'Не найдены записи с месяцем ' v-mon  ' ' v-god 'г. по департаменту' v-dep 'Удаление невозможно!'.
   leave.
  end.
 end.
 
   yesno = yes-no("Удалить ВСЕ лимиты департамента", "Вы уверены?").
    if yesno then
    do:

    do transaction:
     for each limits where mon = v-mon and god = v-god and 
         (if v-dep <> '000' then limits.dep = v-dep else true). 
  
            delete limits.
     end.
    end.

  find first limits where limits.mon = v-mon and limits.god = v-god and 
            (if v-dep <> '000' then limits.dep = v-dep else true) no-lock no-error.
  if avail limits then message 'Не все записи удалены!'.
   else
    message 'Данные за ' v-mon '/' v-god '  по департаменту' v-dep ' успешно удалены из базы!' view-as alert-box. 
   end.
end. 

