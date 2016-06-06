/* swmt100p.p
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

/* swmt100p.p
   заполнение полей SWIFT 100
   изменения от 27.03.2001
   - обратный переход от поля к полю по F4
   30.05.01
   - обработка поля 57

   06/02/2002 - отгадывание параметров "D", "N", "A"
              F52,53,54,56,57... в соотв. с remtrz
*/

def shared var s-remtrz like remtrz.remtrz.
def shared var sw as log.
def var result  as int format "9".
def shared buffer sw-bank for bankl.           /* nan */
def shared var realbic as char format "x(12)". /* real bic code    */
def shared var remrem202 as char format "x(16)". /* field 20 of mt202  */
def var F50-val as char extent 4 format "x(35)". /*ordering cust*/
def shared var F52-L as char format "x(1)".  /* ordering institution*/
def shared var F53-L as char format "x(1)".  /* sender's corr.      */
def shared var F54-L as char format "x(1)".  /* receiver's corr.    */
def shared var F56-L as char format "x(1)".    /*intermediary.  */
def shared var F53-2L as char format "x(1)".    /*intermediary 202.*/
def shared var F53-2val as char extent 4 format "x(35)". /*intermediary 202.*/
def shared var F56-2L as char format "x(1)".    /*intermediary 202.*/
def shared var F56-2val as char extent 4 format "x(35)". /*intermediary 202.*/
def shared var F57-2L as char format "x(1)".    /*intermediary 202.*/
def shared var F57-2val as char extent 5 format "x(35)". /*intermediary 202.*/
def shared var F72-2val as char extent 6 format "x(35)". /*intermediary 202.*/
def shared var F72-1val as char extent 6 format "x(35)". /* mt100.*/
def shared var F57-L as char format "x(1)".    /*account with inst.  */
def shared var F57-str4 as char extent 2 format "x(35)". /*addit.str.for f57d in 100*/
def shared var F58-2L as char format "x(1)".
def shared var F58-2aval as char extent 5 format "x(35)". /*58 - account 202.*/
def  var F71choice as char extent 3 format "x(3)" initial
     ["BEN", "OUR","NON"].

def shared var domt100 as char format "x(12)". /*dest of mt100 if mt202*/
def shared var f_title as char format "x(80)". /*title of frame mt100  */
def var ans as log init yes.
def shared var v-bn1 like remtrz.ord.
def shared var v-bn2 like remtrz.ord.
def shared var v-bn3 like remtrz.ord.
def shared var v-bn4 like remtrz.ord.
def var v-bb as character.
def var v-str as char.

find remtrz where remtrz.remtrz = s-remtrz.
find crc where crc.crc = remtrz.tcrc no-lock no-error.

{sw-mt100p.f}
{sw-mt202p.f}
{swm-tst.i}

realbic = caps(trim(substr(sw-bank.bic, 3, 12))).
 /* always BIC of nostro */

if domt100 eq "ONE" then do:   /* only one mt100 to nostro bank */
      f_title = " SWIFT MT100 MESSAGE. " + "DESTINATION: " + realbic + " ".

      v-str = trim(remtrz.sndcor[1] + ' ' + remtrz.sndcor[2] + ' ' + remtrz.sndcor[3] + ' ' + remtrz.sndcor[4]).
      if index (v-str,' ') = 0 then
      do:
         if v-str = '' or v-str = "NONE" then F53-L = "N".
                                         else F53-L = "A".
      end. else F53-L = "D".
end.
else do:                       /* mt100 to destination, mt202 to nostro */
      f_title = " SWIFT MT100 (1) MESSAGE. " + "DESTINATION: " + domt100 + " ".
      F53-L = "A".
      if remtrz.sndcor[1] eq "" then do:
            remtrz.sndcor[1] = realbic.
            remtrz.sndcor[2] = "".
            remtrz.sndcor[3] = "".
            remtrz.sndcor[4] = "".
      end.

end.

run trtolat(INPUT-OUTPUT remtrz.ord).

/* sasco - for RUB */
if remtrz.tcrc <> 4 then remtrz.ord = caps(trim(remtrz.ord)).
                    else remtrz.ord = trim(remtrz.ord).

  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt100p.p 103", "1", "", "").
  end.

F50-val[1] = substr(remtrz.ord, 1 , 35).
F50-val[2] = substr(remtrz.ord, 36, 35).
F50-val[3] = substr(remtrz.ord, 71, 35).
F50-val[4] = substr(remtrz.ord, 106, 35).


F52-L = "N".
/* new by sasco */
/*
v-str = trim(remtrz.ordins[1] + ' ' + remtrz.ordins[2] + ' ' + remtrz.ordins[3] + ' ' + remtrz.ordins[4]).
if index (v-str,' ') = 0 then
do: if v-str = '' or v-str = "NONE" then F52-L = "N".
                                    else F52-L = "A".
end. else F52-L = "D".
*/


