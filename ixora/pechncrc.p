/* pechncrc.p
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
 * BASES
        BANK COMM       
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* 06/02/2002 / sasco / настройка принтера из OFC 
    курсы - по НацБанку ! ! ! !
   19.03.2008 galina - удален вывод поля "Тв./М"
                       удален вывод поля "Размерн"   
*/

/*define shared frame ncrc. 
define shared var t9 as char.*/
define shared var g-today as date.
output to rpt.img.
/*for each ncrchs:
find ncrc where ncrc.crc = ncrchs.crc no-lock no-error.
if not available ncrc then delete ncrchs.
end.*/
display g-today  label "Дата : " with side-labels .
for each ncrc where ncrc.sts <> 9:
/*find ncrchs where ncrchs.crc = ncrc.crc no-lock no-error.
t9 = ncrchs.Hs.*/
display ncrc.crc label 'Вал'
ncrc.des label " Наименование валюты " format "x(25)"
ncrc.rate[1] label "Курс тенге"
ncrc.rate[2] label "Покупка нал"
ncrc.rate[3] label "Продажа нал"
ncrc.rate[4] label "Покупка безнал"
ncrc.rate[5] label "Продажа безнал"
/*ncrc.rate[9] label "Размерн" format "z,zzz,zz9"
t9 label "Тв./М"*/
 with title " КУРСЫ  ВАЛЮТ  (НАЦ.БАНК)" width 132.
end.

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
                   else put skip(1).
output close. 

