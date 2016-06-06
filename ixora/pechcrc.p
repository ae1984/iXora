/* pechcrc.p
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

/* 06/02/2002 / sasco / настройка принтера из OFC
    курсы - средневзвешенные! ! ! ! !
*/

/*define shared frame crc. */
define shared var t9 as char.
define shared var g-today as date.
output to rpt.img.
for each crchs:
find crc where crc.crc = crchs.crc no-lock no-error.
if not available crc then delete crchs.
end.
display g-today  label "Дата : " with side-labels .
for each crc where crc.sts <> 9:
find crchs where crchs.crc = crc.crc no-lock no-error.
t9 = crchs.Hs.
display crc.crc label 'Вал'
crc.des label " Наименование валюты " format "x(25)"
crc.rate[1] label "Курс тенге"
crc.rate[2] label "Покупка нал"
crc.rate[3] label "Продажа нал"
crc.rate[4] label "Покупка безнал"
crc.rate[5] label "Продажа безнал"
crc.rate[9] label "Размерн" format "z,zzz,zz9"
t9 label "Тв./М"
 with title " КУРСЫ  ВАЛЮТ " width 132.
end.
/* прогонка принтера, чтобы бумагу не выкручивать вручную */
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
                   else put skip(1).
output close. 

