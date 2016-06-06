/* 
Модуль:
     CALL
Назначение:
     Справочная база по банку (основные вопросы)
Вызывается:
     скрипт ie.
Пункты меню:
     16
Автор:
     suchkov     Сучков Андрей Леонидович
Дата создания:
     (24-06-2003)
Протокол изменений:
     ДатаИзменения   ЛогинАвтораИзменения   ОписаниеИзменения
     21-01-2004      suchkov                Добавлена возможность экспорта 
     16-07-2004      torbaev                Курсы валют НацБанка и TexakaBank
     27-07-2004      torbaev                добавлена переменная gcount во фрейме fr3 
                                            (отражает общее количество запросов клиентов).
     28-07-2004      torbaev                появилась функция fncstat. Входные параметры - период дат, 
                                            на выходе кол-во запросов(звонков клиентов) за период.
     02-08-2004      torbaev                Сортировка по темам и по подтемам
                                            
     11.08.2004      saltanat               внесла hide all после некоторых вызовов процедур.
     12.08.2004      saltanat               реализованы пункты меню:
                                            1. Перечень документов для кредита физ. лиц.
                                            2. Перечень документов для юр. лиц.
     12.08.2004      saltanat               подправила работу пункта меню - Статистика в Excel.
     05.01.2005      saltanat               исправила ошибки при расчете периода статистики
     13.06.2005      saltanat               Добавлен новый пункт "Отчет по данным опроса клиентов". 
                                            При проведении опроса у клиентов выводятся услуги и источники с статусом 'r'. 
     
     18.09.06 u00379 - подкиньте пожалуйста исходники call.p и новый исходник udprint.p.  коннект к базам comm, bank.
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/
{global.i} 

define variable l      as integer initial 0.
define variable i      as integer .
define variable k      as integer .
define variable m      as integer .
define variable jj     as integer .
define variable co     as integer .
define variable opnu   as integer .
define variable samp   as character format "x(50)" label "Введите образец поиска".
define variable obraz  as character .
define variable yesno  as logical.
define variable ident  as rowid .
define variable per-s  as date .
define variable per-po as date .

define variable gcount as integer .
define variable gcnt as integer .
define variable currmonth as integer .
define variable prevmonth as integer .
define variable nextmonth as integer .
define variable begday as integer .
define variable endday as integer .
define variable begyear as integer .
define variable nextyear as integer .
define variable ondatecount as integer .
define variable enddayofprevmonth as date .
define variable bdate  as date .
define variable edate  as date .
define variable lookdate as date .
define variable QuestID as integer.
define variable counterID as integer.
define variable SubThemName as character.
define variable SubThemID  like sthem.nu.
define variable SubThemCount as integer.
define variable ThemCount as integer.
define variable subtID as integer.
define variable subtName as character.
define variable ThemID as integer.
define variable ThemName as character.
define variable FirstDayInMonth as logical.
define variable LastDayInMonth as logical.
define variable DontRepeatFirstDay as logical.
define variable CurrentMonth as integer.
define variable FirstPass as logical.
define variable gwBegDate as date.
define variable gwEndDate as date.
define variable SrvTotalByWeekCount as integer.
define variable SrvTotByMonthCnt as integer.
define variable MaxRecsXLSTable as integer initial 0.
define variable SumByRow as integer.
define variable SumByCol as integer extent 7.
define variable ForDepCalcID as integer.
define variable VarSthemNu as integer.

define temp-table statis like stat /*no-undo*/.
define temp-table opr 
            field ques like opros.ques label "Ответ клиента по статистике"
            field nu as integer label "Количество ответов".

define temp-table sttab
            field nu like ques.nu
            field frq as integer
            field ques like ques.ques
            field dat like stat.dat .

define temp-table QuestionsList
            field hotquests like ques.nu label "Номер вопроса"  /* активные (востребованные) вопросы за период */
            field questnames like ques.ques label "Вопросы".

define temp-table SubThemList
            field hotsubthID like sthem.nu label "Номер подтемы"
            field hotsubthemname like sthem.sub label "Наим. подтемы".  /* подтемы за период по которым были запросы */


define temp-table ThemesList
            field thID like them.num label "ї темы"  /* активные (востребованные) темы за период */
            field thName like them.them label "Услуги".


define temp-table weekslist
            field id as integer  label "RecID"
            field dayOfW as date label "День недели"
            field DayCode as integer label "Знак Пн./Пт".

define temp-table EditWeeks
            field id as integer  label "RecID"
            field BegDay as date label "Пн."
            field Endday as date label "Пт.".

define temp-table ForXLSTable
            field ServID like sthem.nu
            field ServName like sthem.sub
            field CallsCount as character extent 7.

define stream StatToExcel.





if not connected ("comm") then do:
message "connect comm...".
run comm-con.
end.


{yes-no.i}

{questions.f}

DEFINE SUB-MENU sublook
      MENU-ITEM s-look LABEL "Просмотр".

DEFINE SUB-MENU subfind
      MENU-ITEM fnques  LABEL "Поиск среди вопросов"
      MENU-ITEM fnansw  LABEL "Поиск среди ответов"
      MENU-ITEM fnall ACCELERATOR "CTRL-F" LABEL "Общий поиск".

DEFINE SUB-MENU subquit
      MENU-ITEM skquit  LABEL "Выход".

DEFINE SUB-MENU subadd
      MENU-ITEM addthem LABEL "Добавить тему"
      MENU-ITEM addsubthem LABEL "Добавить подтему"
      MENU-ITEM addques LABEL "Добавить вопрос".

