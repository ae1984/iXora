/* eknp_dat.i
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
        11.06.2004 nadejda - все поменяла в связи с изменением отчета по постановлению НБ РК
                             теперь берутся только корсчета (ГК 1052), БИК можно не писать при некоторых условиях,
                             все в тенге
                             и в конце должна отражаться курсовая разница

        30.07.2004 sasco - поменял местами 10 и 11 символы (просто так всегда совпадает)
                         - вывод пропущенных проводок в отдельный файл

        05.08.2004 sasco - добавил обработку JOU
        05.05.2005 sasco - дополнительные проверки
        07.06.2005 sasco - проверки на наличие КНП в справочнике
        10/10/05 nataly  - ускорила процесс поиска jl
        12/10/05 nataly  - вставила проверку на наличие страны в случае, когда сек эк-ки 1-2 или 2-1 
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        01.09.2010 marinav - изменение БИКа
*/


{get-dep.i}

def var s_locat as char format "x(1)".
def var s_secek like s_locat.
def var r_locat like s_locat.
def var r_secek like s_locat.
def var knp$ as char format "x(3)".
def var v-jh as int format ">>>>>>>>>".
def var v-who as char format "x(8)".
def var v-sbank as char format "x(12)".
def var v-rbank like v-sbank.
def var v-cbank like v-sbank.
def var v-bank like v-sbank.
def var v-bank2 like v-sbank.
def var v-bank2cnt as char format 'x(2)'.
def var i as int.
def var v-country as char format 'x(2)'.
def var v-cntcbank as char format 'x(2)'.
def var v-cbnk2cbnk as char.
def var v-dc as char.
def var v-sum as deci.
def var v-exit as logical.

def var v-dt as date.
def buffer b-jl for jl.
def temp-table t-crc like crc.

unix silent touch eknpnull.csv.
unix silent rm eknpnull.csv.
  def stream rpt.
  output stream rpt to 'error.csv'.

