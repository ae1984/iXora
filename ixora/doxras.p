/* doxras.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Автоматизированный подсчет доходов и расходов
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
        13/01/04 nataly 
 * CHANGES
        29/01/04 nataly  - были добавлены налоговые, коммунальные и прочие платежи 
        09/02/04 nataly  - в подсчете по амортизации вместо проводок по дебету - берутся проводки по кредиту, тк счет пассивный
        13/02/04 nataly  - отчет выводится в EXCEL , выводятся итоги по доходам и расходам , а также разница между ними, амортизация переведена в расходы
        16/02/04 nadejda - исправлен поиск департамента клиента, сделана обработка суперюзеров
        18.02.2004 nadejda - в сокращенном отчете только сумма в USD
        21.05.2004 nadejda - исправлена ошибка поиска счета при подсчете доходов
        21.05.2004 nadejda - исправлена ошибка поиска второй половины транзакции при подсчете доходов
        23.06.2004 kanat   - добавил проверку на avail lgr (была ругань при подсчете) и подсчет на комиссий за перевод коммунальных платежей
        05.08.2004 kanat - substr(bjl.gl) поменял в целях убыстрения работы отчета на внешний for each temp-gl1 no-lock (все счета ГК по 4 классу ... ).
                           и на for each temp-gl2 no-lock (все счета ГК по 5 классу ...)  
        10.01.2005 sasco - исправил формат вывода с минусом
        18.05.2005 kanat - добавил условие на сторно транзакции по лоходам и расходам
        03.08.2005 kanat - добавил условие по storn
        01.03.2006 sasco - исправил расчет по амортизации (поиск в astjln операции типа '9' и по номеру проводки)
        27/04/09   maarinav - убраны коммунальные и alga
*/

{mainhead.i}

def var sum_tax as decimal.
def var sum_pf as decimal.
def var sum_com10  as decimal.
def var sum_com20  as decimal.
def var sum_prc10  as decimal.
def var sum_prc20  as decimal.

def var bsum$ as dec format "->>>,>>>,>>9.99".
def var isum$ as dec format "->>>,>>>,>>9.99".
def var ic$ as int.
def var i$ as int format ">>>>>." init 1.
def var i1$ as int format ">>>>>".
def var gr$ as char format "x(3)".
def var q$ as int format ">>>>>".
def var qacc$ as int format ">>>>>".


def var v-dat as date.

def new shared var  vprofit as char.
def new shared var v-name as char.
def new shared var sum11 as decimal.
def new shared var v-dep as char format "x(3)".
def new shared var prz as integer.
def new shared var seltxb as int.
def new shared var dt11 as date.
def new shared var dt22 as date.
def var v-aaa as char.


 {comm-txb.i}
seltxb = comm-cod().
 {get-dep.i}

def var v-tek as decimal.
def var v-supusr as char.
def var dt1 as date.
def var dt2 as date.

def buffer bjl for jl.
def buffer bjh for jh.

def temp-table temp 
    field cif  like cif.cif
    field aaa like aaa.aaa
    field fdt as date
    field gl   like jl.gl
    field amt like jl.dam
    field amtkzt like jl.dam
    field jh like jl.jh
    field ofc as char
    field crc like jl.crc
    field doxras as char
    index main is primary doxras gl crc.

def temp-table temp-gl1 
    field gl as integer.

def temp-table temp-gl2 
    field gl as integer.

def new shared frame opt 
       v-dep label "Код департамента" 
       vprofit  label "Профит-центр" skip
       dt1 label  "ДАТА ОТЧЕТА С ..."
         validate (dt1 <= g-today, " Дата не может быть больше текущей!")
       dt2 label  "ПО ..."
         validate (dt2 <= g-today, " Дата не может быть больше текущей!")
       with row 8 centered side-labels.
on help of vprofit in frame opt  run uni_help1("sproftcn", "...").

update v-dep  vprofit dt1 dt2  with frame opt.

if dt2 < dt1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.    
end.
hide frame opt.