DEFINE SUB-MENU submang
      MENU-ITEM outdata LABEL "Данные по входящим звонкам"
      MENU-ITEM crfile  LABEL "Сформировать файл с новыми вопросами"
      MENU-ITEM manstat LABEL "Просмотр статистики"
      MENU-ITEM prc-outstat-astable LABEL "Статистика в Excel"
      MENU-ITEM expexc  LABEL "Вывод вопросов в Internet Explorer" .
/*      MENU-ITEM manjour LABEL "Журнал действий оператора".*/

DEFINE SUB-MENU subinfo
/*      MENU-ITEM val-look ACCELERATOR "home" LABEL "Текущие курсы валют" */
      MENU-ITEM mi-callcurm ACCELERATOR "CTRL-V" LABEL "Новые курсы валют"
      MENU-ITEM mi-kasein ACCELERATOR "CTRL-E" LABEL "Ввод курсов валют KASE"
      MENU-ITEM rekvis  ACCELERATOR "CTRL-R" LABEL "Реквизиты банка"
      MENU-ITEM phones  ACCELERATOR "CTRL-T" LABEL "Телефоны"
      MENU-ITEM tarifsu LABEL "Тарифы для юридических лиц"
      MENU-ITEM tarifsf LABEL "Тарифы для физических лиц"
      MENU-ITEM docs    LABEL "Перечень документов для кредита физ. лиц."
      MENU-ITEM docsur  LABEL "Перечень документов для юр. лиц".
      MENU-ITEM credit-able  LABEL "Док-т для расчета кредитоспособности".
      MENU-ITEM grafik-p  LABEL "График погашения.xls".

DEFINE SUB-MENU subinp
      MENU-ITEM newques ACCELERATOR "CTRL-N" LABEL "Новый вопрос клиента".
      MENU-ITEM opdata  ACCELERATOR "CTRL-O" LABEL "Опросные данные".
      MENU-ITEM oprep   ACCELERATOR "CTRL-X" LABEL "Отчет по данным опроса клиентов".

DEFINE SUB-MENU udcl 
      MENU-ITEM print LABEL "Печать данных на удостоверение".
      MENU-ITEM order LABEL "Индивидуальный заказ".

DEFINE MENU mbar MENUBAR
      SUB-MENU sublook LABEL "Просмотр"
      SUB-MENU subfind LABEL "Поиск"
      SUB-MENU subadd  LABEL "Добавление вопросов"
      SUB-MENU submang LABEL "Управление центром"
      SUB-MENU subinfo LABEL "Информация"
      SUB-MENU subinp  LABEL "Быстрый ввод"
      SUB-MENU udcl  LABEL   "Удостоверение клиента"
      SUB-MENU subquit LABEL "Выход".


ON CHOOSE OF MENU-ITEM print 
   do:
        run udprint("1").
        hide all.
   end.
ON CHOOSE OF MENU-ITEM order 
   do:
        run udprint("2").
        hide all.
   end.

ON CHOOSE OF MENU-ITEM s-look   /* Просмотр  */    
    do:
        run look.
        hide all.
    end.
        
ON CHOOSE OF MENU-ITEM fnques /* Поиск среди вопросов */
    do:
        run fn-ques.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM fnansw /* Поиск среди ответов */
    do:
        run fn-answ.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM fnall /* Общий поиск */
    do:
        run fn-all. 
        hide all.
     end.
    
ON CHOOSE OF MENU-ITEM skquit   /* выход */
    do:
       if connected ("comm") then disconnect "comm" .
       return .
    end. 
 
ON CHOOSE OF MENU-ITEM addthem  /* добавление темы */
     do :        
       run add-them .
       hide all.
     end.

ON CHOOSE OF MENU-ITEM addsubthem  /* добавление подтемы */
     do :        
       run add-sthem .
       hide all.
     end.

ON CHOOSE OF MENU-ITEM addques  /* добавление вопроса */
     do :
       run add-ques.
       hide all.
     end.

ON CHOOSE OF MENU-ITEM outdata /* добавление менеджера */
     do :
/*       run out-data.
       hide all.
       for each opr . delete opr . end .
*/
       run alktic.
     end.

ON CHOOSE OF MENU-ITEM crfile /* выдача прав */
   do:
      run cr-file. 
      hide all.
   end.


ON CHOOSE OF MENU-ITEM manstat /* статистика */
   do:
      run man-stat. 
      hide all.
       for each sttab . delete sttab . end .
   end.

ON CHOOSE OF MENU-ITEM prc-outstat-astable /* статистика */  
   do:
      run dowork. 
      hide all. 
   end.

ON CHOOSE OF MENU-ITEM expexc /* статистика */
   do: run man-expexc. end.

/*ON CHOOSE OF MENU-ITEM manjour *//* журнал действий оператора */
/*   do:
      run man-jour.
      hide all.
   end.*/
/*
ON CHOOSE OF MENU-ITEM val-look /* просмотр валюты */
   do:
      run vallook.
      hide all.                                                           
   end.
*/
ON CHOOSE OF MENU-ITEM mi-callcurm /* просмотр валюты по новому */
   do:
      run callcurm.p.
   end.

ON CHOOSE OF MENU-ITEM credit-able /* Кредитоспособность.xls */ 
   do:
      run credable.
      hide all.                                                           
   end.

ON CHOOSE OF MENU-ITEM grafik-p /* График погашения.xls */ 
   do:
      run graf.
      hide all.                                                           
   end.

ON CHOOSE OF MENU-ITEM mi-kasein /* просмотр валюты по новому */
   do:
      run kasein.p.
   end.


ON CHOOSE OF MENU-ITEM rekvis /* просмотр реквизитов */
   do:
      run rek.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM phones /* просмотр телефонов */
   do:
      run phone.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM tarifsu /* просмотр тарифов юр. лиц*/
   do:
      run tarif-ur.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM tarifsf /* просмотр тарифов физлиц */
   do:
      run tarif-fis.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM newques /* печать истории приходов */
   do:
      run new-ques.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM opdata /* печать истории приходов */
   do:
      run opr.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM oprep /* отчет по данным опроса клиентов в ехсель */
   do:
      run opros.
      hide all.
   end.
   
