/* lb100tax.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Программа формирования файла сообщения по НАЛОГОВЫМ ПЛАТЕЖАМ при выгрузке
 * RUN
        
 * CALLER
        lb100.p, lb100g.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-5-10
 * AUTHOR
        20.04.2004 nadejda
 * CHANGES
        15.07.2004 sasco переделал генерацию номера референса для 102 (чтобы до 999 платежей поместилось)
        19.08.2004 sasco отправка таможенных платежей - каждый идет в отдельный файл MT102
        18.01.2005 sasco     убрал поле SEND
        18.01.2005 sasco     вернул поле SEND
        08.04.2005 sasco вывод в файл напрямую без проверки на размер файла (seek) а то тормозит сильно
                         добавил do transaction для exclusive-lock (u-remtrz)
        11.04.2005 sasco добавил принудительные индексы
        13/04/2005 sasco убрал отладочные сообщения
        12/12/05   marinav - добавила КБК = 106105
        09.01.2006 suchkov - детали платежа 412 символов
        03/05/06 marinav -   если таможенный платеж iscust , то поле 32А повторно не выводить
        24/05/06   marinav  - в 70 поле - дата факт приема платежа
*/

{trim.i}

def input parameter iddat as date.
def input parameter v-paysys as char.
def input parameter p-cnt as integer.
def output parameter amttot like remtrz.payment.
def output parameter cnt as integer.

/* таможня или нет */
define variable iscust as logical. 
/* КБК для таможни */
def var v-kbkcustom as char init "105102,105105,105106,105107,105241,105242,105243,105244,105245,105246,105247,105248,105249,105250,105251,105255,105258,105259,105260,105261,105269,105270,105271,105272,105273,105274,105275,105276,105277,105278,105279,105280,105281,105283,105284,105285,105286,105287,105402,106101,106102,106103,106104,106105,106201,106202,106203,106204,203101".

/* sasco */
FUNCTION ToNumber returns char (inchar as char).
   DEF VAR tt as int.
   DEF VAR oc as char.
   oc = inchar.
   DO tt = 0 to 255:
      IF tt < 48 or tt > 57 THEN oc = GReplace (oc, CHR(tt), "").
   END.
   DO WHILE LENGTH (oc) > 9:
      oc = SUBSTR (oc, 2).
   END.
   if oc = "" then oc = "бн".
   RETURN oc.
END FUNCTION.

def var mt102sum as decimal .
def var ref102 as cha . 
def var num102 as int init 0 .
def var l-102 as log init false . 
def var v-ks as char .  /* v-ba */
def var v-ks1 as char .  /* v-ba */
def shared var g-today as date . 
def shared var g-ofc as cha .     
def shared var v-text as cha . 
def buffer u-remtrz for remtrz . 
def var l-atm as log initial false . 
def var rrr as log extent 255 initial true .
def var vvv as cha.
def var p-tax as log initial true . 
def var r-bic as cha. 
def var asim as int .
def var v-iii as cha extent 6 .
def var v-bb as cha . 
def var v-date as date.
def buffer t-bankl for bankl.
/*
def shared var vvsum as deci . 
def shared var nnsum as int . 
*/
def var v-i as decimal . 
def var i as int. 
def var vsim as cha .
def shared var vnum as int .
def var t-summ like remtrz.amt .
def var v-tmp as  cha . 
def var eii as int . 
def var v_num as int . 
def var t-n as int .
def var v-unidir as cha .
def var v-lbmfo as cha .
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def var ii as int . 
def var r-sqn like remtrz.remtrz . 
def var v-ob as cha .
def var v-on as cha .
def var v-bn as cha .
def var v-dt as cha .
def var v-ri as cha .
def var v-racc as cha . 
def var t-bn as cha .
def var t-on as cha .
def var t-amt as cha .
def var t1-amt as cha .
def var ourbic as cha .
def var lbbic as cha .
def var v-bnk as char.
def var v-name as char.
define variable vdetpay as character .

