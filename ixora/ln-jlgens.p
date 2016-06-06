/* ln-jlgens.p
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

{global.i}
def shared var s-lon like lon.lon.
def buffer t-rem for rem.
def buffer b-bank for bank.
def var vdc like glbal.bal.
def var rnew as log initial false.
def shared var s-jh like jh.jh.
def new shared var s-acc like jl.acc.
def new shared var s-gl like gl.gl.
def shared var s-jl like jl.ln.
def new shared var s-aah  as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def new shared var vcif like cif.cif.
def var vacc like jl.acc.
def shared var vans as log.
def var vans1 as log.
def var vrem like jl.rem.
def var vbal like jl.dam.

def new shared var vpart   as log.
def new shared var vcarry  as dec.
define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define new shared variable rc as integer.
define variable v-gl-avn     like gl.gl.
define variable v-gl-noform  like gl.gl.
define variable v-gl-atalg   like gl.gl.
define variable v-gl-depo    like gl.gl.
define variable varp         like arp.arp.

define var fv  as cha.
define var inc as int.
define var oldround as log.
def var i as int.
def new shared var rtn as log.
def var vln like jl.ln.
def var vop as inte.
def shared var s-consol like jh.consol.
def var vdam like jl.dam.
def var vcam like jl.cam.
def buffer b for jl.
define variable rcd as logical.
define variable v-rmz as character.

define variable aMessage as character.
aMessage = "Вы не можете проводить операции с этим счетом в главной книге !".

find jh where jh.jh eq s-jh.
find lon where lon.lon eq s-lon no-lock no-error.
if available lon then do:
   run f-longl(lon.gl,"gl-noform,gl-atalg,gl-depo",output ok). 
   if not ok
   then do:
        bell.
        message lon.lon " - ln-jlgens:" 
             "longl nav definёti konti".
        pause.
        return.
   end.
   else do:
      v-gl-noform = s-longl[1].
      v-gl-atalg  = s-longl[2].
      v-gl-depo   = s-longl[3].
   end.
   find first arp where arp.arp = "44" + string(lon.crc) + "LIZ" no-lock no-error.
   if available arp
   then do:
      v-gl-avn = arp.gl.
      varp     = arp.arp.
   end.
end.   

{jhjl.f}

vop = lastkey.

  if jh.post eq true and (vop eq 52 or vop = 49 or vop = 13 or vop = 502)
    then do:
      bell.
      {mesg.i 0224}.
      return.
    end.
  if (g-ofc ne "root" and g-ofc ne jh.who)
     and  (vop eq 52 or vop = 49 or vop = 13 or vop = 502)
    then do:
      bell.
      {mesg.i 0602}.
      return.
    end.
  if g-ofc ne "root" and ((jh.sts = 6 or jh.sts = 5)
                           and (vop = 52 or vop = 49 or vop = 13 or vop = 502))
    then do:
      bell.
      {mesg.i 0602}.
      return.
    end.
{x-jltot.i}
if vop = 13 or vop = 502 then do:
   pause 0.
   {x-jlvf.i}
upper13: 
do transaction on error undo, retry:
         find jl of jh where jl.ln = s-jl.
         if vop = 502 then do:
            rnew = true.
            find prev jl of jh no-error.
            if available jl then do:
               vrem[1] = jl.rem[1].
               vrem[2] = jl.rem[2].
               vrem[3] = jl.rem[3].
               vrem[4] = jl.rem[4].
            end.
            find jl of jh where jl.ln = s-jl.
            {mesg.i 0875}.
            jl.crc = jh.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.rem[1] = vrem[1].
            jl.rem[2] = vrem[2].
            jl.rem[3] = vrem[3].
            jl.rem[4] = vrem[4].
            rnew = true.
         end.  /* newjl */
         else do: /* oldjl */
            {mesg.i 0884}.
            find gl of jl no-lock no-error.
            if available gl then display jl.gl gl.sname jl.acc jl.dam jl.cam
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

            disp jl.ln with frame jl.
            display jl.rem with frame rem.
            /* if jl.acc ne ""
              then do:  */
                
                {jlupd-f.i -}
            /*  end. */
         end. /* old */
         do on error undo, retry:
            update jl.gl
                   jl.crc when jh.crc eq 0
                   with frame jl.
            if frame jl jl.gl entered
            then do:
               find sysc where sysc.sysc = "RMPY1G" no-lock no-error.
               if available sysc
               then do:
                    if jl.gl = sysc.inval
                    then do:
                         bell.
                         message "Операция с этим счетом не разрешена !".
                         pause.
                         undo,retry.
                    end.
               end.
            end.
            
            /******** DARBS AR Lizingu aizslegts *********************/
            if jl.gl = v-gl-noform or jl.gl = v-gl-atalg or
               (v-gl-depo <> v-gl-avn and jl.gl = v-gl-depo) then do:
               bell.
               message aMessage.
               pause.
               undo upper13, retry upper13.
            end.
            /*****************************/
            
            find gl of jl no-lock.
            if gl.sts eq 9
            then do:
               bell.
               {mesg.i 1827}.
               undo, retry.
            end.
         
            /*****************************/
            if gl.subled eq "ast" then do:
               bell.
               message "Работа с основными средствами запрещена!".
               undo, retry.
            end.
            /*****************************/
          
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
            end. /* editing */

            /******** DARBS AR 441LIZ aizslegts *********************/
            if jl.acc = varp then do:
               bell.
               message aMessage.
               pause.
               undo upper13, retry upper13.
            end.
            /*****************************/

            vacc = jl.acc.
            s-jh = jh.jh.
            s-jl = jl.ln.
            s-gl = jl.gl.
            s-acc = jl.acc.
            vcif = jh.cif.
            release jl.
            rtn = true.
            run lnx-jlchk. /* newsubledgers made if required */
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
 vdc = 0.