for each gl where string(gl.gl) begins "4" and gl.subled <> "lon" no-lock.
create temp-gl1 no-error.
update temp-gl1.gl = gl.gl no-error.
end.

for each gl where string(gl.gl) begins "5" no-lock.
create temp-gl2 no-error.
update temp-gl2.gl = gl.gl no-error.
end.

find ppoint where ppoint.depart = integer(v-dep) no-lock no-error.
if not available ppoint then do:
    message "Неверный код департамента".
    leave.    
end.

 dt11 = dt1. dt22 = dt2.

def button  btn1  label "Сокращенная форма отчета".
   def button  btn2  label "Расширенная форма отчета ".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберите вариант отчета:" row 5.

  on choose of btn1,btn2,btn3 do:
    if self:label = "Сокращенная форма отчета" then prz = 1.
    else
    if self:label = "Расширенная форма отчета  " then prz = 2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.
 
 displ "РАСЧЕТ РАСХОДОВ И ДОХОДОВ " string(time,"hh:mm:ss") with centered row 5.
 pause 1.

find ppoint where ppoint.dep = integer(v-dep) no-lock no-error.
if avail ppoint then v-name = ppoint.name.

find sysc where sysc.sysc = "sys1" no-lock no-error.
v-supusr = sysc.des.

do v-dat = dt1 to dt2:
 /*учет доходов*/
 for each temp-gl1 no-lock.   
   for each bjl where bjl.jdt = v-dat and bjl.gl = temp-gl1.gl and bjl.dc = "c" no-lock.

   find first bjh where bjh.jh = bjl.jh and not bjh.party matches "*storn*" no-lock no-error.
   if avail bjh then do:
      
      find last crchis where crchis.crc = bjl.crc and crchis.regdt <= bjl.jdt no-lock no-error.
      find  last ofchis where  ofchis.regdt <= v-dat and ofchis.ofc = bjl.who no-lock no-error.

      /* отсечь суперюзеров */
      if avail ofchis and lookup(bjl.who, v-supusr) = 0 then do:
        if ofchis.depart = integer(v-dep) then do:

          create temp. 
          temp.gl = bjl.gl. 
          if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
          else temp.doxras = "ras".
          temp.amtkzt = bjl.cam * crchis.rate[1].  
          temp.amt = bjl.cam.
          temp.crc = bjl.crc.
          temp.ofc = bjl.who.
          temp.jh = bjl.jh.
        end.
      end. /*avail ofchis*/
      else do:
        
        /* 21.05.2004 nadejda - присваивается переменная для последующей проверки, проверка по avail aaa убрана */
        v-aaa = "".
        if bjl.acc <> "" then do:
          find aaa where aaa.aaa = bjl.acc no-lock no-error.
          if avail aaa then v-aaa = aaa.aaa.
        end.
        else do:
          find first jl where jl.jh = bjl.jh and substr(string(jl.gl), 1, 1) = "2" and jl.dc = "d" no-lock no-error.
          if avail jl and jl.acc <> "" then do:
            find aaa where aaa.aaa = jl.acc no-lock no-error.
            if avail aaa then v-aaa = aaa.aaa.
          end.
        end.

        if v-aaa <> "" then do:

          find cif where cif.cif = aaa.cif no-lock no-error.

          if integer (cif.jame) mod 1000 = integer(v-dep) then do:
            create temp. 
            temp.cif = aaa.cif. 
            temp.gl = bjl.gl. 
            if substr(string(temp.gl), 1, 1) = "4" then temp.doxras = "dox".
                                                   else temp.doxras = "ras".

            temp.amtkzt = bjl.cam * crchis.rate[1].  
            temp.amt = bjl.cam.
            temp.crc = bjl.crc.
            temp.ofc = trim(substr(cif.fname, 1, 8)).
            temp.jh = bjl.jh.

          end. /*avail ofchis*/
        end.  /*avail aaa*/
      end.  /*else*/
    end. /* avail bjh ... */
   end. /* for each bjl ... */
  end. /* for each temp-gl ... */
 /*учет расходов*/
   for each temp-gl2 no-lock.
    for each bjl where bjl.jdt = v-dat and bjl.gl = temp-gl2.gl and bjl.dc = "d" no-lock. 

   find first bjh where bjh.jh = bjl.jh and not bjh.party matches "*storn*" no-lock no-error.
   if avail bjh then do:

      find last crchis where crchis.crc = bjl.crc and crchis.regdt <= bjl.jdt no-lock no-error.
      find  last ofchis where  ofchis.regdt <= v-dat and ofchis.ofc = bjl.who no-lock no-error.
      /* отсечь суперюзеров */
      if avail ofchis and lookup(bjl.who, v-supusr) = 0 then do:
        if ofchis.depart = integer(v-dep) then do:

          create temp. 
          temp.gl = bjl.gl. 
          if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
          else temp.doxras = "ras".
          temp.amtkzt = bjl.dam * crchis.rate[1].  
          temp.amt = bjl.dam.
          temp.crc = bjl.crc.
          temp.ofc = bjl.who.
          temp.jh = bjl.jh.

        end.
      end. /*avail ofchis*/
      else do:
       find aaa where aaa.aaa = bjl.acc no-lock no-error.
       if avail aaa then do:
         find cif where cif.cif = aaa.cif no-lock no-error.