/* F54-L = "N".   --- rcvcor [1..4] */
v-str = trim(remtrz.rcvcor[1] + ' ' + remtrz.rcvcor[2] + ' ' + remtrz.rcvcor[3] + ' ' + remtrz.rcvcor[4]).
if index (v-str,' ') = 0 then
do: if v-str = '' or v-str = "NONE" then F54-L = "N".
                                    else F54-L = "A".
end. else F54-L = "D".

/* F56-L = "N".       .intmedact - with spaces if 'D' */
v-str = trim(remtrz.intmedact).
if index (v-str,' ') = 0 then
do: if v-str = '' or v-str = "NONE" then F56-L = "N".
                                    else F56-L = "A".
end. else F56-L = "D".



/* F57-L = "N".    bb[1] - NONE, bb[3] <> '' -> "D" */
if trim(remtrz.bb[1]) = "NONE" then F57-L = "N".
else
if trim(remtrz.bb[3]) <> "" then F57-L = "D".
else F57-L = "A".


F58-2L = "A".

F56-2val[1] = substr(remtrz.intmedact,35,35).
F56-2val[2] = substr(remtrz.intmedact,70,35).
F56-2val[3] = substr(remtrz.intmedact,105,35).
F56-2val[4] = substr(remtrz.intmedact,140,35).
remtrz.intmedact = substr(remtrz.intmedact,1,34).

v-bn1 = substr(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],1,35).
v-bn2 = substr(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],36,35).
v-bn3 = substr(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],71,35).
v-bn4 = substr(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],106,35).

/*remtrz.bb[3] = remtrz.bb[1] + remtrz.bb[2] + remtrz.bb[3].
remtrz.bb[1] = substr(remtrz.bb[3],1,35).
remtrz.bb[2] = substr(remtrz.bb[3],36,35).
F57-str4[1] = substr(remtrz.bb[3],106,35).
F57-str4[2] = substr(remtrz.bb[3],141,35).
remtrz.bb[3] = substr(remtrz.bb[3],71,35). */
if index(remtrz.bb[3],'|') > 0 then do.
   v-bb = remtrz.bb[3].
   remtrz.bb[3] = substr(v-bb,1,index(v-bb,'|') - 1).
   v-bb = substr(v-bb,index(v-bb,'|') + 1).
   if index(v-bb,'|') > 0 then do.
      F57-str4[1] = substr(v-bb,1,index(v-bb,'|') - 1).
      F57-str4[2] = substr(v-bb,index(v-bb,'|') + 1).
   end.
end.


{s100disp.i}
pause 0.

