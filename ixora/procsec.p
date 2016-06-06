/* procsec.p
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

/* procsec.p
   security registration process
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

define shared var s-invsec like invsec.invsec.
define new shared var gdate as date.
def var vacc like jl.acc.
def var vgl like gl.gl.
def var vln as int.
def var vyr as int.
def new shared var s-jh like jl.jh.
def new shared var s-consol like jh.consol initial false.

def var vbal like jl.dam.
def var vdam like vbal.
def var vcam like vbal.
def var vop as int format "z".
/*
def var vcmlr like gl.gl.
def var vcmle like gl.gl.
def var vcmlc like gl.gl.
def var vcon  like gl.gl.
*/
def var i as int.
{jhjl.f new}

{proghead.i}
/*
find sysc where sysc.sysc eq "CMLR".  vcmlr = sysc.inval.
find sysc where sysc.sysc eq "CMLE".  vcmle = sysc.inval.
find sysc where sysc.sysc eq "CMLC".  vcmlc = sysc.inval.
find sysc where sysc.sysc eq "CON".   vcon = sysc.inval.
*/

find invsec where invsec.invsec = s-invsec.
run x-jhnew.
find jh where jh.jh = s-jh.
find bank where bank.bank eq invsec.bank no-error.
if available bank then do:
  /* jh.cif = bank.bank. */
  jh.party = bank.bank + " " + bank.name.
end.
display jh.jh jh.jdt jh.who with frame jh.
display jh.cif jh.party jh.party with frame party.

find stype where stype.stype eq invsec.stype.
vgl = stype.portgl.

    vln = 1.

    /* principle into inv  g/l */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = invsec.purpr.
    jl.dc = "D".
    jl.gl = vgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = invsec.invsec + "/" + invsec.bank + "/"
                         + string(invsec.coupon) + "/" + invsec.stype
                         + "/" + string(invsec.mdt).
    vln = vln + 1.


    /* inv purchase amount payment to broker/seller
     1. if cash or 2. official chk or 3. due to customer 4. dfb

    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = invsec.invsec + "/" + invsec.bank + "/"
                  + string(invsec.coupon) + "/" + invsec.stype
                  + "/" + string(invsec.mdt).
    1. if cash then
    jl.gl = 101100.  /* set cash g/l */
    jl.cam = invsec.prin.
    jl.dc = "C".

    else 2. official chk
    jl.gl = 321100.  /* set off chk g/l */
    find gl where gl.gl eq jl.gl no-error.
        find nmbr where nmbr.code eq gl.code.
        {nmbr-acc.i nmbr.prefix
                    nmbr.nmbr
                    nmbr.fmt
                    nmbr.sufix}
        nmbr.nmbr = nmbr.nmbr + 1.

    jl.acc = vacc.
    jl.cam = invsec.prin.
    jl.dc = "C".
    create ock.
    ock.ock = jl.acc.
    ock.rdt = invsec.tdt.
    ock.payee = trim(trim(cif.prefix) + " " + trim(cif.name)).
    ock.cam[1] = jl.cam.
    jl.rem[2] = jl.acc + "/" + invsec.cif.

    display "Transaction completed..." jh.jh
    with side-label row 7 no-box centered frame ts.
    pause 5.
    */

    {x-jllis.i}
    run x-jlgens.p.
    hide all.
    view frame heading.
    view frame cif.
