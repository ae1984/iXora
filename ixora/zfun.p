/* zfun.p
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
       05/11/03 nataly был добавлен пп HISTORY  где показывается 
                история начисления %% по МБД
       15.12.03 nataly добавлена возможность просмотра остатков на уровнях
       15.01.04 nataly при просмотре и редактировании для сделок РЕПО 
                не показыавется значение fun.bank.
*/

/* zfun.p
   редактирование межбанковских сделок
   изменения от 13.10.2000 (новый zfun.f) */

   
{mainhead.i MMFILE}  /*  FUND MAINTENANCE  */

def var ans as log.
def var cmd as cha format "x(7)" extent 6
    initial ["NEXT","EDIT","DELETE","LEVEL","HISTORY","QUIT"].
def new shared var s-fun like fun.fun.

def var vnew as log.
def var v-weekbeg as int.
def var v-weekend as int.
define variable v-klmbd as integer.
define variable kl-n as character.
define variable ndn-s as decimal.
define variable ndf-s as decimal.
define variable scn-s as decimal.
define variable scf-s as decimal.
define variable dkav  as decimal.
define variable ckav  as decimal.
define variable dblok as decimal.
define variable cblok as decimal.
define variable sm1 as decimal.
define variable sm2 as decimal.
define variable v-crc like crc.crc.
define variable c-gl as character.
define variable c-bank as character.
def var v-maturedt as date.
def var v-grp as char.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


{zfun.f}

