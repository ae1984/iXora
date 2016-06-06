/* pkankvwlst.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Печать заголовков анкет по выборке во временной таблице
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-4-1
 * AUTHOR
        17.02.2003 nadejda
 * CHANGES
        09.12.2003 nadejda - добавлена печать даты решения Кредитного Комитета
        23.07.2004 saltanat - добавлен вывод полей - "Номер транзакции","Номер доходного счета по балансу".
        02.08.04 saltanat - Добавила проверку на вид кредита. 
                            Только если это Быстрые деньги, выводить номер транзакции и номер дох.счета по балансу.
*/

{global.i}
{pk.i}

def input parameter p-title as char.

def var numdxs as char.

def shared temp-table t-anks
  field ln like pkanketa.ln
  field rnn like pkanketa.rnn
  field rating like pkanketa.rating
  index ln is primary unique ln
  index rnn rnn.


def var v-repfile as char init "repanketa.htm".
def var v-refusname as char format "x(40)".
def var v-stsname as char.
def var v-i as integer.
define var v-card as char.
def var v-kredkom as char.

output to value(v-repfile).

find first cmp no-lock no-error.

{html-title.i 
 &stream = " "
 &title = " Список анкет по выборке"
 &size-add = "x-"
}

put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD>" cmp.name "<BR>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " " g-ofc "<BR></TD></TR>" skip
  "<TR><TD>" skip
  "<P align=""center""><B>" p-title "</B></P>" skip
  "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
  "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
    "<TD>N анк</TD>" skip
    "<TD>рейтинг</TD>" skip
    "<TD>ФИО</TD>" skip
    "<TD>причина отказа/ выдано</TD>" skip
    "<TD>банк</TD>" skip.

  case s-credtype :
    when "4" then 
        put unformatted 
         "<TD>вид карточки</TD>" skip
         "<TD>валюта счета</TD>" skip.
    otherwise     
        put unformatted 
        "<TD>код клиента</TD>" skip
        "<TD>ссудный счет</TD>" skip.
  end.

put unformatted 
    "<TD>сумма кредита</TD>" skip
    "<TD>цель кредита</TD>" skip
    "<TD>кред.комитет</TD>" skip
    "<TD>статус</TD>" skip.
if s-credtype = '6' then do:
    put unformatted 
    "<TD>номер транзакции</TD>" skip
    "<TD>номер дох.счета по балансу</TD>" skip.
end.
    put unformatted
    "<TD>дата рег</TD>" skip
    "<TD>кто рег</TD>" skip
  "</TR>" skip.

for each t-anks:
  find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype 
               and pkanketa.ln = t-anks.ln no-lock no-error.

  v-refusname = "".
  do v-i = 1 to num-entries(pkanketa.refusal):
    for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(v-i, pkanketa.refusal) no-lock:
      if v-refusname <> "" then v-refusname = v-refusname + ", ".
      v-refusname = v-refusname + bookcod.name.
    end.
  end.

  v-stsname = "".
  find bookcod where bookcod.bookcod = "pkstsank" and bookcod.code = pkanketa.sts no-lock no-error.
  if avail bookcod then v-stsname = bookcod.name.

  put unformatted 
    "<TR valign=""top"" style=""font:bold;font-size:x-small"" align=""left"">"
      "<TD>" string(pkanketa.ln) "</TD>" skip
      "<TD>" string(pkanketa.rating) "</TD>" skip
      "<TD>" pkanketa.name "</TD>" skip
      "<TD>" v-refusname "</TD>" skip
      "<TD>" pkanketa.bank "</TD>" skip.


  case s-credtype :
    when "4" then do:
        find bookcod where bookcod.bookcod = "kktype" and bookcod.code = trim(pkanketa.partner) no-lock no-error.
          if avail bookcod then v-card = bookcod.name.
                           else v-card = "".
        find crc where crc.crc = pkanketa.crc no-lock no-error.
        put unformatted 
          "<TD>" v-card "</TD>" skip
          "<TD>&nbsp;" crc.code "</TD>" skip.
    end.
    otherwise     
        put unformatted 
          "<TD>" pkanketa.cif "</TD>" skip
          "<TD>&nbsp;" pkanketa.lon "</TD>" skip.
  end.

  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and 
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
  if avail pkanketh and pkanketh.rescha[3] <> "" and num-entries(pkanketh.rescha[3]) > 1 then 
    v-kredkom = trim(entry(2, pkanketh.rescha[3])).
  else v-kredkom = "".


  find first jl where string(jl.gl) = "442900" and jl.jh = pkanketa.acc no-lock no-error.
  if avail jl then numdxs = string(jl.gl).
  else numdxs = "".

  put unformatted 
      "<TD>" replace(trim(string(pkanketa.summa, ">>>,>>>,>>>,>>9.99")), ",", "&nbsp;") "</TD>" skip
      "<TD>" pkanketa.goal "</TD>" skip
      "<TD>" string(date(v-kredkom), "99/99/9999") "</TD>" skip
      "<TD style=""font-size:xx-small"">" v-stsname "</TD>" skip.
if s-credtype = '6' then do:
      put unformatted
      "<TD>" pkanketa.acc "</TD>" skip
      "<TD>" numdxs "</TD>" skip.
end.
      put unformatted
      "<TD>" string(pkanketa.rdt, "99/99/9999") "</TD>" skip
      "<TD>" pkanketa.rwho "</TD>" skip
    "</TR>" skip.
end.
put unformatted "</TABLE>"
  "</TD></TR>"
  "</TABLE>" skip.

{html-end.i " " }

output close.
unix silent cptwin value(v-repfile) excel. 