M50:
/* Field 50. Variable F50-val declared only because remtrz.ord is 1-dim. */
do on error undo,retry M50:
   update      /* M50 - ordering customer */
      F50-val[1] validate(trim(F50-val[1]) ne "", "")
      F50-val[2]
      F50-val[3]
      F50-val[4]
      with overlay top-only row 4 column 41 no-labels 1 col
      title "Ordering customer"
      frame ff50.

   /* sasco - for RUB */
   if remtrz.tcrc <> 4 then
   remtrz.ord = caps(F50-val[1]) + fill(" ",35 - length(F50-val[1])) +
                caps(F50-val[2]) + fill(" ",35 - length(F50-val[2])) +
                caps(F50-val[3]) + fill(" ",35 - length(F50-val[3])) +
                caps(F50-val[4]).
   else
   remtrz.ord = F50-val[1] + fill(" ",35 - length(F50-val[1])) +
                F50-val[2] + fill(" ",35 - length(F50-val[2])) +
                F50-val[3] + fill(" ",35 - length(F50-val[3])) +
                F50-val[4].

   if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt100p.p 197-202", "1", "", "").
   end.

   display remtrz.ord with frame mt100.

   /* FIELD O52A - ordering institution */
   M52:
   do on error undo M52, retry M52:
      update F52-L
             validate(F52-L eq "A" or F52-L eq "D" or F52-l eq "N", "")
             with  frame mt100.
      if F52-L eq "A" then do:
         find sysc where sysc.sysc = "swicod" no-lock.
         remtrz.ordins[1] = sysc.chval.
         do on error undo M52, retry  M52:
            update remtrz.ordins[1] format "x(12)" validate (swm-tst(remtrz.ordins[1]),
     					           "100(52) Swift-код должен быть 8 или 11 символов")
                   label "Ordering institution - BIC"
                   with overlay top-only row 6 centered side-labels
                   frame ff52A.
            remtrz.ordins[1] = caps(trim(remtrz.ordins[1])).
            run swiftext(INPUT        remtrz.ordins[1],
                         INPUT        0,
                         INPUT-OUTPUT result).
            if  result ne 0 then do:
                bell. undo, retry.
            end.
         end. /* do on error */
      end.
      if F52-L eq "D" then do:
         find sysc where sysc.sysc = "swadd1" no-lock.
         remtrz.ordins[1] = sysc.chval.
         find sysc where sysc.sysc = "swadd2" no-lock.
         remtrz.ordins[2] = sysc.chval.
         find sysc where sysc.sysc = "swadd3" no-lock.
         remtrz.ordins[3] = sysc.chval.
         find sysc where sysc.sysc = "swadd4" no-lock.
         remtrz.ordins[4] = sysc.chval.
         do on error undo M52, retry M52:
            update remtrz.ordins
              with overlay top-only row 6 column 41 no-labels 1 col
              title "Ordering institution - ADDRESS"
              frame ff52D.
            remtrz.ordins[1] = caps(remtrz.ordins[1]).
            remtrz.ordins[2] = caps(remtrz.ordins[2]).
            remtrz.ordins[3] = caps(remtrz.ordins[3]).
            remtrz.ordins[4] = caps(remtrz.ordins[4]).
            if remtrz.ordins[1] eq "" then do:
               bell. undo, retry.
            end.
         end. /* do on error */
      end.
      if F52-L eq "N" then do:
         remtrz.ordins[1] = "NONE".
         remtrz.ordins[2] = "".
         remtrz.ordins[3] = "".
         remtrz.ordins[4] = "".
      end.
      display remtrz.ordins[1] with frame mt100.
      MA:
      do on error undo MA, retry MA :
      /* FIELD 53a - Sender's Correspondent */
        if domt100 eq "ONE" then do:
           /* only if one mt100 to dest. else BIC of nostro */
           M53:
           do on error undo M53, retry M53 :
              update F53-L
                validate(F53-L eq "A" or F53-L eq "D" or F53-L eq "N", "")
                with  frame mt100.
              if F53-L eq "A" then do:
                 do on endkey undo M53,retry M53:
                   update remtrz.sndcor[1] format "x(12)"
                      label "Sender's correspondent - BIC"
		      validate (swm-tst(remtrz.sndcor[1]),
     				"100(53) Swift-код должен быть 8 или 11 символов")
                      with overlay top-only row 7 centered side-labels
                      frame ff53A.
                   remtrz.sndcor[1] = caps(trim(remtrz.sndcor[1])).
                   run swiftext(INPUT        remtrz.sndcor[1],
                                INPUT        0,
                                INPUT-OUTPUT result).
                   if result ne 0 then do:
                      bell. undo, retry.
                   end.
                 end. /* do on error */
                 remtrz.sndcor[2] = "".
                 remtrz.sndcor[3] = "".
                 remtrz.sndcor[4] = "".
              end.    /* if F53-L eq "A" */
              if F53-L eq "D" then do:
                 do on endkey undo M53,retry M53:
                   update remtrz.sndcor
                      with overlay top-only row 7 column 41 no-labels 1 col
                      title "Sender's correspondent - ADDRESS"
                      frame ff53D.

                   /* sasco - for RUB */
                   if remtrz.tcrc <> 4 then
                   do:
                   remtrz.sndcor[1] = caps(remtrz.sndcor[1]).
                   remtrz.sndcor[2] = caps(remtrz.sndcor[2]).
                   remtrz.sndcor[3] = caps(remtrz.sndcor[3]).
                   remtrz.sndcor[4] = caps(remtrz.sndcor[4]).
                   end.

                   if remtrz.sndcor[1] eq "" then do:
                      bell. undo, retry.
                   end.
                 end. /* do on error */
              end.  /* if F53-L eq "D" */
              if F53-L eq "N" then do:
                 remtrz.sndcor[1] = "NONE".
                 remtrz.sndcor[2] = "".
                 remtrz.sndcor[3] = "".
                 remtrz.sndcor[4] = "".
              end.
              M56:
              /* Field O56 - Intermediary */
              do on error undo M56 ,retry M56:
                 update F56-L
                    validate(F56-L eq "A" or F56-L eq "N" or F56-L eq "D", "")
                    with  frame mt100.
                 if F56-L eq "A" then do:
                    if trim(remtrz.intmedact) eq ""
                       then remtrz.intmedact = "/".
                    do on error undo M56,retry M56:
                       update remtrz.intmedact
                               format "x(34)" label     "ACCOUNT N"
                               validate(substr(remtrz.intmedact,1,1) eq "/", "")
                               remtrz.intmed
				validate (swm-tst(remtrz.intmed),
				         "100(56) Swift-код должен быть 8 или 11 символов")
                               format "x(12)"  label "      BIC"
                               with overlay top-only row 9 1 col
                               centered side-labels
                               title "Intermediary - BIC"
                               frame ff56A.
                       remtrz.intmedact = caps(trim(remtrz.intmedact)).
                       remtrz.intmed    = caps(trim(remtrz.intmed   )).
                       run swiftext(INPUT        remtrz.intmed,
                                    INPUT        0,
                                    INPUT-OUTPUT result).
                       if result ne 0 then do:
                          bell. undo, retry.
                       end.
                    end. /* do on error */
                 end.  /* if F56-L eq "A" */
                 if F56-L eq "D" then do:
                    update remtrz.intmedact
                            format "x(34)" label "ACCOUNT N"
                            validate(substr(remtrz.intmedact,1,1) eq "/", "")
                           F56-2val[1] format "x(35)"  label "ADDRESS"
                           F56-2val[2] format "x(35)"  label "ADDRESS"
                           F56-2val[3] format "x(35)"  label "ADDRESS"
                           F56-2val[4] format "x(35)"  label "ADDRESS"
                        with overlay top-only row 9 1 col centered no-labels
                        title "Intermediary - name" frame ff56D.
                    remtrz.intmedact = caps(remtrz.intmedact +
                     fill(" ",34 - length(remtrz.intmedact)) +
                     F56-2val[1] + fill(" ",35 - length(F56-2val[1])) +
                     F56-2val[2] + fill(" ",35 - length(F56-2val[2])) +
                     F56-2val[3] + fill(" ",35 - length(F56-2val[3])) +
                     F56-2val[4]).
                 end. /* if F56-L eq "D" */
                 if F56-L eq "N" then do:
                    remtrz.intmedact = "NONE".
                    remtrz.intmed = "".
                 end.
              end. /* do on error M56 */
              end. /* do on error  M53 */
        end. /* if domt100 .... */

        display remtrz.sndcor[1] with frame mt100.
        if domt100 ne "ONE" then do :
           M54:
           /* FIELD 54a - Receiver's Correspondent */
           do on error undo M54,retry M54:
              update F54-L
                validate(F54-L eq "A" or F54-L eq "D" or F54-L eq "N", "")
                with  frame mt100.
              if F54-L eq "A" then do:
                 do on error undo M54,retry M54:
                    update remtrz.rcvcor[1] format "x(12)"
				validate (swm-tst(remtrz.rcvcor[1]),
    				         "100(54) Swift-код должен быть 8 или 11 символов")
                         label "Receiver's correspondent - BIC"
                         with overlay top-only row 8 centered side-labels
                         frame ff54A.
                    remtrz.rcvcor[1] = caps(trim(remtrz.rcvcor[1])).
                    run swiftext(INPUT        remtrz.rcvcor[1],
                                 INPUT        0,
                                 INPUT-OUTPUT result).
                    if result ne 0 then do:
                        bell. undo, retry.
                    end.
                 end. /* do on error */
                 remtrz.rcvcor[2] = "".
                 remtrz.rcvcor[3] = "".
                 remtrz.rcvcor[4] = "".
              end. /* if F54-L eq "A" */
              if F54-L eq "D" then do:
                 do on error undo M54,retry M54:
                    update remtrz.rcvcor
                      with overlay top-only row 8 column 41 no-labels 1 col
                      title "Receiver's correspondent - ADDRESS"
                      frame ff54D.

                    /* sasco - for RUB */
                    if remtrz.tcrc <> 4 then
                    do:
                    remtrz.rcvcor[1] = caps(remtrz.rcvcor[1]).
                    remtrz.rcvcor[2] = caps(remtrz.rcvcor[2]).
                    remtrz.rcvcor[3] = caps(remtrz.rcvcor[3]).
                    remtrz.rcvcor[4] = caps(remtrz.rcvcor[4]).
                    end.

                    if remtrz.rcvcor[1] eq "" then do:
                        bell. undo, retry.
                    end.
                 end. /* do on error */
              end. /* if F54-L eq "D" */
              if F54-L eq "N" then do:
                 remtrz.rcvcor[1] = "NONE".
                 remtrz.rcvcor[2] = "".
                 remtrz.rcvcor[3] = "".
                 remtrz.rcvcor[4] = "".
              end.
           end. /* do on error 54 */
        end.    /* if domt100 ne "ONE"   */

        display remtrz.rcvcor[1] with frame mt100.
        display remtrz.intmedact with frame mt100.
        if (domt100 ne "ONE") and (F56-L ne "N") and (F54-L eq "N") then do:
            bell.
            MESSAGE "Incorrect combination of 54 and 56 fields" VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание ".
            undo, retry.
        end.
        M57:
        /* FIELD 57a - Account with institution */
        do on error undo M57,retry M57:
           update F57-L
             validate(F57-L eq "A" or F57-L eq "D" or F57-L eq "N", "")
             with  frame mt100.
           if F57-L eq "A" then do:
              if trim(remtrz.bb[1]) eq "" then remtrz.bb[1] = "/".
              do on error undo M57,retry M57:
                 update remtrz.bb[1] format "x(34)" label "ACCOUNT N" validate(substr(remtrz.bb[1],1,1) eq "/", "")
                        remtrz.bb[2] validate (swm-tst(remtrz.bb[2]),"100(57) Swift-код должен быть 8 или 11 символов")
                        format "x(12)"  label "      BIC"
                        with overlay top-only row 10 1 col centered side-labels
                        title "Account with institution - BIC" frame ff57A.
                remtrz.bb[1] = caps(remtrz.bb[1]).
                remtrz.bb[2] = caps(remtrz.bb[2]).
                remtrz.bb[3] = "".
                run swiftext(INPUT        remtrz.bb[2],INPUT        0, INPUT-OUTPUT result).
                if result ne 0 then do:
                   bell. undo, retry.
                end.
              end. /* do on error */
           end. /* if F57-L eq "A" */
           if F57-L eq "D" then do:
              if trim(remtrz.bb[1]) +
                 trim(remtrz.bb[2]) +
                 trim(remtrz.bb[3]) eq "" then do:
                 find first bankl where bankl.bank = remtrz.rbank no-lock no-error .
                 if avail bankl then do:
                    remtrz.bb[1] = "/" + bankl.name.
                    remtrz.bb[2] = bankl.addr[1].
                    remtrz.bb[3] = trim(bankl.addr[2]) + " " + bankl.addr[3].
                 end.
              end.
              do on error undo M57,retry M57:
                update remtrz.bb[1] format "x(35)" label "ACCOUNT N"  validate(substr(remtrz.bb[1],1,1) eq "/", "")
                       remtrz.bb[2] format "x(35)" label "ADDRESS"
                       remtrz.bb[3] format "x(35)" label "ADDRESS"
                       F57-str4[1]  format "x(35)" label "ADDRESS"
                       F57-str4[2]  format "x(35)" label "ADDRESS"
                       with overlay top-only row 10 no-labels 1 col centered side-labels
                       title "Account with institution - ADDRESS"
                       frame ff57D.

                /* sasco - for RUB */
                if remtrz.tcrc <> 4 then
                do:
                remtrz.bb[1] = caps(remtrz.bb[1]).
                remtrz.bb[2] = caps(remtrz.bb[2]).
                remtrz.bb[3] = caps(remtrz.bb[3]) + '|' +
                               caps(F57-str4[1]) + '|' +
                               caps(F57-str4[2]) .
                F57-str4[1]  = caps(F57-str4[1]).
                F57-str4[2]  = caps(F57-str4[2]).
                end.
                else do:
                remtrz.bb[3] = remtrz.bb[3] + '|' +
                               F57-str4[1] + '|' +
                               F57-str4[2] .
                end.

                if trim(remtrz.bb[2]) eq "" then do:
                   bell. undo, retry.
                end.
              end. /* do on error */
           end. /* if F57-L eq "D" */
           if F57-L eq "N" then do:
              remtrz.bb[1] = "NONE".
              remtrz.bb[2] = "".
              remtrz.bb[3] = "".
           end.
           display remtrz.bb[1] remtrz.bb[2] with frame mt100.
           pause 0.

           M59:
           /* M59 - beneficiary customer */
           do on error undo M59,retry M59:
              if trim(remtrz.ba) eq "" then remtrz.ba = "/".
              else
                 if substr(trim(remtrz.ba),1,1) <> "/"
                 then remtrz.ba = "/" + trim(remtrz.ba) .
              update remtrz.ba
                      format "x(34)" validate(substr(remtrz.ba,1,1) eq "/", "")
                      with frame mt100.

              /* sasco - for RUB */
              if remtrz.tcrc <> 4 then remtrz.ba = caps(trim(remtrz.ba)).
                                  else remtrz.ba = trim(remtrz.ba).

              display remtrz.ba  with frame mt100.
              pause 0.
              update v-bn1  format "x(35)" validate(trim(v-bn1) ne "", "")
                     v-bn2  format "x(35)"
                     v-bn3  format "x(35)"
                     v-bn4  format "x(35)"
                     with overlay top-only row 10 column 41 no-labels 1 col
                     title "Beneficiary customer" frame ff59.

              /* sasco - for RUB : first - make string, second - caps */
                 remtrz.bn[1] = substr(
                    v-bn1 + fill(" ",35 - length(v-bn1)) +
                    v-bn2 + fill(" ",35 - length(v-bn2)) +
                    v-bn3 + fill(" ",35 - length(v-bn3)) +
                    v-bn4,1,47 ).
                 remtrz.bn[2] = substr(
                    v-bn1 + fill(" ",35 - length(v-bn1)) +
                    v-bn2 + fill(" ",35 - length(v-bn2)) +
                    v-bn3 + fill(" ",35 - length(v-bn3)) +
                    v-bn4,48,47).
                 remtrz.bn[3] = substr(
                    v-bn1 + fill(" ",35 - length(v-bn1)) +
                    v-bn2 + fill(" ",35 - length(v-bn2)) +
                    v-bn3 + fill(" ",35 - length(v-bn3)) +
                    v-bn4,95).
              if remtrz.tcrc <> 4 then
              do:
              remtrz.bn[1] = caps(remtrz.bn[1]).
              remtrz.bn[2] = caps(remtrz.bn[2]).
              remtrz.bn[3] = caps(remtrz.bn[3]).
              end.

           M70:
           /* O70 - details of payment */
           do on error undo M70,retry M70:
              update remtrz.detpay[1]
                     remtrz.detpay[2]
                     remtrz.detpay[3]
                     remtrz.detpay[4]
                     with  frame mt100.


             /* sasco - for RUB */
             if remtrz.tcrc <> 4 then
             do:
              remtrz.detpay[1] = caps(remtrz.detpay[1]).
              remtrz.detpay[2] = caps(remtrz.detpay[2]).
              remtrz.detpay[3] = caps(remtrz.detpay[3]).
              remtrz.detpay[4] = caps(remtrz.detpay[4]).
             end.

              display remtrz.detpay with frame mt100.
              pause 0.
              M71:
              /* Field O71 - Details of charges */
              do on error undo M71, retry M71:
                 form F71choice
                      with overlay top-only row 17 1 col column 45 no-labels
                      frame x.
                 display F71choice with frame x.
                 choose field F71choice AUTO-RETURN with frame x.
                 remtrz.bi = FRAME-VALUE.
                 display remtrz.bi with frame mt100.
                 pause 0.

                 M72:
                 /* O72 - Sender to receivers information */
                 do on error undo M71,retry M71:
                    F72-1val[1] = remtrz.rcvinfo[1] .
                    F72-1val[2] = remtrz.rcvinfo[2] .
                    F72-1val[3] = remtrz.rcvinfo[3] .
                    F72-1val[4] = remtrz.rcvinfo[4] .
                    F72-1val[5] = remtrz.rcvinfo[5] .
                    F72-1val[6] = remtrz.rcvinfo[6] .

                    update F72-1val[1] format "x(35)"
                           F72-1val[2] format "x(35)"
                           F72-1val[3] format "x(35)"
                           F72-1val[4] format "x(35)"
                           F72-1val[5] format "x(35)"
                           F72-1val[6] format "x(35)"
                        with overlay top-only row 13 column 41 no-labels 1 col
                        title "Sender to Receiver information"
                        frame ff72.
                 end. /* do on error M72 */

                 /* sasco - for RUB */
                    F72-1val[1] = trim(F72-1val[1]).
                    F72-1val[2] = trim(F72-1val[2]).
                    F72-1val[3] = trim(F72-1val[3]).
                    F72-1val[4] = trim(F72-1val[4]).
                    F72-1val[5] = trim(F72-1val[5]).
                    F72-1val[6] = trim(F72-1val[6]).
                 if remtrz.tcrc <> 4 then
                 do:
                    F72-1val[1] = caps(F72-1val[1]).
                    F72-1val[2] = caps(F72-1val[2]).
                    F72-1val[3] = caps(F72-1val[3]).
                    F72-1val[4] = caps(F72-1val[4]).
                    F72-1val[5] = caps(F72-1val[5]).
                    F72-1val[6] = caps(F72-1val[6]).
                 end.

                 remtrz.rcvinfo[1] =  F72-1val[1] .
                 remtrz.rcvinfo[2] =  F72-1val[2] .
                 remtrz.rcvinfo[3] =  F72-1val[3] .
                 remtrz.rcvinfo[4] =  F72-1val[4] .
                 remtrz.rcvinfo[5] =  F72-1val[5] .
                 remtrz.rcvinfo[6] =  F72-1val[6] .

                 display F72-1val[1] with frame mt100.
                 pause 0.
        end. /* do on error M71 */
       end. /* do on error M70 */
      end. /* do on error M59 */
     end. /* do on error M57 */
    end. /* do on error MA  */
  end.  /* do on error M52 */
