/* showScrc.p
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

/*
    09.06.2000
    show-crc.p
    Справка по курсам валют за период...
    а также по курсам покупки-продажи за период ...
    Подлипалина Е.Ф.

    06/02/2002 sasco:  настройка принтера из OFC. 
                       курсы валют - средневзвешенные! ! ! 
                                      почти бешеные! ! ! !
*/

{global.i}
def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999".
def var vakod as int.
def var val_name as char.

find last cls no-lock no-error.
g-today = if available cls then cls.cls + 1 else today.
dat1 = today.
dat2 = today.
    unix silent rm -f value("valut.txt"). 
    update dat1 label ' Укажите дату начала периода' format '99/99/9999'
    dat2 label ' Укажите дату конца периода ' format '99/99/9999' skip
    with side-label row 5 centered frame datokn.
if dat1 = dat2 then do:
     output to valut1.txt.
       /*hide frame datokn.*/
       /*message 'ха - ха'.*/
     display 
       skip(1) 'Валюта        Курс  Установлен Наименование                  '
       skip(1) with side-label centered frame headers title '[ Курсы валют на ' + string( dat1, '99/99/9999' ) + ' г, ' + string( time,'hh:mm:ss' ) + ' ]'.
     def new shared var t9 as char format "x(1)".
     for each crc no-lock:
       find last crchis where crc.crc = crchis.crc and crchis.rdt <= dat1 no-lock no-error.
       display
         crchis.crc     no-label
         crc.code       no-label
         crchis.rate[1] no-label
         crchis.rdt     no-label
         crc.des        no-label with centered.
     end.

     /* прогонка принтера, чтобы бумагу не выкручивать вручную */
     find first ofc where ofc.ofc = userid('bank').
     if ofc.mday[2] = 1 then put skip(14).
                        else put skip(1).

     output close.
     pause 0 before-hide.
     run menu-prt('valut1.txt').
     displ 'А теперь курсы покупки-продажи' with centered row 01 frame bbb.
     if dat1 = g-today then run pechcrc.
     else do:
            output to rpt.img.
            for each crchs:
            find crc where crc.crc = crchs.crc no-lock no-error.
            if not available crc then delete crchs.
            end.

            display dat1 label "Дата : " with side-labels .
            for each crc where crc.sts <> 9 no-lock:
               find crchs where crchs.crc = crc.crc no-lock no-error.
               t9 = crchs.Hs.
               find last crchis where crc.crc = crchis.crc and
                                       crchis.rdt <= dat1 no-lock no-error.
               display crc.crc label 'Вал'
               crc.des label " Наименование валюты " format "x(25)"
               crchis.rate[1] label "Курс тенге"
               crchis.rate[2] label "Покупка нал"
               crchis.rate[3] label "Продажа нал"
               crchis.rate[4] label "Покупка безнал"
               crchis.rate[5] label "Продажа безнал"
               crchis.rate[9] label "Размерн" format "z,zzz,zz9"
               t9 label "Тв./М"
               with title " КУРСЫ  ВАЛЮТ " width 132.
            end.

            find first ofc where ofc.ofc = userid('bank').
            if ofc.mday[2] = 1 then put skip(14).
                               else put skip(1).
            output close. 
          end.
     run menu-prt('rpt.img').
     pause before-hide.
     hide frame bbb.
end.
else do:
    run menuScrc(dat1,dat2).
end.

