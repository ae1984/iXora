/* trxjlgen.p
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       01/09/04 sasco русифицировал ошибки
       26.04.05 nataly добавлено автоматическое проставление кодов расходов/доходов {cods.i}
       16.05.05 nataly добавлен признак cods.lookaaa (yes - код определяется корр счетом и просмтавляется автоматически,
                       no -  код проставляется вручную)
      28.09.05 nataly добавлен find first bcods
      13/12/05 nataly добавлен ввод кода доходов
      14/12/05 nataly добавлен supusr2  как исключение по пользователям
      23/01/06 nataly добавила признак архивности справочника
      20/04/06 nataly оптимизировала проверку по cods, для меню с g-fname FOFC и OBMEN будет автоматическое присвоение кодов
      17.01.11 evseev - добавил группы счетов Недропользователь 518,519,520
      26/11/2012 Luiza  - подключила convgl.i  ТЗ 1374
      24.05.2013 evseev - tz-1844
      10.06.2013 evseev - tz-1845
*/

def shared var  g-fname as char.
def shared temp-table tmpl like trxtmpl.
def shared temp-table cdf like trxcdf.
def buffer selgl for gl .
def buffer buygl for gl .
def output parameter rcode as inte.
def output parameter rdes as char.
def var errlist as char extent 31.
def var f-cash as log init false .
def var v-del as log initial false .
def var vcrc as inte.
def var vdam as deci.
def var vcam as deci.
def var crec as recid.
def var flag as logi.
def var flg as logi.
def var v-fexp as char.
def var frate as deci decimals 4 format "999.9999".
def buffer fcrc for crc.
def buffer tcrc for crc.
/*def buffer buy for sysc.
def buffer sel for sysc.*/
def buffer bjl for jl.
errlist[31] = "Нельзя продолжить транзакцию со статусом > 0.".

def shared var s-jh like jh.jh.
def new shared var s-aaa like aaa.aaa.
def new shared var s-aah as int.
def new shared var s-line as inte.
def new shared var s-force as log.
def shared var g-lang as char.
def shared var g-today as date.
def shared var g-ofc as char.
def shared var hsts as inte.
def shared var jh-ref as cha .
def shared var jh-sub as cha .
def shared var hparty as char.
def shared var hpoint as inte.
def shared var hdepart as inte.
def shared var hopt as char.
def var vln as inte.

find sysc where sysc.sysc = "cashgl" no-lock.
/*find buy where buy.sysc = "buygl" no-lock no-error.
find sel where sel.sysc = "selgl" no-lock no-error.*/
{convgl.i "bank"}


                                              /*26.04.05 nataly*/
def buffer bcods for cods.
def buffer bcods2 for cods.

def var flg2 as logical  FORMAT  "true/false"  initial "false".
def buffer gltrx for sysc.
define variable v-code like cods.code init "".
define variable v-dep like cods.dep init "".
def new shared var v-gltrx as char.
find gltrx where gltrx.sysc = "gltrx" no-lock no-error.
if avail gltrx then  v-gltrx = gltrx.chval.
 else  message 'Не найдена запись sysc для GLTRX!'.
define variable v-gl like gl.gl init 0.
define variable v-acc like jl.acc init "".
def var v-supusr as char init "bankadm,superman".
def var v-supusr2 as char .  /*исключения по менеджерам*/

def buffer sysc2 for sysc.
find sysc2 where sysc2.sysc = 'supus2' no-lock no-error.
if avail sysc2  then  v-supusr2 = sysc2.chval.

def temp-table btrxcods
    field num as rowid
    field gl like jl.gl
    field dc as char format 'x(1)'
    field trxln like jl.ln
    field codfr like trxcods.codfr
    field  code as char format 'x(10)'.

for each btrxcods.
  delete btrxcods.
end.

