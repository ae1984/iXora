﻿/* mujsc.f
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

def var v-qqqq as char initial ', ' format "x(2)".
def var fff as char initial ' ' format "x".
put stream m-doc

/*fill("-",130) format "x(130)" skip(1)*/

"   Кредитное учреждение   " at 16 skip
"Итоговое платежное поручение    Nr. " at 16 v-ref skip(1)
"Дата   : " v-mudate skip(1)
"!----------------------------------------------------------------!" skip
"!Плательщик:                          !  Дебет !     Сумма       !" skip
"!                                     !        ! и код валюты    !" skip
"! " v-m1 "!        ! " at 39 v-sm fff v-crccode "!" at 66 skip
"! " v-m2 "!" at 39 "  " v-kbm "!                 !" at 48 skip
"! " v-m3 "!        !                 !" at 39 skip
"! " v-m4 "!        !                 !" at 39 skip
"!-------------------------------------!--------!                 !" skip
"!Получат. :                           ! Кредит !                 !" skip
"!                                     !        !                 !" skip
"! " v-s1 "!        !                 !" at 39 skip
"! " v-s2 "!" at 39 "  " v-kbs "!                 !" at 48 skip
"! " v-s3 "!        !                 !" at 39 skip
"!-------------------------------------!--------!                 !" skip
"! Сумма словами:                                                 !" skip
"! " v-sumt[1] "!" at 66 skip             
"! " v-sumt[2] "!" at 66 skip             
"!----------------------------------------------------------------!" skip(1)
"Кол-во платежных документов :" v-docnum format "zzzzz" skip
"Информация получателю  :" skip(2)


"  М.П." skip(2)
"       Подпись  " skip(1)

"==================================================================" skip.
pause 0.