/* trim-rnn.i
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


    /* отсечение записи РНН */
    tmpd = ?.
    gv-s1 = GPSTrim (GEnglish (v-s1)).
    if index (gv-s1, "RNN") > 0 then do:
       tmpd = DECIMAL (SUBSTR(gv-s1, index (gv-s1, "RNN") + 3, 12)) NO-ERROR.
    
       if tmpd <> ? and length (string (tmpd)) = 12 and string (tmpd) = v-s2 then 
       do:
          rnnind = index (v-s1, string(tmpd)).
          tmpi = r-index (v-s1, "RNN", rnnind).
          if tmpi = 0 then tmpi = r-index (v-s1, "РНН", rnnind).
          if tmpi <> 0 then do:
             tmpd = 1.23.
             SUBSTR (v-s1, tmpi, rnnind - tmpi + 12) = "".
          end.
       end.

    end.

    gv-s1 = GPSTrim (GEnglish (v-s1)).
    if tmpd <> 1.23 then
    if r-index (gv-s1, "RNN") <> index (gv-s1, "RNN") then do:
       
       tmpd = ?.
       tmpd = DECIMAL (SUBSTR(gv-s1, r-index (gv-s1, "RNN") + 3, 12)) NO-ERROR.
       if tmpd <> ? and length (string (tmpd)) = 12 and string (tmpd) = v-s2 then 
       do:
          rnnind = index (v-s1, string(tmpd)).
          if rnnind > 0 then do:
             tmpi = r-index (v-s1, "RNN", rnnind).
             if tmpi = 0 then tmpi = r-index (v-s1, "РНН", rnnind).
             if tmpi <> 0 then SUBSTR (v-s1, tmpi, rnnind - tmpi + 12) = "".
          end.
       end.

    end. 

   v-s1 = TRIM(v-s1).
