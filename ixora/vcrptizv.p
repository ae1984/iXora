/* vcrptizv.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Извещение о платежах за период
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        vcrptiz0.p
 * MENU
        15-3-1
 * AUTHOR
        11.11.2002 nadejda
 * CHANGES
        07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        02.04.2004 nadejda - добавлены колонки суммы в валюте контракта, валюты контракта и курса
        09.02.2004 nadejda - пишется примечание "рыночный курс/курс по контракту"
        30.04.2004 nadejda - инопартнер берется из платежа, если он там есть
        04.05.2004 tsoy      убрал из условие cls.del, тк. теперь поле применеятся для учета типа дня (рабочий / не рабочий). 
	04/01/2006 u00121 - find cif был без last
*/


{vc.i}

{global.i}
{comm-txb.i}

def input parameter p-expimp as char.

def new shared var s-vcourbank as char.

def new shared temp-table t-docsa 
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field crckod as char
  field sum like vcdocs.sum
  field sumret like vcdocs.sum
  field crckodk as char
  field sumk like vcdocs.sum
  field sumretk like vcdocs.sum
  field cursdoc-con as decimal
  field info as char
  field cifname as char
  field rnn as char
  field contrnum as char
  field psnum as char
  field partname as char.

def var v-dtb as date.
def var v-dte as date.
def var v-month as integer.
def var v-god as integer.
def var s-vcdoctypes as char.
def var v-cifname as char.
def var v-contrnum as char.
def var v-partname as char.
def var v-rnn as char.
def var v-psnum as char.
def var i as integer.
def var v-rate as decimal decimals 6.

def temp-table t-period
  field date as date
  index dt is primary date.

form 
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999" skip
  v-dte label "  Конец периода " format "99/99/9999" skip(1)
  with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.


{vc-crosscurs.i}

v-month = month(g-today).
v-god = year(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.
v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then i = 31.
  when 4 or when 6 or when 9 or when 11 then i = 30.
  when 2 then do:
    if v-god mod 4 = 0 then i = 29.
    else i = 28.
  end.
end case.
v-dte = date(v-month, i, v-god).

update v-dtb v-dte with frame f-dt.

for each cls where cls.whn >= v-dtb and cls.whn <= v-dte no-lock:
  create t-period.
  assign t-period.date = cls.whn.
end.

s-vcourbank = comm-txb().

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

for each vccontrs where vccontrs.bank = s-vcourbank and 
      vccontrs.expimp = p-expimp and vccontrs.cttype = "1" and
      can-find(first vcdocs where vcdocs.contract = vccontrs.contract and
        lookup(vcdocs.dntype, s-vcdoctypes) > 0 and
        can-find(t-period where t-period.date = vcdocs.dndate) no-lock)
      use-index main no-lock break by vccontrs.cif:

  if first-of(vccontrs.cif) then do:
    find last cif where cif.cif = vccontrs.cif no-lock no-error.   
    if avail cif then
	do:
    v-cifname = trim(trim(cif.sname) + " " + trim(cif.prefix)).
    v-rnn = string(cif.jss, "999999999999").
	end.
  end. 

  v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").

  find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
  if avail vcps then v-psnum = vcps.dnnum. else v-psnum = "".

  for each vcdocs where vcdocs.contract = vccontrs.contract and
      lookup(vcdocs.dntype, s-vcdoctypes) > 0 and
      can-find(t-period where t-period.date = vcdocs.dndate)
      use-index main no-lock:
  
    if vcdocs.info[4] <> "" then find vcpartners where vcpartners.partner = trim(vcdocs.info[4]) no-lock no-error.
                            else find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
    if avail vcpartners then v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
                        else v-partname = "".

    create t-docsa.
    assign t-docsa.docs = vcdocs.docs
           t-docsa.dndate = vcdocs.dndate
           t-docsa.contrnum = v-contrnum
           t-docsa.cursdoc-con = vcdocs.cursdoc-con
           t-docsa.cifname = v-cifname
           t-docsa.rnn = v-rnn
           t-docsa.psnum = v-psnum
           t-docsa.partname = v-partname.

    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
    t-docsa.crckod = string(ncrc.stn).
    
    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    t-docsa.crckodk = string(ncrc.stn).

    if vcdocs.payret then do: 
      assign t-docsa.sumret = vcdocs.sum
             t-docsa.sum = 0. 
    end.
    else do: 
      assign t-docsa.sum = vcdocs.sum
             t-docsa.sumret = 0. 
    end.

    assign t-docsa.sumk = t-docsa.sum / t-docsa.cursdoc-con
           t-docsa.sumretk = t-docsa.sumret / t-docsa.cursdoc-con. 

    t-docsa.info = vcdocs.info[1].
    if t-docsa.cursdoc-con <> 1 then do:
      if t-docsa.info <> "" then t-docsa.info = t-docsa.info + "<br>".

      run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output v-rate).
      
      t-docsa.info = t-docsa.info + if v-rate = t-docsa.cursdoc-con then "рыночный курс" else "курс по контракту".
    end.
  end.
end.

run vcrptizv0 (p-expimp).