for each tmpl.
 if tmpl.amt = 0 then next.
    if substr(string(tmpl.drgl),1,1) = '5'  or substr(string(tmpl.drgl),1,1) = '4' then do:
     find gl where gl.gl = tmpl.drgl no-lock no-error.
     if available gl then do:

                           /*23/01/06 nataly если единтсвенный код дох-расх, то проставляем офицера по g-ofc*/
       find first bcods where bcods.gl =  tmpl.drgl and bcods.arc = no no-lock no-error.
       if avail bcods  then do:
         if bcods.lookaaa or (g-fname = 'fofc' or g-fname = 'obmen') then flg2 = true.
          else flg2 = false.
        if flg2 = false then do:
         find first bcods2 where bcods2.gl =  tmpl.drgl and bcods2.code <> bcods.code and bcods2.arc = no no-lock no-error.
          if not avail bcods2 then flg2 = true. else flg2 = false.
      end.
     end.

      if lookup(g-ofc, v-supusr) <> 0  or lookup(g-ofc, v-supusr2) <> 0 or flg2 then  do: /*при автоматической проводке беретсЯ 1-я запись из справочника*/
      if lookup(string(tmpl.drgl), v-gltrx) = 0 then
      find first cods where cods.gl =  gl.gl and cods.arc = no  no-lock no-error.
     else  find first cods where cods.gl =  tmpl.drgl and cods.acc = tmpl.cracc and cods.arc = no  no-lock no-error.
       if not avail cods then do:
              v-code = "0000000".   v-dep = "000".
        end.
        else do:
              v-code = cods.code.   v-dep = cods.dep.
              {codsacc.i &acc = tmpl.cracc}
              {codsofc.i} /*проставляем код департамента по логину менеджера, если имеется единственный код дох-расх */
        end.
     end. /*v-supusr*/
     else  do: /*выбирается код расходов и департамент*/
    if lookup(string(tmpl.drgl), v-gltrx) = 0 then v-acc = "".
     else v-acc = tmpl.cracc.
       {trx-cods.i}
       /* find cods where cods.code = v-code no-lock no-error.
       if avail cods then  do:
        {codsacc.i &acc = tmpl.cracc}
       end.  */
      end.
        create btrxcods.
              assign
                 btrxcods.num  = rowid(tmpl)
                 btrxcods.trxln = tmpl.ln
                 btrxcods.dc    =  'd'
                 btrxcods.codfr = 'cods'
                 btrxcods.code = v-code + v-dep.
     end.
    end.  /*drgl = '5' or '4'*/
    if substr(string(tmpl.crgl),1,1) = '5' or substr(string(tmpl.crgl),1,1) = '4'  then do:
     find gl where gl.gl = tmpl.crgl no-lock no-error.
     if available gl then do:

       find first bcods where bcods.gl =  tmpl.crgl and bcods.arc = no no-lock no-error.
       if avail bcods  then do:
         if bcods.lookaaa or (g-fname = 'fofc' or g-fname = 'obmen') then flg2 = true.
          else flg2 = false.
        if flg2 = false then do:
         find first bcods2 where bcods2.gl =  tmpl.crgl and bcods2.code <> bcods.code and bcods2.arc = no no-lock no-error.
          if not avail bcods2 then flg2 = true. else flg2 = false.
      end.
     end.

    if lookup(g-ofc, v-supusr) <> 0 or lookup(g-ofc, v-supusr2) <> 0 or flg2 then  do: /*при автоматической проводке беретсЯ 1-я запись из справочника*/
      if lookup(string(tmpl.crgl), v-gltrx) = 0 then
      find first cods where cods.gl =  gl.gl and cods.arc = no  no-lock no-error.
     else  find first cods where cods.gl =  tmpl.crgl and cods.acc = tmpl.dracc  and cods.arc = no no-lock no-error.
       if not avail cods then do:
              v-code = "0000000".   v-dep = "000".
        end.
        else do:
              v-code = cods.code.   v-dep = cods.dep.
              {codsacc.i &acc =  tmpl.dracc} /*проставляем по доп. признаку 8*/
                {codsofc.i} /*проставляем код департамента по логину менеджера, если имеется единственный код дох-расх */
        end.
     end. /*v-supusr*/
     else  do: /*выбирается код расходов и департамент*/
    if lookup(string(tmpl.crgl), v-gltrx) = 0 then v-acc = "".
     else v-acc = tmpl.dracc.
       {trx-cods.i}
      /*  find cods where cods.code = v-code no-lock no-error.
       if avail cods then  do:
        {codsacc.i &acc = tmpl.dracc}
      end.*/
      end.
        create btrxcods.
              assign
                 btrxcods.num  = rowid(tmpl)
                 btrxcods.trxln = tmpl.ln
                 btrxcods.dc    =  'c'
                 btrxcods.codfr = 'cods'
                 btrxcods.code = v-code + v-dep.
     end.
    end.  /*crgl = '5' or '4'*/

