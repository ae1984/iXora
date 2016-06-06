/* tdamat1.p
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
*/

/*   tdamat1.p
    28/03/02 Выплата просроченных депозитов
    28/10/2013 Luiza  - ТЗ 1937 конвертация депозит cda0003 и uni0048
*/

def shared var g-aaa like aaa.aaa.
def shared var g-lang as char.
def shared var g-today as date.

def var p-aaa like aaa.aaa.
define buffer b-aaa for aaa.
define buffer b-lgr for lgr.
define var grobal  like aal.amt.
define var avabal  like aal.amt.
define var intrat  like aaa.rate.
define var mtddb   like aal.amt.
define var mtdcr   like aal.amt.
define var ytdint  like aal.amt.
define var voldacc as dec decimals 2.
define var vintpay as log label "PAY INTEREST?".
define var vpenalty like aal.amt label "PENALTY".
define var vans as log format "Да/Нет".
define var v-log as log.
define var v-rate like aaa.rate format ">>9.99%".
define var v-intpay like aaa.cbal.
define new shared var s-amt like aal.amt.
define new shared var s-amt1 like aal.amt.
define new shared var s-amt2 like aal.amt.
define new shared var s-amt3 like aal.amt.
define new shared var s-jh like aal.jh.
def new shared var s-aaa like aaa.aaa.
define variable vcalc like aaa.accrued.
define variable vcalc1 like aaa.accrued.
define variable vcalcsv like aaa.accrued.
define variable saccr like aal.amt.
define variable s-sum like aal.amt.
define variable v-taxrate like pri.rate format ">>9.99%".
define variable v-taxamt like jl.dam.
define variable v-geo as integer.
define variable vsanproc like aal.amt.
def var v-param as char.
def var vdel as char initial "^".
def var v-templ as char.
def var rcode as int.
def var rdes as char.
def var ja as log format "Да/Нет".
def var vou-count as int.
def var i as int.
def var v-amt11nc like jl.dam.
def var v-amt11 like jl.dam.



{tdamat1.f}

