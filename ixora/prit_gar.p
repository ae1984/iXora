/* prit_gar.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Печать справки псоле открытия счета
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.2, 1.6.5, 1.6.6
 * AUTHOR
        ....... marinav
 * CHANGES
        16.06.2003 nadejda - переделала выдачу информации о банке внизу справки на взятую из параметров банка в sysc
        14.07.2003 nadejda - для Уральска слово "район" заменено на "область" 
        14.07.2003 nadejda - добавлен вариант входного параметра 3 - для переоткрытия счетов
        19.08.2003 nadejda - добавлен вывод валюты счета при открытии/переоткрытии
*/


def input parameter s-lon like aaa.aaa.
define input parameter fl as int.  /* признак операции со счетом - открыт, закрыт, переоткрыт */
/*
def var fl as int init 2.
def var s-lon like lon.lon.
s-lon = '005079629'.
*/

def shared var g-today as date.
def var v-rnn as char format "x(40)".
def var v-city as char.
def var v-sign as char.
def var v-bankfull as char.
def var i as integer.

define stream m-out.


find first cmp no-lock no-error.
v-city =  entry(1, cmp.addr[1]).

find first aaa where aaa.aaa = s-lon no-lock no-error.
find first cif where cif.cif = aaa.cif no-lock no-error.


find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "rnnsp" and sub-cod.ccode <> "msc" no-lock no-error.
if avail sub-cod then do:
  find codfr where codfr.codfr = "rnnsp" and codfr.code = sub-cod.ccode no-lock no-error.
  if avail codfr then v-rnn = codfr.name[1].
end.
else do:
  find codfr where codfr.codfr = "rnnsp" and codfr.code = substr(cif.jss, 1, 4) use-index cdco_idx no-lock no-error.
  if avail codfr then  v-rnn = codfr.name[1].
end.

/*для Уральска слово "район" заменено на "область" */
find sysc where sysc.sysc = "clecod" no-lock no-error.
if avail sysc and sysc.chval <> "194901964" then v-rnn = v-rnn + " район".

find sysc where sysc.sysc = "nkpar" no-lock no-error.
if not avail sysc then do:
  create sysc.
  assign sysc.sysc  = "NKPAR" 
         sysc.des   = "Подписи извещений в НК о счетах"
         sysc.chval = "Зам.главного бухгалтера".
  find current sysc no-lock.
end.
if num-entries(sysc.chval, "|") > 0 then v-sign = entry(1, sysc.chval, "|").

run defbnkreq (output v-bankfull).

find crc where crc.crc = aaa.crc no-lock no-error.

output stream m-out to rpt.html.

{html-title.i &stream = "stream m-out" &title = "METROCOMBANK" &size-add = "x-"}

do i = 1 to 2:
  run put_sprav.
end.

{html-end.i "stream m-out"}

output stream m-out close.
unix silent cptwin rpt.html winword.exe.

/*************************************************/

procedure put_sprav.

put stream m-out unformatted 
  "<table align=""center"" border=""0"" cellpadding=""0"" cellspacing=""3"" width=""95%"">" skip
    "<tr><td align=""right""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></td></tr><br><br>" skip
    "<tr><td align=""right""><h3>Налоговый комитет</h3></td></tr>" skip
    "<tr><td align=""right""><h3>" v-rnn "</h3></td></tr>"   skip
    "<tr><td align=""right""><h3>" v-city "</h3></td></tr></table>" skip
    "<P align=""justify"" style=""font-size:14.0pt"">" cmp.name " ставит Вас в известность о том, что " skip
    trim(trim(cif.prefix) + " " + trim(cif.name)) ", РНН&nbsp;" cif.jss ", " skip.

case fl :
  when 1 then
      put stream m-out unformatted 
        "открыт страховой депозит счет-гарантия N&nbsp;" s-lon " в&nbsp;" crc.code " с&nbsp;" string(g-today, "99.99.9999").
  when 2 then
      put stream m-out unformatted 
        "закрыт страховой депозит счет-гарантия N&nbsp;" s-lon " с&nbsp;" string(g-today, "99.99.9999") 
        " по причине погашения гарантии".
  when 3 then
      put stream m-out unformatted 
        "открыт страховой депозит счет-гарантия N&nbsp;" s-lon " в&nbsp;" crc.code " с&nbsp;" string(g-today, "99.99.9999") 
        " по причине: восстановление счета".
end case.

put stream m-out unformatted 
  ".</P><P style=""font-size:6.0pt"">&nbsp;</P>" skip
  "<P style=""font-size:14.0pt"">" v-sign "</P>" skip
  "<P style=""font-size:6.0pt"">&nbsp;</P>" skip
  "<HR noshade color=""black"" size=""3"">" skip
  "<P align=""center"" style=""font:bold; font-size:9.0pt"">" v-bankfull "</P>" skip
  "<P style=""font-size:6.0pt"">&nbsp;</P>" skip
  "<P style=""font-size:6.0pt"">&nbsp;</P>" skip
  "<P style=""font-size:6.0pt"">&nbsp;</P>" skip.
end procedure.

