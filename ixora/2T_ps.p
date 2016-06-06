/* 2T_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        очередь 2Т - создание первой проводки в платежной системе
 * RUN
        запускается только в ПС под superman
 * CALLER
        v-stat2
 * SCRIPT

 * INHERIT

 * MENU
        5.1
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        11.06.2001  - для межбанковского депозита
                      (MDD - привлеченный, возврат суммы и %%, шаблон MAR0039)
                      исправлена формула проверки суммы платежа
                      и параметры, передаваемые для транзакции
        31.01.2003 sasco   - обработка платежей с ptype = 7, gl.sub = "arp"
        13.08.2003 nadejda - в предыдущую обработку ARP добавлен тип 5
        26.12.2003 nataly  - изменена обработка платежей типа MDD
        11.01.2005 tsoy    - пропускаем интернет платежи с будущей датой валютирования
        25.07.2006 tsoy    - Для картела отдельный шаблон.
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        08/09/2011 madiyar - убрал пробелы между detpay в примечании к проводке
        20.09.2012 evseev - ТЗ-1520
        08.10.2012 evseev - ТЗ-797
        11.10.2012 Lyubov - ТЗ 1528, создаем записи в pcpay для зачисления на ПК
        06.11.2012 id00810 - добавлено заполнение поля pcpay.info[1] кодом филиала (для дальнейшей разборки в PCPAY_ps.p)
        28.11.2012 evseev - ТЗ-1374
        22.08.2013 Lyubov - ТЗ 2032, добавила no-lock no-error при поиске валюты
        24.09.2013 Lyubov - ТЗ 1986, возврат зачислений по ошибочным клиентам
        10.10.2013 Lyubov - ТЗ 2135, сверка с таблицей payreturn по счету, ИИН, ФИО
        12.11.2013 Lyubov - ТЗ 2205, запоминаем номер первой строки с ИИН

*/


{global.i}
{lgps.i}
{convgl.i "bank"}
/* for trxgen start */

def var s-jh like jh.jh .
def var s-jh1 like jh.jh .
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var rdes1  as cha .
def var rcode1  as int .
def var vparam as cha .
def var vsum as cha .
def var shcode as cha .
/* for trxgen end   */

def var chkbal like jl.dam .

def var ro-gl as char.
def var ro-gl1 as char.
def var ri-gl as char.
def var ri-gl1 as char.
def var fun-amt like remtrz.amt.
def var fun-amt1 like remtrz.amt.
def var fun-amt2 like remtrz.amt.
def var i like trxbal.level.

def new shared var s-remtrz as char.

def new shared temp-table ttmps no-undo
    field sstr as char /*содержимое строки файла*/
    field scnt as inte /*порядковый номер строки в файле*/
    index ttmps-idx scnt.

def var l as int.
def var coun as int.
def var pcaaa as char.
def var pciin as char.
def var pcamt as char.
def var pccrc as int.
def var v-str1 as int.
def var v-str2 as int.
def var pcfm as char.
def var pcnm as char.
def var pcft as char.

def var v-ourbank as char.

find first sysc where sysc.sysc eq "ourbnk" no-lock no-error.
v-ourbank = sysc.chval.
find sysc where sysc.sysc eq "PSPYGL" no-lock no-error. /* Транз.счет ГК для исход.плат. */

ro-gl = string(sysc.inval) .
ro-gl1 = trim(sysc.chval).

find sysc where sysc.sysc eq "PSINGL" no-lock no-error.  /* Транз.счет ГК для вход.плат. */

ri-gl = string(sysc.inval) .
ri-gl1 = trim(sysc.chval).