/*****  надо по cif.jame !!!              ***************

          find cif where cif.cif = aaa.cif no-lock no-error.
*/
      if integer (cif.jame) mod 1000 = integer(v-dep) then do:
/*
      find  last ofchis where  ofchis.regdt <= v-dat and ofchis.ofc = cif.fname no-lock no-error.
      if avail ofchis  and ofchis.depart = integer(v-dep) 
      then do:
*/
       create temp. 
       temp.cif = aaa.cif. temp.gl = bjl.gl. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = bjl.dam * crchis.rate[1].  
       temp.amt = bjl.dam.
       temp.crc = bjl.crc.
       temp.ofc = trim(substr(cif.fname, 1, 8)).
       temp.jh = bjl.jh.

     end. /*avail ofchis*/

       end.  /*avail aaa*/
     end.  /*else*/
     end.  /*avail bjh ... */
    end.  /* for each bjl ....*/
  end. /* for each temp-gl2 ... */
/*расчет доходов по налоговым платежам */
/* for each tax where tax.txb = seltxb and date = v-dat and duid = ? no-lock use-index datenum.
 find first ofc where ofc.ofc = tax.uid no-lock no-error.
 if avail ofc then do:
   if get-dep(tax.uid, tax.date) = integer(v-dep)  then do:  
     sum_tax =  sum_tax + tax.comsum.
   end.
 end.
 end.*/  /*tax*/

/*расчет доходов по пенсионным  платежам*/
  for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-dat and p_f_payment.deluid = ? no-lock:
  find first ofc where ofc.ofc = p_f_payment.uid no-lock no-error.
  if avail ofc then do:
    if get-dep(p_f_payment.uid, p_f_payment.date) = integer(v-dep) then do:
     sum_pf =  sum_pf + p_f_payment.comiss.
    end.
  end.                    
 end.  /*payment*/


/*расчет комиссий за квитанции по коммунальным платежам (диагностика, ИВЦ, АЛСЕКО, КАЗАХТЕЛЕКОМ */
/*  for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dat and
     commonpl.deluid = ? and commonpl.grp <> 15 no-lock use-index datenum.
     find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
     if avail ofc then do:
    if get-dep(commonpl.uid, commonpl.date) = integer(v-dep) then do:
     find commonls where commonls.txb = commonpl.txb and 
     commonls.grp = commonpl.grp and commonls.arp = commonpl.arp and commonls.type = commonpl.type no-lock no-error. 
      if avail commonls and commonls.visible then do:
       if commonls.comgl = 461110 then 
         sum_com10 =  sum_com10 + commonpl.comsum.
       else if commonls.comgl = 461120 then
         sum_com20 =  sum_com20 + commonpl.comsum.
      end.
    end.
    end.                                
  end. */ /*commonpl*/


