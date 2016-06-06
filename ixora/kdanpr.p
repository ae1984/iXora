/* kdanpr.p
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
*/

/* kdanpr.p  Электронное кредитное досье
    Анализ проекта заемщика

  25.07.03 marinav
  30/04/2004 madiar - Просмотр досье филиалов в ГБ.
  19/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
  20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
                      Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var vs-info as char extent 3.


define frame fr skip(1) "                              ОПИСАНИЕ ПРОЕКТА" skip(1)
       vs-info[1]  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " АНАЛИЗ ПРОЕКТА " .

define frame fr2 skip(1) "                          ОПЫТ В ПОДОБНЫХ ПРОЕКТАХ" skip(1)
       vs-info[2]  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕН " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " АНАЛИЗ ПРОЕКТА " .

define frame fr3 skip(1) "                           ВОЗМОЖНОСТЬ РЕАЛИЗАЦИИ" skip(1)
       vs-info[3]  no-label  VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕН " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " АНАЛИЗ ПРОЕКТА " .


define var v-sel as char.

  run sel ("Выбор :", 
           " 1. Описание проекта | 2. Опыт в подобных проектах | 3. Возможность реализации проекта | 4. Выход ").
  v-sel = return-value.
  case v-sel:
    when "1" then do:
          find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and 
                                   kdaffil.code = '05' and (kdaffil.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
          if not avail kdaffil then do:
            if kdlon.bank = s-ourbank then do:
                create kdaffil. 
                kdaffil.bank = s-ourbank. kdaffil.code = '05'. kdaffil.kdlon = s-kdlon. 
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
                find current kdaffil no-lock no-error.
            end.
            else do:
              message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
              bell. undo, retry.
            end.
          end.
          vs-info[1] = kdaffil.info[1].
          if kdlon.bank = s-ourbank then do:
            message 'F1 - Сохранить,   F4 - Выход без сохранения'.
            displ vs-info[1] kdaffil.whn kdaffil.who with frame fr.
            update vs-info[1] with frame fr.
            find current kdaffil exclusive-lock no-error.
            kdaffil.info[1] = vs-info[1].
            find current kdaffil no-lock no-error.
          end.
          else do:
            displ vs-info[1] kdaffil.whn kdaffil.who with frame fr.
            pause.
          end.
    end.
    when "2" then do:
          find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and 
                                   kdaffil.code = '05' and  (kdaffil.bank = s-ourbank or s-ourbank = "TXB00")  no-lock no-error.
          if not avail kdaffil then do:
            if kdlon.bank = s-ourbank then do:
                create kdaffil. 
                kdaffil.bank = s-ourbank. kdaffil.code = '05'. kdaffil.kdlon = s-kdlon. 
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
                find current kdaffil no-lock no-error.
            end.
            else do:
              message skip "Запрашиваемые данные не были введены" skip(1) view-as alert-box buttons ok title " Нет данных! ".
              bell. undo, retry.
            end.
          end.
          vs-info[2] = kdaffil.info[2].
          if kdlon.bank = s-ourbank then do:
            message 'F1 - Сохранить,   F4 - Выход без сохранения'.
            displ vs-info[2] kdaffil.whn kdaffil.who with frame fr2.
            update vs-info[2] with frame fr2.
            find current kdaffil exclusive-lock no-error.
            kdaffil.info[2] = vs-info[2].
            find current kdaffil no-lock no-error.
          end.
          else do:
            displ vs-info[2] kdaffil.whn kdaffil.who with frame fr2.
            pause.
          end.
    end.
    when "3" then do:
          find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and  
                                   kdaffil.code = '05' and (kdaffil.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
          if not avail kdaffil then do:
             if kdlon.bank = s-ourbank then do:
                create kdaffil. 
                kdaffil.bank = s-ourbank. kdaffil.code = '05'. kdaffil.kdlon = s-kdlon. 
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
                find current kdaffil no-lock no-error.
             end.
            else do:
              message skip "Запрашиваемые данные не были введены" skip(1) view-as alert-box buttons ok title " Нет данных! ".
              bell. undo, retry.
            end.
          end.
          vs-info[3] = kdaffil.info[3].
          if kdlon.bank = s-ourbank then do:
            message 'F1 - Сохранить,   F4 - Выход без сохранения'.
            displ vs-info[3] kdaffil.whn kdaffil.who with frame fr3.
            update vs-info[3] with frame fr3.
            find current kdaffil exclusive-lock no-error.
            kdaffil.info[3] = vs-info[3].
            find current kdaffil no-lock no-error.
          end.
          else do:
            displ vs-info[3] kdaffil.whn kdaffil.who with frame fr3.
            pause.
          end.
    end.
    when "4" then return.
  end case.