end. /* do on error M50 */

sw = yes.
do on error undo,retry:

/* mt202  -- mt202  -- mt202  -- mt202  --  mt202  --  */

if domt100 ne "ONE" then do:  /* now it's time for mt202*/

remrem202 = remtrz.remtrz + "-S2".

if F56-L eq "N" and F54-L eq "N" then do: /* no indmed, no rcvcor */
       F53-2L = "N".
       F53-2val[1] = "".
       F53-2val[2] = "".
       F53-2val[3] = "".
       F53-2val[4] = "".
       F56-2L = "N".
       F56-2val[1] = "".
       F56-2val[2] = "".
       F56-2val[3] = "".
       F56-2val[4] = "".
       F57-2L = "N".
       F57-2val[1] = "".
       F57-2val[2] = "".
       F57-2val[3] = "".
       F57-2val[4] = "".
       F57-2val[5] = "".
end.

if F56-L eq "N" and F54-L ne "N" then do: /* no intmed, is rcvcor */
       F53-2L = "N".
       F53-2val[1] = "".
       F53-2val[2] = "".
       F53-2val[3] = "".
       F53-2val[4] = "".
       F56-2L = "N". /* 54 is empty */
       F56-2val[1] = "".
       F56-2val[2] = "".
       F56-2val[3] = "".
       F56-2val[4] = "".
       F57-2L = F54-L.
       F57-2val[1] = remtrz.rcvcor[1].
       F57-2val[2] = remtrz.rcvcor[2].
       F57-2val[3] = remtrz.rcvcor[3].
       F57-2val[4] = remtrz.rcvcor[4].
