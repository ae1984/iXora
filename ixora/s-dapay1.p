/* s-dapay1.p
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

/* s-dapay1.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

def shared var s-bank like dadp.bank.
def shared var s-dadp like dadp.dadp.
def shared frame dadp.
def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def new shared var s-aah as int.
def new shared var s-grp      like dadp.grp.
def new shared var s-type     like dadp.type.
def new shared var s-gl       like dpay.gl.
def new shared var s-drft     like dpay.drft.
def new shared var s-payamt   like dpay.payamt.
def new shared var s-adt      like dadp.adt.
def new shared var s-ddt      like dadp.ddt.
def new shared var s-trm      like dadp.trm.
def new shared var s-name     like bank.name.
def new shared var s-rdt      like dadp.rdt.
def new shared var s-amt      like dadp.amt.
def new shared var s-bal      like dadp.bal.
def new shared var s-caccr    like dadp.caccr.
def new shared var s-crcvd    like dadp.crcvd.
def new shared var s-detail   like dadp.detail.
def new shared var s-pcnt     like dadp.pcnt.
def new shared var s-cif      like dadp.cif.
def new shared var s-party    like dadp.party.
def new shared var s-pacct    like dpay.pacct.
def new shared var s-acc      like jl.acc.
def new shared var s-vgl      like jl.gl.

def var vpdt as date.
def var ans as log.
def var vans as log.

def buffer b-dpay for dpay.
def buffer c-dpay for dpay.
def buffer c-bank for bank.

def var vcdaval as dec.
def var vcdpval as dec.
def var vcapval as dec.
def var vdefdfb as cha.
def var vdagl as int.
def var vdpgl as int.
def var vapgl as int.
def var vdfbgl as int.
def new shared var vvgl like gl.gl.
def new shared var vvamt as dec format "zz,zz9.99-".
def var vvans as log init false.
def var vvdes like gl.des.
/*
form vvgl label "COMM G/L#"
     vvdes
     vvamt label "AMOUNT"
     with row 7 centered frame dadpnew.
*/
  /* assign comm for da/dp */
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.
  find sysc where sysc.sysc eq "CDAGL". vcdaval = sysc.deval.
  find sysc where sysc.sysc eq "CDPGL". vcdpval = sysc.deval.
  find sysc where sysc.sysc eq "CAPGL". vcapval = sysc.deval.
  /* assign dfb code and g/l# for da/dp */
  find sysc where sysc.sysc eq "DEFDFB".
       vdefdfb = sysc.chval.
       vdfbgl = sysc.inval.
  find sysc where sysc.sysc eq "CDAGL". vdagl = sysc.inval.
  find sysc where sysc.sysc eq "CDPGL". vdpgl = sysc.inval.
  find sysc where sysc.sysc eq "CAPGL". vapgl = sysc.inval.

  find dadp where dadp.bank eq s-bank
            and  dadp.dadp eq s-dadp.

  {nda.f}

  s-grp = dadp.grp.
  s-dadp = dadp.dadp.
  s-type = dadp.type.
  s-amt = dadp.amt.
  s-bal = dadp.bal.
  s-pcnt = dadp.pcnt.
  s-caccr = dadp.caccr.
  s-crcvd = dadp.crcvd.
  s-cif = dadp.cif.
  s-bank = dadp.bank.
  s-detail = dadp.detail.
  s-rdt = dadp.rdt.
  s-adt = dadp.adt.
  s-trm = dadp.trm.
  s-ddt = dadp.ddt.

  display s-grp @ dadp.grp
          s-dadp @ dadp.dadp
          s-type @ dadp.type
          s-amt @ dadp.amt
          s-bal @ dadp.bal
          s-pcnt @ dadp.pcnt
          s-caccr
          s-crcvd @ dadp.crcvd
          s-cif @ dadp.cif
          s-bank @ dadp.bank
          s-detail @ dadp.detail
          s-rdt @ dadp.rdt
          s-adt @ dadp.adt
          s-trm @ dadp.trm
          s-ddt @ dadp.ddt
          with frame dadp.
  find bank where bank.bank eq s-bank no-error.
  display bank.name with frame dadp.
  find cif where cif.cif eq s-cif no-error.
  display trim(trim(cif.prefix) + " " + trim(cif.name)) @ dadp.party with frame dadp.

  view frame dadp.
  do:
    /* set comm g/l */
    if s-grp eq 1   /* d/a */
    then do on error undo, retry:
        if s-type eq "i" then s-gl = vdagl.
        if s-type eq "o" then s-gl = vapgl.
    end.
    if s-grp eq 2   /* d/p */
    then do on error undo, retry:
        if s-type eq "i" then s-gl = vdpgl.
        if s-type eq "o" then s-gl = vapgl.
    end.

    update s-drft with frame dadp.
    if s-drft gt dadp.bal
    then do:
        bell.
        {mesg.i 6809}.
        undo, retry.
    end.
    /*
    find crc of dadp.
    s-drft = s-orgamt / crc.rate.
    */
    /* ------------ */
    find first c-dpay where c-dpay.dadp eq s-dadp
         and c-dpay.drft eq s-drft use-index dpay no-error.
    if available c-dpay
    then do:
        {mesg.i 4814} update ans.
        if ans eq false then undo, retry.
    end.
    /* ------------- */
    display s-caccr with frame dadp.
    update s-caccr with frame dadp.
    if s-caccr gt 0 then do:
       display s-gl with frame dadp.
       update s-gl validate(can-find(gl where gl.gl eq s-gl),"")
                   help "COMM G/L ACCOUNT NUMBER"
                   with frame dadp.
       find gl where gl.gl eq s-gl no-error.
       display gl.des with frame dadp.
    end.
    {mesg.i 3812} update vvans.
    if vvans eq true then do:
       update vvgl validate(can-find(gl where gl.gl eq vvgl),"")
                   help "MORE CHARGE G/L ACCT. NUMBER"
                   with frame dadp.
       find gl where gl.gl eq vvgl no-error.
       vvdes = gl.des.
       display vvdes with frame dadp.
       update vvamt with frame dadp.
    end.
    s-payamt = s-drft - s-caccr - vvamt.
    if s-payamt lt 0 then undo, retry.
    if (s-type eq "I")
       or (s-type eq "O" and s-drft - s-caccr eq 0)  then do:
       {mesg.i 4400}.
       update s-pacct
              validate(s-pacct ge 1 and s-pacct le 4,"")
              with frame dadp.
       if s-pacct eq 1 then do:
          s-acc = vdefdfb.
          display s-acc with frame dadp.
          {mesg.i 9822} update s-acc.
          find dfb where dfb.dfb eq s-acc no-error.
          if not available dfb then do:
             {mesg.i 9816}.
             undo, retry.
          end.
          /*
          update s-acc
             validate(can-find(dfb where dfb.dfb eq s-acc) eq true,
             "DFB NOT FOUND") with frame dadp.
          */
       end.
       if s-pacct eq 2 then {mesg.i 0829}.
       if s-pacct eq 3 then do:
          {mesg.i 1812} update s-acc.
          find aaa where aaa.aaa eq s-acc no-error.
          if not available aaa then do:
             {mesg.i 6202}.
             undo, retry.
          end.
          /*
          update s-acc
             validate(can-find(aaa where aaa.aaa eq s-acc) eq true,
             "ACCOUNT NOT FOUND") with frame dadp.
          */
       end.
       if s-pacct eq 4 then do:
          {mesg.i 1819} update s-vgl.
          find gl where gl.gl eq s-vgl no-error.
          if not available gl then do:
             {mesg.i 1818}.
             undo, retry.
          end.
          if gl.subled ne "" then {mesg.i 1812} update s-acc.
       end.
    end. /* end of Inward */

    if (s-type eq "O" and s-drft - s-caccr gt 0) then do:
       {mesg.i 4401}.
       update s-pacct validate(s-pacct ge 1 and s-pacct le 4,"")
              with frame dadp.
       if s-pacct eq 1 then do:
          s-acc = vdefdfb.
          display s-acc with frame dadp.
          {mesg.i 9822} update s-acc.
          find dfb where dfb.dfb eq s-acc no-error.
          if not available dfb then do:
             {mesg.i 9816}.
             undo, retry.
          end.
          /*
          update s-acc
             validate(can-find(dfb where dfb.dfb eq s-acc) eq true,
             "BANK NOT FOUND") with frame dadp.
           */
       end.
       if s-pacct eq 2 then do:
          {mesg.i 9831} update s-acc.
          find ock where ock.ock eq s-acc no-error.
          if available ock then do:
             {mesg.i 9833}.
             undo, retry.
          end.
          /*
          update s-acc
             validate(can-find(ock where ock.ock eq s-acc) eq false,
             "EXISTING CHECK") with frame dadp.
          */
       end.
       if s-pacct eq 3 then do:
          {mesg.i 1812} update s-acc.
          find aaa where aaa.aaa eq s-acc no-error.
          if not available aaa then do:
             {mesg.i 6202}.
             undo, retry.
          end.
          /*
          update s-acc
             validate(can-find(aaa where aaa.aaa eq s-acc) eq true,
             "ACCOUNT NOT FOUND") with frame dadp.
          */
       end.
       if s-pacct eq 4 then do:
          {mesg.i 1820} update s-vgl.
          find gl where gl.gl eq s-vgl no-error.
          if not available gl then do:
             {mesg.i 1818}.
             undo, retry.
          end.
          if gl.subled ne "" then {mesg.i 1812}.
          {mesg.i 1812} update s-acc.
       end.
    end. /* end of Outward */
    vpdt = g-today.
    /*
    if s-grp eq 1 /* D/A */ then do:
       s-adt = g-today.
       update s-adt @ dadp.adt with frame dadp.
       dadp.adt = s-adt.
       update s-trm @ dadp.trm with frame dadp.
       dadp.trm = s-trm.
       s-ddt = s-adt + s-trm.
       dadp.ddt = s-ddt.
       repeat:
         find hol where hol.hol eq s-ddt no-error.
         if not available hol and
   weekday(s-ddt) ge v-weekbeg and
   weekday(s-ddt) le v-weekend
         then leave.
         else s-ddt = s-ddt + 1.
       end.
       display s-ddt with frame dadp.
       /* ------------------------------------------------ */
       if vpdt gt dadp.ddt then do:
          {mesg.i 4816} update vans.
          if vans ne true then undo, retry.
        end.
        /* ---------------------------------------------- */
        s-trm = s-ddt - s-adt.
        display s-trm @ dadp.trm with frame dadp.
        dadp.trm = s-trm.
    end. /* D/A */
    */

    /* -------------------------------------------------- */
    if vpdt gt dadp.ddt then do:
       {mesg.i 4816} update vans.
       if vans ne true then undo, retry.
    end.
    /* -------------------------------------------------- */
  end.

  bell.
  {mesg.i 0928} update ans.
  if ans eq false then undo, retry.
  if s-type eq "i" then run s-dapi.  /* inward pay */
  if s-type eq "o" then run s-dapo.  /* outward pay */
  display s-jh with frame dadp.
  pause 4.
  hide frame dadp.
