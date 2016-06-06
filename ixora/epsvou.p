/* epsvou.p
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
        25/07/2007 madiyar - убрал ссылку на удаленную таблицу ofcb
*/

/* epsvou.p
*/

def new shared var s-consol like jh.consol init false.
def new shared var s-gl1 like gl.gl label "G/L#     ".
def new shared var s-gl2 like gl.gl label "СЧЕТ ГЛАВНОЙ КНИГИ".
def new shared var s-acc like jl.acc.
def new shared var s-jh  like jh.jh label "ПРОВОДКА# ".
def new shared var s-aah like jh.jh.
def new shared var s-line as int.

def var vpay  as char form "x(20)" label "НАИМЕНОВАНИЕ  ".
def var vsub  as char form "x(30)" label "ПРЕДМЕТ  ".
def var vpres as char form "x(20)" label "ПРЕЗИДЕНТ".
def var vrem  as char form "x(55)" extent 5.
def var vcmp like cmp.name.
def var vtrx like epsrec.epsrec.
def var vbal1 like jl.dam label "СУММА   ".
def var vdate as date form "99/99/99" label "ДАТА     ".
def var vdes like gl.des.
def var vchk like aal.chk form ">>>>>>>>>".
def var veps like eps.eps label "EXP CODE ".
def var vln   as int.
def var vct   as int.
def var vans  as log.
def var vpost as log.
def var vybud like jl.dam.
def var vyeps like jl.dam.
def var vybal like jl.dam.
def var vmbal like jl.dam.

def var vofc   like ofc.ofc label "ИСПОЛНИТЕЛЬ# ".
def var vname  like ofc.name.
def var veck   like eck.eck.
def var vpayee like eck.payee.
def var vref   like eck.ref.

def var cmd as char form "x(8)" extent 16
  initial ["NEXT","EDIT","PROCESS","VOUCHER","PRINT","DELETE",
  "QUIT","","","","","","","",""].

def var fv as char.
def var inc as int.

form cmd with row 3 col 71 no-label frame slct.
form veck   label "CHECK#" skip
     vpayee label "PAYEE " skip
     vref   label "ПРИМЕЧАНИЕ" with side-label
  row 14 frame eck overlay title "EXPENSE CHECK".

{epsvou.f}
{mainhead.i "BERUN"}

outer:
repeat:
  vbal1 = 0.
  s-gl1 = 0.
  find sysc where sysc.sysc = "CASHGL" no-lock.
  s-gl2 = sysc.inval.
  s-jh  = 0.
  veck  = "".
  s-acc = "".
  vsub  = "".
  vrem  = "".
  vofc  = "".
  vname = "".

  vpost = false.
  vpay = "РАСХОДНЫЙ ВАУЧЕР".
  update vpay vsub with frame pay.
  update vbal1 with frame pay.
  /*
  find sysc where sysc.sysc eq "PRES" no-error.
  if available sysc then vpres = sysc.chval.
  */
  vdate = g-today.
  update vdate  with frame pay.
  display vdate with frame pay.
  update s-acc with frame pay.
  find eps where eps.eps eq s-acc no-error.
  s-gl1 = eps.gl.
  display eps.des with frame pay.
  if eps.epstot eq true then do:
    bell.
    {mesg.i 0975}.
    undo, retry.
  end.
  update  s-gl2 with frame pay.
  find gl where gl.gl eq s-gl2 no-error.
  vdes = gl.des.
  display vdes with frame pay.
  if gl.subled eq "eck" then do:
    pause 0.
    update veck vpayee vref with frame eck.
      end.
  vchk = int(veck).
  display vchk with frame pay.
  update vofc with frame pay.
  find ofc where ofc.ofc eq vofc no-error.
  if available ofc then vname = ofc.name.
  display vname with frame pay.
  update vrem with frame pay.

  display cmd auto-return with frame slct.

  inner:
  repeat:
    choose field cmd with frame slct.
    if frame-value eq "EDIT" then do:
      if s-jh ne 0 then do:
        bell.
        {mesg.i 0817}.
        pause 1.
        hide message.
        next inner.
      end.
      update vpay vsub with frame pay.
      update vbal1 with frame pay.
      display vdate  s-acc eps.des with frame pay.
      update vdate  s-acc with frame pay.
      find eps where eps.eps eq s-acc no-error.
      s-gl1 = eps.gl.
      display eps.des with frame pay.
      update s-gl2 with frame pay.
      find gl where gl.gl eq s-gl2 no-error.
      vdes = gl.des.
      display vdes with frame pay.
      if gl.subled eq "eck" then do:
        pause 0.
        update veck vpayee vref with frame eck.
      end.
      else do:
        veck = "".
        vpayee = "".
        vref = "".
      end.
      vchk = int(veck).
      display vchk with frame pay.
      update vofc with frame pay.
      find ofc where ofc.ofc eq vofc no-error.
      if available ofc then vname = ofc.name.
      else vname = "".
      display vname with frame pay.
      update vrem with frame pay.
    end.
    else if frame-value eq "PROCESS" then do:
      vans = false.
      if s-jh ne 0 then do:
        bell.
        {mesg.i 0817}.
        pause 1.
        hide message.
        next inner.
      end.
      {mesg.i 0928} update vans.
      if vans eq false then next.
      else do:
        run x-jhnew.
        find jh where jh.jh eq s-jh.
        jh.party =  vsub.
        jh.crc = eps.crc.

        vln = 1.
        create jl.
        jl.jh  = jh.jh.
        jl.jdt = jh.jdt.
        jl.ln  = vln.
        jl.crc = jh.crc.
        jl.who = jh.who.
        jl.whn = jh.whn.
        jl.gl  = s-gl1.
        jl.acc = s-acc.
        jl.dc  = "D".
        jl.dam = vbal1.
        jl.rem[1] = vrem[1].
        jl.rem[2] = vrem[2].
        jl.rem[3] = vrem[3].
        jl.rem[4] = vrem[4].
        jl.rem[5] = vrem[5].
        find gl where gl.gl eq jl.gl.
        {jlupd-r.i}

        vln = 2.
        create jl.
        jl.jh  = jh.jh.
        jl.jdt = jh.jdt.
        jl.ln  = vln.
        jl.crc = jh.crc.
        jl.who = jh.who.
        jl.whn = jh.whn.
        jl.gl  = s-gl2.
        jl.dc  = "C".
        jl.cam = vbal1.
        jl.rem[1] = vrem[1].
        jl.rem[2] = vrem[2].
        jl.rem[3] = vrem[3].
        jl.rem[4] = vrem[4].
        jl.rem[5] = vrem[5].
        find gl where gl.gl eq jl.gl.
        if gl.subled eq "eck" then do:
          create eck.
          eck.who = g-ofc.
          eck.crc = eps.crc.
          eck.eck = veck.
          eck.rdt = vdate.
          eck.gl  = gl.gl.
          eck.ref = vref.
          eck.payee = vpayee.
          jl.acc = veck.
        end.
        {jlupd-r.i}
      end.
      pause 0.
      display s-jh with frame pay.
    end.
    else if frame-value eq "NEXT" then do:
      clear frame pay.
      hide frame slct.
      next outer.
    end.
    else if frame-value eq "QUIT" then return.
    else if frame-value eq "DELETE" then do:
      vans = false.
      {mesg.i 0824} update vans.
      if vans eq false then next.