ON CHOOSE OF MENU-ITEM docs /* перечень документов для оформления кредита */
   do:
      run doc-cred.
      hide all.
   end.

ON CHOOSE OF MENU-ITEM docsur /* перечень документов для оформления кредита */
   do:
      run doc-credur.
      hide all.
   end.


/*==========================================================================*/

/*
ON HOME ANYWHERE
   do:
     run vallook.
   end.
  */

/*==========================================================================*/

/* Когда вводят новую тему*/
on "return" of browse b1
do:
   find last them no-lock no-error.
   if avail them then l = them.nu. else l = 0.
   create them.
   them.sid = 1.
   them.nu = l + 1.
   update them.them with frame fr-1 .
   hide frame fr-1. 
   close query q1. 
   open query q1 for each them no-lock.
   browse b1:refresh().
   apply "value-changed" to browse b1.
end.

/* Когда вводят подтему*/
on "return" of browse b2
do:
   find last sthem no-lock no-error.
   if avail sthem then l = sthem.nu. else l = 0.
   create sthem.
   sthem.sid = 1 .
   sthem.nu = l + 1.
   sthem.them = them.nu .
   update sthem.sub with frame fr-2 .
   close query q2. 
   open query q2 for each them no-lock.
   browse b2:refresh().
   apply "value-changed" to browse b2.
end.

/* Когда вводят вопрос*/
on "return" of browse b4
do:
   open query q5 for each sthem where sthem.them = them.nu and sthem.sid <> 0 no-lock .
   enable all with frame fr5.
   wait-for window-close of frame fr5 focus browse b5.
   close query q4. 
   open query q4 for each them no-lock.
   browse b4:refresh().
   apply "value-changed" to browse b4.
end.

on "return" of browse b5
do:
   VarSthemNu = -1.
   find last ques no-lock no-error.
   if available ques then l = ques.nu. else l = 0.
   create ques.
   ques.nu = l + 1.
   ques.sid = 1 .
   ques.sub = sthem.nu .
   update ques.ques with frame fr-3 .
   update ques.answ with frame fr-3 .
   close query q5. 
   open query q5 for each sthem no-lock.
   browse b5:refresh().
   apply "value-changed" to browse b5.
end.

/* Когда смотрят вопрос */

on "return" of browse b6
do:
   ForDepCalcID = -1.
   VarSthemNu = them.nu.
   open query q7 for each sthem where sthem.them = them.nu and sthem.sid <> 0 no-lock  by sthem.ordby. 
   enable all with frame fr7.
   wait-for window-close of frame fr7 focus browse b7.
   close query q6. 
   open query q6 for each them no-lock. 
   browse b6:refresh().
   apply "value-changed" to browse b6.
end.

on "return" of browse b7
do:
    ForDepCalcID = sthem.nu .
       open query q8 for each ques where ques.sub = sthem.nu and ques.sid <> 0 no-lock .
       if VarSthemNu = 5 then do:
         display "Нажмите CTRL+H или BackSpace для вызова депозитного калькулятора" view-as text with frame fr8.
       end.
       enable all with frame fr8.
       if avail ques then 
         do:
                create statis.
                statis.dat = today .
                statis.ques = sthem.nu .

                wait-for window-close of frame fr8 focus browse b8.
                close query q7. 
                open query q7 for each sthem no-lock.
         end.
       else
         do:
           displ "В данной подтеме еще не созданы вопросы." with centered row 01 frame fr123.
         end.
       browse b7:refresh().
       apply "value-changed" to browse b7.
end.

on choose of browse b7
do:
   for each ques where ques.sub = sthem.nu and ques.sid <> 0 no-lock .
       create statis.
       statis.dat = today .
       statis.ques = sthem.nu .
   end.
end.

on "end-error" of browse b7
do:
   for each statis.
      create stat.
      buffer-copy statis to stat.
      delete statis.
   end.
end.
/* Вывод вопроса  */

on "return" of browse b8
do:
   display ques.ques with frame fr-3 .
   display ques.answ with frame fr-3 .
end.

on "go" of browse b8
do:
   ident = rowid(ques) .
   find first ques where rowid(ques) = ident exclusive-lock.
   if available(ques) then
   do:
      update ques.ques with frame fr-3 .
      update ques.answ with frame fr-3 .
   end.  
   else MESSAGE "Запись используется!" VIEW-AS ALERT-BOX WARNING BUTTONS OK Title "Ошибка".
end.

on "clear" of browse b8
do:
   ident = rowid(ques) .
   find first ques where rowid(ques) = ident exclusive-lock.
   if available(ques) then
   yesno = yes-no("Удаление вопроса", "Вы уверены?").
   if yesno then ques.sid = 0.
   else MESSAGE "Отменено пользователем!" VIEW-AS ALERT-BOX WARNING BUTTONS OK Title "Ошибка".
end.

on "end-error" of browse b8
do:
   hide frame fr-3.
end.

on "BACKSPACE" of browse b8
do:
 case ForDepCalcID :
    when 62 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/zvezda.htm ').
      end.
    when 20 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/classic.htm ').
      end.
    when 21 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/classic_vip.htm ').
      end.
    when 18 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/dallas.htm ').
      end.
    when 19 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/dallas_vip.htm ').
      end.
    when 17 then 
      do:
        unix silent value('rsh `askhost` start iexplore.exe http://www.texakabank.kz/pension.htm ').
      end.

 end.

end.

/* ----------------------- Опрос -------------------------------------------*/

