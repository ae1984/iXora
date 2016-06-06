/* ax-jlgens.p
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


/* ax-jlgens.p */

{global.i}
def buffer t-rem for rem.
def buffer b-bank for bank.
def var vdc like glbal.bal.
def var rnew as log initial false.
def shared var s-jh like jh.jh.
def new shared var s-acc like jl.acc.
def new shared var s-aaa like jl.acc.
def new shared var s-gl like gl.gl.
def new shared var s-jl like jl.ln.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def new shared var vcif like cif.cif.
def var vacc like jl.acc.
def var vans as log.
def var vrem like jl.rem.
def var vbal like jl.dam.
def var vdam like vbal.
def var vcam like vbal.

def var vop  as int format "z".
def new shared var vpart as log.
def new shared var vcarry as dec.
define var fv  as cha.
define var inc as int.
define var oldround as log.
def var i as int.
def new shared var rtn as log initial no.

{jhjl.f}

find jh where jh.jh eq s-jh.

main:
repeat:
  pause 0.
  {x-jlvf.i}

  vop = 0.
  {mesg.i 0410} update vop.

  if (jh.post eq true and (vop eq 1 or vop eq 4)) or
     (g-ofc ne "root" and (jh.sts eq 6 and vop = 4))
    then do:
      bell.
      {mesg.i 0224}.
      next.
    end.

  if (g-ofc ne "root" and g-ofc ne jh.who)
     and (vop eq 1 or vop eq 4  )
    then do:
      bell.
      {mesg.i 0602}.
      next.
    end.
  if g-ofc ne "root" and ( (jh.sts eq 6 and vop eq 4)
                     or (jh.sts eq 6 and vop eq 1))
    then do:
      bell.
      {mesg.i 0602}.
      next.
    end.

  if vop = 1 /* Entry */
    then do:
      do transaction on error undo, retry:
