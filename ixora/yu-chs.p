/* yu-chs.p
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

{yu-chs.f}.
for each wrk:
     wrk.ja-ne = "".
end.
find first wrk.
i = 2.
readkey pause 0.
clear frame sar1 all.
if rezims <= 2 or rezims = 5 or rezims = 6
then repeat:
    display wrk.code wrk.des wrk.ja-ne with frame sar1.
    pause 0.
    if lstkey <> keycode("CURSOR-UP") and lstkey <> keycode("CURSOR-DOWN") and
       i < 15
    then do:
         i = i + 1.
         find next wrk no-error.
         if not available wrk
         then do:
              i = 15.
              find last wrk.
              display wrk.code wrk.des wrk.ja-ne with frame sar1.
              pause 0.
              choose row wrk.code
                  go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN") with frame sar1.
              pause 0.
              lstkey = lastkey.
              if lstkey <> keycode("RETURN")
              then color display normal wrk.code with frame sar1.
         end.
         else do:
              down with frame sar1.
              display wrk.code wrk.des wrk.ja-ne with frame sar1.
              pause 0.
         end.
    end.
    if lstkey = keycode("CURSOR-UP")
    then do:
         find prev wrk no-error.
         if not available wrk
         then find first wrk.
         else up with frame sar1.
         display wrk.code wrk.des wrk.ja-ne with frame sar1.
         choose row wrk.code
                go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN")  with frame sar1.
         pause 0.
         lstkey = lastkey.
         if lstkey <> keycode("RETURN")
         then color display normal wrk.code with frame sar1.
    end.
    if lstkey = keycode("CURSOR-DOWN") or i >= 15 and
    lstkey <> keycode("CURSOR-UP") and
    lstkey <> keycode("PF1") and
    lstkey <> keycode("RETURN")
    then do:
         find next wrk no-error.
         if not available wrk
         then find last wrk.
         else down with frame sar1.
         display wrk.code wrk.des wrk.ja-ne with frame sar1.
         choose row wrk.code
         go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN") with frame sar1.
         lstkey = lastkey.
         if lstkey <> keycode("RETURN")
         then color display normal wrk.code with frame sar1.
         pause 0.
    end.
    if lstkey = keycode("RETURN")
    then  do:
          if rezims = 1 or rezims = 5
          then do:
               if wrk.ja-ne = ""
               then wrk.ja-ne = "*".
               else wrk.ja-ne = "".
               color display normal wrk.code wrk.des wrk.ja-ne with frame sar1.
               readkey pause 0.
               lstkey = keycode("CURSOR-DOWN").
          end.
          else if rezims = 2 or rezims = 6
          then do:
               wrk.ja-ne = "+".
               find first wrk where wrk.ja-ne = "*" no-error.
               if available wrk
               then wrk.ja-ne = "".
               find first wrk where wrk.ja-ne = "+".
               wrk.ja-ne = "*".
               readkey pause 0.
               lstkey = 0.
               find first wrk.
               clear frame sar1 all.
               i = 2.
           end.
    end.
    pause 0.
    if lastkey = keycode("PF1")
    then leave.
end.
else if rezims = 3
then do:
     display wrk.code
             wrk.des
     with frame sar1.
     update wrk.code go-on("PF4") with frame sar1.
     wrk.des = wrk.code.
     wrk.ja-ne = "*".
end.
if lastkey <> keycode("PF4") and rezims <= 5
then do:
     i = rinda + 1.
     for each wrk where wrk.ja-ne = "*":
         i = i + 1.
     end.
     if i - rinda > 1
     then do:
          if i >= 20
          then rinda = 1.
          run yu-chs1(vards).
     end.
end.
hide frame sar1.
pause 0.
/*------------------------------------------------------------------------------
  #3.Programma dod iespёju izvёlёties inform–ciju no pied–v–t– saraksta.Prog-
     ramma str–d– 3 re·Ёmos:
     - 1.re·Ёm– programma µauj izvёlёties vienu vai vair–kus saraksta elementus;
     - 2.re·Ёm– programma µauj izvёlёties tikai vienu saraksta elementu;
     - 3.re·Ёm– programma µauj ievadЁt vajadzЁgo inform–ciju.
     Izvёlёtie saraksta elementi sarakst– tiek atzЁmёti ar simbolu * .
     Progrmma izmanto programmu yu-chs1.

     1.izmai‡a - nu jau ir 4 re·Ёmi: 6.re·Ёms ir tas pats 2.,tikai uz ekr–na
       neatst–j m­su izvёles variantu, k–dreiz tas ir lieki un traucёjoЅi

  #4.Ieejas inform–cija:
     - parametrs vards,kurЅ satur saraksta nosaukumu;
     - parametrs rezims,kur– uzdots programmas darba re·Ёms;
     - shared mainЁgais rinda fiksё rindas numuru,kur– novietot frame'u ar
       attёlojamajiem saraksta elementiem;
     - shared darba fails wrk  satur
               lauku    code     ar saraksta elementa kodu,
               lauku    des      ar saraksta elementa nosaukumu
               lauku    ja-ne    ar atzЁmi * , ja saraksta elements ir izvёlёts

  #5.Izejas inform–cija:
     - izmainЁts shared mainЁgais rinda,ja atzЁmёtajiem elementiem pietr­kst
       vietas uz ekr–na(rinda = 1);
     - darba fails wrk ar atzЁmi * izvёlёtajiem saraksta elementiem.
------------------------------------------------------------------------------*/