def var a-amttot like remtrz.payment .
def var a-cnt as int .
def var i1 as int .
def var n as int .
def var regs as cha .
def var filenum as int .
def var filenumstr as char.
def var daynum as cha .
def var ourbank as cha .
def stream main .
def stream second .
def stream atma . 
def var v-tnum as char.
def var v-clecod as cha. 
def var v-knp as char init "000".
def var v-field as cha extent 50.
def var s-error as cha.
def stream prot . 

/* 19.09.2003 nadejda */
def shared var mtsize as integer. /* максимальный размер файла сообщения в килобайтах */
def shared var mt102_max as integer.
def var v-seek as integer init 0.
def var v-seeklast as logical init no.
/*****/

/* 01.01.2004 nadejda - подборка налоговых платежей для формирования МТ102 в новом формате */
def shared temp-table t-rmztax 
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  field kbk as char
  field rnn as char
  field rem as char
  index main sbank sacc rbank racc rnn kbk rem.

def var eknp-code as char.

/***/

/* обнулим счетчик файлов */
filenum = 0.

/* функция myCustomer */
{mycustomer.i}

{chbin.i}

find first t-rmztax no-error.

/* если нет таких платежей -> выход */
if not available t-rmztax then 
    return.

{lb100s.i "v-paysys"}

/* v-unidir = "/tmp/" SASCO DEBUG */

do transaction :
 amttot = 0 .
 daynum = string(g-today - date(12, 31, year(g-today) - 1), "999") .
 output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks") append.
 
for each t-rmztax no-lock 
    break by t-rmztax.sbank by t-rmztax.sacc by t-rmztax.rbank by t-rmztax.racc by t-rmztax.rnn by t-rmztax.kbk:

  find first remtrz where remtrz.remtrz = t-rmztax.rem no-lock no-error.
  if not avail remtrz then next.

  find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
  if not avail bankl then next.

  /* sasco - проверка на таможню */
  iscust = no.
  if lookup (string(t-rmztax.kbk), v-kbkcustom) > 0 then iscust = yes.

   /*  Beginning of main program body */

  /* 19.09.2003 nadejda - для МТ102 - будем собирать сообщение в отдельный файл */
  /* unix silent rm -f /tmp/ttttmp.eks. */

  output stream main to value("/tmp/ttt.eks") .

  filenum = 2 + vnum * 100. /* 0 - пенсионные, 1 - обычные, 2 - налоговые по новой форме */
  filenumstr = string(filenum,"99999").
  p-tax = true .
  /* Beginning of main program body */

  find crc where crc.crc = remtrz.tcrc no-lock no-error.
  find first t-bankl where t-bankl.bank = remtrz.sbank no-lock no-error.
  find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.
  
  v-bb = t-bankl.name.
  if remtrz.sbank begins "TXB" and remtrz.sbank <> "TXB00" then do:
    find first comm.txb where comm.txb.bank = remtrz.sbank and comm.txb.consolid no-lock no-error.
    if avail comm.txb then v-bb = v-bb + "/RNN/" + entry(1, comm.txb.params).
  end. 
  
  v-bnk = myCustomer("/NAME/" + v-bb + " ", remtrz.sacc, "50", remtrz.remtrz).
  v-bn = myCustomer("/NAME/" + remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] + " ", remtrz.ba, "59", remtrz.remtrz).

  find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock use-index dcod no-error.
  if avail sub-cod then eknp-code = sub-cod.rcod. 
                   else eknp-code = "".
  if eknp-code <> "" and eknp-code matches "*,*,*" then v-knp =  entry(3, sub-cod.rcod). 
                                                   else v-knp = "000". 
 /*  if sub-cod.rcod <> "" and 
     sub-cod.rcod matches "*,*,*" then v-knp =  entry(3, sub-cod.rcod). 
                                  else v-knp = "000". */
  
 
  t-amt = trim(string(remtrz.payment, "zzzzzzzzzzzzzzz9.99-")) .
  if index(t-amt, ".") > 0 then t-amt = replace(t-amt, ".", ",").
  
  if iscust or first-of(t-rmztax.kbk) or 
     (not first-of(t-rmztax.kbk) and max102 > 0 and mt102sum + remtrz.payment >= max102) then do:
   /* 03/05/06 marinav - */
    if not iscust and not first-of(t-rmztax.kbk) and max102 > 0 and mt102sum + remtrz.payment >= max102 then do:
       t1-amt = trim(string(mt102sum, "zzzzzzzzzzzzzzz9.99-")).
       if index(t1-amt, ".") > 0 then t1-amt = replace(t1-amt, ".", ",").

       put stream main unformatted ":32A:"
                       substring(string(year(iddat)), 3, 2) 
                       month(iddat) format "99" 
                       day(iddat) format "99"
                       crc.code format "x(3)"
                       t1-amt skip 
                       "-}"  skip.

       /* 19.09.2003 nadejda */
       v-seeklast = yes.
    end.
    
    mt102sum = 0 .
    num102 = num102 + 1  .



    ref102 =  caps(v-paysys) + "M" + substring(string(year(g-today)), 4, 1) +
              string(month(g-today), "99") +
              string(day(g-today), "99") +