on "return" of browse b9
do:
   create answ .
   answ.sid = opros.sid .
   answ.dat = today .
   if answ.sid =8 then co = 8 .
   if answ.sid = 43 then l = 3. else l = 4.
end.

/*===========================================================================*/

close query q1.
close query q2.
close query q3.
close query q4.
close query q5.
close query q6.
close query q7.
close query q8.
close query q9.
 
/*===========================================================================*/

ASSIGN CURRENT-WINDOW:MENUBAR=MENU mbar:HANDLE.

/*ON "PF3" ANYWHERE
   do:
       APPLY "CHOOSE" TO menu-item val-look.
      hide all.
   end.*/

WAIT-FOR CHOOSE OF MENU-ITEM skquit.                            /* выход */
    
/* ===================== Начало описаний процедур ========================== */

procedure add-them. /* ----------------- Добавление темы ------------------- */

    open query q1 for each them where them.sid <> 0 no-lock.
    enable all with frame fr1.
/*    apply "value-changed" to browse b1.*/
    wait-for window-close of frame fr1 focus browse b1.
/*    release them .*/

end procedure.

procedure add-sthem.            /* ----------------- Добавление подтемы ------------------ */

    open query q2 for each them where them.sid <> 0 no-lock.
    enable all with frame fr2.
    wait-for window-close of frame fr2 focus browse b2.

end procedure.

procedure fn-ques.    /* -------------------- Поиск среди вопросов -------------------- */

    update samp with frame fr-4 .
    obraz = "*" + samp + "*" .
    open query q8 for each ques where ques.ques matches obraz and ques.sid <>0 no-lock .
    enable all with frame fr8.
    wait-for window-close of frame fr8 focus browse b8.

end procedure.

procedure fn-answ. /* -------------------- Поиск среди ответов -------------------- */

    update samp with frame fr-4 .
    obraz = "*" + samp + "*" .
    open query q8 for each ques where ques.answ matches obraz and ques.sid <>0 no-lock .
    enable all with frame fr8.
    wait-for window-close of frame fr8 focus browse b8.

end procedure.

procedure fn-all. /* ------------- ОБЩИЙ Поиск среди вопросов и ответов --------------- */

    update samp with frame fr-4 .
    obraz = "*" + samp + "*" .
    open query q8 for each ques where (ques.answ matches obraz 
                or ques.ques matches obraz) and ques.sid <>0 no-lock .
    enable all with frame fr8.
    wait-for window-close of frame fr8 focus browse b8.

end procedure.

procedure look. /*-------------------- Просмотр вопроса ---------------------*/

    open query q6 for each them no-lock by them.ordby.
    enable all with frame fr6 .
    wait-for window-close of frame fr6 focus browse b6.

end procedure.

procedure add-ques.   /* ----------------- Добавление вопроса ------------------ */

    open query q4 for each them no-lock.
    enable all with frame fr4.
    wait-for window-close of frame fr4 focus browse b4.

end procedure.


function fncstat returns integer (input begdate as date,enddate as date).
    gcount = 0.
       for each stat where stat.dat >= per-s and stat.dat <= per-po no-lock :
           find last sttab where sttab.nu = stat.ques no-lock no-error.
           if avail sttab then  /* во временной таблице sttab подсчета статистики уже есть счетчик по этому вопросу */
             do:
               sttab.frq = sttab.frq + 1.
               gcount = gcount + 1.
             end. 
           else  /* во временной таблице подсчета статистики sttab еще нет пометки по этому вопросу */
             do:
                find sthem where sthem.nu = stat.ques no-lock no-error.
                if avail sthem then 
                  do:
                      create sttab.
                      sttab.frq = 1.                                                     
                      gcount = gcount + 1.

                      sttab.nu = stat.ques .
                      sttab.ques = sthem.sub .
                      sttab.dat = stat.dat .
                  end.
                else
                  do:
                    /* pause message "find last sttab where sttab.nu = stat.ques не отработал". */
                  end.
             end.
       end.
  return (gcount).

end function.
 
                  /* ----------------- Вывод статистики ------------------ */
procedure man-stat.
    per-s = g-today.
    per-po = g-today.
    update per-s per-po with frame fr-5.
    gcnt = fncstat(per-s,per-po).

    open query q3 for each sttab /*break by sttab.frq*/ no-lock.
    display gcount  label "Всего запросов за период " with frame fr3.
    enable all with frame fr3.
    wait-for window-close of frame fr3 focus browse b3.

end procedure. /* man-stat */

procedure credable. /* ------------- Кредитоспособность.xls --------------- */

     unix silent value("cpwin /data/alm/export/call/creditosposobnost.xls excel").

end procedure. /* credable */


procedure graf. /* ------------- График погашения.xls --------------- */

     unix silent value("cpwin /data/alm/export/call/grafik_pogashenya_24.xls excel").

end procedure. /* graf */



procedure getperiodm.
   currmonth = month(g-today).
   if currmonth <> 1 then do:
     prevmonth = currmonth - 1.
   end.
   else do:
     prevmonth = 12.
   end.

   nextmonth = currmonth.
   if prevmonth <> 12 then do:
     begyear = year((g-today)).
     nextyear = begyear.
   end.
   else do:
     begyear = year((g-today)) - 1.
     nextyear = begyear.
     /*nextyear = year(g-today).*/
   end.

   begday = 1.
   enddayofprevmonth = date(nextmonth,01,nextyear) - 1.
   endday = day(enddayofprevmonth).

   bdate = date (prevmonth, begday, begyear).

   edate = date (prevmonth, endday, nextyear).

end procedure. /* getperiodm */

procedure MakeQuestionslist.

declare QuestCursor cursor for
   select 
     distinct ques
   from stat where stat.dat >= bdate and stat.dat <= edate
   order by ques