/*        update jh.cif with frame party. */
              /*  editing: {gethelp.i} end. {x-jlvf.i}   */
 /*       if jh.cif ne ""
          then do:
            find cif where cif.cif eq jh.cif no-error.
            if avail cif then disp cif.name @ jh.party with frame party.
          end.
        else    update jh.party validate(jh.party ne "","")
                    with frame party.    */
        update jh.crc validate (crc eq 0 or
                                can-find(crc where crc.crc eq jh.crc),
                                "RECORD NOT FOUND.")
                    with frame party.

      end.
      repeat:
        inner:
        do transaction on error undo, retry:
        vpart = true.
        vcarry = 0.
        {x-jltot.i}
        {mesg.i 1805}.
        prompt jl.ln with frame jl
          editing:
            readkey.
            if keyfunction(lastkey) eq "J"
              then do:
                find last jl of jh no-lock no-error.
                if not available jl
                  then display 1 @ jl.ln with frame jl.
                  else display (truncate(jl.ln / 100,0) + 1) * 100 + 1 @ jl.ln
                         with frame jl.
                  leave.
              end.
              else apply lastkey.
          end.
        if input jl.ln eq 0
          then do: /* ln0 */
            find last jl of jh no-lock no-error.
            if not available jl
              then display 1 @ jl.ln with frame jl.
              else display jl.ln + 1 @ jl.ln with frame jl.
          end. /* ln0 */
        else if input jl.ln eq ?
          then do:
            {x-jllis.i}
            undo, retry.
          end.
        s-jl = input jl.ln.
        find jl where jl.jh = jh.jh and
                      jl.ln = input jl.ln no-error.
        if not available jl
          then do: /* newjl */
            {mesg.i 0875}.
            create jl.
            jl.jh = jh.jh.
            assign jl.ln .
            jl.crc = jh.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.rem[1] = vrem[1].
            jl.rem[2] = vrem[2].
            jl.rem[3] = vrem[3].
            jl.rem[4] = vrem[4].
            jl.rem[5] = vrem[5].
            rnew = true.

          end.  /* newjn */

          else do: /* oldjl */
            {mesg.i 0884}.
            find gl of jl no-lock.
            display jl.gl gl.sname jl.acc jl.dam jl.cam
              with frame jl.
            if jl.rem[1] eq "" and
               jl.rem[2] eq "" and
               jl.rem[3] eq "" and
               jl.rem[4] eq "" and
               jl.rem[5] eq ""
              then do:
                jl.rem[1] = vrem[1].
                jl.rem[2] = vrem[2].
                jl.rem[3] = vrem[3].
                jl.rem[4] = vrem[4].
                jl.rem[5] = vrem[5].
              end.
            display jl.rem with frame rem.
            if jl.acc ne ""
              then do:
                {jlupd-f.i -}
              end.
          end. /* old */

        do on error undo, retry:
          update jl.gl
                 jl.crc when jh.crc eq 0
                 with frame jl.
                /* editing: {gethelp.i} end. {x-jlvf.i} */
          find gl of jl no-lock.
          if gl.sts eq 9
            then do:
              bell.
              {mesg.i 1827}.
              undo, retry.
            end.
          find crc where crc.crc eq jl.crc no-lock.
          if crc.sts eq 9
            then do:
              bell.
              {mesg.i 9200}.
              undo, retry.
            end.
        end.
        display gl.sname with frame jl.
        if gl.subled ne ""
          then do on error undo, retry: /* subled */
            /* if jl.acc eq "" then jl.acc = vacc. */
            if gl.subled eq "dfb" then jl.acc = g-defdfb.

            {mesg.i 0914}.
            update jl.acc validate(jl.acc ne "","Need sub-ledger#")
              with frame jl editing:
                readkey.
                if keyfunction(lastkey) eq "GO"
                  then do:
                    find nmbr where nmbr.code = gl.code.
                    {nmbr-acc.i nmbr.prefix
                                nmbr.nmbr
                                nmbr.fmt
                                nmbr.sufix}
                    display vacc @ jl.acc with frame jl.
                    nmbr.nmbr = nmbr.nmbr + 1.
                    leave.
                  end.
                  else apply lastkey.
              end.
            vacc = jl.acc.
            s-jh = jh.jh.
            s-jl = jl.ln.
            s-gl = jl.gl.
            s-acc = jl.acc.
            vcif = jh.cif.
            s-aaa = jl.acc.
            release jl.
            rtn = yes.
            run aaa-aas.
            find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
            no-lock no-error.
            if available aas then do: pause. undo,retry. end.
            run x-jlchk. /* newsubledgers made if required */

            find jl where jl.jh = s-jh and jl.ln = s-jl.
            if rtn = true
            then undo,retry.
            {x-jlvf.i} /* show frame */
          end. /* subled */
        update jl.rem with frame rem.
        vrem[1] = jl.rem[1].
        vrem[2] = jl.rem[2].
        vrem[3] = jl.rem[3].
        vrem[4] = jl.rem[4].
        vrem[5] = jl.rem[5].
        if vpart eq false and vcarry ne 0
          then do:
            jl.dam = 0.
            jl.cam = 0.
            if vcarry gt 0
              then do:
                jl.cam = vcarry.
                jl.dc = "C".
              end.
              else do:
                jl.dam = - vcarry.
                jl.dc = "D".
              end.
            display jl.dam jl.cam with frame jl.
          end.
          else do:
            if jl.dam eq 0 and jl.cam eq 0 and vcarry ne 0
              then do:
                if vcarry gt 0
                 then jl.dam = vcarry.
                 else jl.cam = - vcarry.
              end.
            else if rnew
              then do:
                if vbal > 0 then jl.cam = vbal.
                if vbal < 0 then jl.dam = 0 - vbal.
                rnew = false.
              end.
            display jl.dam jl.cam with frame jl.
            update jl.dam with frame jl.
            if jl.dam ne 0
              then do:
                jl.cam = 0.
                jl.dc = "D".
              end.
              else do:
                update jl.cam with frame jl.
                jl.dc = "C".
              end.
            display jl.dam jl.cam with frame jl.
          end.
        if jl.dam = 0 and jl.cam = 0
          then delete jl.
          else do:
find gl where gl.gl = jl.gl no-lock.
if (gl.sub = "dfb") and ( jl.acc ne "lat210.ls" ) then do:
message " W A I T ... ".
find dfb where dfb.dfb = jl.acc no-lock.
/* pause 0 */ .
 vdc = 0.
