/* swmt200p.p
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

/* swmt200p.p */

def shared var s-remtrz like remtrz.remtrz.
def var result as int format "9" .
def shared buffer f57-bank for bankl.          
def shared buffer sw-bank  for bankl.         
def shared var realbic as char format "x(12)". /* real bic code    */
def shared var F53-L as char format "x(1)".    /*sender's corr.  */
def shared var F72-1val as char extent 6 format "x(35)". /* mt100.*/
def shared var F56-L as char format "x(1)".    /*intermediary.  */
def shared var F56-2val as char extent 4 format "x(35)". 
def shared var F57-L as char format "x(1)".    /*account with inst.  */
def shared var v-bb1 like remtrz.ord.
def shared var v-bb2 like remtrz.ord.
def shared var v-bb3 like remtrz.ord.
def shared var v-bb4 like remtrz.ord.

find remtrz where remtrz.remtrz = s-remtrz.
/*
 find dfb where dfb.dfb = remtrz.cracc no-lock.
*/
find crc where crc.crc = remtrz.tcrc no-lock no-error.

{sw-mt200p.f}

do on error undo,retry:

realbic = caps(trim(substr(sw-bank.bic, 3, 12))).
do on error undo,retry:
 update realbic label " DESTINATION OF MT200 " format "x(12)"
   with frame domt100 side-labels row 14 centered overlay
   width 39.
   realbic = caps(trim(realbic)).
    run swiftext(INPUT        realbic,
                 INPUT        1,
                 INPUT-OUTPUT result).
   if result ne 0 then do:
      bell.
      undo, retry.
   end.
end.
remtrz.ord = caps(trim(remtrz.ord)).

F53-L = "N".
F56-L = "N".
F56-2val[1] = substr(remtrz.intmed,1,35).
F56-2val[2] = substr(remtrz.intmed,36,35).
F56-2val[3] = substr(remtrz.intmed,71,35).
F56-2val[4] = substr(remtrz.intmed,106,35).
F57-L = "A".

{s200disp.i}
pause 0.
do on error undo,retry:

/* FIELD 53b - Sender's Correspondent */
do on error undo,retry:
update F53-L validate(F53-L eq "B" or F53-L eq "N", "")
     with  frame mt200.
if F53-L eq "B" then do:
     if trim(remtrz.sndcor[1]) eq "" then remtrz.sndcor[1] = "/".
     do on error undo,retry:
     update remtrz.sndcor[1] validate(substr(remtrz.sndcor[1],1,1) eq "/", "")
            remtrz.sndcor[2]
         with frame mt200.
     remtrz.sndcor[1] = caps(trim(remtrz.sndcor[1])).
     remtrz.sndcor[2] = caps(trim(remtrz.sndcor[2])).
     remtrz.sndcor[3] = "".
     remtrz.sndcor[4] = "".
     if (remtrz.sndcor[2] eq "" and remtrz.sndcor[1] eq "/") then do:
         bell.
         undo, retry.
     end.
     end. /* do on error */
end.
if F53-L eq "N" then do:
     remtrz.sndcor[1] = "NONE".
     remtrz.sndcor[2] = "".
     remtrz.sndcor[3] = "".
     remtrz.sndcor[4] = "".
end.
end. /* do on error */
display remtrz.sndcor[1] remtrz.sndcor[2] with frame mt200.

/* Field O56 - Intermediary */
do on error undo,retry:
update F56-L validate(F56-L eq "A" or F56-L eq "N" or F56-L eq "D", "")
     with  frame mt200.
if trim(remtrz.intmedact) eq "" then remtrz.intmedact = "/".

if F56-L eq "A" then do:
     do on error undo,retry:
     update remtrz.intmedact format "x(34)"
                   validate(substr(remtrz.intmedact,1,1) eq "/", "")
            remtrz.intmed    format "x(12)"
         with frame mt200.
     remtrz.intmedact = caps(trim(remtrz.intmedact)).
     remtrz.intmed    = caps(trim(remtrz.intmed   )).
     run swiftext(INPUT        remtrz.intmed,
                  INPUT        0,
                  INPUT-OUTPUT result).
                  if result ne 0 then do:
                        bell.
                        undo, retry.
                  end.
     end. /* do on error */
end.
if F56-L eq "D" then do:
 update remtrz.intmedact format "x(34)"
    validate(substr(remtrz.intmedact,1,1) eq "/", "") with frame mt200.
  update  F56-2val[1] format "x(35)"  label "ADDRESS"
      F56-2val[2] format "x(35)"  label "ADDRESS"
      F56-2val[3] format "x(35)"  label "ADDRESS"
      F56-2val[4] format "x(35)"  label "ADDRESS"
    with overlay top-only row 9 1 col centered no-labels
    title "Intermediary - name" frame ff56D.
    remtrz.intmed = caps( F56-2val[1] + fill(" ",35 - length(F56-2val[1])) +
                          F56-2val[2] + fill(" ",35 - length(F56-2val[2])) +
                          F56-2val[3] + fill(" ",35 - length(F56-2val[3])) +
                          F56-2val[4] ).
