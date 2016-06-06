/* out_Pps1.p
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
        21.02.2005 tsoy     - добавил время создания платежа.
        15.07.2005 saltanat - добавила переменные s-cif, s-rnn для psror-2.f 
        25.01.2006 suchkov  - перекомпиляция
        05.04.2006 dpuchkov - перекомпиляция
*/


{mainhead.i OUTRMZ}                            

def new shared var v-ref as cha format "x(10)".
def new shared var v-pnp like remtrz.dracc . 
def new shared var v-reg5 as cha . 
def new shared var pakal as cha . 
def new shared var v-chg  as int .
def new shared var remtrz like remtrz.remtrz.
def new shared var v-option as cha .
def new shared var v-dfbname as char .
def new shared var v-bankname as char.

def buffer tgl for gl.

def var t-pay like remtrz.amt no-undo.
def var ourbank like bankl.bank no-undo. 
def var acode like crc.code no-undo.
def var bcode like crc.code no-undo.
def var v-priory as char no-undo.
def var s-cif as char no-undo.
def var s-rnn as char no-undo.

{lgps.i "new"}
m_pid = "P" .
u_pid = "out_P_ps" .
v-option = "remsubk".
find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record OURBNK in sysc file !!".
   pause .
     undo .
    return .
   end.
 ourbank = sysc.chval.


{main_ps.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = REMTRZ
 &formname = psror-2
 &findcon = true
 &addcon = false
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-rotrz
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 &postadd = " remtrz.rwho = g-ofc . 
              remtrz.sbank = ourbank.
              remtrz.scbank = ourbank.
              remtrz.rtim = time.
 find ofc where ofc.ofc eq g-ofc no-lock.
 remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999').
              if remtrz.source <> 'SCN' then remtrz.source = m_pid + 
              string(integer(truncate(ofc.regno / 1000 , 0)),'99') . 
              run psroup-2 . s-newrec = false . 
 if keyfunction(lastkey) = ""end-error""
   then do :
   delete remtrz .
   return .
  end . 
  "
 &end = " "
 &postadd1 = " do transaction : run rmzoutg. pause 0. end. "
}
