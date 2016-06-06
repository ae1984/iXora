/* import.p
 * MODULE
        Коммунальные платежи 
 * DESCRIPTION
        Импортирование и зачисление коммунальных и налоговых платежей
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
	3.2.10.15.5 Импорт и зачисление платежей        
 * AUTHOR
        27/10/2003 kanat
 * CHANGES
        13/11/2003 kanat - изменил копирование логов по импортам файлов кассиров
        21/11/2003 sasco - вставил проверку на Алматы при импорте БД
        12/12/2003 kanat - добавил новую шаренную переменную v-kofc и вызов процедуры com-prcd (печать единого приходного ордера)
                           осуществляется только для сотрудников департамента координации деятельности СПФ. 
        13/12/2003 kanat - Общий приходный ордер печатается только в Алматы
        16/02/2004 kanat - Убрал проверку для филиалов по копированию БД и новых исходных процедур, 
        20/02/2004 kanat - Добавил возможность прекращения операции по желанию пользователя
        23/04/2004 kanat - Добавил возможность зачисления погашений недостач кассиров
        07/05/2004 sasco - Сделал обнуление v-kofc в начале каждого цикла прогрузки Flash
        27/05/2004 kanat - Добавил и удалил очистку всех текстовых файлов на флэш - дисках кассиров.
        15/07/2004 kanat - Добавил зачисление комиссий на счет доходов ГК за дубликаты квитанций
        22/07/2004 kanat - Дубликаты квитанций хранятся и импортируются с отдельного файла
        18/10/2004 kanat - Дубликаты ... с отдельного и файла вместе с архивной историей для руководства 
        28/10/2004 kanat - Добавил очистку всех текстовых файлов на флэш - дисках кассиров - по средам и пятницам, кроме обменнвх операций
        01/11/2004 kanat - И выдач в подотчет ...
        22/12/2004 kanat - Сменил даты очистки файлов на среду и четверг по просьбе ДРР
        18/01/2004 sasco - Добавил зачисление социальных платежей
        23/02/2005 kanat - Добавил удаление соц. отчислений, обменных операций, недостач, выдач в подотчет.
        29/04/2005 kanat - Добавил обработку выдач наличных через POS - terminal
        27/05/2005 kanat - Добавил зачисление выдач наличных через POS - terminal
        14/09/2005 kanat - Добавил дополнительную очистку файлов POS
        15/09/2005 kanat - Поменял местами очистку и копирование файлов
        26/01/2006 marinav - загрузка POS платежей и для Алматы тоже
*/

{global.i}
{msg-box.i}
{comm-txb.i}

def var v-choice as log init true.
def var v-symbol as char.
def var v-handler as char.
def var v-choice-yes as char.
def var pathname as char.

def var seltxb as int.
def var v-state as logical.

def new shared var v-kofc as char.

def new shared var v-pen-jh as integer.
def new shared var v-atv-jh as integer.

def var del-choice as logical init false.

def var v-date as date.

seltxb = comm-cod ().

   run sel ("Выберите тип носителяљ", "1. Дискета      |" +
                                      "2. Flash        |" + 
                                      "3. Выход         ").

   find first sysc where sysc.sysc = "flastp" no-lock no-error.
   if avail sysc then 
   v-symbol = sysc.chval.
   else
   message "Конфигурация для Flash диска отсутствует" view-as alert-box title "Ошибка".

       case return-value:
          when "1" then v-handler = "A:\\".
          when "2" then v-handler = v-symbol + ":\\".
          when "3" then return.
       end.

update v-date label "Введите дату платежей:" format '99/99/99' skip
with side-label row 5 centered frame dataa .

do while v-choice:

         v-choice = false.
         v-kofc = "".

   run SHOW-MSG-BOX ("Загрузка и зачисление налоговых платежей").
   run taxsofp(v-date,v-handler).
   run HIDE-MSG-BOX.	

   run SHOW-MSG-BOX ("Загрузка и зачисление коммунальных платежей").
   run stadsofp(v-date,v-handler).
   run HIDE-MSG-BOX.

   run SHOW-MSG-BOX ("Загрузка и зачисление пенсионных платежей").
   run pensofp(v-date,v-handler).
   run HIDE-MSG-BOX.

   run SHOW-MSG-BOX ("Загрузка и зачисление платежей АЛМА TV").
   run atvsofp(v-date,v-handler).	
   run HIDE-MSG-BOX.

   run SHOW-MSG-BOX ("Загрузка и зачисление недостач кассиров").
   run nedsofp(v-date,v-handler).	
   run HIDE-MSG-BOX.

   run SHOW-MSG-BOX ("Зачисление комиссий за выдачу дубликатов").
   run dubsofp(v-date,v-handler).	
   run HIDE-MSG-BOX.

   run SHOW-MSG-BOX ("Зачисление социальных отчислений").
   run pmpsofp(v-date,v-handler).	
   run HIDE-MSG-BOX.

/*   if seltxb <> 0 then do:*/
   run SHOW-MSG-BOX ("Зачисление выдач наличных через POS").
   run possofp(v-date,v-handler).	
   run HIDE-MSG-BOX.
/*   end.*/


   if seltxb = 0 then
   run com-prcd(v-date, v-kofc, "ALL").

   if v-handler <> "A:\\" then do:
/*
   if seltxb = 0 then do:
*/

      if weekday(today) = 4 or weekday(today) = 5 then do:
      run SHOW-MSG-BOX ("Очистка загруженных текстовых файлов").
      MESSAGE "Произвести очистку файлов?"
              VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
              TITLE "Внимание" UPDATE del-choice.
      if del-choice then do:
      pathname = v-handler.
      pathname = caps(trim(pathname)).
      pathname = replace ( pathname , '/', '\\' ).
      unix silent value("rsh `askhost` del " + pathname + "com*.txt").
      unix silent value("rsh `askhost` del " + pathname + "tax*.txt").
      unix silent value("rsh `askhost` del " + pathname + "dub*.txt").
      unix silent value("rsh `askhost` del " + pathname + "pen*.txt").
      unix silent value("rsh `askhost` del " + pathname + "ned*.txt").
      unix silent value("rsh `askhost` del " + pathname + "atv*.txt").
      unix silent value("rsh `askhost` del " + pathname + "ned*.txt").
      unix silent value("rsh `askhost` del " + pathname + "pmp*.txt").
      unix silent value("rsh `askhost` del " + pathname + "pos*.txt").
      unix silent value("rsh `askhost` del " + pathname + "*.log").
      end.
      run HIDE-MSG-BOX.
      end.

      run SHOW-MSG-BOX ("Копирование БД и процедур").
      pathname = v-handler.
      pathname = caps(trim(pathname)).
      pathname = replace ( pathname , '/', '\\' ).
      unix silent value("rcp " + trim(OS-GETENV("DBDIR")) + "/export/offpl/*.*" + "  `askhost`:" + pathname).
      unix silent value("rcp " + trim(OS-GETENV("DBDIR")) + "/export/offpl/bf*" + "  `askhost`:" + pathname).
      unix silent value("rcp " + trim(OS-GETENV("DBDIR")) + "/export/offpl/bj*" + "  `askhost`:" + pathname).
      unix silent value("rcp `askhost`:" + pathname + "*.log " + trim(OS-GETENV("DBDIR")) + "/import/offpl/log").
      run HIDE-MSG-BOX.

/*
   end.
*/
   end. 

        MESSAGE "Загрузка завершена. Вставьте следующую flash - карту или дискету."
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Импорт и зачисление Offline платежей PragmaTX" UPDATE v-choice.
end.