/*    if vpost true and g-ofc ne "root" then do:
        bell.
        {mesg.i 0604}.
        pause 2.
        next inner.
      end.
*/
      else do:
        if s-jh ne 0 then do:
          find jh where jh.jh eq s-jh no-error.
          if jh.post eq true then do:
            bell.
            {mesg.i 0225}.
            undo, retry.
          end.
          if available jh then delete jh.
          for each jl where jl.jh eq s-jh:
            find gl where gl.gl eq jl.gl no-error.
            {jlupd-f.i}
            if gl.subled eq "eck" and
               eck.dam[1] eq 0 and eck.cam[1] eq 0 and
               eck.dam[2] eq 0 and eck.cam[2] eq 0 and
               eck.dam[3] eq 0 and eck.cam[3] eq 0 and
               eck.dam[4] eq 0 and eck.cam[4] eq 0 and
               eck.dam[5] eq 0 and eck.cam[5] eq 0
              then delete eck.
            delete jl.
          end.
        end.
      end.
      clear frame pay.
      next outer.
    end.
    else if frame-value eq "PRINT" then do:
      if s-jh = 0 then do:
       bell.
       {mesg.i 0929}.
       undo,retry.
       end.
      vans = false.
      {mesg.i 0942} update vans.
      if vans eq false then next.
      else do:

        output to exp.img page-size 55.
         find first cmp.

         vcmp = cmp.name.
         find gl where gl.gl eq s-gl1.
         find crc of eps.

  repeat inc = 1 to 12:
    vybud = vybud
          + eps.basic[inc] + eps.addr[inc] + eps.adda[inc]
          + eps.movein[inc] - eps.moveout[inc] - eps.red[inc].
  end.

    vybal = vybud - eps.dam[1].
    vyeps = eps.dam[1] - vbal1.

    vmbal = vbal1.

         display skip(6)
            " EXPENSE VOUCHER"  at 30 skip
            "=================" at 30 skip(2)
            "AMOUNT   :" at 10 crc.code vbal1  skip(1)
            "CONTROL# :" at 10 s-jh   skip(1)
            "G/L#     :" at 10 s-gl1  "   " gl.des skip(1)
            "DATE     :" at 10 vdate  skip(1)
            /*
            "COMPANY  :" at 10 vcmp   skip(1)
            "PRESIDENT:" at 10 vpres  skip(1)
            */
            "PAY G/L# :" at 10 s-gl2  "   " vdes skip(1)
/*            "CHECK#   :" at 10 vchk   skip(1)  */
            "REMARKS  :" at 10 vrem[1] at 21 skip
                         vrem[2] at 21 skip
                         vrem[3] at 21 skip
                         vrem[4] at 21 skip
                         vrem[5] at 21 skip(7)
            "EXPENSE CODE  : " at 10 s-acc "   " eps.des skip(1)
            "TOTAL BUDGET  : " at 10 vybud skip
            "Y-T-D EXPENSE : " at 10 vyeps skip
            "  REQ.EXPENSE : " at 10 vmbal skip
            "     BALANCE  : " at 10 vybal skip(3)
            "OFFICER  :" at 10 caps(userid('bank')) skip
            "-------------------" at 21 skip(2)
            "MANAGER  :" at 10 skip
            "-------------------" at 21 skip(3)
            "RECEIVED BY  :" at 10 skip
            "-------------------" at 25
            with no-label no-box frame eps.
        output close.
unix silent psor -o Courier 12 12 18 exp.img > post.img.
unix silent lpr -Plp1 post.img.
{mesg.i 0924}.
      end.
    end.
    else if frame-value eq "VOUCHER" then do:
      {mesg.i 0809}.
      run x-jlvou.
      vpost = true.
      pause 0.
    end.
  end.
end.