/*расчет комиссий за перечисления по коммунальным платежам (диагностика, ИВЦ, АЛСЕКО, КАЗАХТЕЛЕОМ */
/*  for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dat and
     commonpl.deluid = ? and commonpl.grp <> 15 no-lock use-index datenum:
     find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
     if avail ofc then do:
    if get-dep(commonpl.uid, commonpl.date) = integer(v-dep) then do:
     find commonls where commonls.txb = commonpl.txb and 
     commonls.grp = commonpl.grp and commonls.arp = commonpl.arp and commonls.type = commonpl.type no-lock no-error. 
      if avail commonls and commonls.visible then do:
       if commonls.prcgl = 460111 then 
         sum_prc10 =  sum_prc10 + (commonpl.sum * commonls.comprc).
       else if commonls.prcgl = 461110 then
         sum_prc20 =  sum_prc20 + (commonpl.sum * commonls.comprc).
      end.
    end.  
  end.                                 
  end.*/ /*commonpl*/


/* расчет комиссий за квитанции по социальным платежам */
 /* for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dat and
     commonpl.deluid = ? and commonpl.grp = 15 no-lock use-index datenum.
     find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
     if avail ofc then do:
    if get-dep(commonpl.uid, commonpl.date) = integer(v-dep) then do:
     find commonls where commonls.txb = commonpl.txb and 
     commonls.grp = commonpl.grp and commonls.arp = commonpl.arp and commonls.type = commonpl.type no-lock no-error. 
      if avail commonls and commonls.visible = no then do:
       if commonls.comgl = 461110 then 
         sum_com10 =  sum_com10 + commonpl.comsum.
       else if commonls.comgl = 461120 then
         sum_com20 =  sum_com20 + commonpl.comsum.
      end.
    end.
    end.                                
  end.*/ /*commonpl*/

    
end. /*v-dat*/
  /*итоговая сумма по налоговым*/
  if sum_tax <> 0 then do:
       create temp. 
       temp.gl = 461110. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_tax.  
       temp.amt = sum_tax.
       temp.crc = 1.
       temp.ofc = "Налоговые платежи".
       temp.jh = 0.
  end.
  /*итоговая сумма по пенсионным*/
  if sum_pf <> 0 then do:
       create temp. 
       temp.gl = 461110. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_pf.  
       temp.amt = sum_pf.
       temp.crc = 1.
       temp.ofc = "Пенсионные платежи".
       temp.jh = 0.
  end.

/* Итоговые суммы за комиссии по квитанциям */
  /*итоговая сумма по прочим платежам ЮЛ*/
  if sum_com10 <> 0 then do:
       create temp. 
       temp.gl = 461110. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_com10.  
       temp.amt = sum_com10.
       temp.crc = 1.
       temp.ofc = "Прочие платежи ЮЛ".
       temp.jh = 0.
  end.
  /*итоговая сумма по прочим платежам ФЛ*/
  if sum_com20 <> 0 then do:
       create temp. 
       temp.gl = 461120. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_com20.  
       temp.amt = sum_com20.
       temp.crc = 1.
       temp.ofc = "Прочие платежи ФЛ".
       temp.jh = 0.
  end.
/* Итоговые суммы за комиссии по процентам */

  if sum_prc10 <> 0 then do:
       create temp. 
       temp.gl = 460111. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_prc10.  
       temp.amt = sum_prc10.
       temp.crc = 1.
       temp.ofc = "Комиссии за перевод ЮЛ".
       temp.jh = 0.
  end.
  if sum_prc20 <> 0 then do:
       create temp. 
       temp.gl = 461110. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_prc20.  
       temp.amt = sum_prc20.
       temp.crc = 1.
       temp.ofc = "Комиссии за перевод ЮЛ (кассовые операции)".
       temp.jh = 0.
  end.



/*расчет расходов по депозитам*/