do v-dt = v-dtb to v-dte:
  hide message no-pause.
  message " Обработка " v-dt.

  for each t-crc: delete t-crc. end.
  for each crc where crc.crc > 1 no-lock:
    find last crchis where crchis.crc = crc.crc and crchis.rdt <= v-dt no-lock no-error.
    if avail crchis then do:
       create t-crc.
       buffer-copy crchis to t-crc.
    end.
  end.

  do i = 1 to num-entries  (v-gllistL) :
  for each jl where /*jl.jh = 442591 and*/ jl.jdt = v-dt  and string(jl.gl) begins entry (i,v-gllistL) use-index jdt no-lock: 


      v-jh = 0.
      v-who = jl.who.
      find jh where jh.jh = jl.jh no-lock no-error.

      v-cbnk2cbnk = "".
      s_locat = "".
      s_secek = "".
      r_locat = "".
      r_secek = "".
      knp$ = "".
      v-bank2cnt = "".

      case jh.sub :
      when "rmz" then do:
          find remtrz where remtrz.remtrz = substr(jh.party, 1, 10) no-lock no-error.
          if jl.dc = 'C' then v-jh = remtrz.jh1.
                         else v-jh = remtrz.jh2.
          find jh where jh.jh = v-jh no-lock no-error.
          v-who = jh.who.

          v-bank = remtrz.sbank.
          if v-bank begins "TXB" then do: 
              v-sbank = v-ourbic.
          end.
          else do: 
              find bankl where bankl.bank = v-bank no-lock.
              v-sbank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
              if v-sbank = "" then v-sbank = bankl.bank.
              v-bank2 = v-bank.
              v-bank2cnt = bankl.frbno.
          end.

          v-bank = remtrz.rbank.
          if v-bank begins "TXB" then do: 
              v-rbank = v-ourbic.
          end.
          else do: 
              find bankl where bankl.bank = v-bank no-lock.
              v-rbank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
              if v-rbank = "" then v-rbank = bankl.bank.
              v-bank2 = v-bank.
              v-bank2cnt = bankl.frbno.
          end.


          v-cntcbank = "".
          v-cbank = "".
          if lookup(remtrz.ptype, "2,6,M" /* исход */  ) > 0 then v-cbank = remtrz.rcbank.
          else do:
            if lookup(remtrz.ptype, "5,7" /* вход */  ) > 0 then v-cbank = remtrz.scbank.
            else do: 
              if remtrz.ptype = "4" then do:
                 find bankt where bankt.acc = remtrz.dracc and not bankt.cbank begins "txb" no-lock no-error.
                 if avail bankt then do:
                    find bankl where bankl.bank = bankt.cbank no-lock.
                    if bankl.bank begins "TXB" 
                    then v-bank = v-ourbic.
                    else do: 
                         v-sbank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
                         if v-sbank = "" then v-bank = bankl.bank.
                         v-bank2 = bankl.bank.
                         v-bank2cnt = bankl.frbno.
                         v-cbank = bankl.bank.
                    end.
                 end.
                 find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                 if avail aaa then assign v-cntcbank = 'KZ' v-bank2 = remtrz.scbank  v-bank2cnt = 'KZ'.
              end. 
              else do: 
                 if remtrz.ptype = "3" then do:
                    find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
                    if avail aaa then assign v-cntcbank = 'KZ' v-bank2 = remtrz.rcbank  v-cbank = remtrz.rcbank v-bank2cnt = 'KZ'.
                 end.
              end. 
            end.
          end.
          if v-cbank <> "" then do:
            find bankl where bankl.bank = v-cbank no-lock no-error.
            v-cntcbank = bankl.frbno.   
            if remtrz.ptype = "M" then assign v-bank2 = v-cbank  v-bank2cnt = bankl.frbno.
          end.
          if remtrz.ptype = "5" then do:
            /* входящий платеж на филиал - взять ЕКНП и страну с филиала */
            find txb where txb.consolid and txb.bank = remtrz.rbank no-lock no-error.
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
            run eknp_fil (remtrz.remtrz, remtrz.racc, remtrz.amt, output s_locat, output s_secek, output r_locat, output r_secek, output knp$, output v-country).
            disconnect "txb".
          end.

          if s_locat = "" or r_locat = "" or s_secek = "" or r_secek = "" or knp$ = "" then do:
            find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
            if available sub-cod and sub-cod.ccode = "eknp" and num-entries(sub-cod.rcode) = 3 then do:
                if s_locat = "" then s_locat = substr(sub-cod.rcode, 1, 1).
                if s_secek = "" then s_secek = substr(sub-cod.rcode, 2, 1).
                if r_locat = "" then r_locat = substr(sub-cod.rcode, 4, 1).
                if r_secek = "" then r_secek = substr(sub-cod.rcode, 5, 1).
                if knp$ = "" then knp$ = substr(sub-cod.rcode, 7, 3).
            end.
          end.

          if v-country = "" then do:
            find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "iso3166" no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> "msc" then do: 
                v-country = sub-cod.ccode.
            end.
          end.
 /* message  'rmz ' v-bank2cnt v-cntcbank view-as alert-box.*/

      end.
      when "ujo" or when "jou"  or when " " then do:
        v-bank = "банк не найден".
        find bankt where bankt.acc = jl.acc and not bankt.cbank begins "txb" no-lock no-error.
        if avail bankt then  do:
          find bankl where bankl.bank = bankt.cbank no-lock.
          if bankl.bank begins "TXB" then 
            v-bank = v-ourbic.
          else do: 
            v-bank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
            if v-bank = "" then v-bank = bankl.bank.
            v-bank2 = bankl.bank.
            v-bank2cnt = bankl.frbno.
          end.
         
          v-exit = no.
          v-dc = if jl.dc = "c" then "d" else "c".
          for each b-jl where b-jl.jh = jl.jh and b-jl.ln <> jl.ln no-lock use-index jhln:
            if b-jl.dc = v-dc and b-jl.sub = "dfb" /*and (b-jl.cam + b-jl.dam) = (jl.dam + jl.cam)*/ then do:
              /* корсчет-корсчет по корбанкам рез-рез и нерез-нерез - такие проводки вообще не учитываем ! */
              v-cbnk2cbnk = "1".

              find bankt where bankt.acc = b-jl.acc and not bankt.cbank begins "txb"  no-lock no-error.
              if avail bankt then do:
                find bankl where bankl.bank = bankt.cbank no-lock no-error.
                v-exit = (v-bank2cnt = "kz" and bankl.frbno = "kz") or 
                         (v-bank2 <> "" and v-bank2cnt <> "kz" and bankl.frbno <> "kz").
              end.
              leave.
            end.
          end.
          /* корсчет-корсчет по корбанкам рез-рез и нерез-нерез - такие проводки вообще не учитываем ! */
          if v-exit then do: 
	  
	     find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt no-lock no-error.

             output to eknp_skip.txt append.
	     put unformatted jl.gl " " jl.jh " " jl.acc " " jl.crc " " jl.cam " " jl.dam " " crchis.rate[1] " "
	     (jl.dam + jl.cam) * crchis.rate[1] skip.
             output close.
             next.
	     
	  end.

          if jl.dc = "c" then do:
            v-rbank = v-bank.
            v-sbank = v-ourbic.
          end.
          else do:
            v-sbank = v-bank.
            v-rbank = v-ourbic.
          end.
          v-country = bankl.frbno.
          v-cbank = "==".
          v-cntcbank = v-country.
    end.      
