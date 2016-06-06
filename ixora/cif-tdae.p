/* cif-tdae.p
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
        10.05.2004 nadejda - добавила присваивание aaa.nextint = aaa.lstmdt
        20.05.2004 nadejda - добавлен параметр номера счета в вызов tdagetrate
        21.05.2004 nadejda - добавлена информация, является ли счет исключением по % ставке
        21.06.2004 nadejda - добавлена переменная v-rate
        28.06.2004 nadejda - установка искл. % ставки перенсена в cif-tda%.p, здесь запрещена
*/

/* cif-tda.p
   Creates/updates TDA account.
*/

{global.i}

def shared var s-aaa like aaa.aaa.

def var vdaytm as int.
def var vdays as int.
def var mbal like aaa.opnamt.
def var vans as log initial false.
def var termdays as inte.
def var v-availedit as logical init yes.
def var v-rate like aaa.rate.  /* ставка на группе на текущий момент */ 

{cif-tda.f}

on help of aaa.pri in frame aaa do:
   run tdaint-help.
end.


find aaa where aaa.aaa eq s-aaa exclusive-lock.
find lgr where lgr.lgr = aaa.lgr no-lock.
if not available aaa then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.
else if aaa.cr[1] > 0 then do:
  bell.
  message "Счет срочного депозита " aaa.aaa " имеет ненулевые обороты." skip
          "Нельзя редактировать параметры!" view-as alert-box title "".
  undo, return.
end.

if aaa.payfre = 1 then v-excl = yes.

display aaa.aaa aaa.cla aaa.lstmdt aaa.expdt aaa.pri 
       aaa.rate aaa.opnamt mbal v-excl with frame aaa.

update aaa.cla aaa.lstmdt with frame aaa.
run EvaluateExpiryDate.
termdays = aaa.expdt - aaa.lstmdt + 1.
display aaa.expdt termdays with frame aaa.
update aaa.opnamt aaa.pri with frame aaa.
aaa.nextint = aaa.lstmdt.
run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output aaa.rate).
mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).
disp aaa.rate mbal with frame aaa.

Procedure EvaluateExpiryDate.
 def var years as inte initial 0.
 def var months as inte initial 0.
 def var days as inte.
 days = day(aaa.lstmdt).
 years = integer(aaa.cla / 12 - 0.5).
 months = aaa.cla - years * 12.
 months = months + month(aaa.lstmdt).
 if months > 12 then do:
    years = years + 1.
    months = months - 12.
 end.
   if month(aaa.lstmdt) <> month(aaa.lstmdt + 1) then do:
      months = months + 1.
      if months = 13 then do:
         months = 1.
         years = years + 1.
      end.
      days = 1.
   end.
   aaa.expdt = date(months, days, year(aaa.lstmdt) + years).
   if month(aaa.lstmdt) <> month(aaa.lstmdt + 1) then aaa.expdt = aaa.expdt - 1.
End procedure.