end.

if F56-L ne "N" and F54-L ne "N" then do: /* is intmed, is rcvcor */
       F53-2L = "N".
       F53-2val[1] = "".
       F53-2val[2] = "".
       F53-2val[3] = "".
       F53-2val[4] = "".
       F56-2L = F54-L.   /* 54 of related mt100 */
       F56-2val[1] = remtrz.rcvcor[1].
       F56-2val[2] = remtrz.rcvcor[2].
       F56-2val[3] = remtrz.rcvcor[3].
       F56-2val[4] = remtrz.rcvcor[4].

       if  (substr(F72-1val[1], 2, 3) eq "RCB") then do:
               F57-2L = "A".
               F57-2val[1] = substr(F72-1val[1], 6, 12).
               F57-2val[2] = "".
               F57-2val[3] = "".
               F57-2val[4] = "".
               F57-2val[5] = "".
       end.
       else do:
               F57-2L = "N".
               F57-2val[1] = "".
               F57-2val[2] = "".
               F57-2val[3] = "".
               F57-2val[4] = "".
               F57-2val[5] = "".
       end.
end.
/*
F58-2aval = "/" + domt100.
*/

Message " update MT202 (y/n) ? " update ans.

{s202disp.i}
if ans = no then
pause .
else do :
pause 0.

