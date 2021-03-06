﻿/* 2sb.i
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

find first vsb2 where nn = str1 no-lock no-error.
     {1} = {1} + summa.
     {2} = {2} + summa * txb.ln%his.intrate / 100.
     if v-srok ge 0 and v-srok le 30 then do: 
        find first vsb2 where nn = str2 no-lock no-error.
        {1} = {1} + summa.
        {2} = {2} + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok ge 31 and v-srok le 90 then do: 
        find first vsb2 where nn = str3 no-lock no-error.
        {1} = {1} + summa.
        {2} = {2} + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok ge 91 and v-srok le 360 then do: 
        find first vsb2 where nn = str4 no-lock no-error.
        {1} = {1} + summa.
        {2} = {2} + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok ge 361 and v-srok le 1800 then do: 
        find first vsb2 where nn = str5 no-lock no-error.
        {1} = {1} + summa.
        {2} = {2} + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok > 1800 then do: 
        find first vsb2 where nn = str6 no-lock no-error.
        {1} = {1} + summa.
        {2} = {2} + summa * txb.ln%his.intrate / 100.
     end.
