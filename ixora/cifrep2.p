/* cifrep2.p

 * MODULE

 * DESCRIPTION
        отчет по категориям клиентов форма 1 (1.4.1.9.9)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        14.09.2010 k.gitalov
 * CHANGES
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD

*/

{global.i}

def var CurCat as char.
def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer b-lgr for lgr.
def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var dt_tmp as date no-undo.
def var day-count as int.
def var all-bal as deci.
def var tmp-bal as deci.
def var unknown as deci init 0.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.
def var repname as char init "".
def var v-result as char init "".


define temp-table wrk
       field cif as char           /*Код клиента*/
       field trw as char           /*Категория клиента*/
       field acc as char           /*счет клиента*/
       field crc as int            /*валюта счета*/
       field send-val as deci      /*Переводные операции*/
       field send-val-count as int
       field conv-oper as deci     /*Конвертация*/
       field conv-oper-count as int
       field dam as deci           /*Расход*/
       field dam-count as int
       field cam as deci           /*Приход*/
       field cam-count as int
       field sr-bal as deci        /*среднемесячные остатки*/
       field pass as int           /*кол-во действующих паспортов сделок*/
       field activ as log.         /*активный счет (если KZT) и не менее 3 операций по Кт*/

define temp-table gl_wrk
            field type as int
            field gl as int
            field tarcod as char
            field name as char
            field crc as int.

/**************************************************************************************/
function LogFile returns integer (input p-file as char, input p-mess as char).
    output to value(p-file) append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
    return 0.
end function.
/**************************************************************************************/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/**************************************************************************************/
function DeleteFile returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("rm " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/**************************************************************************************/
function GetCatName returns char ( input code as char ):
  find first codfr where codfr.codfr = 'cifkat' and codfr.code = code no-lock no-error.
  if avail codfr then return codfr.name[1].
  else return codfr.code.
end function.
/**************************************************************************************/
function GetNormSumm returns char (input summ as deci):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then
   do:
    ss1 = summ.
    ret = string(ss1,">>>>>>>>>>>>>>>>9.99").
   end.
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,">>>>>>>>>>>>>>>>9.99")).
   end.
   return trim(ret).
end function.
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/**************************************************************************************/
function GetTypeCod returns int (input code as char ,input r-jh as int ):
  def buffer b-gl_wrk for gl_wrk.
  find first b-gl_wrk where b-gl_wrk.tarcod = trim(code) no-lock no-error.
  if avail b-gl_wrk then return b-gl_wrk.type.
  else do:
    LogFile("cifrep2.log","Не найден код тарифа " + code + " для проводки " + string(r-jh)).
    return 0.
  end.
end function.
/**************************************************************************************/
function GetType returns int (input agl as int,input r-jh as int):
  def var curtype as int init -1.
  def buffer b-remtrz for remtrz.
  def buffer b-joudoc for joudoc.
  def buffer b-gl_wrk for gl_wrk.


  for each b-gl_wrk where b-gl_wrk.gl = agl no-lock:
    if curtype = -1 then curtype = b-gl_wrk.type.
    if curtype <> b-gl_wrk.type  then  /*Неоднозначное определение группы комисии*/
    do:

      find first b-remtrz where  b-remtrz.valdt2 <= dt2 and b-remtrz.valdt2 >= dt1 and  b-remtrz.jh1 = r-jh no-lock no-error.
      if avail b-remtrz then
      do:
        curtype = GetTypeCod ( string (b-remtrz.svccgr) , r-jh).
        if curtype = 0 then do: LogFile("cifrep2.log","Найден RMZ " + b-remtrz.remtrz + "  проводка:" + string(r-jh) + " код комиссии:" + string (b-remtrz.svccgr)). end.
      end.
      else do:
        find first b-joudoc where  b-joudoc.whn >= dt1 and b-joudoc.whn <= dt2 and  b-joudoc.jh = r-jh no-lock no-error.
        if avail b-joudoc then
        do:
          curtype = GetTypeCod ( string (b-joudoc.comcode) , r-jh).
          if curtype = 0 then do: LogFile("cifrep2.log","Найден JOU " + b-joudoc.docnum + "  проводка:" + string(r-jh) + " код комиссии - " + string (b-joudoc.comcode)). end.
        end.
      end.
      leave.
    end.
  end.
  return curtype.
end function.
/**************************************************************************************/
function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
 define buffer bcrc1 for crchis.
 define buffer bcrc2 for crchis.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end function.
