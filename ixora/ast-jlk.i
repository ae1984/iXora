/* ast-jlk.i
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

/* ast-jlk.i kontrole kor.konta  sm. x-jlchk.p*/
def new shared var s-aaa like aaa.aaa.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var v-reg5  as char format "x(13)".

v-kdes="". v-gldes="". /* kor-gl=?. */
displ v-kdes v-gldes kor-gl with frame kor.
/*
if vop=1 then do on endkey undo,next m1 : /* ma: esli bez izveles vop bus */ /* arp */
*/
if vop=1 then do on endkey undo,next ma : /* ma: esli bez izveles vop bus */ /* arp */
   message " Введите номер ARP".
   update kor-acc with frame kor.
   find arp where arp.arp eq kor-acc no-lock no-error.
   if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
   if arp.crc <> 1 then do: bell. {mesg.i 9813}. undo,next. end.
   kor-gl=arp.gl.
   v-kdes=arp.des.
   displ kor-gl v-kdes with frame kor. 
   find gl where gl.gl=kor-gl no-lock no-error.
   if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
   v-gldes=gl.des. displ v-gldes with frame kor.

/*.
   if gl.subled eq "arp" and gl.level eq 1 then do:


    if (arp.dam[1] + (if vidop<>"D" then v-sum else 0) lt
        arp.cam[1] + (if vidop ="D" then v-sum else 0) and gl.type eq "A" or
        arp.cam[1] + (if vidop<>"D" then v-sum else 0) lt 
        arp.dam[1] + (if vidop ="D" then v-sum else 0) and gl.type eq "L") then
    do:
     bell. message " ARP карточки остаток : " +
                string(arp.dam[1] - arp.cam[1],"zzz,zzz,zzz,zz9.99").
     pause 10. undo, next.
    end.
   end.
.*/

end.
else if vop=2 then do on endkey undo,next m1:
    find sysc where sysc.sysc eq "cashgl" no-lock no-error.
     kor-acc="".
     kor-gl=sysc.inval.
     find first gl where gl.gl=kor-gl no-lock no-error.
     if not avail gl then do: bell. {mesg.i 2203}. undo,next. end.
     else  displ kor-gl v-gldes kor-acc with frame kor.

end.
else if vop=3 then do on endkey undo,next m1:
      update kor-acc with frame kor.
      find aaa where aaa.aaa = kor-acc no-lock no-error. /* new */
      if not available aaa then do:
        bell. {mesg.i 2203}. undo,retry.
      end.
      else find lgr where lgr.lgr = aaa.lgr and lgr.led = 'ODA' no-lock no-error.
      if avail lgr then do:
        bell. message ' Счет   ODA '. undo,retry.
      end.
      else kor-gl = aaa.gl.
           s-aaa = kor-acc.
           run aaa-aas.
           find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
           no-lock no-error.
           if available aas then do: pause. undo,retry. end.
    
      if aaa.crc ne 1 then do:
         bell. {mesg.i 9813}. undo,retry.
      end.
      if aaa.sta eq "C" then do:
         bell. {mesg.i 6207}. undo,retry.
      end.
        find cif of aaa no-lock no-error.
        v-kdes = trim(trim(cif.prefix) + " " + trim(cif.name)).
        tt1 = substring(v-kdes,1,60).
        tt2 = substring(v-kdes,61,60).
        v-reg5 = trim(substr(cif.jss,1,13)).
        v-arem[3]=v-arem[2] + 'Re¦.' + v-reg5 + v-kdes.
        v-arem[2]=substring(trim(v-arem[3]),1,55).
        v-arem[3]=substring(trim(v-arem[3]),56,55).  
        disp kor-gl v-kdes v-arem[2] v-arem[3] with frame kor.
        pause 0.

        form bila
           tt1 label "ПОЛНОЕ ----"
           tt2 label "--НАЗВАНИЕ "
           cif.lname  label "КОРОТКОЕ   " format "x(60)"
           cif.pss   label "ИДЕНТ.КАРТА"
           cif.jss   label "РЕГ.НОМЕР "  format "x(13)"
           with overlay  1 column row 13 column 1 frame ggg.
      if aaa.craccnt ne "" then
        find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error .
      if available xaaa then do:
       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
       disp  bila tt1 tt2  cif.lname cif.pss cif.jss with frame ggg.
       pause .
      end.
      else do:
       bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal  .
       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
       pause .
      end.

end.
else if vop=4 then do on endkey undo,next m1:  /* gl.gr–m */
     kor-acc="".
     update kor-gl with frame kor.
     find first gl where gl.gl=kor-gl no-lock no-error.
      if not available gl then do: bell. {mesg.i 2203}. undo,next. end.
      if gl.crc <> 1 then do: bell. {mesg.i 9813}. undo,next. end.
      if gl.sts eq 9 or gl.subled ne "" then do: bell. {mesg.i 1827}. undo,next. end.
      displ kor-gl v-gldes kor-acc with frame kor.

end.
else if vop=5 then do on endkey undo,next m1:  /* EPS */
      update kor-acc with frame kor.
      find eps where eps.eps = kor-acc no-lock no-error.
      if not available eps then do:
         bell. {mesg.i 2203}. undo,retry.
      end.
      v-kdes =eps.ref. 
      kor-gl = eps.gl.
      if eps.crc ne 1 then do:
         bell. {mesg.i 9813}. undo,retry.
      end.
     find gl where gl.gl=kor-gl no-lock no-error.
     if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
     v-gldes=gl.des. 
     disp kor-gl v-kdes kor-acc v-gldes with frame kor.
end.

