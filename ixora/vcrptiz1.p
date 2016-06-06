/* vcrptiz1.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Извещение об одном платеже по контракту
 * RUN
        
 * CALLER
        vccontrs.p через vc-alldoc.i
 * SCRIPT
        
 * INHERIT
        vcrptizv0.p
 * MENU
        15-1
 * AUTHOR
        30.10.2002 nadejda
 * CHANGES
        07.11.2002 nadejda переведен на html 
        07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        02.04.2004 nadejda - добавлены колонки суммы в валюте контракта, валюты контракта и курса
        09.02.2004 nadejda - пишется примечание "рыночный курс/курс по контракту"
        30.04.2004 nadejda - инопартнер берется из платежа, если он там есть
*/


{vc.i}

{global.i}

def input parameter p-contract like vccontrs.contract.
def input parameter p-docs like vcdocs.docs.

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

def var v-rate as decimal decimals 6.

{vc-crosscurs.i}

create t-docsa.

t-docsa.docs = p-docs.

find vcdocs where vcdocs.docs = p-docs no-lock no-error.
t-docsa.dndate = vcdocs.dndate.
find vccontrs where vccontrs.contract = p-contract no-lock no-error.
t-docsa.contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").

find cif where cif.cif = vccontrs.cif no-lock no-error. 
t-docsa.cifname = trim(trim(cif.sname) + " " + trim(cif.prefix)).
t-docsa.rnn = string(cif.jss, "999999999999").

find vcps where vcps.contract = p-contract and vcps.dntype = "01" no-lock no-error.
if avail vcps then t-docsa.psnum = vcps.dnnum. else t-docsa.psnum = "".

if vcdocs.info[4] <> "" then find vcpartners where vcpartners.partner = trim(vcdocs.info[4]) no-lock no-error.
                        else find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
if avail vcpartners then t-docsa.partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
                    else t-docsa.partname = "".

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

t-docsa.cursdoc-con = vcdocs.cursdoc-con.

assign t-docsa.sumk = t-docsa.sum / t-docsa.cursdoc-con
       t-docsa.sumretk = t-docsa.sumret / t-docsa.cursdoc-con. 


t-docsa.info = vcdocs.info[1].
if t-docsa.cursdoc-con <> 1 then do:
  if t-docsa.info <> "" then t-docsa.info = t-docsa.info + "<br>".

  run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output v-rate).
  
  t-docsa.info = t-docsa.info + if v-rate = t-docsa.cursdoc-con then "рыночный курс" else "курс по контракту".
end.


run vcrptizv0 (vccontrs.expimp).

