/* dealval.p
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* dealval.p
deal record is transfered to newly created fun file.
jane han
*/

def new shared var vans as log.

def var fv as cha.
def var inc as int.
def var vdeal like deal.deal.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{mainhead.i MMTRX}

def new shared var s-fun like fun.fun.

repeat:
  prompt "Введите номер сделки" vdeal with frame deal row 5 no-label centered.
  find deal where deal.deal eq input vdeal no-error.
  if not avail deal 
  then do:
       message "Не найдена сделка " input vdeal.
       pause.
       undo, retry.
  end.


  if deal.fun ne "" 
  then do:
       message "Произведена транзакция валютирования".
       pause.
       undo, retry.
  end.
  find fun where fun.fun = deal.deal exclusive-lock no-error.
  if available fun
  then do:
       if fun.sts >= 1
       then do:
            message "Для сделки" fun.fun skip
                    "уже проведена операция по дате валютирования"
            view-as alert-box title "Ошибка".
            undo,retry.
       end.
  end.          
  if deal.prn = 0
  then do:
       message "Сделка не оформлена - транзакция невозможна".
       pause.
       undo,retry.
  end.     
  if not available fun
  then create fun.
  fun.fun = deal.deal.
  fun.gl = deal.gl.
  find gl where gl.gl eq fun.gl no-lock.
  fun.grp = deal.grp.
  fun.bank = deal.bank.
  find bankl where bankl.bank eq deal.bank no-lock.
  fun.cst = bankl.name.
  fun.amt = deal.prn.
  fun.regdt = deal.valdt. 
  fun.rdt = deal.valdt.
  fun.duedt = deal.maturedt.
  repeat:
    find hol where hol.hol eq fun.duedt no-lock no-error.
    if not avail hol and
       weekday(fun.duedt) ge v-weekbeg and
       weekday(fun.duedt) le v-weekend
    then leave.
    else fun.duedt = fun.duedt + 1.
  end.
  fun.trm = fun.duedt - fun.rdt.
  fun.intrate = deal.intrate.
  fun.interest = deal.intamt.
  fun.itype = deal.inttype.
  if gl.type eq "L" 
  then fun.dfb = deal.atvalueon[1].
  else fun.dfb = deal.atmaton[1].
  find dfb where dfb.dfb = fun.dfb no-lock.
  fun.crc = dfb.crc.
  find bankl where bankl.bank eq fun.bank no-lock.
  fun.tbank = bankl.bank.
  fun.crbank = bankl.bank.
  fun.acct = bankl.acct.
  fun.who = g-ofc.
  fun.whn = g-today.
  {subadd-pc.i  &sub = "fun"}
  fun.rcvacc = deal.atvalueon[1]. 
  fun.payacc = deal.atmaton[1]. 
  fun.accrcv = deal.atvalueon[3].
  fun.accpay = deal.atmaton[3].
  fun.info[1] = deal.rem[1]. 
  fun.info[2] = deal.rem[2]. 
  if gl.type eq "A" 
  then fun.ref = deal.rem[1].
  else fun.ref = deal.rem[2].   

/* append for accrued system by S.Kuzema */
  fun.zalog  = deal.zalog.
  fun.geo    = deal.geo.
  fun.lonsec = deal.lonsec.
  fun.risk   = deal.risk.
  fun.penny  = deal.penny.
  

  fun.sts = 0.
  s-fun = fun.fun.
  release fun.
  run funedt.
  if not vans then  next.
  
end.  /* repeat */