/* message v-ourbic jl.dc v-sbank view-as alert-box.*/
        /* ЕКНП */
        s_locat = "".
        s_secek = "".
        r_locat = "".
        r_secek = "".
        knp$ = "".
        find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.codfr = "locat" no-lock no-error.
        if avail trxcods then do:
          if jl.dc = "d" then s_locat = trxcods.code. 
                         else r_locat = trxcods.code.
        end.
        find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.codfr = "secek" no-lock no-error.
        if avail trxcods then do:
          if jl.dc = "d" then s_secek = trxcods.code. 
                         else r_secek = trxcods.code.
        end.

        for each b-jl where b-jl.jh = jl.jh and b-jl.ln <> jl.ln no-lock use-index jhln:
          find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = "locat" no-lock no-error.
          if avail trxcods then do:
            if b-jl.dc = "d" then s_locat = trxcods.code. 
                             else r_locat = trxcods.code.
          end.
          find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = "secek" no-lock no-error.
          if avail trxcods then do:
            if b-jl.dc = "d" then s_secek = trxcods.code. 
                             else r_secek = trxcods.code.
          end.
        end.

        find first trxcods where trxcods.trxh = jl.jh and /*trxcods.trxln = jl.ln and*/ trxcods.codfr = "spnpl" no-lock no-error.
        if avail trxcods then knp$ = trxcods.code.
        /* если это пополнение корсчета - КНП по дебету 321, по кредиту 311 */
        if jl.trx = "uni0046" then do:
          if jl.dc = "c" then knp$ = "321".
                         else knp$ = "311".
        end.

        /* если это пополнение корсчета - страна всегда KZ */
        if v-country = "" and (jl.trx = "uni0046" or 
           (s_locat = "1" and r_locat = "1" and s_secek = "4" and r_secek = "4" and jl.rem[1] begins "пополнение")) then do:
          v-country = "KZ".
          v-cntcbank = v-country.
          v-bank2cnt = v-country.
        end.

 /* message  'jou - ' jl.jh ' - ' v-bank2cnt ' - ' v-cntcbank ' - ' v-cbank ' - ' v-sbank ' - ' v-cbnk2cbnk view-as alert-box.*/

      end.
      otherwise do:
        message "no sub " jh.jh jh.sub. pause 50.
      end.
      end case.
      

      if s_locat = "" and lookup(jl.trx, "uni0134,scu0019") > 0 then s_locat = "1".
      if s_secek = "" and lookup(jl.trx, "uni0134,scu0019") > 0 then s_secek = "4".
      if r_locat = "" and lookup(jl.trx, "uni0134,scu0019") > 0 then r_locat = "2".
      if r_secek = "" and lookup(jl.trx, "uni0134,scu0019") > 0 then r_secek = "4".
      if knp$ = "" then 
        case jl.trx :
          when "uni0134" then knp$ = "150".
          when "scu0019" then knp$ = "623".
        end case.

      
      find crc where crc.crc = jl.crc no-lock no-error.

      create t-eknp.
      t-eknp.jdt = jl.jdt.
      t-eknp.acc = jl.acc.
      t-eknp.sub = jh.sub.
      t-eknp.sbank = v-sbank.
      t-eknp.rbank = v-rbank.
      t-eknp.cbank = v-cbank.
      t-eknp.bank2 = v-bank2.
      t-eknp.bank2cnt = v-bank2cnt.
      t-eknp.crc = jl.crc.
      t-eknp.crcode = crc.code.
      t-eknp.jh1 = jl.jh.
      t-eknp.jh2 = v-jh.
      t-eknp.gl = jl.gl.
      t-eknp.dam = jl.dam.
      t-eknp.cam = jl.cam.

      if jl.crc = 1 then t-eknp.sumkzt = jl.dam + jl.cam.
      else do:
        find t-crc where t-crc.crc = jl.crc no-lock no-error.
        t-eknp.sumkzt = round((jl.dam + jl.cam) * t-crc.rate[1] / t-crc.rate[9], 2).
      end.

      t-eknp.s_locat = int(s_locat).
      t-eknp.s_secek = int(s_secek).
      t-eknp.r_locat = int(r_locat).
      t-eknp.r_secek = int(r_secek).
      t-eknp.knp =  knp$. /*int(knp$).*/
      t-eknp.cnt = caps(v-country).
      t-eknp.cntcbank = caps(v-cntcbank).
      t-eknp.rem = jl.rem[1].
      t-eknp.who = v-who.
      t-eknp.cbnk2cbnk = v-cbnk2cbnk.

      /*если проводки типа 1-2 или 2-1 страна должна быть ! */
  if t-eknp.s_locat <> t-eknp.r_locat and t-eknp.cnt = ""  then do:
     if substr(t-eknp.sbank,5,2) = 'KZ' and substr(t-eknp.rbank,5,2) = 'KZ' then t-eknp.cnt = 'KZ'.
     if t-eknp.cnt = "" then put stream rpt unformatted 
           "/INFO/" t-eknp.sbanksend 
           "//" t-eknp.rbanksend 
           "/" t-eknp.s_locat 
           "/" t-eknp.s_secek 
           "/" t-eknp.r_locat 
           "/" t-eknp.r_secek 
           "/" t-eknp.knp    format "999"
           "/" trim(replace(string(t-eknp.dam,"->>>>>>>>>>9.99"),".",",")) 
           "/" trim(replace(string(t-eknp.cam,"->>>>>>>>>>9.99"),".",",")) 
           "/" caps(t-eknp.crcode) 
           "/" caps(t-eknp.cntsend) skip.

      if t-eknp.cnt = "" then put stream rpt unformatted  'no country! - проводка - ' t-eknp.jh1 skip.
  end.

      /*если проводки типа 1-1 или 2-2 страны не должно быть ! */
  if t-eknp.s_locat = t-eknp.r_locat and t-eknp.cnt <> ""  then t-eknp.cnt = ''.
     
      if v-sbank = v-ourbic then do:
        if (v-bank2cnt = "kz" and v-cntcbank = "kz") or (v-bank2cnt <> "kz" and v-cntcbank <> "kz") then do:
          if v-bank2cnt = "kz" then do:
            if ((v-cbank = v-rbank) and (s_locat = "1" and r_locat = "1" and s_secek = "4" and r_secek = "4")) or
               v-cbnk2cbnk = "1"
              then t-eknp.ptype = 14. 
              else t-eknp.ptype = 1.
          end.
          else do:
            if ((v-cbank = v-rbank) and (s_locat = "1" and r_locat = "1" and s_secek = "4" and r_secek = "4")) or
               v-cbnk2cbnk = "1"
              then t-eknp.ptype = 16.
              else t-eknp.ptype = 2.
          end.
        end.
        else do:
          if v-bank2cnt = "kz" then t-eknp.ptype = 14.
                               else t-eknp.ptype = 16.
        end.
      end.
      else do:
        if (v-bank2cnt = "kz" and v-cntcbank = "kz") or (v-bank2cnt <> "kz" and v-cntcbank <> "kz") then do:
          if v-bank2cnt = "kz" then do:
            if ((v-cbank = v-sbank) and (s_locat = "1" and r_locat = "1" and s_secek = "4" and r_secek = "4") ) or
               v-cbnk2cbnk = "1"
              then t-eknp.ptype = 15.
              else t-eknp.ptype = 9.
          end.
          else do:
            if ((v-cbank = v-sbank) and (s_locat = "1" and r_locat = "1" and s_secek = "4" and r_secek = "4") ) or
               v-cbnk2cbnk = "1"
              then do:
                t-eknp.ptype = 17.
                /*if knp$ = "321" then t-eknp.s_locat = 2.*/
              end.
              else t-eknp.ptype = 3.
          end.
        end.
        else do:
          if v-bank2cnt = "kz" then t-eknp.ptype = 15.
                               else t-eknp.ptype = 13.
        end.
      end.


      if jl.gl = 201300 then do:
         find first aaa where aaa.aaa = jl.acc no-lock no-error.
         if avail aaa and aaa.name matches "*Kassa Nova*" then do:   
            if jl.dc = 'd' then t-eknp.ptype = 1.
            if jl.dc = 'c' then do:
               t-eknp.ptype = 9.
               find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
               if avail b-jl and b-jl.sub = 'dfb' then do:
                  find bankt where bankt.acc = b-jl.acc no-lock no-error.
                  if avail bankt then do:
                     find bankl where bankl.bank = bankt.cbank no-lock no-error.
                     if bankl.frbno ne "kz" and bankl.frbno ne "" then  t-eknp.ptype = 13.
                     t-eknp.sbank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
                     t-eknp.sbanksend = t-eknp.sbank. 
                  end.
               end.
            end.
         end.   
      end.   

      /* проставить посылаемые данные БИКов и стран */
      if not t-eknp.sbank begins "-" then t-eknp.sbanksend = t-eknp.sbank.
      if not t-eknp.rbank begins "-" then t-eknp.rbanksend = t-eknp.rbank.
      t-eknp.cntsend = t-eknp.cnt.