for read only.

  select 
    count(*)
  into ondatecount
  from stat where  stat.dat >= bdate and stat.dat <= edate.


open  QuestCursor.
  do k = 1 to ondatecount:
    fetch QuestCursor into QuestID.
/*    message 'fetch QuestCursor iteration' string(k)  view-as alert-box. */
    find first ques where ques.nu = QuestID no-lock no-error.
    if avail ques then do:
        create QuestionsList.
        assign
          QuestionsList.hotquests = QuestID.
          QuestionsList.questnames = ques.ques.
    end.
  end.

close QuestCursor.
/*
displ bdate edate with frame fr567.
pause. 
hide frame fr567.
*/

end procedure. /* MakeQuestionslist */

procedure MakeSubThemesLst.

declare SubThemCursor cursor for
  select
    distinct ques.sub, sthem.sub 
  from stat
    left join ques on stat.ques = ques.nu
    left join sthem on ques.sub = sthem.nu
  where stat.dat >= bdate and  stat.dat <= edate
  order by ques.sub
for read only.

  select
    count(distinct ques.sub)
  into SubThemCount
  from stat
    left join ques on stat.ques = ques.nu
  where stat.dat >= bdate and  stat.dat <= edate.

open SubThemCursor.
  do m = 1 to SubThemCount:
    fetch SubThemCursor into subtID, subtName.
    /* message 'fetch SubThemCursor iteration' string(m)  view-as alert-box. */
    find first sthem where sthem.nu = subtID no-lock no-error.
    if avail sthem then do:
        create SubThemList.
        assign 
          SubThemList.hotsubthID = subtID
          SubThemList.hotsubthemname = subtName.
    end.
  end.

close SubThemCursor.

end procedure. /* MakeSubThemesLst */


procedure MakeThemesLst.

declare ThemesCursor cursor for
  select
    distinct them.num, them.them
  from comm.stat
     left join ques on stat.ques = ques.nu
     left join sthem on ques.sub = sthem.nu
     left join them on them.num = sthem.them
  where stat.dat >= bdate and  stat.dat <= edate
  order by them.num
for read only.

  select
    count(distinct them.num)
  into ThemCount
  from comm.stat
     left join ques on stat.ques = ques.nu
     left join sthem on ques.sub = sthem.nu
     left join them on them.num = sthem.them
  where stat.dat >= bdate and  stat.dat <= edate.
/*
displ bdate ThemCount edate  with frame fr666.
pause. 
hide frame fr666.
*/
open ThemesCursor.
  do m = 1 to ThemCount:
    fetch ThemesCursor into ThemID, ThemName.
    /* message 'fetch ThemCursor iteration' string(m)  view-as alert-box.  */
    find first them where them.num = ThemID no-lock no-error.
    if avail them then do:
        create ThemesList.
        assign 
          ThemesList.thID = ThemID
          ThemesList.thName = ThemName.
    end.
  end.

close ThemesCursor.

end procedure. /* MakeThemesLst */


procedure makeweeksdates.

for each weekslist.
delete weekslist.
end.

   CurrentMonth = month(bdate).
   FirstDayInMonth = true.
   LastDayInMonth = true.
   DontRepeatFirstDay = False.
   lookdate = bdate.
   repeat:

        if ((weekday(lookdate) <> 7)and(weekday(lookdate) <> 1)) then do:
           /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
           if FirstDayInMonth then 
             do:
               FirstDayInMonth = false.
               counterID = counterID + 1.
               create weekslist.
               assign
                 weekslist.id = counterID.
                 weekslist.DayOfW = lookdate.
                 weekslist.DayCode = weekday(lookdate).
               DontRepeatFirstDay = False.
             end.
           if DontRepeatFirstDay then
             do:
                 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
                 if (LastDayInMonth)and(Month(lookdate + 1) > CurrentMonth) then do:
                   LastDayInMonth = false.
                   counterID = counterID + 1.
                   create weekslist.
                   assign
                     weekslist.id = counterID.
                     weekslist.DayOfW = lookdate.
                     weekslist.DayCode = weekday(lookdate).
                 end.
             end.
           /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
           if ((weekday(lookdate) = 2)or(weekday(lookdate) = 6)) then 
                   do:
                     counterID = counterID + 1.
                     create weekslist.
                     assign
                       weekslist.id = counterID.
                       weekslist.DayOfW = lookdate.
                       weekslist.DayCode = weekday(lookdate).
                   end.

        end.
        if lookdate = edate then do:
          leave.
        end.
        else do:
         lookdate = lookdate + 1.
         DontRepeatFirstDay = true.
        end.
   end.

end procedure. /* makeweeksdates */

procedure groupweeksdays.

  for each EditWeeks.
  delete EditWeeks.
  end.

  counterID = 0.
  FirstPass = true.
  find first weekslist no-lock.
  repeat:
     if ((FirstPass) and (weekslist.DayCode = 6)) then 
       do:
           counterID = counterID + 1.
           create EditWeeks.
           assign
             EditWeeks.id = counterID
             EditWeeks.BegDay = weekslist.DayOfW
             EditWeeks.EndDay = weekslist.DayOfW.
           FirstPass = false.
       end.
     else
       do:
           counterID = counterID + 1.
           create EditWeeks.
           assign
             EditWeeks.id = counterID
             EditWeeks.BegDay = weekslist.dayOfW.
             find next weekslist no-lock no-error.
             if not avail weekslist then do:
               leave.
               message "find next weekslist не прошел!" view-as alert-box.
             end.
           assign
             EditWeeks.EndDay = weekslist.dayOfW.
       end.

    find next weekslist no-lock no-error.
    if not avail weekslist then do:
      leave.
    end.
  end.