for each t-rem where /* t-rem.grp = 2 and */ t-rem.valdt >= g-today
 and t-rem.vjh eq ?  /* and rem.valdt ne ? */ use-index valdt no-lock .
 if t-rem.valdt eq ? then leave.
 find b-bank where b-bank.bank = t-rem.bank no-lock no-error.
 if available b-bank and b-bank.acc = dfb.dfb then do:
   if t-rem.grp = 2 then vdc = vdc + t-rem.payment.
   else if t-rem.grp = 1 and t-rem.valdt = g-today and t-rem.jh = ? then
   vdc = vdc - t-rem.payment.
end.
end.
vdc = vdc - jl.dam + jl.cam .
message dfb.name " Balance: "
dfb.dam[1] - dfb.cam[1] /* format "z,zzz,zzz,zzz,zz9.99-"  */ "-" vdc " = "
 dfb.dam[1] - dfb.cam[1] - vdc /* format "z,zzz,zzz,zzz,zz9.99-" */  .
pause.

if ( dfb.dam[1] - dfb.cam[1] - vdc lt 0 ) and ( jl.dam - jl.cam < 0 ) then do:
 bell . bell .
 message " Balance < 0 ..  Not sufficient fond !!! ".
 pause.
 undo,retry.
end.

end.

            {jlupd-r.i +}
          end.


        /** СТРАШНЫЙ КУСОК ДЛЯ AST ********************************/
        if gl.subled eq "ast" then do on error undo, retry:

            define variable v-asttr like asttr.asttr.
            define variable aga as logical.
            form v-asttr label "TRX KODS" asttr.atdes label "APRAKSTS"
                with frame pvn overlay centered title "PAPILDINFORM…CIJA".

            aga = false.
            if ast.cont eq " " then
                message "Ievest papildinform–ciju ? " update aga.
                if aga then do:
                    update ast.cont label "KATEGORIJA" ast.ser label "KODS"
                        ast.ref label "NOLIET. LIKME"
                        ast.crline label "S…KOTN. VЁRT§BA"
                        ast.ddt[1] label "GADS"
                        with frame addi centered overlay row 13 1 col.
            end.

            if ast.cont ne " " then do:
                create astjl.
                repeat on error undo, retry:
                    update v-asttr
                        validate (can-find (asttr where asttr.asttr eq v-asttr),
                        "Tranzakcijas kods ne eksistё") with frame pvn.

                    find asttr where asttr.asttr eq v-asttr no-lock.
                        if asttr.atdc ne jl.dc then do:
                            message "Tranzakciju pazЁmes (DB/CR) ne sakrЁt".
                            undo, retry.
                        end.
                        else do:
                            display asttr.atdes with frame pvn.
                            leave.
                        end.
                end.

                astjl.ak = ast.cont.
                astjl.atrx = v-asttr.
                astjl.ajh = jl.jh.
                astjl.agl = jl.gl.
                astjl.aast = jl.acc.

                if vcarry eq 0 then
                    astjl.aamt = if jl.dc eq "D" then jl.dam else jl.cam.
                else astjl.aamt = - vcarry.

                if v-asttr eq "2" then ast.icost = ast.icost + astjl.aamt.
                if v-asttr eq "5" then ast.icost = ast.icost - astjl.aamt.
            end.
        end.

        /** ЕГО КОНЕЦ (страшного куска) *************************/

        down 1 with frame jl.

     /*   run chk-wf. */
        {x-jlvf.i}
        end. /* do transaction */
      end. /* inner */
    end. /* 1. Edit */
  else if vop eq 3 /* Print */
    then do transaction:
      hide all.
      run x-jlvou.
      if jh.sts ne 6 then do :
       for each jl of jh :
        jl.sts = 5.
       end.
       jh.sts = 5.
       end.
      {x-jlvf.i}
    end. /* 3. Print */

  else if vop eq 4 /* Delete */
    then do:
      run ax-jlsub22.
      clear frame jl all.
    end. /* 4.Delete */

  else if vop eq 5 /* Stamp */
    then do:
      {mesg.i 6811} update vans.
      if vans
        then do:
          run jl-stmp.
        end.
      {x-jlvf.i}
    end. /* 5.Stamp
*/
  {x-jltot.i}
  if vbal ne 0
    then do:
      bell.
      {mesg.i 0256}.
    end.

/*  for each jl of jh transaction:
    if jl.dam = 0 and jl.cam = 0 then delete jl.
  end.
 */
end. /* main */
