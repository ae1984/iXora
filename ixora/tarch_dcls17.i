/* tarch_dcls17.i
 * MODULE
        Вычмсление оборотов по переводным операциям
 * DESCRIPTION
        Отчет по общей сумме оборотов
 * RUN
        9-14-10
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        12/09/05 saltanat
 * CHANGES
*/  

{comm-txb.i}
{curs_conv.i}

def var v-cbank as char.
v-cbank = comm-txb ().


def var v-dict    as char initial "flg90".
def var v-dict2   as char initial "stmt".
def var v-amt90   like jl.dam.
def var v-amt90n  like jl.dam.
def var v-crc     like crc.crc initial 2.
def var v-f       as log.
def var v-amt     like jl.dam.
def var v-des     as char.
def var v-gl      like gl.gl.
def var v-branch  as char.

def new shared var s-jh like jh.jh.

def var jparr     as char.
def var vou-count as int.
def var i         as int.
def var v-templ   as char initial "cif0006".
def var v-str     as char.
def var v-balold  as dec.
def var v-intold  as dec.
def var v-rem     as char.
def var vbal      like jl.dam.
def var vavl      like jl.dam.
def var vhbal     like jl.dam.
def var vfbal     like jl.dam.
def var vcrline   like jl.dam.
def var vcrlused  like jl.dam.
def var vooo      like aaa.aaa.
def var v-payout  as logical.
def var v-err     as log.

def var v-jurfiz as char.

def temp-table wt2 
    field cif like cif.cif
    field kod like tarif2.str5
    field amt as deci 
index wt2 cif
index id kod.

def var v-arp as char.
def var v-aaa as char.
def var v-arplg as char.

def var v-self as logical.
def var v-rnn  as char.
def var v-i    as int.
 
def buffer cjl for jl.
def buffer caaa for aaa.

def var v-chgx   as char initial "009".  /* за ведение счета ЧП в тенге внутренние дебетовые проводки -1тг      */

find sysc where sysc = "ourbnk" no-error. /* Код банка,принятый в Прагме */
 if avail sysc then v-branch = sysc.chval. /*TXB00, TXB01 и т.д.*/

find sysc where sysc  = "arpdt" no-error .  /* Счет-искл (ARP) для плат карт */
 if available sysc then v-arp = sysc.chval. 

find sysc where sysc = "aaact" no-error.   /* Счет-искл (CIF) для плат карт  */
if available sysc then v-aaa = sysc.chval.

find sysc where sysc  = "arplg" no-error .  /* Счет-искл (ARP) для плат карт на филиалах */
 if available sysc then v-arplg = sysc.chval. 
 else v-arplg = ''.


/*******************************************************************************************/

for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.sub eq "CIF" and jl.lev eq 1 no-lock use-index jdtlevsub:

    v-f = yes.
    /*****************************************************************************************************************************************/
    if lookup(string(jl.gl),v-aaa) > 0 then 
    do: /*если счет принадлежит к счету исключения для клиентов и снятия идут с льготного АРП-счета - например, карточники переводы делают коммерсантам */
        find bjl where bjl.jh = jl.jh and bjl.sub = "ARP" and bjl.lev = 1  and lookup(string(bjl.gl),v-arp) > 0 and bjl.dc = (if jl.dc = "c" then "d" else "c")  no-lock no-error. 
        if available bjl then v-f = no.
        else if v-cbank ne 'TXB00' then do: /* если счет принадлежит к счету искл. кл. и перевод клиенту осущ-ся на филиале с льгот. транз. счета платежных карт Ц.О. */
                find remtrz where remtrz.rdt <= jl.jdt and remtrz.sbank = 'TXB00' and lookup(remtrz.sacc,v-arplg) > 0 and remtrz.jh2 = jl.jh  no-lock no-error.
            if avail remtrz then v-f = no.
        end.

    end.
    /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    if jl.rem[1] begins "Storno" then v-f = no.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    find trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.trxt = 0 and trxcods.codfr = v-dict no-lock no-error.
        if available trxcods then 
    do:
            if trxcods.code eq "no" then v-f = no.
    end.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    find trxcods where trxcods.trxh eq jl.jh and trxcods.trxln eq jl.ln and trxcods.trxt eq 0 and trxcods.codfr eq v-dict2 no-lock no-error.
        if available trxcods then 
    do:
            if trxcods.code begins "chg" then v-f = no.
    end.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    if jl.rem[1] begins "Storno" or jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then v-f = no.
        /*****************************************************************************************************************************************/    
        /*****************************************************************************************************************************************/
    if not v-f then next.

    /* Интернет платежи будем обрабатывать отдельно в dcls18.p */
    find jh where jh.jh = jl.jh no-lock no-error.
    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
    if avail remtrz and remtrz.source = "IBH" and v-cbank = "TXB00" and remtrz.ptype <> "M"  then next.