end procedure. /* groupweeksdays */


procedure FillEmpty.
  declare SrvByMonthCursor cursor for
    select distinct sthem.nu from stat
       left join sthem on stat.ques = sthem.nu
    where stat.dat >= bdate and stat.dat <= edate
  for read only.

    select count(distinct sthem.nu) 
    into SrvTotByMonthCnt
    from stat
       left join sthem on stat.ques = sthem.nu
    where stat.dat >= bdate and stat.dat <= edate.

  Open SrvByMonthCursor.

  do jj = 1 to SrvTotByMonthCnt:
    fetch SrvByMonthCursor into SubThemID. 
  /*  message 'fetch Month-Cursor iteration' string(jj) view-as alert-box.  */
    do:
        find first sthem where sthem.nu = SubThemID no-lock no-error.
        if avail sthem then do:
            create ForXLSTable.
            assign 
              ForXLSTable.ServID = SubThemID
              ForXLSTable.ServName = sthem.sub
              ForXLSTable.CallsCount[1] = string("0")
              ForXLSTable.CallsCount[2] = string("0")
              ForXLSTable.CallsCount[3] = string("0")
              ForXLSTable.CallsCount[4] = string("0")
              ForXLSTable.CallsCount[5] = string("0").  
            MaxRecsXLSTable = MaxRecsXLSTable + 1.
        end.
    end.
  end.

 Close SrvByMonthCursor.
 /* message 'MaxRecsXLSTable = ' string(MaxRecsXLSTable) view-as alert-box. */

end procedure.  /* FillEmpty */

procedure OutInTT.

  for each ForXLSTable.
  delete ForXLSTable.
  end.

  create ForXLSTable.
    ForXLSTable.ServName = "Услуги".
    find first EditWeeks no-lock no-error.
    ForXLSTable.CallsCount[1] = "c " + string(EditWeeks.BegDay,"99.99.9999") + " по " + string(EditWeeks.EndDay,"99.99.9999").
    find next EditWeeks no-lock no-error.
    ForXLSTable.CallsCount[2] = "c " + string(EditWeeks.BegDay,"99.99.9999") + " по " + string(EditWeeks.EndDay,"99.99.9999").
    find next EditWeeks no-lock no-error.
    ForXLSTable.CallsCount[3] = "c " + string(EditWeeks.BegDay,"99.99.9999") + " по " + string(EditWeeks.EndDay,"99.99.9999").
    find next EditWeeks no-lock no-error.
    ForXLSTable.CallsCount[4] = "c " + string(EditWeeks.BegDay,"99.99.9999") + " по " + string(EditWeeks.EndDay,"99.99.9999").
    find next EditWeeks no-lock no-error.
    if avail EditWeeks then do:
      ForXLSTable.CallsCount[5] = "c " + string(EditWeeks.BegDay,"99.99.9999") + " по " + string(EditWeeks.EndDay,"99.99.9999").
    end.
    ForXLSTable.CallsCount[7] = "Итого по виду услуг".

end procedure.

procedure CalcServLst.
/* Use  MaxRecsXLSTable - Макс. количество тем в месяце */
    find first ForXLSTable exclusive-lock.
    find next ForXLSTable exclusive-lock.
    do m = 1 to 7:
      SumByCol[m] = 0.
    end.
    repeat:
       SumByRow = 0.
       find first EditWeeks no-lock no-error.
         do k = 1 to 5:
            gwBegDate = EditWeeks.BegDay.
            gwEndDate = EditWeeks.Endday.
              select count(*) 
              into SrvTotalByWeekCount
              from stat
                 left join sthem on stat.ques = sthem.nu
              where stat.dat >= gwBegDate and stat.dat <= gwEndDate
                and sthem.nu = ForXLSTable.ServID.
            SumByRow = SumByRow + SrvTotalByWeekCount.
            SumByCol[k] = SumByCol[k] + SrvTotalByWeekCount.
            update
              ForXLSTable.CallsCount[k] = string(SrvTotalByWeekCount).
            find next EditWeeks no-lock no-error.
            if not avail EditWeeks then do:
              leave.
            end.
        end.
      update
        ForXLSTable.CallsCount[7] = string(SumByRow).
      find next ForXLSTable exclusive-lock.
      if not avail ForXLSTable then do:
        leave.
      end.
    end.

/*-----------------*/
            create ForXLSTable.  
            assign 
              ForXLSTable.ServID = 99999
              ForXLSTable.ServName = "Итого за неделю"
              ForXLSTable.CallsCount[1] = string(SumByCol[1])
              ForXLSTable.CallsCount[2] = string(SumByCol[2])
              ForXLSTable.CallsCount[3] = string(SumByCol[3])
              ForXLSTable.CallsCount[4] = string(SumByCol[4])
              ForXLSTable.CallsCount[5] = string(SumByCol[5]).  
/*-----------------*/

end procedure. /* CalcServLst */



procedure ShowWeeks.
 
 def output parameter bool as logical.

    def query qEditWeeks for EditWeeks scrolling.

    def browse brEditWeeks
        query qEditWeeks     
        display
          EditWeeks.id
          EditWeeks.BegDay
          EditWeeks.EndDay
          enable EditWeeks.BegDay help "Для перемещения по столбцам используйте CTRL+G CTRL+U" EditWeeks.EndDay
        with 6 down width 46 no-row-markers title "Недели ушедшего месяца" overlay. 
        
    def button keyOk label "Ok".
        
    def frame frEditWeeks
        brEditWeeks
        skip(0)  
        space(14) keyOk 
        with centered.
           
    on END-ERROR of browse brEditWeeks
      do:
        bool = false.
        close query qEditWeeks.
        hide frame frEditWeeks.
      end.
         
    on choose of keyOk
      do:
        bool = true.
        close query qEditWeeks.
        hide frame frEditWeeks.
      end.

 /*------------------------------------*/
    open query qEditWeeks for each EditWeeks by id.

    enable all with frame frEditWeeks overlay top-only. 

    wait-for window-close of frame frEditWeeks or choose of keyOk focus browse brEditWeeks.

    hide frame frEditWeeks. 
    close query qEditWeeks. 
 