do on error undo,retry:


/* FIELD 53a - Sender's Correspondent */
do on error undo,retry:
update F53-2L validate(F53-2L eq "A" or F53-2L eq "D" or F53-2L eq "N" or
                       F53-2L eq "B", "")
     with  frame mt202.
if F53-2L eq "A" then do:
     do on error undo,retry:
     update F53-2val[1] format "x(12)" validate (swm-tst(F53-2val[1]),
     					         "202-2(53) Swift-код должен быть 8 или 11 символов")
         label "Sender's correspondent - BIC"
         with overlay top-only row 6 centered side-labels
         frame ff53A-2.
     F53-2val[1] = caps(trim(F53-2val[1])).
     run swiftext(INPUT        F53-2val[1],
                  INPUT        0,
                  INPUT-OUTPUT result).
       if result ne 0 then
          do: bell. undo, retry. end.
     end. /* do on error */
     F53-2val[2] = "".
     F53-2val[3] = "".
     F53-2val[4] = "".
end.
if F53-2L eq "D" or F53-2L eq "B" then do:
     do on error undo,retry:
     update F53-2val with frame mt202.

     /* sasco - for RUB */
     if remtrz.tcrc <> 4 then
     do:
     F53-2val[1] = caps(F53-2val[1]).
     F53-2val[2] = caps(F53-2val[2]).
     F53-2val[3] = caps(F53-2val[3]).
     F53-2val[4] = caps(F53-2val[4]).
     end.

     if F53-2val[1] eq "" then do:
         bell.
         undo, retry.
     end.
     end. /* do on error */