/*если все проверки прошли, то идем дальше*/
find aaa where aaa.aaa = jl.acc no-lock no-error. /*а есть ли вообще такой счет?*/
if not available aaa then next. /*если не найден то переходим на следующую проводку */

find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
if not available sub-cod then next. /* Убрала проверку на юр лиц в Алмате, т.к. берем комиссии для физ лиц тоже. */
v-jurfiz = sub-cod.ccode. /* Запоминаем статус клиента */

find sub-cod where sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" and sub-cod.acc = aaa.aaa no-lock no-error. /*льготный счет ?*/
if available sub-cod and sub-cod.ccode = "no" then next. /*счет льготный, выходим*/

find jh where jh.jh = jl.jh no-lock no-error.

find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
v-payout = (avail remtrz and remtrz.ptype <> "M").  /* YES = платеж внешний */
v-err = no.

 /* 15.08.2005 saltanat - Разделяю расчет по статусам клиента */
if v-jurfiz = "0" then do:
/* ---------- ЮРИДИЧЕСКИЕ ЛИЦА ----------- */
if jl.dc = "D" then do:
   if jl.crc = 1 then do: /*****************************************************************************************************************************************/
      if v-payout then do:  /* дебет тенге внешний */                            
        /* 17.11.2004 saltanat - Для платежей со штрих кодами другая комиссия  *  * */
         if remtrz.source = 'SCN' then do: /* дебет тенге внешний с штрих-кодом */                                  
            if remtrz.valdt2 > g-today then do:
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '022' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '022'. end.
                wt2.amt = wt2.amt + jl.dam.                       
            end.   

            if remtrz.valdt2 = g-today then do:
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '012' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '012'. end.
                wt2.amt = wt2.amt + jl.dam.                       
            end.
         end. /* дебет тенге внешний с штрих-кодом */
         else do: /* дебет тенге внешний без штрих-кода */
            if remtrz.valdt2 = g-today then do:
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '163' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '163'. end.
                wt2.amt = wt2.amt + jl.dam.                       
            end.

            if remtrz.valdt2 > g-today then do:
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '170' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '170'. end.
                wt2.amt = wt2.amt + jl.dam.                       
            end.
         end. /* дебет тенге внешний без штрих-кода */
   end.
   else  
      do: /* дебет тенге внутренний */
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '141' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '141'. end.
                wt2.amt = wt2.amt + jl.dam.                       
      end.
  end. /*jl.crc =1 *****************************************************************************************************************************************/
  else /*это валюта*/
  do:
     if v-payout then do: /* дебет валюта внешний */
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '167' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '167'. end.
				find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
		        if avail crchis then 
                wt2.amt = wt2.amt + jl.dam * crchis.rate[1].                       
     end.
     else do: 
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '165' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '165'. end.
				find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
		        if avail crchis then 
                wt2.amt = wt2.amt + jl.dam * crchis.rate[1].                       

     end.
   end.                            
end. /* "D" */
if jl.dc = "C" then do: 
   if jl.crc = 1 then do:
      if v-payout then do: /* кредит тенге внешний */
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '164' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '164'. end.
                wt2.amt = wt2.amt + jl.cam.                       
      end.
      else do: /* кредит тенге внутренний */
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '142' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '142'. end.
                wt2.amt = wt2.amt + jl.cam.                       
      end.
   end. /*jl.crc = 1*/
   else /*это валюта*/
   do:
      if v-payout then do: /* кредит валюта внешний */ 
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '168' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '168'. end.
				find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
		        if avail crchis then 
                wt2.amt = wt2.amt + jl.cam * crchis.rate[1].                       
      end.
      else do: /* кредит валюта внутренний */
				find wt2 where wt2.cif = aaa.cif and wt2.kod = '166' no-error.
				if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '166'. end.
				find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
		        if avail crchis then 
                wt2.amt = wt2.amt + jl.cam * crchis.rate[1].                       
      end.
  end. /*это валюта*/