end procedure. /* ShowWeeks */


procedure dowork.

 def var bool as logical.

 run getperiodm. /* на выходе получили период с bdate по edate. */
/* run MakeQuestionslist. / * получили список горячих вопросов за период */
/* run MakeSubThemesLst. / * получили список горячих подтем за период */
/* run MakeThemesLst. /  * получили список горячих тем за период */
 counterID = 0.
 run makeweeksdates.
 run groupweeksdays.
 run ShowWeeks(output bool). 
 if bool then do: 
 hide all.
 
 display "Ждите..." with frame MyWaitFr COLUMN 39 ROW 14.
   
 run OutInTT. 
 run FillEmpty.
 run CalcServLst.

 hide frame MyWaitFr no-pause.

 output stream StatToExcel to srvs.txt. 
 output to cbyweeks.html.
 {html-title.i}

 put unformatted "<table border=1 cellspacing=0>" skip.

        find first ForXLSTable no-lock.
        repeat:
           put unformatted "<tr>".
           put unformatted "<td>" ForXLSTable.ServName "</td>".
           do k = 1 to 5: 
                 put unformatted "   " "<td>"  ForXLSTable.CallsCount[k] "</td>" skip.
           end.  
           put unformatted "         " "<td>"  ForXLSTable.CallsCount[7] "</td>" skip.
              put unformatted "</tr>" skip.
           find next ForXLSTable no-lock no-error.
           if not avail ForXLSTable then do:
             leave.
           end.
        end.
 put unformatted skip "</table>" skip.
 {html-end.i}
 output close.
 output to terminal.

 for each ForXLSTable no-lock:
   put stream StatToExcel ServName AT 3 format "x(38)" 
   ForXLSTable.CallsCount[1] format "x(26)" AT 44  
   ForXLSTable.CallsCount[2] format "x(26)" AT 78  
   ForXLSTable.CallsCount[3] format "x(26)" AT 110 
   ForXLSTable.CallsCount[4] format "x(26)" AT 140
   ForXLSTable.CallsCount[5] format "x(26)" AT 180 

   ForXLSTable.CallsCount[7] format "x(26)" AT 230 
   skip .
 end.

 output stream StatToExcel close.
 unix silent value ('cptwin cbyweeks.html excel').
 end.
 else hide all.

end procedure. /* dowork */



procedure man-jour.
end procedure.

procedure vallook. /* ----------------- Посмотрим валюту! ------------------ */
 for each crc no-lock :
     displ crc.crc label "N"
       crc.des label "Валюта"
           crc.code label "Код"
           crc.rate[1] format ">,>>>,>>>,>>9.99" label "Курс НБРК" 
           crc.rate[2] format ">,>>>,>>>,>>9.99" label "Покупка"
           crc.rate[3] format ">,>>>,>>>,>>9.99" label "Продажа"
           with overlay centered row 22.
 end.
end procedure.

procedure phone. /* ----------------- Посмотрим телефоны ------------------ */
 unix silent ie http://portal/phones/phones.htm .  
end procedure.

procedure tarif-ur. /* ------------------------- Тарифы ----------------------- */
 unix silent ie http://portal/tariff/tariff_almaty_ur.htm .  
end procedure.

procedure tarif-fis. /* ------------------------- Тарифы ----------------------- */
 unix silent ie http://portal/tariff/tariff_almaty_fiz.htm .
end procedure.

procedure rek. /* ------------------------- Реквизиты ----------------------- */
 unix silent ie http://portal/req/req.htm .
end procedure.

procedure doc-cred. /* --------- Перечень документов для оформления кредита ----------- */

def var v-sel as char.

 run sel2 ("Выбор :", " 1. Ипотечное кредитование | 2. Кредит под залог недвижимости | 3. Автокредит ", output v-sel).
 
 case v-sel:
    /* Ипотека */
    when "1" then do: 
          unix silent value("cpwin /data/alm/export/call/ipoteka.doc winword").
    end.
    /* Кредит под недвижимость */
    when "2" then do: 
          unix silent value("cpwin /data/alm/export/call/zalognedvij.doc winword").
    end.
    /* Автокредит */
    when "3" then do: 
           unix silent value("cpwin /data/alm/export/call/autocredit.doc winword").
    end.
 end.

end procedure.

procedure doc-credur. /* --------- Перечень документов для оформления кредита ----------- */


def var v-sel as char.

 run sel2 ("Выбор :", " 1.Фил. и предст. юр.лиц-нерезидентов РК | 2.Фил. и предст. юр.лиц-резиденты РК | 3.Индивидуальные предприниматели | 4.Юридические лица - нерезиденты  РК | 5.Юридические лица - резиденты РК | 6.Посольства ", output v-sel).
 
 case v-sel:
    when "1" then do: 
          unix silent value("cpwin /data/alm/export/call/fil_nerez.doc winword").
    end.
    when "2" then do: 
          unix silent value("cpwin /data/alm/export/call/fil_rez.doc winword").
    end.
    when "3" then do: 
           unix silent value("cpwin /data/alm/export/call/indiv_predpr.doc winword").
    end.
    when "4" then do: 
           unix silent value("cpwin /data/alm/export/call/nerez.doc winword").
    end.
    when "5" then do: 
           unix silent value("cpwin /data/alm/export/call/rez.doc winword").
    end.
    when "6" then do: 
           unix silent value("cpwin /data/alm/export/call/posol.doc winword").
    end.
 end.