end.
if F53-2L eq "N" then do:
     F53-2val[1] = "NONE".
     F53-2val[2] = "".
     F53-2val[3] = "".
     F53-2val[4] = "".
end.
end. /* do on error */
display F53-2val with frame mt202.
pause 0.

/* FIELD 56a - intermediary */
do on error undo,retry:
update F56-2L validate(F56-2L eq "A" or F56-2L eq "D" or F56-2L eq "N"
                       , "")
     with  frame mt202.
if F56-2L eq "A" then do:
     do on error undo,retry:
     update F56-2val[1] validate (swm-tst(F56-2val[1]),
     				  "202-2(56) Swift-код должен быть 8 или 11 символов")
     				  format "x(12)"
         label "Intermediary - BIC"
         with overlay top-only row 10 centered side-labels
         frame ff56A-2.
     F56-2val[1] = caps(trim(F56-2val[1])).
     run swiftext(INPUT        F56-2val[1],
                  INPUT        0,
                  INPUT-OUTPUT result).
      if result ne 0
        then do: bell. undo, retry. end.
     end. /* do on error */
     F56-2val[2] = "".
     F56-2val[3] = "".
     F56-2val[4] = "".
end.
if F56-2L eq "D" then do:
     do on error undo,retry:
     update F56-2val with frame mt202.

     /* sasco - for RUB */
     if remtrz.tcrc <> 4 then
     do:
     F56-2val[1] = caps(F56-2val[1]).
     F56-2val[2] = caps(F56-2val[2]).
     F56-2val[3] = caps(F56-2val[3]).
     F56-2val[4] = caps(F56-2val[4]).
     end.

     if F56-2val[1] eq "" then do:
         bell.
         undo, retry.
     end.
     end. /* do on error */
end.
if F56-2L eq "N" then do:
     F56-2val[1] = "NONE".
     F56-2val[2] = "".
     F56-2val[3] = "".
     F56-2val[4] = "".
end.
end. /* do on error */
display F56-2val with frame mt202.
pause 0.