/*              "-" + filenumstr + "-" + string(num102). */
              "-" + filenumstr + string(num102, "999"). 




    put stream main unformatted
         "\{1:" +  v-tnum + "\}" skip "\{2:I102S".

    if v-paysys = "c" then put stream main unformatted "CLEAR".
                      else put stream main unformatted "GROSS".
      
      /*iban*/
    put stream main unformatted
         "000000U3003"  + "\}" skip 
         "\{4:" skip
         ":20:" ref102 skip.

     /* организация-отправитель, т.е. реквизиты нашего офиса/филиала */
     if v-bin = yes then v-bnk = replace(v-bnk,"RNN","IDN"). 
     if not iscust then put stream main unformatted caps(v-bnk).
     else do: /* реквизиты плательщика для таможни */
             v-name = "".
             if index(trim(remtrz.ord), "/RNN/") = 0 then 
               v-name = trim(remtrz.ord).
             else
               v-name = trim(substr(trim(remtrz.ord), 1, index(trim(remtrz.ord), "/RNN/") - 1)).
             if length(v-name) > 60 then v-name = trim(substr(v-name, 1, 60)).
             put stream main unformatted ":50:/D/" + remtrz.sacc + chr(10) +
                                         "/NAME/" + v-name + chr(10).

             v-name = "".
             if index(trim(remtrz.ord), "/RNN/") > 0 then 
                v-name = trim(substr(trim(remtrz.ord), index(trim(remtrz.ord), "/RNN/"))) + chr(10).
             else v-name = "/RNN/000000000000" + chr(10).
             repeat:
               if substr(v-name, index(v-name, "/RNN/") + 4, 1) = " " then 
                 v-name = replace(v-name, "/RNN/ ", "/RNN/") . 
               else leave . 
             end.         
             if v-bin = yes then v-name = replace(v-name,"RNN","IDN"). 
             put stream main unformatted v-name +
                                         "/CHIEF/НЕ ПРЕДУСМОТРЕНО" + chr(10) +
                                         "/MAINBK/НЕ ПРЕДУСМОТРЕНО" + chr(10).
     end. /* конец шапки для таможни */


     /* find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock use-index dcod no-error. */
     /* find first sub-cod where sub-cod.d-cod = "eknp" and  sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error . */
     if /* avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*" */
        eknp-code <> "" and eknp-code matches "*,*,*" then do :
        /* 
        put stream main unformatted "/IRS/" + substr(entry(1, sub-cod.rcod), 1, 1) skip.
        put stream main unformatted "/SECO/" + substr(entry(1, sub-cod.rcod), 2, 1) skip.
        */
        put stream main unformatted "/IRS/" + substr(entry(1, eknp-code), 1, 1) skip.
        put stream main unformatted "/SECO/" + substr(entry(1, eknp-code), 2, 1) skip.
     end.
     
     /*iban*/
     put stream main unformatted
            ":52B:" + trim(v-clecod) + chr(10) .

     put stream main unformatted
         if remtrz.rbank ne remtrz.rcbank then
            ":54B:" + trim(remtrz.rcbank)  + chr(10) 
         else ""
            ":57B:" + trim(remtrz.rbank)
         skip.


     /* получатель */
     if v-bin = yes then v-bn = replace(v-bn,"RNN","IDN"). 
     put stream main unformatted caps(v-bn).

     /*
     find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
     if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*" then do :
        put stream main unformatted "/IRS/" + substr(entry(2, sub-cod.rcod), 1, 1) skip.
        put stream main unformatted "/SECO/" + substr(entry(2,sub-cod.rcod), 2, 1) skip.
     end.
     */
     if eknp-code <> "" and eknp-code matches "*,*,*" then do :
        put stream main unformatted "/IRS/" + substr(entry(1, eknp-code), 1, 1) skip.
        put stream main unformatted "/SECO/" + substr(entry(1, eknp-code), 2, 1) skip.
     end.


     put stream main unformatted
         ":70:" skip 
         "/VO/08" skip
         "/SEND/07" skip  
         "/PSO/01" skip
         "/PRT/50" skip 
         "/BCLASS/" t-rmztax.kbk skip.

  end.

  put stream main unformatted
      ":21:" remtrz.remtrz skip
      ":32B:" 
      crc.code format "x(3)" 
      t-amt skip. 

  v-dt = ":70:/NUM/" + ToNumber (substr(remtrz.sqn, 19)) + chr(10).