end. /*tmpl*/

                                               /*26.04.05 nataly*/

/*
for each tmpl:
 disp tmpl.ln tmpl.amt tmpl.crc tmpl.rate tmpl.rate-f tmpl.drgl tmpl.dracc tmpl.crgl tmpl.cracc.
end.
pause 333.
*/

if s-jh > 0 then find last jl where jl.jh = s-jh no-lock no-error.
if not available jl then do:
 run x-jhnew.
 find jh where jh.jh eq s-jh exclusive-lock.
 jh.crc = 0.
 jh.party = hparty.
 jh.point = hpoint.
 jh.depart = hdepart.
 jh.sts = hsts.
 jh.ref = jh-ref .
 jh.sub = jh-sub .
end.
else do:
 vln = jl.ln.
 find jh where jh.jh = s-jh exclusive-lock.
 if jh.post = true or jh.sts > 0 then do:
   rcode = 31.
   find first tmpl.
   rdes = errlist[rcode] + ":Шаблон=" + tmpl.code + ";Пров=" + string(s-jh).
   return.
 end.
 for each jl where jl.jh = jh.jh and jl.acc <> "" exclusive-lock:
    {trxupd-f.i}
 end.
end.
f-cash = false .
for each tmpl .
   if tmpl.drgl = sysc.inval then f-cash = true .
end.

for each tmpl:
 if tmpl.amt = 0 then next.
   flg = true.
  if hopt = "+" then do:
    flg = false.
    find first jl where jl.jh = s-jh
                    and jl.gl = tmpl.drgl
                    and jl.acc = tmpl.dracc
                    and jl.crc = tmpl.crc
                    and jl.dc = "D" use-index jhln exclusive-lock no-error.
    if available jl then do:
      mcdf1:
      for each cdf where cdf.drcod <> "msc" and cdf.drcod-f = "d":
          find trxcods where trxcods.trxh = jl.jh
                         and trxcods.trxln = jl.ln
                         and trxcods.codfr = cdf.codfr
                         and trxcods.code = cdf.drcod no-lock no-error.
          if not available trxcods then do:
             flg = true.
             leave mcdf1.
          end.
      end.
      if not flg then do: jl.dam = jl.dam + tmpl.amt.
      end.
    end.
    else flg = true.
  end.
  if flg then do:
     vln = vln + 1.
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.dam = tmpl.amt.
     jl.crc = tmpl.crc.
     jl.gl = tmpl.drgl.
     jl.acc = tmpl.dracc.
     jl.dc = "D".
     jl.who = jh.who.
     jl.point = jh.point.
     jl.depart = jh.depart.
     jl.subled = tmpl.drsub.
     jl.lev = tmpl.dev.
     jl.trx = tmpl.code.
     jl.genln = tmpl.ln .
     jl.rem[1] = tmpl.rem[1].
     jl.rem[2] = tmpl.rem[2].
     jl.rem[3] = tmpl.rem[3].
     jl.rem[4] = tmpl.rem[4].
     jl.rem[5] = tmpl.rem[5].
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.
     jl.sts = jh.sts.
     if jl.sts = 6 /*and jl.gl = sysc.inval*/ then jl.teller = jh.who.
     for each cdf where cdf.trxcode = tmpl.code
                    and cdf.trxln = tmpl.ln
                    and cdf.drcod <> "msc"
                    and cdf.drcod-f = "d":
         create trxcods.
         trxcods.trxh = jl.jh.
         trxcods.trxln = jl.ln.
         trxcods.codfr = cdf.codfr.
         trxcods.code = cdf.drcod.
     end.
					    /*26.04.05 nataly*/
        find btrxcods where btrxcods.num = rowid(tmpl) and btrxcods.dc = 'd' no-lock no-error.
       if avail btrxcods then do:
        create trxcods.
              assign
                 trxcods.trxh  = jl.jh
                 trxcods.trxln = jl.ln
                 trxcods.codfr = 'cods'
                 trxcods.code = btrxcods.code.
    end.                                    /*26.04.05 nataly*/
  end. /*flg*/
     find first selgl where selgl.gl = tmpl.crgl no-lock no-error .
     if isConvGL(tmpl.drgl) /* tmpl.drgl = sel.inval*/ and avail selgl
      and selgl.typ ne "R" and selgl.typ ne "E"