/**************************************************************************************/
function GetCifName return char (input tcif as char):
  find first cif where cif.cif = tcif no-lock no-error.
  if avail cif then return cif.name.
  else return tcif.
end function.
/**************************************************************************************/
function GetSuppCred returns decimal ( input tcif as char ):
   def var summ as deci init 0.
   for each lon where lon.cif = tcif no-lock .
    for each lonres where lonres.jdt >= dt1 and lonres.jdt <= dt2 and lonres.lon = lon.lon and lonres.dc = 'c' and ( lonres.lev = 2 or lonres.lev = 16 ) no-lock:
     if lonres.crc = 1 then summ = summ + lonres.amt.
	 else summ = summ + Convcrc(lonres.amt , lonres.crc , 1 , lonres.jdt ).
    end.
   end.
   return summ.
end function.
/**************************************************************************************/

function GetCount returns int ( input crc as int , input val as char ):
  def var rez as int.
  case val:
    when "Переводы" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.send-val-count.
      end.
    end.
    when "Конвертация" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.conv-oper-count.
      end.
    end.
    when "Приход" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.cam-count.
      end.
    end.
    when "Расход" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.dam-count.
      end.
    end.
  end case.
  return rez.
end function.

function GetPaySumm returns deci ( input crc as int , input val as char ):
  def var rez as deci. /* decimals 2 format "z,zzz,zzz,zzz,zz9.99-".*/
  case val:
    when "Переводы" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.send-val.
      end.
    end.
    when "Конвертация" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.conv-oper.
      end.
    end.
    when "Приход" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.cam.
      end.
    end.
    when "Расход" then do:
      for each wrk where wrk.crc = crc no-lock:
        rez = rez + wrk.dam.
      end.
    end.
  end case.
  return rez.
end function.


function GetKZTCount returns int ():
  def var rez as int init 0.
  for each wrk where wrk.crc = 1 no-lock:
   if wrk.activ then rez = rez + 1.
  end.
  return rez.
end function.

function GetPass returns int (input crc as int):
  def var rez as int init 0.
  for each wrk where wrk.crc = crc no-lock:
    rez = rez + wrk.pass.
  end.
  return rez.
end function.


function GetSrBal returns deci(input crc as int):
  def var rez as deci. /* decimals 2 format "z,zzz,zzz,zzz,zz9.99-".*/
   for each wrk where wrk.crc = crc no-lock:
     rez = rez + wrk.sr-bal.
   end.
  return rez.
end function.
/**************************************************************************************/



function CreateRec returns int ( input cif as char ,
                                 input acc as char ,
                                 input crc as int,
				                 output send-val as deci ,
                                 output send-val-count as int,
				                 output conv-oper as deci ,
                                 output conv-oper-count as int,
				                 output dam as deci ,
                                 output dam-count as int,
				                 output cam as deci ,
                                 output cam-count as int,
                                 output sr-bal as deci ,
                                 output pass as int ,
				                 output activ as log ):

  def var tmp-activ as int init 0.
  /*переводы только исходящие*/
  def buffer b-remtrz for remtrz.
  for each b-remtrz where  b-remtrz.valdt2 <= dt2 and b-remtrz.valdt2 >= dt1 and b-remtrz.sacc = acc and b-remtrz.jh1 <> ? and b-remtrz.jh2 <> ? no-lock:
    find first jh where jh.jh = b-remtrz.jh1 and jh.party begins "Storn" no-lock no-error.
    if avail jh then next.
    send-val = send-val + b-remtrz.payment.
    send-val-count = send-val-count + 1.
  end.

  /*конвертации*/
  for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.acc = acc and jl.ln = 1 /*and jl.dc = "D"*/ no-lock by jl.jh:
    find first jh where jh.jh = jl.jh and jh.party begins "Storn" no-lock no-error.
	if avail jh then next.
    find first dealing_doc where dealing_doc.jh = jl.jh no-lock no-error.
    if avail dealing_doc then do:
       conv-oper = conv-oper + jl.dam.
       conv-oper-count = conv-oper-count + 1.
    end.
  end.

  /*приход-расход  только кассовые*/
  def buffer b-jl for jl.
  for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.acc = acc no-lock by jl.jh:
    find first jh where jh.jh = jl.jh and jh.party begins "Storn" no-lock no-error.
    if avail jh then next.

    if jl.dc = "D" then do:
      find first b-jl where b-jl.jdt = jl.jdt and b-jl.jh = jl.jh and b-jl.dc = "C" and b-jl.ln = jl.ln + 1 no-lock no-error.
      if b-jl.gl = 100100 or b-jl.gl = 100200 then do:
        dam = dam + jl.dam.
        dam-count = dam-count + 1.
      end.
    end.
    else do:
      find first b-jl where b-jl.jdt = jl.jdt and b-jl.jh = jl.jh and b-jl.dc = "D" and b-jl.ln = jl.ln - 1 no-lock no-error.
      if b-jl.gl = 100100 or b-jl.gl = 100200 then do:
        cam = cam + jl.cam.
        cam-count = cam-count + 1.
      end.
    end.
    release b-jl.
  end.

  /*активные счета в тенге*/
  for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.acc = acc no-lock by jl.jh:
    find first jh where jh.jh = jl.jh and jh.party begins "Storn" no-lock no-error.
    if avail jh then next.
    find first b-jl where b-jl.jdt = jl.jdt and b-jl.jh = jl.jh and b-jl.dc = "C" and ( b-jl.gl = 460410 or b-jl.gl = 460430 ) no-lock no-error.
    if avail b-jl then next.  /*есть комиссия за конвертацию*/
     if jl.cam > 0 then do:
      if jl.crc = 1 then tmp-activ = tmp-activ + 1.
     end.
  end.



  /*среднемесячные остатки*/
  all-bal = 0.
  tmp-bal = 0.
  dt_tmp = dt1.
  do while dt_tmp < dt2 + 1 :
   run lonbalcrc('cif',acc,dt_tmp,"1",no,crc,output tmp-bal).
   all-bal = all-bal + (- tmp-bal).
   dt_tmp = dt_tmp + 1.
  end.
  sr-bal = all-bal / day-count.


 /*Открытые паспорта сделок*/
  for each vccontrs where  vccontrs.cttype = '1' and vccontrs.cif = cif  and vccontrs.ncrc = crc and vccontrs.cdt < dt2  no-lock:
   if vccontrs.ctclosedt > dt2 or vccontrs.sts = 'A' then pass = pass + 1.
  end.



  if tmp-activ >= 3 then activ = true.
  else activ = false.
 return 0.