for each t-rem where /* t-rem.grp = 2 and */ t-rem.valdt >= g-today
 and t-rem.vjh eq ?  /* and rem.valdt ne ? */ use-index valdt no-lock .
 if t-rem.valdt eq ? then leave.
 find b-bank where b-bank.bank = t-rem.bank no-lock no-error.
 if available b-bank and b-bank.acc = dfb.dfb then do:
   if t-rem.grp = 2 then vdc = vdc + t-rem.payment.
   else if t-rem.grp = 1 and t-rem.valdt = g-today and t-rem.jh = ?
   then
   vdc = vdc - t-rem.payment.
end.
end.
vdc = vdc - jl.dam + jl.cam .
message dfb.name " Баланс: "
dfb.dam[1] - dfb.cam[1]  "-" vdc " = "
 dfb.dam[1] - dfb.cam[1] - vdc.
pause.

if ( dfb.dam[1] - dfb.cam[1] - vdc lt 0 ) and ( jl.dam - jl.cam < 0 ) then do:
 bell . bell .
 message " Баланс < 0 ..  !!! ".
 pause.
 undo,retry.
end.
end.


{jlupd-r.i +}
end.
end. /*do transaction*/
{x-jltot.i}
end. /*vop = 13 and vop = 502*/

else if vop = 404 then do:
  {x-jltot.i}
  if vbal <> 0 then do:
   bell.
   vans = true.
   {mesg.i 0421} update vans.
   if not vans then do:
     {mesg.i 0255}. pause 1.
   end.   
  end.
end.
else if vop = 49 then do transaction:
        update jh.crc validate (crc eq 0 or
                                can-find(crc where crc.crc eq jh.crc),
                                "RECORD NOT FOUND.")
                    with frame party.
end.

else if vop eq 51 /* Print */
    then do transaction:
      run x-jlvou.
      if jh.sts ne 6 then do :
       for each jl of jh :
        jl.sts = 5.
       end.
       jh.sts = 5.
      end.
  end. /* 3. Print */

  else if vop eq 52 /* Delete */
    then do transaction:
         if jh.sts >= 6
         then do:
              bell.
              message "Статус 6 !!!".
              pause.
              undo,retry.
         end.
         if substring(jh.party,1,3) = " FX"
         then do:
              find fexp where fexp.fex = substring(jh.party,2,10) no-error.
              if available fexp
              then do:
                   if fexp.type = 8 and fexp.jh = jh.jh
                   then delete fexp.
              end.
         end.
         if substring(jh.party,2,3)  = "RMZ" or
            substring(jh.party,13,3) = "RMZ" or 
            substring(jh.party,1,3) = "RMZ" or
            substring(jh.party,12,3) = "RMZ"
         then do:
            if substring(jh.party,2,3) = "RMZ"
            then v-rmz = substring(jh.party,2,10).
            else if substring(jh.party,13,3) = "RMZ"
            then v-rmz = substring(jh.party,13,10). 
            else if substring(jh.party,1,3) = "RMZ"
            then v-rmz = substring(jh.party,1,10).
            else v-rmz= substring(jh.party,12,10).
            find remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
            if available remtrz
            then do:
                 if remtrz.source = "LON"
                 then do:
                      if remtrz.jh2 <> 0 and remtrz.jh2 <> ?
                      then do:
                           message "Выполнена 2. транзакция " remtrz.jh2.
                           pause.
                           undo,retry.
                      end.
                      find que where que.remtrz = v-rmz exclusive-lock.
                      que.pid = "D".
                      remtrz.jh1 = ?.
                 end.
                 else do:
                      run chklonps(v-rmz,"LON",output rcd).
                      if not rcd
                      then do:
                           run longo2L(v-rmz,"LON",output rcd).
                      end.
                      if not rcd
                      then do:
                           bell.
                           message "Транзакция не удалена !".
                           pause.
                           undo,retry.
                      end.
                 end.
            end.
         end.
         run x-jlsub22.
         find first jl of jh no-error.
         if not available jl then clear frame jl all.
    end. /* 4.Delete */

  else if vop eq 53 /* Stamp */
    then do transaction:
      find sysc where sysc.sysc = "cashgl" no-lock no-error.
      find first jl of jh use-index jhln where jl.gl = sysc.inval 
        no-lock no-error.
      if available jl then do:
        bell.
        {mesg.i 420}. pause.
        return.
      end.
      else do:
           {mesg.i 6811} update vans1.
           if vans1
           then do:
                if jh.sts >= 6
                then do:
                     bell.
                     message "Транзакция отштампована !".
                     pause.
                     undo,retry.
                end.
                if substring(jh.party,2,3)  = "RMZ" or 
                   substring(jh.party,13,3) = "RMZ"
                then do:
                     if substring(jh.party,2,3) = "RMZ"
                     then v-rmz = substring(jh.party,2,10).
                     else v-rmz = substring(jh.party,13,10).
                     find remtrz where remtrz.remtrz = v-rmz no-lock no-error.
                     rcd = available remtrz.
                     if rcd
                     then do:
                          find first que where que.remtrz = v-rmz 
                               no-lock no-error.
                          if available que 
                          then do:
                               if remtrz.jh2 = s-jh and que.pid = "F"
                               then rcd = true.
                               else do:
                                    run longoF(v-rmz,"LON",jh.jh,output rcd).
                               end.
                          end.
                     end.
                     if not rcd
                     then do:
                          bell.
                          message "В операции не найден перевод !".
                          pause.
                          undo,return.
                     end.
                end.
                run jl-stmp.
           end.
      end.
   end. /* 5.Stamp*/