find first que where que.pid = m_pid and que.con = "W" use-index fprc no-lock no-error.
if not avail que then return .
do transaction on error undo, return:
   find first que where que.pid = m_pid and que.con = "W" use-index fprc  exclusive-lock no-wait no-error.
   if avail que then  do:
      que.dw = today.
      que.tw = time.
      que.con = "P".
      find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock no-wait no-error.
      if not avail remtrz then do:
        que.pid = m_pid .
        que.df = today.
        que.tf = time.
        que.con = "W".
        return .
      end.
      if remtrz.valdt1 gt g-today and remtrz.source <> "IBH" then do.
         v-text = remtrz.remtrz +  " 1 дата валютирования не сегодня !".
         run lgps.
         que.dp = today.
         que.tp = time.
         que.con = "F".
         que.pvar = "".
         que.rcod = "3".
         return .
      end.
      find first jl where jl.jh = remtrz.jh1 no-lock no-error  .
      if not avail jl then remtrz.jh1 = ? .
      if remtrz.jh1 ne ?  then do.
         v-text = remtrz.remtrz +  " 1 проводка = " + string(remtrz.jh1)  + " уже сделана . " .
         run lgps.
         que.dp = today.
         que.tp = time.
         que.con = "F".
         que.pvar = "100".
         que.rcod = "1".
         return .
      end.
      if remtrz.drgl eq ? or remtrz.drgl = 0 then do.
         v-text = remtrz.remtrz + " ошибка счета Г/К дебета !" .
         run lgps.
         que.dp = today.
         que.tp = time.
         que.con = "F".
         que.pvar = "100".
         que.rcod = "1".
         return .
      end.
      find first gl where gl.gl = remtrz.drgl no-lock .
      if gl.sub = "cif" then do:
         find first aaa where aaa.aaa = remtrz.dracc exclusive-lock no-wait no-error .
         if not avail aaa  then do:
            que.pid = m_pid .
            que.df = today.
            que.tf = time.
            que.con = "W".
            return .
         end.
      end.
      if gl.sub = "fun" then  do:
         find first fun where fun.fun = remtrz.dracc  exclusive-lock no-wait no-error.
         if not avail fun then  do:
            que.pid = m_pid .
            que.df = today.
            que.tf = time.
            que.con = "W".
            return .
         end.
      end.
      if    ((lookup(remtrz.ptype,"N,1,2,4,6,M") ne 0)
         or (lookup(remtrz.ptype,"5,7") > 0 and gl.sub = "arp" and sbank = "ARPTXB"))
         or (lookup(remtrz.ptype,"5,7") ne 0 and gl.sub = "cif" and remtrz.bi = "our") then do.
         if remtrz.fcrc = remtrz.tcrc then do.
            if remtrz.source = "MDL" then do.  /* депозиты размещенные */
               vparam = remtrz.remtrz      + vdel +
                        string(remtrz.amt) + vdel +
                        remtrz.dracc + vdel +
                        remtrz.remtrz + " " +
                        replace(trim(remtrz.detpay[1]) +
                        trim(remtrz.detpay[2]) +
                        trim(remtrz.detpay[3]) +
                        trim(remtrz.detpay[4]) +
                        substr(remtrz.ord,1,35) +
                        substr(remtrz.ord,36,70) +
                        substr(remtrz.ord,71),"^"," ") .
               shcode = "MAR0036" .
               run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).
               if rcode = 0 then do :
                  fun.jh1 = int(s-jh).
                  v-text = "Valdt TRX was made for FUN " + trim(fun.fun).
                  run lgps.
               end.
            end. else if remtrz.source = "MDD" then do : /* депозиты привлеч. */
                  repeat :
                       find trxbal where trxbal.subled = gl.sub
                                        and trxbal.acc = remtrz.dracc
                                        and trxbal.level = i
                                        and trxbal.crc = fun.crc
                                        no-lock no-error.
                       if avail trxbal then do.
                          fun-amt = fun-amt + trxbal.cam - trxbal.dam.
                          if i = 1
                             then fun-amt1 =  trxbal.cam - trxbal.dam.
                             else fun-amt2 =  trxbal.cam - trxbal.dam.
                       end.
                       i = i + 1.
                       if i gt 2 then leave.
                  end.
                  if not ( remtrz.detpay[2] matches '*amount*') then fun-amt1 = 0.
                  if not ( remtrz.detpay[2]  matches '*%%*'   ) then fun-amt2 = 0.
                  vparam = remtrz.remtrz      + vdel +
                         string(fun-amt1) + vdel +
                         remtrz.dracc + vdel +
                         remtrz.remtrz + " " + replace(
                         trim(remtrz.detpay[1]) +
                         trim(remtrz.detpay[2]) +
                         trim(remtrz.detpay[3]) +
                         trim(remtrz.detpay[4]) +
                         substr(remtrz.ord,1,35) +
                         substr(remtrz.ord,36,70) +
                         substr(remtrz.ord,71),"^"," ") + vdel +
                         string(fun-amt2) + vdel +
                         remtrz.dracc .
                  shcode = "MAR0039" .
                  run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).
                  if rcode = 0 then do :
                     fun.jh1 = int(s-jh).
                     v-text = "Maturdt TRX was made for FUN " + trim(fun.fun).
                     run lgps.
                  end.
            end. else if remtrz.source = "mt103" then do : /* входящие мт103 */
               vparam = remtrz.remtrz      + vdel +
                        string(remtrz.amt) + vdel +
                        remtrz.dracc + vdel + ro-gl1 + vdel +
                        remtrz.remtrz + " " + replace(
                        trim(remtrz.detpay[1]) +
                        trim(remtrz.detpay[2]) +
                        trim(remtrz.detpay[3]) +
                        trim(remtrz.detpay[4]) +
                        substr(remtrz.ord,1,35) +
                        substr(remtrz.ord,36,70) +
                        substr(remtrz.ord,71),"^"," ") .
               if gl.sub = "dfb" then shcode = "PSY0007".
               run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).

            end. else do.
                  vparam = remtrz.remtrz      + vdel +
                           string(remtrz.amt) + vdel +
                           remtrz.dracc         + vdel +
                           (
                             if (lookup(remtrz.ptype,"5,7") > 0 and gl.sub = "arp" and sbank = "ARPTXB" and remtrz.tcrc = 1)
                             then ri-gl1
                             else
                             if (lookup(remtrz.ptype,"5,7") > 0 and gl.sub = "arp" and sbank = "ARPTXB" and remtrz.tcrc <> 1)
                             then ri-gl
                             else
                             if remtrz.tcrc = 1
                             then ro-gl1
                             else ro-gl
                           ) +
                           vdel + remtrz.remtrz + " " + replace(
                           trim(remtrz.detpay[1]) +
                           trim(remtrz.detpay[2]) +
                           trim(remtrz.detpay[3]) +
                           trim(remtrz.detpay[4]) +
                           substr(remtrz.ord,1,35) +
                           substr(remtrz.ord,36,70) +
                           substr(remtrz.ord,71),"^"," ")  + vdel +
                           string(remtrz.svca)     + vdel +
                           trim(if remtrz.svca ne 0 then
                           remtrz.svcaaa else remtrz.dracc) +
                           vdel + string(remtrz.svccgl)   + vdel +
                           remtrz.remtrz + " " +
                           "Комиссия банка за перевод" .
                  if gl.sub = "cif" then do:
                     if remtrz.ptype ne "M" then shcode = "PSY0001".
                     else if remtrz.ptype eq "M" then do.
                           shcode = "PSY0039" .
                           if remtrz.ba = "011999832" and remtrz.rbank = "TXB00" then  do:
                              shcode = "PSY0046" .
                           end.
                           if remtrz.source = "IBH" and remtrz.rsub = "arp" and length(remtrz.cracc) = 20 then do:
                              shcode = "PSY0047".
                           end.
                           if shcode <> "PSY0047" then do:
                               vparam = remtrz.remtrz      + vdel +
                                        string(remtrz.amt) + vdel +
                                        remtrz.dracc         + vdel +
                                        remtrz.cracc  + vdel +
                                        remtrz.remtrz + " " + replace(
                                        trim(remtrz.detpay[1]) +
                                        trim(remtrz.detpay[2]) +
                                        trim(remtrz.detpay[3]) +
                                        trim(remtrz.detpay[4]) +
                                        substr(remtrz.ord,1,35) +
                                        substr(remtrz.ord,36,70) +
                                        substr(remtrz.ord,71),"^"," ")  + vdel +
                                        string(remtrz.svca)     + vdel +
                                        trim(if remtrz.svca ne 0
                                        then remtrz.svcaaa else remtrz.dracc)
                                        + vdel +  string(remtrz.svccgl)   + vdel +
                                        remtrz.remtrz + " " +
                                        "Комиссия банка за перевод" .
                           end. else do:
                               vparam = remtrz.remtrz      + vdel +
                                        string(remtrz.amt) + vdel +
                                        remtrz.dracc         + vdel +
                                        remtrz.cracc  + vdel +
                                        remtrz.remtrz + " " + replace(
                                        trim(remtrz.detpay[1]) +
                                        trim(remtrz.detpay[2]) +
                                        trim(remtrz.detpay[3]) +
                                        trim(remtrz.detpay[4]) +
                                        substr(remtrz.ord,1,35) +
                                        substr(remtrz.ord,36,70) +
                                        substr(remtrz.ord,71),"^"," ").
                           end.
                     end.
                  end. else if gl.sub = "arp" then shcode = "PSY0038".
                  run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).
            end.
         end.  else do.
              vparam = remtrz.remtrz
                  + vdel + string(remtrz.tcrc)
                  + vdel + string(getConvGL(remtrz.tcrc,"D"))
                  + vdel + (if remtrz.tcrc = 1 then ro-gl1 else ro-gl)
                  + vdel + string(remtrz.amt)
                  + vdel + remtrz.dracc
                  + vdel + string(getConvGL(remtrz.fcrc,"C"))
                  + vdel + remtrz.remtrz + " " + replace(
                       trim(remtrz.detpay[1]) +
                       trim(remtrz.detpay[2]) +
                       trim(remtrz.detpay[3]) +
                       trim(remtrz.detpay[4]) + ' ' +
                       substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) +
                       substr(remtrz.ord,71),"^"," ")
                  + vdel + string(remtrz.svca)
                  + vdel +(if remtrz.svca ne 0 then remtrz.svcaaa else remtrz.dracc)
                  + vdel + string(remtrz.svccgl) .
              shcode = "PSY0002" .
              run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz,output rcode,
                         output rdes,input-output s-jh).
              if rcode = 0 then  do:
                 run trxsim("", shcode,vdel,vparam,6,
                            output rcode1,output rdes1,output vsum) .
                 if rcode1 = 0 then remtrz.payment = decimal(vsum) .
                 else do:
                    v-text = remtrz.remtrz + " " + rdes1 .
                    run lgps .
                 end.
              end.
         end.
      end.
      else if lookup(remtrz.ptype,"3,7,5") ne 0  then do:
              vparam = remtrz.remtrz      + vdel +
                       string(remtrz.amt) + vdel +
                       remtrz.dracc         + vdel.
              if remtrz.rsub ne "451050" then do :
                 if remtrz.tcrc = 1 then vparam = vparam + ri-gl1 + vdel. else vparam = vparam + ri-gl + vdel.
              end.
              vparam = vparam + remtrz.remtrz + " " + replace(
                       trim(remtrz.detpay[1]) +
                       trim(remtrz.detpay[2]) +
                       trim(remtrz.detpay[3]) +
                       trim(remtrz.detpay[4]) +
                       substr(remtrz.ord,1,35) +
                       substr(remtrz.ord,36,70) +
                       substr(remtrz.ord,71),"^"," ").
              find first gl  where remtrz.drgl = gl.gl no-lock .
              if gl.sub = "dfb" and remtrz.rsub ne "451050" then  shcode = "PSY0027".
              else if gl.sub = "dfb" and remtrz.rsub eq "451050" then shcode = "PSY0028".
              else if gl.sub = "cif" and remtrz.rsub ne "451050" then shcode = "PSY0029".
              else if gl.sub = "cif" and remtrz.rsub eq "451050" then shcode = "PSY0030".
              run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).
      end.
      if remtrz.ptyp = "8" and remtrz.fcrc = remtrz.tcrc then do :
               vparam = remtrz.remtrz      + vdel +
                        string(remtrz.amt) + vdel +
                        remtrz.dracc + vdel + ro-gl1 + vdel +
                        remtrz.remtrz + " " + replace(
                        trim(remtrz.detpay[1]) +
                        trim(remtrz.detpay[2]) +
                        trim(remtrz.detpay[3]) +
                        trim(remtrz.detpay[4]) +
                        substr(remtrz.ord,1,35) +
                        substr(remtrz.ord,36,70) +
                        substr(remtrz.ord,71),"^"," ") .
               if gl.sub = "dfb" then shcode = "PSY0007".
               else if gl.sub = "cif" then shcode = "PSY0004".
               run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode,output rdes,input-output s-jh).
      end.
      if rcode > 0  then  do:
         v-text = " Ошибка 1 проводки rcode = " + string(rcode) + ":" + rdes + " " + remtrz.remtrz + " " + remtrz.dracc .
         run lgps.
         que.dp = today.
         que.tp = time.
         que.con = "F".
         if rcode = 28 then que.rcod = "2". else que.rcod = "1".
         return .
      end.
      find first jl where jl.jh = s-jh and jl.ln = 2 no-lock no-error.
      if avail jl then remtrz.info[10] = string(jl.gl) .
      if remtrz.info[9] eq "" then  remtrz.info[9]  = string(g-today) + " " +  remtrz.scbank .
      remtrz.info[6] = "TRXGEN " + shcode .
      v-text = string(s-jh) + " 1 проводка " + remtrz.remtrz + " тип = " +
               string(remtrz.ptype) +
               " " + remtrz.dracc + " " + string(remtrz.amt) +
               " Валюта = " +  string(remtrz.fcrc)  .
      if remtrz.ptype = "M"  then do:
         v-text  = v-text + '  2-TRX = 1-TRX' .
         remtrz.jh2  = s-jh.
      end.
      run lgps.
      que.dp = today.
      que.tp = time.
      que.con = "F".
      que.rcod = "0".
      remtrz.jh1 = s-jh.