/*
      / * если это снятия/размещения депозита на корсчете, то оба банка = банк-корр * /
      if lookup(t-eknp.ptype, "14,15,16,17") > 0 anf lookup(t-eknp.knp, "311,321") > 0 then do:
        if t-eknp.rbanksend = v-ourbic then t-eknp.rbanksend = t-eknp.sbanksend.
        else 
          if t-eknp.sbanksend = v-ourbic then t-eknp.sbanksend = t-eknp.rbanksend.
      end.
*/
      /* если платеж через корбанк-нерезидент, то не нужно писать БИК банка-партнера */
      if t-eknp.cntcbank <> "kz" then do:
        /* платеж исходящий */
        if t-eknp.ptype = 2 or t-eknp.ptype = 12 then t-eknp.rbanksend = "".
        /* платеж входящий */
        if t-eknp.ptype = 3 or t-eknp.ptype = 13 then t-eknp.sbanksend = "".
      end.
      /* */
      if t-eknp.ptype = 17 and t-eknp.rbank begins "-" then t-eknp.sbanksend = "".

      /* вообще не будем банк ставить, а то телеграмма не проходит */
      if t-eknp.ptype = 16 and t-eknp.knp = '321' and t-eknp.s_locat = 2 then do:
        t-eknp.sbanksend = "".
        t-eknp.rbanksend = "".
      end.

      /* если оба резиденты или оба нерезиденты - страну ставить не надо */
      if (t-eknp.s_locat = 1 and t-eknp.r_locat = 1) or (t-eknp.s_locat = 2 and t-eknp.r_locat = 2) then 
        t-eknp.cntsend = "".

      if t-eknp.ptype = 9 or t-eknp.ptype = 17 then t-eknp.rbanksend = v-ourbic.

      /* 05-05-05 sasco дополнительные проверки */
      /* проверка на нулевые значения ЕНКП */
      if t-eknp.s_locat = 0 or t-eknp.s_secek = 0 or t-eknp.r_locat = 0 or t-eknp.r_secek = 0 or t-eknp.knp = "" then do:
         output to eknpnull.csv append.
         export delimiter ";" t-eknp.
         output close.
         delete t-eknp.
      end.
      else do:
        find codfr where codfr.codfr = "spnpl" and codfr.code = string (t-eknp.knp, "999") no-lock no-error.
        if not avail codfr then do:
           output to eknpnull.csv append.
           export delimiter ";" t-eknp.
           output close.
           delete t-eknp.
        end.
        else do: /* проверки на наш БИК */
           if t-eknp.ptype = 3 or t-eknp.ptype = 13 then assign t-eknp.sbanksend = "" t-eknp.rbanksend = v-ourbic.
           if t-eknp.ptype = 2 then assign t-eknp.sbanksend = v-ourbic t-eknp.rbanksend = "".
           if t-eknp.ptype = 9 then assign t-eknp.rbanksend = v-ourbic.
           /* проверка на страну */
           if t-eknp.s_locat <> t-eknp.r_locat and t-eknp.cnt = "" then do:
                if t-eknp.crc = 2 then  t-eknp.cnt = "US".
                 else  if t-eknp.crc = 4 then  t-eknp.cnt = "RU".
                  else if t-eknp.crc = 3 then  t-eknp.cnt = "DE".
                    else t-eknp.cnt = "ERROR".
              end.
           /* <- 05-05-05 */


           /* проверка на несовпадение данных */
           if ((t-eknp.sbank = v-ourbic and 
                ((t-eknp.r_locat = 2 and t-eknp.cnt = "kz") or 
                 (t-eknp.r_locat = 1 and t-eknp.cnt <> "kz"))) or
               (t-eknp.rbank = v-ourbic and 
                ((t-eknp.s_locat = 2 and t-eknp.cnt = "kz") or 
                 (t-eknp.s_locat = 1 and t-eknp.cnt <> "kz")))) and 
              (get-dep(t-eknp.who, t-eknp.jdt) = 1 and 
               can-find (ofc where ofc.ofc = t-eknp.who and lookup(ofc.titcd, "103,506") = 0 no-lock)) 
              then t-eknp.errors = "несовпадение данных др.банка и страны".  /* ОПЕРУ не считаем */
        end. /* проверки на БИК */

        /* проверки на резидентов-нерезидентов */
        if t-eknp.s_locat <> t-eknp.r_locat and t-eknp.cnt = "" then do:
           t-eknp.cnt = "НЕТ СТРАНЫ". 
           if t-eknp.ptype = 3 then t-eknp.cnt = "kz".
        end.
        if t-eknp.s_locat = t-eknp.r_locat then t-eknp.cnt = "".

        /* корректировка БИКов */
        if t-eknp.ptype = 2 then assign t-eknp.sbanksend = v-ourbic t-eknp.rbanksend = "".
        if t-eknp.ptype = 3 or t-eknp.ptype = 13 then assign t-eknp.sbanksend = "" t-eknp.rbanksend = v-ourbic.

        if t-eknp.ptype = 17 then assign t-eknp.sbanksend = "" t-eknp.rbanksend = "".

