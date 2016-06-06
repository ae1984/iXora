/* vcpril6dat.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 6 - уведомление о просроченной лицензии
        Сборка данных во временные таблицы
 * RUN
        
 * CALLER
        vcpril6.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-4-1-9, 15-4-2-11, 15-4-3-7
 * AUTHOR
        29.09.2003 nadejda
 * CHANGES
        08.01.2004 nadejda - исправлена ошибка проверки лицензии на завершение
*/

{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-dtrep as date.
def shared var v-sumzero as logical.
def shared var v-period as integer.

def shared temp-table t-contrs
  field contract like vccontrs.contract
  field ctnum as char
  field ctdate as date
  field expimp as char
  field partner as char
  field partnname as char
  field partnaddr as char
  field licid like vcrslc.rslc
  field licnum as char
  field licdt as date
  field liclastdt as date
  field licsum as decimal
  field liccrc as char
  field cif like txb.cif.cif
  field cifname as char
  field okpo as char
  field rnn as char
  field addr as char
  index main is primary unique cifname cif ctdate ctnum contract licdt licnum licid.


def temp-table t-docs0
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  index main is primary dndate dnnum docs.

def shared temp-table t-docs
  field licid like vcrslc.rslc
  field ln as integer
  field data20 as date
  field sum20 as deci
  field crc20 as char
  field data30 as date
  field sum30 as deci
  field crc30 as char
  index ln is primary unique licid ln.


def var s-dnvid as char no-undo.
def var s-vcdocptypes as char no-undo.
def var s-vcdocgtypes as char no-undo.
def var i as integer no-undo.

s-dnvid = "p".
s-vcdocptypes = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index(s-dnvid, txb.codfr.name[5]) > 0 no-lock:
  s-vcdocptypes = s-vcdocptypes + txb.codfr.code + ",".
end.

s-dnvid = "g".
s-vcdocgtypes = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index(s-dnvid, txb.codfr.name[5]) > 0 no-lock:
  s-vcdocgtypes = s-vcdocgtypes + txb.codfr.code + ",".
end.


for each vcrslc where vcrslc.dntype = "22" and vcrslc.dndate <= v-dtrep no-lock:
  if vcrslc.info[1] = "Z" and date(vcrslc.info[2]) <= v-dtrep then next.
  if vcrslc.sum = 0 and not v-sumzero then next.
  if vcrslc.lastdate >= v-dtrep or vcrslc.lastdate < v-dtrep - v-period then next.

  find vccontrs where vccontrs.contract = vcrslc.contract no-lock no-error.
  if not avail vccontrs or (vccontrs.bank <> p-vcbank) then next.
  if vccontrs.sts begins "C" then next.
  
  find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
  if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.
  
  find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsts" and 
                         txb.sub-cod.acc = vccontrs.cif no-lock no-error.

  find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
  find txb.ncrc where txb.ncrc.crc = vcrslc.ncrc no-lock no-error.

  create t-contrs.
  assign t-contrs.contract = vccontrs.contract
         t-contrs.ctnum = vccontrs.ctnum
         t-contrs.ctdate = vccontrs.ctdate
         t-contrs.expimp = vccontrs.expimp
         t-contrs.partner = vccontrs.partner
         t-contrs.partnname = if avail vcpartners then trim(trim(vcpartners.name) + " " + trim(vcpartners.formasob)) else ""
         t-contrs.partnaddr = if avail vcpartners then trim(vcpartners.address) else ""
         t-contrs.licid = vcrslc.rslc
         t-contrs.licnum = vcrslc.dnnum
         t-contrs.licdt = vcrslc.dndate
         t-contrs.liclastdt = vcrslc.lastdate
         t-contrs.licsum = vcrslc.sum
         t-contrs.liccrc = txb.ncrc.code
         t-contrs.cif = vccontrs.cif
         t-contrs.cifname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name))
         t-contrs.okpo = if txb.sub-cod.ccode = "0" then txb.cif.ssn else ""
         t-contrs.rnn = if trim(txb.cif.jss) begins "0000" then "" else trim(txb.cif.jss)
         t-contrs.addr = trim(txb.cif.addr[1]).

  if trim(txb.cif.tel) <> "" then do:
    if t-contrs.addr <> "" then t-contrs.addr = t-contrs.addr + ", ".
    t-contrs.addr = t-contrs.addr + "тел." + trim(txb.cif.tel).
  end.

  if trim(txb.cif.fax) <> "" then do:
    if t-contrs.addr <> "" then t-contrs.addr = t-contrs.addr + ", ".
    t-contrs.addr = t-contrs.addr + "факс " + trim(txb.cif.fax).
  end.

  /* платежи */
  for each t-docs0. delete t-docs0. end.
  for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, s-vcdocptypes) > 0 
           and vcdocs.dndate < v-dtrep no-lock:
    create t-docs0.
    buffer-copy vcdocs to t-docs0.
  end.

  i = 0.
  for each t-docs0:
    i = i + 1.
    create t-docs.
    t-docs.licid = vcrslc.rslc.
    t-docs.ln = i.

    find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.

    if vccontrs.expimp = "i" then do:
      t-docs.data20 = vcdocs.dndate.
      find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docs.crc20 = txb.ncrc.code.
      if vcdocs.payret then t-docs.sum20 = - vcdocs.sum.
                       else t-docs.sum20 = vcdocs.sum.
    end.
    else do:
      t-docs.data30 = vcdocs.dndate.
      find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docs.crc30 = txb.ncrc.code.
      if vcdocs.payret then t-docs.sum30 = - vcdocs.sum.
                       else t-docs.sum30 = vcdocs.sum.
    end.
  end.


  /* ГТД */
  for each t-docs0. delete t-docs0. end.
  for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, s-vcdocgtypes) > 0 
           and vcdocs.dndate < v-dtrep no-lock:
    create t-docs0.
    buffer-copy vcdocs to t-docs0.
  end.

  for each t-docs0:
    find vcdocs where vcdocs.docs = t-docs0.docs no-lock no-error.

    if vccontrs.expimp = "i" then
      find first t-docs where t-docs.licid = vcrslc.rslc and t-docs.data30 = ? no-error.
    else
      find first t-docs where t-docs.licid = vcrslc.rslc and t-docs.data20 = ? no-error.

    if not avail t-docs then do:
      find last t-docs where t-docs.licid = vcrslc.rslc no-lock no-error.
      if avail t-docs then i = t-docs.ln + 1.
                      else i = 1.
      create t-docs.
      t-docs.licid = vcrslc.rslc.
      t-docs.ln = i.
    end.
      
    if vccontrs.expimp = "i" then do:
      t-docs.data30 = vcdocs.dndate.
      find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docs.crc30 = txb.ncrc.code.
      if vcdocs.payret then t-docs.sum30 = - vcdocs.sum.
                       else t-docs.sum30 = vcdocs.sum.
    end.
    else do:
      t-docs.data20 = vcdocs.dndate.
      find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docs.crc20 = txb.ncrc.code.
      if vcdocs.payret then t-docs.sum20 = - vcdocs.sum.
                       else t-docs.sum20 = vcdocs.sum.
    end.
  end.

end.

