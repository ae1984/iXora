/* cif-tda%.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Установка исключительной % ставки по депозиту TDA
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-2 (Искл%)
 * AUTHOR
        28.06.2004 nadejda - копия cif-tdae.p
        19.10.2004 dpuchkov- возможность менять дату окончания
        30.10.2013 tz1890
 * CHANGES
*/


{global.i}

message 'Пункт верхнего меню "Искл%" не активен!' view-as alert-box.
return.

def var s-aaa like aaa.aaa.
update s-aaa label "Номер счета" with centered overlay color message row 5 frame f-aaa.
hide frame f-aaa.

def var vdaytm as int.
def var vdays as int.
def var mbal like aaa.opnamt.
def var vans as log initial false.
def var termdays as inte.
def var v-availedit as logical init yes.
def var v-rate like aaa.rate.  /* ставка на группе на текущий момент */
def var d-prddate as date.

{cif-tda.f}


find aaa where aaa.aaa = s-aaa exclusive-lock.
if not available aaa then do:
  bell.
  {mesg.i 8813}.
  return.
end.

find lgr where lgr.lgr = aaa.lgr no-lock.
if lgr.led <> "TDA" and lgr.led <> "CDA"  then do:
  message " Разрешено использовать данную функцию только для депозитов физлиц и юрлиц !".
  return.
end.

if aaa.payfre = 1 then v-excl = yes.

display aaa.aaa aaa.cla aaa.lstmdt aaa.expdt aaa.pri
       aaa.rate aaa.opnamt mbal v-excl with frame aaa.
termdays = aaa.expdt - aaa.lstmdt + 1.
display aaa.expdt termdays with frame aaa.
if lgr.led <> "CDA" then do:
   run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output aaa.rate).
   mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).
end.

disp aaa.rate mbal with frame aaa.

d-prddate = aaa.expdt.
update aaa.expdt with frame aaa.

update v-excl with frame aaa.

{cif-tda-excl.i}