/*        and tmpl.crgl < 700000  */
     then run trxfxsel.
     release jl.

   flg = true.
   if hopt = "+" then do:
   flg = false.
   find first jl where jl.jh = s-jh
                 and jl.gl   = tmpl.crgl
                 and jl.acc  = tmpl.cracc
                 and jl.crc  = tmpl.crc
                 and jl.dc   = "C" use-index jhln exclusive-lock no-error.
   if not avail jl then
   find first jl where jl.jh = s-jh
                 and jl.gl   = tmpl.crgl
                 and jl.acc  = tmpl.cracc
                 and jl.crc  = tmpl.crc
                 and jl.dc   = "D"
                 and jl.dam  = tmpl.amt  use-index jhln
                 exclusive-lock no-error.

   if available  jl then do:
      if jl.dc = "C" then do:
      mcdf2:
      for each cdf where cdf.crcod <> "msc" and cdf.crcode-f = "d":
          find trxcods where trxcods.trxh = jl.jh
                         and trxcods.trxln = jl.ln
                         and trxcods.codfr = cdf.codfr
                         and trxcods.code = cdf.crcod no-lock no-error.
          if not available trxcods then do:
             flg = true.
             leave mcdf2.
          end.
      end.
      end.
      else
      do:
      for each cdf where  cdf.trxcode = tmpl.code
                          and cdf.trxln = tmpl.ln
                          and cdf.crcod <> "msc":
       flag = true .
      end.
      find first trxcods where trxcods.trxh = jl.jh
                         and trxcods.trxln = jl.ln
                         no-lock no-error.
        if avail trxcods then flag = true .
      end.
      if not flg then do: jl.cam = jl.cam + tmpl.amt.
        if jl.dam - jl.cam = 0 then
        do:
        find first fexp where fexp.fex = jl.deal no-error .
        if avail fexp then delete fexp.
        delete jl.
        v-del = true .
        end.
        else v-del = false .
      end.
    end.
    else flg = true.
  end.
  if flg then do:
     vln = vln + 1.
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.cam = tmpl.amt.
     jl.crc = tmpl.crc.
     jl.gl = tmpl.crgl.
     jl.acc = tmpl.cracc.
     jl.dc = "C".
     jl.who = jh.who.
     jl.point = jh.point.
     jl.depart = jh.depart.
     jl.subled = tmpl.crsub.
     jl.lev = tmpl.cev.
     jl.trx = tmpl.code.
     jl.genln = tmpl.ln .
     jl.rem[1] = tmpl.rem[1].
     jl.rem[2] = tmpl.rem[2].
     jl.rem[3] = tmpl.rem[3].
     jl.rem[4] = tmpl.rem[4].
     jl.rem[5] = tmpl.rem[5].
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.
     jl.sts = jh.sts.