/*nataly 12/10/05 */
         if t-eknp.ptype = 9 and t-eknp.sbank begins "-"  then assign t-eknp.sbanksend =  substr(t-eknp.sbank,3,9).
         if t-eknp.ptype = 1 and t-eknp.rbank begins "-"  then assign t-eknp.rbanksend =  substr(t-eknp.rbank,3,9).
         if t-eknp.ptype = 15 and t-eknp.sbanksend  = ""  then assign t-eknp.sbanksend =  substr(t-eknp.sbank,3,9).

         find FIRST bankl where bankl.bank = t-eknp.sbanksend no-lock no-error.
         if avail bankl and bankl.addr[3] ne "" then t-eknp.sbanksend = bankl.addr[3].


      end.
      v-sbank = "".
      v-rbank = "".
      v-bank2 = "".
      v-country = "".
      v-cbank = "".
      v-cntcbank = "".
      v-cbnk2cbnk = "".
  end.    
end. /*glist*/
end . /*jl*/

for each t-eknp break by t-eknp.acc:
  if t-eknp.crc = 1 then next.

  v-sum = t-eknp.sumkzt.
  if t-eknp.cam > 0 then v-sum = - v-sum.
  accum v-sum (sub-total by t-eknp.acc).
  if last-of(t-eknp.acc) then do:
    create t-corracc.
    t-corracc.gl = t-eknp.gl.
    t-corracc.acc = t-eknp.acc.
    t-corracc.crc = t-eknp.crc.
    t-corracc.sum = accum sub-total by t-eknp.acc v-sum.

    find last hisdfb where hisdfb.dfb = t-eknp.acc and hisdfb.fdt < v-dtb no-lock no-error.
    if avail hisdfb then t-corracc.balb = hisdfb.dam[1] -  hisdfb.cam[1].
                    else do:
                        find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = t-eknp.acc and histrxbal.lev = 1 and histrxbal.dt < v-dtb no-lock no-error.
                        if avail histrxbal then t-corracc.balb = histrxbal.dam - histrxbal.cam.                      
                    end.
    if t-corracc.balb <> 0 then do:
      find last crchis where crchis.crc = t-corracc.crc and crchis.rdt < v-dtb no-lock no-error.
      t-corracc.balbkzt = t-corracc.balb * crchis.rate[1] / crchis.rate[9].
    end.

    find last hisdfb where hisdfb.dfb = t-eknp.acc and hisdfb.fdt <= v-dte no-lock no-error.
    if avail hisdfb then t-corracc.bale = hisdfb.dam[1] -  hisdfb.cam[1].
                    else do:
                        find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = t-eknp.acc and histrxbal.lev = 1 and histrxbal.dt <= v-dte no-lock no-error.
                        if avail histrxbal then t-corracc.bale = histrxbal.dam - histrxbal.cam.                      
                    end.
    if t-corracc.bale <> 0 then do:
      find last crchis where crchis.crc = t-corracc.crc and crchis.rdt <= v-dte no-lock no-error.
      t-corracc.balekzt = t-corracc.bale * crchis.rate[1] / crchis.rate[9].
    end.

    t-corracc.balcurs = t-corracc.balekzt - (t-corracc.balbkzt + t-corracc.sum).

    find bankt where bankt.acc = t-eknp.acc and not bankt.cbank begins "txb" no-lock no-error.
    if avail bankt then do:
      find bankl where bankl.bank = bankt.cbank no-lock.
      v-bank = if bankl.frbno = "KZ" then bankl.addr[3] else left-trim(bankl.bic, '0').