for each cif no-lock:
/*  
  find ofc where cif.fname = ofc.ofc no-lock no-error.
  if not avail ofc then next.
  if avail ofc  and (ofc.regno - 1000) <>  integer(v-dep) then next.
*/
  if integer(cif.jame) mod 1000 <>  integer(v-dep) then next.
  
  for each aaa no-lock where aaa.cif = cif.cif.
   find lgr where lgr.lgr = aaa.lgr no-lock no-error.
   if avail lgr and lgr.led <> "cda" and lgr.led <> "tda" then next.
    do v-dat = dt1 to dt2.
       find last accr where accr.aaa = aaa.aaa and accr.fdt = v-dat  use-index aaa no-lock no-error. 
       find last crchis where crchis.crc = aaa.crc 
          and crchis.rdt <= v-dat   use-index crcrdt no-lock no-error.
 
        if available accr then  v-tek = accr.accrued .
         else v-tek = 0.
/*      message aaa.aaa aaa.cif cif.fname v-tek.*/
    find trxlevgl where trxlevgl.gl = aaa.gl and lev = 11 no-lock no-error.
    if v-tek <> 0 then do:
       create temp. 
       temp.cif = aaa.cif. temp.gl = trxlevgl.glr. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = v-tek * crchis.rate[1].  
       temp.amt = v-tek.
       temp.crc = aaa.crc.
       temp.ofc = trim(substr(cif.fname, 1, 8)).
       temp.jh = 0.
       temp.aaa = aaa.aaa.
       temp.fdt = v-dat.
/*      message temp.cif temp.ofc temp.aaa temp.fdt.*/

        /*   message aaa.aaa aaa.lgr lgr.led v-dat v-tek trxlevgl.glr.   pause 300.*/
    end.
    end. /*v-dat*/     
  end.
end.         
  
/*расчет амортизации*/
   displ "РАСЧЕТ НАЧИСЛ ПО АМОРТИЗАЦИИ " string(time,"hh:mm:ss") with centered row 5. 
   pause 1.

do v-dat = dt1 to dt2:
    for each bjl where bjl.jdt = v-dat and
     substr(string(bjl.gl),1,3) = "169"  and bjl.dc = "c" no-lock. /*берутся проводки по кредиту*/

   find first bjh where bjh.jh = bjl.jh and not bjh.party matches "*storn*" no-lock no-error.
   if avail bjh then do:

      /* поиск наличия проводки по амортизации */
      find astjln where astjln.aast = bjl.acc and astjln.ajh = bjl.jh and astjln.atrx = '9' no-lock no-error.
      if avail astjln then do:

      find last crchis where crchis.crc = bjl.crc 
      and crchis.regdt <= bjl.jdt no-lock no-error.
   find last  hist where hist.pkey = "AST" and hist.op = "MOVEDEP"
   and date <= bjl.jdt and hist.skey = bjl.acc no-lock no-error.

   if hist.chval[1] = vprofit then do:
    
       create temp. 
      /* temp.cif = aaa.cif.*/ temp.gl = bjl.gl. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = bjl.cam * crchis.rate[1].  
       temp.amt = bjl.cam.
       temp.crc = bjl.crc.
       temp.ofc = bjl.who.
       temp.jh = bjl.jh.

      end . /* vprofit */
    end. /* avail astjln */
    end. /* bjh */
  end. /*bjl*/
end.  /*v-dat*/

/*Расходы за ЗП*/
/*{comm-txb.i}*/
/*run doxras2.
  */
      create temp. 
      temp.gl = 572000. 
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
      temp.amtkzt = sum11.  
      temp.amt = sum11.
      temp.crc = 1.
      temp.ofc = "".
      temp.jh = 0.