/* FIELD 57a - Account with institution */
do on error undo,retry:
 update F57-2L validate(F57-2L eq "A" or F57-2L eq "D" or F57-2L eq "N" or
                       F57-2L eq "B", "")
     with  frame mt202.

  if trim(F57-2val[1]) eq "" then F57-2val[1] = "/".
 update F57-2val[1] format "x(34)"
       validate(substr(F57-2val[1],1,1) eq "/", "") with  frame mt202.
 F57-2val[1] = caps(F57-2val[1]).

 if F57-2L eq "A" then do:
     do on error undo,retry:
     update F57-2val[2] format "x(12)"  validate (swm-tst(F57-2val[2]),
     					          "202-2(57) Swift-код должен быть 8 или 11 символов")
         label "Account with institution - BIC"
         with overlay top-only row 14 centered side-labels
         frame ff57A-2.
     F57-2val[2] = caps(trim(F57-2val[2])).
     run swiftext(INPUT        F57-2val[2],
                  INPUT        0,
                  INPUT-OUTPUT result).
       if result ne 0 then
          do: bell. undo, retry. end.
     end. /* do on error */
     F57-2val[3] = "".
     F57-2val[4] = "".
     F57-2val[5] = "".
 end.
 if F57-2L eq "D" or F57-2L eq "B" then do:
     do on error undo,retry:
     update F57-2val[2] F57-2val[3] F57-2val[4] F57-2val[5] with frame mt202.

     /* sasco - for RUB */
     if remtrz.tcrc <> 4 then
     do:
     F57-2val[2] = caps(F57-2val[2]).
     F57-2val[3] = caps(F57-2val[3]).
     F57-2val[4] = caps(F57-2val[4]).
     F57-2val[5] = caps(F57-2val[5]).
     end.

     if F57-2val[1] eq "" then do:
         bell.
         undo, retry.
     end.
     end. /* do on error */
 end.
 if F57-2L eq "N" then do:
     F57-2val[1] = "NONE".
     F57-2val[2] = "".
     F57-2val[3] = "".
     F57-2val[4] = "".
     F57-2val[5] = "".
 end.
end. /* do on error */
display F57-2val with frame mt202.
pause 0.

/* Field M58 - Account Line */

do on error undo,retry:

update F58-2L validate(F58-2L eq "A" or F58-2L eq "D", "") with  frame mt202.

  if trim(F58-2aval[1]) eq "" then F58-2aval[1] = "/".
  update F58-2aval[1] format "x(34)"
         validate(substr(F58-2aval[1],1,1) eq "/", "")
         with frame mt202.
  F58-2aval[1] = caps(F58-2aval[1]).

  if F58-2L eq "A" then do on error undo, retry :
   update F58-2aval[2] validate(F58-2aval[2] ne "" ,"") format "x(12)"
     with overlay top-only row 17 col 41 no-label title "BIC" frame ff58A.
   F58-2aval[2] = caps(F58-2aval[2]).
   run swiftext(INPUT        F58-2aval[2],
                INPUT        0,
                INPUT-OUTPUT result).
   if result ne 0 then
   do: bell. undo, retry. end.
  end.
  if F58-2L eq "D" then do :
   update F58-2aval[2] format "x(35)" validate(F58-2aval[2] ne "","")
          F58-2aval[3] format "x(35)"
          F58-2aval[4] format "x(35)"
          F58-2aval[5] format "x(35)"
   with overlay top-only row 14 col 41 no-labels
    title "58D:/ Beneficiary institution - ADDRESS"  frame ff58D.
  end.
end. /* do on error */

/* sasco - for RUB */
if remtrz.tcrc <> 4 then
do:
F58-2aval[2] = caps(F58-2aval[2]).
F58-2aval[3] = caps(F58-2aval[3]).
F58-2aval[4] = caps(F58-2aval[4]).
F58-2aval[5] = caps(F58-2aval[5]).
end.

display F58-2aval[1] with frame mt202.
pause 0.

do on error undo,retry:

 F72-2val[1] = remtrz.rcvinfo[1] .
 F72-2val[2] = remtrz.rcvinfo[2] .
 F72-2val[3] = remtrz.rcvinfo[3] .
 F72-2val[4] = remtrz.rcvinfo[4] .
 F72-2val[5] = remtrz.rcvinfo[5] .
 F72-2val[6] = remtrz.rcvinfo[6] .

update      /* O72 - Sender to receivers information */
    F72-2val[1] format "x(35)"
    F72-2val[2] format "x(35)"
    F72-2val[3] format "x(35)"
    F72-2val[4] format "x(35)"
    F72-2val[5] format "x(35)"
    F72-2val[6] format "x(35)"
         with overlay top-only row 13 column 41 no-labels 1 col
         title "Sender to Receiver information"
         frame ff72-2.
end. /* do on error */

/* sasco - for RUB */
if remtrz.tcrc <> 4 then
do:
F72-2val[1] = caps(F72-2val[1]).
F72-2val[2] = caps(F72-2val[2]).
F72-2val[3] = caps(F72-2val[3]).
F72-2val[4] = caps(F72-2val[4]).
F72-2val[5] = caps(F72-2val[5]).
F72-2val[6] = caps(F72-2val[6]).
end.

 remtrz.rcvinfo[1] =  F72-2val[1] .
 remtrz.rcvinfo[2] =  F72-2val[2] .
 remtrz.rcvinfo[3] =  F72-2val[3] .
 remtrz.rcvinfo[4] =  F72-2val[4] .
 remtrz.rcvinfo[5] =  F72-2val[5] .
 remtrz.rcvinfo[6] =  F72-2val[6] .

display F72-2val[1] with frame mt202.
pause 0.

end.
end. /* if domt100 ne "ONE" ... */

end. /* do on error */

if realbic = domt100 then do:
  sw = no.
  bell. Message " Destination MT100 = Destination MT202 ! ".
  pause. leave.
end.

 end.  /* do on error */