view frame fun.
view frame slct.
                                
                                                                
find sysc where sysc.sysc = 'repogr' no-lock no-error.
if avail sysc then v-grp = sysc.chval.
                                                                            
                                                                
outer:
repeat:
  vnew = false.
  prompt-for fun.fun with frame fun.
  find fun using fun.fun no-error.
  if not available fun
  then do:
       message "Создать новую сделку ?" update ans.
       if ans eq false 
       then next.
       create fun.
       assign fun.fun.
       fun.zalog = no.
       fun.who   = g-ofc.
       fun.rdt   = g-today.
       {subadd-pc.i  &sub = "fun"}
       vnew = true.
    end. 
    s-fun = fun.fun.
    find deal where deal.deal = fun.fun no-lock.
    v-maturedt = deal.maturedt.
    find fungrp where fungrp.fungrp = fun.grp no-lock no-error.
    if available fungrp
    then do:
         fun.gl = fungrp.gl.
         find gl where gl.gl = fun.gl no-lock.
         c-gl = string(gl.gl) + " " + gl.des.
    end.
    else c-gl = "".
    find bankl where bankl.bank = fun.bank no-error.
    if available bankl
    then c-bank = bankl.name.
    else c-bank = "".

    if fun.interest > 0 
    then fun.basedy = fun.amt * fun.trm *
                      fun.intrate / fun.interest / 100.
    find sub-cod where sub-cod.sub = "FUN" and sub-cod.acc = fun.fun and 
         sub-cod.d-cod = "klmbd" exclusive-lock no-error.
    if available sub-cod
    then v-klmbd = integer(sub-cod.ccode).
    else v-klmbd = 0.
    find codfr where codfr.codfr = "klmbd" and 
         codfr.code = string(v-klmbd,"999") no-lock.
    kl-n = codfr.name[1].
    ndn-s = round(v-klmbd * (fun.dam[1] - fun.cam[1]) / 100,2).
    find trxbal where trxbal.subled =  "FUN" and trxbal.acc = fun.fun and 
         trxbal.level = 3 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then ndf-s = trxbal.cam - trxbal.dam.
    else ndf-s = 0.
    sm1 = ndf-s.
 
    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 6 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then scf-s = trxbal.dam - trxbal.cam.
    else scf-s = 0.
    sm2 = scf-s.
    scn-s = fun.amt.

    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 4 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then do:
         dkav = trxbal.dam.
         ckav = trxbal.cam.
    end.
    else do:
         dkav = 0.
         ckav = 0.
    end.     

    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 5 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then do:
         dblok = trxbal.dam.
         cblok = trxbal.cam.
    end.
    else do:
         dblok = 0.
         cblok = 0.
    end.
  /* не счет РЕПО*/
    if lookup(string(fun.grp), v-grp) = 0 then
     display fun.crc
            fun.basedy
            c-gl
            fun.grp
            fun.bank
            fun.cst 
            fun.amt
            fun.rdt
            fun.duedt
            v-maturedt
            fun.trm
            fun.intrate
            fun.interest
            fun.itype
            fun.rem
            fun.dam[1] 
            fun.cam[1]
            fun.dam[2]
            fun.cam[2]
            dkav
            ckav 
            dblok
            cblok
            scn-s
            scf-s
            v-klmbd
            kl-n
            ndn-s
            ndf-s
            with frame fun.
       else 
     display fun.crc
            fun.basedy
            c-gl
            fun.grp
           /* fun.bank*/
            fun.cst 
            fun.amt
            fun.rdt
            fun.duedt
            v-maturedt
            fun.trm
            fun.intrate
            fun.interest
            fun.itype
            fun.rem
            fun.dam[1] 
            fun.cam[1]
            fun.dam[2]
            fun.cam[2]
            dkav
            ckav 
            dblok
            cblok
            scn-s
            scf-s
            v-klmbd
            kl-n
            ndn-s
            ndf-s
            with frame fun.

    display cmd auto-return with frame slct.

    inner:
    repeat:
       if not vnew 
       then do:
            choose field cmd with frame slct.
       end.
     /*05/11/03 nataly*/
       if frame-value eq "HISTORY"
       then do:
        find gl where gl.gl = fun.gl no-lock no-error.
       if gl.type = 'A' then
        run histfunA(fun.fun).
       else  run histfunP(fun.fun).
       end.
     /*05/11/03 nataly*/
     /*15.12.03 nataly*/
       if frame-value eq "LEVEL"
       then do:
         run s-funamt.
         display fun.crc
            fun.basedy
            c-gl
            fun.grp
            fun.bank
            fun.cst 
            fun.amt
            fun.rdt
            fun.duedt
            v-maturedt
            fun.trm
            fun.intrate
            fun.interest
            fun.itype
            fun.rem
            fun.dam[1] 
            fun.cam[1]
            fun.dam[2]
            fun.cam[2]
            dkav
            ckav 
            dblok
            cblok
            scn-s
            scf-s
            v-klmbd
            kl-n
            ndn-s
            ndf-s
            with frame fun.

        display cmd auto-return with frame slct.
       end.
     /*15.12.03 nataly*/
       if frame-value eq "EDIT" or vnew eq true 
       then do with frame fun:
            vnew = false.

            update fun.grp with frame fun.
            if frame fun fun.grp entered
            then do:
                 find fungrp where fungrp.fungrp = fun.grp no-lock no-error.
                 if not available fungrp
                 then undo,retry.
                 fun.gl = fungrp.gl.
                 find gl where gl.gl = fun.gl no-lock.
                 c-gl = string(fun.gl) + " " + gl.des.
                 display c-gl with frame fun.
            end. 
            
            v-crc = 0.
            for each trxbal where trxbal.subled = "FUN" and 
                trxbal.acc = fun.fun  and trxbal.level <= 5 and
                (trxbal.dam > 0 or trxbal.cam > 0) no-lock:
                if trxbal.crc > 0
                then v-crc = trxbal.crc.
                if v-crc > 0
                then leave.
            end.
            if v-crc = 0
            then update fun.crc with frame fun.
            if frame fun fun.crc entered
            then do:
                 for each trxbal where trxbal.subled = "FUN" and
                     trxbal.acc = fun.fun and trxbal.level <= 5 exclusive-lock:
                     trxbal.crc = fun.crc.
                 end.
            end.     

            update fun.basedy with frame fun.
            if frame fun fun.basedy entered
            then do:
                 fun.interest = round(fun.amt * fun.trm *
                                fun.intrate / fun.basedy / 100,2).
                 display fun.interest with frame fun.
            end.     
          if lookup(string(fun.grp), v-grp) = 0 then
            update fun.bank
                   validate(bank eq "" or
                       can-find(bankl where bankl.bank eq bank),"")
            with frame fun.
            if frame fun fun.bank entered
            then do:
                 find bankl where bankl.bank = fun.bank no-lock.
                 fun.cst = bankl.name.
                 display fun.cst with frame fun. 
            end.     
            update fun.amt
                   fun.rdt
                   fun.duedt
            with frame fun.
            if frame fun fun.amt entered or
               frame fun fun.rdt entered or
               frame fun fun.duedt entered 
            then do:
                 repeat:
                    find hol where hol.hol eq fun.duedt no-error.
                    if not available hol and
                       weekday(fun.duedt) ge v-weekbeg and
                       weekday(fun.duedt) le v-weekend
                    then leave.
                    else fun.duedt = fun.duedt + 1.
                 end.
                 fun.trm = fun.duedt - fun.rdt.
                 fun.interest = round(fun.amt * fun.trm *
                                fun.intrate / fun.basedy / 100,2).
                 scn-s = fun.amt.
                 display fun.duedt fun.interest scn-s with frame fun.
            end.     
            find gl where gl.gl eq fun.gl no-lock.

            display fun.trm fun.duedt fun.iddt with frame fun.
 
            update fun.itype fun.intrate with frame fun.
 
            if frame fun fun.intrate entered
            then do:
                 fun.interest = round(fun.amt * fun.trm *
                                fun.intrate / fun.basedy / 100,2).
                 display fun.interest with frame fun.
            end.             
            update fun.rem with frame fun.
            find crc of fun.
       
            /* append then edit /
            update fun.geo
                   fun.zalog
                   fun.lonsec  
                   fun.risk   
                   fun.penny
            with frame fun.
            display fun.ncrc[3]
                    fun.dam[3]
                    fun.cam[3]
            with frame fun. */
                  
            update fun.dam[1] 
                   fun.cam[1]
                   fun.dam[2] 
                   fun.cam[2]
            with frame fun.
            if frame fun fun.dam[1] entered or
               frame fun fun.cam[1] entered
            then do:
                 find trxbal where trxbal.subled = "FUN" and
                      trxbal.acc = fun.fun and trxbal.level = 1 and
                      trxbal.crc = fun.crc exclusive-lock no-error.
                 if not available trxbal
                 then do:
                      create trxbal.
                      trxbal.subled = "FUN".
                      trxbal.crc = fun.crc.
                      trxbal.acc = fun.fun.
                      trxbal.level = 1.
                 end.
                 trxbal.gl = fun.gl.
                 trxbal.dam = fun.dam[1].
                 trxbal.cam = fun.cam[1].
                 ndn-s = round(integer(v-klmbd) * 
                         (fun.dam[1] - fun.cam[1]) / 100,2).
                 display ndn-s with frame fun. 
            end.
            if frame fun fun.dam[2] entered or
               frame fun fun.cam[2] entered
            then do:
                 find trxbal where trxbal.subled = "FUN" and
                      trxbal.acc = fun.fun and trxbal.level = 2 and
                      trxbal.crc = fun.crc exclusive-lock no-error.
                 if not available trxbal
                 then do:
                      create trxbal.
                      trxbal.subled = "FUN".
                      trxbal.crc = fun.crc.
                      trxbal.acc = fun.fun.
                      trxbal.level = 2.
                 end.
                 find trxlevgl where trxlevgl.gl = fun.gl and 
                      trxlevgl.subled = "FUN" and trxlevgl.level = 2 no-lock.
                 trxbal.gl = trxlevgl.glr.
                 trxbal.dam = fun.dam[2].
                 trxbal.cam = fun.cam[2].
            end.
            if gl.type = "A"
            then do:
                 update dkav with frame fun.
                 update ckav with frame fun.
                 if frame fun dkav entered or
                    frame fun ckav entered
                 then do:
                      find trxbal where trxbal.subled = "FUN" and
                           trxbal.acc = fun.fun and trxbal.level = 4 and
                           trxbal.crc = fun.crc exclusive-lock no-error.
                      if not available trxbal
                      then do:
                           create trxbal.
                           trxbal.subled = "FUN".
                           trxbal.crc = fun.crc.
                           trxbal.acc = fun.fun.
                           trxbal.level = 4.
                      end.
                      find trxlevgl where trxlevgl.gl = fun.gl and 
                           trxlevgl.subled = "FUN" and 
                           trxlevgl.level = 4 no-lock.
                      trxbal.gl = trxlevgl.glr.
                      trxbal.dam = dkav.
                      trxbal.cam = ckav.
                      fun.dam[4] = dkav.
                      fun.cam[4] = ckav.
                 end.
            
                 update dblok with frame fun.
                 update cblok with frame fun.
                 if frame fun dblok entered or
                    frame fun cblok entered
                 then do:
                      find trxbal where trxbal.subled = "FUN" and
                           trxbal.acc = fun.fun and trxbal.level = 5 and
                           trxbal.crc = fun.crc exclusive-lock no-error.
                      if not available trxbal
                      then do:
                           create trxbal.
                           trxbal.subled = "FUN".
                           trxbal.crc = fun.crc.
                           trxbal.acc = fun.fun.
                           trxbal.level = 5.
                      end.
                      find trxlevgl where trxlevgl.gl = fun.gl and 
                           trxlevgl.subled = "FUN" and 
                           trxlevgl.level = 5 no-lock.
                      trxbal.gl = trxlevgl.glr.
                      trxbal.dam = dblok.
                      trxbal.cam = cblok.
                      fun.dam[5] = dblok.
                      fun.cam[5] = cblok.
                 end.
            end.

            update scf-s v-klmbd ndf-s with frame fun.
            if frame fun v-klmbd entered
            then do:
                 find codfr where codfr.codfr = "klmbd" and 
                      codfr.code = string(v-klmbd,"999") no-lock no-error.
                 if not available codfr
                 then undo,retry.
                 kl-n = codfr.name[1].
                 ndn-s = round(integer(v-klmbd) * 
                         (fun.dam[1] - fun.cam[1]) / 100,2).
                 display kl-n ndn-s with frame fun.
                 find sub-cod where sub-cod.sub = "FUN" and 
                      sub-cod.acc = fun.fun and sub-cod.d-cod = "klmbd" 
                      exclusive-lock no-error.
                 if available sub-cod
                 then.
                 else do:
                      create sub-cod.
                      sub-cod.sub = "FUN".
                      sub-cod.acc = fun.fun.
                      sub-cod.d-cod = "klmbd".
                 end.
                 sub-cod.ccode = string(v-klmbd,"999").
            end.     
            if frame fun scf-s entered 
            then do:
                 find trxbal where trxbal.subled = "FUN" and
                      trxbal.acc = fun.fun and trxbal.level = 6 and
                      trxbal.crc = fun.crc exclusive-lock no-error.
                 if not available trxbal
                 then do:
                      create trxbal.
                      trxbal.subled = "FUN".
                      trxbal.crc = fun.crc.
                      trxbal.acc = fun.fun.
                      trxbal.level = 6.
                 end.
                 find trxlevgl where trxlevgl.gl = fun.gl and 
                      trxlevgl.subled = "FUN" and trxlevgl.level = trxbal.level                       no-lock.
                 trxbal.gl = trxlevgl.glr.
                 trxbal.dam = scf-s.
                 trxbal.cam = 0.
            end.
            if frame fun ndf-s entered 
            then do:
                 find trxbal where trxbal.subled = "FUN" and
                      trxbal.acc = fun.fun and trxbal.level = 3 and
                      trxbal.crc = fun.crc exclusive-lock no-error.
                 if not available trxbal
                 then do:
                      create trxbal.
                      trxbal.subled = "FUN".
                      trxbal.crc = fun.crc.
                      trxbal.acc = fun.fun.
                      trxbal.level = 3.
                 end.
                 find trxlevgl where trxlevgl.gl = fun.gl and 
                      trxlevgl.subled = "FUN" and trxlevgl.level = trxbal.level                       no-lock.
                 trxbal.gl = trxlevgl.glr.
                 trxbal.dam = 0.
                 trxbal.cam = ndf-s.
            end.
        
             
       end.

       else if frame-value eq "QUIT" 
       then return.
       else if frame-value eq "DELETE "
       then do:
            message "Удалить запись ?" update ans.
            if ans eq false 
            then next.
            find first jl where jl.acc = fun.fun no-lock no-error.
            if not available jl and
               fun.dam[1] = 0 and
               fun.cam[1] = 0 and
               fun.dam[2] = 0 and
               fun.cam[2] = 0 and
               fun.dam[3] = 0 and
               fun.cam[3] = 0 and 
               scf-s = 0 and
               ndf-s = 0
            then delete fun.
            else do : 
                 message "Запись не пустая и не может быть удалена !!! ". 
                 pause.
            end.
            pause.
            next outer.
       end.
       else if frame-value eq "NEXT"
       then do:
            clear frame fun.
            next outer.
       end.
    end. /* inner */
    clear frame fun.
    hide  frame slct.
  end. /* outer */

