/* s-dilrmz.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

/* s-remout.p*/

{global.i}
def var ys as log .
def var kchoose as char . 
def buffer tgl for gl.
def shared var v-option as cha .
def shared var s-remtrz like remtrz.remtrz .
def var t-pay like remtrz.amt.
def var prilist as cha.
/*define new shared frame vkbrmz. */
def var acode like crc.code.
def var bcode like crc.code.

{lgps.i}
{vkbrmz.f}

 find first remtrz where remtrz.remtrz = s-remtrz no-lock .

 find first que where que.remtrz = remtrz.remtrz no-lock no-error .
 if avail que then do:
 if ( que.con ne "W" or que.pid ne  m_pid  ) and m_pid ne "PS_"
  then do:
   Message " Impossible to process !! " . pause .
   return.
   end.

 find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) 
                     and tarif2.stat = 'r' no-lock no-error .
 if avail tarif2 then pakal = tarif2.pakalp .
  else pakal = ' ' .
 find gl where gl.gl = remtrz.drgl no-lock no-error.
 find tgl where tgl.gl = remtrz.crgl no-lock no-error.
 find crc where crc.crc = remtrz.fcrc no-lock no-error .
  if avail crc then acode = crc.code .
 find crc where crc.crc = remtrz.tcrc no-lock no-error .
  if avail crc then bcode = crc.code .
 t-pay = remtrz.margb + remtrz.margs .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 if avail ptyp then display ptyp.des with frame vkbrmz.


find last linkjl where linkjl.jdt le g-today and linkjl.jdt ge g-today - 10
and linkjl.rem = remtrz.remtrz no-lock no-error.
if avail linkjl  then v-cor = linkjl.atr[12].

end.
do trans :
/* run start. */
 v-psbank = remtrz.sbank .
 display
     remtrz.remtrz remtrz.sqn  remtrz.rdt
     remtrz.valdt1  remtrz.valdt2 remtrz.jh1      remtrz.jh2
     v-psbank remtrz.rbank remtrz.scbank remtrz.rcbank
     remtrz.sacc remtrz.racc rsub
     remtrz.drgl remtrz.crgl remtrz.dracc  remtrz.cracc
     remtrz.fcrc acode remtrz.tcrc bcode remtrz.amt remtrz.payment
     remtrz.ptype remtrz.cover remtrz.svccgr  pakal
     remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
     v-cor remtrz.bn remtrz.ord remtrz.detpay   with frame vkbrmz .
     if avail tgl then  display tgl.sub with frame vkbrmz .
     if avail gl then  display gl.sub with frame vkbrmz .
   release remtrz .
   release que .
end .
kchoose = "".

{subap.i
&choosekey = "keys kchoose auto-return "
&poschoose = "  kchoose = """" .  "
&head = remtrz
&headkey = remtrz
&framename = vkbrmz
&formname = vkbrmz
/*&updatecon = false
&deletecon =  false  */
&postrun = "  find linkjl where 
    linkjl.jdt le g-today and linkjl.jdt ge g-today - 5
    and linkjl.rem = s-remtrz no-lock no-error.
                if avail linkjl then v-cor  = linkjl.atr[12].

            disp v-cor with frame  vkbrmz.  pause 0.
     if m_pid ne  ""PS_"" then do:
     find first que where que.remtrz = s-remtrz
              no-lock no-error.
     if not avail que then return .
   if avail que and  not ( que.pid eq m_pid and que.con eq  ""W"" )
             then do: release remtrz.
             release que. return . end.  end  . "}

pause 0.