end. /* "C" */
end. /* юр. лицо */
else if v-jurfiz = "1" then do:
/* ---------- ФИЗИЧЕСКИЕ ЛИЦА ----------- */                       
if jl.dc = "D" then do:
 /* 22.08.2005 saltanat - Если это внутренний перевод и осущ-ся одним клиентом, то комиссия не взимается */
   v-self = no.
   if not v-payout then do: /* внутренний платеж */
                        for each cjl where cjl.jh = jl.jh and cjl.dc = 'c' no-lock.
                                   if cjl.acc ne '' then do:
                                      find caaa where caaa.aaa = cjl.acc no-lock no-error.
                                      if avail caaa then do:
                                         if aaa.cif = caaa.cif then do: v-self = yes. leave. end.
                                      end.
                                   end.
                               end.
                            end.
                            else do: /* внешний платеж */
                               if remtrz.rbank begins 'TXB' then do: /* расматриваются платежи по сети Банка */
        						  v-rnn = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
								  v-i = index(v-rnn,'RNN').
								  if v-i > 0 then do:
                                     find cif where cif.cif = aaa.cif no-lock no-error.
                                     if avail cif then do:
                                        if substring(v-rnn,v-i + 4,12) = cif.jss then v-self = yes.
                                     end.   
								  end.
                               end. /* TXB */
   end.
                               
   if v-self then next. /* Если платеж одного клиента */
                                                                                                 
                            if jl.crc = 1 then 
                            do: /*****************************************************************************************************************************************/
                                if v-payout then 
                                do:  /* дебет тенге внешний */
                                                                
                                  if remtrz.source ne 'SCN' then do: /* дебет тенге внешний без штрих-кода */                                    
                                    if remtrz.valdt2 = g-today then do:
										find wt2 where wt2.cif = aaa.cif and wt2.kod = '212' no-error.
										if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '212'. end.
						                wt2.amt = wt2.amt + jl.dam.                       
                                     end.
                                  end. /* дебет тенге внешний без штрих-кода */
                                end.
                                else  
                                do: /* дебет тенге внутренний */
									/* 16.08.2005 saltanat - Включила проверку : 1. операция д.б. м/у клиентами банка 
                                    		                                     2. не брать комиссий с кассовых операций */
				                	     if (avail remtrz) and (not (remtrz.rbank begins 'TXB')) then next.
                            
                                         find first cjl where cjl.jh = jl.jh and cjl.dc = 'c' and (cjl.gl = 100100 or cjl.gl = 100200) no-lock no-error.
                                         if avail cjl then next.
                                           
										find wt2 where wt2.cif = aaa.cif and wt2.kod = '230' no-error.
										if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '230'. end.
						                wt2.amt = wt2.amt + jl.dam.                       
                                end.
                            end. /*jl.crc =1 *****************************************************************************************************************************************/
                            else /*это валюта*/
                            do:
                                if not v-payout then do: /* дебет валюта внутренний */ 
									/* 16.08.2005 saltanat - Включила проверку : 1. операция д.б. м/у клиентами банка 
                                    		                                     2. не брать комиссий с кассовых операций */
				                	     if (avail remtrz) and (not (remtrz.rbank begins 'TXB')) then next.
                            
                                         find first cjl where cjl.jh = jl.jh and cjl.dc = 'c' and (cjl.gl = 100100 or cjl.gl = 100200) no-lock no-error.
                                         if avail cjl then next.

										find wt2 where wt2.cif = aaa.cif and wt2.kod = '230' no-error.
										if not available wt2 then do: create wt2. wt2.cif = aaa.cif. wt2.kod = '230'. end.
										find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
								        if avail crchis then 
						                wt2.amt = wt2.amt + jl.dam * crchis.rate[1].                       
                                end.
                            end. /* валюта */ 
                        end. /* "D" */                          
end. /* физ. лицо */ 
end. /*for each jl*/