/*****************Lyubov - создаем запись в pcpay, для зачисления ЗП**********************/
      if remtrz.ptype = 'M' then do:
      s-remtrz = remtrz.remtrz.
         find last jl where jl.jh = remtrz.jh1 no-lock no-error.
         if avail jl and jl.gl = 286012 then do:
            find first pcpay where pcpay.ref = remtrz.remtrz no-lock no-error.
            if not avail pcpay then do:
                run pcmt102.
                find first ttmps where ttmps.sstr begins ':21:1' no-lock no-error.
                if avail ttmps then v-str1 = ttmps.scnt.

                find last ttmps where ttmps.sstr begins ':21:' no-lock no-error.
                if avail ttmps then do:
                    coun = int(substr(ttmps.sstr,5)).
                    v-str2 = 0.
                    do l = 1 to coun:
                        find first ttmps where ttmps.sstr begins '/FM/' and ttmps.scnt > v-str1 no-lock no-error.
                        if avail ttmps then do:
                           pcfm = substr(ttmps.sstr,5).
                        end.
                        find first ttmps where ttmps.sstr begins '/NM/' and ttmps.scnt > v-str1 no-lock no-error.
                        if avail ttmps then do:
                           pcnm = substr(ttmps.sstr,5).
                        end.
                        find first ttmps where ttmps.sstr begins '/FT/' and ttmps.scnt > v-str1 no-lock no-error.
                        if avail ttmps then do:
                           pcft = substr(ttmps.sstr,5).
                        end.
                        find first ttmps where ttmps.sstr begins '/IDN/' and ttmps.scnt > v-str1 no-lock no-error.
                        if avail ttmps then do:
                           pciin = substr(ttmps.sstr,6).
                        end.
                        find first ttmps where ttmps.sstr begins '/LA/' and ttmps.scnt > v-str1 no-lock no-error.
                        if avail ttmps then do:
                           pcaaa = substr(ttmps.sstr,5).
                           v-str1 = ttmps.scnt.
                        end.
                        find first ttmps where ttmps.sstr begins ':32B:' and ttmps.scnt > v-str2 no-lock no-error.
                        if avail ttmps then do: displ sstr format 'x(20)'.
                           find first crc where crc.code = substr(ttmps.sstr,6,3) no-lock no-error.
                           if avail crc then pccrc = crc.crc.
                           pcamt = substr(ttmps.sstr,9).
                           pcamt = trim(replace(pcamt,',','.')).
                           v-str2 = ttmps.scnt.
                        end.
                        find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = pcaaa and payreturn.iin = pciin
                                               and payreturn.name = pcfm + ' ' + pcnm + ' ' + pcft no-lock no-error.
                        if not avail payreturn then do:
                            create pcpay.
                            assign pcpay.bank    = v-ourbank
                                   pcpay.aaa     = pcaaa
                                   pcpay.crc     = pccrc
                                   pcpay.amt     = deci(pcamt)
                                   pcpay.ref     = remtrz.remtrz + '_' + string(l)
                                   pcpay.jh      = s-jh
                                   pcpay.sts     = 'ready'
                                   pcpay.who     = g-ofc
                                   pcpay.whn     = g-today
                                   pcpay.info[1] = substr(v-ourbank,4,2).
                        end.
                    end.
                    for each payreturn where payreturn.rmz = remtrz.remtrz exclusive-lock:
                        s-jh1 = 0.
                        vparam = string(payreturn.amt) + vdel + string(remtrz.fcrc) + vdel + remtrz.racc + vdel + remtrz.sacc + vdel +
                                 'Возврат. Некорректные данные получателя. ' + payreturn.reason.
                        run trxgen('uni0018', vdel, vparam, "", "", output rcode, output rdes, input-output s-jh1).
                        if rcode = 0 then payreturn.jh = s-jh1.
                    end.
                end.
            end.
         end.
      end.
/*****************Lyubov - создаем запись в pcpay, для зачисления ЗП**********************/
      find first jh where jh.jh = remtrz.jh1 exclusive-lock no-error.
      chkbal = 0.
      for each jl of jh  exclusive-lock.
          if jl.dam > 0 then chkbal = chkbal + jl.dam .
                        else chkbal = chkbal - jl.cam .
          jl.sts = 6 .
      end .
      jh.sts = 6 .
      if chkbal ne 0 then do:
         v-text =
         remtrz.remtrz + " Ошибка ! Несбалансированная проводка ! ".
         que.rcod = "1".
         run lgps.
      end.
   end.
end.