/* а не будем вообще указывать банк для нерезидентов, а то телеграмма не проходит */
      if bankl.frbno = "KZ" then do:
        t-corracc.sbanksend = v-bank.
        t-corracc.rbanksend = v-bank.
      end.

      t-corracc.bank2 = bankl.bank.
      t-corracc.cnt = bankl.frbno.
      t-corracc.cntsend = "". /* страна совпадает по умолчанию - поскольку пишется банк-корр с обеих сторон */
    end.
    else do:
       find first aaa where aaa.aaa = t-eknp.acc no-lock no-error.
       if avail aaa then do:
        t-corracc.sbanksend = aaa.name.
        t-corracc.rbanksend = aaa.name.
        t-corracc.bank2 = aaa.name.  /* БИК ???*/
        t-corracc.cnt = "KZ".
        t-corracc.cntsend = "". /* страна совпадает по умолчанию - поскольку пишется банк-корр с обеих сторон */
       end.
    end.

    t-corracc.s_locat = 1.
    t-corracc.s_secek = 4.
    t-corracc.r_locat = 1.
    t-corracc.r_secek = 4.
    t-corracc.knp = 290.

    t-corracc.kz = (t-corracc.cnt = "kz").  /* страна коррбанка казахстан/нет */

    if t-corracc.cnt = "kz" then
      t-corracc.ptype = if t-corracc.sum < 0 then 14 else 15.
    else do:
      t-corracc.ptype = if t-corracc.sum < 0 then 16 else 17.
    end.
  end.
end.

   output stream rpt close.
/*
for each t-corracc.
displ t-corracc.
end.
*/
