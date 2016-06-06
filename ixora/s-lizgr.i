/* s-lizgr.i
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
* s-lizgr.i
* Include file for s-liz.p
*/
if {&count_period} then outer: do:
   if available cGraph then do:
      pr-rate = cGraph.rate.
      savePeriodSum = pr-sum.
      do while available cGraph and cGraph.rate = pr-rate:
          pr-sum = pr-sum + 1.
          pr-cnt = pr-cnt + 1.
          if /*cGraph.fx-amt-pay or*/ cGraph.fx-cost-pay then leave outer.
          find next cGraph no-error.
      end.
   end.
end.
/*message "pr-sum =" pr-sum "pr-cnt =" pr-cnt. pause.*/

if pr-sum > 0 then do:
   prc-mon = (pr-rate / 12 * period) / 100. /* procent lizinga za period plate·a*/
   /*sv-apm  = round((kopa-s - ava-s - pirk-s) * pr-cnt / mn, 2).*/
   sv-apm  = round((sv-not-paied - pirk-s) * pr-cnt / (mn - savePeriodSum), 2).
   if sv-not-paied >= (pirk-s + sv-apm) then sv-pirk-s = sv-not-paied - sv-apm.
   else sv-pirk-s = pirk-s.

/*message "s-lizgr.i: sv-not-paied " sv-not-paied
        "sv-pirk-s " sv-pirk-s "prc-mon " prc-mon "pr-cnt " pr-cnt skip 
        "sv-apm " sv-apm. pause.*/

   /* formula annuiteta */
   if depo-mn = 0 then
      run Formula_Annuiteta(sv-not-paied,0,sv-pirk-s,prc-mon,pr-cnt,0).
   else
      run Formula_Annuiteta(sv-not-paied,0,sv-pirk-s,prc-mon,pr-cnt - depo-mn,0).
/*message "return-value " return-value. pause.*/
   if return-value <> "" then
      per-pay = decimal(return-value).
   else if return-value = "0" then 
      per-pay = 0.
   else do:
      bell.
      message "Месячн.платежи < 0 !" view-as alert-box.
      return "false".
   end.
end.
else return.