end function.

/**************************************************************************************/
define frame fr
   skip(1)
   dt1      label 'C ' format '99/99/9999'
   dt2      label ' ПО' format '99/99/9999' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА".

   dt1 = g-today. dt2 = g-today.

   update dt1 dt2 with frame fr.
   hide frame fr.

   day-count = dt2 - dt1.
/**************************************************************************************/


if FileExist("cifrep2.log") then do:
   if not DeleteFile("cifrep2.log") then message "Ошибка при удалении временного файла." view-as alert-box.
end.

 run LoadGL.


 {comm-txb.i}

 run catlist(1).
 CurCat = return-value.
 if CurCat = "EXIT" then return.


 repname = "form2_" + comm-txb() + "_" + CurCat + "_" +   replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".html".


 input through cptwin value("/data/reports/categ/" + repname) iexplore.
 repeat:
   import v-result.
 end.


 if v-result = "" then do:
  return.
 end.


   for each b-cif where b-cif.del = no and b-cif.trw = CurCat no-lock by b-cif.cif:

     for each b-aaa where b-aaa.cif = b-cif.cif and b-aaa.regdt <= dt2 /*and b-aaa.sta <> "E" and b-aaa.sta <> "C"*/ no-lock:
        find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> "oda" no-lock no-error.
        if avail b-lgr then
        do:

          if b-aaa.sta = 'c' then
          do:
            find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
            if avail sub-cod then
            do:
              if sub-cod.rdt < dt1 then next.
            end.
            else next.

          end.

          create wrk.
                 wrk.cif = b-aaa.cif.
                 wrk.trw = b-cif.trw.
                 wrk.acc = b-aaa.aaa.
                 wrk.crc = b-aaa.crc.
                 CreateRec( wrk.cif , b-aaa.aaa , b-aaa.crc ,
                                  wrk.send-val ,
                                  wrk.send-val-count,
                                  wrk.conv-oper ,
                                  wrk.conv-oper-count,
                                  wrk.dam ,
                                  wrk.dam-count,
                                  wrk.cam ,
                                  wrk.cam-count,
                                  wrk.sr-bal,
                                  wrk.pass,
                                  wrk.activ ).

        end.

        hide message no-pause.
        message "Сбор данных - " LN[i] " " b-aaa.cif.
        if i = 8 then i = 1.
        else i = i + 1.

     end. /*for each b-aaa*/

   end. /*for each b-cif*/

 hide message no-pause.

 run ExportFile.

 v-result = "".
 input through value ("mv " + repname + " /data/reports/categ/" + repname ).
 repeat:
   import unformatted v-result.
 end.

 if v-result <> "" then do:
   message " Произошла ошибка при копировании отчета - " v-result.
 end.


