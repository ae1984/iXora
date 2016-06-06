/* pushofc.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Отсылка сформированного PUSH-отчета получателям
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        28/03/05 sasco
 * CHANGES
        25/07/05 sasco Исправил процедуру копирования на сервер
        15/09/06 marinav - в текст письма добавляется название филиала
*/


def shared var g-ofc as char.
def shared var g-today as date.

{push.i}

def var retval as char.
def var rcp_fname as char.

find first cmp no-lock no-error.

/* просматриваем всех заказчиков */
for each pushord where pushord.id = vid no-lock:

    /* ищем настройку отчета */
    find pushrep where pushrep.id = vid no-lock no-error.
    if not avail pushrep then do:
       run savelog ("pushrep", "Не найдена настройка отчета с ID = " + string(pushord.id)).
       next.
    end.

    /* ищем настройку заказчика */
    find pushofc where pushofc.ofc = pushord.ofc no-lock no-error.
    if not avail pushofc then do:
       run savelog ("pushrep", "Не найдена настройка получателя " + pushord.ofc).
       next.
    end.

    /* найдем отчет в списке готовых */
    find last pushrun where pushrun.id = vid and
                            pushrun.d = vdate and
                            pushrun.m = vmont and
                            pushrun.q = vquar and
                            pushrun.y = vyear
                            no-lock no-error.
    if not avail pushrun then do:
       run savelog ("pushrep", "Не найден готовый отчет с ID= " + string(pushord.id) + 
                               " d= " + string (vdate) + " m= " + string (vmont) + 
                               " q= " + string (vquar) + " y= " + string (vyear)).
       next.
    end.

    if SEARCH (pushrun.fname) = ? then do:
       run savelog ("pushrep", "Не найден файл " + pushrun.fname + " для отчета ID = " + string(pushord.id)).
       next.
    end.


    case pushord.oper:

         /* отправка по e-mail */
         when "e" then do:
                           if pushofc.email = "" then do:
                              run savelog ("pushrep", "Не найдена настройка E-MAIL получателя " + pushord.ofc).
                              next.
                           end.

                           unix silent value ("cp " + pushrun.fname + " rep_rcp.html").
                           unix silent value ("un-win rep_rcp.html rep.html").
                           run mail(pushofc.email, "REPORTER", "Report", pushrep.des + " " + cmp.name  , "", "", "rep.html").  

                           run savelog ("pushrep", "Успешная отправка на EMAIL файла " + pushrun.fname + 
                                                   " для " + pushofc.ofc + " на адрес " + pushofc.email +
                                                   " для отчета ID = " + string(pushord.id)).

                           unix silent value ("rm rep_rcp.html").
                           unix silent value ("rm rep.html").
                      end.

         /* отправка по e-mail */
         when "d" then do:
                           if pushofc.host = "" then do:
                              run savelog ("pushrep", "Не найдена настройка HOST для RCP получателя " + pushord.ofc).
                              next.
                           end.
                           if pushofc.path = "" then do:
                              run savelog ("pushrep", "Не найдена настройка PATH для RCP получателя " + pushord.ofc).
                              next.
                           end.

                           rcp_fname = entry (num-entries (pushrun.fname, "/"), pushrun.fname, "/").

                           unix silent value ("cp " + pushrun.fname + " rep_rcp.html"). 
                           unix silent value ("un-win rep_rcp.html rep.html").
                           unix silent value ("rm rep_rcp.html").
                           unix silent value ("mv rep.html " + rcp_fname).
                           
                           input through value ("rcp " + rcp_fname + " " + pushofc.host + ":" + pushofc.path + " 2> /dev/null; echo $?").
                                 import retval.
                                 input close.

                           unix silent value ("rm " + rcp_fname).

                           if retval <> "0" then run savelog ("pushrep", "Ошибка копирования RCP файла " + pushrun.fname + 
                                                                         " на ХОСТ " + pushofc.host + " директория " + pushofc.path +
                                                                         " для отчета ID = " + string(pushord.id)).
                           else run savelog ("pushrep", "Успешное копирование RCP файла " + pushrun.fname + 
                                                        " для " + pushofc.ofc + " на ХОСТ " + pushofc.host + " директория " + pushofc.path +
                                                        " для отчета ID = " + string(pushord.id)).

                      end.
    end case.

end. /* each pushord */


