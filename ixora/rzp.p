/* rzp.p
 * MODULE
        Формирование и отправка сообщений МТ102 дл зп.
 * DESCRIPTION
	Создание и отправка платежей по ЗП проектам Народного банка
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        02/10/2006 tsoy
 * CHANGES
*/

{mainhead.i OUTRMZ}

def var acode like crc.code.
def var bcode like crc.code.
def new shared var v-ref as cha format "x(10)".
def new shared var v-pnp like remtrz.dracc . 
def new shared var v-reg5 as cha . 
def new shared var pakal as cha . 
def new shared var v-chg  as int .
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha .
def var ourbank like bankl.bank . 
def new shared var v-dfbname as char .
def new shared var v-bankname as char.
def var v-priory as char.
def var s-cif as char.
def var s-rnn as char.

{lgps.i "new"}
m_pid = "P" .
u_pid = "RZP" .
/*v-option = "remsubk".*/
v-option = "RZP".

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
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
 &option = RZP
 &formname = psror-2
 &findcon = true
 &addcon = false
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = zp1-rotrz 
 &clearframe = " "
 &viewframe = " "
 &postfind = " "
 &preadd = " "
 &postadd = " "
 &end = " "
 &postadd1 = " "
}