/*        24/05/06   marinav  - в 70 поле - дата факт приема платежа*/

  if remtrz.rcvinfo[2] ne '' then
  v-dt = v-dt + 
         "/DATE/" + substr(string(year(date(remtrz.rcvinfo[2]))), 3, 2) + 
         string(month(date(remtrz.rcvinfo[2])), "99") + string(day(date(remtrz.rcvinfo[2])), "99") + 
         chr(10).
  else
  v-dt = v-dt + 
         "/DATE/" + substr(string(year(remtrz.valdt1)), 3, 2) + 
         string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1), "99") + 
         chr(10).
  

  v-on = "/NAME/".
  v-name = "".
  if index(trim(remtrz.ord), "/RNN/") = 0 then 
    v-name = trim(remtrz.ord).
  else
    v-name = trim(substr(trim(remtrz.ord), 1, index(trim(remtrz.ord), "/RNN/") - 1)).
  if length(v-name) > 60 then v-name = trim(substr(v-name, 1, 60)).
  v-on = v-on + v-name + chr(10).

  if index(trim(remtrz.ord), "/RNN/") > 0 then 
    v-on = v-on + trim(substr(trim(remtrz.ord), index(trim(remtrz.ord), "/RNN/"))) + chr(10).
  
  repeat:
    if substr(v-on, index(v-on, "/RNN/") + 4, 1) = " " then 
      v-on = replace(v-on, "/RNN/ ", "/RNN/") . 
    else leave . 
  end.                 

  put stream main unformatted 
      v-dt 
      caps(v-on)
      "/KNP/" + v-knp skip.

  v-dt = "/ASSIGN/". 

     vdetpay = "" .
     do ii = 1 to 4:
        vdetpay = vdetpay + trim(remtrz.detpay[ii]).
     end.

     if vdetpay <> "" then do:
       if length (vdetpay) > 62 then do:
          if length (vdetpay) > 132 then do:
             if length (vdetpay) > 202 then do:
                if length (vdetpay) > 272 then do:
                   if length (vdetpay) > 342 then do:
                      if length (vdetpay) > 412 then
                        v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343,70) .
                   else v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343).
                   end.
                   else v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273).
                end.
                else v-dt = v-dt + substring (vdetpay,1,62) 
                       + chr(10) + substring (vdetpay,63,70) 
                       + chr(10) + substring (vdetpay,133,70) 
                       + chr(10) + substring (vdetpay,202).
             end.
             else v-dt = v-dt + substring (vdetpay,1,62) 
                    + chr(10) + substring (vdetpay,63,70) 
                    + chr(10) + substring (vdetpay,133).
          end.
          else v-dt = v-dt + substring (vdetpay,1,62) + chr(10) + substring (vdetpay,63).
       end.
       else v-dt = v-dt + vdetpay .
     end.
     v-dt = v-dt + chr(10).

  put stream main unformatted caps(v-dt).


   /* SASCO DEBUG - comment u-remtrz if you just testing test */
  /* 08.04.05 - transaction */
  do transaction:
     find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock.
     u-remtrz.t_sqn = ref102.
     u-remtrz.ref = "p" + daynum + filenumstr + ".eks/102/" + string(num102) + "/".
  end.

  mt102sum = mt102sum + remtrz.payment.


  /* sasco добавил проверку на таможню */
  if  iscust  or  last-of(t-rmztax.kbk) then do:
    t-amt = trim(string(mt102sum, "zzzzzzzzzzzzzzz9.99-")).
    if index(t-amt,".") > 0 then t-amt = replace(t-amt, ".", ",").
    
    put stream main unformatted ":32A:"
        substring(string(year(iddat)), 3, 2) 
        month(iddat) format "99" 
        day(iddat) format "99"
        crc.code format "x(3)"
        t-amt skip
        "-}"  skip.

    /* 19.09.2003 nadejda */
    v-seeklast = yes.
  end.
    
  cnt = cnt + 1.
  amttot = amttot + remtrz.payment.

  put stream prot unformatted p-cnt + cnt ":" trim(remtrz.remtrz)
    if index(remtrz.sqn, ".", 19) = 0 then caps(substring(remtrz.sqn, 19))
    else caps(substring(remtrz.sqn, 19,index(remtrz.sqn, ".", 19) - 19)) ":"
    v-ks ":" remtrz.payment " - p" + daynum + filenumstr + ".eks"
    " (102_" + string(num102) + ")"
    skip.
  
  output stream main close .

   if filenum > 0 then do:
     /* 19.09.2003 nadejda  - для МТ102 - прибавить полученный файл к общему сообщению */