/* TDA Special Treatment */
     if jl.subled = "cif" and jl.lev = 1 then do:
        find aaa where aaa.aaa = jl.acc no-lock no-error.
        if available aaa then do:
           find lgr where lgr.lgr = aaa.lgr no-lock no-error.
           if available lgr and lgr.led = "TDA" then do:
              if not (tmpl.drsub = "cif" and tmpl.dracc = aaa.aaa) then jl.consol = true.
           end.

           if available lgr and lgr.led = "CDA" and lookup(lgr.lgr, "478,479,480,481,482,483,484,485,486,487,488,489,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 then do:
              if not (tmpl.drsub = "cif" and tmpl.dracc = aaa.aaa) then jl.consol = true.
           end.

        end.
     end.
/* End TDA */
/*     if tmpl.drgl = sysc.inval then jl.aax = 1.     */
     if jl.acc ne "" and jl.lev = 1
     then do:
      find first aaa where aaa.aaa = jl.acc no-error .
      if avail aaa and f-cash then jl.aax = 1.
     end.
     if jl.sts = 6 /*and jl.gl = sysc.inval*/ then jl.teller = jh.who.
     for each cdf where cdf.trxcode = tmpl.code
                    and cdf.trxln = tmpl.ln
                    and cdf.crcod <> "msc"
                    and cdf.crcode-f = "d":
         create trxcods.
         trxcods.trxh = jl.jh.
         trxcods.trxln = jl.ln.
         trxcods.codfr = cdf.codfr.
         trxcods.code = cdf.crcod.
     end.
					    /*26.04.05 nataly*/
        find btrxcods where btrxcods.num = rowid(tmpl) and btrxcods.dc = 'c' no-lock no-error.
       if avail btrxcods then do:
        create trxcods.
              assign
                 trxcods.trxh  = jl.jh
                 trxcods.trxln = jl.ln
                 trxcods.codfr = 'cods'
                 trxcods.code = btrxcods.code.
    end.                                    /*26.04.05 nataly*/

  end. /*FLG*/
    if not v-del  then do:
     find first buygl where buygl.gl = tmpl.crgl no-lock no-error .
     if isConvGL(tmpl.drgl)  /* tmpl.drgl = buy.inval*/ and avail buygl
        and buygl.typ ne "R" and buygl.typ ne "E"
 /*    if tmpl.crgl = buy.inval
        and tmpl.drgl < 700000  */
     then run trxfxbuy.
     release jl.
     end.
end. /*for each tmpl*/

for each jl where jl.jh = s-jh and jl.acc <> "" exclusive-lock:
    {trxupd-r.i}
end. /*for each jl*/
release jl.

{trxupd-i.i}

/***********Creation or updating of fexp record when we sell currency*******/
PROCEDURE trxfxsel.
find tcrc where tcrc.crc = jl.crc no-lock.
frate = round(tmpl.rate * tcrc.rate[9], 4).
flag = false.
for each bjl where bjl.jh = s-jh and bjl.deal <> "" no-lock:
    find fexp where fexp.fex = bjl.deal exclusive-lock no-error.
    if not available fexp then next.
    find fcrc where fcrc.crc = fexp.fcrc no-lock.
    if fexp.payment = 0 then do:
       fexp.payment = tmpl.amt.
       fexp.tcrc = tcrc.crc.
       fexp.igl = tmpl.crgl.
       fexp.tacc = tmpl.cracc.
       substring(fexp.party,47) =
         " SELL-RATE: " + string(frate,"999.9999") + " " + "Ls " + "/ "
       + string(tcrc.rate[9],"zzzzzzz") + " " + string(tcrc.code,"x(3)")
       + " MIDL-RATE: " + string(fcrc.rate[1],"999.9999") + " " + "Ls " + "/ "
       + string(fcrc.rate[9],"zzzzzzz") + " " + string(fcrc.code,"x(3)")
       + " MIDL-RATE: " + string(tcrc.rate[1],"999.9999") + " " + "Ls " + "/ "
       + string(tcrc.rate[9],"zzzzzzz") + " " + string(tcrc.code,"x(3)").
       jl.deal = fexp.fex.
       flag = true.
       leave.
    end.
end.
if flag = false then do:
   find nmbr where nmbr.code = "FX" exclusive-lock.
   v-fexp = nmbr.prefix + string (nmbr.nmbr,nmbr.fmt) + nmbr.sufix.
   nmbr.nmbr = nmbr + 1.
   release nmbr.
   create fexp.
   fexp.fex = v-fexp.
   fexp.regdt = g-today.
   fexp.who   = g-ofc.
   fexp.tim   = time.
   fexp.type  = 5.
       fexp.payment = tmpl.amt.
       fexp.tcrc = tcrc.crc.
       fexp.igl = tmpl.crgl.
       fexp.tacc = tmpl.cracc.
       fexp.jh = s-jh.
       fexp.party = " " + fexp.fex.
       substring(fexp.party,47) =
         " SELL-RATE: " + string(frate,"999.9999") + " " + "Ls " + "/ "
       + string(tcrc.rate[9],"zzzzzzz") + " " + string(tcrc.code,"x(3)").
       jl.deal = fexp.fex.
end.
END procedure.

/***********Creation or updating of fexp record when we buy currency*******/
PROCEDURE trxfxbuy.
find fcrc where fcrc.crc = jl.crc no-lock.
frate = round(tmpl.rate * fcrc.rate[9], 4).
flag = false.
for each bjl where bjl.jh = s-jh and bjl.deal <> "" no-lock:
    find fexp where fexp.fex = bjl.deal exclusive-lock no-error.
    if not available fexp then next.
    find tcrc where tcrc.crc = fexp.tcrc no-lock.
    if fexp.amt = 0 then do:
       fexp.amt = tmpl.amt.
       fexp.fcrc = fcrc.crc.
       fexp.gl = tmpl.drgl.
       fexp.facc = tmpl.dracc.
       fexp.party = fexp.party +
       " BUY-RATE : " + string(frate,"999.9999") +  " " + "Ls " + "/ "
       + string(fcrc.rate[9],"zzzzzzz") + " " + string(fcrc.code,"x(3)").
       substring(fexp.party,76) =
         " MIDL-RATE: " + string(fcrc.rate[1],"999.9999") + " " + "Ls " + "/ "
       + string(fcrc.rate[9],"zzzzzzz") + " " + string(fcrc.code,"x(3)")
       + " MIDL-RATE: " + string(tcrc.rate[1],"999.9999") + " " + "Ls " + "/ "
       + string(tcrc.rate[9],"zzzzzzz") + " " + string(tcrc.code,"x(3)").
       jl.deal = fexp.fex.
       flag = true.
       leave.
    end.
end.
if flag = false then do:
  find nmbr where nmbr.code = "FX" exclusive-lock.
  v-fexp = nmbr.prefix + string (nmbr.nmbr,nmbr.fmt) + nmbr.sufix.
  nmbr.nmbr = nmbr + 1.
  release nmbr.
  create fexp.
  fexp.fex = v-fexp.
  fexp.regdt = g-today.
  fexp.who   = g-ofc.
  fexp.tim   = time.
  fexp.type  = 5.
       fexp.amt = tmpl.amt.
       fexp.fcrc = fcrc.crc.
       fexp.gl = tmpl.drgl.
       fexp.facc = tmpl.dracc.
       fexp.jh = s-jh.
       fexp.party = " " + fexp.fex.
       fexp.party = fexp.party +
       " BUY-RATE : " + string(frate,"999.9999") +  " " + "Ls " + "/ "
       + string(fcrc.rate[9],"zzzzzzz") + " " + string(fcrc.code,"x(3)").
       jl.deal = fexp.fex.
end.
END procedure.




