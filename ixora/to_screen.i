/*
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 k.gitalov
 * BASES

 * CHANGES
*/


function UrlEncode returns char (input parm1 as char).
     def var v-rem as char.
     v-rem = parm1.
       v-rem = replace(v-rem,"&"," ").
       v-rem = replace(v-rem,"#"," ").
       v-rem = replace(v-rem,"№","!номер!").
       v-rem = replace(v-rem,"""","'").
       v-rem = replace(v-rem,"%%","%").
       v-rem = replace(v-rem,"%","!процентов!").
     return v-rem.
end function.