outer:
repeat:
  clear frame aaa.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq "" then prompt-for aaa.aaa with frame aaa.
                 else display g-aaa @ aaa.aaa with frame aaa.
  find aaa using aaa.aaa.
  find crc of aaa.
  find cif of aaa.
  s-aaa = aaa.aaa.
  p-aaa = aaa.craccnt.

  run aaa-aas.
  find first aas where aas.aaa = s-aaa and (aas.sic = 'SP' or aas.sic eq "HB")
  no-lock no-error.
  if available aas then do: pause.
  undo,retry. end.

  find lgr where lgr.lgr eq aaa.lgr.
  if lgr.led ne "CDA" and lgr.led ne "CSA"
  then do:
     bell.
    {mesg.i 8212}.
     undo, retry.
  end.
  if aaa.sta eq "C"
  then do:
      bell.
      message "Счет закрыт".
      undo, retry.
  end.

  if aaa.hbal ne 0 then do:
    bell.
    {mesg.i 8806}.
    {mesg.i 0928} update v-log.
    if v-log eq false then undo,leave.
  end.
  if lgr.lookaaa eq true
  then do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq aaa.pri no-error.
         intrat = pri.rate + aaa.rate.
         end.
         else intrat = aaa.rate.
       end.
  else do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq lgr.pri.
         intrat = pri.rate + lgr.rate.
         end.
         else intrat = lgr.rate.
       end.

   find first b-aaa where b-aaa.aaa = p-aaa.
     if avail b-aaa then
       message "Просроченный депозит, счет " b-aaa.aaa
       " Сумма " b-aaa.cr[1] - b-aaa.dr[1]
       " Процент " b-aaa.accrued.

   find b-lgr where b-lgr.lgr = b-aaa.lgr.

  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = b-aaa.cbal.
  ytdint = aaa.dr[2] + b-aaa.dr[2].
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  vsanproc = aaa.dr[2] - aaa.cr[3].
  do transaction:
     aaa.accrued = aaa.cr[2] - aaa.dr[2].
  end.
  vcalc = aaa.accrued.
  vcalc1 = b-aaa.accrued.

  display
     cif.cif   aaa.gl
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname aaa.aaa  b-aaa.aaa b-aaa.gl
     aaa.sta   crc.des
     grobal aaa.hbal
     avabal vcalc vcalc1
     intrat
     ytdint
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt aaa.expdt
     vsanproc when vsanproc ge 0 aaa.cr[3]
     with frame aaa.


  vans = no.
  message "Закрывать депозит  (Да/Нет) ? " update vans.
  if vans eq false then next.

  vintpay = true.
  vpenalty = 0.
  vcalc = 0.
  v-rate = 0.

  vcalc = aaa.accrued.
  update vcalc validate (vcalc ne 0, "Введите сумму !") with frame aaa.
  update vcalc1 with frame aaa.

  vcalcsv = vcalc + vcalc1.
  display vcalcsv with frame aaa.

  if aaa.expdt gt g-today then do:
      bell.
      {mesg.i 6807}.

      update v-rate with frame aaa.

      vpenalty = (vcalc + vsanproc) * v-rate  / 100.

      update /* vintpay */ vpenalty with frame aaa.
  end.

    v-geo = integer(cif.geo).
    v-taxrate = 0.
    if length(cif.geo) gt 0 then
    v-geo = integer(substring(cif.geo,length(cif.geo),1)). else v-geo = 0.
    if (v-geo eq 2 or v-geo eq 3)
        and substring(cif.lgr,1,1) eq "Y" then do:
            find sysc where sysc.sysc eq "TAXNR%" no-lock no-error.
            if available sysc then v-taxrate = sysc.deval. else v-taxrate = 0.
    end.

  /*  update v-taxrate with frame aaa.
    v-taxamt = maximum(vcalc - vpenalty,0) * v-taxrate / 100.00 .
    update v-taxamt validate(v-taxamt ge 0 ,"") with frame aaa.*/
  s-jh = 0.
  do transaction on error undo,retry:

   /* Для депозита*/
   if vintpay eq true and aaa.cr[2] gt aaa.dr[2] then do:
      saccr = aaa.cr[2] - aaa.dr[2].
      s-amt = round(vcalc , crc.decpnt).
      s-amt1 = 0.
      s-amt2 = saccr - s-amt.
      find first trxbal where trxbal.acc = aaa.aaa and trxbal.level = 11.
      s-amt3 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1],2).

      message trxbal.dam trxbal.cam crc.rate[1] s-amt3.

      if saccr ne s-amt then do :
        /* Подгонка 2 уровня */

        if s-amt2 > s-amt3 then s-amt1 = s-amt2 - s-amt3.

        v-templ = "cda0003".
        /*v-param = string(maximum(s-amt - saccr,0)) + vdel
        + aaa.aaa + vdel + string(0 - minimum(s-amt - saccr + s-amt1,0)).*/

        if aaa.crc = 1 then v-param = string(maximum(s-amt - saccr,0)) + vdel + aaa.aaa + vdel +
                            string(0) + vdel + aaa.aaa + vdel +
                            "0" + vdel + string(0 - minimum(s-amt - saccr + s-amt1,0)) + vdel + aaa.aaa.
        else v-param = string(maximum(s-amt - saccr,0)) + vdel + aaa.aaa + vdel +
                        string(0 - minimum(s-amt - saccr + s-amt1,0)) + vdel + aaa.aaa + vdel +
                        string(round((0 - minimum(s-amt - saccr + s-amt1,0)) * crc.rate[1],2)) + vdel +
                        string(0) + vdel + aaa.aaa.

        run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
        output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message v-templ ' ' rdes.
            pause.
            message v-param.
            pause.
            undo,retry.
        end.


        if s-amt2 > s-amt3 then do:
           s-amt1 = s-amt2 - s-amt3.
           v-templ = 'uni0048'.
           message s-amt1 s-amt2 s-amt3.
           /*v-param = string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов".*/
           if aaa.crc = 1 then v-param = string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel +
                                    string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
           else v-param = string(0) + vdel + aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel + string(round(s-amt1 * crc.rate[1],2)).
           run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
           output rcode, output rdes, input-output s-jh).

           if rcode ne 0 then do:
               message v-templ ' ' rdes.
               pause.
               message v-param.
               pause.
               undo,retry.
           end.
        end.



      end.

      v-templ = "uni0049".
      v-param = string(s-amt) + vdel
      + aaa.aaa + vdel + b-aaa.aaa + vdel + 'Выплата процентов'
      + vdel + string(lgr.autoext,"999").
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).

      if rcode ne 0 then do:
         message v-templ ' ' rdes.
         pause.
         undo,retry.
      end.
  end.




 /* Для SAV счета*/
   if vintpay eq true and b-aaa.cr[2] gt b-aaa.dr[2] then do:
      saccr = b-aaa.cr[2] - b-aaa.dr[2].
      s-amt = round(vcalc1 , crc.decpnt).
      if saccr ne s-amt then do :
        /* Подгонка 2 уровня */
        v-templ = "cda0003".
        /*v-param = string(maximum(s-amt - saccr,0)) + vdel
        + b-aaa.aaa + vdel + string(0 - minimum(s-amt - saccr ,0)).*/
        if aaa.crc = 1 then v-param = string(maximum(s-amt - saccr,0)) + vdel + aaa.aaa + vdel +
                            string(0) + vdel + aaa.aaa + vdel +
                            "0" + vdel + string(0 - minimum(s-amt - saccr ,0)) + vdel + aaa.aaa.
        else v-param = string(maximum(s-amt - saccr,0)) + vdel + aaa.aaa + vdel +
                        string(0 - minimum(s-amt - saccr ,0)) + vdel + aaa.aaa + vdel +
                        string(round((0 - minimum(s-amt - saccr ,0)) * crc.rate[1],2)) + vdel +
                        string(0) + vdel + aaa.aaa.
        run trxgen (v-templ, vdel, v-param, "CIF" , b-aaa.aaa ,
        output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message v-templ ' ' rdes.
            pause.
            message v-param.
            pause.
            undo,retry.
        end.

      end.

      v-templ = "cda0001".
      v-param = string(s-amt) + vdel
      + b-aaa.aaa + vdel + string(b-lgr.autoext,"999").
      run trxgen (v-templ, vdel, v-param, "CIF" , b-aaa.aaa ,
      output rcode, output rdes, input-output s-jh).

      if rcode ne 0 then do:
         message v-templ ' ' rdes.
         pause.
         undo,retry.
      end.
 end.

    if v-taxamt gt 0 then do:
      v-templ = "cda0002".
      v-param = string(v-taxamt) + vdel
      + b-aaa.aaa.
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).

      if rcode ne 0 then do:
         message v-templ ' ' rdes.
         pause.
         undo,retry.
      end.
    end. /* v-taxamt ge 0 */

  display s-jh with frame aaa.

  aaa.accrued = 0.
  b-aaa.accrued = 0.
  aaa.sta = "M".
  b-aaa.sta = 'M'.
  end.
  if s-jh ne 0 then do :

    find jh where jh.jh = s-jh.

    /* pechat vauchera */
    ja = no.
    vou-count = 1. /* kolichestvo vaucherov */

    do on endkey undo:
        find first jl where jl.jh = s-jh no-error.
          if available jl  then do:

        message "Печатать ваучер ?" update ja.
        if ja   then do:
             message "Сколько ?" update vou-count.
            if vou-count > 0 and vou-count < 10 then do:
                    {mesg.i 0933} s-jh.
                    s-jh = jh.jh.
                    do i = 1 to vou-count:
                        run x-jlvou.
                    end.

                    run trxsts(input s-jh,input 6, output rcode, output rdes).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                    end.
                    /*
                    if jh.sts < 5
                    then jh.sts = 5.
                    for each jl of jh:
                        if jl.sts < 5
                        then jl.sts = 5.
                    end.
                    */
              end.  /* if vou-count > 0 */
        end. /* if ja */
       if not ja then  do:
     /* message 's-jh =' s-jh. pause 20 .  return.  */
        {mesg.i 0933} s-jh.    s-jh = jh.jh. pause 5.
        run trxsts(input s-jh,input 6, output rcode, output rdes).
          if rcode ne 0 then do:
              message rdes.
              pause.
          end.
        end. /*  if not ja*/
        pause 0.

      end.  /* if available jl */
           else do:
                    message "Can't find transaction " s-jh view-as alert-box.
                    return.
                end.
        end. /*if s-jh ne 0 */
    pause 0.
    view frame lon.
    view frame ln1.

  end.
end. /* outer */