end.
if F56-L eq "N" then do:
     remtrz.intmedact = "NONE".
     remtrz.intmed = "".
end.
end. /* do on error */
display remtrz.intmedact remtrz.intmed with frame mt200.

/* FIELD 57a - Account with institution (M in mt200) */
do on error undo,retry:
update F57-L validate(F57-L eq "A" or F57-L eq "D", "")
     with  frame mt200.
if F57-L eq "A" then do:
     if trim(remtrz.bb[1]) eq "" then remtrz.bb[1] = "/".
     find f57-bank where f57-bank.bank = remtrz.sbank no-lock no-error.
     if f57-bank.bic ne "" then do:
        remtrz.bb[2] = trim(substr(f57-bank.bic,3)).
        remtrz.bb[3] = "".
     end.
     do on error undo,retry:
     update remtrz.bb[1]
            remtrz.bb[2]
         with frame mt200.
     remtrz.bb[1] = caps(trim(remtrz.bb[1])).
     remtrz.bb[2] = caps(trim(remtrz.bb[2])).
     remtrz.bb[3] = "".
     if substr(remtrz.bb[1],1,1) ne "/"
     then do:
         bell.
         undo, retry.
     end.
     run swiftext(INPUT        remtrz.bb[2],
                  INPUT        0,
                  INPUT-OUTPUT result).
     if result ne 0 then do:
        bell.
        undo, retry.
     end.
     end. /* do on error */
end.
else
if F57-L eq "D" then do:

/*** KOVAL     v-bb1 = substr(remtrz.bb[2] ,1,35).
     v-bb2 = substr(remtrz.bb[2] ,36,35).
     v-bb3 = substr(remtrz.bb[3] ,1,35).
     v-bb4 = substr(remtrz.bb[3] ,36,35).  			     ***/

     assign  v-bb1 = "" v-bb2 = "" v-bb3 = "" v-bb4 = "".

     do on error undo,retry:
/*** KOVAL      if trim(remtrz.bb[1]) eq "" then remtrz.bb[1] = "/". ***/
      update remtrz.bb[1] format "x(34)"
      with frame mt200.

    update v-bb1 format "x(35)" validate(trim(v-bb1) ne "", "")
           v-bb2 format "x(35)"
           v-bb3 format "x(35)"
           v-bb4 format "x(35)"
    with overlay top-only row 10 column 41 no-labels 1 col
          title "Account with institution" frame ff57D.
    remtrz.bb[2] = caps(
                     v-bb1 + fill(" ",35 - length(v-bb1)) +
                     v-bb2 + fill(" ",35 - length(v-bb2)) ).
    remtrz.bb[3] = caps(
                     v-bb3 + fill(" ",35 - length(v-bb3)) +
                     v-bb4 + fill(" ",35 - length(v-bb4))).
     remtrz.bb[1] = caps(trim(remtrz.bb[1])).
     
     if ((remtrz.bb[2] eq "") and (remtrz.bb[3] eq ""))
     then do:
         bell.
         undo, retry.
     end.
     end. /* do on error */
end.
end. /* do on error */
display remtrz.bb[1] remtrz.bb[2]  with frame mt200.

do on error undo,retry:
 if F72-1val[1] = "" then 
 do:
    F72-1val[1] = remtrz.rcvinfo[1]  . 
    F72-1val[2] = remtrz.rcvinfo[2]  .
    F72-1val[3] = remtrz.rcvinfo[3]  .
    F72-1val[4] = remtrz.rcvinfo[4]  .
    F72-1val[5] = remtrz.rcvinfo[5]  .
    F72-1val[6] = remtrz.rcvinfo[6]  .
 end .
update      /* O72 - Sender to receivers information */
    F72-1val[1] format "x(35)"
    F72-1val[2] format "x(35)"
    F72-1val[3] format "x(35)"
    F72-1val[4] format "x(35)"
    F72-1val[5] format "x(35)"
    F72-1val[6] format "x(35)"
         with  frame mt200.
end. /* do on error */
F72-1val[1] = caps(trim(F72-1val[1])).
F72-1val[2] = caps(trim(F72-1val[2])).
F72-1val[3] = caps(trim(F72-1val[3])).
F72-1val[4] = caps(trim(F72-1val[4])).
F72-1val[5] = caps(trim(F72-1val[5])).
F72-1val[6] = caps(trim(F72-1val[6])).
display F72-1val with frame mt200.

end.  /* do on error */

end.  /* do on error */
