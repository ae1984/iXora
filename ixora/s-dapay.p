/* s-dapay.p
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

/* s-dapay.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

def shared var s-bank like dadp.bank.
def shared var s-dadp like dadp.dadp.

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.

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

def var s-pdt as date.
def var ans as log.
def var vans as log.

def buffer b-dpay for dpay.
def buffer c-dpay for dpay.
def buffer c-bank for bank.

def var vcdaval as dec.
def var vcdpval as dec.
def var vdefdfb as cha.
def var vdagl as int.
def var vdpgl as int.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

find sysc where sysc.sysc eq "CDAGL". vcdaval = sysc.deval.
find sysc where sysc.sysc eq "CDPGL". vcdpval = sysc.deval.
find sysc where sysc.sysc eq "DEFDFB". vdefdfb = sysc.chval.
find sysc where sysc.sysc eq "CDAGL". vdagl = sysc.inval.
find sysc where sysc.sysc eq "CDPGL". vdpgl = sysc.inval.

find dadp where dadp.bank eq s-bank
          and  dadp.dadp eq s-dadp.
form
  s-grp colon 11 s-dadp colon 41 skip
  s-type colon 11
  s-gl colon 11 gl.des colon 31
  s-amt colon 11 label "AMOUNT" skip
  s-bal colon 11 s-pcnt colon 41 label "PAYMENT COUNT" skip
  s-drft colon 11
  s-caccr colon 11 label "COMM-ACCR"
  s-crcvd colon 41 label "COMM-RCVD" skip
  s-pacct colon 11 s-acc colon 41 label "SUB-LEDGER"
  s-rdt colon 11
  s-pdt colon 11 label "PAY-DATE" skip
  s-adt colon 11 label "ACCPT-DATE" s-trm colon 41 skip
  s-ddt colon 11 label "DUE-DATE"
  s-cif colon 11 s-party colon 41
  s-bank colon 11 bank.name colon 31 label "NAME" skip
  s-detail colon 11  s-jh colon 41
  with row 3 side-label centered frame dpay title "D/A D/P PAYMENT".

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

display s-grp s-dadp s-type s-amt s-bal s-pcnt s-caccr s-crcvd s-cif
  s-bank s-detail s-rdt s-adt s-trm s-ddt with frame dpay.
find bank where bank.bank eq s-bank no-error.
display bank.name with frame dpay.
find cif where cif.cif eq s-cif no-error.
display trim(trim(cif.prefix) + " " + trim(cif.name)) @ s-party with frame dpay.

view frame dpay.
/*
update s-grp validate(s-grp ge 1 and s-grp le 2,"")
               help "1.D/A 2.D/P"
       with frame dpay.
  */
  do:
    if s-grp eq 1   /* d/a */
      then do on error undo, retry:
        s-gl = vdagl.
        /*
        s-caccr = vcdaval.
        */
        display s-gl with frame dpay.
        update s-gl validate(can-find(gl where gl.gl eq s-gl),"")
                    help "G/L ACCOUNT NUMBER"
               with frame dpay.
        find gl where gl.gl eq s-gl no-error.
        display gl.des with frame dpay.
      end.

    if s-grp eq 2   /* d/p */
      then do on error undo, retry:
        s-gl = vdpgl.
        /*
        s-caccr = vcdpval.
        */
        display s-gl with frame dpay.
        update s-gl validate(can-find(gl where gl.gl eq s-gl),"")
                    help "G/L ACCOUNT NUMBER"
               with frame dpay.
        find gl where gl.gl eq s-gl no-error.
        display gl.des with frame dpay.
      end.

    update s-drft
    with frame dpay.
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
    if s-type eq "O" and s-grp eq 2 then
    s-caccr = 0.
    display s-caccr with frame dpay.
    update s-caccr  when s-drft eq 0 and s-grp eq 2
           with frame dpay.
    s-payamt = s-drft + s-caccr.

    if s-type eq "I" then do:
    update s-pacct validate(s-pacct ge 1 and s-pacct le 3,"")
                   help "1.CASH 2.CHECK 3.DUE TO ACCT"
           with frame dpay.
   /*
   if s-pacct eq 2
      then do:
        update s-acc with frame dpay.
        if integer(s-acc) le 0
          then do:
            bell.
            {mesg.i 4803}.
            undo, retry.
          end.
      end.
      */
     if s-pacct eq 3 then do:
      {mesg.i 1812}.
      update s-acc
         validate(can-find(aaa where aaa.aaa eq s-acc) eq true,
      "ACCOUNT NOT FOUND")
      with frame dpay.
    end.
    end. /* end of I */
    s-pdt = g-today.
    /*
    update s-pdt with frame dpay.
    */

    /*
    if s-grp eq 1 /* D/A */
      then do:
        s-adt = g-today.
        update s-adt with frame dpay.
        dadp.adt = s-adt.
        update s-trm with frame dpay.
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
      display s-ddt with frame dpay.
      /* ------------------------------------------------ */
      if s-pdt gt dadp.ddt then
        do:
          {mesg.i 4816} update vans.
          if vans ne true then undo, retry.
        end.
        /* ------------------------------------------------ */
        s-trm = s-ddt - s-adt.
        display s-trm with frame dpay.
        dadp.trm = s-trm.
      end. /* D/A */
      */

      /* ------------------------------------------------ */
      if s-pdt gt dadp.ddt then
        do:
          {mesg.i 4816} update vans.
          if vans ne true then undo, retry.
        end.
        /* ------------------------------------------------ */
      /*  nothing for D/P */
      /* D/P is not related to term */
  end.   /* except commission */
bell.
{mesg.i 0928} update ans.
if ans eq false then undo, retry.
/*
if (s-grp eq 2 or (s-grp eq 1 and s-drft ne 0))
  or (s-type eq "O" and s-caccr eq 0)
  then run s-daptr.   /* d/p all and d/a payment */
  else run s-dapad.   /* d/a  commission only */
*/
if (s-grp eq 1 and s-caccr ne 0)
  then run s-dapad.
  else run s-daptr.
display s-jh with frame dpay.
pause 4.
hide frame dpay.