/*     if l-102 then unix silent value("cat /tmp/ttt.eks >> /tmp/ttttmp.eks") .*/

     unix silent value("cat /tmp/ttt.eks >>" + v-unidir + "p" + daynum + filenumstr + ".eks").
     unix silent /bin/rm -f /tmp/ttt.eks.
   end.


/* ДАЛЕЕ СЛЕДУЕТ ТОРМОЗНАЯ ПРОВЕРКА НА РАЗМЕР ФАЙЛА */
/*  
  unix silent value("cat /tmp/ttt.eks >> /tmp/ttttmp.eks").

  unix silent value("cat /tmp/ttt.eks >>" + v-unidir + "p" + daynum + filenumstr + ".eks") .
  unix silent /bin/rm -f /tmp/ttt.eks.

  if v-seeklast then do:
    v-seeklast = no.

    unix silent un-dos /tmp/ttttmp.eks /tmp/ttttmpd.eks.
    input stream main from /tmp/ttttmpd.eks.
    seek stream main to end.
    v-seek = seek (main).
    input stream main close.
    unix silent /bin/rm -f /tmp/ttttmp.eks.
    unix silent /bin/rm -f /tmp/ttttmpd.eks.

    if v-seek >= mtsize then
      message skip " Размер файла сообщения" v-seek "кБ превышает допустимый" mtsize "кБ !" 
              skip " Уменьшите максимальное количество платежей в пачке (" mt102_max ")~n~n и ПЕРЕФОРМИРУЙТЕ пачку!" 
              skip(1) view-as alert-box button ok title " ОШИБКА ! ".

    v-seek = 0.
  end.
*/

 end. /*  for each  t-rmztax  */

end.

output stream prot close.