end procedure.

procedure out-data. /* --------- Вывод опросных данных ----------- */
for each opros where opros.sts = 'r' no-lock.
    i = 0.
    for each answ where answ.sid = opros.sid no-lock.
      i = i + 1.
    end.  
    create opr.
    opr.ques = opros.ques.
    opr.nu = i.
end.

    open query q10 for each opr where opr.nu <> 0 no-lock.
    enable all with frame fr10.
    wait-for window-close of frame fr10 focus browse b10.

    for each opr . delete opr . end .
end procedure.

procedure cr-file. /* Формирование (и передача в Word) файла новых вопросов, к которым еще нет ответов */
  output to ques.img .
  for each nques .
     put "Вопрос номер:" nques.nu skip(1)
          nques.ques format "x(800)"
          skip(3).
     delete nques.
  end.
  output close.
  unix silent cptwo "ques.img" .
  unix silent rm -f value("ques.img") .
end procedure.

procedure new-ques. /* --------------------- Ввод нового вопроса без ответа --------------------- */
   find last nques no-lock no-error.
   if avail nques then l = nques.nu. else l = 0.
   create nques .
   nques.nu = l + 1.

   update nques.ques with frame fr-7.
   hide frame fr-7.
end procedure.

procedure opr. /* --------------------- Проведение опроса --------------------- */

   do i = 1 to 2 .
      find opros where opros.sid = i and opros.sts = 'r' no-lock .
      display opros.ques with frame fr-8.
      opnu = opros.sid .

      open query q9 for each opros where opros.nu = opnu and opros.sts = 'r' no-lock.
      enable all with frame fr9.
      wait-for "return" of frame fr9 focus browse b9.
      close query q9.
   end .

   if co = 8 then

   do i = l to 5 .
      find opros where opros.sid = i and opros.sts = 'r' no-lock .
      opnu = opros.sid .
      display opros.ques with frame fr-8.

      open query q9 for each opros where opros.nu = opnu and opros.sts = 'r' no-lock.
      enable all with frame fr9.
      wait-for "return" of frame fr9 focus browse b9.
      close query q9.
   end.
   l = 0. i = 0. co = 0. opnu = 0.
end procedure.

procedure man-expexc. /* -------------- Экспорт вопросов в EXCEL ---------------------- */
    output to call_center.html.
    {html-title.i}
    for each them where them.sid <> 0 no-lock .
        put unformatted "<font size=""6""><b><a href=""\#" them.nu """>" them.them "</a></b></font><br>" skip.
    end.
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.
    for each them where them.sid <> 0 no-lock .
        put unformatted "<tr><td colspan=2><font size=""6""><b><a name=""" them.nu """></a>" them.them "</b></font></td></tr>" skip.
        for each sthem where sthem.them = them.nu and sthem.sid <> 0 no-lock .
            put unformatted "<TR style=""font:bold;font-size:12pt"">" skip
                            "<TD colspan=2>" sthem.sub "</TD></TR>" skip.
            for each ques where ques.sub = sthem.nu and ques.sid <> 0 no-lock.
                put unformatted "<TR style=""font-size:10pt"">" skip
                                "<TD>" ques.ques "</TD>" skip
                                "<TD>" ques.answ "</TD>" skip.
            end.
        end.
    end.
    put unformatted "</table>" .
    {html-end.i}
    output close.
    unix silent cptwin call_center.html iexplore.
/*    unix silent cptwin value(v-file) excel.*/
end procedure.



/*** ============================================================================================***/

                 /* ---------------=== Table stat ===--------------- */

/*  select  sid label 'sid',nu label 'nu',dat label 'dat',ques label 'ques' from stat  */

/*  select  max(sid) from stat  = 0 */

/*  select  max(nu) from stat   = 0 */

/*  select  max(ques) from stat = 499  */

/* select  max(dat) from stat = 28/07/04 */

/*
find first them where them.them matches "*Обменные операц*" exclusive-lock.
update them.ordby

*/

/*===================================== End table stat =============================================*/


                 /* ---------------=== Table sthem ===--------------- */

/*  select sub,sid,them,nu from sthem       */

/*  sthem.sub - наименования подтем         */

/*  select distinct sid from sthem = {0,1}  */

/*  select max(them) from sthem    =   16   */

/*  select max(nu) from sthem      =   63   */


/*  select distinct nu from opros */ /* 6 тем */


/* select sub label 'sub',sid label 'sid',them label 'them',nu label 'nu' from sthem */

/*==================================== End table sthem =========================================*/


                 /* ---------------=== Table ques ===--------------- */

/* select sub label 'sub',sid label 'sid',ques label 'ques',answ label 'answ',nu label 'nu' from ques */

/* select max(nu) from ques   = 566        */

/* select max(sub) from ques  =  63        */

/* select max(sid) from ques  =   2  {0,1} */

/*==================================== End table ques =========================================*/


                 /* ---------------=== Table them ===--------------- */

/*   select sid label 'sid',them label 'them',num label 'num'  from them  */

/*   select distinct sid   from them  = {1} */

/*  select distinct num  from them order by num = {1..16} */

/*  select max(num)  from them = 16 */

/*==================================== End table them =========================================*/

/*---------------------------------------------------------------------
      Количество звонков по подтемам за период
      --------------------------------------
 select sthem.sub format "x(60)",count(*) from stat
    left join sthem on stat.ques = sthem.nu
 where stat.dat >= 06/01/04 and stat.dat <= 06/01/04
 group by sthem.nu

   display "Нажмите  для вызова депозитного калькулятора " view-as text with frame fr7.

---------------------------------------------------------------------*/
