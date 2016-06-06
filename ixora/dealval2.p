/* dealval2.p
 * MODULE
        Модуль ЦБ 
 * DESCRIPTION
        Открытие и редактирование сделок по ЦБ 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        deal2.p
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25/11/03 nataly автоматическое открытие счета SCU 
*/

/* dealval.p
deal record is transfered to newly created scu file.
jane han
*/

def new shared var vans as log.
DEF  shared VAR vnew AS LOG.
DEF  shared VAR vedit AS LOG.

def var fv as cha.
def var inc as int.
def  shared var vdeal like deal.deal.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{mainhead.i MMTRX}

def new shared var s-scu like scu.scu.

  find deal where deal.deal eq vdeal no-error.
  if not avail deal 
  then do:
       message "Не найдена сделка "  vdeal.
       pause.
       undo, retry.
  end.


  if deal.fun ne "" 
  then do:
       message "Произведена транзакция валютирования".
       pause.
       undo, retry.
  end.
  find scu where scu.scu = deal.deal exclusive-lock no-error.
  if available scu
  then do:
       if scu.sts >= 1
       then do:
            message "Для сделки" scu.scu skip
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
  if not available scu
  then create scu.
  scu.scu = deal.deal.
  scu.gl = deal.gl.
  find gl where gl.gl eq scu.gl no-lock.
  scu.grp = deal.grp.
  scu.bank = deal.bank.
  find bankl where bankl.bank eq deal.bank no-lock.
  scu.cst = bankl.name.
  scu.amt = deal.prn.
  scu.regdt = deal.valdt. 
  scu.rdt = deal.valdt.
  scu.duedt = deal.maturedt.
  repeat:
    find hol where hol.hol eq scu.duedt no-lock no-error.
    if not avail hol and
       weekday(scu.duedt) ge v-weekbeg and
       weekday(scu.duedt) le v-weekend
    then leave.
    else scu.duedt = scu.duedt + 1.
  end.
  scu.trm = scu.duedt - scu.rdt.
  scu.intrate = deal.intrate.
  scu.interest = deal.intamt.
  scu.itype = deal.inttype.
  if gl.type eq "L" 
  then scu.dfb = deal.atvalueon[1].
  else scu.dfb = deal.atmaton[1].
  find dfb where dfb.dfb = scu.dfb no-lock.
  scu.crc = dfb.crc.
  find bankl where bankl.bank eq scu.bank no-lock.
  scu.tbank = bankl.bank.
  scu.crbank = bankl.bank.
  scu.acct = bankl.acct.
  scu.who = g-ofc.
  scu.whn = g-today.
  {subadd-pc.i  &sub = "scu"}
  scu.rcvacc = deal.atvalueon[1]. 
  scu.payacc = deal.atmaton[1]. 
  scu.accrcv = deal.atvalueon[3].
  scu.accpay = deal.atmaton[3].
  scu.info[1] = deal.rem[1]. 
  scu.info[2] = deal.rem[2]. 
  if gl.type eq "A" 
  then scu.ref = deal.rem[1].
  else scu.ref = deal.rem[2].   

/* append for accrued system by S.Kuzema */
  scu.zalog  = deal.zalog.
  scu.geo    = deal.geo.
  scu.lonsec = deal.lonsec.
  scu.risk   = deal.risk.
  scu.penny  = deal.penny.
  

  scu.sts = 0.
  s-scu = scu.scu.
  release scu.
  /* run funedt.*/
 if vnew then message 'Счет SCU ' s-scu ' успешно открыт!' view-as alert-box.
 if vedit then message 'Счет SCU ' s-scu ' успешно отредактирован!' view-as alert-box.
  
