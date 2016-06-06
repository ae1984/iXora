/* Hvars_ps.i
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

def {1} shared var v-bic as cha .
def {1} shared var v-bsubc as cha .
def {1} shared var v-bc as cha .
def {1} shared var v-osubc as cha .
def {1} shared var v-oc as cha .
def {1} shared var v-pk as cha .
def {1} shared var fou as log initial false .
def {1} shared var m-typ as cha .
def {1} shared var v-pri as cha .
def {1} shared var v-ret as cha .
def {1} shared var tradr as cha .
def {1} shared var exitcod as cha .
def {1} shared var v-date as date .
def {1} shared var v-bank like bank.bankl.bank .
def {1} shared var lbnstr as cha .
def {1} shared var dep-date as date .
def {1} shared var v-cif like bank.cif.cif .
def {1} shared var rep as cha initial "0".
def {1} shared var irep as int initial 0.
def {1} shared var blok4 as log initial false .
def {1} shared var blokA as log initial false .
def {1} shared var v-ref as cha  .
def {1} shared var v-crc like bank.remtrz.fcrc .
def {1} shared var v-amt like bank.remtrz.amt.
def {1} shared var v-ord like bank.remtrz.ord.
def {1} shared var v-info as cha .
def {1} shared var v-info3 as cha .
def {1} shared var v-intmed as cha .
def {1} shared var v-intmedact as cha .
def {1} shared var v-acc like bank.remtrz.sacc.
def {1} shared var v-bb as cha .
def {1} shared var v-ba as cha .
def {1} shared var v-ben as cha .
def {1} shared var v-det as cha .
def {1} shared var v-chg as cha .
def {1} shared var tmp as cha .
def {1} shared var trz1 as cha .
def {1} shared var trz2 as cha .
def {1} shared buffer que1 for bank.que .
def {1} shared buffer que2 for bank.que .
def {1} shared var trzerr as log .
def {1} shared var snpgl like bank.remtrz.crgl .
def {1} shared var snpgl2 like bank.remtrz.crgl .
def {1} shared var snpacc like bank.remtrz.cracc .

def {1} shared var i as int .
def {1} shared var num as cha extent 100 .
def {1} shared var v-string as cha .
def {1} shared var impok as log initial false .
def {1} shared var ok as log initial false .
def {1} shared var acode like bank.crc.code.
def {1} shared var bcode like bank.crc.code.
def {1} shared var c-acc as cha .
def {1} shared var vv-crc like bank.crc.crc .
def {1} shared var v-cashgl like bank.gl.gl.
def {1} shared var vf1-rate like bank.fexp.rate.
def {1} shared var vfb-rate like bank.fexp.rate.
def {1} shared var vt1-rate like bank.fexp.rate.
def {1} shared var vts-rate like bank.fexp.rate.
def {1} shared buffer xaaa for bank.aaa.
def {1} shared buffer fcrc for bank.crc.
def {1} shared buffer t-bankl for bank.bankl.
def {1} shared buffer tcrc for bank.crc.
def {1} shared var ourbank as cha.
def {1} shared var clecod  as cha.
def {1} shared var v-sender like bank.remtrz.sbank .
def {1} shared var t-pay like bank.remtrz.payment.
def {1} shared buffer tgl for bank.gl.
def {1} shared var b as int.
def {1} shared var s as int.
def {1} shared var sender   as cha.
def {1} shared var v-field  as cha extent 50 .
def {1} shared var receiver as cha.
def {1} shared var v-err as cha .
def {1} shared var s-remtrz like bank.remtrz.remtrz .
def {1} shared var v-reterr as int initial 0.
def {1} shared var v-weekbeg as int.
def {1} shared var v-weekend as int.
def {1} shared var brnch as log init no.
def {1} shared var l-chng as log . 
def {1} shared var old-bank like bank.bankl.bank
. 
