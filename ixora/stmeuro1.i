/* stmeuro1.i
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

/*  Include for formatter for EURO Currencies */
/*  stmeuro1.i Started 28/12/1998            */
 neuroamt = {1}.
 if v-euro then do:
 euroamt = 0.    /* obligately if you don't want to be fun  !!! */
 run conv(acc_list.crc,11,false,false,
 input-output neuroamt, input-output euroamt,
 output vrat1, output vrat2, output coef1, output coef2, 
 output marg1, output marg2).

 run pskip(0).
 put "EUR" format "X(4)" at {2} + margin.
 put euroamt format "z,zzz,zzz,zzz,zz9.99" at {2} + 4 + margin.
 end.
 
