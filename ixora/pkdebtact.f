/* pkdebtact.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Работа с задолжниками
        Форма "Работа с задолжником"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-3-7 
 * AUTHOR
        
 * CHANGES
        24/02/06 Natalya D. - удалила отображение "ВЕС" и заминила "ПРИМЕЧАНИЕ" на "ПРИЧИНА".
                              Причина отображается в виде метки "*", но при переходе на нее
                              открывается фрейм с возможностью использования справочника.
   
*/
form
    pkdebtdat.rdt format "99/99/99" label "ДАТА ДЕЙСТВ"
    v-tim format "x(6)" label "ВРЕМЯ"
    pkdebtdat.rwho format "x(8)" label "КТО ДЕЙСТВ"
    pkdebtdat.action format "x(12)"
        help "F2 - Выбрать только 1 действие с задолжником"
        validate (can-find(bookcod where bookcod.bookcod = "pkdbtact" and bookcod.code = pkdebtdat.action)
                  and pkdebtdat.action <> "" ,
                  "НЕПРАВИЛЬНОЕ ДЕЙСТВИЕ (сверьтесь со справочником)")
    pkdebtdat.result format "x(12)"
        help "F2 - Выбрать результат действий с задолжником"
        validate (can-find(bookcod where bookcod.bookcod = "pkdbtres" and bookcod.code = pkdebtdat.result)
                  and pkdebtdat.result <> "" ,
                  "НЕПРАВИЛЬНЫЙ РЕЗУЛЬТАТ (сверьтесь со справочником)")
    pkdebtdat.checkdt format "99/99/99" label "ДАТА КОНТР"
        help "Введите дату контроля"

    /*pkdebtdat.info[2] format "x(3)" label "ВЕС"*/
    pkdebtdat.info[3] format "x(1)" label "ПРИЧИНА"        
    with row 5 overlay centered scroll 5 down title " РАБОТА С ЗАДОЛЖНИКОМ " frame f-dat.

form 
   pkdebtdat.info[1] label "ПРИЧИНА"  VIEW-AS EDITOR SIZE 60 BY 3 
      help "F1- СОХРАНИТЬ ПРИЧИНУ F2- СПРАВОЧНИК F4- ВЫЙТИ НЕСОХРАНЯЯ"      
   with frame f-infos overlay  row 8 width 65 centered top-only side-label.