if FileExist("cifrep2.log") then do:
    message "При формировании отчета произошли ошибки!~n Неопределенных платежей на сумму:" GetNormSumm( unknown ) view-as alert-box.
    LogFile("cifrep2.log","Неопределенных платежей на сумму:" + GetNormSumm( unknown ) ).
    unix silent cptwin cifrep2.log notepad.
end.


/***************************************************************************************************************/
procedure ExportFile.
    output to value(repname).
    {html-title.i}

    def var Caption as char init "Обороты, количество операций, среднемесячные остатки.".
    def var NameBank as char.
    def buffer b-cmp for cmp.
    def var FormatStr as char init ">>>>>>>>>>>>>>>>9.99".
   /* def var tmp-cif as char.*/
    find first b-cmp no-lock no-error.
    if avail b-cmp then
    do:
      NameBank = trim(b-cmp.name).
    end.

    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

    put unformatted "<tr><td align=center colspan=14><font size=""4""><b><a name="" ""></a>" Caption "  " NameBank "  С " GetDate(dt1) " ПО " GetDate(dt2) "</b></font></td></tr>" skip.

    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD width=120>" "Категория: " GetCatName( CurCat ) "</TD>" skip
                                "<TD width=60>" "Вид валюты" "</TD>" skip
                                "<TD width=200 colspan=\"2\">" "Переводы" "</TD>" skip
                                "<TD width=200 colspan=\"2\">" "Конвертация" "</TD>" skip
                                "<TD width=200 colspan=\"2\">" "Приход" "</TD>" skip
                                "<TD width=200 colspan=\"2\">" "Расход" "</TD>" skip
                                "<TD width=120>" "Среднемесячные остатки" "</TD>" skip
                                "<TD width=120>" "Количество действующих паспортов сделок" "</TD>" skip
                                "<TD width=120>" "Количество активных счетов в тенге" "</TD>" skip.

    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>"  "</TD>" skip
                                "<TD width=80>" "Кол-во" "</TD>" skip
                                "<TD width=120>" "Сумма" "</TD>" skip
                                "<TD width=80>" "Кол-во" "</TD>" skip
                                "<TD width=120>" "Сумма" "</TD>" skip
                                "<TD width=80>" "Кол-во" "</TD>" skip
                                "<TD width=120>" "Сумма" "</TD>" skip
                                "<TD width=80>" "Кол-во" "</TD>" skip
                                "<TD width=120>" "Сумма" "</TD>" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "KZT" "</TD>" skip
                                "<TD width=80>" string(GetCount(1,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(1,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(1,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(1,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(1,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(1,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(1,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(1,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(1),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(1)) "</TD>" skip
                                "<TD width=120>" string(GetKZTCount()) "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "USD" "</TD>" skip
                                "<TD width=80>" string(GetCount(2,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(2,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(2,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(2,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(2,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(2,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(2,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(2,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(2),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(2)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "EUR" "</TD>" skip
                                "<TD width=80>" string(GetCount(3,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(3,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(3,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(3,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(3,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(3,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(3,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(3,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(3),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(3)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "RUR" "</TD>" skip
                                "<TD width=80>" string(GetCount(4,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(4,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(4,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(4,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(4,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(4,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(4,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(4,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(4),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(4)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "GBP" "</TD>" skip
                                "<TD width=80>" string(GetCount(6,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(6,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(6,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(6,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(6,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(6,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(6,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(6,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(6),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(6)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "SEK" "</TD>" skip
                                "<TD width=80>" string(GetCount(7,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(7,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(7,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(7,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(7,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(7,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(7,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(7,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(7),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(7)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

      put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "AUD" "</TD>" skip
                                "<TD width=80>" string(GetCount(8,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(8,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(8,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(8,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(8,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(8,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(8,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(8,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(8),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(8)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "CHF" "</TD>" skip
                                "<TD width=80>" string(GetCount(9,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(9,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(9,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(9,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(9,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(9,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(9,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(9,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(9),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(9)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "ZAR" "</TD>" skip
                                "<TD width=80>" string(GetCount(10,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(10,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(10,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(10,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(10,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(10,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(10,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(10,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(10),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(10)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

     put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD width=120>"  "</TD>" skip
                                "<TD width=60>" "CAD" "</TD>" skip
                                "<TD width=80>" string(GetCount(11,"Переводы")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(11,"Переводы"),FormatStr) skip
                                "<TD width=80>"  string(GetCount(11,"Конвертация")) "</TD>" skip
                                "<TD width=120>"  string(GetPaySumm(11,"Конвертация"),FormatStr)  "</TD>" skip
                                "<TD width=80>"  string(GetCount(11,"Приход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(11,"Приход"),FormatStr) "</TD>" skip
                                "<TD width=80>"  string(GetCount(11,"Расход")) "</TD>" skip
                                "<TD width=120>" string(GetPaySumm(11,"Расход"),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetSrBal(11),FormatStr) "</TD>" skip
                                "<TD width=120>" string(GetPass(11)) "</TD>" skip
                                "<TD width=120>"  "</TD>" skip.

    def var comm-cred-all as deci init 0.
    def var supp-cred-all as deci init 0.
    def var kass-oper-all as deci init 0.
    def var send-kz-all as deci init 0.
    def var send-val-all as deci init 0.
    def var conv-oper-all as deci init 0.
    def var doc-oper-all as deci init 0.
    def var garan-oper-all as deci init 0.
    def var other-oper-all as deci init 0.

 /*   find first wrk no-lock no-error.
    tmp-cif = wrk.cif.
   */


/*
    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "Итого" "</TD>" skip
                                "<TD>" GetNormSumm(comm-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(supp-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(kass-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-kz-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-val-all) "</TD>" skip
                                "<TD>" GetNormSumm(conv-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(doc-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(garan-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(other-oper-all) "</TD>" skip.

*/

    put unformatted "</table>" .
    {html-end.i}
    output close.
    unix silent cptwin value(repname) iexplore.
    /*unix silent cptwin cifrep.html excel. */
end procedure.
/***************************************************************************************************************/

procedure LoadGL :
  empty temp-table gl_wrk.
  def buffer b-gl_wrk for gl_wrk.
  def var ktype as int.
  def var kpos as int.
  def buffer b-tarif2 for tarif2.
  def var TarCod as char extent 8 initial
                                 ["940,980,117,983,976,901,902,903,905,906,907,908,909,910", /* Комиссии по выданным кредитам*/
                                  "403,409,439,151,456,430,436,401,468,126,199", /*Кассовые операции */
                                  "214,215,163,019,017,202,222,111,112,147", /*Переводные операции в тенге*/
                                  "204,205,218,123,304,305,306", /*Переводные операции в ин.  валюте*/
                                  "804,802,808,803", /*Конвертация*/
                                  "970,995,996,971,997,998,999,910,972,960,961,962,963,964,965,966,967,968,969,952,953,954,955,956,957,958,959,941,942,943,944,945,946,947,911", /*Документарные операции*/
                                  "981,982,987,993,994,988,993,994,989,984,990,985,986", /*Гарантии*/
                                  "142,137,177,039,120,440,146,040,132,158,102,192,153,024,101,020,023,102,104,154,109,161,191"]. /*Прочие комиссии*/

  do ktype = 1 to 8:
    /* message TarCod[ktype] view-as alert-box.*/
    do kpos = 1 to NUM-ENTRIES(TarCod[ktype]):

        find first b-tarif2 where b-tarif2.num + b-tarif2.kod = trim(ENTRY(kpos,TarCod[ktype])) /* and b-tarif2.stat = 'r'*/ no-lock no-error.
        if avail b-tarif2 then do:
      /*
        find first b-gl_wrk where b-gl_wrk.gl = b-tarif2.kont and b-gl_wrk.type <> ktype no-lock no-error.
        if avail b-gl_wrk then
        do:
          message "Уже есть..." b-gl_wrk.gl "  cod = " b-gl_wrk.tarcod view-as alert-box.
        end.
        */
           create gl_wrk.
                  gl_wrk.type = ktype.
                  gl_wrk.gl = b-tarif2.kont.
                  gl_wrk.tarcod =  ENTRY(kpos,TarCod[ktype]).
                  gl_wrk.name = b-tarif2.pakalp.
                  find first gl where gl.gl = gl_wrk.gl no-lock no-error.
                  if avail gl then gl_wrk.crc = gl.crc.
        end.
        else do:
           message "Нет записей в тарификаторе с кодом " + ENTRY(kpos,TarCod[ktype]) + " !" view-as alert-box.
        end.

     /* message ENTRY(kpos,TarCod[ktype]) view-as alert-box.*/
    end.
  end.


end procedure.