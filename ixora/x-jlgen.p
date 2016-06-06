/* x-jlgen.p
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

/* x-jlgen.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/
{global.i}
def shared var s-jh like jh.jh.
def new shared var s-acc like jl.acc.
def new shared var s-gl like gl.gl.
def new shared var s-jl like jl.ln.
def new shared var s-aah  as int.
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
def var vpart as log.
def var vcarry as dec.
define var fv  as cha.
define var inc as int.
define var oldround as log.
def var i as int.

{jhjl.f}

find jh where jh.jh eq s-jh.

main:
repeat:
  pause 0.
  {x-jlvf.i}

  vop = 0.
  {mesg.i 0410} update vop.

  if jh.post eq true and (vop eq 1 or vop eq 4)
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
  if g-ofc ne "root" and ((jh.sts eq 4 and vop eq 4)
                       or (jh.sts eq 5 and vop eq 5))
    then do:
      bell.
      {mesg.i 0602}.
      next.
    end.

  if vop = 1 /* Entry */
    then do:
      do transaction on error undo, retry:
        update jh.cif with frame party.
              /*  editing: {gethelp.i} end. {x-jlvf.i}   */
        if jh.cif ne ""
          then do:
            find cif where cif.cif eq jh.cif.
            display trim(trim(cif.prefix) + " " + trim(cif.name)) @ jh.party with frame party.
          end.
        else    update jh.party validate(jh.party ne "","")
                    with frame party.
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
        end.
        display gl.sname with frame jl.
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
            else if new jl
              then do:
                if vbal > 0 then jl.cam = vbal.
                if vbal < 0 then jl.dam = 0 - vbal.
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
        down with frame jl.
        run chk-wf.
        {x-jlvf.i}
        end. /* do transaction */
      end. /* inner */
    end. /* 1. Edit */
 /*
  else if vop eq 2 /* List */
    then do:
      {x-jllis.i}
    end. /* list */
 */
  else if vop eq 3 /* Print */
    then do transaction:
    /*
      {x-jltot.i}
      if vbal ne 0
        then do:
          bell. bell. bell. bell.
          {mesg.i 0256}.
          if userid('bank') ne "root"
            then undo, retry.
        end.

      for each jl of jh :
        if jl.dam = 0 and jl.cam = 0
          then delete jl.
      end. */
      hide all.
      run x-jlvou1.
      jh.sts = 4.
      {x-jlvf.i}
    end. /* 3. Print */

  else if vop eq 4 /* Delete */
    then do:
      run x-jldel.
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
