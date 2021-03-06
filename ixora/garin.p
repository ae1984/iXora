﻿/* garin.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Перевод суммы для погашения рефинансируемого кредита и непосредственно погашение
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        18/02/2009 id00004
 * BASES
        bank, comm
 * CHANGES
*/

{global.i}

  def new shared var s-jh  like jh.jh.

  def var v-ln as int.
  define var v-code as char.
  define var v-dep as char format 'x(3)'.

  def var n-aaan like aaa.aaa.
  update n-aaan label "Номер счета" with centered overlay color message row 5 frame f-aaa.
  hide frame f-aaa.


  find last aaa where aaa.aaa = n-aaan exclusive-lock no-error.
  if not avail aaa then do:
     message "Cчет не найден.".  pause. return.  
  end.





  if avail aaa then do:

     if not string(aaa.gl) begins "2203" and    
        not string(aaa.gl) begins "2211" and
        not string(aaa.gl) begins "2215" and
        not string(aaa.gl) begins "2217" and
        not string(aaa.gl) begins "2219" and
        not string(aaa.gl) begins "2221" and
        not string(aaa.gl) begins "2222" and

        not string(aaa.gl) begins "2204" and
        not string(aaa.gl) begins "2205" and
        not string(aaa.gl) begins "2206" and
        not string(aaa.gl) begins "2207" and
        not string(aaa.gl) begins "2208" and
        not string(aaa.gl) begins "2209" 

     then do:
        message "Ошибка: Согласно ТЗ операция доступна для счетов: 2203,2211,2215,2217,2219,2221,2222,2204,2205,2206,2207,2208,2209".
        pause.
        return.
     end.


     do transaction on error undo,leave:

        find last trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 1 no-lock no-error.
        run x-jhnew.
        pause 0.
        find jh  exclusive-lock where jh.jh = s-jh no-error.
        if not avail jh then return. 
        jh.crc = 0.
        jh.party = "GL CORRECTION TRANSACTION".
        jh.jdt = g-today.

         v-ln = 1.
         create jl.
         jl.jh = jh.jh.
         jl.ln = v-ln.
         jl.crc = aaa.crc.
         jl.who = jh.who.
         jl.jdt = jh.jdt.
         jl.whn = jh.whn.   
         jl.dc = "D".
         jl.sub = "CIF".
/*       jl.lev = 16. 	*/
         jl.acc = "".
         jl.rem[1] = "GL CORRECTION TRANSACTION".
         if (trxbal.dam - trxbal.cam) > 0 then do:
           jl.dam = trxbal.dam - trxbal.cam.
if string(aaa.gl) begins "2204" or string(aaa.gl) begins "2205" or  string(aaa.gl) begins "2206" or  string(aaa.gl) begins "2207" or string(aaa.gl) begins "2208" or string(aaa.gl) begins "2209" then
   jl.gl = 221330.
else
   jl.gl = 222330.


         end.
         else do:
           jl.dam = - (trxbal.dam - trxbal.cam).
           jl.gl = aaa.gl.
         end.
         jl.cam = 0.
         
         {cods.i}
         v-ln = v-ln + 1.

         create jl.
         jl.jh = jh.jh.
         jl.ln = v-ln.
         jl.crc = aaa.crc.
         jl.who = jh.who.
         jl.jdt = jh.jdt.
         jl.whn = jh.whn.
         jl.dc = "C".
         jl.acc = "".
         jl.rem = "GL CORRECTION TRANSACTION".
         if (trxbal.dam - trxbal.cam) > 0 then do:
           jl.cam = (trxbal.dam - trxbal.cam).
           jl.gl = aaa.gl.
         end.
         else do:
           jl.cam = - (trxbal.dam - trxbal.cam).

           if string(aaa.gl) begins "2204" or string(aaa.gl) begins "2205" or  string(aaa.gl) begins "2206" or  string(aaa.gl) begins "2207" or   string(aaa.gl) begins "2208" or   string(aaa.gl) begins "2209"  then
              jl.gl = 221330.
           else
              jl.gl = 222330.
         end.
         jl.dam = 0.
         {cods.i}


  create aan.
  aan.sub = 'cif'.
  aan.aaa = aaa.aaa.
  aan.crc = aaa.crc.
  aan.fdt = g-today.
  aan.glold = aaa.gl.

  if string(aaa.gl) begins "2204" or string(aaa.gl) begins "2205" or  string(aaa.gl) begins "2206" or  string(aaa.gl) begins "2207" or   string(aaa.gl) begins "2208" or   string(aaa.gl) begins "2209"  then
     aan.glnew = 221330.
  else
     aan.glnew = 222330.

  aan.lgrold = aaa.lgr.
  aan.lgrnew = aaa.lgr.
  aan.rem = 'Сс счет ' + aaa.aaa + ', перенос c Г/К ' + string(aaa.gl) + ' на Г/К ' + string(aan.glnew).

def var v-dbpath as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

    output to value(v-dbpath + "Garantii.log") append.
    put unformatted
        g-today " "
        string(time, "hh:mm:ss") " "
        userid("bank") format "x(8)" " "
        aaa.aaa " Перенос с Г/К " aaa.gl " на Г/К 222330  Транзакция " jl.jh
        skip.
    output close.


    if string(aaa.gl) begins "2204" or string(aaa.gl) begins "2205" or  string(aaa.gl) begins "2206" or  string(aaa.gl) begins "2207" or   string(aaa.gl) begins "2208" or   string(aaa.gl) begins "2209"  then
       aaa.gl = 221330.
    else
       aaa.gl = 222330.

     message "Перенос суммы успешно завершен. Номер транзакции " jl.jh  view-as alert-box title "".
     run mail("denis@metrobank.kz", "Депозит-гарантия <abpk@metrocombank.kz>", "Перенос счета", "cif=" + aaa.cif + " счет " + aaa.aaa + " Перенос с Г/К " + string(aaa.gl) + " на Г/К " + string(aan.glnew) + "  Транзакция " + string(jl.jh) , "1", "","").
     end.
  end.