/*
def new shared var vmc1 as integer.
def new shared var vmc2 as integer.
def new shared var vgod as integer.

def var vgod1 as integer.
def var vgod2 as integer.

if not connected ("alga") then do:

  find txb where txb.txb = seltxb and txb.city = 998 no-lock no-error.
  if not avail txb then do:
     message "Не найдены настройки БД Alga~nв таблице COMM.TXB"
     view-as alert-box title "ОШИБКА". pause 300.
     return "0".
  end.
  connect value("-db " + txb.path + " -ld alga ").
end.
vmc1 = month(dt1).
vmc2 = month(dt2).
vgod1 = year(dt1).
vgod2 = year(dt2).

if vgod1 <> vgod2 then do:
  vmc1 = month(dt1). vmc2 = 12. vgod = vgod1.
  run list.p.
  vmc1 = 1. vmc2 =  month(dt2). vgod = vgod2.
  run list.p.
end.
else do:
  vmc1 = month(dt1). vmc2 = month(dt2). vgod = vgod1.
  run list.p.
end.

disconnect "alga".
  */
def var sumgl as decimal.
def var sumdoxras as decimal.
def var sumdox as decimal.
def var sumras as decimal.
def var sumcrc1 as decimal.
def var sumcrc2 as decimal.

def var v-rateusd as decimal.
find last crchis where crchis.crc = 2 and crchis.rdt <= dt2 no-lock no-error.
v-rateusd = crchis.rate[1].


def stream vcrpt.
def var p-filename as char init "doxras.html".
output stream vcrpt  to value(p-filename).


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "x-"}


put stream vcrpt unformatted 
    "<p align=center><b> ОТЧЕТ ПО ДОХОДАМ-РАСХОДАМ<br>ПО ДЕПАРТАМЕНТУ " 
    v-name "<br>ЗА ПЕРИОД " string(dt1) +  "г. - " string(dt2)  "г. " "</b></p>"  skip
    "<TABLE border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

if prz = 2 then do:
  put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>ИТОГО</TD>" skip
       "<TD>Валюта/ГК</TD>" skip
       "<TD>N транз.</TD>" skip
       "<TD>Сумма в вал. </TD>" skip
       "<TD>Сумма в тенге</TD>" skip
       "<TD>Логин</TD>" skip
       "<TD>Сумма в USD</TD>" skip
       "</TR>" skip.
end.
else do:
  put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Счет ГК доходов/расходов</TD>" skip
       "<TD>Наименование счета ГК</TD>" skip
  /*
       "<TD>Сумма в вал. </TD>" skip
       "<TD>Сумма в тенге</TD>" skip
  */
       "<TD>Сумма в USD</TD>" skip
       "</TR>" skip.
end.

for each temp break by temp.doxras by temp.gl by temp.crc.
  
  ACCUMULATE temp.amt    (total by temp.doxras   by temp.gl   by temp.crc).
  ACCUMULATE temp.amtkzt (total by temp.doxras   by temp.gl   by temp.crc).

  if prz = 2 then do:
    put stream vcrpt unformatted
       "<TR align=""center"">" skip 
         "<TD>&nbsp;</TD>" skip
         "<TD>"string(temp.crc)"</TD>" skip
         "<TD>"string(temp.jh)"</TD>" skip
         "<TD>" + replace(string(temp.amt,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
         "<TD>" + replace(string(temp.amtkzt,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
         "<TD>" temp.ofc "</TD>" skip
         "<TD>&nbsp;</TD>" skip
         "</TR>" skip.
  end.

  if last-of(temp.crc) then  do: 
    sumcrc1 = ACCUMulate total  by (temp.crc) temp.amt.   
    sumcrc2 = ACCUMulate total  by (temp.crc) temp.amtkzt.   
    find crc where crc.crc = temp.crc no-lock no-error.

    if prz = 2 then do:
      put stream vcrpt unformatted
        "<TR align=""center"" style=""font:bold"">" skip 
        "<TD>Итого по валюте</TD>" skip
        "<TD>" crc.code "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>" + replace(string(sumcrc1,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(sumcrc2,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip.
    end.
/*
    else do:  
      put stream vcrpt unformatted
         "<TR align=""center"">" skip 
         "<TD>&nbsp;</TD>" skip
         "<TD>" crc.code "</TD>" skip
         "<TD>" replace(string(sumcrc1,"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
         "<TD>" replace(string(sumcrc2,"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
         "<TD>&nbsp;</TD>" skip
         "</TR>" skip.
    end.
*/
  end. /*last-of crc*/

  if last-of(temp.gl) then  do: 
    sumgl = ACCUMulate total by (temp.gl) temp.amtkzt.   

    find gl where gl.gl = temp.gl no-lock no-error.
    if prz = 2 then do:
      put stream vcrpt unformatted        
       "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Итого по ГК " string(temp.gl) "</TD>" skip
       "<TD colspan=3 align=left>" gl.des "</TD>" skip
       "<TD>" replace(string(sumgl, "zzzzzzzzzzzzz9.99-"), ".", ",") "</TD>" skip
       "<TD>&nbsp;</TD>" skip
       "<TD>" replace(string(sumgl / v-rateusd, "zzzzzzzzzzzzz9.99-"), ".", ",") "</TD>" skip
       "</TR>" skip.
    end.
    else do:  
      put stream vcrpt unformatted
         "<TR>" skip 
         "<TD align=""center"">" string(temp.gl) "</TD>" skip
         "<TD>" gl.des "</TD>" skip
/*
         "<TD colspan=3 align=left>" string(temp.gl) " " gl.des "</TD>" skip
         "<TD>" + replace(string(sumgl,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
*/
         "<TD align=right>" replace(string(sumgl / v-rateusd, "zzzzzzzzzzzzz9.99-"), ".", ",") "</TD>" skip
         "</TR>" skip.
    end.
  end. /*last-of gl*/

  if last-of(temp.doxras) then  do: 
    sumdoxras = ACCUMulate total by (temp.doxras) temp.amtkzt.
    if temp.doxras = "dox" then sumdox = sumdoxras.
                           else sumras = sumdoxras.
    if prz = 2 then do:
      put stream vcrpt unformatted        
       "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Итого по " if temp.doxras = "dox" then "доходам" else "расходам" "</TD>" skip
       "<TD>&nbsp;</TD>" skip
       "<TD>&nbsp;</TD>" skip
       "<TD>&nbsp;</TD>" skip
       "<TD>" replace(string(sumdoxras,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
       "<TD>&nbsp;</TD>" skip
       "<TD>" replace(string(sumdoxras / v-rateusd,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
       "</TR>" skip.
    end.
    else do:  
       put stream vcrpt unformatted
          "<TR style=""font:bold"">" skip 
          "<TD colspan=2>Итого по " if temp.doxras = "dox" then "доходам" else "расходам" "</TD>" skip
/*
          "<TD>&nbsp;</TD>" skip
          "<TD>&nbsp;</TD>" skip
          "<TD>" replace(string(sumdoxras,"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
*/
          "<TD align=right>" replace(string(sumdoxras / v-rateusd, "zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
          "</TR>" skip.
    end.
  end. /*last-of doxras*/
end.

if prz = 2  then
    put stream vcrpt unformatted        
     "<TR align=""center"" style=""font:bold"">" skip 
     "<TD>Доходы - расходы</TD>" skip
     "<TD>&nbsp;</TD>" skip
     "<TD>&nbsp;</TD>" skip
     "<TD>&nbsp;</TD>" skip
     "<TD>" replace(string(sumdox - sumras,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
     "<TD>&nbsp;</TD>" skip
     "<TD>" replace(string((sumdox - sumras) / v-rateusd,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
     "</TR>" skip.
else 
    put stream vcrpt unformatted
     "<TR style=""font:bold"">" skip 
     "<TD colspan=2>Доходы - расходы</TD>" skip
/*
     "<TD>&nbsp;</TD>" skip
     "<TD>&nbsp;</TD>" skip
     "<TD>" replace(string(sumdox - sumras,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
*/
     "<TD align=right>" replace(string((sumdox - sumras) / v-rateusd,"zzzzzzzzzzzzz9.99-"),".",",") "</TD>" skip
     "</TR>" skip.



/*output stream rpt close.
run menu-prt("doxras.img").*/
put stream vcrpt unformatted
  "</TABLE>" skip.


{html-end.i " stream vcrpt "}

output stream vcrpt close.

unix silent cptwin value(p-filename) excel.
pause 0.

